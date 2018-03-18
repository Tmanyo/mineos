--[[
	Mineos Notepad Version 1
	Contributors:
		Code & Textures: Tmanyo
		Textures: DI3HARD139
--]]

local maximize_notepad = {}
local a = {}
text = {}
notepad_status = {}
notepad_task = {}

minetest.register_on_joinplayer(function(player)
	notepad_status[player:get_player_name()] = {}
	notepad_task[player:get_player_name()] = {}
	a[player:get_player_name()] = 0
	maximize_notepad[player:get_player_name()] = {}
	if not files.Documents[player:get_player_name()] then
		files.Documents[player:get_player_name()] = {}
	end
end)

function notepad(player, perform)
	if perform then
		perform  = perform
	else
		perform = ""
	end
	if not text[player:get_player_name()] then
		text[player:get_player_name()] = ""
	end
	if maximize_notepad[player:get_player_name()] ~= true then
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
		"textarea[2.7,2;6,5.3;notes;;" .. minetest.formspec_escape(text[
		player:get_player_name()]) .. "]" ..
		current_tasks[player:get_player_name()] ..
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
		"textarea[.25,.5;11,8.5;notes;;" .. minetest.formspec_escape(text[
		player:get_player_name()]) .. "]" ..
		current_tasks[player:get_player_name()])
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.notepad then
			if not current_tasks[player:get_player_name()]:match("notepad") then
				register_task("notepad", player)
				handle_tasks("notepad", player)
				current_tasks[player:get_player_name()] = current_tasks[player:get_player_name()] .. notepad_task[player:get_player_name()]
			end
			active_task[player:get_player_name()] = "notepad"
			notepad_status[player:get_player_name()] = "minimized"
			change_tasks("notepad", player)
			notepad(player)
		end
		if not fields.save_notes then
			a[player:get_player_name()] = 0
		end
		if fields.save_notes then
			a[player:get_player_name()] = a[player:get_player_name()] + 1
			if a[player:get_player_name()] == 1 then
				text[player:get_player_name()] = fields.notes
				maximize_notepad[player:get_player_name()] = false
				notepad(player, "field[2.7,7.5;4,1;filename;" ..
				"Filename: (Enter filename then press save again.);]")
			else
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
						end
					end
					if save_name == "" then
						save_name = fields.filename
					end
					table.insert(files.Documents[player:
					get_player_name()], save_name ..
					".mn - "  .. fields.notes)
					save_files()
					a[player:get_player_name()] = 0
					remember_notes(fields, player)
					notepad(player)
				end
			end
		end
		if fields.open_notes then
			text[player:get_player_name()] = ""
			a[player:get_player_name()] = 0
			register_task("file_system", player)
			file_system_status[player:get_player_name()] = "minimized"
			active_task[player:get_player_name()] = "file_system"
			change_tasks("file_system", player)
			end_task("notepad", player)
			file_system(player, files.Documents[player:get_player_name()])
			for k,v in pairs(files.Documents[player:get_player_name()]) do
				table.insert(results[player:get_player_name()], v)
			end
		end
		if fields.close_notepad then
			maximize_notepad[player:get_player_name()] = false
			text[player:get_player_name()] = ""
			end_task("notepad", player)
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
		end
		if fields.minimize_notepad then
			a[player:get_player_name()] = 0
			remember_notes(fields, player)
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
			notepad_status[player:get_player_name()] = "minimized"
		end
		if fields.notepad_task then
			active_task[player:get_player_name()] = "notepad"
			change_tasks("notepad", player)
			if notepad_status[player:get_player_name()] == "minimized" then
				notepad(player)
				notepad_status[player:get_player_name()] = "maximized"
			else
				text[player:get_player_name()] = fields.notes
				desktop(player, files.theme[player:get_player_name()],
				current_tasks[player:get_player_name()])
				notepad_status[player:get_player_name()] = "minimized"
			end
		end
		if fields.maximize_notepad then
			a[player:get_player_name()] = 0
			maximize_notepad[player:get_player_name()] = true
			notepad(player)
		end
		if fields.window_notepad then
			maximize_notepad[player:get_player_name()] = false
			notepad(player)
		end
	end
end)
