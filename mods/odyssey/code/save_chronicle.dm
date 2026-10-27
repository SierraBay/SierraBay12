/// Campaign chronicle: durable event log across Odyssey shifts.

/proc/odyssey_chronicle_flush()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.campaign_id)
		return FALSE
	return odyssey_write_json(odyssey_snapshot_path("chronicle", state.save_generation), list(
		"version" = ODYSSEY_VERSION,
		"campaign_id" = state.campaign_id,
		"generation" = state.save_generation,
		"entries" = state.chronicle
	))


/proc/odyssey_chronicle_append(kind, title, body, visibility = ODYSSEY_CHRONICLE_VIS_PUBLIC, list/refs)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !state.campaign_id)
		return null
	if (!kind || !title)
		return null
	if (!(visibility in list(ODYSSEY_CHRONICLE_VIS_PUBLIC, ODYSSEY_CHRONICLE_VIS_COMMAND, ODYSSEY_CHRONICLE_VIS_ADMIN)))
		visibility = ODYSSEY_CHRONICLE_VIS_PUBLIC
	if (!islist(state.chronicle))
		state.chronicle = list()
	var/id = "evt-[state.next_chronicle_id++]"
	var/list/entry = list(
		"id" = id,
		"shift" = state.shift_number,
		"at" = odyssey_ic_timestamp(),
		"kind" = kind,
		"visibility" = visibility,
		"title" = "[title]",
		"body" = "[body]"
	)
	if (islist(refs) && length(refs))
		entry["refs"] = refs
	state.chronicle += list(entry)
	while (length(state.chronicle) > ODYSSEY_CHRONICLE_MAX)
		state.chronicle.Cut(1, 2)
	odyssey_chronicle_flush()
	log_debug("ODYSSEY: chronicle [kind] shift=[state.shift_number] [title]")
	return entry


/proc/odyssey_collect_chronicle()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	return islist(state.chronicle) ? state.chronicle.Copy() : list()


/proc/odyssey_apply_chronicle(list/entries, overwrite = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	// begin_campaign may already have loaded disk + appended continue/start for this round.
	if (length(state.chronicle) && !overwrite)
		return
	if (!islist(entries))
		state.chronicle = list()
		return
	state.chronicle = entries.Copy()
	var/max_id = 0
	for (var/list/entry in state.chronicle)
		if (!islist(entry))
			continue
		var/id = entry["id"]
		if (!istext(id))
			continue
		var/num = text2num(copytext(id, 5))
		if (isnum(num) && num > max_id)
			max_id = num
	state.next_chronicle_id = max(state.next_chronicle_id, max_id + 1)
	log_debug("ODYSSEY: apply_chronicle entries=[length(state.chronicle)] next_id=[state.next_chronicle_id]")


/proc/odyssey_job_is_command(job_title)
	if (!job_title || !SSjobs)
		return FALSE
	var/list/heads = SSjobs.titles_by_department(COM)
	return islist(heads) && (job_title in heads)


/proc/odyssey_chronicle_note_death(mob/living/carbon/human/H, reason, job_title)
	if (!istype(H))
		return
	var/name = H.real_name || "Неизвестный"
	var/job = job_title || H.mind?.role_alt_title || H.mind?.assigned_role || H.job || "Unknown"
	var/vis = odyssey_job_is_command(job) ? ODYSSEY_CHRONICLE_VIS_PUBLIC : ODYSSEY_CHRONICLE_VIS_COMMAND
	odyssey_chronicle_append(
		ODYSSEY_CHRONICLE_KIND_DEATH,
		"Погиб: [name]",
		"[job]. Причина: [reason || "death"].",
		vis,
		list("name" = name, "job" = job, "reason" = reason)
	)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	state.chronicle_deaths_this_shift = (state.chronicle_deaths_this_shift || 0) + 1


/proc/odyssey_chronicle_note_shift_losses()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/deaths = state.chronicle_deaths_this_shift || 0
	if (deaths < 1)
		return
	odyssey_chronicle_append(
		ODYSSEY_CHRONICLE_KIND_LOSSES,
		"Потери экипажа за смену",
		"Зафиксировано погибших по roster: [deaths].",
		ODYSSEY_CHRONICLE_VIS_PUBLIC,
		list("count" = deaths)
	)
	state.chronicle_deaths_this_shift = 0


/proc/odyssey_chronicle_ui_entries(min_visibility = ODYSSEY_CHRONICLE_VIS_PUBLIC)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/out = list()
	if (!islist(state.chronicle))
		return out
	var/allow_command = (min_visibility == ODYSSEY_CHRONICLE_VIS_COMMAND || min_visibility == ODYSSEY_CHRONICLE_VIS_ADMIN)
	var/allow_admin = (min_visibility == ODYSSEY_CHRONICLE_VIS_ADMIN)
	for (var/list/entry in state.chronicle)
		if (!islist(entry))
			continue
		var/vis = entry["visibility"] || ODYSSEY_CHRONICLE_VIS_PUBLIC
		if (vis == ODYSSEY_CHRONICLE_VIS_ADMIN && !allow_admin)
			continue
		if (vis == ODYSSEY_CHRONICLE_VIS_COMMAND && !allow_command)
			continue
		out += list(list(
			"id" = entry["id"],
			"shift" = entry["shift"],
			"at" = entry["at"],
			"kind" = entry["kind"],
			"visibility" = vis,
			"title" = entry["title"],
			"body" = entry["body"]
		))
	return out


/proc/odyssey_roster_counts(list/roster)
	var/alive = 0
	var/dead = 0
	var/dead_command = 0
	if (!islist(roster))
		return list("alive" = 0, "dead" = 0, "dead_command" = 0)
	for (var/key in roster)
		var/list/entry = roster[key]
		if (!islist(entry))
			continue
		if (entry["status"] == "dead")
			dead++
			if (odyssey_job_is_command(entry["job"]))
				dead_command++
		else
			alive++
	return list("alive" = alive, "dead" = dead, "dead_command" = dead_command)


/// Lobby / admin briefing built from campaign meta (+ optional live state).
/proc/odyssey_continue_briefing(list/meta, short = FALSE)
	if (!islist(meta))
		meta = odyssey_load_meta()
	if (!islist(meta))
		return short ? "Нет сейва Одиссеи." : "Нет активного сейва Одиссеи."

	var/list/graph = meta["sector_graph"]
	var/next_sector = (meta["transition_committed"] && meta["selected_sector_id"]) ? meta["selected_sector_id"] : meta["current_sector_id"]
	var/list/sector = islist(graph) ? graph[next_sector] : null
	var/echelon = odyssey_sector_echelon(next_sector, graph)
	var/max_shifts = meta["max_shifts"] || ODYSSEY_MAX_SHIFTS
	var/shift = meta["shift_number"] || 1
	var/sector_name = sector?["name"] || next_sector || "?"
	var/danger = sector?["danger"]
	var/course_text
	if (meta["transition_committed"] && meta["selected_sector_id"])
		var/dest_id = meta["selected_sector_id"]
		var/dest_name = dest_id
		if (dest_id == ODYSSEY_SECTOR_RETURN)
			dest_name = "возвращение домой"
		else if (dest_id == ODYSSEY_SECTOR_COMPLETE)
			dest_name = "завершение Одиссеи"
		else if (islist(graph) && islist(graph[dest_id]) && graph[dest_id]["name"])
			dest_name = graph[dest_id]["name"]
		course_text = "прыжок → «[dest_name]»"
	else
		course_text = "смена на месте (тот же сектор)"

	var/list/roster = odyssey_load_roster()
	var/list/counts = odyssey_roster_counts(roster)
	var/list/abandoned = meta["abandoned_shuttles"]
	var/list/shuttle_reports = meta["shuttle_reports"]
	var/list/damaged_bits = list()
	if (islist(shuttle_reports))
		for (var/shuttle_name in shuttle_reports)
			var/list/report = shuttle_reports[shuttle_name]
			if (!islist(report) || report["status"] != ODYSSEY_SHUTTLE_STATUS_DAMAGED)
				continue
			damaged_bits += "[shuttle_name] ([report["repair_cost"] || "?"] T)"
	var/shuttle_text = islist(abandoned) && length(abandoned) ? english_list(abandoned) : "нет"
	var/damaged_text = length(damaged_bits) ? english_list(damaged_bits) : "нет"

	var/list/chronicle = null
	var/list/chronicle_file = odyssey_read_json(odyssey_snapshot_path("chronicle", meta["generation"]))
	if (islist(chronicle_file) && islist(chronicle_file["entries"]))
		chronicle = chronicle_file["entries"]
	var/list/recent = list()
	if (islist(chronicle))
		for (var/i = length(chronicle); i >= 1 && length(recent) < 3; i--)
			var/list/entry = chronicle[i]
			if (!islist(entry))
				continue
			if ((entry["visibility"] || ODYSSEY_CHRONICLE_VIS_PUBLIC) != ODYSSEY_CHRONICLE_VIS_PUBLIC)
				continue
			recent += entry["title"]

	if (short)
		var/bits = list()
		bits += "эшелон [echelon]/[max_shifts]"
		bits += "«[sector_name]»"
		if (counts["dead"])
			bits += "[counts["dead"]] погибших"
		if (islist(abandoned) && length(abandoned))
			bits += "утерян [abandoned[1]][length(abandoned) > 1 ? "…" : ""]"
		if (length(damaged_bits))
			bits += "повреждён [damaged_bits[1]][length(damaged_bits) > 1 ? "…" : ""]"
		return "Продолжить Одиссею? [jointext(bits, ", ")]. [course_text]. (≥[ODYSSEY_MIN_YES_VOTES] «За»)"

	var/list/lines = list()
	lines += "Одиссея — сводка"
	lines += "Смена экипажа: [shift] | Эшелон: [echelon]/[max_shifts]"
	lines += "Сектор: «[sector_name]»[danger ? " ([danger])" : ""]"
	lines += "Курс: [course_text]"
	lines += "Roster: живых [counts["alive"]], погибших [counts["dead"]][counts["dead_command"] ? " (командный состав: [counts["dead_command"]])" : ""]"
	lines += "Утерянные шаттлы: [shuttle_text]"
	lines += "Повреждённые шаттлы (ремонт): [damaged_text]"
	var/list/contracts = meta["contracts"]
	var/list/objectives = meta["objectives"]
	var/list/contract_titles = list()
	if (islist(contracts))
		for (var/list/entry in contracts)
			if (islist(entry) && entry["status"] == ODYSSEY_OBJ_STATUS_ACTIVE)
				contract_titles += entry["title"]
	var/list/objective_titles = list()
	if (islist(objectives))
		for (var/list/entry in objectives)
			if (islist(entry) && entry["status"] == ODYSSEY_OBJ_STATUS_ACTIVE && entry["scope"] == "shift")
				objective_titles += entry["title"]
	lines += "Контракт: [length(contract_titles) ? english_list(contract_titles) : "нет активного"]"
	lines += "Цели прошлой смены (ещё active): [length(objective_titles) ? english_list(objective_titles) : "закрыты / нет"]"
	if (length(recent))
		lines += "Недавние события: [jointext(recent, " · ")]"
	return jointext(lines, "\n")


/proc/odyssey_announce_continue_briefing()
	var/text = odyssey_continue_briefing(null, FALSE)
	to_chat(world, SPAN_NOTICE("<b>[replacetext(text, "\n", "<br>")]</b>"))
