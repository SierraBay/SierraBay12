/obj/item/device/scanner/health/show_menu(mob/user)
	tgui_interact(user)

/obj/item/device/scanner/health/scan(atom/A, mob/user)
	scan_data = medical_scan_action(A, user, src, mode, FALSE)
	playsound(src, 'sound/effects/fastbeep.ogg', 20)
	if(!scan_data)
		return
	scan_title = "[capitalize(name)] scan - [A]"
	tgui_interact(user)

/obj/item/device/scanner/health/tgui_state(mob/user)
	return GLOB.tgui_hands_state

/obj/item/device/scanner/health/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HealthAnalyzer", name)
		ui.open()

/obj/item/device/scanner/health/tgui_data(mob/user)
	var/list/data = list()
	data["scan_title"] = scan_title
	data["has_scan"] = !!scan_data
	data["scan_results"] = list()
	data["reagent_results"] = list()
	if(!scan_data)
		return data

	// Scan results are stored as one html string (also used for printing); split it into lines for the interface.
	var/list/lines = splittext(replacetext(scan_data, regex("<style>.*?</style>", "g"), ""), "<br>")
	var/list/scan_lines = list()
	var/list/reagent_lines = list()
	var/in_reagents = FALSE
	// The first line is the "Scan results for ..." header, which the window title already shows.
	for(var/i = 2 to length(lines))
		var/line = lines[i]
		if(!length(trimtext(line)))
			continue
		if(findtext(line, "Reagent scan:"))
			in_reagents = TRUE
			continue
		if(in_reagents)
			reagent_lines += line
		else
			scan_lines += line
	data["scan_results"] = scan_lines
	data["reagent_results"] = reagent_lines
	return data

/obj/item/device/scanner/health/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return TRUE
	var/mob/user = usr
	switch(action)
		if("print")
			print_report(user)
			return TRUE
		if("clear")
			to_chat(user, "You clear data buffer on [src].")
			scan_data = null
			scan_title = null
			return TRUE
