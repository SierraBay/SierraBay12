/datum/nano_module/visualizer
	var/datum/real_instrument/instrument
	var/list/active_notes = list()

/datum/nano_module/visualizer/New(datum/real_instrument/I)
	..(I)
	instrument = I

/datum/nano_module/visualizer/ui_interact(mob/user, ui_key = "visualizer", datum/nanoui/ui = null, force_open = 0)
	var/list/active_notes_list = list()
	for(var/N in active_notes)
		active_notes_list += text2num(N)

	var/list/data = list(
		"active_notes" = active_notes_list
	)

	ui = SSnano.try_update_ui(user, instrument.owner, ui_key, ui, data, force_open)
	if (!ui)
		var/list/keys = list()
		var/list/note_names = list("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B")
		for(var/i=21; i<=108; i++)
			var/note_in_octave = i % 12
			var/is_black = (note_in_octave in list(1, 3, 6, 8, 10))
			var/note_name = "[note_names[note_in_octave + 1]][round(i / 12)]"
			keys += list(list(
				"id" = i,
				"is_black" = is_black,
				"name" = note_name
			))
		data["keys"] = keys

		ui = new (user, instrument.owner, ui_key, "visualizer.tmpl", "Piano Visualizer", 1500, 300)
		ui.add_script("piano_visualizer.js")
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
		ui.set_auto_update_content(0) // Disable automatic full re-render for stability

/datum/nano_module/visualizer/proc/note_on(note_num, duration)
	active_notes["[note_num]"] = 1
	SSnano.update_uis(instrument.owner)
	addtimer(new Callback(src, PROC_REF(note_off), note_num), duration)

/datum/nano_module/visualizer/proc/note_off(note_num)
	active_notes -= "[note_num]"
	SSnano.update_uis(instrument.owner)
