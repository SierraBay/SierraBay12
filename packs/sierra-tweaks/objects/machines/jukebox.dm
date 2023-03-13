//
// Media Player Jukebox
// Rewritten by Leshana from existing Polaris code, merging in D2K5 and N3X15 work
//

#define JUKEMODE_NEXT        1 // Advance to next song in the track list
#define JUKEMODE_RANDOM      2 // Not shuffle, randomly picks next each time.
#define JUKEMODE_REPEAT_SONG 3 // Play the same song over and over
#define JUKEMODE_PLAY_ONCE   4 // Play, then stop.

/obj/machinery/media/jukebox
	name = "space jukebox"
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "superjuke"
	var/state_base = "superjuke"
	anchored = 1
	density = 1
	power_channel = EQUIP
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100

	var/hacked = 0 // Whether to show the hidden songs or not

	var/obj/item/music_tape/tape

	var/loop_mode = JUKEMODE_PLAY_ONCE			// Behavior when finished playing a song
	var/max_queue_len = 3						// How many songs are we allowed to queue up?
	var/datum/track/current_track				// Currently playing song
	var/list/datum/track/queue = list()			// Queued songs
	var/list/datum/track/tracks = list()		// Available tracks
	var/list/datum/track/secret_tracks = list() // Only visible if hacked

/obj/machinery/media/jukebox/New()
	..()
	queue_icon_update()

// On initialization, copy our tracks from the global list
/obj/machinery/media/jukebox/Initialize()
	..()
	if(all_jukebox_tracks.len < 1)
		stat |= MACHINE_BROKEN_GENERIC // No tracks configured this round!
		return
	// Ootherwise load from the global list!
	for(var/datum/track/T in all_jukebox_tracks)
		if(T.secret)
			secret_tracks |= T
		else
			tracks |= T
	return

/obj/machinery/media/jukebox/Process()
	if(!playing)
		return
	if(inoperable())
		disconnect_media_source()
		playing = 0
		return
	// If the current track isn't finished playing, let it keep going
	if(current_track && world.time < media_start_time + current_track.duration)
		return
	// Otherwise time to pick a new one!
	if(queue.len > 0)
		current_track = queue[1]
		queue.Cut(1, 2)  // Remove the item we just took off the list
	else
		// Oh... nothing in queue? Well then pick next according to our rules
		switch(loop_mode)
			if(JUKEMODE_NEXT)
				var/curTrackIndex = max(1, tracks.Find(current_track))
				var/newTrackIndex = (curTrackIndex % tracks.len) + 1  // Loop back around if past end
				current_track = tracks[newTrackIndex]
			if(JUKEMODE_RANDOM)
				var/previous_track = current_track
				do
					current_track = pick(tracks)
				while(current_track == previous_track && tracks.len > 1)
			if(JUKEMODE_REPEAT_SONG)
				current_track = current_track
			if(JUKEMODE_PLAY_ONCE)
				current_track = null
				playing = 0
				update_icon()
	updateDialog()
	start_stop_song()

// Tells the media manager to start or stop playing based on current settings.
/obj/machinery/media/jukebox/proc/start_stop_song()
	if(current_track && playing)
		media_url = current_track.url
		media_start_time = world.time
		visible_message("<span class='notice'>\The [src] begins to play [current_track.display()].</span>")
	else
		media_url = ""
		media_start_time = 0
	update_music()


/obj/machinery/media/jukebox/attackby(obj/item/I, mob/user)
	if (isWrench(I))
		add_fingerprint(user)
		wrench_floor_bolts(user, 0)
		power_change()

		if(!anchored)
			playing = 0
			disconnect_media_source()
		else
			update_media_source()
		return


	// INF@CODE - START
	if(istype(I, /obj/item/music_tape))
		var/obj/item/music_tape/D = I
		if(tape)
			to_chat(user, "<span class='notice'>There is already \a [tape] inside.</span>")
			return

		if(D.ruined)
			to_chat(user, "<span class='warning'>\The [D] is ruined, you can't use it.</span>")
			return

		if(user.drop_item())
			visible_message("<span class='notice'>[usr] insert \a [tape] into \the [src].</span>")
			D.forceMove(src)
			tape = D
			tracks += tape.track
		return
	// INF@CODE - END


	return ..()

/obj/machinery/media/jukebox/power_change()
	if(!powered(power_channel) || !anchored)
		stat |= MACHINE_STAT_NOPOWER
	else
		stat &= ~MACHINE_STAT_NOPOWER

	if(stat & (MACHINE_STAT_NOPOWER|MACHINE_BROKEN_GENERIC) && playing)
		StopPlaying()
	update_icon()

/obj/machinery/media/jukebox/on_update_icon()
	overlays.Cut()
	if (!anchored || inoperable())
		icon_state = "[initial(icon_state)]-[MACHINE_IS_BROKEN(src) ? "broken" : "nopower"]"
		return
	icon_state = initial(icon_state)
	if (playing)
		return
	overlays += "[initial(icon_state)]-[emagged ? "emagged" : "running"]"

/obj/machinery/media/jukebox/Topic(href, href_list)
	if(..() || !(Adjacent(usr) || istype(usr, /mob/living/silicon)))
		return

	if(!anchored)
		usr << "<span class='warning'>You must secure \the [src] first.</span>"
		return

	if(inoperable())
		usr << "\The [src] doesn't appear to function."
		return

	if(href_list["change_track"])
		var/datum/track/T = locate(href_list["change_track"]) in tracks
		if(istype(T))
			current_track = T
			StartPlaying()
	else if(href_list["loopmode"])
		var/newval = text2num(href_list["loopmode"])
		loop_mode = sanitize_inlist(newval, list(JUKEMODE_NEXT, JUKEMODE_RANDOM, JUKEMODE_REPEAT_SONG, JUKEMODE_PLAY_ONCE), loop_mode)
	else if(href_list["volume"])
		var/newval = input("Choose Jukebox volume (0-100%)", "Jukebox volume", round(volume * 100.0))
		newval = sanitize_integer(text2num(newval), min = 0, max = 100, default = volume * 100.0)
		volume = newval / 100.0
		update_music() // To broadcast volume change without restarting song
	else if(href_list["stop"])
		StopPlaying()
	else if(href_list["play"])
		if(current_track == null)
			usr << "No track selected."
		else
			StartPlaying()

	return 1

/obj/machinery/media/jukebox/interact(mob/user)
	if(inoperable())
		usr << "\The [src] doesn't appear to function."
		return
	ui_interact(user)

/obj/machinery/media/jukebox/ui_interact(mob/user, ui_key = "jukebox", var/datum/nanoui/ui = null, var/force_open = 1)
	var/title = "RetroBox - Space Style"
	var/data[0]

	if(operable())
		data["playing"] = playing
		data["hacked"] = hacked
		data["max_queue_len"] = max_queue_len
		data["media_start_time"] = media_start_time
		data["loop_mode"] = loop_mode
		data["volume"] = volume
		if(current_track)
			data["current_track_ref"] = "\ref[current_track]"  // Convenient shortcut
			data["current_track"] = current_track.toNanoList()
		data["percent"] = playing ? min(100, round(world.time - media_start_time) / current_track.duration) : 0;

		var/list/nano_tracks = new
		for(var/datum/track/T in tracks)
			nano_tracks[++nano_tracks.len] = T.toNanoList()
		data["tracks"] = nano_tracks

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "_jukebox.tmpl", title, 450, 600)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(playing)

/obj/machinery/media/jukebox/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/media/jukebox/attack_hand(var/mob/user as mob)
	interact(user)

/obj/machinery/media/jukebox/proc/StopPlaying()
	playing = 0
	update_use_power(1)
	update_icon()
	start_stop_song()

/obj/machinery/media/jukebox/proc/StartPlaying()
	if(!current_track)
		return
	playing = 1
	update_use_power(2)
	update_icon()
	start_stop_song()
	updateDialog()

// Advance to the next track - Don't start playing it unless we were already playing
/obj/machinery/media/jukebox/proc/NextTrack()
	if(!tracks.len) return
	var/curTrackIndex = max(1, tracks.Find(current_track))
	var/newTrackIndex = (curTrackIndex % tracks.len) + 1  // Loop back around if past end
	current_track = tracks[newTrackIndex]
	if(playing)
		start_stop_song()
	updateDialog()

// Advance to the next track - Don't start playing it unless we were already playing
/obj/machinery/media/jukebox/proc/PrevTrack()
	if(!tracks.len) return
	var/curTrackIndex = max(1, tracks.Find(current_track))
	var/newTrackIndex = curTrackIndex == 1 ? tracks.len : curTrackIndex - 1
	current_track = tracks[newTrackIndex]
	if(playing)
		start_stop_song()
	updateDialog()
