local maximize_pic_viewer = {}
image_to_display = {}
pic_viewer_task = {}
pic_viewer_status = {}

minetest.register_on_joinplayer(function(player)
	pic_viewer_task[player:get_player_name()] = {}
	pic_viewer_status[player:get_player_name()] = {}
	maximize_pic_viewer[player:get_player_name()] = {}
	image_to_display[player:get_player_name()] = {}
end)

function get_pictures()
	local s = ""
	for k,v in pairs(files.Pictures) do
		if k == 1 then
			s = v
		else
			s = s .. "," .. v
		end
	end
	return s
end

function pic_viewer(player)
	local index = {}
	local image = {}
	local picture_list = {}
	if type(image_to_display[player:get_player_name()]) ~= "table" then
		picture_list = minetest.get_dir_list(minetest.get_modpath(
		"mineos") .. "/textures")
		for k,v in pairs(picture_list) do
			if image_to_display[player:get_player_name()] == v then
				index = k
			else
				if maximize_pic_viewer[player:get_player_name()] ~= true then
					image = "label[5,5;Failed to load \"" ..
					image_to_display[player:get_player_name()] .. "\".]"
				else
					image = "label[4.5,4;Failed to load \"" ..
					image_to_display[player:get_player_name()] .. "\".]"
				end
			end
		end
		if picture_list[index] == image_to_display[player:get_player_name()] then
			if maximize_pic_viewer[player:get_player_name()] ~= true then
				image = "image[3.5,3;6,5;" .. image_to_display[player:get_player_name()] .. "]"
			else
				image = "image[1,.5;11,8;" .. image_to_display[player:get_player_name()] .. "]"
			end
		end
	else
		local pos = ""
		if maximize_pic_viewer[player:get_player_name()] ~= true then
			pos = "4.5,5"
		else
			pos = "4,4"
		end
		image = "label[" .. pos .. ";Click the Open button to open a picture!]"
	end
	if maximize_pic_viewer[player:get_player_name()] ~= true then
		desktop(player, files.theme[player:get_player_name()] ..
		"^pic_viewer_overlay.png",
		"image_button[1.5,2.6;1,.5;;open_pics;Open;true;false;]" ..
		"image_button[2.3,2.6;1,.5;;close_pics;Close;true;false;]" ..
		"image_button[9.35,2.55;.6,.45" .. get_button_style(player,
		"pic_viewer", "white").min[player:get_player_name()] ..
		";true;false;]" ..
		"image_button[9.75,2.55;.6,.45" .. get_button_style(player,
		"pic_viewer", "white").max[player:get_player_name()] ..
		";true;false;]" ..
		"image_button[10.15,2.58;.6,.4" .. get_button_style(player,
		"pic_viewer", "white").close[player:get_player_name()] ..
		";true;false;]" ..
		image ..
		current_tasks[player:get_player_name()])
	else
		maximized(player, "maximized_pic_viewer",
		"image_button[0,0;1,.5;;open_pics;Open;true;false;]" ..
		"image_button[1,0;1,.5;;close_pics;Close;true;false;]" ..
		"image_button[9.65,-.11;.6,.45" .. get_button_style(player,
		"pic_viewer", "white").min[player:get_player_name()] ..
		";true;false;]" ..
		"image_button[10.05,-.11;.6,.45" .. get_button_style(player,
		"pic_viewer", "white").win[player:get_player_name()] ..
		";true;false;]" ..
		"image_button[10.45,-.08;.6,.4" .. get_button_style(player,
		"pic_viewer", "white").close[player:get_player_name()] ..
		";true;false;]" ..
		image ..
		current_tasks[player:get_player_name()])
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.pic_viewer then
			remember_notes(fields, player)
			if not current_tasks[player:get_player_name()]:match("pic_viewer") then
				register_task("pic_viewer", player)
				handle_tasks("pic_viewer", player)
				current_tasks[player:get_player_name()] = current_tasks[player:get_player_name()] .. pic_viewer_task[player:get_player_name()]
			end
			active_task[player:get_player_name()] = "pic_viewer"
			pic_viewer_status[player:get_player_name()] = "minimized"
			pic_viewer(player)
		end
		if fields.open_pics then
			register_task("file_system", player)
			file_system_status[player:get_player_name()] = "minimized"
			active_task[player:get_player_name()] = "file_system"
			change_tasks("file_system", player)
			end_task("pic_viewer", player)
			file_system(player, files.Pictures)
			for k,v in pairs(files.Pictures) do
				table.insert(results[player:get_player_name()], v)
			end
		end
		if fields.close_pics then
			image_to_display[player:get_player_name()] = {}
			pic_viewer(player)
		end
		if fields.close_pic_viewer then
			image_to_display[player:get_player_name()] = {}
			maximize_pic_viewer[player:get_player_name()] = false
			end_task("pic_viewer", player)
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
		end
		if fields.minimize_pic_viewer then
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
			pic_viewer_status[player:get_player_name()] = "minimized"
		end
		if fields.pic_viewer_task then
			active_task[player:get_player_name()] = "pic_viewer"
			change_tasks("pic_viewer", player)
			if pic_viewer_status[player:get_player_name()] == "minimized" then
				pic_viewer(player)
				pic_viewer_status[player:get_player_name()] = "maximized"
			else
				desktop(player, files.theme[player:get_player_name()],
				current_tasks[player:get_player_name()])
				pic_viewer_status[player:get_player_name()] = "minimized"
			end
		end
		if fields.maximize_pic_viewer then
			maximize_pic_viewer[player:get_player_name()] = true
			pic_viewer(player)
		end
		if fields.window_pic_viewer then
			maximize_pic_viewer[player:get_player_name()] = false
			pic_viewer(player)
		end
	end
end)
