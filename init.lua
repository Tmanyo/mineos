files = {
	Documents = {},
	Downloads = {},
	Desktop = {"Notepad"},
	Music = {},
	Pictures = {},
}

local files_to_seach = {}

local f = io.open(minetest.get_worldpath() .. "/mineos_files.db", "r")
if f == nil then
	local f = io.open(minetest.get_worldpath() .. "/mineos_files.db", "w")
	f:write(minetest.serialize(files))
	f:close()
end

function save_files()
	local f = io.open(minetest.get_worldpath() .. "/mineos_files.db", "w")
	f:write(minetest.serialize(files))
	f:close()
end

function read_files()
	local f = io.open(minetest.get_worldpath() .. "/mineos_files.db", "r")
	local files = minetest.deserialize(f:read("*a"))
	f:close()
	return files
end


function desktop(player, background, action)
	minetest.show_formspec(player:get_player_name(), "mineos:desktop",
		"size[11,9]" ..
		"background[0,0;11,9;" .. background .. ".png]" ..
		action ..
		"image_button[.5,.5;1,1;notepad.png;notepad;;true;false;]" ..
		"image_button[0,8.25;.75,.75;mine_menu.png;mine_menu;;true;false;]" ..
		"image_button[.75,8.25;.75,.75;file_system.png;file_system;;true;false;]" ..
		"label[10,8.15;" .. os.date("%I:%M %p\n%x", os.time()) .. "]")
end

function maximized(player, background, action)
	minetest.show_formspec(player:get_player_name(), "mineos:desktop",
		"size[11,9]" ..
		"background[0,0;11,9;" .. background .. ".png]" ..
		action ..
		"image_button[0,8.25;.75,.75;mine_menu.png;mine_menu;;true;false;]" ..
		"label[10,8.15;" .. os.date("%I:%M %p\n%x", os.time()) .. "]")
end

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

minetest.register_node("mineos:computer", {
	description = "MineOS Computer",
	tiles = {"computer.png"},
	groups = {cracky=3,oddly_breakable_by_hand=1},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		desktop(player, "default", "")
	end,
})

local a = 0
local status = {}
local text = {}

files = read_files()

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
