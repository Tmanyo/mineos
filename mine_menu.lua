--[[
	Mineos Mine Menu Version 1
	Contributors:
		Code & Textures: Tmanyo
--]]

local minemenu_results = {}
local refined_minemenu_results = {}

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

function mine_menu(player)
	desktop(player, "menu",
	"textlist[0,4.7;3,3;menu_results;" .. get_menu_results() .. ";;true]" ..
	"field[.25,7.6;2.5,1;program_find;;Search Application to Run]" ..
	"button[2.3,7.5;1,.5;search_programs;Search]")
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.mine_menu then
			mine_menu(player)
		end
		if fields.search_programs then
			if fields.program_find ~= "" and
			fields.program_find ~= "Search Application to Run" then
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
			app_selected = string.lower(refined_minemenu_results[
			result.index])
			_G[app_selected](player, files.Desktop)
		end
	end
end)
