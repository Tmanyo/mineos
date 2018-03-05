terminal_status = {}
terminal_task = {}

command = {}
terminal_text = ""

function terminal(player)
	local starter = {}
	starter = player:get_player_name() .. ">"
	desktop(player, files.theme[player:get_player_name()] ..
	"^terminal_overlay.png",
	"label[6.25,2;Terminal]" ..
	"image_button[9.65,1.98;.6,.4" .. get_button_style(player, "terminal",
	"white").close[player:get_player_name()] .. ";true;false;]" ..
	"image_button[9.25,1.95;.6,.45" .. get_button_style(player, "terminal",
	"white").min[player:get_player_name()] .. ";true;false;]" ..
	"field[3.8,5.1;6.45,1;command_input;;" .. minetest.formspec_escape(starter) .. "]" ..
	"field_close_on_enter[command_input;false]" ..
	"image_button[3,2.1;1.5,.5;;run;Run;true;false;]" ..
	"textlist[3.5,2.5;6.25,2.5;command_output;" .. minetest.formspec_escape(
	"#FF0000".. starter) .. wrap_textlist_text(terminal_text, 85) .. ";" ..
	#lines .. ";false]" ..
	current_tasks)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.close_terminal then
			end_task("terminal")
			desktop(player, files.theme[player:get_player_name()],
			current_tasks)
			terminal_text = ""
		end
		if fields.minimize_terminal then
			remember_notes(fields)
			terminal_status = "minimized"
			desktop(player, files.theme[player:get_player_name()],
			current_tasks)
		end
		if fields.terminal_task then
			active_task = "terminal"
			handle_tasks("terminal")
			change_tasks("terminal")
			if terminal_status == "minimized" then
				terminal(player)
				terminal_status = "maximized"
			else
				terminal_status = "minimized"
				desktop(player, files.theme[player:get_player_name()],
				current_tasks)
			end
		end
		if fields.run or fields.command_input then
			if fields.command_input == nil then
				return false
			elseif fields.command_input == player:get_player_name() .. ">" then
				return false
			end
			local not_program = {}
			local is_program = {}
			local program_string = ""
			local output = ""
			if fields.command_input:match(player:get_player_name() ..
			">.+") then
				command = fields.command_input:gsub(player:get_player_name() ..
				">", "")
			else
				command = ""
			end
			if command ~= "" then
				for k,v in pairs(programs) do
					if command == string.lower(v) then
						register_task(command)
						if command ~= "file_system" then
							current_tasks = current_tasks ..
							handle_tasks(command)
						end
						active_task = command
						--change_tasks("terminal")
						_G[command .. "_status"] =
						"minimized"
						terminal_status = "minimized"
						remember_notes(fields)
						if command == "email" then
							email(player, inbox_items(player))
						elseif command == "files_system" then
							file_system(player, files.Desktop)
						else
							_G[command](player)
						end
						is_program = 1
						terminal_text = terminal_text .. command ..
						", ,Application launched successfully., ," ..
						"#FF0000" .. player:get_player_name() .. ">"
					end
				end
				if is_program ~= 1 then
					not_program = 1
					is_program = {}
				end
				if not_program == 1 then
					for k,v in pairs(programs) do
						if k == #programs then
							program_string = program_string ..
							minetest.formspec_escape(", ") .. string.lower(v)
						elseif k ~= (#programs - 1) then
							program_string = program_string ..
							string.lower(v) .. minetest.formspec_escape(", ")
						else
							program_string = program_string .. "," ..
							string.lower(v)
						end
					end
					if command == "commands -a" then
						terminal_text = terminal_text .. command ..
						", ,Application: <application_name>," ..
						"Exit: exit,Application List: " ..
						program_string .. ",Player " ..
						"Information: info <name>" ..
						",Shutdown: shutdown," ..
						"Restart: restart," ..
						"Kill: kill <application_name>" ..
						",Kill All: kill -a" ..
						",Tasks: tasks" ..
						",Properties: properties <application_name>," ..
						",Properties All: properties -a" ..
						",MineOS Version: version"
					elseif command == "shutdown" then
						for k,v in pairs(tasks.name) do
							end_task(v)
						end
						minetest.close_formspec(player:get_player_name(), "mineos:desktop")
						current_tasks = ""
						terminal_text = ""
						clicks = 0
					elseif command == "restart" then
						for k,v in pairs(tasks.name) do
							end_task(v)
						end
						minetest.close_formspec(player:get_player_name(), "mineos:desktop")
						current_tasks = ""
						clicks = 0
						minetest.after(3, function()
							desktop(player, "default", current_tasks)
						end)
						terminal_text = ""
					elseif command:match("^kill .+") then
						local success = {}
						local application_to_kill = command:sub(command:find(" ") + 1,
						command:len())
						if application_to_kill == "-a" then
							tasks.name = {}
							counter = 0
							success = 1
							register_task("terminal")
							current_tasks = handle_tasks("terminal")
						else
							for k,v in pairs(tasks.name) do
								if v == application_to_kill then
									end_task(application_to_kill)
									success = 1
								end
							end
						end
						if success ~= 1 then
							application_to_kill = "unknown"
						end
						local message = {}
						if application_to_kill == "-a" then
							message = "All applications"
						elseif application_to_kill == "unknown" then
							message = "Task not found."
						else
							message = application_to_kill:gsub("^%l",
							application_to_kill:sub(1,1):upper())
						end
						if message == "Task not found." then
							terminal_text = terminal_text .. command ..
							", ," .. message
						else
							terminal_text = terminal_text .. command ..
							", ," .. message .. " successfully stopped."
						end
						success = {}
					elseif command == "tasks" then
						terminal_text = terminal_text .. command ..
						", ,Current Tasks:"
						for k,v in pairs(tasks.name) do
							if k ~= #tasks.name then
								terminal_text = terminal_text ..
								"," .. v .. ","
							else
								terminal_text = terminal_text ..
								"," .. v
							end
						end
					elseif command:match("^properties .+") then
						local file = {}
						local application = {}
						application = command:sub(12, command:len())
						if application ~= "-a" then
							for k,v in pairs(programs) do
								if string.lower(v) == application then
									file = io.open(minetest.get_modpath(
									"mineos") .. "/" .. application .. ".lua", "r")
								end
							end
							if type(file) ~= "table" then
								terminal_text = terminal_text .. command ..
								", ," .. application .. ".lua size: " ..
								file:seek("end") * (10^-3) .. " KB"
								file:close()
							else
								terminal_text = terminal_text .. command ..
								", ," .. application .. " could not be found."
							end
						else
							local total = 0
							local all_files = minetest.get_dir_list(
							minetest.get_modpath("mineos"), false)
							for k,v in pairs(all_files) do
								local file = io.open(minetest.get_modpath("mineos") ..
								"/" .. v, "r")
								total = total + (file:seek("end") * (10^-3))
								file:close()
								file = {}
							end
							terminal_text = terminal_text .. command ..
							", ,Mineos size (excluding textures and sounds): " ..
							total .. " KB"
						end
					elseif command == "version" then
						terminal_text = terminal_text ..
						command .. ", ," .. version
					elseif command:match("info .+") then
						local player_name = command:sub(
						command:find(" ",5) + 1, command:len())
						if minetest.player_exists(player_name) == true then
							if player_name == player:get_player_name() then
								terminal_text = terminal_text .. command ..
								", ,Uptime: " .. minetest.get_player_information(
								player_name).connection_uptime .. ",IP " ..
								"Address: " .. minetest.get_player_information(
								player_name).address
							else
								if minetest.get_connected_players()[player_name] then
									terminal_text = terminal_text .. command ..
									", ,Uptime: " .. minetest.get_player_information(
									player_name).connection_uptime .. ",IP " ..
									"Address: " .. minetest.get_player_information(
									player_name).address
								else
									terminal_text = terminal_text .. command ..
									", ,Player exists" ..
									minetest.formspec_escape(",") .. " but" ..
									" is not currently online."
									terminal(player)
								end
							end
						else
							terminal_text = terminal_text .. command ..
							", ,Player does not exist."
							terminal(player)
						end
					else
						terminal_text = terminal_text .. command .. ", ,Unknown Command"
					end
					if terminal_text:match("Password for sudo:, ," .. player:get_player_name() ..
					">$") then
						if minetest.check_player_privs(
						player:get_player_name()).server == true then
							terminal_text = terminal_text .. command ..
							", ,Uptime: " .. minetest.get_player_information(
							player_name).connection_uptime .. ",IP " ..
							"Address: " .. minetest.get_player_information(
							player_name).address
						end
					end
					terminal_text = terminal_text ..
					", ,#FF0000" .. player:get_player_name() .. ">"
					terminal(player)
					if command == "exit" then
						end_task("terminal")
						desktop(player, files.theme[player:get_player_name()],
						current_tasks)
						terminal_text = ""
					end
				end
			else
				terminal_text = terminal_text ..
				", ,Unknown Command, ,#FF0000" .. player:get_player_name() ..
				">"
				terminal(player)
			end
		end
	end
end)
