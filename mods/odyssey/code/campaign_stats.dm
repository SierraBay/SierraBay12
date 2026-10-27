/// End-of-campaign statistics for Odyssey.

/proc/odyssey_task_status_bucket(status)
	switch (status)
		if (ODYSSEY_OBJ_STATUS_COMPLETED)
			return "completed"
		if (ODYSSEY_OBJ_STATUS_FAILED)
			return "failed"
		if (ODYSSEY_OBJ_STATUS_EXPIRED)
			return "expired"
		if (ODYSSEY_OBJ_STATUS_ACTIVE)
			return "active"
	return "other"


/proc/odyssey_tally_task_list(list/entries)
	var/list/out = list(
		"completed" = 0,
		"failed" = 0,
		"expired" = 0,
		"active" = 0,
		"other" = 0,
		"total" = 0,
		"titles_completed" = list(),
		"titles_failed" = list(),
		"titles_expired" = list(),
		"titles_active" = list()
	)
	if (!islist(entries))
		return out
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		out["total"]++
		var/bucket = odyssey_task_status_bucket(entry["status"])
		out[bucket]++
		var/title = entry["title"] || entry["id"] || "?"
		switch (bucket)
			if ("completed")
				out["titles_completed"] += title
			if ("failed")
				out["titles_failed"] += title
			if ("expired")
				out["titles_expired"] += title
			if ("active")
				out["titles_active"] += title
	return out


/proc/odyssey_build_route_stats(list/route_ids, list/graph = null)
	var/list/out = list()
	if (!islist(route_ids))
		return out
	for (var/id in route_ids)
		var/name = id
		if (islist(graph) && islist(graph[id]) && graph[id]["name"])
			name = graph[id]["name"]
		else
			name = odyssey_sector_display_name(id)
		out += list(list("id" = id, "name" = name))
	return out


/proc/odyssey_build_casualty_stats(list/roster)
	var/list/dead = list()
	if (!islist(roster))
		return dead
	for (var/key in roster)
		var/list/entry = roster[key]
		if (!islist(entry) || entry["status"] != "dead")
			continue
		dead += list(list(
			"name" = entry["name"] || "Unknown",
			"job" = entry["job"] || "?",
			"death_shift" = entry["death_shift"]
		))
	return dead


/proc/odyssey_build_campaign_stats(status = null, reason = null)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/R = odyssey_research_ensure()
	var/list/roster = length(state.roster) ? state.roster : odyssey_load_roster()
	var/list/counts = odyssey_roster_counts(roster)

	var/list/stats = list(
		"status" = status || state.status,
		"reason" = reason || state.outcome_reason,
		"campaign_id" = state.campaign_id,
		"shifts" = state.shift_number,
		"max_shifts" = state.max_shifts,
		"route" = odyssey_build_route_stats(state.route_history, state.sector_graph),
		"alive" = counts["alive"],
		"dead" = counts["dead"],
		"dead_command" = counts["dead_command"],
		"casualties" = odyssey_build_casualty_stats(roster),
		"abandoned_shuttles" = islist(state.abandoned_shuttles) ? state.abandoned_shuttles.Copy() : list(),
		"contracts" = odyssey_tally_task_list(state.contracts),
		"objectives" = odyssey_tally_task_list(state.objectives),
		"science_briefs" = odyssey_tally_task_list(R["active_briefs"]),
		"dept_briefs" = odyssey_tally_task_list(R["dept_briefs"]),
		"built_at" = time2text(world.realtime, "YYYY-MM-DD hh:mm")
	)
	return stats


/proc/odyssey_campaign_stats_text(list/stats, html = FALSE)
	if (!islist(stats))
		return "Нет статистики Одиссеи."
	var/br = html ? "<br>" : "\n"
	var/list/lines = list()
	lines += "=== Итоги Одиссеи ==="
	lines += "Исход: [odyssey_lobby_outcome_ic(stats["status"])]"
	if (stats["reason"])
		lines += "Причина: [stats["reason"]]"
	lines += "Смен пройдено: [stats["shifts"]] / [stats["max_shifts"]]"
	lines += "Живых: [stats["alive"]] · Погибших: [stats["dead"]][stats["dead_command"] ? " (командный: [stats["dead_command"]])" : ""]"

	var/list/route = stats["route"]
	if (islist(route) && length(route))
		var/list/names = list()
		for (var/list/node in route)
			if (islist(node))
				names += (node["name"] || node["id"])
		lines += "Маршрут: [jointext(names, " → ")]"

	var/list/abandoned = stats["abandoned_shuttles"]
	if (islist(abandoned) && length(abandoned))
		lines += "Утерянные шаттлы: [english_list(abandoned)]"
	else
		lines += "Утерянные шаттлы: нет"

	lines += odyssey_campaign_stats_task_block("Контракты", stats["contracts"])
	lines += odyssey_campaign_stats_task_block("Цели смен", stats["objectives"])
	lines += odyssey_campaign_stats_task_block("Научные брифы", stats["science_briefs"])
	lines += odyssey_campaign_stats_task_block("Брифы отделов", stats["dept_briefs"])

	var/list/casualties = stats["casualties"]
	if (islist(casualties) && length(casualties))
		lines += "Потери:"
		var/shown = 0
		for (var/list/row in casualties)
			if (!islist(row))
				continue
			var/line = "  • [row["name"]] — [row["job"]]"
			if (row["death_shift"])
				line += " (смена [row["death_shift"]])"
			lines += line
			shown++
			if (shown >= 24)
				lines += "  • …и другие ([length(casualties) - shown] не показаны)"
				break
	else
		lines += "Потери: нет"

	return jointext(lines, br)


/proc/odyssey_campaign_stats_task_block(label, list/tally)
	if (!islist(tally))
		return "[label]: нет данных"
	var/line = "[label]: выполнено [tally["completed"] || 0], провалено [tally["failed"] || 0], истекло [tally["expired"] || 0], активных на конец [tally["active"] || 0] (всего [tally["total"] || 0])"
	return line


/proc/odyssey_campaign_stats_html(list/stats)
	if (!islist(stats))
		return "<p><i>Нет статистики Одиссеи.</i></p>"
	var/list/dat = list()
	dat += "<h3 style='color:#85bab6; border-bottom:1px solid #335555; padding-bottom:4px;'>Итоги экспедиции</h3>"
	dat += "<p><b>[html_encode(odyssey_lobby_outcome_ic(stats["status"]))]</b>"
	if (stats["reason"])
		dat += "<br><span style='color:#889999;'>[html_encode("[stats["reason"]]")]</span>"
	dat += "</p>"
	dat += "<p>Смен: <b>[stats["shifts"]]</b> / [stats["max_shifts"]] · "
	dat += "живых <b>[stats["alive"]]</b>, погибших <b>[stats["dead"]]</b>"
	if (stats["dead_command"])
		dat += " (командный: [stats["dead_command"]])"
	dat += ".</p>"

	var/list/route = stats["route"]
	if (islist(route) && length(route))
		var/list/names = list()
		for (var/list/node in route)
			if (islist(node))
				names += html_encode("[node["name"] || node["id"]]")
		dat += "<p><b>Маршрут:</b> [jointext(names, " → ")]</p>"

	var/list/abandoned = stats["abandoned_shuttles"]
	if (islist(abandoned) && length(abandoned))
		dat += "<p><b>Утерянные шаттлы:</b> [html_encode(english_list(abandoned))]</p>"

	dat += odyssey_campaign_stats_html_tasks("Контракты", stats["contracts"])
	dat += odyssey_campaign_stats_html_tasks("Цели смен", stats["objectives"])
	dat += odyssey_campaign_stats_html_tasks("Научные брифы", stats["science_briefs"])
	dat += odyssey_campaign_stats_html_tasks("Брифы отделов", stats["dept_briefs"])

	var/list/casualties = stats["casualties"]
	if (islist(casualties) && length(casualties))
		dat += "<p><b>Потери:</b></p><ul style='margin-top:0;'>"
		var/shown = 0
		for (var/list/row in casualties)
			if (!islist(row))
				continue
			dat += "<li>[html_encode("[row["name"]]")] — [html_encode("[row["job"]]")]"
			if (row["death_shift"])
				dat += " <span style='color:#889999;'>(смена [row["death_shift"]])</span>"
			dat += "</li>"
			shown++
			if (shown >= 24)
				dat += "<li><i>…и другие.</i></li>"
				break
		dat += "</ul>"
	return jointext(dat, null)


/proc/odyssey_campaign_stats_html_tasks(label, list/tally)
	if (!islist(tally) || !(tally["total"]))
		return "<p><b>[html_encode(label)]:</b> <i>нет</i></p>"
	var/list/dat = list()
	dat += "<p><b>[html_encode(label)]:</b> "
	dat += "выполнено <b>[tally["completed"] || 0]</b>, "
	dat += "провалено <b>[tally["failed"] || 0]</b>, "
	dat += "истекло <b>[tally["expired"] || 0]</b>"
	if (tally["active"])
		dat += ", незакрытых <b>[tally["active"]]</b>"
	dat += ".</p>"
	if (length(tally["titles_completed"]))
		dat += "<p style='margin-left:8px; color:#a8c0bc;'>✓ [html_encode(english_list(tally["titles_completed"]))]</p>"
	if (length(tally["titles_failed"]))
		dat += "<p style='margin-left:8px; color:#c09090;'>✗ [html_encode(english_list(tally["titles_failed"]))]</p>"
	return jointext(dat, null)


/proc/odyssey_publish_campaign_stats(status, reason)
	var/list/stats = odyssey_build_campaign_stats(status, reason)
	var/text = odyssey_campaign_stats_text(stats, FALSE)
	odyssey_chronicle_append(
		ODYSSEY_CHRONICLE_KIND_OUTCOME,
		"Итоги Одиссеи",
		text,
		ODYSSEY_CHRONICLE_VIS_PUBLIC,
		list("kind" = "campaign_stats", "status" = status)
	)
	priority_announcement.Announce("Odyssey campaign closed. Full expedition statistics have been entered into the public chronicle.", "Odyssey Command")
	return stats
