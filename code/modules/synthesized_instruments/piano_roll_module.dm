/datum/nano_module/piano_editor
	var/datum/synthesized_song/song
	var/datum/real_instrument/instrument
	var/list/save_buffer = list() 
	var/expected_chunks = 0

/datum/nano_module/piano_editor/New(datum/real_instrument/I, datum/synthesized_song/S)
	..()
	src.instrument = I
	src.song = S

/datum/nano_module/piano_editor/ui_interact(mob/user, ui_key = "piano_editor", datum/nanoui/ui = null, force_open = 0)
	var/list/data = list()
	data["ref"] = "\ref[src]"
	
	var/display_bpm = 120
	if(song.tempo > 0)
		display_bpm = round(600 / song.tempo)
	
	// When loading into editor, check for BPM header
	if (length(song.lines) && findtext(song.lines[1], "BPM: "))
		var/found_bpm = text2num(copytext(song.lines[1], 6))
		if(found_bpm) 
			display_bpm = found_bpm
			// Do NOT Cut(1,2) here permanently, as it might affect other UIs. 
			// We just use the value for display.
	
	data["tempo"] = display_bpm

	var/list/chords = list()
	var/current_time = 0
	
	if(song && length(song.lines))
		var/list/last_octaves = list("c"=3,"d"=3,"e"=3,"f"=3,"g"=3,"a"=3,"b"=3)
		
		for(var/line in song.lines)
			if(!line || findtext(line, "BPM: "))
				continue
			
			var/list/line_chords = splittext(line, ",")
			for(var/chord_str in line_chords)
				if(!chord_str) 
					chords += list(list("notes" = list(), "div" = 1))
					continue
				
				var/list/chord_data = list()
				var/list/parts = splittext(chord_str, "/")
				if(!length(parts))
					continue
				
				var/list/notes_raw = splittext(parts[1], "-")
				var/div = 1
				if(length(parts) > 1)
					div = text2num(parts[2]) || 1

				var/list/notes = list()
				for(var/N in notes_raw)
					if(!N)
						continue
					var/n_lower = lowertext(N)
					var/name = copytext(n_lower, 1, 2)
					var/acc = ""
					var/oct_idx = 2
					if(copytext(n_lower, 2, 3) in list("#", "b", "n", "s"))
						acc = copytext(n_lower, 2, 3)
						oct_idx = 3
					
					var/oct_str = copytext(n_lower, oct_idx)
					var/oct = last_octaves[name]
					if(oct_str && text2num(oct_str) != null)
						oct = text2num(oct_str)
						last_octaves[name] = oct
					
					notes += "[name][acc][oct]"

				chord_data["notes"] = notes
				chord_data["div"] = div
				chords += list(chord_data)
				
				current_time += (1 / div)
	
	data["chords"] = chords
	data["playback"] = list(
		"playing" = song.playing, 
		"pos" = song ? song.current_playback_time : 0,
		"can_resume" = (song.current_line > 1 && !song.playing),
		"song_version" = song.song_version
	)

	ui = SSnano.try_update_ui(user, instrument.owner, ui_key, ui, data, force_open)
	if (!ui)
		ui = new /datum/nanoui(user, instrument.owner, ui_key, "piano_window_interface.tmpl", "Piano Roll Editor", 1200, 700)
		ui.add_script("piano_editor_script.js")
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/piano_editor/Topic(href, href_list)
	if (..())
		return 1

	if(href_list["save_chunk"])
		var/idx = text2num(href_list["idx"])
		var/total = text2num(href_list["total"])
		var/chunk = href_list["data"]
		if (idx == 0 || !save_buffer || length(save_buffer) != total)
			save_buffer = list()
			for(var/i = 1; i <= total; i++)
				save_buffer += ""
			expected_chunks = total
		
		save_buffer[idx + 1] = chunk
		return 1

	if(href_list["save_commit"])
		var/received_count = 0
		for(var/C in save_buffer)
			if(C) received_count++
		
		if(received_count < expected_chunks)
			to_chat(usr, "<span class='warning'>Save failed: Missing data chunks. Please try saving again.</span>")
			save_buffer = list() 
			expected_chunks = 0
			return 1

		var/full_text = jointext(save_buffer, "")
		save_buffer = list() 
		expected_chunks = 0
		
		if(!full_text)
			to_chat(usr, "<span class='warning'>Save failed: Received empty song data.</span>")
			return 1

		// ADVANCED SYNC: Directly parse the song text format
		song.lines = splittext(full_text, "\n")
		
		if(length(song.lines) && findtext(song.lines[1], "BPM: "))
			var/bpm = text2num(copytext(song.lines[1], 6))
			if(bpm)
				song.tempo = 600 / bpm
			// Keep the BPM header in lines for persistence, 
			// the editor load logic handles skipping it.
		else
			// Fallback: Use tempo param if header is missing
			if(href_list["tempo"])
				var/bpm = text2num(href_list["tempo"])
				song.tempo = 600 / bpm

		to_chat(usr, "Project saved successfully!")
		SSnano.update_uis(instrument.owner)
		return 1

	return 1
