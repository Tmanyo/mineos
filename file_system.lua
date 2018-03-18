results = {}
music_row = {}
counter = {}
file_system_status = {}
local path_to_find = {}
local search_word = {}
local item = {}
local selected = {}

minetest.register_on_joinplayer(function(player)
	results[player:get_player_name()] = {}
	music_row[player:get_player_name()] = {}
	path_to_find[player:get_player_name()] = {}
	search_word[player:get_player_name()] = {}
	file_system_status[player:get_player_name()] = {}
	counter[player:get_player_name()] = 0
	item[player:get_player_name()] = {}
	selected[player:get_player_name()] = {}
end)

function file_system(player, t, extra)
	local bg = {}
	if t == files.Documents[player:get_player_name()] then
		path_to_find[player:get_player_name()] = ">Documents"
	elseif t == files.Desktop then
		path_to_find[player:get_player_name()] = ">Desktop"
	elseif t == files.Music then
		path_to_find[player:get_player_name()] = ">Music"
	elseif t == files.Downloads then
		path_to_find[player:get_player_name()] = ">Downloads"
	elseif t == files.Pictures then
		path_to_find[player:get_player_name()] = ">Pictures"
	end
	if type(search_word[player:get_player_name()]) == "table" then
		search_word[player:get_player_name()] = ""
	end
	if extra then
		extra = extra
		bg = files.theme[player:get_player_name()] ..
		"^file_system_dialog_overlay.png"
	else
		extra = ""
		bg = files.theme[player:get_player_name()] ..
		"^file_system_overlay.png"
	end
	desktop(player, bg,
	"label[5.65,1.85;File System]" ..
	"image_button[9.15,1.93;.6,.4" .. get_button_style(player, "file_system",
	"white").close[player:get_player_name()] .. ";true;false;]" ..
	"image_button[8.75,1.9;.6,.45" .. get_button_style(player, "file_system",
	"white").min[player:get_player_name()] .. ";true;false;]" ..
	"box[2.64,2.3;6.89,.5;black]" ..
	"image_button[6.75,2.4;.4,.4;search.png;search_f;;true;false;]" ..
	"textarea[3.2,2.4;4,.5;path;;" ..
	minetest.formspec_escape(path_to_find[player:get_player_name()]) .. "]" ..
	"textarea[7.3,2.4;2.5,.5;search_fs;;" ..
	minetest.formspec_escape(search_word[player:get_player_name()]) .. "]" ..
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
	"box[3.8,2.79;.1,3.36;black]" ..
	"tableoptions[background=#7AC5CD]" ..
	"tablecolumns[" ..
		"image,align=center,1=mn.png,2=app.png,3=unknown.png" ..
		",4=music.png,5=picture.png;" ..
		"text]" ..
	"table[4,2.9;5.2,3;contents;" .. refine_returns(t) .. ";]" ..
	extra ..
	current_tasks[player:get_player_name()])
end

-- Show files without serialized table junk.
function refine_returns(t)
	local refined = ""
	local vals = {}
	local val = minetest.serialize(t)
	if t == files.Desktop then
		for k,v in pairs(files.Desktop) do
			if k ~= #files.Desktop then
				refined = refined .. "2," .. v .. ","
			else
				refined = refined .. "2," .. v
			end
		end
	elseif t == files.Music then
		for k,v in pairs(files.Music) do
			if k ~= #files.Music then
				refined = refined .. "4," .. v .. ","
			else
				refined = refined .. "4," .. v
			end
		end
	elseif t == files.Downloads then
		for k,v in pairs(files.Downloads) do
			refined = "3," .. v
		end
	elseif t == files.Pictures then
		if get_pictures() == "" then
			refined = ""
		else
			refined = get_pictures():gsub(",", ",5,"):gsub("^", "5,")
		end
	else
		for k,v in pairs(t) do
			if v:match("%.mn") then
				refined = refined .. "1," .. minetest.formspec_escape(v:gsub("\"", ""):
				gsub(" ", "")):gsub("-.+", ",")
			elseif v:match("%.ogg") then
				refined = refined .."4," .. v .. ","
			elseif v:match("%.png") then
				refined = refined .. "5," .. v .. ","
			elseif minetest.serialize(files.Desktop):match(v) then
				refined = refined .. "2," .. v .. ","
			elseif #t > 1 and k == 1 then
				refined = v .. ","
			elseif #t == 1 then
				refined = v
			else
				refined = refined .. "," .. v
			end
		end
	end
	if refined == "nil" then
		refined = ""
	elseif refined:match(",$") then
		refined = refined:gsub(",$", "")
	end
	return refined
end

local table_to_search = {}
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.file_system then
			for k,v in pairs(files.Desktop) do
				table.insert(results[player:get_player_name()], v)
			end
			remember_notes(fields, player)
			counter[player:get_player_name()] = counter[player:get_player_name()] + 1
			if counter[player:get_player_name()] == 1 then
				register_task("file_system", player)
				file_system_status[player:get_player_name()] = "minimized"
			end
			active_task[player:get_player_name()] = "file_system"
			change_tasks("file_system", player)
			if file_system_status[player:get_player_name()] == "minimized" then
				file_system(player, files.Desktop)
				file_system_status[player:get_player_name()] = "maximized"
			else
				desktop(player, files.theme[player:get_player_name()],
				current_tasks[player:get_player_name()])
				file_system_status[player:get_player_name()] = "minimized"
			end
		end
		if fields.search_f then
			local search_object = {}
			local index = {}
			local search_term = escape_characters(fields.path)
			if search_term ~= path_to_find[player:get_player_name()] then
				results[player:get_player_name()] = {}
				if search_term:find("\\") then
					table_to_search = search_term:sub(2,
					search_term:find("\\") - 1)
					search_object = search_term:sub(
					search_term:find("\\") + 1, search_term:
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
									results[player:get_player_name()],
									t[k])
								elseif table_to_search ==
								"Documents" then
									table.insert(
									results[player:get_player_name()],
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
									results[player:get_player_name()],t[k])
								elseif table_to_search ==
								"Documents" then
									table.insert(
									results[player:get_player_name()],
									t[player:
									get_player_name()]
									[k])
								end
							end
						end
					end
				end
			elseif fields.search_fs ~= "" then
				results[player:get_player_name()] = {}
				search_object = escape_characters(fields.search_fs)
				for k,v in pairs(files.Desktop) do
					if string.lower(v) == string.lower(
					search_object) then
						table.insert(results[player:get_player_name()], v)
					elseif string.lower(v):match("^" ..
					string.lower(search_object):sub(1,3))
					then
						table.insert(results[player:get_player_name()], v)
					end
				end
				for k,v in pairs(files.Documents[player:
				get_player_name()]) do
					if string.lower(v) == string.lower(
					search_object) then
						table.insert(results[player:get_player_name()], v)
					elseif string.lower(v):match("^" ..
					string.lower(search_object):sub(1,3))
					then
						table.insert(results[player:get_player_name()], v)
					end
				end
				get_music()
				for k,v in pairs(files.Music) do
					if v == string.lower(search_object) then
						table.insert(results[player:get_player_name()], v)
					elseif v:gsub("mineos_", ""):match("^" ..
					string.lower(search_object):sub(1,3)) then
						table.insert(results[player:get_player_name()], v)
					end
				end
				for k,v in pairs(files.Pictures) do
					if v == string.lower(search_object) then
						table.insert(results[player:get_player_name()], v)
					elseif v:match("^" .. string.lower(
					search_object):sub(1,3)) then
						table.insert(results[player:get_player_name()], v)
					end
				end
			end
			path_to_find[player:get_player_name()] = fields.path
			search_word[player:get_player_name()] = fields.search_fs
			file_system(player, results[player:get_player_name()])
		end
		if fields.close_file_system then
			results[player:get_player_name()] = {}
			counter[player:get_player_name()] = 0
			search_word[player:get_player_name()] = ""
			end_task("file_system", player)
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
		end
		if fields.minimize_file_system then
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
			file_system_status[player:get_player_name()] = "minimized"
		end
		if fields.documents_f then
			if not files.Documents[player:get_player_name()] then
				files.Documents[player:get_player_name()] = {}
			end
			results[player:get_player_name()] = {}
			file_system(player, files.Documents[player:
			get_player_name()])
			for k,v in pairs(files.Documents[player:
			get_player_name()]) do
				table.insert(results[player:get_player_name()], v)
			end
		end
		if fields.desktop_f then
			results[player:get_player_name()] = {}
			file_system(player, files.Desktop)
			for k,v in pairs(files.Desktop) do
				table.insert(results[player:get_player_name()], v)
			end
		end
		if fields.downloads_f then
			results[player:get_player_name()] = {}
			file_system(player, files.Downloads)
			for k,v in pairs(files.Downloads) do
				table.insert(results[player:get_player_name()], v)
			end
		end
		if fields.pictures_f then
			results[player:get_player_name()] = {}
			get_pictures()
			file_system(player, files.Pictures)
			for k,v in pairs(files.Pictures) do
				table.insert(results[player:get_player_name()], v)
			end
		end
		if fields.music_f then
			results[player:get_player_name()] = {}
			get_music()
			file_system(player, files.Music)
			for k,v in pairs(files.Music) do
				table.insert(results[player:get_player_name()], v)
			end
		end
		local event = minetest.explode_table_event(fields.contents)
		if event.type == "DCL" then
			local application = {}
			local file = {}
			if results[player:get_player_name()][event.row] ~= nil then
				if results[player:get_player_name()][event.row]:match("%.ogg") then
					music_row[player:get_player_name()] = event.row
					for k,v in pairs(results[player:get_player_name()]) do
						table.insert(file, v)
					end
					if file[event.row] ~= nil then
						register_task("tmusic_player", player)
						handle_tasks("tmusic_player", player)
						current_tasks[player:get_player_name()] = current_tasks[player:get_player_name()] ..
						tmusic_player_task[player:get_player_name()]
						active_task[player:get_player_name()] = "tmusic_player"
						tmusic_player_status[player:get_player_name()] = "minimized"
						search_word[player:get_player_name()] = ""
						results[player:get_player_name()] = {}
						end_task("file_system", player)
						tmusic_player(player)
					end
				elseif results[player:get_player_name()][event.row]:match("%.mn") then
					for k,v in pairs(results[player:get_player_name()]) do
						table.insert(file, v)
					end
					if file[event.row] ~= nil then
						text[player:get_player_name()] = minetest.serialize(
						file[event.row]):
						gsub("return ", ""):gsub("{", ""):
						gsub("}", ""):gsub("\"", ""):
						gsub(".+%.mn %- ", "")
						if not minetest.serialize(tasks.name[player:get_player_name()]):
						match("notepad") then
							register_task("notepad", player)
							handle_tasks("notepad", player)
							current_tasks[player:get_player_name()] = current_tasks[player:get_player_name()] ..
							notepad_task[player:get_player_name()]
						end
						active_task[player:get_player_name()] = "notepad"
						notepad_status[player:get_player_name()] = "minimized"
						search_word[player:get_player_name()] = ""
						results[player:get_player_name()] = {}
						end_task("file_system", player)
						notepad(player)
					end
				elseif results[player:get_player_name()][event.row]:match("%.png") then
					for k,v in pairs(results[player:get_player_name()]) do
						table.insert(file, v)
					end
					if file[event.row] ~= nil then
						register_task("pic_viewer", player)
						handle_tasks("pic_viewer", player)
						current_tasks[player:get_player_name()] = current_tasks[player:get_player_name()] ..
						pic_viewer_task[player:get_player_name()]
						active_task[player:get_player_name()] = "pic_viewer"
						pic_viewer_status[player:get_player_name()] = "minimized"
						search_word[player:get_player_name()] = ""
						results[player:get_player_name()] = {}
						end_task("file_system", player)
						image_to_display[player:get_player_name()] = file[event.row]
						pic_viewer(player)
					end
				elseif results[player:get_player_name()][event.row]:match("Downloads not") then
					return false
				else
					application = string.lower(
					results[player:get_player_name()][event.row])
					register_task(application, player)
					current_tasks[player:get_player_name()] = current_tasks[player:get_player_name()] ..
					handle_tasks(application, player)
					active_task[player:get_player_name()] = application
					_G[application .. "_status"][player:get_player_name()] = "minimized"
					search_word[player:get_player_name()] = ""
					results[player:get_player_name()] = {}
					end_task("file_system", player)
					if application == "email" then
						email(player, inbox_items(player))
					else
						_G[application](player)
					end
				end
			end
		end
		if event.type == "CHG" then
			selected[player:get_player_name()] = "true"
			item[player:get_player_name()] = event.row
		end
		if fields.delete then
			if files.Documents[player:get_player_name()] ~= nil then
				if selected[player:get_player_name()] == "true" then
					if #results[player:get_player_name()] > 0 then
						if results[player:get_player_name()][item[player:get_player_name()]]:match("%.mn") then
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
		end
		if fields.yes then
			table.remove(files.Documents[player:get_player_name()],
			item[player:get_player_name()])
			save_files()
			item[player:get_player_name()] = {}
			file_system(player, files.Documents[player:
			get_player_name()])
			selected[player:get_player_name()] = "false"
		end
		if fields.no then
			file_system(player, files.Documents[player:
			get_player_name()])
			selected[player:get_player_name()] = "false"
		end
	end
end)
