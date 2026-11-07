/proc/odyssey_snapshot_path(kind, generation)
	if (generation)
		return "[ODYSSEY_DATA_DIR]_[odyssey_map_key()]_[generation]_[kind].json"
	return "[ODYSSEY_DATA_DIR]_[odyssey_map_key()]_[kind].json"


/proc/odyssey_begin_campaign(continued, announce = TRUE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (continued)
		// Baselines must be taken on a clean DMM. Mid-round apply diffs against a dirty world.
		if (GAME_STATE >= RUNLEVEL_GAME)
			log_error("ODYSSEY: continue refused mid-round (GAME_STATE=[GAME_STATE]); use lobby continue before round start")
			state.validation_errors = list("continue mid-round запрещён: загрузка сейва только до старта раунда (лобби), иначе baselines снимаются с уже изменённой карты")
			return FALSE
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
		// Drop prior campaign snapshot trees so generations do not accumulate on disk.
		odyssey_purge_map_snapshots(null)
		state.active = TRUE
		state.continued = FALSE
		state.status = ODYSSEY_STATUS_ACTIVE
		state.outcome_reason = null
		state.save_version = ODYSSEY_VERSION
		state.meta_path = odyssey_meta_path()
		state.campaign_id = "[odyssey_map_key()]_[time2text(world.realtime, "YYYYMMDDhhmmss")]"
		state.save_generation = null
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
		state.post_jump_save_ready = FALSE
		state.bsd_post_jump_cooling = FALSE
		state.bsd_cooling_until = 0
		state.shift_end_queued = FALSE
		odyssey_clear_save_warn_timer()
		state.route_history = list(ODYSSEY_SECTOR_START)
		state.roster = list()
		state.sleepers = list()
		state.changelings = list()
		state.revolutionaries = list()
		state.loyalists = list()
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
	state.save_applied = FALSE
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
	state.post_jump_save_ready = FALSE
	state.bsd_post_jump_cooling = FALSE
	state.bsd_cooling_until = 0
	state.shift_end_queued = FALSE
	odyssey_clear_save_warn_timer()
	var/list/saved_route_history = meta["route_history"]
	state.route_history = islist(saved_route_history) ? saved_route_history.Copy() : list(state.current_sector_id)
	state.roster = odyssey_load_roster()
	state.sleepers = odyssey_normalize_sleepers(meta["sleepers"])
	state.changelings = odyssey_normalize_changelings(meta["changelings"])
	state.revolutionaries = odyssey_normalize_faction_map(meta["revolutionaries"])
	state.loyalists = odyssey_normalize_faction_map(meta["loyalists"])
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
		state.post_jump_save_ready = FALSE
		state.bsd_post_jump_cooling = TRUE
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
		"revolutionaries" = state.revolutionaries,
		"loyalists" = state.loyalists,
		"merc_used" = state.merc_used,
		"merc_used_shift" = state.merc_used_shift,
		"merc_used_reason" = state.merc_used_reason,
		"abandoned_shuttles" = state.abandoned_shuttles,
		"shuttle_reports" = state.shuttle_reports,
		"next_chronicle_id" = state.next_chronicle_id,
		"next_objective_id" = state.next_objective_id,
		"contracts" = state.contracts,
		"objectives" = state.objectives,
		"parts" = list("turfs", "machinery", "structures", "mechs", "economy", "research", "roster", "newscast", "corpses", "materials", "papers", "items", "remains", "cleanables", "chronicle")
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
	// Jump commits immediately; save/roundend wait for the post-jump grace (crew prep).
	return state.active && state.transition_committed && state.odyssey_bsd_jump_done && state.post_jump_save_ready


/// Same style as «Одиссея начинается» / «Одиссея: загрузка…» — OOC chat, not IC channels.
/proc/odyssey_ooc_announce(message, urgent = FALSE)
	if (!message)
		return
	if (urgent)
		to_chat(world, SPAN_DANGER("<b>[message]</b>"))
	else
		to_chat(world, SPAN_NOTICE("<b>[message]</b>"))


/// After Odyssey Jump: open the save grace window, then arm roundend.
/proc/odyssey_schedule_post_jump_save()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !state.odyssey_bsd_jump_done)
		return
	state.post_jump_save_ready = FALSE
	var/minutes = max(1, round(ODYSSEY_SAVE_WARN_BEFORE / (1 MINUTE)))
	odyssey_ooc_announce("Одиссея: переход выполнен. Сохранение кампании через [minutes] мин - закончите критичные действия и не отключайтесь.")
	odyssey_clear_save_warn_timer()
	state.save_warn_timer_id = addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_arm_post_jump_save)), ODYSSEY_SAVE_WARN_BEFORE, TIMER_STOPPABLE)
	log_game("ODYSSEY: post-jump save grace=[ODYSSEY_SAVE_WARN_BEFORE] sector=[state.selected_sector_id]")


/proc/odyssey_arm_post_jump_save()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	state.save_warn_timer_id = null
	if (!state.active || !state.odyssey_bsd_jump_done)
		return
	state.post_jump_save_ready = TRUE
	odyssey_ooc_announce("Одиссея: начинается сохранение кампании. Ожидайте смену экипажа.", TRUE)
	log_game("ODYSSEY: post-jump save armed sector=[state.selected_sector_id]")


/proc/odyssey_clear_save_warn_timer()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.save_warn_timer_id)
		deltimer(state.save_warn_timer_id)
		state.save_warn_timer_id = null


/// OOC warning so crew can finish surgery, dock, and stay connected for the save UI.
/proc/odyssey_announce_save_imminent(context = null)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	state.save_warn_timer_id = null
	if (!state.active)
		return
	var/minutes = max(1, round(ODYSSEY_SAVE_WARN_BEFORE / (1 MINUTE)))
	var/detail = context ? " ([context])" : ""
	odyssey_ooc_announce("Одиссея: сохранение кампании через [minutes] мин[detail]. Закончите критичные действия и не отключайтесь.")
	log_game("ODYSSEY: save warning announced context=[context || "none"]")


/// Fire [odyssey_announce_save_imminent] ODYSSEY_SAVE_WARN_BEFORE before [delay_until_save] elapses.
/proc/odyssey_schedule_save_warn(delay_until_save, context = null)
	odyssey_clear_save_warn_timer()
	if (!isnum(delay_until_save) || delay_until_save <= 0)
		return
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	var/warn_in = delay_until_save - ODYSSEY_SAVE_WARN_BEFORE
	if (warn_in <= 0)
		odyssey_announce_save_imminent(context)
		return
	state.save_warn_timer_id = addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_announce_save_imminent), context), warn_in, TIMER_STOPPABLE)


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
	odyssey_schedule_save_warn(ODYSSEY_SHIFT_END_DELAY, "смена экипажа")
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
	odyssey_clear_save_warn_timer()
	priority_announcement.Announce("Shift rotation is beginning. Stand by for crew changeover.")
	odyssey_ooc_announce("Одиссея: начинается сохранение кампании. Ожидайте смену экипажа.", TRUE)
	SSticker.forced_end = TRUE
	log_game("ODYSSEY: shift-end forced_end shift=[state.shift_number] sector=[state.current_sector_id]")


/// Read snapshot JSON; when [session] is set, fill/reuse its cache so validate+apply share one disk read.
/proc/odyssey_validate_read_json(kind, generation, datum/odyssey_load_session/session = null)
	if (istype(session))
		return odyssey_session_cached_json(session, kind, generation)
	return odyssey_read_json(odyssey_snapshot_path(kind, generation))


/proc/odyssey_validate_check_part(kind, expected_generation, expected_campaign, list/errors, required, datum/odyssey_load_session/session = null)
	var/path = odyssey_snapshot_path(kind, expected_generation)
	if (!fexists(path))
		if (required)
			errors += "[kind].json отсутствует или повреждён"
		else if (expected_generation && (kind == "structures" || kind == "roster"))
			errors += "[kind].json отсутствует"
		return
	var/list/data = odyssey_validate_read_json(kind, expected_generation, session)
	if (!islist(data))
		errors += "[kind].json [required ? "отсутствует или " : ""]повреждён"
		return
	if (required)
		var/version = data["version"] || 1
		if (version < 1 || version > ODYSSEY_VERSION)
			errors += "[kind].json имеет неподдерживаемую версию [version]"
		if (data["campaign_id"] && data["campaign_id"] != expected_campaign)
			errors += "[kind].json относится к другой кампании"
	if (expected_generation && data["generation"] != expected_generation)
		errors += "[kind].json относится к другой генерации"


/// Optional [session]: populate json cache during validate for apply reuse. Safe — same checks, one read.
/proc/odyssey_validate_save(datum/odyssey_load_session/session = null)
	var/list/errors = list()
	var/list/meta = odyssey_load_meta()
	if (!islist(meta))
		errors += "campaign.json отсутствует или несовместим"
		return errors
	errors += odyssey_validate_graph(meta["sector_graph"])
	var/expected_generation = meta["generation"]
	var/expected_campaign = meta["campaign_id"]
	for (var/kind in list("turfs", "machinery", "mechs", "economy"))
		odyssey_validate_check_part(kind, expected_generation, expected_campaign, errors, TRUE, session)
	for (var/optional_kind in list("structures", "roster"))
		odyssey_validate_check_part(optional_kind, expected_generation, expected_campaign, errors, FALSE, session)
	for (var/optional_kind in list("newscast", "corpses", "chronicle", "research", "materials", "papers", "remains", "cleanables", odyssey_items_manifest_kind()))
		var/path = odyssey_snapshot_path(optional_kind, expected_generation)
		if (!fexists(path))
			if (istype(session))
				odyssey_session_cached_json(session, optional_kind, expected_generation) // cache miss
			continue
		odyssey_validate_check_part(optional_kind, expected_generation, expected_campaign, errors, FALSE, session)
	for (var/bucket in ODYSSEY_ITEM_BUCKETS)
		var/kind = odyssey_item_snapshot_kind(bucket)
		var/items_path = odyssey_snapshot_path(kind, expected_generation)
		if (!fexists(items_path))
			if (istype(session))
				odyssey_session_cached_json(session, kind, expected_generation)
			continue
		odyssey_validate_check_part(kind, expected_generation, expected_campaign, errors, FALSE, session)
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
	odyssey_clear_save_warn_timer()
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
	odyssey_science_enabled = FALSE
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


/// Collect + write one snapshot part with progress UI. Returns written entry count or -1 on write fail.
/proc/odyssey_save_part(datum/odyssey_load_session/session, id, generation, list/common, entries_or_data, as_data = FALSE)
	var/n = islist(entries_or_data) ? length(entries_or_data) : 0
	odyssey_load_step(session, id, "active", "запись ([n])…")
	var/list/payload = common.Copy()
	if (as_data)
		payload["data"] = entries_or_data
	else
		payload["entries"] = entries_or_data
	if (!odyssey_write_json(odyssey_snapshot_path(id, generation), payload))
		odyssey_load_step(session, id, "error", "запись не удалась")
		return -1
	odyssey_load_step(session, id, "done", "готово ([n])")
	return n


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

	var/datum/odyssey_load_session/session = new
	session.subtitle = "Сохранение кампании"
	session.footer = "Пожалуйста, подождите. Не закрывайте клиент до завершения записи."
	session.idle_headline = "Сохранение…"
	session.add_step("prepare", "Подготовка (roster / антаги / шаттлы)")
	session.add_step("bookkeeping", "Итоги смены / хроника")
	session.add_step("turfs", "turfs.json")
	session.add_step("machinery", "machinery.json")
	session.add_step("structures", "structures.json")
	session.add_step("mechs", "mechs.json")
	session.add_step("economy", "economy.json")
	session.add_step("research", "research.json")
	session.add_step("roster", "roster.json")
	session.add_step("newscast", "newscast.json")
	session.add_step("corpses", "corpses.json")
	session.add_step("materials", "materials.json")
	session.add_step("papers", "papers.json")
	session.add_step("items_collect", "Сбор предметов")
	for (var/bucket in ODYSSEY_ITEM_BUCKETS)
		session.add_step(odyssey_item_snapshot_kind(bucket), "items_[bucket].json")
	session.add_step(odyssey_items_manifest_kind(), "items.json (lane)")
	session.add_step("remains", "remains.json")
	session.add_step("cleanables", "cleanables.json")
	session.add_step("chronicle", "chronicle.json")
	session.add_step("meta", "campaign.json")
	session.add_step("finish", "Завершение")

	odyssey_load_ui_push(session)
	to_chat(world, SPAN_NOTICE("<b>Одиссея: сохранение состояния кампании…</b>"))
	odyssey_invalidate_persistable_turfs_cache()

	odyssey_load_step(session, "prepare", "active")
	odyssey_sync_sleepers_for_save()
	odyssey_sync_changelings_for_save()
	odyssey_sync_revolutionaries_for_save()
	odyssey_sync_roster_for_save()
	odyssey_collect_abandoned_shuttles()
	odyssey_ensure_data_dir()
	odyssey_load_step(session, "prepare", "done")

	// Chronicle shift closure before generation bump / sector hop bookkeeping.
	odyssey_load_step(session, "bookkeeping", "active")
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
	odyssey_load_step(session, "bookkeeping", "done")

	var/generation = "[state.campaign_id]-[world.realtime]-[world.time]"
	var/list/common = list("version" = ODYSSEY_VERSION, "campaign_id" = state.campaign_id, "generation" = generation)
	var/success = TRUE
	var/list/turfs
	var/list/machinery
	var/list/structures
	var/list/mechs
	var/list/economy
	var/list/research
	var/list/newscast
	var/list/corpses
	var/list/materials
	var/list/papers
	var/list/item_buckets
	var/list/remains
	var/list/cleanables
	var/list/chronicle

	odyssey_load_step(session, "turfs", "active", "один обход карты…")
	var/list/station = odyssey_collect_station(generation)
	turfs = station["turfs"]
	machinery = station["machinery"]
	structures = station["structures"]
	materials = station["materials"]
	papers = station["papers"]
	item_buckets = station["items"]
	remains = station["remains"]
	cleanables = station["cleanables"]
	if (odyssey_save_part(session, "turfs", generation, common, turfs) < 0)
		success = FALSE

	if (success)
		odyssey_load_step(session, "machinery", "active", "запись…")
		if (odyssey_save_part(session, "machinery", generation, common, machinery) < 0)
			success = FALSE

	if (success)
		odyssey_load_step(session, "structures", "active", "запись…")
		if (odyssey_save_part(session, "structures", generation, common, structures) < 0)
			success = FALSE

	if (success)
		odyssey_load_step(session, "mechs", "active", "сбор…")
		mechs = odyssey_collect_mechs()
		if (odyssey_save_part(session, "mechs", generation, common, mechs) < 0)
			success = FALSE

	if (success)
		odyssey_load_step(session, "economy", "active", "сбор…")
		economy = odyssey_collect_economy()
		if (odyssey_save_part(session, "economy", generation, common, economy, TRUE) < 0)
			success = FALSE

	if (success)
		odyssey_load_step(session, "research", "active", "сбор…")
		research = odyssey_collect_research()
		if (odyssey_save_part(session, "research", generation, common, research, TRUE) < 0)
			success = FALSE

	if (success)
		odyssey_load_step(session, "roster", "active", "запись…")
		if (odyssey_save_part(session, "roster", generation, common, state.roster) < 0)
			success = FALSE

	if (success)
		odyssey_load_step(session, "newscast", "active", "сбор…")
		newscast = odyssey_collect_newscast(generation)
		if (odyssey_save_part(session, "newscast", generation, common, newscast, TRUE) < 0)
			success = FALSE

	if (success)
		odyssey_load_step(session, "corpses", "active", "сбор…")
		corpses = odyssey_collect_corpses()
		if (odyssey_save_part(session, "corpses", generation, common, corpses) < 0)
			success = FALSE

	if (success)
		odyssey_load_step(session, "materials", "active", "запись…")
		if (odyssey_save_part(session, "materials", generation, common, materials) < 0)
			success = FALSE

	if (success)
		odyssey_load_step(session, "papers", "active", "запись…")
		if (odyssey_save_part(session, "papers", generation, common, papers) < 0)
			success = FALSE

	if (success)
		odyssey_load_step(session, "items_collect", "done", "собрано ([odyssey_count_item_bucket_entries(item_buckets)])")
		for (var/bucket in ODYSSEY_ITEM_BUCKETS)
			var/kind = odyssey_item_snapshot_kind(bucket)
			var/list/entries = item_buckets[bucket]
			if (!islist(entries) || !length(entries))
				odyssey_load_step(session, kind, "done", "пусто — пропуск")
				continue
			odyssey_load_step(session, kind, "active", "запись ([length(entries)])…")
			if (!odyssey_write_json(odyssey_snapshot_path(kind, generation), common + list("bucket" = bucket, "entries" = entries)))
				odyssey_load_step(session, kind, "error", "запись не удалась")
				success = FALSE
				break
			odyssey_load_step(session, kind, "done", "готово ([length(entries)])")
		if (success)
			odyssey_load_step(session, odyssey_items_manifest_kind(), "active", "lane marker…")
			if (!odyssey_write_items_manifest(item_buckets, common))
				odyssey_load_step(session, odyssey_items_manifest_kind(), "error", "запись не удалась")
				success = FALSE
			else
				odyssey_load_step(session, odyssey_items_manifest_kind(), "done", "item_count=[odyssey_count_item_bucket_entries(item_buckets)]")

	if (success)
		odyssey_load_step(session, "remains", "active", "запись…")
		if (odyssey_save_part(session, "remains", generation, common, remains) < 0)
			success = FALSE

	if (success)
		odyssey_load_step(session, "cleanables", "active", "запись…")
		if (odyssey_save_part(session, "cleanables", generation, common, cleanables) < 0)
			success = FALSE

	if (success)
		odyssey_load_step(session, "chronicle", "active", "сбор…")
		chronicle = odyssey_collect_chronicle()
		if (odyssey_save_part(session, "chronicle", generation, common, chronicle) < 0)
			success = FALSE

	if (!success)
		log_error("ODYSSEY: snapshot write failed; campaign meta was not published")
		odyssey_delete_generation(generation)
		odyssey_invalidate_persistable_turfs_cache()
		session.finished = TRUE
		sleep(2 SECONDS)
		odyssey_load_ui_close(session)
		return FALSE

	// Transfer/shift-end stays in the current sector and does not consume a graph hop.
	// Odyssey Jump still increments shift_number on continue via transition_committed.
	if (!force && !state.transition_committed && !outcome)
		state.shift_number++
		log_game("ODYSSEY: same-sector crew shift=[state.shift_number] echelon=[odyssey_campaign_echelon(state)] sector=[state.current_sector_id]")

	odyssey_load_step(session, "meta", "active", "запись…")
	var/list/meta = odyssey_state_meta(null, generation)
	if (!odyssey_write_meta(meta))
		odyssey_load_step(session, "meta", "error", "запись не удалась")
		log_error("ODYSSEY: meta write failed after snapshot generation [generation]")
		odyssey_delete_generation(generation)
		odyssey_invalidate_persistable_turfs_cache()
		session.finished = TRUE
		sleep(2 SECONDS)
		odyssey_load_ui_close(session)
		return FALSE
	odyssey_load_step(session, "meta", "done")

	state.save_generation = generation
	// Keep only the published generation — older trees (and failed orphans) are removed.
	odyssey_purge_map_snapshots(generation)
	odyssey_load_step(session, "finish", "active")
	session.finished = TRUE
	odyssey_load_step(session, "finish", "done")
	log_game("ODYSSEY: saved campaign=[state.campaign_id] shift=[state.shift_number] turfs=[length(turfs)] machinery=[length(machinery)] mechs=[length(mechs)] materials=[length(materials)] papers=[length(papers)] items=[odyssey_count_item_bucket_entries(item_buckets)] remains=[length(remains)] cleanables=[length(cleanables)] corpses=[length(corpses)] chronicle=[length(chronicle)] force=[force]")
	to_world(SPAN_NOTICE("<b>Состояние Одиссеи сохранено (смена [state.shift_number]).</b>"))
	odyssey_invalidate_persistable_turfs_cache()
	if (session.ui_dirty)
		odyssey_load_ui_push(session, TRUE)
	sleep(0.3 SECONDS)
	odyssey_load_ui_close(session)
	return TRUE


/// Apply campaign snapshot. Prefer odyssey_bootstrap_continued_save() so clients get the load UI.
/proc/odyssey_apply_save(force = FALSE)
	return odyssey_bootstrap_continued_save(force)


/// Legacy hook from SSticker pregame. Odyssey votes are started from the lobby Odyssey button / admin panel.
/proc/odyssey_pregame_consider_vote()
	return
