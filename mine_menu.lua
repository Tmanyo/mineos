--[[
	Mineos Mine Menu Version 1
	Contributors:
		Code & Textures: Tmanyo
--]]

local minemenu_results = {}
local refined_minemenu_results = {}
clicks = {}

minetest.register_on_joinplayer(function(player)
	clicks[player:get_player_name()] = 0
	minemenu_results[player:get_player_name()] = {}
	refined_minemenu_results[player:get_player_name()] = {}
end)

function get_menu_results(player)
	local raw_results = {}
	for k,v in pairs(refined_minemenu_results[player:get_player_name()]) do
		table.insert(raw_results, string.upper(v:sub(1,1)) .. v:
		sub(2,v:len()))
	end
	local results = minetest.serialize(raw_results)
	results = results:gsub("return ", ""):gsub("{", ""):gsub("}", ""):
	gsub("\"", ""):gsub(" ", "")
	if results == "" then
		results = "No Results"
	end
	return results
end

function menu_startup(player)
	local result_list = {}
	refined_minemenu_results[player:get_player_name()] = programs
	result_list = minetest.serialize(programs):gsub("return ", ""):
	gsub("{", ""):gsub("}", ""):gsub("\"", ""):gsub(" ", "")
	return result_list
end

function mine_menu(player)
	local result_list = {}
	if clicks[player:get_player_name()] == 1 then
		result_list = menu_startup(player)
	else
		result_list = get_menu_results(player)
	end
	mine_menu_open = true
	desktop(player, files.theme[player:get_player_name()] ..
	"^mine_menu_overlay.png",
	"textlist[0,4.7;3,3;menu_results;" .. result_list .. ";;true]" ..
	"field[.25,7.6;2.5,1;program_find;;" .. minetest.formspec_escape("") .. "]" ..
	"button[2.3,7.5;1,.5;search_programs;Search]" ..
	current_tasks[player:get_player_name()])
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.mine_menu then
			clicks[player:get_player_name()] = clicks[player:get_player_name()] + 1
			if clicks[player:get_player_name()] == 1 then
				exempt_clock[player:get_player_name()] = true
				remember_notes(fields, player)
				mine_menu(player)
			else
				mine_menu_open = false
				exempt_clock[player:get_player_name()] = false
				desktop(player, files.theme[player:get_player_name()],
				current_tasks[player:get_player_name()])
				clicks[player:get_player_name()] = 0
			end
		end
		if fields.search_programs then
			clicks[player:get_player_name()] = clicks[player:get_player_name()] + 1
			if fields.program_find ~= "" then
				refined_minemenu_results[player:get_player_name()] = {}
				minemenu_results[player:get_player_name()] = {}
				if string.lower(fields.program_find) == "all"
				then
					minemenu_results[player:get_player_name()] = programs
				elseif fields.program_find:match("%w") then
					for k,v in pairs(programs) do
						if string.lower(
						fields.program_find) ==
						string.lower(v) then
							table.insert(
							minemenu_results[player:get_player_name()],
							fields.program_find)
						end
						if string.lower(v):
						match(string.lower(
						fields.program_find):sub(1,3))
						then
							table.insert(
							minemenu_results[player:get_player_name()],v)
						end
					end
				end
				local hash = {}
				for _,v in ipairs(minemenu_results[player:get_player_name()]) do
					if not hash[string.lower(v)] then
						refined_minemenu_results[player:get_player_name()][
						#refined_minemenu_results[player:get_player_name()]+1] = v
						hash[string.lower(v)] = true
					end
				end
				mine_menu(player)
			end
		end
		local result = minetest.explode_textlist_event(
		fields.menu_results)
		local app_selected = {}
		if result.type == "CHG" then
			if get_menu_results(player) ~= "No Results" then
				exempt_clock[player:get_player_name()] = false
				clicks[player:get_player_name()] = 0
				app_selected = string.lower(refined_minemenu_results[player:get_player_name()][
				result.index])
				register_task(app_selected, player)
				if app_selected ~= "file_system" then
					current_tasks[player:get_player_name()] = current_tasks[player:get_player_name()] .. handle_tasks(app_selected, player)
				end
				_G[app_selected .. "_status"][player:get_player_name()] = "minimized"
				active_task[player:get_player_name()] = app_selected
				if app_selected == "file_system" then
					file_system(player, files.Desktop)
				elseif app_selected == "email" then
					email(player, inbox_items(player))
				else
					_G[app_selected](player)
				end
			end
		end
	end
end)
