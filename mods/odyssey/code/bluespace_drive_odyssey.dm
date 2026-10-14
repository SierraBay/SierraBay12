/// Odyssey helpers wired into the physical bluespace drive from bluespace_drive.dm.


/proc/odyssey_find_ship_bluespace_drive()
	var/list/drives = SSmachines.get_machinery_of_type(/obj/machinery/bluespace_drive)
	for (var/obj/machinery/bluespace_drive/D as anything in drives)
		if (QDELETED(D))
			continue
		if (D.linked)
			return D
	for (var/obj/machinery/bluespace_drive/D as anything in drives)
		if (!QDELETED(D) && isStationLevel(D.z))
			return D
	return null


/proc/odyssey_bluespace_drive_status()
	var/obj/machinery/bluespace_drive/D = odyssey_find_ship_bluespace_drive()
	if (!istype(D))
		return list(
			"present" = FALSE,
			"label" = "Drive not detected",
			"block_reason" = "No shipboard Bluespace Drive is linked. Check engineering and the drive console.",
			"energized" = FALSE,
			"energized_label" = "—",
			"fuel_label" = "—",
			"fuel_ok" = FALSE,
			"course_ok" = FALSE,
			"course_label" = "—",
			"cooldown_label" = "Ready",
			"on_cooldown" = FALSE,
			"jumping" = FALSE,
			"jump_locked" = FALSE,
			"odyssey_jump" = FALSE,
			"can_odyssey_jump" = FALSE,
			"can_abort" = FALSE
		)

	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/fuel_moles = D.fuel_gas ? D.fuel_gas.total_moles : 0
	var/fuel_ok = fuel_moles >= D.emergency_jump_min_moles
	var/fuel_full = fuel_moles >= D.minimum_phoron_moles_per_jump
	var/course_ok = !!(state.selected_sector_id && odyssey_sector_is_available(state.selected_sector_id, state))
	var/nominal_fuel = D.minimum_phoron_moles_per_jump
	var/emergency_fuel = D.emergency_jump_min_moles

	var/fuel_label
	if (fuel_full)
		fuel_label = "[round(fuel_moles, 0.1)] mol phoron (nominal, ≥ [nominal_fuel] mol)"
	else if (fuel_ok)
		fuel_label = "[round(fuel_moles, 0.1)] mol phoron (emergency reserve, ≥ [emergency_fuel] mol)"
	else
		fuel_label = "[round(fuel_moles, 0.1)] / [emergency_fuel] mol phoron — below emergency threshold"

	var/course_label
	if (course_ok)
		course_label = odyssey_sector_display_name(state.selected_sector_id)
	else if (state.selected_sector_id)
		course_label = "[odyssey_sector_display_name(state.selected_sector_id)] — corridor unavailable"
	else
		course_label = "None plotted (open Sector Map)"

	var/cooldown_seconds = D.on_cooldown ? max(0, round((D.cooldown_end_time - world.time) / 10)) : 0
	var/cooldown_label = D.on_cooldown ? "[cooldown_seconds]s remaining" : "Ready"
	var/energized_label = D.energized ? "Energized" : "Standby"

	var/label = "Ready"
	var/block_reason = null
	if (D.jumping)
		if (D.odyssey_campaign_jump)
			label = "Odyssey jump sequence in progress"
		else
			label = "Overmap jump sequence in progress"
		if (D.jump_locked)
			label += " — abort locked"
			block_reason = "The drive is in final approach. Abort is disabled; the corridor cannot be cancelled from this console."
		else
			block_reason = "A jump sequence is already charging. Abort remains available until final lock."
	else if (D.on_cooldown)
		label = "Cooling down"
		block_reason = "The drive is thermally locked after the previous jump. Wait [cooldown_label] before initiating another sequence."
	else if (!D.energized)
		label = "Standby"
		block_reason = "The drive is not energized. Energize it from the Bluespace Drive console in engineering before a jump can be armed."
	else if (!fuel_ok)
		label = "Insufficient fuel"
		block_reason = "Phoron fuel is below the emergency minimum of [emergency_fuel] mol (currently [round(fuel_moles, 0.1)] mol). Charge the drive tank before attempting a jump."
	else if (!course_ok)
		label = "No Sector Map course"
		block_reason = "No valid Odyssey corridor is plotted. Select an available sector on the Sector Map tab. The last authorized command selection is used."
	else if (!fuel_full)
		label = "Emergency fuel reserve"
		block_reason = "Fuel is below the nominal [nominal_fuel] mol charge. An Odyssey jump is still possible, but the drive will treat it as an emergency sequence and double post-jump cooldown."
	else
		label = "Ready for Odyssey jump"
		block_reason = null

	var/can_odyssey = state.active && !D.jumping && !D.on_cooldown && D.energized && course_ok && fuel_ok
	return list(
		"present" = TRUE,
		"label" = label,
		"block_reason" = block_reason,
		"energized" = D.energized,
		"energized_label" = energized_label,
		"fuel_label" = fuel_label,
		"fuel_ok" = fuel_ok,
		"fuel_full" = fuel_full,
		"course_ok" = course_ok,
		"course_label" = course_label,
		"cooldown_label" = cooldown_label,
		"on_cooldown" = D.on_cooldown,
		"jumping" = D.jumping,
		"jump_locked" = D.jump_locked,
		"odyssey_jump" = D.odyssey_campaign_jump,
		"can_odyssey_jump" = can_odyssey,
		"can_abort" = D.jumping && !D.jump_locked
	)


/proc/odyssey_drive_can_campaign_jump(obj/machinery/bluespace_drive/D, mob/user)
	if (!istype(D))
		return FALSE
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || state.status != ODYSSEY_STATUS_ACTIVE)
		if (user)
			to_chat(user, SPAN_WARNING("Одиссея не активна."))
		return FALSE
	if (!state.selected_sector_id || !odyssey_sector_is_available(state.selected_sector_id, state))
		if (user)
			to_chat(user, SPAN_WARNING("Одиссея: сначала выберите следующий сектор на Sector Map."))
		return FALSE
	return TRUE


/proc/odyssey_drive_announce_jump(obj/machinery/bluespace_drive/D, emergency)
	if (!istype(D))
		return
	var/dest_name = odyssey_jump_destination_text()
	if (emergency)
		command_announcement.Announce("EMERGENCY ALERT! Odyssey sector transition jump with insufficient fuel. Destination: [dest_name]. Cancel before final lock if unauthorized. [D.jump_delay / 10] seconds to space warping.", "EMERGENCY ODYSSEY JUMP")
	else
		command_announcement.Announce("Attention all hands! Odyssey bluespace transition to [dest_name] is charging. Abort is available until final lock. [D.jump_delay / 10] seconds to space warping.", "Odyssey Jump Sequence Initiated")


/proc/odyssey_drive_announce_abort(obj/machinery/bluespace_drive/D)
	command_announcement.Announce("Odyssey jump sequence aborted. Plotted course remains on the Sector Map.", "Odyssey Jump Aborted")


/proc/odyssey_drive_execute_campaign_jump(obj/machinery/bluespace_drive/D)
	if (!istype(D))
		return FALSE
	if (!odyssey_drive_can_campaign_jump(D, null))
		D.visible_message(SPAN_DANGER("\The [D] fails to lock the Odyssey corridor!"))
		command_announcement.Announce("Odyssey jump failed: no valid Sector Map course.", "Bluespace Drive Fault")
		return FALSE

	if (!odyssey_commit_transition())
		D.visible_message(SPAN_DANGER("\The [D] fails to lock the Odyssey corridor!"))
		command_announcement.Announce("Odyssey jump failed: navigation corridor could not be committed.", "Bluespace Drive Fault")
		return FALSE

	for (var/mob/living/L in GLOB.player_list)
		if (!AreConnectedZLevels(L.z, D.z))
			continue
		if (istype(get_area(L), /area/space))
			to_chat(L, SPAN_DANGER("Space completely warps around you, turning your body into something that a mind can barely comprehend..."))
			L.death()

	D.open_rift()

	var/datum/odyssey_state/state = odyssey_ensure_state()
	log_and_message_admins("Odyssey BSD jump committed to [state.selected_sector_id]")
	odyssey_on_bsd_jump_complete()
	return TRUE


/proc/odyssey_on_bsd_jump_complete()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	state.odyssey_bsd_jump_done = TRUE
	priority_announcement.Announce("Odyssey bluespace corridor locked. Ship systems entering transition shutdown — prepare for shift change.", "Odyssey Transition", new_sound = GLOB.using_map.shuttle_leaving_dock_sound)
	log_game("ODYSSEY: BSD jump complete, round end armed for sector=[state.selected_sector_id]")


/obj/machinery/bluespace_drive/proc/initiate_odyssey_jump(mob/user = null)
	return initiate_jump(user, TRUE)


/proc/odyssey_drive_append_ui(obj/machinery/bluespace_drive/D, list/data)
	if (!istype(D) || !islist(data))
		return
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/fuel_moles = D.fuel_gas ? D.fuel_gas.total_moles : 0
	data["odyssey_active"] = state.active
	data["odyssey_jump"] = D.odyssey_campaign_jump
	data["odyssey_course"] = state.selected_sector_id ? odyssey_sector_display_name(state.selected_sector_id) : null
	data["odyssey_can_jump"] = state.active && odyssey_drive_can_campaign_jump(D, null) && D.energized && !D.jumping && !D.on_cooldown && (fuel_moles >= D.emergency_jump_min_moles)
	if (state.active && state.selected_sector_id)
		data["odyssey_dest_label"] = odyssey_jump_destination_text()
	if (D.odyssey_campaign_jump)
		data["has_destination"] = TRUE
