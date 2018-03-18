music_playing = {}
tmusic_player_task = {}
tmusic_player_status = {}
local song = {}
local row = {}

minetest.register_on_joinplayer(function(player)
	tmusic_player_task[player:get_player_name()] = {}
	tmusic_player_status[player:get_player_name()] = {}
	song[player:get_player_name()] = {}
	row[player:get_player_name()] = {}
	music_playing[player:get_player_name()] = nil
	music_row[player:get_player_name()] = {}
end)

minetest.mkdir(minetest.get_modpath("mineos") .. "/sounds")

function get_music()
	files.Music = minetest.get_dir_list(minetest.get_modpath("mineos") ..
	"/sounds", false)
	local s = minetest.serialize(files.Music)
	return s:gsub("_", ""):gsub("return ",""):gsub("mineos", ""):
	gsub("%.ogg", ""):gsub("{", ""):gsub("}", ""):gsub("\"", ""):gsub(" ", "")
end

function tmusic_player(player)
	local select = {}
	if minetest.serialize(music_row[player:get_player_name()]):match("%d") then
		select = music_row[player:get_player_name()]
	else
		select = ""
	end
	desktop(player, files.theme[player:get_player_name()] ..
	"^tmusic_player_overlay.png",
	"label[2.5,2.5;Playable songs:]" ..
	"image[5,2;3,.75;tmusic_logo.png]" ..
	"image_button[9.8,2.03;.6,.4" .. get_button_style(player,
	"tmusic_player", "white").close[player:get_player_name()] .. ";true;false;]" ..
	"image_button[9.4,2;.6,.45" .. get_button_style(player,
	"tmusic_player", "white").min[player:get_player_name()] .. ";true;false;]" ..
	"textlist[2.5,3;6,3.75;song_list;".. get_music() .. ";" .. select .. ";]" ..
	"image_button[8.5,5.5;1.5,.5;;stop;Stop;true;false;]" ..
	"image_button[8.5,5;1.5,.5;;loop_current;Loop Current;true;false;]" ..
	"image_button[8.5,6;1.5,.5;;help;Help;true;false]" ..
	current_tasks[player:get_player_name()])
end

minetest.setting_set("individual_loop", "true")

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.tmusic_player then
			remember_notes(fields, player)
			if not current_tasks[player:get_player_name()]:match("tmusic_player") then
				register_task("tmusic_player", player)
				handle_tasks("tmusic_player", player)
				current_tasks[player:get_player_name()] = current_tasks[player:get_player_name()] .. tmusic_player_task[player:get_player_name()]
			end
			active_task[player:get_player_name()] = "tmusic_player"
			tmusic_player_status[player:get_player_name()] = "minimized"
			tmusic_player(player)
		end
		if fields.close_tmusic_player then
			end_task("tmusic_player", player)
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
			music_row[player:get_player_name()] = {}
		end
		if fields.minimize_tmusic_player then
			tmusic_player_status[player:get_player_name()] = "minimized"
			desktop(player, files.theme[player:get_player_name()],
			current_tasks[player:get_player_name()])
		end
		if fields.tmusic_player_task then
			remember_notes(fields, player)
			active_task[player:get_player_name()] = "tmusic_player"
			change_tasks("tmusic_player", player)
			if tmusic_player_status[player:get_player_name()] == "minimized" then
				tmusic_player(player)
				tmusic_player_status[player:get_player_name()] = "maximized"
			else
				desktop(player, files.theme[player:get_player_name()],
				current_tasks[player:get_player_name()])
				tmusic_player_status[player:get_player_name()] = "minimized"
			end
		end
		if fields.stop then
               		if music_playing[player:get_player_name()] == nil then
                    		return false
               		else
				song[player:get_player_name()] = {}
                    		music_playing[player:get_player_name()] = minetest.sound_stop(music_playing[player:get_player_name()])
                    		minetest.setting_set("individual_loop", "false")
               		end
          	end
          	if fields.loop_current then
               		if minetest.setting_getbool("individual_loop") == true then
                    		if music_playing[player:get_player_name()] ~= nil then
                         		music_playing[player:get_player_name()] = minetest.sound_stop(
					music_playing[player:get_player_name()])
				end
                         	if music_playing[player:get_player_name()] == nil then
                              		music_playing[player:get_player_name()] = minetest.sound_play(
					song[player:get_player_name()], {
                                   	gain = 10,
                                   	to_player =
					player:get_player_name(),
					loop = true
                              		})
                         	end
               		end
          	end
		local event = minetest.explode_textlist_event(fields.song_list)
		if event.type == "CHG" then
			if #files.Music >= 1 then
				row[player:get_player_name()] = event.index
				if music_playing[player:get_player_name()] ~= nil then
					music_playing[player:get_player_name()] = minetest.sound_stop(
					music_playing[player:get_player_name()])
				end
				if music_playing[player:get_player_name()] == nil then
					song[player:get_player_name()] = files.Music[event.index]:gsub(
					"%.ogg", "")
					music_playing[player:get_player_name()] = minetest.sound_play(song[player:get_player_name()], {
						gain = 10,
						to_player = player:get_player_name()
					})
				end
			end
		end
		if fields.help then
			local help_text_1 = "To add music" ..
			minetest.formspec_escape(",") .. " convert your audio file into" ..
			" an OGG Vorbis format and save it to the mod's" ..
			" sounds folder.  The filename convention is - " ..
			"mineos_soundname.  An example is mineos_bowwowcow."
			local help_text_2 = "To play music" ..
			minetest.formspec_escape(",") .. " click on the song you" ..
			" would like to play."
			local help_text_3 = "To stop music" ..
			minetest.formspec_escape(",") .. " click the stop" ..
			" button.  If there was no music playing to begin with" ..
			minetest.formspec_escape(",") .. " nothing, will happen."
			local help_text_4 = "To repeat the current song" ..
			minetest.formspec_escape(",") .. " click the song and" ..
			" click Loop Current."
			desktop(player, files.theme[player:get_player_name()] ..
			"^tmusic_player_overlay.png",
			"label[6,2;Help]" ..
			"textlist[2.5,2.5;7,3;help_info;" .. "Adding Music:," ..
			wrap_textlist_text(help_text_1, 80) .. ",,Playing Music:," ..
			help_text_2 .. ",,Stopping Music:," ..
			help_text_3 .. ",,Looping Current Song:," ..
			help_text_4 .. ";;true]" ..
			"image[3,6;3,.75;tmusic_logo.png]" ..
			"image_button[7,6;1.5,.5;;music_back;Back;true;false;]" ..
			current_tasks[player:get_player_name()])
		end
		if fields.music_back then
			tmusic_player(player)
		end
	end
end)
