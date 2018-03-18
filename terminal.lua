terminal_status = {}
terminal_task = {}
command = {}
terminal_text = {}

minetest.register_on_joinplayer(function(player)
	terminal_status[player:get_player_name()] = {}
	terminal_task[player:get_player_name()] = {}
	terminal_text[player:get_player_name()] = ""
	command[player:get_player_name()] = {}
end)

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
	"#FF0000".. starter) .. wrap_textlist_text(terminal_text[player:get_player_name()], 85) .. ";" ..
	#lines .. ";false]" ..
	current_tasks[player:get_player_name()])
end

function terminal_return(player, output)
	terminal_text[player:get_player_name()] = terminal_text[player:get_player_name()] ..
	command[player:get_player_name()] .. ", ," .. output
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.close_terminal then
			end_task("terminal", player)
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
			terminal_text[player:get_player_name()] = ""
		end
		if fields.minimize_terminal then
			remember_notes(fields, player)
			terminal_status[player:get_player_name()] = "minimized"
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
		end
		if fields.terminal_task then
			active_task[player:get_player_name()] = "terminal"
			handle_tasks("terminal", player)
			change_tasks("terminal", player)
			if terminal_status[player:get_player_name()] == "minimized" then
				terminal(player)
				terminal_status[player:get_player_name()] = "maximized"
			else
				terminal_status[player:get_player_name()] = "minimized"
				desktop(player, files.theme[player:get_player_name()],
				current_tasks[player:get_player_name()])
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
				command[player:get_player_name()] = fields.command_input:gsub(player:get_player_name() ..
				">", "")
			else
				command[player:get_player_name()] = ""
			end
			if command[player:get_player_name()] ~= "" then
				for k,v in pairs(programs) do
					if command[player:get_player_name()] == string.lower(v) then
						register_task(command[player:get_player_name()], player)
						if command[player:get_player_name()] ~= "file_system" then
							current_tasks[player:get_player_name()] = current_tasks[player:get_player_name()] ..
							handle_tasks(command[player:get_player_name()], player)
						end
						active_task[player:get_player_name()] = command[player:get_player_name()]
						--change_tasks("terminal", player)
						_G[command[player:get_player_name()] .. "_status"][player:get_player_name()] =
						"minimized"
						terminal_status[player:get_player_name()] = "minimized"
						remember_notes(fields, player)
						if command[player:get_player_name()] == "email" then
							email(player, inbox_items(player))
						elseif command[player:get_player_name()] == "files_system" then
							file_system(player, files.Desktop)
						else
							_G[command[player:get_player_name()]](player)
						end
						is_program = 1
						terminal_return(player, "Application launched successfully., ," ..
						"#FF0000" .. player:get_player_name() .. ">")
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
					if command[player:get_player_name()] == "commands -a" then
						terminal_return(player, "Application: <application_name>," ..
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
						",MineOS Version: version" ..
						",Add Picture: picture -n <name>" ..
						",Delete Picture: picture -d <name>")
					elseif command[player:get_player_name()] == "shutdown" then
						for k,v in pairs(tasks.name[player:get_player_name()]) do
							end_task(v, player)
						end
						minetest.close_formspec(player:get_player_name(), "mineos:desktop")
						current_tasks[player:get_player_name()] = ""
						terminal_text[player:get_player_name()] = ""
						clicks = 0
					elseif command[player:get_player_name()] == "restart" then
						for k,v in pairs(tasks.name[player:get_player_name()]) do
							end_task(v, player)
						end
						minetest.close_formspec(player:get_player_name(), "mineos:desktop")
						current_tasks[player:get_player_name()] = ""
						clicks = 0
						minetest.after(3, function()
							desktop(player, "default", current_tasks[player:get_player_name()])
						end)
						terminal_text[player:get_player_name()] = ""
					elseif command[player:get_player_name()]:match("^kill .+") then
						local success = {}
						local application_to_kill = command[player:get_player_name()]:sub(command[player:get_player_name()]:find(" ") + 1,
						command[player:get_player_name()]:len())
						if application_to_kill == "-a" then
							tasks.name[player:get_player_name()] = {}
							counter[player:get_player_name()] = 0
							success = 1
							register_task("terminal", player)
							current_tasks[player:get_player_name()] = handle_tasks("terminal", player)
						else
							for k,v in pairs(tasks.name[player:get_player_name()]) do
								if v == application_to_kill then
									end_task(application_to_kill, player)
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
							terminal_return(player, message)
						else
							terminal_return(player, message ..
							" successfully stopped.")
						end
						success = {}
					elseif command[player:get_player_name()] == "tasks" then
						terminal_return(player, "Current Tasks:")
						for k,v in pairs(tasks.name[player:get_player_name()]) do
							if k ~= #tasks.name[player:get_player_name()] then
								terminal_text[player:get_player_name()] = terminal_text[player:get_player_name()] ..
								"," .. v .. ","
							else
								terminal_text[player:get_player_name()] = terminal_text[player:get_player_name()] ..
								"," .. v
							end
						end
					elseif command[player:get_player_name()]:match("^properties .+") then
						local file = {}
						local application = {}
						application = command[player:get_player_name()]:sub(12, command[player:get_player_name()]:len())
						if application ~= "-a" then
							for k,v in pairs(programs) do
								if string.lower(v) == application then
									file = io.open(minetest.get_modpath(
									"mineos") .. "/" .. application .. ".lua", "r")
								end
							end
							if type(file) ~= "table" then
								terminal_return(player, application .. ".lua size: " ..
								file:seek("end") * (10^-3) .. " KB")
								file:close()
							else
								terminal_return(player, application .. " could not be found.")
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
							terminal_return(player, "Mineos size (excluding textures and sounds): " ..
							total .. " KB")
						end
					elseif command[player:get_player_name()] == "version" then
						terminal_return(player, version)
					elseif command[player:get_player_name()]:match("picture %-n .+") then
						if not command[player:get_player_name()]:match("%.png") then
							terminal_return(player, "Invalid image name.")
						else
							table.insert(files.Pictures, command[player:get_player_name()]:
							sub(12, command[player:get_player_name()]:len()))
							terminal_return(player, "Picture successfully registered.")
							save_files()
						end
					elseif command[player:get_player_name()]:match("picture %-d .+") then
						local pic_index = {}
						for k,v in pairs(files.Pictures) do
							if v == command[player:get_player_name()]:
							sub(12, command[player:get_player_name()]:len()) then
								pic_index = k
							end
						end
						if type(pic_index) ~= "table" then
							table.remove(files.Pictures, pic_index)
							save_files()
							terminal_return(player, "Picture successfully deleted.")
						else
							terminal_return(player, "Picture does not exist.")
						end
					elseif command[player:get_player_name()]:match("info .+") then
						local player_name = command[player:get_player_name()]:sub(
						command[player:get_player_name()]:find(" ",5) + 1, command[player:get_player_name()]:len())
						if minetest.player_exists(player_name) == true then
							if player_name == player:get_player_name() then
								terminal_return(player, "Uptime: " .. minetest.get_player_information(
								player_name).connection_uptime .. ",IP " ..
								"Address: " .. minetest.get_player_information(
								player_name).address)
							else
								if minetest.get_connected_players()[player_name] then
									terminal_return(player, "Uptime: " .. minetest.get_player_information(
									player_name).connection_uptime .. ",IP " ..
									"Address: " .. minetest.get_player_information(
									player_name).address)
								else
									terminal_return(player, "Player exists" ..
									minetest.formspec_escape(",") .. " but" ..
									" is not currently online.")
									terminal(player)
								end
							end
						else
							terminal_return(player, "Player does not exist.")
							terminal(player)
						end
					else
						terminal_return(player, "Unknown Command")
					end
					terminal_text[player:get_player_name()] = terminal_text[player:get_player_name()] ..
					", ,#FF0000" .. player:get_player_name() .. ">" 
					terminal(player)
					if command[player:get_player_name()] == "exit" then
						end_task("terminal", player)
						desktop(player, files.theme[player:get_player_name()],
						current_tasks[player:get_player_name()])
						terminal_text[player:get_player_name()] = ""
					end
				end
			else
				terminal_return(player, "Unknown Command, ,#FF0000" ..
				player:get_player_name() .. ">")
				terminal(player)
			end
		end
	end
end)
