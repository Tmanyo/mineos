local files_to_seach = {}

function file_system(player, t)
	files_to_seach = t
	local path_to_find = ">Desktop"
	if t == files.Documents then
		path_to_find = ">Documents"
	elseif t == files.Desktop then
		path_to_find = ">Desktop"
	end
	local refined_search = path_to_find:gsub(">", "")
	desktop(player, "default_fs",
	"label[5.65,1.85;File System]" ..
	"image_button[9.25,2;.5,.3;;close_fs;X;true;false;]" ..
	"image_button[8.9,1.95;.5,.4;maximize_w.png;maximize_fs;;true;false;]" ..
	"image_button[8.6,2;.5,.3;;minimize_fs;--;true;false;]" ..
	"box[2.65,2.3;6.88,.5;black]" ..
	"textarea[3.2,2.4;4,.5;path;;" .. minetest.formspec_escape(path_to_find) .. "]" ..
	"textarea[7.3,2.4;2.5,.5;search_fs;;" .. minetest.formspec_escape("Search " .. refined_search) .. "]" ..
	"image_button[2.75,3;1,.3;;desktop_f;" .. minetest.colorize("#000000", "Desktop") .. ";true;false;]" ..
	"image_button[2.8,3.3;1,.3;;documents_f;" .. minetest.colorize("#000000", "Documents") .. ";true;false;]" ..
	"image_button[2.8,3.6;1,.3;;downloads_f;" .. minetest.colorize("#000000", "Downloads") .. ";true;false;]" ..
	"image_button[2.8,3.9;1,.3;;music_f;" .. minetest.colorize("#000000", "Music") .. ";true;false;]" ..
	"image_button[2.8,4.2;1,.3;;pictures_f;" .. minetest.colorize("#000000", "Pictures") .. ";true;false;]" ..
	"box[3.8,2.79;.1,3.35;black]" ..
	"tableoptions[background=#7AC5CD]" ..
	"table[4,2.9;5.2,3;contents;" .. refine_returns(t) .. ";]")
end

local a = 0
local status = {}
local text = {}

function refine_returns(t)
	local refined = {}
	local t_ = {}
	if t == files.Desktop then
		for k,v in pairs(t) do
			table.insert(t_, v)
		end
	else
		for k,v in pairs(t) do
			table.insert(t_, k)
		end
	end
	local val = minetest.serialize(t_)
	refined = val:gsub("return ", ""):gsub("{", ""):gsub("}", ""):gsub("\"", "")
	return refined
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.file_system then
			if status == "maximized" then
				desktop(player, "default", "")
				status = "minimized"
			else
				desktop(player, "default_fs",
				"label[5.65,1.85;File System]" ..
				"image_button[9.25,2;.5,.3;;close_fs;X;true;false;]" ..
				"image_button[8.9,1.95;.5,.4;maximize_w.png;maximize_fs;;true;false;]" ..
				"image_button[8.6,2;.5,.3;;minimize_fs;--;true;false;]" ..
				"box[2.65,2.3;6.88,.5;black]" ..
				"textarea[3.2,2.4;4,.5;path;;" .. minetest.formspec_escape(">Desktop") .. "]" ..
				"textarea[7.3,2.4;2.5,.5;search_fs;;Search Desktop]" ..
				"image_button[2.75,3;1,.3;;desktop_f;" .. minetest.colorize("#000000", "Desktop") .. ";true;false;]" ..
				"image_button[2.8,3.3;1,.3;;documents_f;" .. minetest.colorize("#000000", "Documents") .. ";true;false;]" ..
				"image_button[2.8,3.6;1,.3;;downloads_f;" .. minetest.colorize("#000000", "Downloads") .. ";true;false;]" ..
				"image_button[2.8,3.9;1,.3;;music_f;" .. minetest.colorize("#000000", "Music") .. ";true;false;]" ..
				"image_button[2.8,4.2;1,.3;;pictures_f;" .. minetest.colorize("#000000", "Pictures") .. ";true;false;]" ..
				"box[3.8,2.79;.1,3.35;black]" ..
				"tableoptions[background=#7AC5CD]" ..
				"table[4,2.9;5.2,3;contents;" .. refine_returns(files.Desktop) .. ";]")
				status = "maximized"
			end
		end
		if fields.close_fs then
			desktop(player, "default", "")
		end
		if fields.minimize_fs then
			desktop(player, "default", "")
			status = "minimized"
		end
		if fields.documents_f then
			file_system(player, files.Documents)
		end
		if fields.desktop_f then
			file_system(player, files.Desktop)
		end
	end
	local event = minetest.explode_table_event(fields.contents)
	if event.type == "CHG" then
		minetest.chat_send_all(tonumber(event.index))
		minetest.after(2,function()
			desktop(player, "default_notepad",
			"image_button[2.4,1.53;.75,.3;;save_notes;Save;true;false;]" ..
			"image_button[3,1.53;.75,.3;;open_notes;Open;true;false;]" ..
			"image_button[7.4,1.53;.5,.3;;minimize_np;--;true;false;]" ..
			"image_button[7.7,1.5;.5,.4;maximize_w.png;maximize_np;;true;false;]" ..
			"image_button[8,1.53;.5,.3;;close_notepad;X;true;false;]" ..
			"textarea[2.7,2;6,5.3;notes;;" .. "cows" .. "]" ..
			"image_button[1.5,8.25;.75,.75;notepad.png;notepad_task;;true;false;]")
		end)
	end
end)
