files = {
	Documents = {},
	Downloads = {"Downloads not currently supported in MineOS v0.1."},
	Desktop = {"Notepad","Calculator","Email","Tmusic_Player","Pic_Viewer",
	"Settings"},
	Music = {},
	Pictures = {},
	inbox = {},
	sent = {},
	read_emails = {},
	important_emails = {},
	theme = {},
	button_theme = {},
}

programs = {"Calculator","Email","File_System","Notepad","Pic_Viewer","Settings",
"Terminal","Tmusic_Player"}

version = "MineOS v0.1"
lines = {}

local form_closed = {}
local field_info = {}

local path = minetest.get_modpath("mineos")

dofile(path .. "/file_system.lua")
dofile(path .. "/notepad.lua")
dofile(path .. "/mine_menu.lua")
dofile(path .. "/calculator.lua")
dofile(path .. "/task_handling.lua")
dofile(path .. "/email.lua")
dofile(path .. "/tmusic_player.lua")
dofile(path .. "/terminal.lua")
dofile(path .. "/pic_viewer.lua")
dofile(path .. "/settings.lua")

-----
-- Data Saving Functions
-----
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

--[[ My own text wrapping function because I don't like minetest.wrap_text()
as it does not work properly.]]--
function wrap_text(text, limit)
	local new_text = ""
	local x = 1
	if text:len() > limit then
		while x == 1 do
			local s = text:sub(1,limit)
			local space = s:reverse():find(" ")
			if limit == 1 then
				local letter = s:sub(1,1)
				new_text = new_text .. letter .. "\n"
				text = text:sub(2, text:len())
			else
				if space == nil then
					local split = s:sub(1,(limit - 1))
					new_text = new_text .. split .. "-\n"
					text = text:sub(split:len() + 1,
					text:len())
				else
					local last_space = (limit - space) + 1
					new_text = new_text ..
					text:sub(1,last_space) .. "\n"
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

-- Experimental Text Wrapping function (Not fully tested)
function wrap_textlist_text(text, limit)
	local new_text = ""
	lines = {}
	for line in text:gmatch("([^,]+),") do
		table.insert(lines, line)
	end
	table.insert(lines, text:match(",([^,]+)$"))
	for k,v in pairs(lines) do
		if v:len() > limit then
			local rest = {}
			rest = v
			local last_space = {}
			while rest:len() > limit do
				last_space = rest:sub(1,limit):reverse():find(" ")
				if not last_space then
					new_text = new_text .. "," .. rest:sub(1,limit)
					rest = rest:sub(limit + 1, rest:len())
				else
					new_text = new_text .. "," .. rest:sub(1,limit - (last_space - 1))
					rest = rest:sub(limit - (last_space - 1) + 1, rest:len())
				end
			end
			new_text = new_text .. "," .. rest
		else
			if new_text == "" then
				new_text = v
			else
				new_text = new_text .. "," .. v
			end
		end
	end
	return new_text
end

-- Escape Lua magic characters from text.
local special_characters = {"[","(",")","%"}
function escape_characters(text)
	local new_text = ""
	for character in text:gmatch(".") do
		for k,v in pairs(special_characters) do
			if character == v then
				new_text = new_text .. "%" .. character
			else
				if k == #special_characters then
					new_text = new_text .. character
				end
			end
		end
	end
	return new_text
end

-- The main formspec function.
mine_menu_open = {}
function desktop(player, background, action)
	form_closed = false
	local icons_to_hide = {}
	if mine_menu_open ~= true then
		icons_to_hide = "image_button[.5,4.25;1,1;tmusic_player.png;tmusic_player;;true;false;]" ..
		"tooltip[tmusic_player;Tmusic Player]" ..
		"image_button[.5,5.5;1,1;pic_viewer.png;pic_viewer;;true;false;]" ..
		"tooltip[pic_viewer;Pic Viewer]" ..
		"image_button[.5,6.75;1,1;settings.png;settings;;true;false;]" ..
		"tooltip[settings;Settings]"
	else
		icons_to_hide = ""
	end
	minetest.show_formspec(player:get_player_name(), "mineos:desktop",
		"size[11,9]" ..
		"bgcolor[#3B3A39;false]" ..
		"background[0,0;11,9;" .. background .. "]" ..
		action ..
		"image_button[.5,.5;1,1;notepad.png;notepad;;true;false;]" ..
		"tooltip[notepad;Notepad]" ..
		"image_button[.5,1.75;1,1;calculator.png;calculator;;true;false;]" ..
		"tooltip[calculator;Calculator]" ..
		"image_button[.5,3;1,1;email.png;email;;true;false;]" ..
		"tooltip[email;Email]" ..
		icons_to_hide ..
		"image_button[0,8.25;.75,.75;mine_menu.png;mine_menu;;true;false;]" ..
		"tooltip[mine_menu;Mine Menu]" ..
		"image_button[.75,8.25;.75,.75;file_system.png;file_system;;true;false;]" ..
		"tooltip[file_system;File System]" ..
		"label[10,8.15;" .. os.date("%I:%M %p\n%x", os.time()) .. "]" ..
		"image[3.75,8.75;4,1;mineos_logo.png]")
end

-- Create a timer for the clock if only the desktop is being shown.
exempt_clock = {}
local function timer(player, fields)
	local tmr = 0
	minetest.register_globalstep(function(dtime)
		tmr = tmr + dtime
		if tmr >= 5 then
			if active_task == "" then
				if form_closed ~= true then
					if exempt_clock ~= true then
						desktop(player, files.theme[
						player:get_player_name()], "")
						tmr = 0
					end
				end
			end
		end
	end)
end

-- Check to see if formspec is still open.
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.quit == "true" then
			for k,v in pairs(tasks.name) do
				end_task(v)
			end
			current_tasks = ""
			terminal_text = ""
			clicks = 0
			form_closed = true
		end
		if not fields.mine_menu then
			mine_menu_open = false
		end
	end
end)

-- Function to use if application is to be used in full screen mode.
function maximized(player, background, action)
	minetest.show_formspec(player:get_player_name(), "mineos:desktop",
		"size[11,9]" ..
		"bgcolor[#3B3A39;false]" ..
		"background[0,0;11,9;" .. background .. ".png]" ..
		action ..
		"image_button[0,8.25;.75,.75;mine_menu.png;mine_menu;;true;false;]" ..
		"image_button[.75,8.25;.75,.75;file_system.png;file_system;;true;false;]" ..
		"label[10,8.15;" .. os.date("%I:%M %p\n%x", os.time()) .. "]" ..
		"image[3.75,8.75;4,1;mineos_logo.png]")
end

-----
-- Computer node
-----
minetest.register_node("mineos:computer_on", {
	description = "MineOS Computer On",
	drawtype = "mesh",
	mesh = "computer.obj",
	tiles = {
		{name="mineos_computer.png"},{name="default_screen.png"},
	},
	paramtype = "light",
	light_source = 5,
	paramtype2 = "facedir",
	selection_box = {
          	type = "fixed",
          	fixed = {
               		{-.5,-.5,-.5,.5,.4,.2},
          	},
     	},
     	collision_box = {
          	type = "fixed",
          	fixed = {
               		{-.5,-.5,-.5,.5,.4,.2},
          	},
     	},
	groups = {cracky=3,crumbly=3,falling_node=1,
	not_in_creative_inventory=1},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if not files.theme[player:get_player_name()] then
			files.theme[player:get_player_name()] = "green_theme.png"
			save_files()
		end
		desktop(player, files.theme[player:get_player_name()], "")
		timer(player, field_info)
	end,
	on_punch = function(pos, node, player, pointed_thing)
		node.name = "mineos:computer"
		minetest.set_node(pos, node)
	end,
	on_dig = function(pos, node, player)
		node.name = "mineos:computer"
	end,
})

minetest.register_node("mineos:computer", {
	description = "MineOS Computer",
	drawtype = "mesh",
	mesh = "computer.obj",
	tiles = {
		{name="mineos_computer.png"},{name="off_screen.png"},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	selection_box = {
          	type = "fixed",
          	fixed = {
               		{-.5,-.5,-.5,.5,.4,.2},
          	},
     	},
     	collision_box = {
          	type = "fixed",
          	fixed = {
               		{-.5,-.5,-.5,.5,.4,.2},
          	},
     	},
	groups = {cracky=3,crumbly=3,falling_node=1},
	on_punch = function(pos, node, player, pointed_thing)
		node.name = "mineos:computer_on"
		minetest.set_node(pos, node)
	end,
})
