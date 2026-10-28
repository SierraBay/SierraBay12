/// End-of-campaign statistics for Odyssey.

var/global/list/odyssey_last_campaign_stats
var/global/odyssey_show_roundend_stats = FALSE

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
			"death_shift" = entry["death_shift"],
			"death_reason" = entry["death_reason"]
		))
	return dead


/proc/odyssey_stats_type_label(path_text)
	if (!istext(path_text) || !length(path_text))
		return "?"
	var/pos = findlasttext(path_text, "/")
	if (pos)
		return copytext(path_text, pos + 1)
	return path_text


/proc/odyssey_tally_persist_actions(list/entries)
	var/list/out = list(
		"created" = 0,
		"destroyed" = 0,
		"modified" = 0,
		"moved" = 0,
		"other" = 0,
		"total" = 0
	)
	if (!islist(entries))
		return out
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		out["total"]++
		var/action = entry["action"]
		switch (action)
			if ("created")
				out["created"]++
			if ("destroyed")
				out["destroyed"]++
			if ("modified")
				out["modified"]++
			if ("moved")
				out["moved"]++
			else
				out["other"]++
	return out


/proc/odyssey_stats_snapshot_entries(kind)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/generation = state.save_generation
	if (!generation)
		return null
	var/list/data = odyssey_read_json(odyssey_snapshot_path(kind, generation))
	if (!islist(data))
		return null
	return data["entries"]


/proc/odyssey_build_mech_stats()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/entries = odyssey_collect_mechs()
	var/list/created = list()
	var/list/destroyed = list()
	var/list/surviving = list()
	var/modified = 0
	var/moved = 0
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		var/action = entry["action"]
		var/list/baseline = entry["id"] ? state.mech_baseline?[entry["id"]] : null
		var/type_text = entry["type"] || (islist(baseline) ? baseline["type"] : null)
		var/label = entry["name"]
		if (!label)
			label = odyssey_stats_type_label(type_text)
		if (!label)
			label = entry["id"] || "?"
		var/row = list(
			"name" = label,
			"type" = type_text,
			"action" = action,
			"id" = entry["id"]
		)
		switch (action)
			if ("created")
				created += list(row)
				surviving += list(row)
			if ("destroyed")
				destroyed += list(row)
			if ("modified")
				modified++
				surviving += list(row)
			if ("moved")
				moved++
				surviving += list(row)
	return list(
		"counts" = list(
			"created" = length(created),
			"destroyed" = length(destroyed),
			"modified" = modified,
			"moved" = moved,
			"surviving" = length(surviving),
			"total" = length(entries)
		),
		"created" = created,
		"destroyed" = destroyed,
		"surviving" = surviving
	)


/proc/odyssey_build_economy_stats()
	var/list/data = odyssey_collect_economy()
	var/list/out = list(
		"station_money" = null,
		"departments" = list()
	)
	if (islist(data["station"]))
		out["station_money"] = data["station"]["money"]
	var/list/departments = data["departments"]
	if (islist(departments))
		for (var/dept in departments)
			var/list/entry = departments[dept]
			if (!islist(entry))
				continue
			out["departments"] += list(list("name" = dept, "money" = entry["money"]))
	return out


/proc/odyssey_build_damage_stats()
	var/list/turf_entries = odyssey_stats_snapshot_entries("turfs")
	var/list/mach_entries = odyssey_stats_snapshot_entries("machinery")
	var/list/struct_entries = odyssey_stats_snapshot_entries("structures")
	if (!islist(mach_entries))
		mach_entries = odyssey_collect_machinery()
	if (!islist(struct_entries))
		struct_entries = odyssey_collect_structures()
	return list(
		"turfs" = odyssey_tally_persist_actions(turf_entries),
		"machinery" = odyssey_tally_persist_actions(mach_entries),
		"structures" = odyssey_tally_persist_actions(struct_entries),
		"from_save" = !!islist(turf_entries)
	)


/proc/odyssey_build_shuttle_stats()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/abandoned = islist(state.abandoned_shuttles) ? state.abandoned_shuttles.Copy() : list()
	var/list/damaged = list()
	if (islist(state.shuttle_reports))
		for (var/name in state.shuttle_reports)
			var/list/report = state.shuttle_reports[name]
			if (!islist(report))
				continue
			if (report["status"] == ODYSSEY_SHUTTLE_STATUS_DAMAGED)
				damaged += list(list(
					"name" = name,
					"damage" = report["damage"],
					"repair_cost" = report["repair_cost"]
				))
	return list("abandoned" = abandoned, "damaged" = damaged)


/proc/odyssey_build_research_stats(list/R)
	if (!islist(R))
		R = odyssey_research_ensure()
	return list(
		"samples" = length(R["samples_collected"]),
		"anomalies" = length(R["anomalies_catalogued"]),
		"notes" = length(R["sector_notes"])
	)


/proc/odyssey_build_campaign_stats(status = null, reason = null)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/R = odyssey_research_ensure()
	var/list/roster = length(state.roster) ? state.roster : odyssey_load_roster()
	var/list/counts = odyssey_roster_counts(roster)
	var/list/shuttles = odyssey_build_shuttle_stats()

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
		"abandoned_shuttles" = shuttles["abandoned"],
		"damaged_shuttles" = shuttles["damaged"],
		"contracts" = odyssey_tally_task_list(state.contracts),
		"objectives" = odyssey_tally_task_list(state.objectives),
		"science_briefs" = odyssey_tally_task_list(R["active_briefs"]),
		"dept_briefs" = odyssey_tally_task_list(R["dept_briefs"]),
		"mechs" = odyssey_build_mech_stats(),
		"economy" = odyssey_build_economy_stats(),
		"damage" = odyssey_build_damage_stats(),
		"research" = odyssey_build_research_stats(R),
		"chronicle_events" = islist(state.chronicle) ? length(state.chronicle) : 0,
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

	var/list/mechs = stats["mechs"]
	if (islist(mechs) && islist(mechs["counts"]))
		var/list/mc = mechs["counts"]
		lines += "Мехи: создано [mc["created"] || 0], уничтожено [mc["destroyed"] || 0], изменено [mc["modified"] || 0], перемещено [mc["moved"] || 0], на борту [mc["surviving"] || 0]"

	var/list/damage = stats["damage"]
	if (islist(damage))
		var/list/turfs = damage["turfs"]
		var/list/mach = damage["machinery"]
		var/list/structs = damage["structures"]
		if (islist(turfs) || islist(mach) || islist(structs))
			lines += "Повреждения/дельты: турфы [islist(turfs) ? (turfs["total"] || 0) : 0], машины [islist(mach) ? (mach["total"] || 0) : 0], структуры [islist(structs) ? (structs["total"] || 0) : 0]"

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
			if (shown >= 40)
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


/proc/odyssey_campaign_stats_html_list(label, list/rows, name_key = "name", extra_key = null, limit = 40)
	if (!islist(rows) || !length(rows))
		return "<p><b>[html_encode(label)]:</b> <i>нет</i></p>"
	var/list/dat = list()
	dat += "<p><b>[html_encode(label)]</b> ([length(rows)]):</p><ul style='margin-top:0;'>"
	var/shown = 0
	for (var/list/row in rows)
		if (!islist(row))
			continue
		dat += "<li>[html_encode("[row[name_key] || "?"]")]"
		if (extra_key && row[extra_key])
			dat += " — [html_encode("[row[extra_key]]")]"
		dat += "</li>"
		shown++
		if (shown >= limit)
			dat += "<li><i>…и другие ([length(rows) - shown]).</i></li>"
			break
	dat += "</ul>"
	return jointext(dat, null)


/proc/odyssey_campaign_stats_html(list/stats)
	if (!islist(stats))
		return "<p><i>Нет статистики Одиссеи.</i></p>"
	var/list/dat = list()
	dat += "<div style='font-family:Verdana,sans-serif; font-size:13px; line-height:1.35;'>"
	dat += "<h2 style='color:#85bab6; border-bottom:1px solid #335555; padding-bottom:4px; margin-top:0;'>Итоги экспедиции Одиссея</h2>"
	dat += "<p><b>[html_encode(odyssey_lobby_outcome_ic(stats["status"]))]</b>"
	if (stats["reason"])
		dat += "<br><span style='color:#889999;'>[html_encode("[stats["reason"]]")]</span>"
	if (stats["campaign_id"])
		dat += "<br><span style='color:#667777; font-size:11px;'>ID: [html_encode("[stats["campaign_id"]]")] · [html_encode("[stats["built_at"] || ""]")]</span>"
	dat += "</p>"
	dat += "<p>Смен: <b>[stats["shifts"]]</b> / [stats["max_shifts"]] · "
	dat += "живых <b>[stats["alive"]]</b>, погибших <b>[stats["dead"]]</b>"
	if (stats["dead_command"])
		dat += " (командный: [stats["dead_command"]])"
	dat += " · событий хроники: <b>[stats["chronicle_events"] || 0]</b>.</p>"

	var/list/route = stats["route"]
	if (islist(route) && length(route))
		var/list/names = list()
		for (var/list/node in route)
			if (islist(node))
				names += html_encode("[node["name"] || node["id"]]")
		dat += "<p><b>Маршрут:</b> [jointext(names, " → ")]</p>"

	dat += "<h3 style='color:#9ab8b4; margin-bottom:4px;'>Шаттлы</h3>"
	var/list/abandoned = stats["abandoned_shuttles"]
	if (islist(abandoned) && length(abandoned))
		dat += "<p><b>Утерянные:</b> [html_encode(english_list(abandoned))]</p>"
	else
		dat += "<p><b>Утерянные:</b> <i>нет</i></p>"
	var/list/damaged = stats["damaged_shuttles"]
	if (islist(damaged) && length(damaged))
		dat += "<ul style='margin-top:0;'>"
		for (var/list/row in damaged)
			if (!islist(row))
				continue
			dat += "<li>[html_encode("[row["name"]]")] — урон [row["damage"] || "?"], ремонт [row["repair_cost"] || "?"] ₮</li>"
		dat += "</ul>"

	dat += "<h3 style='color:#9ab8b4; margin-bottom:4px;'>Задачи</h3>"
	dat += odyssey_campaign_stats_html_tasks("Контракты", stats["contracts"])
	dat += odyssey_campaign_stats_html_tasks("Цели смен", stats["objectives"])
	dat += odyssey_campaign_stats_html_tasks("Научные брифы", stats["science_briefs"])
	dat += odyssey_campaign_stats_html_tasks("Брифы отделов", stats["dept_briefs"])

	var/list/research = stats["research"]
	if (islist(research))
		dat += "<p><b>Исследования:</b> образцов [research["samples"] || 0], аномалий [research["anomalies"] || 0], заметок [research["notes"] || 0].</p>"

	dat += "<h3 style='color:#9ab8b4; margin-bottom:4px;'>Мехи</h3>"
	var/list/mechs = stats["mechs"]
	if (islist(mechs) && islist(mechs["counts"]))
		var/list/mc = mechs["counts"]
		dat += "<p>Создано <b>[mc["created"] || 0]</b>, уничтожено <b>[mc["destroyed"] || 0]</b>, "
		dat += "изменено <b>[mc["modified"] || 0]</b>, перемещено <b>[mc["moved"] || 0]</b>, "
		dat += "на борту к концу <b>[mc["surviving"] || 0]</b>.</p>"
		dat += odyssey_campaign_stats_html_list("Собранные / новые", mechs["created"])
		dat += odyssey_campaign_stats_html_list("Уничтоженные", mechs["destroyed"])
		dat += odyssey_campaign_stats_html_list("Оставшиеся на борту", mechs["surviving"])
	else
		dat += "<p><i>Нет данных по мехам.</i></p>"

	dat += "<h3 style='color:#9ab8b4; margin-bottom:4px;'>Повреждения судна</h3>"
	var/list/damage = stats["damage"]
	if (islist(damage))
		if (!damage["from_save"])
			dat += "<p style='color:#889999; font-size:11px;'>Сводка турфов из последнего сейва недоступна; машины/структуры посчитаны по состоянию на момент завершения.</p>"
		for (var/kind in list("turfs", "machinery", "structures"))
			var/list/tally = damage[kind]
			var/label = kind
			switch (kind)
				if ("turfs")
					label = "Турфы"
				if ("machinery")
					label = "Машины"
				if ("structures")
					label = "Структуры"
			if (!islist(tally) || !(tally["total"]))
				dat += "<p><b>[label]:</b> <i>без дельт</i></p>"
				continue
			dat += "<p><b>[label]:</b> всего [tally["total"]], создано [tally["created"] || 0], уничтожено [tally["destroyed"] || 0], изменено [tally["modified"] || 0], перемещено [tally["moved"] || 0].</p>"
	else
		dat += "<p><i>Нет данных о повреждениях.</i></p>"

	dat += "<h3 style='color:#9ab8b4; margin-bottom:4px;'>Экономика</h3>"
	var/list/economy = stats["economy"]
	if (islist(economy))
		if (!isnull(economy["station_money"]))
			dat += "<p><b>Счёт судна:</b> [economy["station_money"]] ₮</p>"
		var/list/depts = economy["departments"]
		if (islist(depts) && length(depts))
			dat += "<ul style='margin-top:0;'>"
			for (var/list/row in depts)
				if (!islist(row))
					continue
				dat += "<li>[html_encode("[row["name"]]")]: <b>[row["money"]]</b> ₮</li>"
			dat += "</ul>"
	else
		dat += "<p><i>Нет данных по счетам.</i></p>"

	dat += "<h3 style='color:#9ab8b4; margin-bottom:4px;'>Потери экипажа</h3>"
	var/list/casualties = stats["casualties"]
	if (islist(casualties) && length(casualties))
		dat += "<ul style='margin-top:0;'>"
		var/shown = 0
		for (var/list/row in casualties)
			if (!islist(row))
				continue
			dat += "<li>[html_encode("[row["name"]]")] — [html_encode("[row["job"]]")]"
			if (row["death_shift"])
				dat += " <span style='color:#889999;'>(смена [row["death_shift"]])</span>"
			if (row["death_reason"])
				dat += " <span style='color:#778888;'>\[[html_encode("[row["death_reason"]]")]\]</span>"
			dat += "</li>"
			shown++
			if (shown >= 60)
				dat += "<li><i>…и другие ([length(casualties) - shown]).</i></li>"
				break
		dat += "</ul>"
	else
		dat += "<p><i>Потерь не зафиксировано.</i></p>"
	dat += "</div>"
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


/proc/odyssey_campaign_stats_chat_summary(list/stats)
	if (!islist(stats))
		return null
	var/singleton/modpack/odyssey/pack = GET_SINGLETON(/singleton/modpack/odyssey)
	var/list/lines = list()
	lines += "<br><br><br><b>ODYSSEY STATISTIC.</b>"
	lines += "<br>Исход: [html_encode(odyssey_lobby_outcome_ic(stats["status"]))]."
	if (stats["reason"])
		lines += "<br>Причина: [html_encode("[stats["reason"]]")]."
	lines += "<br>Смен пройдено: [stats["shifts"]] / [stats["max_shifts"]]. Живых: [stats["alive"]], погибших: [stats["dead"]]"
	if (stats["dead_command"])
		lines += " (командный: [stats["dead_command"]])"
	lines += "."
	var/list/contracts = stats["contracts"]
	var/list/objectives = stats["objectives"]
	if (islist(contracts) || islist(objectives))
		lines += "<br>Контракты: выполнено [islist(contracts) ? (contracts["completed"] || 0) : 0]. Цели смен: выполнено [islist(objectives) ? (objectives["completed"] || 0) : 0]."
	var/list/mechs = stats["mechs"]
	if (islist(mechs) && islist(mechs["counts"]))
		var/list/mc = mechs["counts"]
		lines += "<br>Мехи: создано [mc["created"] || 0], уничтожено [mc["destroyed"] || 0], на борту [mc["surviving"] || 0]."
	lines += "<br><a href='byond://?src=\ref[pack];show_odyssey_stats=1'>\[Показать подробную статистику\]</a>"
	return jointext(lines, null)


/proc/odyssey_announce_campaign_stats_chat(list/stats)
	if (!islist(stats))
		return
	odyssey_last_campaign_stats = stats
	odyssey_show_roundend_stats = TRUE
	var/summary = odyssey_campaign_stats_chat_summary(stats)
	if (summary)
		to_chat(world, summary)


/proc/odyssey_roundend_text()
	if (!odyssey_show_roundend_stats || !islist(odyssey_last_campaign_stats))
		return null
	return odyssey_campaign_stats_chat_summary(odyssey_last_campaign_stats)


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
	odyssey_announce_campaign_stats_chat(stats)
	priority_announcement.Announce("Экспедиция Одиссеи завершена. Итоги записаны в хронику и выведены в статистику.", "Odyssey Command")
	return stats
