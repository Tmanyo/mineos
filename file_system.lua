results = {}
music_row = {}
local path_to_find = {}
local search_word = {}

function file_system(player, t, extra)
	local bg = {}
	if t == files.Documents[player:get_player_name()] then
		path_to_find = ">Documents"
	elseif t == files.Desktop then
		path_to_find = ">Desktop"
	elseif t == files.Music then
		path_to_find = ">Music"
	end
	if type(search_word) == "table" then
		search_word = ""
	end
	if extra then
		extra = extra
		bg = "fs_dialog_1"
	else
		extra = ""
		bg = "default_fs"
	end
	desktop(player, bg,
	"label[5.65,1.89;File System]" ..
	"image_button[9.2,2.02;.35,.295;close_w.png;close_fs;;true;false;]" ..
	"image_button[8.9,2.02;.38,.297;maximize_w.png;maximize_fs;;true;false;]" ..
	"image_button[8.6,2.02;.38,.297;minimize_w.png;minimize_fs;;true;false;]" ..
	"box[2.65,2.3;6.88,.5;black]" ..
	"image_button[6.75,2.4;.4,.4;search.png;search_f;;true;false;]" ..
	"textarea[3.2,2.4;4,.5;path;;" ..
	minetest.formspec_escape(path_to_find) .. "]" ..
	"textarea[7.3,2.4;2.5,.5;search_fs;;" ..
	minetest.formspec_escape(search_word) .. "]" ..
	"image_button[2.75,3;1,.3;;desktop_f;" ..
	minetest.colorize("#000000", "Desktop") .. ";true;false;]" ..
	"image_button[2.8,3.3;1,.3;;documents_f;" ..
	minetest.colorize("#000000", "Documents") .. ";true;false;]" ..
	"image_button[2.8,3.6;1,.3;;downloads_f;" ..
	minetest.colorize("#000000", "Downloads") .. ";true;false;]" ..
	"image_button[2.8,3.9;1,.3;;music_f;" ..
	minetest.colorize("#000000", "Music") .. ";true;false;]" ..
	"image_button[2.8,4.2;1,.3;;pictures_f;" ..
	minetest.colorize("#000000", "Pictures") .. ";true;false;]" ..
	"image_button[2.8,5.5;1,.3;;delete;" ..
	minetest.colorize("#FF0000", "Delete") .. ";true;false;]" ..
	"box[3.8,2.79;.1,3.35;black]" ..
	"tableoptions[background=#7AC5CD]" ..
	"table[4,2.9;5.2,3;contents;" .. refine_returns(t) .. ";]" ..
	current_tasks ..
	extra)
end

file_system_status = {}

function refine_returns(t)
	local refined = {}
	local val = minetest.serialize(t)
	if t == files.Desktop then
		refined = val:gsub("return ", ""):gsub("{", ""):gsub("}", ""):
		gsub("\"", ""):gsub(" ", "")
	else
		refined = val:gsub("return ", ""):gsub("{", ""):gsub("}", ""):
		gsub("\"", ""):gsub(" ", ""):gsub("-.+,", ","):gsub("-.+", "")
	end
	if refined == "nil" then
		refined = ""
	end
	return refined
end

local counter = 0
local selected = {}
local item = {}
local table_to_search = {}
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.file_system then
			for k,v in pairs(files.Desktop) do
				table.insert(results, v)
			end
			remember_notes(fields)
			counter = counter + 1
			if counter == 1 then
				register_task("file_system")
				file_system_status = "minimized"
			end
			active_task = "file_system"
			change_tasks("file_system")
			if file_system_status == "minimized" then
				file_system(player, files.Desktop)
				file_system_status = "maximized"
			else
				desktop(player, "default", "")
				file_system_status = "minimized"
			end
		end
		if fields.search_f then
			local search_object = {}
			local index = {}
			if fields.path ~= path_to_find then
				results = {}
				if fields.path:find("\\") then
					table_to_search = fields.path:sub(2,
					fields.path:find("\\") - 1)
					search_object = fields.path:sub(
					fields.path:find("\\") + 1, fields.path:
					len())
				else
					table_to_search = ""
					search_object = ""
				end
				for k,v in pairs(files) do
					if k == table_to_search then
						local t = v
						local result = {}
						if table_to_search == "Desktop"
						then
							for k,v in pairs(t) do
								table.insert(result,
								string.lower(v))
							end
						elseif table_to_search == "Documents"
						then
							for k,v in pairs(t[player:
							get_player_name()]) do
								table.insert(result,
								string.lower(v):
								sub(1,string.lower(v):
								find("%.") - 1))
							end
						elseif table_to_search == "Music"
						then
							for k,v in pairs(t) do
								table.insert(result,
								v:sub(8,v:find("%.")
								 - 1))
							end
						end
						for k,v in pairs(result) do
							if v == string.lower(
							search_object) then
								if table_to_search ==
								"Desktop" or
								table_to_search ==
								"Music" then
									table.insert(
									results,
									t[k])
								elseif table_to_search ==
								"Documents" then
									table.insert(
									results,
									t[player:
									get_player_name()]
									[k])
								end
							elseif v:
							match("^" ..
							search_object:sub(1,3)) then
								if table_to_search ==
								"Desktop" or
								table_to_search ==
								"Music" then
									table.insert(
									results,t[k])
								elseif table_to_search ==
								"Documents" then
									table.insert(
									results,
									t[player:
									get_player_name()]
									[k])
								end
							end
						end
					end
				end
			elseif fields.search_fs ~= "" then
				results = {}
				search_object = fields.search_fs
				for k,v in pairs(files.Desktop) do
					if string.lower(v) == string.lower(
					search_object) then
						table.insert(results, v)
					elseif string.lower(v):match("^" ..
					string.lower(search_object):sub(1,3))
					then
						table.insert(results, v)
					end
				end
				for k,v in pairs(files.Documents[player:
				get_player_name()]) do
					if string.lower(v) == string.lower(
					search_object) then
						table.insert(results, v)
					elseif string.lower(v):match("^" ..
					string.lower(search_object):sub(1,3))
					then
						table.insert(results, v)
					end
				end
				get_music()
				for k,v in pairs(files.Music) do
					if v == string.lower(search_object) then
						table.insert(results, v)
					elseif v:gsub("mineos_", ""):match("^" ..
					string.lower(search_object):sub(1,3)) then
						table.insert(results, v)
					end
				end
			end
			path_to_find = fields.path
			search_word = fields.search_fs
			file_system(player, results)
		end
		if fields.close_fs then
			results = {}
			counter = 0
			search_word = ""
			end_task("file_system")
			desktop(player, "default", current_tasks)
		end
		if fields.minimize_fs then
			desktop(player, "default", current_tasks)
			file_system_status = "minimized"
		end
		if fields.documents_f then
			results = {}
			file_system(player, files.Documents[player:
			get_player_name()])
			for k,v in pairs(files.Documents[player:
			get_player_name()]) do
				table.insert(results, v)
			end
		end
		if fields.desktop_f then
			results = {}
			file_system(player, files.Desktop)
			for k,v in pairs(files.Desktop) do
				table.insert(results, v)
			end
		end
		if fields.music_f then
			results = {}
			get_music()
			file_system(player, files.Music)
			for k,v in pairs(files.Music) do
				table.insert(results, v)
			end
		end
		local event = minetest.explode_table_event(fields.contents)
		if event.type == "DCL" then
			local application = {}
			local file = {}
			if results[event.row] ~= nil then
				if results[event.row]:match("%.ogg") then
					music_row = event.row
					for k,v in pairs(results) do
						table.insert(file, v)
					end
					if file[event.row] ~= nil then
						register_task("tmusic_player")
						handle_tasks("tmusic_player")
						current_tasks = current_tasks ..
						tmusic_player_task
						active_task = "tmusic_player"
						tmusic_player_status = "minimized"
						search_word = ""
						results = {}
						end_task("file_system")
						counter = 0
						tmusic_player(player)
					end
				elseif results[event.row]:match("%.mn") then
					for k,v in pairs(results) do
						table.insert(file, v)
					end
					if file[event.row] ~= nil then
						text = minetest.serialize(
						file[event.row]):
						gsub("return ", ""):gsub("{", ""):
						gsub("}", ""):gsub("\"", ""):
						gsub(".+%.mn %- ", "")
						register_task("notepad")
						handle_tasks("notepad")
						current_tasks = current_tasks ..
						notepad_task
						active_task = "notepad"
						notepad_status = "minimized"
						search_word = ""
						results = {}
						end_task("file_system")
						counter = 0
						notepad(player)
					end
				else
					application = string.lower(
					results[event.row])
					register_task(application)
					current_tasks = current_tasks ..
					handle_tasks(application)
					active_task = application
					_G[application .. "_status"] = "minimized"
					search_word = ""
					results = {}
					end_task("file_system")
					counter = 0
					if application == "email" then
						email(player, inbox_items(player))
					else
						_G[application](player)
					end
				end
			end
		end
		if event.type == "CHG" then
			selected = "true"
			item = event.row
		end
		if fields.delete then
			if files.Documents[player:get_player_name()] ~= nil then
				if selected == "true" then
					if results[item]:match("%.mn") then
						file_system(player,
						files.Documents[player:
						get_player_name()],
						"label[4,6.7;" ..
						minetest.colorize("#000000",
						"Are you sure you want to" ..
						" delete this item?") .. "]" ..
						"image_button[4,7.2;1,.3;;yes;" ..
						minetest.colorize("#FF0000", "Yes") ..
						";true;false;]" ..
						"image_button[5.2,7.2;1,.3;;no;" ..
						minetest.colorize("#FF0000", "No") ..
						";true;false;]")
					end
				end
			end
		end
		if fields.yes then
			table.remove(files.Documents[player:get_player_name()],
			item)
			save_files()
			item = {}
			file_system(player, files.Documents[player:
			get_player_name()])
			selected = "false"
		end
		if fields.no then
			file_system(player, files.Documents[player:
			get_player_name()])
			selected = "false"
		end
	end
end)
