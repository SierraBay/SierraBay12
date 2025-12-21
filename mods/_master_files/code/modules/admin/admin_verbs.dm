/datum/admins/proc/mp_panel()
	set category = "Fun"
	set name = "MP Panel"
	set desc = "Lists all current music players and control it."

	if(!check_rights(R_ADMIN|R_FUN, 0, usr))
		return

	var/list/dat = list("<div align='center'><h1>Music Player Control Panel</h1><br>")

	dat += "<b>Current music players in world ([LAZYLEN(GLOB.music_players)]):</b></div><br>"
	dat += "<hr>"

	if(LAZYLEN(GLOB.music_players) == 0)
		dat += "<div class='statusDisplay'><center>At the moment there are no devices in this world session.</center></div>"
	else
		for(var/a in GLOB.music_players)
			var/obj/item/music_player/p = a
			var/obj/item/music_tape/tape = p.tape
			var/track_name = "no track"

			if(!tape)
				track_name = "no tape"
			else if(tape.track && tape.track.title)
				track_name = tape.track.title

			dat += "<div class='statusDisplay'>"
			dat += "Music Player #[p.serial_number] ([track_name]) : <br>"
			dat += "<a href='?_src_=holder;mp_play=\ref[p]'>[p.mode ? "<font color=cc5555>Stop</font>" : "<font color=55cc55>Play</font>"]</a> | "
			dat += "<a href='?_src_=holder;mp_volume=\ref[p]'>Volume</a> | "
			dat += "<a href='?_src_=holder;adminplayerobservefollow=\ref[p]'>Current location</a> | "
			dat += "<a href='?_src_=vars;Vars=\ref[p]'>VV</a> | "
			if(tape && tape.track && tape.track.source)
				dat += "<a href='?_src_=holder;listen_tape_sound=\ref[tape.track.source]'>Play to yourself</a> | "
			dat += "<a href='?_src_=holder;mp_explode=\ref[p]'><font color=cc5555>\[X\]</font></a><br>"
			dat += "</div>"

	var/datum/browser/popup = new(usr, "mp_panel",, 500, 325, src)
	popup.set_content(jointext(dat, null))
	popup.open()