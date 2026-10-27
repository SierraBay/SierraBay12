/// Shared expedition briefing payload for Newscast / Command / lobby summaries.

/proc/odyssey_briefing_headlines(limit = 5)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/out = list()
	if (!islist(state.chronicle))
		return out
	for (var/i = length(state.chronicle); i >= 1 && length(out) < limit; i--)
		var/list/entry = state.chronicle[i]
		if (!islist(entry))
			continue
		if ((entry["visibility"] || ODYSSEY_CHRONICLE_VIS_PUBLIC) != ODYSSEY_CHRONICLE_VIS_PUBLIC)
			continue
		out += list(list(
			"title" = entry["title"],
			"at" = entry["at"],
			"shift" = entry["shift"],
			"body" = entry["body"]
		))
	return out


/proc/odyssey_briefing_dead_roster(limit = 24)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/out = list()
	if (!islist(state.roster))
		return out
	for (var/key in state.roster)
		var/list/entry = state.roster[key]
		if (!islist(entry) || entry["status"] != "dead")
			continue
		out += list(list(
			"name" = entry["name"] || "Unknown",
			"job" = entry["job"] || "Unknown",
			"death_shift" = entry["death_shift"],
			"death_reason" = entry["death_reason"]
		))
		if (length(out) >= limit)
			break
	return out


/proc/odyssey_briefing_shuttles()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/abandoned = list()
	var/list/damaged = list()
	if (islist(state.shuttle_reports))
		for (var/name in state.shuttle_reports)
			var/list/report = state.shuttle_reports[name]
			if (!islist(report))
				continue
			if (report["status"] == ODYSSEY_SHUTTLE_STATUS_ABANDONED)
				abandoned += name
			else if (report["status"] == ODYSSEY_SHUTTLE_STATUS_DAMAGED)
				damaged += list(list(
					"name" = name,
					"damage" = report["damage"],
					"repair_cost" = report["repair_cost"],
					"fee_pending" = !!report["fee_pending"]
				))
	else if (islist(state.abandoned_shuttles))
		abandoned = state.abandoned_shuttles.Copy()
	return list("abandoned" = abandoned, "damaged" = damaged)


/proc/odyssey_build_briefing_ui(min_visibility = ODYSSEY_CHRONICLE_VIS_PUBLIC)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/sector = odyssey_get_sector(state.current_sector_id, state)
	var/list/counts = odyssey_roster_counts(state.roster)
	var/list/shuttles = odyssey_briefing_shuttles()
	var/list/active_contracts = list()
	for (var/list/entry in odyssey_objectives_ui_entries(min_visibility))
		if (entry["scope"] == "campaign" && entry["status"] == ODYSSEY_OBJ_STATUS_ACTIVE)
			active_contracts += list(entry)
	var/list/active_objectives = list()
	for (var/list/entry in odyssey_objectives_ui_entries(min_visibility))
		if (entry["scope"] == "shift" && entry["status"] == ODYSSEY_OBJ_STATUS_ACTIVE)
			active_objectives += list(entry)

	var/course
	if (state.selected_sector_id)
		course = "Проложен курс на «[odyssey_sector_display_name(state.selected_sector_id)]»"
		if (state.selected_by)
			course += " (отметил: [state.selected_by])"
		if (state.transition_committed)
			course += " — прыжок утверждён, ожидается переход."
		else
			course += " — ожидает подтверждения на Bluespace Drive."
	else
		course = "Курс не выбран: смена, скорее всего, пройдёт в текущем секторе."

	var/personnel = "В журнале экспедиции: живых [counts["alive"]], погибших [counts["dead"]]"
	if (counts["dead_command"])
		personnel += " (в т.ч. командный состав: [counts["dead_command"]])"
	personnel += "."

	var/list/damaged_ui = list()
	for (var/list/row in shuttles["damaged"])
		if (!islist(row))
			continue
		var/line = "[row["name"]] — оценка ремонта [row["repair_cost"] || "?"] T"
		if (row["fee_pending"])
			line += " (списание с бюджета ожидает)"
		damaged_ui += list(list("name" = row["name"], "line" = line))

	return list(
		"active" = state.active,
		"shift" = state.shift_number,
		"echelon" = odyssey_campaign_echelon(state),
		"max_shifts" = state.max_shifts,
		"sector_id" = state.current_sector_id,
		"sector_name" = odyssey_sector_display_name(state.current_sector_id),
		"danger" = sector?["danger"],
		"danger_label" = odyssey_danger_label(sector?["danger"]),
		"summary" = sector?["summary"],
		"course" = course,
		"personnel" = personnel,
		"alive" = counts["alive"],
		"dead" = counts["dead"],
		"dead_command" = counts["dead_command"],
		"dead_roster" = odyssey_briefing_dead_roster(),
		"abandoned_shuttles" = shuttles["abandoned"],
		"damaged_shuttles" = damaged_ui,
		"headlines" = odyssey_briefing_headlines(),
		"contracts" = active_contracts,
		"objectives" = active_objectives,
		"science_briefs" = odyssey_science_active_briefs_ui(),
		"dept_briefs" = odyssey_dept_active_briefs_ui()
	)
