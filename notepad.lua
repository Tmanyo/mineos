--[[
	Mineos Notepad Version 1
	Contributors:
		Code & Textures: Tmanyo
		Textures: DI3HARD139
--]]

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
	desktop(player, "default_notepad",
	"image_button[2.4,1.53;.75,.3;;save_notes;Save;true;false;]" ..
	"image_button[3,1.53;.75,.3;;open_notes;Open;true;false;]" ..
	"image_button[7.4,1.53;.35,.295;minimize_w.png;minimize_np;;true;false;]" ..
	"image_button[7.7,1.53;.38,.297;maximize_w.png;maximize_np;;true;false;]" ..
	"image_button[8,1.53;.38,.297;close_w.png;close_notepad;;true;false;]" ..
	"textarea[2.7,2;6,5.3;notes;;" .. minetest.formspec_escape(text) .. "]" ..
	current_tasks ..
	perform)
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
			notepad(player)
		end
		if fields.save_notes then
			a = a + 1
			if a == 1 then
				text = fields.notes
				notepad(player, "field[2.7,7.5;4,1;filename;Filename: (Enter filename then press save again.);]")
			else
				if not files.Documents[player:get_player_name()] then
					files.Documents[player:get_player_name()] = {}
				end
				table.insert(files.Documents[player:get_player_name()], fields.filename .. ".mn" .. " - "  .. fields.notes)
				save_files()
				a = 0
				notepad(player)
			end
		end
		if fields.open_notes then
			register_task("file_system")
			file_system_status = "minimized"
			active_task = "file_system"
			change_tasks("file_system")
			end_task("notepad")
			file_system(player, files.Documents[player:get_player_name()])
			view = "documents"
		end
		if fields.close_notepad then
			text = ""
			end_task("notepad")
			desktop(player, "default", current_tasks)
		end
		if fields.minimize_np then
			remember_notes(fields)
			desktop(player, "default", current_tasks)
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
				desktop(player, "default", current_tasks)
				notepad_status = "minimized"
			end
		end
		if fields.maximize_np then
			maximized(player, "full_notepad",
			"image_button[0,0;.75,.3;;save_notes;Save;true;false;]" ..
			"image_button[.6,0;.75,.3;;open_notes;Open;true;false;]" ..
			"image_button[9.9,0;.35,.295;minimize_w.png;minimize_np;;true;false;]" ..
			"image_button[10.2,0;.38,.297;window_w.png;window_np;;true;false;]" ..
			"image_button[10.5,0;.38,.297;close_w.png;close_notepad;;true;false;]" ..
			"textarea[.25,.5;11,8.5;notes;;" .. minetest.formspec_escape(text) .. "]" ..
			current_tasks)
		end
		if fields.window_np then
			notepad(player)
		end
	end
end)
