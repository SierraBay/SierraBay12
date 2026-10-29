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
		odyssey_last_campaign_stats = null
		odyssey_show_roundend_stats = FALSE
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
		state.changelings = list()
		state.sleeper_midround_done = FALSE
		state.merc_used = FALSE
		state.merc_used_shift = 0
		state.merc_used_reason = null
		state.merc_shift_decision = null
		state.raider_shift_decision = null
		state.ninja_shift_decision = null
		state.changeling_shift_count = 0
		state.abandoned_shuttles = list()
		state.shuttle_reports = list()
		state.chronicle = list()
		state.next_chronicle_id = 1
		state.chronicle_deaths_this_shift = 0
		state.pending_chronicle_deaths = list()
		state.contracts = list()
		state.objectives = list()
		state.next_objective_id = 1
		state.next_object_id = 1
		state.validation_errors = odyssey_validate_graph(state.sector_graph)
		if (length(state.validation_errors))
			log_error("ODYSSEY: generated invalid graph: [json_encode(state.validation_errors)]")
			state.active = FALSE
			return FALSE
	if (announce)
		to_world(SPAN_NOTICE("<b>Одиссея [continued ? "продолжается" : "начинается"]. Смена [state.shift_number].</b>"))
	log_game("ODYSSEY: begin active=[state.active] continued=[continued] shift=[state.shift_number] id=[state.campaign_id]")
	// Switch prefs to the Odyssey persist lane so lobby locks/UI match the campaign file.
	character_persist_reload_connected_snapshots()
	if (continued)
		odyssey_chronicle_append(
			ODYSSEY_CHRONICLE_KIND_CONTINUE,
			"Кампания продолжается",
			"Смена [state.shift_number]. Сектор: [odyssey_sector_display_name(state.current_sector_id)].",
			ODYSSEY_CHRONICLE_VIS_PUBLIC,
			list("sector" = state.current_sector_id, "shift" = state.shift_number)
		)
	else
		odyssey_chronicle_append(
			ODYSSEY_CHRONICLE_KIND_START,
			"Одиссея началась",
			"Кампания [state.campaign_id]. Маршруты эшелона [state.min_shifts]–[state.max_shifts].",
			ODYSSEY_CHRONICLE_VIS_PUBLIC,
			list("campaign_id" = state.campaign_id)
		)
		odyssey_ensure_campaign_contract()
	odyssey_refresh_lobby_titlescreens()
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
	state.sleepers = odyssey_normalize_sleepers(meta["sleepers"])
	state.changelings = odyssey_normalize_changelings(meta["changelings"])
	state.sleeper_midround_done = FALSE
	state.merc_used = !!meta["merc_used"]
	state.merc_used_shift = meta["merc_used_shift"] || 0
	state.merc_used_reason = meta["merc_used_reason"]
	state.merc_shift_decision = null
	state.raider_shift_decision = null
	state.ninja_shift_decision = null
	state.changeling_shift_count = 0
	odyssey_load_shuttle_reports(meta)
	state.next_object_id = max(1, meta["next_object_id"] || 1)
	state.next_chronicle_id = max(1, meta["next_chronicle_id"] || 1)
	state.next_objective_id = max(1, meta["next_objective_id"] || 1)
	state.chronicle_deaths_this_shift = 0
	state.pending_chronicle_deaths = list()
	var/list/saved_contracts = meta["contracts"]
	state.contracts = islist(saved_contracts) ? saved_contracts.Copy() : list()
	var/list/saved_objectives = meta["objectives"]
	state.objectives = islist(saved_objectives) ? saved_objectives.Copy() : list()
	var/list/chronicle_data = odyssey_read_json(odyssey_snapshot_path("chronicle", state.save_generation))
	odyssey_apply_chronicle(chronicle_data?["entries"], TRUE)
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
		"changelings" = state.changelings,
		"merc_used" = state.merc_used,
		"merc_used_shift" = state.merc_used_shift,
		"merc_used_reason" = state.merc_used_reason,
		"abandoned_shuttles" = state.abandoned_shuttles,
		"shuttle_reports" = state.shuttle_reports,
		"next_chronicle_id" = state.next_chronicle_id,
		"next_objective_id" = state.next_objective_id,
		"contracts" = state.contracts,
		"objectives" = state.objectives,
		"parts" = list("turfs", "machinery", "structures", "mechs", "economy", "roster", "newscast", "corpses", "materials", "chronicle")
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
	var/corpses_path = odyssey_snapshot_path("corpses", expected_generation)
	if (fexists(corpses_path))
		var/list/corpses_data = odyssey_read_json(corpses_path)
		if (!islist(corpses_data))
			errors += "corpses.json повреждён"
		else if (expected_generation && corpses_data["generation"] != expected_generation)
			errors += "corpses.json относится к другой генерации"
	var/chronicle_path = odyssey_snapshot_path("chronicle", expected_generation)
	if (fexists(chronicle_path))
		var/list/chronicle_data = odyssey_read_json(chronicle_path)
		if (!islist(chronicle_data))
			errors += "chronicle.json повреждён"
		else if (expected_generation && chronicle_data["generation"] != expected_generation)
			errors += "chronicle.json относится к другой генерации"
	var/research_path = odyssey_snapshot_path("research", expected_generation)
	if (fexists(research_path))
		var/list/research_data = odyssey_read_json(research_path)
		if (!islist(research_data))
			errors += "research.json повреждён"
		else if (expected_generation && research_data["generation"] != expected_generation)
			errors += "research.json относится к другой генерации"
	var/materials_path = odyssey_snapshot_path("materials", expected_generation)
	if (fexists(materials_path))
		var/list/materials_data = odyssey_read_json(materials_path)
		if (!islist(materials_data))
			errors += "materials.json повреждён"
		else if (expected_generation && materials_data["generation"] != expected_generation)
			errors += "materials.json относится к другой генерации"
	return errors


/proc/odyssey_chronicle_campaign_outcome(status, reason)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.outcome_chronicled)
		return
	state.outcome_chronicled = TRUE
	odyssey_chronicle_append(
		ODYSSEY_CHRONICLE_KIND_OUTCOME,
		"Кампания завершена: [status]",
		"Причина: [reason || "не указана"].",
		ODYSSEY_CHRONICLE_VIS_PUBLIC,
		list("status" = status, "reason" = reason)
	)


/proc/odyssey_finish_campaign(status, reason)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/stats = null
	if (state.active)
		odyssey_chronicle_note_shift_losses()
		odyssey_evaluate_objectives(list("status" = status, "reason" = reason))
		odyssey_science_expire_active_briefs("campaign_end")
		odyssey_dept_expire_active_briefs("campaign_end")
		odyssey_chronicle_campaign_outcome(status, reason)
		stats = odyssey_publish_campaign_stats(status, reason)
	state.status = status
	state.outcome_reason = reason
	state.active = FALSE
	var/list/meta = odyssey_state_meta(FALSE)
	meta["archived_at"] = time2text(world.realtime, "YYYY-MM-DD hh:mm")
	meta["archive_reason"] = reason
	if (islist(stats))
		meta["campaign_stats"] = stats
	odyssey_write_meta(meta)
	log_game("ODYSSEY: campaign finished status=[status] reason=[reason]")
	// Back to the normal persist lane; Odyssey body file is left on disk untouched.
	character_persist_reload_connected_snapshots()
	odyssey_refresh_lobby_titlescreens()
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
	odyssey_sync_changelings_for_save()
	odyssey_sync_roster_for_save()
	odyssey_collect_abandoned_shuttles()
	odyssey_ensure_data_dir()

	// Chronicle shift closure before generation bump / sector hop bookkeeping.
	var/list/outcome = force ? null : odyssey_roundend_outcome()
	if (!force)
		odyssey_evaluate_objectives(outcome)
		odyssey_chronicle_note_shift_losses()
		if (outcome)
			odyssey_chronicle_campaign_outcome(outcome["status"], outcome["reason"])
		else if (!state.transition_committed)
			// Jump chronicle entry is written at BSD commit when transition_committed.
			odyssey_chronicle_append(
				ODYSSEY_CHRONICLE_KIND_SHIFT_END,
				"Смена экипажа в секторе",
				"Корабль остаётся в «[odyssey_sector_display_name(state.current_sector_id)]». Смена [state.shift_number] → [state.shift_number + 1].",
				ODYSSEY_CHRONICLE_VIS_PUBLIC,
				list("sector" = state.current_sector_id)
			)

	var/generation = "[state.campaign_id]-[world.realtime]-[world.time]"
	var/list/turfs = odyssey_collect_turfs()
	var/list/machinery = odyssey_collect_machinery()
	var/list/structures = odyssey_collect_structures()
	var/list/mechs = odyssey_collect_mechs()
	var/list/economy = odyssey_collect_economy()
	var/list/research = odyssey_collect_research()
	var/list/newscast = odyssey_collect_newscast(generation)
	var/list/corpses = odyssey_collect_corpses()
	var/list/materials = odyssey_collect_materials()
	var/list/chronicle = odyssey_collect_chronicle()
	var/list/common = list("version" = ODYSSEY_VERSION, "campaign_id" = state.campaign_id, "generation" = generation)
	var/success = TRUE
	success = odyssey_write_json(odyssey_snapshot_path("turfs", generation), common + list("entries" = turfs)) && success
	success = odyssey_write_json(odyssey_snapshot_path("machinery", generation), common + list("entries" = machinery)) && success
	success = odyssey_write_json(odyssey_snapshot_path("structures", generation), common + list("entries" = structures)) && success
	success = odyssey_write_json(odyssey_snapshot_path("mechs", generation), common + list("entries" = mechs)) && success
	success = odyssey_write_json(odyssey_snapshot_path("economy", generation), common + list("data" = economy)) && success
	success = odyssey_write_json(odyssey_snapshot_path("research", generation), common + list("data" = research)) && success
	success = odyssey_write_json(odyssey_snapshot_path("roster", generation), common + list("entries" = state.roster)) && success
	success = odyssey_write_json(odyssey_snapshot_path("newscast", generation), common + list("data" = newscast)) && success
	success = odyssey_write_json(odyssey_snapshot_path("corpses", generation), common + list("entries" = corpses)) && success
	success = odyssey_write_json(odyssey_snapshot_path("materials", generation), common + list("entries" = materials)) && success
	success = odyssey_write_json(odyssey_snapshot_path("chronicle", generation), common + list("entries" = chronicle)) && success
	if (!success)
		log_error("ODYSSEY: snapshot write failed; campaign meta was not published")
		return FALSE

	// Transfer/shift-end stays in the current sector and does not consume a graph hop.
	// Odyssey Jump still increments shift_number on continue via transition_committed.
	if (!force && !state.transition_committed && !outcome)
		state.shift_number++
		log_game("ODYSSEY: same-sector crew shift=[state.shift_number] echelon=[odyssey_campaign_echelon(state)] sector=[state.current_sector_id]")

	var/list/meta = odyssey_state_meta(null, generation)
	if (!odyssey_write_meta(meta))
		log_error("ODYSSEY: meta write failed after snapshot generation [generation]")
		return FALSE
	state.save_generation = generation
	log_game("ODYSSEY: saved campaign=[state.campaign_id] shift=[state.shift_number] turfs=[length(turfs)] machinery=[length(machinery)] mechs=[length(mechs)] materials=[length(materials)] corpses=[length(corpses)] chronicle=[length(chronicle)] force=[force]")
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
	odyssey_ensure_persist_baselines()
	// Fresh DMM would refill sheet stacks every shift; wipe, then restore last shift's stacks.
	odyssey_strip_map_materials()
	var/list/meta = odyssey_load_meta()
	var/generation = islist(meta) ? meta["generation"] : state.save_generation
	if (generation)
		state.save_generation = generation
	var/list/turfs = odyssey_read_json(odyssey_snapshot_path("turfs", generation))
	var/list/machinery = odyssey_read_json(odyssey_snapshot_path("machinery", generation))
	var/list/structures = odyssey_read_json(odyssey_snapshot_path("structures", generation))
	var/list/mechs = odyssey_read_json(odyssey_snapshot_path("mechs", generation))
	var/list/economy = odyssey_read_json(odyssey_snapshot_path("economy", generation))
	var/list/research = odyssey_read_json(odyssey_snapshot_path("research", generation))
	var/list/newscast = odyssey_read_json(odyssey_snapshot_path("newscast", generation))
	var/list/corpses = odyssey_read_json(odyssey_snapshot_path("corpses", generation))
	var/list/materials = odyssey_read_json(odyssey_snapshot_path("materials", generation))
	var/list/chronicle = odyssey_read_json(odyssey_snapshot_path("chronicle", generation))

	odyssey_apply_turfs(turfs?["entries"])
	odyssey_build_persist_index()
	odyssey_apply_machinery(machinery?["entries"])
	odyssey_apply_structures(structures?["entries"])
	odyssey_apply_mechs(mechs?["entries"])
	odyssey_clear_persist_index()
	odyssey_apply_economy(economy?["data"])
	odyssey_apply_research(research?["data"])
	odyssey_apply_newscast(newscast?["data"], state.save_generation)
	odyssey_apply_corpses(corpses?["entries"])
	// After structures (closets) exist again: place saved sheet stacks.
	odyssey_apply_materials(materials?["entries"])
	odyssey_apply_chronicle(chronicle?["entries"], force)

	log_game("ODYSSEY: applied save campaign=[state.campaign_id] shift=[state.shift_number] force=[force]")
	return TRUE


/// Legacy hook from SSticker pregame. Odyssey votes are started from the lobby Odyssey button / admin panel.
/proc/odyssey_pregame_consider_vote()
	return
