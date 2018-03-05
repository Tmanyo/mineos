--[[
	Mineos Notepad Version 1
	Contributors:
		Code & Textures: Tmanyo
		Textures: DI3HARD139
--]]

local maximize = {}
local a = 0
notepad_status = {}
text = ""
notepad_task = {}

function notepad(player, perform)
	if perform then
		perform  = perform
	else
		perform = ""
	end
	if maximize ~= true then
		desktop(player, files.theme[player:get_player_name()] ..
		"^notepad_overlay.png",
		"image_button[2.4,1.53;.75,.3;;save_notes;Save;true;false;]" ..
		"image_button[3,1.53;.75,.3;;open_notes;Open;true;false;]" ..
		"image_button[7.15,1.42;.6,.45" .. get_button_style(player,
		"notepad", "white").min[player:get_player_name()] .. ";true;false;]" ..
		"image_button[7.55,1.42;.6,.45" .. get_button_style(player,
		"notepad", "white").max[player:get_player_name()] .. ";true;false;]" ..
		"image_button[7.95,1.45;.6,.4" .. get_button_style(player,
		"notepad", "white").close[player:get_player_name()] .. ";true;false;]" ..
		"textarea[2.7,2;6,5.3;notes;;" .. minetest.formspec_escape(text) .. "]" ..
		current_tasks ..
		perform)
	else
		maximized(player, "full_notepad",
		"image_button[0,0;.75,.3;;save_notes;Save;true;false;]" ..
		"image_button[.6,0;.75,.3;;open_notes;Open;true;false;]" ..
		"image_button[9.7,-.1;.6,.45" .. get_button_style(player,
		"notepad", "white").min[player:get_player_name()] .. ";true;false;]" ..
		"image_button[10.1,-.1;.6,.45" .. get_button_style(player,
		"notepad", "white").win[player:get_player_name()] .. ";true;false;]" ..
		"image_button[10.5,-.07;.6,.4" .. get_button_style(player,
		"notepad", "white").close[player:get_player_name()] .. ";true;false;]" ..
		"textarea[.25,.5;11,8.5;notes;;" .. minetest.formspec_escape(text) .. "]" ..
		current_tasks)
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.notepad then
			if not current_tasks:match("notepad") then
				register_task("notepad")
				handle_tasks("notepad")
				current_tasks = current_tasks .. notepad_task
			end
			active_task = "notepad"
			notepad_status = "minimized"
			change_tasks("notepad")
			notepad(player)
		end
		if not fields.save_notes then
			a = 0
		end
		if fields.save_notes then
			a = a + 1
			if a == 1 then
				text = fields.notes
				maximize = false
				notepad(player, "field[2.7,7.5;4,1;filename;" ..
				"Filename: (Enter filename then press save again.);]")
			else
				if not files.Documents[player:get_player_name()] then
					files.Documents[player:get_player_name()] = {}
				end
				if fields.filename ~= "" and not
				fields.filename:match(" ") then
					local save_name = ""
					local n = 0
					for k,v in pairs(files.Documents[player:
					get_player_name()]) do
						if v:match(".+%.mn"):
						gsub("%.mn", "") == fields.filename then
							n = n + 1
							fields.filename = fields.filename:
							gsub("%(%d%)", "") .. "(" .. n .. ")"
							if k == #files.Documents[player:
							get_player_name()] then
								save_name = fields.filename:
								gsub("()", "")
							end
						else
							save_name = fields.filename
						end
					end
					table.insert(files.Documents[player:
					get_player_name()], save_name ..
					".mn - "  .. fields.notes)
					save_files()
					a = 0
					remember_notes(fields)
					notepad(player)
				end
			end
		end
		if fields.open_notes then
			text = ""
			a = 0
			register_task("file_system")
			file_system_status = "minimized"
			active_task = "file_system"
			change_tasks("file_system")
			end_task("notepad")
			file_system(player, files.Documents[player:get_player_name()])
			for k,v in pairs(files.Documents[player:get_player_name()]) do
				table.insert(results, v)
			end
		end
		if fields.close_notepad then
			maximize = false
			text = ""
			end_task("notepad")
			desktop(player, files.theme[player:get_player_name()],
			current_tasks)
		end
		if fields.minimize_notepad then
			a = 0
			remember_notes(fields)
			desktop(player, files.theme[player:get_player_name()],
			current_tasks)
			notepad_status = "minimized"
		end
		if fields.notepad_task then
			active_task = "notepad"
			change_tasks("notepad")
			if notepad_status == "minimized" then
				notepad(player)
				notepad_status = "maximized"
			else
				text = fields.notes
				desktop(player, files.theme[player:get_player_name()],
				current_tasks)
				notepad_status = "minimized"
			end
		end
		if fields.maximize_notepad then
			a = 0
			maximize = true
			notepad(player)
		end
		if fields.window_notepad then
			maximize = false
			notepad(player)
		end
	end
end)
