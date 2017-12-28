files = {
	Documents = {},
	Downloads = {},
	Desktop = {"Notepad", "Calculator"},
	Music = {},
	Pictures = {},
}

programs = {"Calculator","File_System","Notepad"}

view = {}

dofile(minetest.get_modpath("mineos") .. "/file_system.lua")
dofile(minetest.get_modpath("mineos") .. "/notepad.lua")
dofile(minetest.get_modpath("mineos") .. "/mine_menu.lua")
dofile(minetest.get_modpath("mineos") .. "/calculator.lua")

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

files = read_files()

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

minetest.register_node("mineos:computer", {
	description = "MineOS Computer",
	tiles = {"computer.png"},
	groups = {cracky=3,oddly_breakable_by_hand=1},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		desktop(player, "default", "")
	end,
})
