/datum/computer_file/program/crew_manifest
	extended_desc = "This program allows access to the manifest of active crew. During an Odyssey campaign it also archives crew lists from previous shifts."


/datum/nano_module/program/crew_manifest
	/// Shift numbers currently expanded in the Odyssey past-manifest accordion. Survives NanoUI auto-refresh.
	var/list/odyssey_open_past_shifts


/datum/nano_module/program/crew_manifest/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, state = GLOB.default_state)
	var/list/data = host.initial_data(program)

	data["crew_manifest"] = html_crew_manifest(TRUE)
	data["odyssey_past_manifest"] = odyssey_html_past_crew_manifest(TRUE, odyssey_open_past_shifts, src)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "crew_manifest.tmpl", name, 450, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_auto_update(1)
		ui.set_initial_data(data)
		ui.open()


/datum/nano_module/program/crew_manifest/Topic(href, href_list)
	if (..())
		return TRUE
	if (href_list["odyssey_toggle_past"])
		var/shift = text2num(href_list["odyssey_toggle_past"])
		if (!shift)
			return FALSE
		var/key = "[shift]"
		if (!odyssey_open_past_shifts)
			odyssey_open_past_shifts = list()
		if (odyssey_open_past_shifts[key])
			odyssey_open_past_shifts -= key
		else
			odyssey_open_past_shifts[key] = TRUE
		SSnano.update_uis(src)
		return TRUE
	return FALSE
