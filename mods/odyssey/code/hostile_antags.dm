/// Odyssey hostile-sector outsiders: raiders (pirates) and ninja, independent rolls per red sector visit.

/proc/odyssey_current_sector_danger()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/sector = odyssey_get_sector(state.current_sector_id, state)
	if (!islist(sector))
		return ODYSSEY_DANGER_SAFE
	return sector["danger"] || ODYSSEY_DANGER_SAFE


/// Shared queue helper for OVERRIDE_JOB outsiders on the current hostile sector.
/proc/odyssey_consider_outsider_antag(datum/game_mode/mode, antag_id, chance, min_candidates, decision_var)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(mode) || !antag_id || !decision_var)
		return

	var/current_decision = state.vars[decision_var]

	// Keep a successful roll across choose_gamemode retries this lobby.
	if (current_decision == ODYSSEY_OUTSIDER_DECISION_SPAWN || (antag_id in additional_antag_types))
		additional_antag_types |= antag_id
		state.vars[decision_var] = ODYSSEY_OUTSIDER_DECISION_SPAWN
		return

	if (current_decision)
		return

	if (odyssey_current_sector_danger() != ODYSSEY_DANGER_HOSTILE)
		state.vars[decision_var] = ODYSSEY_OUTSIDER_DECISION_WRONG_SECTOR
		return

	if (antag_id in mode.antag_tags)
		log_game("ODYSSEY: [antag_id] present in gamemode [mode.config_tag], waiting for spawn")
		return

	var/datum/antagonist/antag = GLOB.all_antag_types_[antag_id]
	if (!istype(antag))
		return

	var/list/potential = antag.get_potential_candidates(mode, TRUE)
	var/candidate_count = length(potential)
	if (candidate_count < min_candidates)
		state.vars[decision_var] = ODYSSEY_OUTSIDER_DECISION_SKIP_CANDIDATES
		log_game("ODYSSEY: [antag_id] skip candidates=[candidate_count]/[min_candidates]")
		return

	if (!prob(chance))
		state.vars[decision_var] = ODYSSEY_OUTSIDER_DECISION_MISS
		log_game("ODYSSEY: [antag_id] roll miss chance=[chance] candidates=[candidate_count]")
		return

	state.vars[decision_var] = ODYSSEY_OUTSIDER_DECISION_SPAWN
	additional_antag_types |= antag_id
	log_and_message_admins("ODYSSEY: queuing [antag.role_text_plural] this hostile sector (candidates=[candidate_count], chance=[chance]%).")
	log_game("ODYSSEY: [antag_id] roll hit candidates=[candidate_count] sector=[state.current_sector_id]")


/proc/odyssey_consider_raiders(datum/game_mode/mode)
	odyssey_consider_outsider_antag(mode, MODE_RAIDER, ODYSSEY_RAIDER_CHANCE, ODYSSEY_RAIDER_MIN_CANDIDATES, "raider_shift_decision")


/proc/odyssey_consider_ninja(datum/game_mode/mode)
	odyssey_consider_outsider_antag(mode, MODE_NINJA, ODYSSEY_NINJA_CHANCE, ODYSSEY_NINJA_MIN_CANDIDATES, "ninja_shift_decision")


/proc/odyssey_log_outsider_spawn(antag_id, decision_var)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	var/datum/antagonist/antag = GLOB.all_antag_types_[antag_id]
	if (!istype(antag))
		return
	var/spawned = antag.get_antag_count()
	if (spawned < 1)
		if (state.vars[decision_var] == ODYSSEY_OUTSIDER_DECISION_SPAWN)
			log_game("ODYSSEY: [antag_id] queued but none spawned")
		return
	log_and_message_admins("ODYSSEY: [antag.role_text_plural] spawned ([spawned]) on hostile sector [state.current_sector_id].")
	log_game("ODYSSEY: [antag_id] spawned=[spawned] sector=[state.current_sector_id] decision=[state.vars[decision_var]]")


/proc/odyssey_confirm_hostile_outsiders()
	odyssey_log_outsider_spawn(MODE_RAIDER, "raider_shift_decision")
	odyssey_log_outsider_spawn(MODE_NINJA, "ninja_shift_decision")


/datum/antagonist/raider/finalize_spawn()
	..()
	odyssey_log_outsider_spawn(MODE_RAIDER, "raider_shift_decision")


/datum/antagonist/ninja/finalize_spawn()
	..()
	odyssey_log_outsider_spawn(MODE_NINJA, "ninja_shift_decision")
