/proc/odyssey_snapshot_path(kind, generation)
	if (generation)
		return "[ODYSSEY_DATA_DIR]_[odyssey_map_key()]_[generation]_[kind].json"
	return "[ODYSSEY_DATA_DIR]_[odyssey_map_key()]_[kind].json"


/proc/odyssey_begin_campaign(continued, announce = TRUE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (continued)
		var/list/meta = odyssey_load_meta()
		if (!islist(meta) || !meta["active"])
			log_error("ODYSSEY: cannot continue without active campaign meta")
			return FALSE
		if (!odyssey_load_runtime_state(meta, TRUE))
			var/final_status = state.status == ODYSSEY_STATUS_ACTIVE ? ODYSSEY_STATUS_ADMIN_ABORTED : state.status
			odyssey_archive_campaign("invalid_or_finished_continuation", final_status)
			log_error("ODYSSEY: continuation rejected and archived")
			return FALSE
	else
		state.active = TRUE
		state.continued = FALSE
		state.status = ODYSSEY_STATUS_ACTIVE
		state.outcome_reason = null
		state.save_version = ODYSSEY_VERSION
		state.meta_path = odyssey_meta_path()
		state.campaign_id = "[odyssey_map_key()]_[time2text(world.realtime, "YYYYMMDDhhmmss")]"
		state.campaign_seed = "[state.campaign_id]:[world.realtime]"
		state.shift_number = 1
		state.min_shifts = ODYSSEY_MIN_SHIFTS
		state.max_shifts = ODYSSEY_MAX_SHIFTS
		state.sector_graph = odyssey_generate_sector_graph(state.campaign_seed)
		state.current_sector_id = ODYSSEY_SECTOR_START
		state.selected_sector_id = null
		state.selected_by = null
		state.transition_committed = FALSE
		state.odyssey_bsd_jump_done = FALSE
		state.shift_end_queued = FALSE
		state.route_history = list(ODYSSEY_SECTOR_START)
		state.roster = list()
		state.sleepers = list()
		state.sleeper_midround_done = FALSE
		state.merc_used = FALSE
		state.merc_used_shift = 0
		state.merc_used_reason = null
		state.merc_shift_decision = null
		state.raider_shift_decision = null
		state.ninja_shift_decision = null
		state.changeling_shift_count = 0
		state.abandoned_shuttles = list()
		state.next_object_id = 1
		state.validation_errors = odyssey_validate_graph(state.sector_graph)
		if (length(state.validation_errors))
			log_error("ODYSSEY: generated invalid graph: [json_encode(state.validation_errors)]")
			state.active = FALSE
			return FALSE
	if (announce)
		to_world(SPAN_NOTICE("<b>Одиссея [continued ? "продолжается" : "начинается"]. Смена [state.shift_number].</b>"))
	log_game("ODYSSEY: begin active=[state.active] continued=[continued] shift=[state.shift_number] id=[state.campaign_id]")
	return TRUE


/proc/odyssey_load_runtime_state(list/meta, advance_transition = FALSE)
	if (!islist(meta))
		return FALSE
	var/datum/odyssey_state/state = odyssey_ensure_state()
	state.active = !!meta["active"]
	state.continued = TRUE
	state.status = meta["status"] || ODYSSEY_STATUS_ACTIVE
	state.outcome_reason = meta["outcome_reason"]
	state.save_version = meta["version"] || ODYSSEY_VERSION
	state.save_generation = meta["generation"]
	state.meta_path = odyssey_meta_path()
	state.campaign_id = meta["campaign_id"]
	state.campaign_seed = meta["campaign_seed"] || state.campaign_id
	state.shift_number = max(1, meta["shift_number"] || 1)
	state.min_shifts = meta["min_shifts"] || ODYSSEY_MIN_SHIFTS
	state.max_shifts = meta["max_shifts"] || ODYSSEY_MAX_SHIFTS
	state.sector_graph = meta["sector_graph"]
	state.current_sector_id = meta["current_sector_id"] || ODYSSEY_SECTOR_START
	state.selected_sector_id = meta["selected_sector_id"]
	state.selected_by = meta["selected_by"]
	state.transition_committed = !!meta["transition_committed"]
	state.odyssey_bsd_jump_done = FALSE
	state.shift_end_queued = FALSE
	var/list/saved_route_history = meta["route_history"]
	state.route_history = islist(saved_route_history) ? saved_route_history.Copy() : list(state.current_sector_id)
	state.roster = odyssey_load_roster()
	var/list/saved_sleepers = meta["sleepers"]
	state.sleepers = islist(saved_sleepers) ? saved_sleepers.Copy() : list()
	state.sleeper_midround_done = FALSE
	state.merc_used = !!meta["merc_used"]
	state.merc_used_shift = meta["merc_used_shift"] || 0
	state.merc_used_reason = meta["merc_used_reason"]
	state.merc_shift_decision = null
	state.raider_shift_decision = null
	state.ninja_shift_decision = null
	state.changeling_shift_count = 0
	var/list/saved_abandoned = meta["abandoned_shuttles"]
	state.abandoned_shuttles = islist(saved_abandoned) ? saved_abandoned.Copy() : list()
	state.next_object_id = max(1, meta["next_object_id"] || 1)
	state.validation_errors = odyssey_validate_graph(state.sector_graph)
	if (length(state.validation_errors))
		state.active = FALSE
		return FALSE

	if (advance_transition && state.transition_committed)
		if (state.selected_sector_id == ODYSSEY_SECTOR_RETURN)
			state.active = FALSE
			state.status = ODYSSEY_STATUS_RETURNED
			return FALSE
		if (state.selected_sector_id == ODYSSEY_SECTOR_COMPLETE)
			state.active = FALSE
			state.status = ODYSSEY_STATUS_COMPLETED
			return FALSE
		if (!odyssey_sector_is_available(state.selected_sector_id, state))
			state.validation_errors += "committed destination is not linked to current sector"
			state.active = FALSE
			return FALSE
		state.current_sector_id = state.selected_sector_id
		state.shift_number++
		state.route_history += state.current_sector_id
		state.selected_sector_id = null
		state.selected_by = null
		state.transition_committed = FALSE
		state.odyssey_bsd_jump_done = FALSE
	return state.active


/proc/odyssey_state_meta(active_override, generation)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/is_active = isnull(active_override) ? state.active : !!active_override
	if (isnull(generation))
		generation = state.save_generation
	return list(
		"version" = ODYSSEY_VERSION,
		"active" = is_active,
		"status" = state.status,
		"outcome_reason" = state.outcome_reason,
		"campaign_id" = state.campaign_id,
		"campaign_seed" = state.campaign_seed,
		"shift_number" = state.shift_number,
		"min_shifts" = state.min_shifts,
		"max_shifts" = state.max_shifts,
		"map" = odyssey_map_key(),
		"saved_at" = time2text(world.realtime, "YYYY-MM-DD hh:mm"),
		"generation" = generation,
		"sector_graph" = state.sector_graph,
		"current_sector_id" = state.current_sector_id,
		"selected_sector_id" = state.selected_sector_id,
		"selected_by" = state.selected_by,
		"transition_committed" = state.transition_committed,
		"route_history" = state.route_history,
		"next_object_id" = state.next_object_id,
		"sleepers" = state.sleepers,
		"merc_used" = state.merc_used,
		"merc_used_shift" = state.merc_used_shift,
		"merc_used_reason" = state.merc_used_reason,
		"abandoned_shuttles" = state.abandoned_shuttles,
		"parts" = list("turfs", "machinery", "structures", "mechs", "economy", "roster", "newscast")
	)


/proc/odyssey_commit_transition()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || state.status != ODYSSEY_STATUS_ACTIVE)
		return FALSE
	if (!state.selected_sector_id || !odyssey_sector_is_available(state.selected_sector_id, state))
		return FALSE
	state.transition_committed = TRUE
	log_game("ODYSSEY: transition committed from=[state.current_sector_id] to=[state.selected_sector_id]")
	return TRUE


/proc/odyssey_can_prepare_jump(mob/user)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || state.status != ODYSSEY_STATUS_ACTIVE)
		return TRUE
	if (state.selected_sector_id && odyssey_sector_is_available(state.selected_sector_id, state))
		return TRUE
	if (user)
		to_chat(user, SPAN_WARNING("Одиссея: сначала выберите следующий сектор на навигационном компьютере."))
	return FALSE


/// Classic Comm bluespace jump is disabled during Odyssey — transitions go through the physical drive.
/proc/odyssey_blocks_classic_bluespace_jump(mob/user)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return FALSE
	if (user)
		to_chat(user, SPAN_WARNING("Одиссея: переход выполняется через Bluespace Drive (консоль привода или Command), не через эвакуационный протокол."))
	return TRUE


/proc/odyssey_transition_ready_to_end()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	return state.active && state.transition_committed && state.odyssey_bsd_jump_done


/// Transfer vote / autotransfer: schedule shift end in place instead of a classic bluespace jump.
/proc/odyssey_try_end_shift()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || state.status != ODYSSEY_STATUS_ACTIVE)
		return FALSE
	if (SSticker.forced_end)
		return TRUE
	if (state.shift_end_queued)
		return TRUE
	state.shift_end_queued = TRUE
	var/minutes = ODYSSEY_SHIFT_END_DELAY / (1 MINUTE)
	priority_announcement.Announce("Shift rotation has been scheduled. The vessel remains in the current operating sector. Crew changeover in [minutes] minutes.")
	addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_finish_shift_end)), ODYSSEY_SHIFT_END_DELAY)
	log_and_message_admins("ODYSSEY: shift end scheduled in [minutes] minutes (shift [state.shift_number], sector [state.current_sector_id]).")
	log_game("ODYSSEY: shift-end scheduled delay=[ODYSSEY_SHIFT_END_DELAY] shift=[state.shift_number] sector=[state.current_sector_id]")
	return TRUE


/proc/odyssey_finish_shift_end()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || state.status != ODYSSEY_STATUS_ACTIVE)
		return
	if (SSticker.forced_end)
		return
	priority_announcement.Announce("Shift rotation is beginning. Stand by for crew changeover.")
	SSticker.forced_end = TRUE
	log_game("ODYSSEY: shift-end forced_end shift=[state.shift_number] sector=[state.current_sector_id]")


/proc/odyssey_validate_save()
	var/list/errors = list()
	var/list/meta = odyssey_load_meta()
	if (!islist(meta))
		errors += "campaign.json отсутствует или несовместим"
		return errors
	errors += odyssey_validate_graph(meta["sector_graph"])
	var/expected_generation = meta["generation"]
	var/expected_campaign = meta["campaign_id"]
	for (var/kind in list("turfs", "machinery", "mechs", "economy"))
		var/list/data = odyssey_read_json(odyssey_snapshot_path(kind, expected_generation))
		if (!islist(data))
			errors += "[kind].json отсутствует или повреждён"
			continue
		var/version = data["version"] || 1
		if (version < 1 || version > ODYSSEY_VERSION)
			errors += "[kind].json имеет неподдерживаемую версию [version]"
		if (expected_generation && data["generation"] != expected_generation)
			errors += "[kind].json относится к другой генерации"
		if (data["campaign_id"] && data["campaign_id"] != expected_campaign)
			errors += "[kind].json относится к другой кампании"
	for (var/optional_kind in list("structures", "roster"))
		var/path = odyssey_snapshot_path(optional_kind, expected_generation)
		if (!fexists(path))
			if (expected_generation)
				errors += "[optional_kind].json отсутствует"
			continue
		var/list/optional_data = odyssey_read_json(path)
		if (!islist(optional_data))
			errors += "[optional_kind].json повреждён"
		else if (expected_generation && optional_data["generation"] != expected_generation)
			errors += "[optional_kind].json относится к другой генерации"
	var/newscast_path = odyssey_snapshot_path("newscast", expected_generation)
	if (fexists(newscast_path))
		var/list/newscast_data = odyssey_read_json(newscast_path)
		if (!islist(newscast_data))
			errors += "newscast.json повреждён"
		else if (expected_generation && newscast_data["generation"] != expected_generation)
			errors += "newscast.json относится к другой генерации"
	return errors


/proc/odyssey_finish_campaign(status, reason)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	state.status = status
	state.outcome_reason = reason
	state.active = FALSE
	var/list/meta = odyssey_state_meta(FALSE)
	meta["archived_at"] = time2text(world.realtime, "YYYY-MM-DD hh:mm")
	meta["archive_reason"] = reason
	odyssey_write_meta(meta)
	log_game("ODYSSEY: campaign finished status=[status] reason=[reason]")
	return TRUE


/proc/odyssey_roundend_outcome()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return null
	if (SSticker?.mode?.station_was_nuked)
		return list("status" = ODYSSEY_STATUS_SHIP_DESTROYED, "reason" = "station_was_nuked")
	if (evacuation_controller?.emergency_evacuation && evacuation_controller.round_over())
		return list("status" = ODYSSEY_STATUS_EVACUATED, "reason" = "emergency_abandon_ship")
	if (state.transition_committed && state.selected_sector_id == ODYSSEY_SECTOR_RETURN)
		return list("status" = ODYSSEY_STATUS_RETURNED, "reason" = "command_returned_home")
	if (state.transition_committed && state.selected_sector_id == ODYSSEY_SECTOR_COMPLETE)
		return list("status" = ODYSSEY_STATUS_COMPLETED, "reason" = "final_sector_completed")
	var/list/current = odyssey_get_sector(state.current_sector_id, state)
	if (current?["terminal"])
		return list("status" = ODYSSEY_STATUS_COMPLETED, "reason" = "final_sector_completed")
	if (odyssey_campaign_crew_lost())
		return list("status" = ODYSSEY_STATUS_CREW_LOST, "reason" = "no_living_campaign_crew")
	return null


/proc/odyssey_save_round(force = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active && !force)
		return FALSE
	if (force && !state.campaign_id)
		odyssey_begin_campaign(FALSE)
	if (force && state.shift_number < 1)
		state.shift_number = 1
	if (force)
		state.active = TRUE
		state.save_version = ODYSSEY_VERSION
		state.meta_path = odyssey_meta_path()

	odyssey_sync_sleepers_for_save()
	odyssey_sync_roster_for_save()
	odyssey_collect_abandoned_shuttles()
	odyssey_ensure_data_dir()
	var/generation = "[state.campaign_id]-[world.realtime]-[world.time]"
	var/list/turfs = odyssey_collect_turfs()
	var/list/machinery = odyssey_collect_machinery()
	var/list/structures = odyssey_collect_structures()
	var/list/mechs = odyssey_collect_mechs()
	var/list/economy = odyssey_collect_economy()
	var/list/newscast = odyssey_collect_newscast(generation)
	var/list/common = list("version" = ODYSSEY_VERSION, "campaign_id" = state.campaign_id, "generation" = generation)
	var/success = TRUE
	success = odyssey_write_json(odyssey_snapshot_path("turfs", generation), common + list("entries" = turfs)) && success
	success = odyssey_write_json(odyssey_snapshot_path("machinery", generation), common + list("entries" = machinery)) && success
	success = odyssey_write_json(odyssey_snapshot_path("structures", generation), common + list("entries" = structures)) && success
	success = odyssey_write_json(odyssey_snapshot_path("mechs", generation), common + list("entries" = mechs)) && success
	success = odyssey_write_json(odyssey_snapshot_path("economy", generation), common + list("data" = economy)) && success
	success = odyssey_write_json(odyssey_snapshot_path("roster", generation), common + list("entries" = state.roster)) && success
	success = odyssey_write_json(odyssey_snapshot_path("newscast", generation), common + list("data" = newscast)) && success
	if (!success)
		log_error("ODYSSEY: snapshot write failed; campaign meta was not published")
		return FALSE

	// Transfer/shift-end stays in the current sector and does not consume a graph hop.
	// Odyssey Jump still increments shift_number on continue via transition_committed.
	if (!force && !state.transition_committed && !odyssey_roundend_outcome())
		state.shift_number++
		log_game("ODYSSEY: same-sector crew shift=[state.shift_number] echelon=[odyssey_campaign_echelon(state)] sector=[state.current_sector_id]")

	var/list/meta = odyssey_state_meta(null, generation)
	if (!odyssey_write_meta(meta))
		log_error("ODYSSEY: meta write failed after snapshot generation [generation]")
		return FALSE
	state.save_generation = generation
	log_game("ODYSSEY: saved campaign=[state.campaign_id] shift=[state.shift_number] turfs=[length(turfs)] machinery=[length(machinery)] mechs=[length(mechs)] force=[force]")
	to_world(SPAN_NOTICE("<b>Состояние Одиссеи сохранено (смена [state.shift_number]).</b>"))
	return TRUE


/proc/odyssey_apply_save(force = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if ((!state.active || !state.continued) && !force)
		return FALSE

	state.validation_errors = odyssey_validate_save()
	if (length(state.validation_errors))
		log_error("ODYSSEY: save validation failed: [json_encode(state.validation_errors)]")
		return FALSE

	odyssey_apply_abandoned_shuttles()
	var/list/turfs = odyssey_read_json(odyssey_snapshot_path("turfs", state.save_generation))
	var/list/machinery = odyssey_read_json(odyssey_snapshot_path("machinery", state.save_generation))
	var/list/structures = odyssey_read_json(odyssey_snapshot_path("structures", state.save_generation))
	var/list/mechs = odyssey_read_json(odyssey_snapshot_path("mechs", state.save_generation))
	var/list/economy = odyssey_read_json(odyssey_snapshot_path("economy", state.save_generation))
	var/list/newscast = odyssey_read_json(odyssey_snapshot_path("newscast", state.save_generation))

	odyssey_apply_turfs(turfs?["entries"])
	odyssey_apply_machinery(machinery?["entries"])
	odyssey_apply_structures(structures?["entries"])
	odyssey_apply_mechs(mechs?["entries"])
	odyssey_apply_economy(economy?["data"])
	odyssey_apply_newscast(newscast?["data"], state.save_generation)

	log_game("ODYSSEY: applied save campaign=[state.campaign_id] shift=[state.shift_number] force=[force]")
	return TRUE


/// Called from SSticker pregame. Starts start/continue vote once per lobby.
/proc/odyssey_pregame_consider_vote()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.pregame_vote_done)
		return
	if (GAME_STATE >= RUNLEVEL_SETUP)
		return
	if (SSvote?.active_vote)
		return

	var/list/lobby = SSticker?.lobby_players()
	var/players = length(lobby)
	if (players < ODYSSEY_MIN_YES_VOTES)
		return

	var/has_campaign = odyssey_campaign_exists()
	var/started = FALSE
	if (has_campaign)
		started = SSvote.initiate_vote(/datum/vote/odyssey_continue, automatic = 1)
	else
		started = SSvote.initiate_vote(/datum/vote/odyssey_start, automatic = 1)
	if (started)
		state.pregame_vote_done = TRUE
