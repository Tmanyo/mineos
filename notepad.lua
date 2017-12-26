local a = 0
local status = {}
local text = {}

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.notepad then
			desktop(player, "default_notepad",
			"image_button[2.4,1.53;.75,.3;;save_notes;Save;true;false;]" ..
			"image_button[3,1.53;.75,.3;;open_notes;Open;true;false;]" ..
			"image_button[7.4,1.53;.5,.3;;minimize_np;--;true;false;]" ..
			"image_button[7.7,1.5;.5,.4;maximize_w.png;maximize_np;;true;false;]" ..
			"image_button[8,1.53;.5,.3;;close_notepad;X;true;false;]" ..
			"textarea[2.7,2;6,5.3;notes;;]" ..
			"image_button[1.5,8.25;.75,.75;notepad.png;notepad_task;;true;false;]")
		end
		if fields.save_notes then
			a = a + 1
			if a == 1 then
				desktop(player, "default_notepad",
				"image_button[2.4,1.53;.75,.3;;save_notes;Save;true;false;]" ..
				"image_button[3,1.53;.75,.3;;open_notes;Open;true;false;]" ..
				"image_button[7.4,1.53;.5,.3;;minimize_np;--;true;false;]" ..
				"image_button[7.7,1.5;.5,.4;maximize_w.png;maximize_np;;true;false;]" ..
				"image_button[8,1.53;.5,.3;;close_notepad;X;true;false;]" ..
				"textarea[2.7,2;6,5.3;notes;;" .. fields.notes .. "]" ..
				"field[2.7,7.5;4,1;filename;Filename: (Enter filename then press save again.);]" ..
				"image_button[1.5,8.25;.75,.75;notepad.png;notepad_task;;true;false;]")
			else
				files.Documents[fields.filename .. ".mn"] = {}
				table.insert(files.Documents[fields.filename .. ".mn"], fields.notes)
				save_files()
				a = 0
				desktop(player, "default_notepad",
				"image_button[2.4,1.53;.75,.3;;save_notes;Save;true;false;]" ..
				"image_button[3,1.53;.75,.3;;open_notes;Open;true;false;]" ..
				"image_button[7.4,1.53;.5,.3;;minimize_np;--;true;false;]" ..
				"image_button[7.7,1.5;.5,.4;maximize_w.png;maximize_np;;true;false;]" ..
				"image_button[8,1.53;.5,.3;;close_notepad;X;true;false;]" ..
				"textarea[2.7,2;6,5.3;notes;;" .. fields.notes .. "]" ..
				"image_button[1.5,8.25;.75,.75;notepad.png;notepad_task;;true;false;]")
			end
		end
		if fields.close_notepad then
			desktop(player, "default", "")
		end
		if fields.minimize_np then
			desktop(player, "default",
			"image_button[1,8.25;.75,.75;notepad.png;notepad_task;;true;false;]")
			status = "minimized"
			text = fields.notes
		end
		if fields.notepad_task then
			if status == "minimized" then
				desktop(player, "default_notepad",
				"image_button[2.4,1.53;.75,.3;;save_notes;Save;true;false;]" ..
				"image_button[3,1.53;.75,.3;;open_notes;Open;true;false;]" ..
				"image_button[7.4,1.53;.5,.3;;minimize_np;--;true;false;]" ..
				"image_button[7.7,1.5;.5,.4;maximize_w.png;maximize_np;;true;false;]" ..
				"image_button[8,1.53;.5,.3;;close_notepad;X;true;false;]" ..
				"textarea[2.7,2;6,5.3;notes;;" .. text .. "]" ..
				"image_button[1,8.25;.75,.75;notepad.png;notepad_task;;true;false;]")
				status = "maximized"
			else
				desktop(player, "default",
				"image_button[1,8.25;.75,.75;notepad.png;notepad_task;;true;false;]")
				status = "minimized"
				text = fields.notes
			end
		end
		if fields.maximize_np then
			maximized(player, "full_notepad",
			"image_button[0,0;.75,.3;;save_notes;Save;true;false;]" ..
			"image_button[.6,0;.75,.3;;open_notes;Open;true;false;]" ..
			"image_button[9.9,0;.5,.3;;minimize_np;--;true;false;]" ..
			"image_button[10.2,-.05;.5,.4;window_w.png;window_np;;true;false;]" ..
			"image_button[10.5,0;.5,.3;;close_notepad;X;true;false;]" ..
			"textarea[.25,.5;11,8.5;notes;;" .. fields.notes .. "]" ..
			"image_button[1,8.25;.75,.75;notepad.png;notepad_task;;true;false;]")
		end
		if fields.window_np then
			desktop(player, "default_notepad",
			"image_button[2.4,1.53;.75,.3;transparent.png;save_notes;Save;true;false;]" ..
			"image_button[3,1.53;.75,.3;transparent.png;open_notes;Open;true;false;]" ..
			"image_button[7.4,1.53;.5,.3;;minimize_np;--;true;false;]" ..
			"image_button[7.7,1.5;.5,.4;maximize_w.png;maximize_np;;true;false;]" ..
			"image_button[8,1.53;.5,.3;;close_notepad;X;true;false;]" ..
			"textarea[2.7,2;6,5.3;notes;;" .. fields.notes .. "]" ..
			"image_button[1,8.25;.75,.75;notepad.png;notepad_task;;true;false;]")
		end
	end
end)
