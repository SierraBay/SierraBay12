// ============================================================
// Artifact Scanpad — simple platform for placing items/artifacts
// ============================================================

/obj/machinery/artifact_scanpad
	name = "Anomaly Scanner Pad"
	desc = "A reinforced platform for placing anomalous objects and samples for scanning."
	icon = 'icons/obj/machines/research/xenoarcheology_scanner.dmi'
	icon_state = "xenoarch_scanner"
	anchored = TRUE
	density = FALSE

// ============================================================
// Artifact Analyser — thin remote controller for the spectrometer
// All scanning mechanics live on the radiocarbon_spectrometer.
// ============================================================

/obj/machinery/artifact_analyser
	name = "Anomaly Analyser"
	desc = "A remote console that controls a linked radiocarbon spectrometer to study anomalous materials."
	icon = 'mods/RnD/icons/xenoarcheology_scanner.dmi'
	icon_state = "xenoarch_console"
	anchored = TRUE
	density = TRUE
	var/obj/machinery/radiocarbon_spectrometer/linked_spectrometer
	var/obj/scanned_object
	var/report_num = 0

/obj/machinery/artifact_analyser/Initialize()
	. = ..()
	sync_with_spectrometer()

/obj/machinery/artifact_analyser/Destroy()
	if(linked_spectrometer)
		if(linked_spectrometer.remote_console == src)
			linked_spectrometer.remote_console = null
		linked_spectrometer = null
	release_scanned_object()
	return ..()

/obj/machinery/artifact_analyser/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/artifact_analyser/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(user.stat)
		return

	if(!linked_spectrometer)
		sync_with_spectrometer()

	var/obj/machinery/radiocarbon_spectrometer/spec = linked_spectrometer

	var/data[0]
	if(spec)
		// Mirror all spectrometer data
		data["last_scan_data"] = spec.last_scan_data
		data["scan_progress"] = round(spec.scanner_progress)
		data["scanning"] = spec.scanning
		data["scanner_seal_integrity"] = round(spec.scanner_seal_integrity)
		data["scanner_rpm"] = round(spec.scanner_rpm)
		data["scanner_temperature"] = round(spec.scanner_temperature)
		data["coolant_usage_rate"] = "[spec.coolant_usage_rate]"
		data["unused_coolant_abs"] = round(spec.fresh_coolant)
		data["unused_coolant_per"] = round(spec.fresh_coolant / spec.reagents.maximum_volume * 100)
		data["coolant_purity"] = "[spec.coolant_purity * 100]"
		data["optimal_wavelength"] = round(spec.optimal_wavelength)
		data["maser_wavelength"] = round(spec.maser_wavelength)
		data["maser_efficiency"] = round(spec.maser_efficiency * 100)
		data["radiation"] = round(spec.radiation)
		data["t_left_radspike"] = round(spec.t_left_radspike)
		data["rad_shield_on"] = spec.rad_shield
		data["pad_linked"] = !!spec.linked_pad
		// Find target on pad
		var/pad_target_name = ""
		if(spec.linked_pad)
			for(var/obj/O in spec.linked_pad.loc)
				if(O == spec.linked_pad || O.invisibility)
					continue
				if(istype(O, /obj/machinery) && !istype(O, /obj/machinery/artifact))
					continue
				pad_target_name = O.name
				break
			if(!pad_target_name)
				for(var/obj/item/I in spec.linked_pad.loc)
					pad_target_name = I.name
					break
		data["pad_target"] = pad_target_name
	else
		// No spectrometer — show empty state
		data["last_scan_data"] = "No spectrometer linked."
		data["scan_progress"] = 0
		data["scanning"] = 0
		data["scanner_seal_integrity"] = 0
		data["scanner_rpm"] = 0
		data["scanner_temperature"] = 0
		data["coolant_usage_rate"] = "0"
		data["unused_coolant_abs"] = 0
		data["unused_coolant_per"] = 0
		data["coolant_purity"] = "0"
		data["optimal_wavelength"] = 0
		data["maser_wavelength"] = 0
		data["maser_efficiency"] = 0
		data["radiation"] = 0
		data["t_left_radspike"] = 0
		data["rad_shield_on"] = 0
		data["pad_linked"] = FALSE
		data["pad_target"] = ""

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "geoscanner.tmpl", "Anomaly Analyser — Remote Spectrometer Control", 900, 825)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/artifact_analyser/OnTopic(user, href_list)
	// Proxy all controls to the linked spectrometer
	if(!linked_spectrometer)
		return TOPIC_NOACTION

	if(href_list["begin_external_scan"])
		begin_scan()
		. = TOPIC_REFRESH

	else if(href_list["halt_external_scan"])
		halt_scan()
		. = TOPIC_REFRESH

	else if(href_list["maserWavelength"])
		linked_spectrometer.maser_wavelength = max(min(linked_spectrometer.maser_wavelength + 1000 * text2num(href_list["maserWavelength"]), 10000), 1)
		. = TOPIC_REFRESH

	else if(href_list["coolantRate"])
		linked_spectrometer.coolant_usage_rate = max(min(linked_spectrometer.coolant_usage_rate + text2num(href_list["coolantRate"]), 10000), 0)
		. = TOPIC_REFRESH

	else if(href_list["toggle_rad_shield"])
		linked_spectrometer.rad_shield = !linked_spectrometer.rad_shield
		. = TOPIC_REFRESH

	else if(href_list["sync_pad"])
		linked_spectrometer.sync_with_pad()
		. = TOPIC_REFRESH

/obj/machinery/artifact_analyser/proc/sync_with_spectrometer()
	// Unlink old
	if(linked_spectrometer && linked_spectrometer.remote_console == src)
		linked_spectrometer.remote_console = null
	linked_spectrometer = null

	for(var/obj/machinery/radiocarbon_spectrometer/S in range(7, src))
		linked_spectrometer = S
		S.remote_console = src
		// Also make sure spectrometer finds its pad
		if(!S.linked_pad)
			S.sync_with_pad()
		src.visible_message("<b>[name]</b> states, \"Spectrometer located, commencing sync.\"")
		return
	src.visible_message("<b>[name]</b> states, \"Sync unsuccessful, could not locate spectrometer.\"")

/obj/machinery/artifact_analyser/proc/begin_scan()
	if(!linked_spectrometer)
		sync_with_spectrometer()
	if(!linked_spectrometer)
		src.visible_message("<b>[name]</b> states, \"No spectrometer linked.\"")
		return
	if(!linked_spectrometer.linked_pad)
		src.visible_message("<b>[name]</b> states, \"Spectrometer has no scan pad.\"")
		return
	if(linked_spectrometer.scanning)
		src.visible_message("<b>[name]</b> states, \"Spectrometer is busy.\"")
		return

	var/obj/machinery/artifact_scanpad/pad = linked_spectrometer.linked_pad

	// Find scan target on the pad
	var/obj/target = null
	for(var/obj/O in pad.loc)
		if(O == pad || O.invisibility)
			continue
		if(istype(O, /obj/machinery)) // skip other machines on the tile (e.g. the spectrometer itself)
			var/obj/machinery/artifact/art_check = O
			if(!istype(art_check)) // only allow artifact-type machinery
				continue
		// Check if artifact is already in use
		if(istype(O, /obj/machinery/artifact))
			var/obj/machinery/artifact/artifact = O
			if(artifact.being_used)
				src.visible_message("<b>[name]</b> states, \"Cannot scan. Too much interference.\"")
				return
			artifact.anchored = TRUE
			artifact.being_used = TRUE
		target = O
		break

	if(!target)
		// Also check for items on the pad tile
		for(var/obj/item/I in pad.loc)
			target = I
			break

	if(!target)
		src.visible_message("<b>[name]</b> states, \"Unable to isolate scan target. Place an object on the scan pad.\"")
		return

	scanned_object = target
	if(linked_spectrometer.start_external_scan(target))
		src.visible_message("<b>[name]</b> states, \"Scanning begun.\"")
	else
		// Failed to start — release artifact if we locked it
		release_scanned_object()
		src.visible_message("<b>[name]</b> states, \"Failed to initiate scan.\"")

/obj/machinery/artifact_analyser/proc/halt_scan()
	if(linked_spectrometer)
		linked_spectrometer.halt_external_scan()
	release_scanned_object()
	src.visible_message("<b>[name]</b> states, \"Scanning halted.\"")

// Called by the spectrometer when the external scan reaches 100%
/obj/machinery/artifact_analyser/proc/complete_scan()
	src.visible_message("<b>[name]</b> states, \"Scanning complete.\"")

	var/results = ""
	if(!scanned_object)
		results = "Error: scanned object lost."
	else
		results = get_scan_info(scanned_object)

	// Determine paper type — mission artifacts may use a custom deliverable_paper_type
	var/paper_type = /obj/item/paper/anomaly_scan
	if(scanned_object && istype(scanned_object, /obj/machinery/artifact/mission))
		var/obj/machinery/artifact/mission/MA = scanned_object
		paper_type = MA.deliverable_paper_type || /obj/item/paper/anomaly_scan
	var/obj/item/paper/anomaly_scan/P = new paper_type(src.loc)

	P.SetName("[src] report #[++report_num]")
	P.info = "<b>[src] analysis report #[report_num]</b><br>"
	P.info += "<br>"
	P.info += "\icon[scanned_object] [results]"
	P.stamped = list(/obj/item/stamp)
	P.queue_icon_update()
	P.is_copy = FALSE

	if(scanned_object && istype(scanned_object, /obj/machinery/artifact))
		var/obj/machinery/artifact/A = scanned_object
		P.artifact = A.name
		if(A.my_effect)
			P.my_effect = A.my_effect.name
		if(A.secondary_effect)
			P.secondary_effect = A.secondary_effect.name
		if(istype(A, /obj/machinery/artifact/mission))
			var/obj/machinery/artifact/mission/MA = A
			MA.on_analysis_complete()

	release_scanned_object()
	updateDialog()

// Called by the spectrometer when scan target is lost or emergency stop occurs
/obj/machinery/artifact_analyser/proc/on_scan_lost()
	src.visible_message("<b>[name]</b> states, \"Scan target lost. Scanning aborted.\"")
	release_scanned_object()
	updateDialog()

/obj/machinery/artifact_analyser/proc/release_scanned_object()
	if(!scanned_object)
		return
	if(istype(scanned_object, /obj/machinery/artifact))
		var/obj/machinery/artifact/artifact = scanned_object
		artifact.anchored = FALSE
		artifact.being_used = FALSE
	scanned_object = null

//hardcoded responses, oh well
/obj/machinery/artifact_analyser/proc/get_scan_info(obj/scanned_obj)
	// Check for artifact subtypes first (switch only matches exact type)
	if(istype(scanned_obj, /obj/machinery/artifact))
		var/obj/machinery/artifact/A = scanned_obj
		var/out = "Anomalous alien device - composed of an unknown alloy.<br><br>"
		if(A.my_effect)
			out += A.my_effect.getDescription()
			out += "<br>Estimated effect radius: [A.my_effect.effectrange] tile\s."
		if(A.secondary_effect)
			out += "<br><br>Internal scans indicate ongoing secondary activity operating independently from primary systems.<br><br>"
			out += A.secondary_effect.getDescription()
			out += "<br>Estimated effect radius: [A.secondary_effect.effectrange] tile\s."
		if(A.damage_desc)
			out += "<br><br>[A.damage_desc]"
		return out

	switch(scanned_obj.type)
		if(/obj/machinery/auto_cloner)
			return "Automated cloning pod - appears to rely on an artificial ecosystem formed by semi-organic nanomachines and the contained liquid.<br>The liquid resembles protoplasmic residue supportive of unicellular organism developmental conditions.<br>The structure is composed of a titanium alloy."
		if(/obj/machinery/power/supermatter)
			return "Superdense phoron clump - appears to have been shaped or hewn, structure is composed of matter aproximately 20 times denser than ordinary refined phoron."
		if(/obj/structure/constructshell)
			return "Tribal idol - subject resembles statues/emblems built by superstitious pre-warp civilisations to honour their gods. Material appears to be a rock/plastcrete composite."
		if(/obj/machinery/giga_drill)
			return "Automated mining drill - structure composed of titanium-carbide alloy, with tip and drill lines edged in an alloy of diamond and phoron."
		if(/obj/structure/cult/pylon)
			return "Tribal pylon - subject resembles statues/emblems built by cargo cult civilisations to honour energy systems from post-warp civilisations."
		if(/obj/machinery/replicator)
			return "Automated construction unit - subject appears to be able to synthesize various objects given a material, some with simple internal circuitry. Method unknown."
		else
			return "[scanned_obj.name] - mundane application."
