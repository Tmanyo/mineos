files = {
	Documents = {},
	Downloads = {},
	Desktop = {"Notepad","Calculator","Email"},
	Music = {},
	Pictures = {},
	inbox = {},
	sent = {},
	read_emails = {},
	important_emails = {},
}

programs = {"Calculator","Email","File_System","Notepad"}

view = {}

dofile(minetest.get_modpath("mineos") .. "/file_system.lua")
dofile(minetest.get_modpath("mineos") .. "/notepad.lua")
dofile(minetest.get_modpath("mineos") .. "/mine_menu.lua")
dofile(minetest.get_modpath("mineos") .. "/calculator.lua")
dofile(minetest.get_modpath("mineos") .. "/webspider.lua")
dofile(minetest.get_modpath("mineos") .. "/task_handling.lua")
dofile(minetest.get_modpath("mineos") .. "/email.lua")

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


--[[
The game has a built-in text wrapping function, but because I pointed out that
the first one didn't work right, developers decided that the best thing to do
was to change the documentation to fit what it really does (which is nothing)
instead of actually fixing the function.... So it finally got "fixed" but it
still isn't to my liking.  This is the function I made.  I know for a fact that
it works.
--]]

function wrap_text(text, limit)
	local new_text = ""
	local x = 1
	if text:len() > limit then
		while x == 1 do
			local s = text:sub(1,limit)
			local space = s:reverse():find(" ")
			if limit == 1 then
				local letter = s:sub(1,1)
				new_text = new_text .. letter .. ","
				text = text:sub(2, text:len())
			else
				if space == nil then
					local split = s:sub(1,(limit - 1))
					new_text = new_text .. split .. "-,"
					text = text:sub(split:len() + 1,
					text:len())
				else
					local last_space = (limit - space) + 1
					new_text = new_text ..
					text:sub(1,last_space) .. ","
					text = text:sub(last_space + 1,
					text:len())
				end
				if text:len() < limit then
					new_text = new_text .. text
					text = ""
				end
			end
			if text == "" then
				x = 0
			end
		end
	else
		new_text = text
	end
	return new_text
end

function desktop(player, background, action)
	minetest.show_formspec(player:get_player_name(), "mineos:desktop",
		"size[11,9]" ..
		"background[0,0;11,9;" .. background .. ".png]" ..
		action ..
		"image_button[.5,.5;1,1;notepad.png;notepad;;true;false;]" ..
		"image_button[.5,1.75;1,1;calculator.png;calculator;;true;false;]" ..
		--"image_button[.5,3;1,1;webspider.png;webspider;;true;false;]" ..
		"image_button[.5,3;1,1;email.png;email;;true;false;]" ..
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
		"image_button[.75,8.25;.75,.75;file_system.png;file_system;;true;false;]" ..
		"label[10,8.15;" .. os.date("%I:%M %p\n%x", os.time()) .. "]")
end

minetest.register_node("mineos:computer", {
	description = "MineOS Computer",
	tiles = {"computer.png"},
	groups = {cracky=3,oddly_breakable_by_hand=1},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		desktop(player, "default", "", "desktop")
	end,
})
