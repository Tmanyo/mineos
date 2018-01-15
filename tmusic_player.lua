music_playing = nil

tmusic_player_task = {}
tmusic_player_status = {}

local song = {}

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
	if minetest.serialize(music_row):match("%d") then
		select = music_row
	else
		select = ""
	end
	desktop(player, "default_tmusic",
	"label[2.5,2.5;Playable songs:]" ..
	"image[5,2;3,.75;tmusic_logo.png]" ..
	"image_button[9.9,2.15;.5,.3;;close_tmusic;X;true;false;]" ..
	"image_button[9.6,2.15;.5,.3;;minimize_tmusic;--;true;false;]" ..
	"textlist[2.5,3;6,3.75;song_list;".. get_music() .. ";" .. select .. ";]" ..
	"image_button[8.5,5.5;1.5,.5;;stop;Stop;true;false;]" ..
	"image_button[8.5,5;1.5,.5;;loop_current;Loop Current;true;false;]" ..
	"image_button[8.5,6;1.5,.5;;help;Help;true;false]" ..
	current_tasks)
end

minetest.setting_set("individual_loop", "true")

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mineos:desktop" then
		if fields.tmusic_player then
			remember_notes(fields)
			if not current_tasks:match("tmusic_player") then
				register_task("tmusic_player")
				handle_tasks("tmusic_player")
				current_tasks = current_tasks .. tmusic_player_task
			end
			active_task = "tmusic_player"
			tmusic_player_status = "minimized"
			tmusic_player(player)
		end
		if fields.close_tmusic then
			end_task("tmusic_player")
			desktop(player, "default", current_tasks)
			music_row = {}
		end
		if fields.minimize_tmusic then
			tmusic_player_status = "minimized"
			desktop(player, "default", current_tasks)
		end
		if fields.tmusic_player_task then
			remember_notes(fields)
			active_task = "tmusic_player"
			change_tasks("tmusic_player")
			if tmusic_player_status == "minimized" then
				tmusic_player(player)
				tmusic_player_status = "maximized"
			else
				desktop(player, "default", current_tasks)
				tmusic_player_status = "minimized"
			end
		end
		if fields.stop then
               		if music_playing == nil then
                    		return false
               		else
				song = {}
                    		music_playing = minetest.sound_stop(music_playing)
                    		minetest.setting_set("individual_loop", "false")
               		end
          	end
          	if fields.loop_current then
               		if minetest.setting_getbool("individual_loop") == true then
                    		if music_playing ~= nil then
                         		music_playing = minetest.sound_stop(
					music_playing)
				end
                         	if music_playing == nil then
                              		music_playing = minetest.sound_play(
					song, {
                                   	gain = 10,
                                   	to_player =
					minetest.get_connected_players(),
					loop = true
                              		})
                         	end
               		end
          	end
		local event = minetest.explode_textlist_event(fields.song_list)
		if event.type == "CHG" then
			if #files.Music >= 1 then
				if music_playing ~= nil then
					music_playing = minetest.sound_stop(
					music_playing)
				end
				if music_playing == nil then
					song = files.Music[event.index]:gsub(
					"%.ogg", "")
					music_playing = minetest.sound_play(song, {
						gain = 10,
						to_player = minetest.get_connected_players()
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
			minetest.formspec_escape(",") .. " nothing will happen."
			local help_text_4 = "To repeat the current song" ..
			minetest.formspec_escape(",") .. " click the song and" ..
			" click Loop Current."
			desktop(player, "default_tmusic",
			"label[6,2;Help]" ..
			"textlist[2.5,2.5;7,3;help_info;" .. "Adding Music:," ..
			wrap_text(help_text_1, 90) .. ",,Playing Music:," ..
			help_text_2 .. ",,Stopping Music:," ..
			wrap_text(help_text_3, 90) .. ",,Looping Current Song:," ..
			help_text_4 .. ";;true]" ..
			"image[3,6;3,.75;tmusic_logo.png]" ..
			"image_button[7,6;1.5,.5;;music_back;Back;true;false;]" ..
			current_tasks)
		end
		if fields.music_back then
			tmusic_player(player)
		end
	end
end)
