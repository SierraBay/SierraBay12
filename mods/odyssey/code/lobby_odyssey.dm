/// Lobby titlescreen: Odyssey status colour + IC expedition briefing popup.

/datum/map/update_titlescreen_odyssey(client/C)
	if (isnull(C))
		return
	send_output(C, "[odyssey_lobby_button_active() ? 1 : 0]", "lobbybrowser:setOdysseyStatus")


/proc/odyssey_lobby_button_active()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.active)
		return TRUE
	return odyssey_campaign_exists()


/proc/odyssey_refresh_lobby_titlescreens()
	if (!istype(GLOB.using_map))
		return
	GLOB.using_map.update_titlescreens()


/mob/new_player/lobby_open_odyssey_panel()
	if (!client || !check_rights(R_ADMIN|R_DEBUG|R_SERVER, FALSE, client))
		to_chat(src, SPAN_WARNING("Недостаточно прав для Odyssey Panel."))
		return
	client.odyssey_panel()


/mob/new_player/lobby_start_odyssey_vote()
	if (odyssey_try_start_lobby_vote(src))
		to_chat(src, SPAN_NOTICE("Голосование по Одиссее запущено. Откройте Vote, чтобы проголосовать."))
		lobby_show_odyssey()


/proc/odyssey_lobby_vote_section_html(mob/user)
	var/list/dat = list()
	dat += "<h3 style='color:#85bab6; border-bottom:1px solid #335555; padding-bottom:4px;'>Голосование</h3>"

	if (GAME_STATE != RUNLEVEL_LOBBY)
		dat += "<p><i>Голосование доступно только в лобби до старта раунда.</i></p>"
		return jointext(dat, null)

	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.active)
		dat += "<p><i>Экспедиция уже включена в этом раунде — голосование не требуется.</i></p>"
		return jointext(dat, null)

	if (SSvote?.active_vote)
		var/vote_name = SSvote.active_vote.name || "голосование"
		dat += "<p>Сейчас идёт: <b>[html_encode(vote_name)]</b>.</p>"
		dat += "<p><a href='byond://?src=\ref[SSvote];vote_panel=1'><b>Открыть окно Vote</b></a></p>"
		return jointext(dat, null)

	var/has_campaign = odyssey_campaign_exists()
	var/list/lobby = SSticker?.lobby_players()
	var/players = length(lobby)
	dat += "<p>В лобби игроков: <b>[players]</b>. Для решения нужно минимум <b>[ODYSSEY_MIN_YES_VOTES]</b> голосов «За», и их должно быть больше, чем «Против».</p>"

	if (has_campaign)
		dat += "<p>На диске есть незавершённый маршрут. Можно предложить экипажу <b>продолжить</b> Одиссею"
		if (players < ODYSSEY_MIN_CONTINUE_PLAYERS)
			dat += " (нужно ≥ [ODYSSEY_MIN_CONTINUE_PLAYERS] в лобби"
			if (isadmin(user))
				dat += "; админ может запустить раньше"
			dat += ")"
		dat += ".</p>"
		if (players >= ODYSSEY_MIN_CONTINUE_PLAYERS || isadmin(user))
			dat += "<p><a href='?src=\ref[user];lobby_odyssey_vote=1'><b>Начать голосование: продолжить Одиссею</b></a></p>"
		else
			dat += "<p><i>Кнопка голосования станет доступна при [ODYSSEY_MIN_CONTINUE_PLAYERS]+ игроках в лобби.</i></p>"
	else
		var/list/meta = odyssey_load_meta()
		if (islist(meta) && !meta["active"])
			dat += "<p>Последняя экспедиция закрыта в журнале. Можно предложить <b>новую</b> Одиссею.</p>"
		else
			dat += "<p>Активного маршрута нет. Можно предложить экипажу <b>начать</b> новую Одиссею.</p>"
		dat += "<p><a href='?src=\ref[user];lobby_odyssey_vote=1'><b>Начать голосование: новая Одиссея</b></a></p>"

	return jointext(dat, null)


/proc/odyssey_lobby_status_phrase(list/meta, datum/odyssey_state/state)
	if (state?.active)
		return state.continued \
			? "Экспедиция продолжается. Сьерра уже в пути — следующая смена готовится к дежурству." \
			: "Экспедиция утверждена. Корабль готовится к выходу в первый сектор маршрута."
	if (islist(meta) && meta["active"])
		return "На борту есть незавершённый маршрут Одиссеи. Командование может возобновить экспедицию на этой смене."
	if (islist(meta))
		return "Последняя Одиссея закрыта в бортовом журнале. Новый маршрут пока не открыт."
	return "Одиссея не объявлена. NSV Sierra следует обычному расписанию, пока командование не утвердит экспедицию."


/proc/odyssey_lobby_outcome_ic(status)
	switch (status)
		if (ODYSSEY_STATUS_COMPLETED)
			return "Маршрут завершён успешно — финальный сектор достигнут."
		if (ODYSSEY_STATUS_RETURNED)
			return "Экспедиция свёрнута: корабль взял курс домой."
		if (ODYSSEY_STATUS_EVACUATED)
			return "Экспедиция прервана аварийной эвакуацией."
		if (ODYSSEY_STATUS_SHIP_DESTROYED)
			return "Сьерра потеряна. Экспедиция окончена катастрофой."
		if (ODYSSEY_STATUS_CREW_LOST)
			return "Живой состав экспедиции исчерпан. Маршрут закрыт."
		if (ODYSSEY_STATUS_ADMIN_ABORTED)
			return "Экспедиция снята с повестки командованием флота."
	return "Экспедиция более не числится активной."


/// Rich IC HTML briefing for the lobby Odyssey button (and similar surfaces).
/proc/odyssey_lobby_briefing_html(list/meta, datum/odyssey_state/state = null)
	if (!istype(state))
		state = odyssey_ensure_state()
	if (!islist(meta) && state.active)
		meta = odyssey_state_meta(TRUE, state.save_generation)
	if (!islist(meta))
		meta = odyssey_load_meta()

	var/list/dat = list()
	dat += "<div style='font-family:Verdana,Geneva,sans-serif; line-height:1.5; color:#c8d4d0;'>"
	dat += "<div style='text-align:center; margin:0 0 12px 0;'>"
	dat += "<div style='font-size:1.35em; letter-spacing:0.08em; color:#85bab6;'><b>NSV SIERRA</b></div>"
	dat += "<div style='font-size:1.1em; color:#dce8e4;'><b>Брифинг экспедиции «Одиссея»</b></div>"
	dat += "<div style='font-size:0.9em; color:#7a9a96; margin-top:4px;'>Секретно · для личного состава</div>"
	dat += "</div>"

	dat += "<p style='margin:8px 0; padding:8px 10px; background:rgba(0,0,0,0.25); border-left:3px solid #5588aa;'>"
	dat += html_encode(odyssey_lobby_status_phrase(meta, state))
	dat += "</p>"

	if (!islist(meta) && !state.active)
		dat += "<p>Экспедиция «Одиссея» — многосменный поход Сьерры по цепочке секторов туманности. "
		dat += "Командование прокладывает курс, экипаж проходит смены; потери, повреждения и контракты сохраняются между ними.</p>"
		dat += "<p><i>Сейчас активного маршрута нет. Если командование объявит Одиссею, брифинг появится здесь.</i></p>"
		dat += "</div>"
		return jointext(dat, null)

	var/list/graph = meta["sector_graph"]
	var/sector_id = state.active ? state.current_sector_id : meta["current_sector_id"]
	if (!state.active && meta["transition_committed"] && meta["selected_sector_id"])
		sector_id = meta["selected_sector_id"]
	var/list/sector = null
	if (state.active)
		sector = odyssey_get_sector(sector_id, state)
	else if (islist(graph))
		sector = graph[sector_id]

	var/sector_name = sector?["name"] || odyssey_sector_display_name(sector_id)
	var/danger = sector?["danger"]
	var/danger_label = odyssey_danger_label(danger)
	var/summary = sector?["summary"]
	var/shift = state.active ? state.shift_number : (meta["shift_number"] || 1)
	var/max_shifts = state.active ? state.max_shifts : (meta["max_shifts"] || ODYSSEY_MAX_SHIFTS)
	var/echelon = state.active ? odyssey_campaign_echelon(state) : odyssey_sector_echelon(sector_id, graph)

	// --- Situation ---
	dat += "<h3 style='color:#85bab6; border-bottom:1px solid #335555; padding-bottom:4px;'>Обстановка</h3>"
	dat += "<p>"
	dat += "Смена экспедиции: <b>[shift]</b><br>"
	dat += "Глубина маршрута (эшелон): <b>[echelon]</b> из <b>[max_shifts]</b><br>"
	dat += "Текущий сектор: <b>«[html_encode(sector_name)]»</b>"
	if (danger_label)
		dat += " — класс угрозы: <b>[html_encode(danger_label)]</b>"
	dat += "</p>"
	if (summary)
		dat += "<p style='font-style:italic; color:#a8c0bc;'>«[html_encode(summary)]»</p>"

	// Course
	var/course
	var/sel = state.active ? state.selected_sector_id : meta["selected_sector_id"]
	var/committed = state.active ? state.transition_committed : !!meta["transition_committed"]
	if (sel)
		course = "Проложен курс на «[odyssey_sector_display_name(sel)]»"
		if (committed)
			course += " — прыжок утверждён, ожидается переход."
		else
			course += " — ожидает подтверждения на Bluespace Drive."
	else
		course = "Курс не выбран: смена, скорее всего, пройдёт в текущем секторе."
	dat += "<p>[html_encode(course)]</p>"

	if (islist(meta) && !meta["active"] && !state.active)
		dat += "<p><i>[html_encode(odyssey_lobby_outcome_ic(meta["status"]))]</i></p>"
		if (islist(meta["campaign_stats"]))
			dat += odyssey_campaign_stats_html(meta["campaign_stats"])

	// --- Mission ---
	var/list/contracts = state.active ? state.contracts : meta["contracts"]
	var/list/objectives = state.active ? state.objectives : meta["objectives"]
	dat += "<h3 style='color:#85bab6; border-bottom:1px solid #335555; padding-bottom:4px;'>Задание</h3>"
	var/had_contract = FALSE
	if (islist(contracts))
		for (var/list/entry in contracts)
			if (!islist(entry) || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
				continue
			had_contract = TRUE
			var/ctr_title = entry["title"] || "Контракт"
			var/ctr_brief = entry["brief"]
			dat += "<p><b>[html_encode(ctr_title)]</b><br>"
			if (ctr_brief)
				dat += "<span style='color:#a8c0bc;'>[html_encode(ctr_brief)]</span></p>"
			else
				dat += "</p>"
	if (!had_contract)
		dat += "<p><i>Активный контракт экспедиции не указан.</i></p>"

	var/had_obj = FALSE
	if (islist(objectives))
		for (var/list/entry in objectives)
			if (!islist(entry) || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE || entry["scope"] != "shift")
				continue
			if (!had_obj)
				dat += "<p><b>Цели текущей / последней смены:</b></p><ul style='margin-top:0;'>"
				had_obj = TRUE
			var/obj_title = entry["title"] || "?"
			var/obj_brief = entry["brief"]
			dat += "<li><b>[html_encode(obj_title)]</b>"
			if (obj_brief)
				dat += " — [html_encode(obj_brief)]"
			dat += "</li>"
		if (had_obj)
			dat += "</ul>"
	if (!had_obj)
		dat += "<p><i>Отдельных целей смены в брифинге нет (они выдаются после начала смены).</i></p>"

	// --- Personnel ---
	var/list/roster = state.active && length(state.roster) ? state.roster : odyssey_load_roster()
	var/list/counts = odyssey_roster_counts(roster)
	var/alive_n = counts["alive"]
	var/dead_n = counts["dead"]
	var/dead_cmd = counts["dead_command"]
	dat += "<h3 style='color:#85bab6; border-bottom:1px solid #335555; padding-bottom:4px;'>Личный состав</h3>"
	dat += "<p>В журнале экспедиции: живых <b>[alive_n]</b>, погибших <b>[dead_n]</b>"
	if (dead_cmd)
		dat += " (в т.ч. командный состав: <b>[dead_cmd]</b>)"
	dat += ".</p>"
	if (dead_n)
		dat += "<p><b>Потери, зафиксированные в журнале:</b></p><ul style='margin-top:0;'>"
		var/shown = 0
		for (var/key in roster)
			var/list/entry = roster[key]
			if (!islist(entry) || entry["status"] != "dead")
				continue
			var/dead_name = entry["name"] || "Неизвестный"
			var/dead_job = entry["job"] || "должность не указана"
			dat += "<li>[html_encode(dead_name)] — [html_encode(dead_job)]"
			if (entry["death_shift"])
				dat += " <span style='color:#889999;'>(смена [entry["death_shift"]])</span>"
			dat += "</li>"
			shown++
			if (shown >= 16)
				dat += "<li><i>…и другие.</i></li>"
				break
		dat += "</ul>"
		dat += "<p style='font-size:0.9em; color:#889999;'>Места погибших членов экипажа закрыты до конца экспедиции.</p>"

	// --- Assets ---
	var/list/abandoned = list()
	var/list/damaged_lines = list()
	var/list/shuttle_reports = state.active ? state.shuttle_reports : meta["shuttle_reports"]
	if (islist(shuttle_reports))
		for (var/shuttle_name in shuttle_reports)
			var/list/report = shuttle_reports[shuttle_name]
			if (!islist(report))
				continue
			if (report["status"] == ODYSSEY_SHUTTLE_STATUS_ABANDONED)
				abandoned += shuttle_name
			else if (report["status"] == ODYSSEY_SHUTTLE_STATUS_DAMAGED)
				damaged_lines += "[shuttle_name] — оценка ремонта [report["repair_cost"] || "?"] T"
	else if (islist(meta["abandoned_shuttles"]))
		abandoned = meta["abandoned_shuttles"]
	else if (state.active && islist(state.abandoned_shuttles))
		abandoned = state.abandoned_shuttles

	dat += "<h3 style='color:#85bab6; border-bottom:1px solid #335555; padding-bottom:4px;'>Флот и техника</h3>"
	if (length(abandoned))
		dat += "<p>Шаттлы, не вернувшиеся на Сьерру: <b>[html_encode(english_list(abandoned))]</b>. "
		dat += "Доки на следующих сменах будут пустовать.</p>"
	else
		dat += "<p>Потерь вспомогательного флота не отмечено.</p>"
	if (length(damaged_lines))
		dat += "<p>Повреждённые единицы (требуют внимания инженерии):</p><ul style='margin-top:0;'>"
		for (var/line in damaged_lines)
			dat += "<li>[html_encode(line)]</li>"
		dat += "</ul>"
	else
		dat += "<p>Критических повреждений шаттлов в отчёте нет.</p>"

	// --- Route ---
	var/list/route = state.active ? state.route_history : meta["route_history"]
	if (islist(route) && length(route))
		dat += "<h3 style='color:#85bab6; border-bottom:1px solid #335555; padding-bottom:4px;'>Пройденный путь</h3>"
		var/list/route_names = list()
		for (var/id in route)
			route_names += "«[odyssey_sector_display_name(id)]»"
		dat += "<p>[html_encode(jointext(route_names, " → "))]</p>"

	// --- Chronicle headlines ---
	var/list/chronicle = null
	if (state.active && islist(state.chronicle) && length(state.chronicle))
		chronicle = state.chronicle
	else if (islist(meta))
		var/list/chronicle_file = odyssey_read_json(odyssey_snapshot_path("chronicle", meta["generation"]))
		if (islist(chronicle_file))
			chronicle = chronicle_file["entries"]
	if (islist(chronicle) && length(chronicle))
		dat += "<h3 style='color:#85bab6; border-bottom:1px solid #335555; padding-bottom:4px;'>Из бортового журнала</h3>"
		var/shown_h = 0
		for (var/i = length(chronicle); i >= 1 && shown_h < 6; i--)
			var/list/entry = chronicle[i]
			if (!islist(entry))
				continue
			if ((entry["visibility"] || ODYSSEY_CHRONICLE_VIS_PUBLIC) != ODYSSEY_CHRONICLE_VIS_PUBLIC)
				continue
			var/ev_title = entry["title"] || "Запись"
			var/ev_at = entry["at"] || ""
			var/ev_shift = entry["shift"] || "?"
			var/ev_body = entry["body"]
			dat += "<div style='margin:0 0 10px 0; padding:6px 8px; background:rgba(0,0,0,0.2); border-left:3px solid #5588aa;'>"
			dat += "<b>[html_encode(ev_title)]</b>"
			if (entry["shift"] || entry["at"])
				dat += "<br><span style='font-size:0.85em; color:#889999;'>Смена [ev_shift] · [html_encode(ev_at)]</span>"
			if (ev_body)
				dat += "<br>[html_encode(ev_body)]"
			dat += "</div>"
			shown_h++
		if (!shown_h)
			dat += "<p><i>Публичных записей пока нет.</i></p>"

	dat += "<p style='margin-top:14px; font-size:0.85em; color:#667777; text-align:center;'>"
	dat += "— Конец брифинга. На смене тот же документ: Newscast / Command → Briefing —"
	dat += "</p></div>"
	return jointext(dat, null)


/mob/new_player/lobby_show_odyssey()
	var/list/meta = odyssey_load_meta()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/dat = list()

	if (client && check_rights(R_ADMIN|R_DEBUG|R_SERVER, FALSE, client))
		dat += "<div style='font-family:Verdana,sans-serif; margin-bottom:8px;'>"
		dat += "<a href='?src=\ref[src];lobby_odyssey_panel=1'><b>Открыть Odyssey Panel</b></a>"
		dat += " <span style='color:#889999; font-size:0.85em;'>(OOC · админ)</span></div><hr>"

	dat += "<div style='font-family:Verdana,Geneva,sans-serif;'>"
	dat += odyssey_lobby_vote_section_html(src)
	dat += "</div><hr>"
	dat += odyssey_lobby_briefing_html(meta, state)

	var/datum/browser/popup = new(src, "odyssey_lobby", "Odyssey — Брифинг", 560, 720, src)
	popup.set_content(jointext(dat, null))
	popup.open()


/hook/roundstart/proc/odyssey_refresh_lobby_button()
	odyssey_refresh_lobby_titlescreens()
	return TRUE
