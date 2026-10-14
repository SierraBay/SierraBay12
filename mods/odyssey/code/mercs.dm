/// Odyssey mercenaries (nuke): at most once per campaign, flat chance each shift until used.

/datum/game_mode/create_antagonists()
	odyssey_prepare_station_antags(src)
	odyssey_prepare_changelings(src)
	odyssey_consider_mercenaries(src)
	odyssey_consider_raiders(src)
	odyssey_consider_ninja(src)
	..()


/proc/odyssey_consider_mercenaries(datum/game_mode/mode)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(mode))
		return

	if (state.merc_used)
		additional_antag_types -= MODE_MERCENARY
		if (MODE_MERCENARY in mode.antag_tags)
			log_game("ODYSSEY: merc_used, extra roll skipped; voted mercenary kept on [mode.config_tag]")
		else
			log_game("ODYSSEY: merc_used, extra merc queue skipped for [mode.config_tag]")
		return

	// Keep a successful Odyssey roll across choose_gamemode retries this lobby.
	if (state.merc_shift_decision == ODYSSEY_MERC_DECISION_SPAWN || (MODE_MERCENARY in additional_antag_types))
		additional_antag_types |= MODE_MERCENARY
		state.merc_shift_decision = ODYSSEY_MERC_DECISION_SPAWN
		return

	// One miss/skip per shift — do not re-roll on mode retries.
	if (state.merc_shift_decision)
		return

	// Pure mercenary / mixed mode already carries mercs; do not double-queue.
	if (MODE_MERCENARY in mode.antag_tags)
		log_game("ODYSSEY: merc present in gamemode [mode.config_tag], waiting for spawn confirm")
		return

	var/datum/antagonist/merc = GLOB.all_antag_types_[MODE_MERCENARY]
	if (!istype(merc))
		return

	var/list/potential = merc.get_potential_candidates(mode, TRUE)
	var/candidate_count = length(potential)
	if (candidate_count < ODYSSEY_MERC_MIN_CANDIDATES)
		state.merc_shift_decision = ODYSSEY_MERC_DECISION_SKIP_CANDIDATES
		log_game("ODYSSEY: merc skip candidates=[candidate_count]/[ODYSSEY_MERC_MIN_CANDIDATES]")
		return

	if (!prob(ODYSSEY_MERC_CHANCE))
		state.merc_shift_decision = ODYSSEY_MERC_DECISION_MISS
		log_game("ODYSSEY: merc roll miss chance=[ODYSSEY_MERC_CHANCE] candidates=[candidate_count]")
		return

	state.merc_shift_decision = ODYSSEY_MERC_DECISION_SPAWN
	additional_antag_types |= MODE_MERCENARY
	log_and_message_admins("ODYSSEY: queuing mercenaries this shift (candidates=[candidate_count], chance=[ODYSSEY_MERC_CHANCE]%).")
	log_game("ODYSSEY: merc roll hit candidates=[candidate_count]")


/proc/odyssey_confirm_mercenaries()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || state.merc_used)
		return

	var/datum/antagonist/merc = GLOB.all_antag_types_[MODE_MERCENARY]
	if (!istype(merc))
		return

	var/spawned = merc.get_antag_count()
	if (spawned < 1)
		if (state.merc_shift_decision == ODYSSEY_MERC_DECISION_SPAWN)
			log_game("ODYSSEY: merc queued but none spawned; flag not set")
		return

	var/reason = "spawned"
	if (state.merc_shift_decision == ODYSSEY_MERC_DECISION_SPAWN)
		reason = "odyssey_roll"
	else if (MODE_MERCENARY in SSticker.mode.antag_tags)
		reason = "gamemode"
	else if (MODE_MERCENARY in additional_antag_types)
		reason = "additional_antag"

	odyssey_mark_merc_used(reason, spawned)


/proc/odyssey_mark_merc_used(reason, spawned = 0)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	state.merc_used = TRUE
	state.merc_used_shift = state.shift_number
	state.merc_used_reason = reason
	log_and_message_admins("ODYSSEY: mercenaries locked for campaign (reason=[reason], spawned=[spawned], shift=[state.shift_number]).")
	log_game("ODYSSEY: merc_used reason=[reason] spawned=[spawned] shift=[state.shift_number]")

	var/list/meta = odyssey_load_meta()
	if (!islist(meta))
		meta = odyssey_state_meta(TRUE)
	meta["merc_used"] = TRUE
	meta["merc_used_shift"] = state.merc_used_shift
	meta["merc_used_reason"] = reason
	odyssey_write_meta(meta)


/datum/antagonist/mercenary/finalize_spawn()
	..()
	odyssey_confirm_mercenaries()
