--[[
	Mineos Mine Menu Version 1
	Contributors:
		Code & Textures: Tmanyo
--]]

local minemenu_results = {}
local refined_minemenu_results = {}
clicks = 0

function get_menu_results()
	local raw_results = {}
	for k,v in pairs(refined_minemenu_results) do
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

function menu_startup()
	local result_list = {}
	refined_minemenu_results = programs
	result_list = minetest.serialize(programs):gsub("return ", ""):
	gsub("{", ""):gsub("}", ""):gsub("\"", ""):gsub(" ", "")
	return result_list
end

function mine_menu(player)
	local result_list = {}
	if clicks == 1 then
		result_list = menu_startup()
	else
		result_list = get_menu_results()
	end
	mine_menu_open = true
	desktop(player, "menu",
	"textlist[0,4.7;3,3;menu_results;" .. result_list .. ";;true]" ..
	"field[.25,7.6;2.5,1;program_find;;]" ..
	"button[2.3,7.5;1,.5;search_programs;Search]" ..
	current_tasks)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.mine_menu then
			clicks = clicks + 1
			if clicks == 1 then
				exempt_clock = true
				remember_notes(fields)
				mine_menu(player)
			else
				mine_menu_open = false
				exempt_clock = false
				desktop(player, "default", current_tasks)
				clicks = 0
			end
		end
		if fields.search_programs then
			clicks = clicks + 1
			if fields.program_find ~= "" then
				refined_minemenu_results = {}
				minemenu_results = {}
				if string.lower(fields.program_find) == "all"
				then
					minemenu_results = programs
				else
					for k,v in pairs(programs) do
						if string.lower(
						fields.program_find) ==
						string.lower(v) then
							table.insert(
							minemenu_results,
							fields.program_find)
						end
						if string.lower(v):
						match(string.lower(
						fields.program_find):sub(1,3))
						then
							table.insert(
							minemenu_results,v)
						end
					end
				end
				local hash = {}
				for _,v in ipairs(minemenu_results) do
					if not hash[string.lower(v)] then
						refined_minemenu_results[
						#refined_minemenu_results+1] = v
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
			if get_menu_results() ~= "No Results" then
				exempt_clock = false
				clicks = 0
				app_selected = string.lower(refined_minemenu_results[
				result.index])
				register_task(app_selected)
				if app_selected ~= "file_system" then
					current_tasks = current_tasks .. handle_tasks(app_selected)
				end
				_G[app_selected .. "_status"] = "minimized"
				active_task = app_selected
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
