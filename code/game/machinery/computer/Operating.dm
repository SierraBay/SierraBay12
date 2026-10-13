//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/operating
	name = "patient monitoring console"
	density = TRUE
	anchored = TRUE
	icon_keyboard = "med_key"
	icon_screen = "crew"
	machine_name = "patient monitoring console"
	machine_desc = "Displays a realtime health readout of a patient laid onto an adjacent operating table."
	var/mob/living/carbon/human/victim = null
	var/obj/machinery/optable/table = null

/obj/machinery/computer/operating/New()
	..()
	for(var/D in list(NORTH,EAST,SOUTH,WEST))
		table = locate(/obj/machinery/optable, get_step(src, D))
		if (table)
			table.computer = src
			break

// [SIERRA-EDIT] - CARDIAC_OVERHAUL - Use NanoUI instead of HTML browser
// /obj/machinery/computer/operating/interface_interact(user) // SIERRA-EDIT - ORIGINAL
// 	interact(user) // SIERRA-EDIT - ORIGINAL
// 	return TRUE // SIERRA-EDIT - ORIGINAL
/obj/machinery/computer/operating/interface_interact(user)
	ui_interact(user)
	return TRUE
// [/SIERRA-EDIT]

// [SIERRA-REMOVE] - CARDIAC_OVERHAUL - Removed in favor of NanoUI ui_interact()
/*
/obj/machinery/computer/operating/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (inoperable()) )
		if (!istype(user, /mob/living/silicon))
			user.unset_machine()
			close_browser(user, "window=op")
			return

	user.set_machine(src)
	var/dat = "<HEAD><TITLE>Operating Computer</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<a href='byond://?src=\ref[user];mach_close=op'>Close</A><br><br>" //| <a href='byond://?src=\ref[user];update=1'>Update</A>"
	if(src.table && (src.table.check_victim()))
		src.victim = src.table.victim
		dat += {"
<B>Patient Information:</B><BR>
<BR>
[medical_scan_results(victim, 1)]
"}
	else
		src.victim = null
		dat += {"
<B>Patient Information:</B><BR>
<BR>
<B>No Patient Detected</B>
"}
	show_browser(user, dat, "window=op")
	onclose(user, "op")
*/
// [/SIERRA-REMOVE]

// [SIERRA-ADD] - CARDIAC_OVERHAUL - NanoUI implementation for patient monitoring
/obj/machinery/computer/operating/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/nanoui/master_ui = null, datum/topic_state/state = GLOB.default_state)
	var/list/data = list()

	data["ref"] = "\ref[src]"
	data["beep"] = FALSE
	data["read_alerts"] = FALSE
	data["detailed"] = TRUE
	data["connected_table"] = table ? TRUE : FALSE

	if(table && table.check_victim())
		victim = table.victim
	else
		victim = null

	if(victim)
		data["victim"] = list("name" = victim.name)
		
		var/obj/item/organ/internal/heart/heart = victim.internal_organs_by_name[BP_HEART]
		if(istype(heart))
			if(BP_IS_ROBOTIC(heart))
				if(heart.is_working())
					data["cardiac_rhythm"] = "Continuous Flow"
					data["bpm"] = 0
					data["rhythm_is_safe"] = TRUE
					data["cardiac_status"] = "Steady Whirr"
				else
					data["cardiac_rhythm"] = "Asystole"
					data["bpm"] = 0
					data["rhythm_is_safe"] = FALSE
					data["cardiac_status"] = "Pump Failure"
			else
				data["cardiac_rhythm"] = heart.cardiac_rhythm
				data["bpm"] = victim.get_pulse_as_number()
				data["rhythm_is_safe"] = RHYTHM_HAS_PULSE(heart.cardiac_rhythm)
				data["infarct_progress"] = heart.infarct_progress
				if(heart.cardiac_rhythm == RHYTHM_NSR)
					data["cardiac_status"] = "Normal"
				else
					data["cardiac_status"] = heart.cardiac_rhythm
		else
			data["cardiac_rhythm"] = "Asystole"
			data["bpm"] = 0
			data["rhythm_is_safe"] = FALSE
			data["cardiac_status"] = "No Heartbeat"

		data["blood_pressure"] = victim.get_blood_pressure()
		data["oxygenation"] = victim.get_blood_oxygenation()

		// BP status class
		if(victim.get_blood_volume() <= 70)
			data["bp_status"] = "danger"
		else
			data["bp_status"] = ""

		// Oxy status class
		var/oxy = victim.get_blood_oxygenation()
		if(oxy < BLOOD_VOLUME_SURVIVE)
			data["oxy_status"] = "danger"
		else if(oxy < BLOOD_VOLUME_OKAY)
			data["oxy_status"] = "warning"
		else
			data["oxy_status"] = "normal-pulse"

		data["temperature"] = round(victim.bodytemperature - T0C, 0.1)

		// Breathing
		var/breathing = "none"
		var/breath_status = "danger"
		var/obj/item/organ/internal/lungs/lungs = victim.internal_organs_by_name[BP_LUNGS]
		if (istype(lungs) && !(victim.status_flags & FAKEDEATH))
			if (lungs.breath_fail_ratio < 0.3)
				breathing = "normal"
				breath_status = "normal-pulse"
			else if (lungs.breath_fail_ratio < 1)
				breathing = "shallow"
				breath_status = "warning"
		data["breathing"] = breathing
		data["breath_status"] = breath_status

		// Brain
		var/brain_activity = "none"
		var/brain_status = "danger"
		var/obj/item/organ/internal/brain/brain = victim.internal_organs_by_name[BP_BRAIN]
		if (istype(brain) && !victim.is_dead())
			switch (brain.get_current_damage_threshold())
				if (0)
					brain_activity = "normal"
					brain_status = ""
				if (1 to 2)
					brain_activity = "minor damage"
					brain_status = "warning"
				if (3 to 5)
					brain_activity = "weak"
					brain_status = "danger"
				if (6 to 8)
					brain_activity = "extremely weak"
					brain_status = "danger"
				if (9 to INFINITY)
					brain_activity = "fading"
					brain_status = "danger"
		data["brain_activity"] = brain_activity
		data["brain_status"] = brain_status

		// Injury details for detailed scans (always detailed for operating computer)
		var/list/injuries = list()
		var/has_injuries = FALSE
		for(var/name in victim.organs_by_name)
			var/obj/item/organ/external/organ = victim.organs_by_name[name]
			if (!organ)
				continue
			if (GET_FLAGS(organ.status, ORGAN_BROKEN | ORGAN_ARTERY_CUT))
				has_injuries = TRUE
				var/list/injury = list("limb" = organ.name)
				var/issue = ""
				if (GET_FLAGS(organ.status, ORGAN_BROKEN))
					issue += "Fracture. "
				if (GET_FLAGS(organ.status, ORGAN_ARTERY_CUT))
					issue += "Arterial bleed."
				injury["issue"] = issue
				injuries += list(injury)
		data["injuries"] = injuries
		data["has_injuries"] = has_injuries

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-vitals_monitor.tmpl", "Patient Monitoring Console", 550, 600, state = state)
		ui.set_initial_data(data)
		ui.add_script("vitals_monitor.js")
		ui.open()
		ui.set_auto_update(1)
// [/SIERRA-ADD]

/obj/machinery/computer/operating/Process()
	if(operable())
		updateDialog()
