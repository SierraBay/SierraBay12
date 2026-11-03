/// Odyssey mercenaries (nuke): at most once per campaign, flat chance each shift until used.
/// While Odyssey is active, vanilla gamemode antag_tags are ignored — only campaign rules apply.

/datum/game_mode/create_antagonists()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return ..()

	if (!config.traitor_scaling)
		antag_scaling_coeff = 0

	// Shared mode_cache datums must not be mutated; ignore antag_tags / latejoin entirely.
	round_autoantag = FALSE
	odyssey_sanitize_additional_antags()
	odyssey_prepare_changelings(src)
	odyssey_prepare_revolution(src)
	odyssey_consider_mercenaries(src)
	odyssey_consider_raiders(src)
	odyssey_consider_ninja(src)

	antag_templates = list()
	var/list/all_antag_types = GLOB.all_antag_types_
	for (var/antag_type in additional_antag_types)
		var/datum/antagonist/antag = all_antag_types[antag_type]
		if (antag)
			antag_templates |= antag
	shuffle(antag_templates)
	log_game("ODYSSEY: campaign antag templates=[length(antag_templates)] additional=[english_list(additional_antag_types)] mode=[config_tag]")


/datum/game_mode/announce()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return ..()
	to_chat(world, SPAN_NOTICE("<B>Текущий режим: Одиссея.</B>"))
	to_chat(world, SPAN_NOTICE("Антагонисты задаются правилами кампании (предатели, генокрады, наёмники, пираты, ниндзя), а не голосованием за игровой режим."))


/// Drop anything that is not an Odyssey-owned additional antag id.
/proc/odyssey_sanitize_additional_antags()
	var/list/allowed = list(MODE_CHANGELING, MODE_MERCENARY, MODE_RAIDER, MODE_NINJA)
	for (var/antag_id in additional_antag_types.Copy())
		if (!(antag_id in allowed))
			additional_antag_types -= antag_id


/// Mercenaries queued by Odyssey this shift.
/proc/odyssey_merc_conflict_active(datum/game_mode/mode)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.merc_shift_decision == ODYSSEY_MERC_DECISION_SPAWN)
		return TRUE
	if (MODE_MERCENARY in additional_antag_types)
		return TRUE
	return FALSE


/// Raiders/ninja queued by Odyssey this shift.
/proc/odyssey_outsider_conflict_active(datum/game_mode/mode)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.raider_shift_decision == ODYSSEY_OUTSIDER_DECISION_SPAWN)
		return TRUE
	if (state.ninja_shift_decision == ODYSSEY_OUTSIDER_DECISION_SPAWN)
		return TRUE
	if (MODE_RAIDER in additional_antag_types)
		return TRUE
	if (MODE_NINJA in additional_antag_types)
		return TRUE
	return FALSE


/// Shift 1 → 0%, each later shift +ODYSSEY_MERC_CHANCE_STEP, capped at ODYSSEY_MERC_CHANCE_MAX.
/proc/odyssey_merc_chance_for_shift(shift_number)
	if (!isnum(shift_number) || shift_number < 1)
		shift_number = 1
	return clamp((shift_number - 1) * ODYSSEY_MERC_CHANCE_STEP, 0, ODYSSEY_MERC_CHANCE_MAX)


/proc/odyssey_consider_mercenaries(datum/game_mode/mode)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(mode))
		return

	if (state.merc_used)
		additional_antag_types -= MODE_MERCENARY
		log_game("ODYSSEY: merc_used, extra merc queue skipped for [mode.config_tag]")
		return

	// Keep a successful Odyssey roll across choose_gamemode retries this lobby.
	if (state.merc_shift_decision == ODYSSEY_MERC_DECISION_SPAWN || (MODE_MERCENARY in additional_antag_types))
		if (odyssey_outsider_conflict_active(mode))
			additional_antag_types -= MODE_MERCENARY
			state.merc_shift_decision = ODYSSEY_MERC_DECISION_BLOCKED_OUTSIDER
			log_game("ODYSSEY: merc queue dropped — raiders/ninja conflict on [mode.config_tag]")
			return
		additional_antag_types |= MODE_MERCENARY
		additional_antag_types -= MODE_RAIDER
		additional_antag_types -= MODE_NINJA
		state.merc_shift_decision = ODYSSEY_MERC_DECISION_SPAWN
		return

	// One miss/skip/block per shift — do not re-roll on mode retries.
	if (state.merc_shift_decision)
		return

	if (odyssey_outsider_conflict_active(mode))
		state.merc_shift_decision = ODYSSEY_MERC_DECISION_BLOCKED_OUTSIDER
		additional_antag_types -= MODE_MERCENARY
		log_game("ODYSSEY: merc skip — raiders/ninja conflict on [mode.config_tag]")
		return

	var/chance = odyssey_merc_chance_for_shift(state.shift_number)
	if (chance <= 0)
		state.merc_shift_decision = ODYSSEY_MERC_DECISION_MISS
		log_game("ODYSSEY: merc skip shift=[state.shift_number] chance=0 (first shift)")
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

	if (!prob(chance))
		state.merc_shift_decision = ODYSSEY_MERC_DECISION_MISS
		log_game("ODYSSEY: merc roll miss shift=[state.shift_number] chance=[chance] candidates=[candidate_count]")
		return

	state.merc_shift_decision = ODYSSEY_MERC_DECISION_SPAWN
	additional_antag_types |= MODE_MERCENARY
	additional_antag_types -= MODE_RAIDER
	additional_antag_types -= MODE_NINJA
	log_and_message_admins("ODYSSEY: queuing mercenaries this shift (shift=[state.shift_number], candidates=[candidate_count], chance=[chance]%).")
	log_game("ODYSSEY: merc roll hit shift=[state.shift_number] chance=[chance] candidates=[candidate_count]")


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
	odyssey_chronicle_append(
		ODYSSEY_CHRONICLE_KIND_MERC,
		"Контакт с наёмниками",
		"Зафиксирована высадка враждебного отряда (причина учёта: [reason], состав: [spawned]).",
		ODYSSEY_CHRONICLE_VIS_PUBLIC,
		list("reason" = reason, "spawned" = spawned)
	)
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
