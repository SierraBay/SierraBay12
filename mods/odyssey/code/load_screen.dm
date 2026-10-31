/// Game-like Odyssey progress UI (load + roundend save): bar + per-step status.


/datum/odyssey_load_session
	var/list/steps = list() // list of {id, label, status, detail}
	var/percent = 0
	var/headline = "Подготовка…"
	var/subtitle = "Загрузка сохранения кампании"
	var/footer = "Пожалуйста, подождите. Экипаж появится после завершения загрузки."
	var/idle_headline = "Загрузка…"
	var/window_id = "odyssey_progress"
	var/finished = FALSE
	var/failed = FALSE
	var/last_ui_push = 0
	var/ui_dirty = FALSE
	/// kind → decoded JSON (or null if missing). Filled by validate, reused by apply.
	var/list/json_cache
	var/list/json_seen


/datum/odyssey_load_session/New()
	..()
	json_cache = list()
	json_seen = list()


/datum/odyssey_load_session/proc/add_step(id, label)
	steps += list(list(
		"id" = id,
		"label" = label,
		"status" = "pending",
		"detail" = null
	))


/datum/odyssey_load_session/proc/find_step(id)
	for (var/list/step in steps)
		if (step["id"] == id)
			return step
	return null


/datum/odyssey_load_session/proc/set_step(id, status, detail = null)
	var/list/step = find_step(id)
	if (!islist(step))
		return
	step["status"] = status
	if (!isnull(detail))
		step["detail"] = detail
	var/done = 0
	var/active_label = null
	for (var/list/S in steps)
		if (S["status"] == "done")
			done++
		else if (S["status"] == "active" || S["status"] == "error")
			active_label = S["label"]
			if (S["detail"])
				active_label = "[active_label] — [S["detail"]]"
	percent = length(steps) ? round(100 * done / length(steps)) : 0
	if (status == "error")
		failed = TRUE
		headline = "Ошибка: [active_label || id]"
	else if (finished)
		headline = "Готово"
		percent = 100
	else
		headline = active_label || idle_headline


/datum/odyssey_load_session/proc/build_html()
	var/list/rows = list()
	for (var/list/S in steps)
		var/mark
		var/color
		switch (S["status"])
			if ("done")
				mark = "✓"
				color = "#6dcf8a"
			if ("active")
				mark = "●"
				color = "#7ec8e3"
			if ("error")
				mark = "✗"
				color = "#e07070"
			else
				mark = "○"
				color = "#5a6570"
		var/extra = S["detail"] ? " <span style='opacity:0.75'>[html_encode(S["detail"])]</span>" : ""
		rows += "<li style='color:[color];margin:3px 0;font-size:13px'><b>[mark]</b> [html_encode(S["label"])][extra]</li>"

	return {"
<!DOCTYPE html>
<html><head><meta charset="utf-8"/>
<style>
body{margin:0;background:#0b1016;color:#d5dde6;font-family:'Segoe UI',Tahoma,sans-serif;}
.wrap{padding:28px 32px 24px;}
h1{margin:0 0 6px;font-size:22px;letter-spacing:0.12em;font-weight:600;color:#e8eef5;}
.sub{margin:0 0 18px;color:#8b98a8;font-size:13px;}
.bar{height:18px;background:#1a222c;border:1px solid #2c3846;border-radius:3px;overflow:hidden;}
.fill{height:100%;width:[percent]%;background:linear-gradient(90deg,#2f6f8f,#4aa3c7);}
.meta{display:flex;justify-content:space-between;margin:8px 0 16px;font-size:13px;color:#aeb9c6;}
.now{color:#9fd3ea;}
ul{list-style:none;margin:0;padding:0;max-height:300px;overflow:auto;}
.foot{margin-top:16px;font-size:12px;color:#6d7a88;}
</style></head>
<body><div class="wrap">
<h1>ОДИССЕЯ</h1>
<p class="sub">[html_encode(subtitle)]</p>
<div class="bar"><div class="fill"></div></div>
<div class="meta"><span class="now">[html_encode(headline)]</span><span>[percent]%</span></div>
<ul>
[jointext(rows, "")]
</ul>
<p class="foot">[html_encode(footer)]</p>
</div></body></html>
"}


/proc/odyssey_session_cached_json(datum/odyssey_load_session/session, kind, generation)
	if (!istype(session))
		return odyssey_read_json(odyssey_snapshot_path(kind, generation))
	if (!islist(session.json_cache))
		session.json_cache = list()
	if (!islist(session.json_seen))
		session.json_seen = list()
	if (session.json_seen[kind])
		return session.json_cache[kind]
	var/list/data = odyssey_read_json(odyssey_snapshot_path(kind, generation))
	session.json_seen[kind] = TRUE
	session.json_cache[kind] = data
	return data


/proc/odyssey_load_ui_push(datum/odyssey_load_session/session, force = FALSE)
	if (!istype(session))
		return
	if (!force && session.last_ui_push && (world.time < session.last_ui_push + ODYSSEY_LOAD_UI_INTERVAL))
		session.ui_dirty = TRUE
		return
	var/html = session.build_html()
	var/wid = session.window_id || "odyssey_progress"
	for (var/client/C in GLOB.clients)
		if (!C)
			continue
		show_browser(C, html, "window=[wid];size=720x560;can_close=0;can_minimize=0;can_resize=0;titlebar=1;focus=1")
	session.last_ui_push = world.time
	session.ui_dirty = FALSE


/proc/odyssey_load_ui_close(datum/odyssey_load_session/session = null)
	var/wid = istype(session) ? (session.window_id || "odyssey_progress") : "odyssey_progress"
	for (var/client/C in GLOB.clients)
		if (!C)
			continue
		close_browser(C, "window=[wid]")
		// Legacy window id from early load UI.
		close_browser(C, "window=odyssey_load")


/proc/odyssey_load_step(datum/odyssey_load_session/session, id, status, detail = null, force_ui = FALSE)
	if (!istype(session))
		return
	session.set_step(id, status, detail)
	var/force = force_ui || status == "error" || session.finished
	var/before = session.last_ui_push
	odyssey_load_ui_push(session, force)
	// Yield only when we actually refreshed the browse window.
	if (force || session.last_ui_push != before)
		stoplag(1)


/proc/odyssey_load_read_json(datum/odyssey_load_session/session, kind, generation)
	var/list/data = odyssey_session_cached_json(session, kind, generation)
	if (!islist(data))
		log_debug("ODYSSEY: load [kind] missing for generation=[generation]")
		return null
	var/n = islist(data["entries"]) ? length(data["entries"]) : (islist(data["data"]) ? length(data["data"]) : 0)
	log_debug("ODYSSEY: load [kind] entries/data=[n]")
	odyssey_load_step(session, kind, "active", "применение ([n])…")
	return data


/// Full continued-campaign bootstrap with loading UI. Safe to call once per round.
/proc/odyssey_bootstrap_continued_save(force = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if ((!state.active || !state.continued) && !force)
		return FALSE
	if (state.save_applied && !force)
		return TRUE

	var/datum/odyssey_load_session/session = new
	session.subtitle = "Загрузка сохранения кампании"
	session.footer = "Пожалуйста, подождите. Экипаж появится после завершения загрузки."
	session.idle_headline = "Загрузка…"
	session.add_step("validate", "Проверка сохранения")
	session.add_step("shuttles", "Брошенные шаттлы")
	session.add_step("baselines", "Снимок чистой карты (baseline)")
	session.add_step("turfs", "turfs.json")
	session.add_step("machinery", "machinery.json")
	session.add_step("structures", "structures.json")
	session.add_step("mechs", "mechs.json")
	session.add_step("strip_lanes", "Очистка карты (materials/items/…)")
	session.add_step("cleanables", "cleanables.json")
	session.add_step("papers", "papers.json")
	for (var/bucket in ODYSSEY_ITEM_BUCKETS)
		session.add_step(odyssey_item_snapshot_kind(bucket), "items_[bucket].json")
	session.add_step("items_nested", "Вложение предметов")
	session.add_step("economy", "economy.json")
	session.add_step("research", "research.json")
	session.add_step("newscast", "newscast.json")
	session.add_step("corpses", "corpses.json")
	session.add_step("remains", "remains.json")
	session.add_step("materials", "materials.json")
	session.add_step("chronicle", "chronicle.json")
	session.add_step("finish", "Завершение")

	odyssey_load_ui_push(session, TRUE)
	to_world(SPAN_NOTICE("<b>Одиссея: загрузка сохранения кампании…</b>"))
	odyssey_invalidate_persistable_turfs_cache()

	odyssey_load_step(session, "validate", "active", "meta и части снимка", TRUE)
	state.validation_errors = odyssey_validate_save(session)
	if (length(state.validation_errors))
		odyssey_load_step(session, "validate", "error", json_encode(state.validation_errors), TRUE)
		log_error("ODYSSEY: save validation failed: [json_encode(state.validation_errors)]")
		odyssey_invalidate_persistable_turfs_cache()
		sleep(2 SECONDS)
		odyssey_load_ui_close(session)
		return FALSE
	odyssey_load_step(session, "validate", "done")

	odyssey_load_step(session, "shuttles", "active")
	odyssey_apply_abandoned_shuttles()
	odyssey_load_step(session, "shuttles", "done")

	odyssey_load_step(session, "baselines", "active", "areas / turfs / objects / mechs")
	odyssey_ensure_persist_baselines()
	odyssey_load_step(session, "baselines", "done")

	var/list/meta = odyssey_load_meta()
	var/generation = islist(meta) ? meta["generation"] : state.save_generation
	if (generation)
		state.save_generation = generation

	var/list/turfs = odyssey_load_read_json(session, "turfs", generation)
	odyssey_apply_turfs(turfs?["entries"])
	odyssey_load_step(session, "turfs", "done", "готово")

	// Persist index was filled during the clean-map baseline walk. Turf swaps refresh their own tile.

	var/list/machinery = odyssey_load_read_json(session, "machinery", generation)
	odyssey_apply_machinery(machinery?["entries"])
	odyssey_load_step(session, "machinery", "done", "готово")

	var/list/structures = odyssey_load_read_json(session, "structures", generation)
	odyssey_apply_structures(structures?["entries"])
	odyssey_load_step(session, "structures", "done", "готово")

	var/list/mechs = odyssey_load_read_json(session, "mechs", generation)
	odyssey_apply_mechs(mechs?["entries"])
	odyssey_load_step(session, "mechs", "done", "готово")

	var/list/cleanables = odyssey_session_cached_json(session, "cleanables", generation)
	var/list/papers = odyssey_session_cached_json(session, "papers", generation)
	var/list/remains = odyssey_session_cached_json(session, "remains", generation)
	var/list/materials = odyssey_session_cached_json(session, "materials", generation)
	var/do_items = odyssey_items_snapshot_present(generation)
	odyssey_load_step(session, "strip_lanes", "active")
	// Materials always stripped on continue (DMM stacks would otherwise refill even without materials.json).
	odyssey_strip_persistable_lanes(
		strip_materials = TRUE,
		strip_cleanables = islist(cleanables),
		strip_papers = islist(papers),
		strip_items = do_items,
		strip_remains = islist(remains)
	)
	odyssey_load_step(session, "strip_lanes", "done")

	if (islist(cleanables))
		odyssey_load_step(session, "cleanables", "active", "применение…")
		odyssey_apply_cleanables(cleanables["entries"])
		odyssey_load_step(session, "cleanables", "done", "готово")
	else
		odyssey_load_step(session, "cleanables", "done", "нет файла — пропуск")

	if (islist(papers))
		odyssey_load_step(session, "papers", "active", "применение…")
		var/papers_generation = papers["generation"] || state.save_generation || generation
		odyssey_apply_papers(papers["entries"], papers_generation)
		odyssey_load_step(session, "papers", "done", "готово")
	else
		odyssey_load_step(session, "papers", "done", "нет файла — пропуск")

	var/list/item_created = list()
	var/list/item_deferred = list()
	for (var/bucket in ODYSSEY_ITEM_BUCKETS)
		var/kind = odyssey_item_snapshot_kind(bucket)
		var/list/bucket_data = odyssey_load_read_json(session, kind, generation)
		if (islist(bucket_data))
			var/n = odyssey_apply_item_bucket_roots(bucket_data["entries"], item_created, item_deferred)
			odyssey_load_step(session, kind, "done", "готово ([n])")
		else
			odyssey_load_step(session, kind, "done", "нет файла — пропуск")

	odyssey_load_step(session, "items_nested", "active")
	var/nested = odyssey_apply_deferred_items(item_deferred, item_created)
	odyssey_load_step(session, "items_nested", "done", "готово ([nested])")

	odyssey_clear_persist_index()

	var/list/economy = odyssey_load_read_json(session, "economy", generation)
	odyssey_apply_economy(economy?["data"])
	odyssey_load_step(session, "economy", "done", "готово")

	var/list/research = odyssey_load_read_json(session, "research", generation)
	odyssey_apply_research(research?["data"])
	odyssey_load_step(session, "research", "done", "готово")

	var/list/newscast = odyssey_load_read_json(session, "newscast", generation)
	odyssey_apply_newscast(newscast?["data"], state.save_generation)
	odyssey_load_step(session, "newscast", "done", "готово")

	var/list/corpses = odyssey_load_read_json(session, "corpses", generation)
	odyssey_apply_corpses(corpses?["entries"])
	odyssey_load_step(session, "corpses", "done", "готово")

	if (islist(remains))
		odyssey_load_step(session, "remains", "active", "применение…")
		odyssey_apply_remains(remains["entries"])
		odyssey_load_step(session, "remains", "done", "готово")
	else
		odyssey_load_step(session, "remains", "done", "нет файла — пропуск")

	if (islist(materials))
		odyssey_load_step(session, "materials", "active", "применение…")
		odyssey_apply_materials(materials["entries"])
		odyssey_load_step(session, "materials", "done", "готово")
	else
		odyssey_load_step(session, "materials", "done", "нет файла — пропуск")

	var/list/chronicle = odyssey_load_read_json(session, "chronicle", generation)
	odyssey_apply_chronicle(chronicle?["entries"], force)
	odyssey_load_step(session, "chronicle", "done", "готово")

	odyssey_load_step(session, "finish", "active")
	state.save_applied = TRUE
	session.finished = TRUE
	odyssey_load_step(session, "finish", "done", null, TRUE)
	log_game("ODYSSEY: applied save campaign=[state.campaign_id] shift=[state.shift_number] force=[force]")
	to_world(SPAN_NOTICE("<b>Одиссея: сохранение загружено.</b>"))
	odyssey_invalidate_persistable_turfs_cache()
	if (session.ui_dirty)
		odyssey_load_ui_push(session, TRUE)
	sleep(0.3 SECONDS)
	odyssey_load_ui_close(session)
	return TRUE
