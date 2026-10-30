/// Odyssey helpers wired into the physical bluespace drive from bluespace_drive.dm.

/obj/machinery/bluespace_drive
	odyssey_jump_delay = ODYSSEY_BSD_JUMP_DELAY


/proc/odyssey_jump_delay_text(obj/machinery/bluespace_drive/D)
	if (!istype(D))
		return "unknown"
	var/seconds = max(1, round(D.odyssey_jump_delay / (1 SECOND)))
	if (seconds >= 60)
		return "[round(seconds / 60, 0.1)] minutes"
	return "[seconds] seconds"


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
	var/bsu_now = round(D.power_from_gas / 1000, 0.1)
	var/bsu_need = round(D.odyssey_min_jump_power / 1000, 0.1)
	var/bsu_ok = D.power_from_gas >= D.odyssey_min_jump_power
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
	else if (!bsu_ok)
		label = "Insufficient field charge"
		block_reason = "Sector transition needs at least [bsu_need] BSU of bluespace field charge (currently [bsu_now] BSU). Feed moderator gas into the energized drive."
	else if (!course_ok)
		label = "No Sector Map course"
		block_reason = "No valid Odyssey corridor is plotted. Select an available sector on the Sector Map tab. The last authorized command selection is used."
	else if (!fuel_full)
		label = "Emergency fuel reserve"
		block_reason = "Fuel is below the nominal [nominal_fuel] mol charge. An Odyssey jump is still possible, but the drive will treat it as an emergency sequence and double post-jump cooldown."
	else
		label = "Ready for Odyssey jump"
		block_reason = null

	var/can_odyssey = state.active && !D.jumping && !D.on_cooldown && D.energized && course_ok && fuel_ok && bsu_ok
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
	if (D.power_from_gas < D.odyssey_min_jump_power)
		if (user)
			to_chat(user, SPAN_WARNING("Одиссея: для перехода в другой сектор нужно минимум [round(D.odyssey_min_jump_power / 1000, 0.1)] BSU (сейчас [round(D.power_from_gas / 1000, 0.1)]). Зарядите привод модератором."))
		return FALSE
	return TRUE


/proc/odyssey_drive_announce_jump(obj/machinery/bluespace_drive/D, emergency)
	if (!istype(D))
		return
	var/dest_name = odyssey_jump_destination_text()
	var/eta = odyssey_jump_delay_text(D)
	if (emergency)
		command_announcement.Announce("EMERGENCY ALERT! Odyssey sector transition jump with insufficient fuel. Destination: [dest_name]. Cancel before final lock if unauthorized. [eta] to space warping.", "EMERGENCY ODYSSEY JUMP")
	else
		command_announcement.Announce("Attention all hands! Odyssey bluespace transition to [dest_name] is charging. Abort is available until final lock. [eta] to space warping.", "Odyssey Jump Sequence Initiated")
	odyssey_post_status_jump_countdown()


/proc/odyssey_drive_announce_abort(obj/machinery/bluespace_drive/D)
	odyssey_clear_status_jump_countdown()
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

	odyssey_drive_jump_climax(D)
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
	odyssey_evaluate_objectives_after_jump()
	odyssey_chronicle_append(
		ODYSSEY_CHRONICLE_KIND_JUMP,
		"Переход: [odyssey_sector_display_name(state.current_sector_id)] → [odyssey_sector_display_name(state.selected_sector_id)]",
		"Odyssey Jump выполнен. Коридор зафиксирован.",
		ODYSSEY_CHRONICLE_VIS_PUBLIC,
		list("from" = state.current_sector_id, "to" = state.selected_sector_id)
	)
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
	data["odyssey_min_bsu"] = round(D.odyssey_min_jump_power / 1000, 0.1)
	data["odyssey_bsu_ok"] = D.power_from_gas >= D.odyssey_min_jump_power
	if (state.active && state.selected_sector_id)
		data["odyssey_dest_label"] = odyssey_jump_destination_text()
	if (D.odyssey_campaign_jump)
		data["has_destination"] = TRUE


/// Cancel pending Odyssey jump atmosphere timers.
/proc/odyssey_drive_clear_jump_fx(obj/machinery/bluespace_drive/D)
	if (!istype(D) || !islist(D.odyssey_fx_timer_ids))
		return
	for (var/timer_id in D.odyssey_fx_timer_ids)
		if (timer_id)
			deltimer(timer_id)
	D.odyssey_fx_timer_ids = null


/proc/odyssey_drive_track_fx_timer(obj/machinery/bluespace_drive/D, timer_id)
	if (!istype(D) || !timer_id)
		return
	LAZYADD(D.odyssey_fx_timer_ids, timer_id)


/// Schedule last-minute brace cues for an Odyssey jump (announcements + local sounds).
/proc/odyssey_drive_schedule_jump_fx(obj/machinery/bluespace_drive/D, active_delay)
	if (!istype(D) || active_delay <= 0)
		return
	odyssey_drive_clear_jump_fx(D)
	D.odyssey_fx_timer_ids = list()

	var/buildup = min(ODYSSEY_JUMP_FX_BUILDUP, active_delay - 1)
	if (buildup < 15 SECONDS)
		return

	var/start_in = active_delay - buildup
	// Wave schedule inside the buildup window (seconds before jump ≈ buildup - offset).
	odyssey_drive_track_fx_timer(D, addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_drive_jump_fx_wave), D, 1), start_in, TIMER_STOPPABLE))
	if (buildup >= 40 SECONDS)
		odyssey_drive_track_fx_timer(D, addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_drive_jump_fx_wave), D, 2), start_in + 20 SECONDS, TIMER_STOPPABLE))
	if (buildup >= 55 SECONDS)
		odyssey_drive_track_fx_timer(D, addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_drive_jump_fx_wave), D, 3), start_in + 40 SECONDS, TIMER_STOPPABLE))
		odyssey_drive_track_fx_timer(D, addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_drive_jump_fx_wave), D, 4), start_in + 50 SECONDS, TIMER_STOPPABLE))


/proc/odyssey_drive_jump_fx_active(obj/machinery/bluespace_drive/D)
	return istype(D) && D.jumping && D.odyssey_campaign_jump && !QDELETED(D)


/proc/odyssey_drive_jump_fx_wave(obj/machinery/bluespace_drive/D, wave)
	if (!odyssey_drive_jump_fx_active(D))
		return
	switch (wave)
		if (1)
			command_announcement.Announce(
				"Bluespace field density is rising. Brace for sector transition.",
				"Odyssey Jump"
			)
			for (var/mob/living/L in GLOB.player_list)
				if (!AreConnectedZLevels(L.z, D.z))
					continue
				if (!istype(get_area(L), /area/hallway))
					continue
				L.playsound_local(L, 'sound/magic/ethereal_enter.ogg', 35)
		if (2)
			for (var/mob/living/L in GLOB.player_list)
				if (!AreConnectedZLevels(L.z, D.z))
					continue
				if (!istype(get_area(L), /area/hallway))
					continue
				L.playsound_local(L, 'sound/machines/BSD_interact.ogg', 40)
		if (3)
			for (var/mob/living/L in GLOB.player_list)
				if (!AreConnectedZLevels(L.z, D.z))
					continue
				L.playsound_local(L, 'sound/magic/ethereal_enter.ogg', 45)
		if (4)
			command_announcement.Announce(
				"Final approach. Abort is about to lock. All hands brace for Odyssey transition.",
				"Odyssey Jump"
			)
			for (var/mob/living/L in GLOB.player_list)
				if (!AreConnectedZLevels(L.z, D.z))
					continue
				L.playsound_local(L, 'sound/magic/ethereal_enter.ogg', 55)


/// Moment-of-jump hit: flash, camera shake, shipwide sound.
/proc/odyssey_drive_jump_climax(obj/machinery/bluespace_drive/D)
	if (!istype(D))
		return
	playsound(D, 'sound/magic/ethereal_exit.ogg', 100, TRUE)
	playsound(D, 'sound/effects/EMPulse.ogg', 60, TRUE)
	for (var/mob/living/L in GLOB.player_list)
		if (!AreConnectedZLevels(L.z, D.z))
			continue
		L.playsound_local(L, 'sound/magic/ethereal_exit.ogg', 80)
		if (!L.client)
			continue
		L.flash_eyes(FLASH_PROTECTION_MAJOR)
		shake_camera(L, 8, 2)
		to_chat(L, SPAN_NOTICE("The hull lurches as bluespace folds around the ship — for a heartbeat the corridors are not quite here."))
