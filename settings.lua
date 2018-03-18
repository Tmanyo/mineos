local themes = ""
local theme_table = {}
local preview_theme = {}
local selected_theme = {}

settings_task = {}
settings_status = {}

minetest.register_on_joinplayer(function(player)
	if not files.button_theme[player:get_player_name()] then
		files.button_theme[player:get_player_name()] = "default"
		save_files()
	end
	settings_task[player:get_player_name()] = {}
	settings_status[player:get_player_name()] = {}
	preview_theme[player:get_player_name()] = ""
	selected_theme[player:get_player_name()] = ""
end)

function get_button_style(player, app, color)
	local style = {
		min = {},
		max = {},
		win = {},
		close = {},
	}
	if files.button_theme[player:get_player_name()] == "default" then
		if color == "black" then
			style.min[player:get_player_name()] = ";;minimize_" ..
			app .. ";" .. minetest.colorize("#000000", "--")
		else
			style.min[player:get_player_name()] = ";;minimize_" ..
			app .. ";--"
		end
		style.max[player:get_player_name()] = ";maximize_" ..
		color:sub(1,1) .. ".png;maximize_" .. app .. ";"
		style.win[player:get_player_name()] = ";window_" ..
		color:sub(1,1) .. ".png;window_" .. app .. ";"
		if color == "black" then
			style.close[player:get_player_name()] = ";;close_" ..
			app .. ";" .. minetest.colorize("#000000", "X")
		else
			style.close[player:get_player_name()] = ";;close_" ..
			app .. ";X"
		end
	elseif files.button_theme[player:get_player_name()] == "win7" then
		style.min[player:get_player_name()] = ";win7_min.png;minimize_" ..
		app .. ";"
		style.max[player:get_player_name()] = ";win7_max.png;maximize_" ..
		app .. ";"
		style.win[player:get_player_name()] = ";win7_win.png;window_" ..
		app .. ";"
		style.close[player:get_player_name()] = ";win7_x.png;close_" ..
		app .. ";"
	end
	return style
end

function get_themes()
	themes = ""
	local all_files = minetest.get_dir_list(minetest.get_modpath("mineos") ..
	"/textures")
	for k,v in pairs(all_files) do
		if v:match(".+_theme.png") then
			local remove = v:gsub("_theme.png", "")
			local refined_themes = ""
			for word in remove:gmatch("%w+") do
				word = word:gsub(word:sub(1,1), string.upper(
				word:sub(1,1)))
				refined_themes = refined_themes .. word .. " "
			end
			refined_themes = refined_themes:gsub(" $", "")
			table.insert(theme_table, remove)
			themes = themes .. refined_themes .. ","
		end
	end
	themes = themes:gsub(",$", "")
	return themes
end

function settings(player)
	get_themes()
	local current_theme = ""
	for k,v in pairs(theme_table) do
		if files.theme[player:get_player_name()]:match(v) then
			current_theme = k
		end
	end
	if preview_theme[player:get_player_name()] == "" then
		preview_theme[player:get_player_name()] = files.theme[player:get_player_name()]
	end
	if selected_theme[player:get_player_name()] == "" then
		selected_theme[player:get_player_name()] = current_theme
	end
	desktop(player, files.theme[player:get_player_name()] ..
	"^settings_overlay.png",
	"label[3.5,1.75;" .. minetest.colorize("#000000", "Themes:") .. "]" ..
	"textlist[3.5,2.25;3,4;themes;" .. get_themes() .. ";" ..
	selected_theme[player:get_player_name()] .. ";false]" ..
	"image_button[9.22,1.62;.6,.4" .. get_button_style(player,
	"settings", "black").close[player:get_player_name()] .. ";true;false;]" ..
	"image_button[8.82,1.59;.6,.45" .. get_button_style(player,
	"settings", "black").min[player:get_player_name()] .. ";true;false;]" ..
	"label[6.8,4.5;" .. minetest.colorize("#000000", "Button Styles:") .. "]" ..
	"image_button[6.95,5;1,.5;;default_buttons;" .. minetest.colorize(
	"#000000", "--          X") .. ";true;false;]" ..
	"image[7.2,5.05;.4,.3;maximize_b.png]" ..
	"tooltip[default_buttons;Default]" ..
	"image_button[7.8,5.53;.6,.4;win7_x.png;win7_x;;true;false;]" ..
	"image_button[7.4,5.5;.6,.45;win7_max.png;win7_max;;true;false;]" ..
	"image_button[7,5.5;.6,.45;win7_min.png;win7_min;;true;false;]" ..
	"tooltip[win7_x;Modern]" ..
	"tooltip[win7_max;Modern]" ..
	"tooltip[win7_min;Modern]" ..
	"image_button[3.6,6.75;1,.5;;apply_theme;" .. minetest.colorize(
	"#FF0000", "Apply") .. ";true;false;]" ..
	"image[6.8,2;3,2.75;" .. preview_theme[player:get_player_name()] .. "]" ..
	current_tasks[player:get_player_name()])
end

local button_type = ""
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.settings then
			if not current_tasks[player:get_player_name()]:match("settings") then
				register_task("settings", player)
				handle_tasks("settings", player)
				current_tasks[player:get_player_name()] = current_tasks[player:get_player_name()] .. settings_task[player:get_player_name()]
			end
			remember_notes(fields, player)
			active_task[player:get_player_name()] = "settings"
			settings_status[player:get_player_name()] = "minimized"
			change_tasks("settings", player)
			settings(player)
		end
		local event = minetest.explode_textlist_event(fields.themes)
		if event.type == "CHG" then
			preview_theme[player:get_player_name()] = theme_table[event.index] .. "_theme.png"
			selected_theme[player:get_player_name()] = event.index
			settings(player)
		end
		if fields.apply_theme then
			if preview_theme[player:get_player_name()] ~= "" then
				files.theme[player:get_player_name()] = preview_theme[player:get_player_name()]
			end
			if button_type ~= "" then
				files.button_theme[player:get_player_name()] = button_type
			end
			save_files()
			settings(player)
		end
		if fields.default_buttons then
			button_type = "default"
		end
		if fields.win7_x or fields.win7_min or fields.win7_max then
			button_type = "win7"
		end
		if fields.close_settings then
			end_task("settings", player)
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
		end
		if fields.minimize_settings then
			settings_status[player:get_player_name()] = "minimized"
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
		end
		if fields.settings_task then
			active_task[player:get_player_name()] = "settings"
			change_tasks("settings", player)
			if settings_status[player:get_player_name()] == "minimized" then
				settings(player)
				settings_status[player:get_player_name()] = "maximized"
			else
				desktop(player, files.theme[player:get_player_name()],
				current_tasks[player:get_player_name()])
				settings_status[player:get_player_name()] = "minimized"
			end
		end
	end
end)
