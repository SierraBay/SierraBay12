/// Admin panel for Odyssey campaign state, disk saves, and lifecycle actions.
var/global/datum/odyssey_panel/odyssey_panel

/datum/odyssey_panel

/proc/odyssey_ensure_panel()
	if (!odyssey_panel)
		odyssey_panel = new /datum/odyssey_panel
	return odyssey_panel


/proc/odyssey_announce_admin_campaign(kind)
	switch (kind)
		if ("new")
			to_world(SPAN_NOTICE("<b>Администрация включила Одиссею: в этом раунде начнётся новая кампания.</b>"))
		if ("continue")
			to_world(SPAN_NOTICE("<b>Администрация включила Одиссею: этот раунд — продолжение кампании.</b>"))
		if ("archive")
			to_world(SPAN_WARNING("<b>Администрация архивировала Одиссею. Продолжение кампании больше не будет предложено.</b>"))
		else
			return
	log_game("ODYSSEY: admin campaign announce kind=[kind]")


/client/proc/odyssey_panel()
	set category = "Admin"
	set name = "Odyssey Panel"
	set desc = "Состояние Одиссеи, сейвы и управление кампанией."

	if (!check_rights(R_ADMIN|R_DEBUG|R_SERVER))
		return
	var/datum/odyssey_panel/panel = odyssey_ensure_panel()
	panel.show(src)


/datum/odyssey_panel/proc/show(client/C)
	if (!C || !check_rights(R_ADMIN|R_DEBUG|R_SERVER, FALSE, C))
		return

	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/meta = odyssey_load_meta()
	var/list/lobby = SSticker?.lobby_players()
	var/lobby_count = length(lobby)
	var/has_campaign = odyssey_campaign_exists()
	var/disk_exists = islist(meta)
	var/disk_archived = disk_exists && !meta["active"]
	var/in_lobby = (GAME_STATE == RUNLEVEL_LOBBY)
	var/map_key = odyssey_map_key()

	var/list/dat = list()
	dat += "<div align='center'><h1>Одиссея</h1></div>"
	dat += "<a href='?src=\ref[src];refresh=1'>Обновить</a>"
	dat += "<hr>"

	// --- Runtime ---
	dat += "<h3>Раунд</h3>"
	dat += "<div class='statusDisplay'>"
	dat += "Карта: <b>[html_encode(map_key)]</b> | GAME_STATE: <b>[GAME_STATE]</b><br>"
	if (state.active)
		dat += "Кампания: <b><font color='55aa55'>АКТИВНА</font></b>"
		dat += state.continued ? " (продолжение)" : " (новая)"
		dat += "<br>"
		dat += "ID: <code>[html_encode(state.campaign_id)]</code><br>"
		dat += "Эшелон: <b>[odyssey_campaign_echelon(state)]/[state.max_shifts]</b> | "
		dat += "смена экипажа: <b>[state.shift_number]</b> | status: <b>[state.status]</b><br>"
		dat += "Сектор: <b>[html_encode(state.current_sector_id)]</b>"
		if (state.selected_sector_id)
			dat += " → курс: <b>[html_encode(state.selected_sector_id)]</b>"
			if (state.selected_by)
				dat += " ([html_encode(state.selected_by)])"
		dat += "<br>"
		dat += "transition committed: <b>[state.transition_committed ? "да" : "нет"]</b> | "
		dat += "BSD jump: <b>[state.odyssey_bsd_jump_done ? "да" : "нет"]</b> | "
		dat += "shift end queued: <b>[state.shift_end_queued ? "да" : "нет"]</b><br>"
		dat += "Abandoned shuttles: <b>[length(state.abandoned_shuttles)]</b>"
		if (length(state.abandoned_shuttles))
			dat += " <code>[html_encode(english_list(state.abandoned_shuttles))]</code>"
		dat += "<br>"
		dat += "Shuttle reports: <b>[length(state.shuttle_reports)]</b><br>"
		for (var/shuttle_name in state.shuttle_reports)
			var/list/report = state.shuttle_reports[shuttle_name]
			if (!islist(report))
				continue
			dat += " — <b>[html_encode(shuttle_name)]</b>: [report["status"]]"
			if (report["status"] == ODYSSEY_SHUTTLE_STATUS_DAMAGED)
				dat += " damage=[report["damage"]] cost=[report["repair_cost"]] fee_pending=[report["fee_pending"] ? "да" : "нет"]"
			dat += "<br>"
	else
		dat += "Кампания: <b>не активна</b> в этом раунде<br>"
		if (state.campaign_id)
			dat += "Последний ID: <code>[html_encode(state.campaign_id)]</code> | status: <b>[state.status]</b>"
			if (state.outcome_reason)
				dat += " ([html_encode(state.outcome_reason)])"
			dat += "<br>"
	dat += "Лобби: <b>[lobby_count]</b> (vote из кнопки Odyssey; порог ≥ [ODYSSEY_MIN_YES_VOTES] «За»)"
	dat += "</div>"

	// --- Disk ---
	dat += "<h3>Диск (campaign.json)</h3>"
	dat += "<div class='statusDisplay'>"
	if (!disk_exists)
		dat += "<i>Нет файла — следующему лобби предложат <b>start</b>.</i><br>"
		dat += "Путь: <code>[html_encode(odyssey_meta_path())]</code>"
	else
		dat += "Continue в лобби: <b>[has_campaign ? "<font color='55aa55'>ДА</font>" : "<font color='cc5555'>нет</font>"]</b>"
		if (disk_archived)
			dat += " — архив ([html_encode(meta["status"])]"
			var/archive_why = meta["archive_reason"] || meta["outcome_reason"]
			if (archive_why)
				dat += ": [html_encode(archive_why)]"
			dat += ")"
		dat += "<br>"
		dat += "ID: <code>[html_encode(meta["campaign_id"])]</code> | v[meta["version"]] | gen [meta["generation"] || "—"]<br>"
		dat += "Эшелон/смена: <b>[meta["shift_number"]]/[meta["max_shifts"]]</b> | "
		dat += "сектор: <b>[html_encode(meta["current_sector_id"])]</b>"
		if (meta["selected_sector_id"])
			dat += " → <b>[html_encode(meta["selected_sector_id"])]</b>"
			if (meta["transition_committed"])
				dat += " <i>(committed)</i>"
		dat += "<br>"
		dat += "saved_at: <b>[html_encode(meta["saved_at"] || "—")]</b><br>"
		if (meta["archived_at"])
			dat += "archived_at: <b>[html_encode(meta["archived_at"])]</b><br>"
		dat += "Путь: <code>[html_encode(odyssey_meta_path())]</code>"
	dat += "</div>"

	// --- Snapshots ---
	dat += "<h3>Снапшоты</h3>"
	dat += "<div class='statusDisplay'>"
	dat += "<table width='100%'>"
	dat += "<tr><th>Файл</th><th>Есть</th><th>Версия</th><th>Записей</th><th></th></tr>"
	for (var/kind in list("turfs", "machinery", "structures", "mechs", "economy", "research", "roster", "newscast", "corpses", "chronicle"))
		var/list/summary = odyssey_snapshot_summary(kind)
		dat += "<tr>"
		dat += "<td><code>[kind].json</code></td>"
		dat += "<td>[summary["exists"] ? "да" : "нет"]</td>"
		dat += "<td>[summary["version"] || "—"]</td>"
		dat += "<td>[summary["count"]]</td>"
		dat += "<td>"
		if (summary["exists"])
			dat += "<a href='?src=\ref[src];preview=[kind]'>Превью</a>"
		dat += "</td>"
		dat += "</tr>"
	dat += "</table>"
	dat += "</div>"

	// --- Route / roster ---
	dat += "<h3>Маршрут, roster, антаги</h3><div class='statusDisplay'>"
	if (islist(state.sector_graph) && length(state.sector_graph))
		if (state.selected_sector_id && !state.transition_committed)
			dat += "<a href='?src=\ref[src];clear_destination=1'>Сбросить курс</a><br><br>"
		for (var/id in state.sector_graph)
			var/list/node = state.sector_graph[id]
			var/is_current = (id == state.current_sector_id)
			var/is_selected = (id == state.selected_sector_id)
			dat += "<b>[id]</b>"
			if (is_current)
				dat += " <font color='55aa55'>(текущий)</font>"
			if (is_selected)
				dat += " <font color='5588cc'>(курс)</font>"
			dat += ": [html_encode(node["name"])] depth=[node["depth"]] danger=[node["danger"]]"
			if (state.active && !state.transition_committed)
				dat += " <a href='?src=\ref[src];force_destination=[url_encode(id)]'>назначить курс</a>"
			dat += "<br>"
		dat += "<hr>"
	dat += "Участники: <b>[length(state.roster)]</b><br>"
	for (var/key in state.roster)
		var/list/member = state.roster[key]
		dat += "[html_encode(member["name"])] ([key]): <b>[member["status"]]</b>"
		if (member["death_shift"])
			dat += " — смерть в смене [member["death_shift"]] ([member["death_reason"]])"
		dat += "<br>"
	dat += "<hr>Спящие: <b>[length(state.sleepers)]</b> (active [odyssey_count_active_sleepers()]) | midround: <b>[state.sleeper_midround_done ? "уже был" : "ещё нет"]</b>"
	if (state.active)
		dat += " | <a href='?src=\ref[src];make_sleeper=1'>назначить спящего</a>"
	dat += "<br>"
	for (var/skey in state.sleepers)
		var/list/sleeper = state.sleepers[skey]
		if (!islist(sleeper))
			continue
		dat += "[html_encode(sleeper["name"])] ([skey]): <b>[sleeper["status"]]</b> shift=[sleeper["assigned_shift"]] source=[sleeper["source"]]"
		if (sleeper["death_shift"])
			dat += " — снят в смене [sleeper["death_shift"]] ([sleeper["death_reason"]])"
		dat += "<br>"
	dat += "<hr>Генокрады: <b>[length(state.changelings)]</b> (active [odyssey_count_active_changelings()])"
	if (state.active)
		dat += " | <a href='?src=\ref[src];make_changeling=1'>назначить генокрада</a>"
	dat += "<br>"
	for (var/ckey_slot in state.changelings)
		var/list/cling = state.changelings[ckey_slot]
		if (!islist(cling))
			continue
		dat += "[html_encode(cling["name"])] ([ckey_slot]): <b>[cling["status"]]</b> shift=[cling["assigned_shift"]] source=[cling["source"]]"
		if (cling["lost_shift"])
			dat += " — снят в смене [cling["lost_shift"]] ([cling["lost_reason"]])"
		dat += "<br>"
	dat += "<hr>Mercenaries: <b>[state.merc_used ? "уже были" : "ещё нет"]</b>"
	if (state.merc_used)
		dat += " — смена [state.merc_used_shift] ([html_encode(state.merc_used_reason)])"
	else if (state.merc_shift_decision)
		dat += " | решение смены: <b>[html_encode(state.merc_shift_decision)]</b>"
	dat += "<br>"
	dat += "Hostile: raiders=<b>[html_encode(state.raider_shift_decision || "—")]</b> | "
	dat += "ninja=<b>[html_encode(state.ninja_shift_decision || "—")]</b> | "
	dat += "danger=<b>[html_encode(odyssey_current_sector_danger())]</b><br>"
	if (length(state.validation_errors))
		dat += "<hr><font color='cc5555'>Ошибки: [html_encode(json_encode(state.validation_errors))]</font>"
	dat += "</div>"

	// --- Objectives ---
	dat += "<h3>Контракты и цели</h3><div class='statusDisplay'>"
	dat += "Контракты: <b>[length(state.contracts)]</b> | Цели: <b>[length(state.objectives)]</b>"
	if (state.active)
		dat += " | <a href='?src=\ref[src];objectives_regen=1'>Пересоздать цели смены</a>"
	dat += "<br>"
	for (var/list/entry in state.contracts)
		if (!islist(entry))
			continue
		dat += "<b>CTR</b> [html_encode(entry["title"] || "?")] — <b>[entry["status"]]</b> ([entry["kind"]])<br>"
	for (var/list/entry in state.objectives)
		if (!islist(entry))
			continue
		if (entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE && entry["shift_issued"] != state.shift_number)
			continue
		dat += "<b>OBJ</b> [html_encode(entry["title"] || "?")] — <b>[entry["status"]]</b>"
		if (!isnull(entry["progress"]))
			dat += " [entry["progress"]]/[entry["target"]]"
		dat += " ([entry["kind"]])<br>"
	dat += "</div>"

	// --- Science briefs (RnD) ---
	dat += "<h3>Наука (НИО / research.json)</h3><div class='statusDisplay'>"
	var/list/R = odyssey_research_ensure()
	dat += "flag <code>odyssey_science_enabled</code>: <b>[odyssey_science_enabled ? "TRUE" : "FALSE"]</b>"
	if (state.active)
		dat += " | <a href='?src=\ref[src];sci_regen=1'>Пересоздать брифы</a>"
		dat += " | <a href='?src=\ref[src];sci_pay_test=1'>Тест +1000 Science</a>"
		dat += " | <a href='?src=\ref[src];preview=research'>Превью research</a>"
	dat += "<br>"
	dat += "Samples: <b>[length(R["samples_collected"])]</b> | Anomalies: <b>[length(R["anomalies_catalogued"])]</b><br>"
	dat += "<b>Брифы:</b><br>"
	var/brief_shown = 0
	for (var/list/entry in R["active_briefs"])
		if (!islist(entry))
			continue
		if (entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE && entry["shift_issued"] != state.shift_number)
			continue
		brief_shown++
		dat += "• <b>[html_encode(entry["title"] || "?")]</b> — <b>[entry["status"]]</b> "
		dat += "[entry["progress"]]/[entry["target"]] ([entry["kind"]])"
		if (entry["reward_credits"])
			dat += " reward=<b>[entry["reward_credits"]]</b>₮"
		if (entry["target_gene"])
			dat += " gene=<code>[html_encode(entry["target_gene"])]</code>"
		if (entry["target_type"])
			dat += " type=<code>[html_encode(entry["target_type"])]</code>"
		if (entry["status"] == ODYSSEY_OBJ_STATUS_ACTIVE)
			dat += " <a href='?src=\ref[src];sci_progress=[html_encode(entry["id"])]'> +1 progress</a>"
			dat += " <a href='?src=\ref[src];sci_complete=[html_encode(entry["id"])]'><font color='55aa55'>Complete+pay</font></a>"
		dat += "<br>"
	if (!brief_shown)
		dat += "<i>Нет брифов этой смены.</i><br>"
	if (state.active)
		dat += "<br><b>Симулировать сдачу:</b> "
		dat += "<a href='?src=\ref[src];sci_sim=spectrum'>spectrum</a> | "
		dat += "<a href='?src=\ref[src];sci_sim=catalog'>catalog</a> | "
		dat += "<a href='?src=\ref[src];sci_sim=flora'>flora</a> | "
		dat += "<a href='?src=\ref[src];sci_sim=slime'>slime</a>"
	dat += "</div>"

	// --- Department briefs (Cargo / Medical) ---
	dat += "<h3>Отделы (Карго / Мед)</h3><div class='statusDisplay'>"
	if (state.active)
		dat += "<a href='?src=\ref[src];dept_regen=1'>Пересоздать брифы отделов</a><br>"
	var/dept_shown = 0
	for (var/list/dentry in R["dept_briefs"])
		if (!islist(dentry))
			continue
		if (dentry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE && dentry["shift_issued"] != state.shift_number)
			continue
		dept_shown++
		dat += "• <b>[html_encode(dentry["title"] || "?")]</b> — <b>[dentry["status"]]</b> "
		dat += "[dentry["progress"]]/[dentry["target"]] ([dentry["kind"]])"
		if (dentry["reward_credits"])
			dat += " reward=<b>[dentry["reward_credits"]]</b>₮"
		if (dentry["target_dept"])
			dat += " dept=<code>[html_encode(dentry["target_dept_label"] || dentry["target_dept"])]</code>"
		if (dentry["status"] == ODYSSEY_OBJ_STATUS_ACTIVE)
			dat += " <a href='?src=\ref[src];dept_progress=[html_encode(dentry["id"])]'>+progress</a>"
			dat += " <a href='?src=\ref[src];dept_complete=[html_encode(dentry["id"])]'><font color='55aa55'>Complete+pay</font></a>"
		dat += "<br>"
	if (!dept_shown)
		dat += "<i>Нет брифов отделов этой смены.</i><br>"
	dat += "</div>"

	// --- Chronicle ---
	dat += "<h3>Хроника</h3><div class='statusDisplay'>"
	dat += "Записей: <b>[length(state.chronicle)]</b>"
	if (state.active)
		dat += " | <a href='?src=\ref[src];chronicle_add=1'>Добавить запись</a>"
		dat += " | <a href='?src=\ref[src];show_briefing=1'>Сводка continue</a>"
		dat += " | <a href='?src=\ref[src];show_stats=1'>Итоги (preview)</a>"
	else
		dat += " | <a href='?src=\ref[src];show_stats=1'>Итоги кампании</a>"
	dat += "<br>"
	var/shown = 0
	for (var/i = length(state.chronicle); i >= 1 && shown < 12; i--)
		var/list/entry = state.chronicle[i]
		if (!islist(entry))
			continue
		dat += "<b>[html_encode(entry["title"] || "?")]</b> "
		dat += "<font size=1>(смена [entry["shift"]], [entry["visibility"]], [entry["at"]])</font><br>"
		if (entry["body"])
			dat += "<i>[html_encode(entry["body"])]</i><br>"
		shown++
	if (!length(state.chronicle))
		dat += "<i>Пусто.</i>"
	dat += "</div>"

	// --- Economy ---
	dat += "<h3>Экономика (live)</h3>"
	dat += "<div class='statusDisplay'>"
	if (istype(station_account))
		dat += "NSV Sierra #[station_account.account_number]: <b>[station_account.money]</b><br>"
	else
		dat += "Счёт судна (NSV Sierra): нет<br>"
	var/list/unique_depts = odyssey_unique_department_accounts()
	for (var/dept in unique_depts)
		var/datum/money_account/A = unique_depts[dept]
		dat += "[html_encode(dept)]: <b>[A.money]</b><br>"
	dat += "</div>"

	// --- Actions ---
	dat += "<h3>Действия</h3>"
	dat += "<div class='statusDisplay'>"

	dat += "<b>Лобби</b> — голосование через кнопку Odyssey у игроков или здесь (≥ [ODYSSEY_MIN_YES_VOTES] «За» и больше «Против»). Авто-vote в pregame отключён.<br>"
	if (in_lobby)
		if (has_campaign)
			dat += "<a href='?src=\ref[src];vote_continue=1'><b>Голосование: продолжить</b></a>"
			dat += " <i>(чтобы предложить start — сначала архивируйте сейв)</i>"
		else if (disk_archived)
			dat += "<a href='?src=\ref[src];vote_start=1'><b>Голосование: начать новую</b></a>"
			dat += " <i>(continue недоступен: сейв архивирован — сначала «Восстановить архив»)</i>"
		else
			dat += "<a href='?src=\ref[src];vote_start=1'><b>Голосование: начать новую</b></a>"
	else
		dat += "<i>Раунд уже идёт — лобби-голосования недоступны.</i>"
	dat += "<br><br>"

	dat += "<b>Кампания</b><br>"
	if (!state.active)
		dat += "<a href='?src=\ref[src];begin_new=1'>Включить новую Одиссею в этом раунде</a><br>"
		if (disk_exists)
			dat += "<a href='?src=\ref[src];begin_continue=1'>Включить продолжение из сейва</a>"
			dat += " <i>(apply на roundstart; mid-round — Force apply)</i><br>"
	else
		dat += "<i>Раунд уже в Одиссее.</i><br>"
		dat += "<a href='?src=\ref[src];finish=1'><font color='cc5555'>Завершить кампанию (runtime + архив)</font></a><br>"
		if (!state.shift_end_queued)
			dat += "<a href='?src=\ref[src];queue_shift_end=1'>Назначить End the shift ([ODYSSEY_SHIFT_END_DELAY / (1 MINUTE)] мин)</a><br>"
		else
			dat += "<i>Shift end уже в очереди.</i><br>"
	if (has_campaign)
		dat += "<a href='?src=\ref[src];archive=1'><font color='cc5555'>Архивировать сейв на диске</font></a>"
		dat += " <i>(следующий лобби предложит start)</i><br>"
	else if (disk_archived)
		dat += "<a href='?src=\ref[src];reactivate=1'>Восстановить архив на диске (active)</a>"
		dat += " <i>(без старта раунда — только чтобы лобби снова предложило continue)</i><br>"
	dat += "<br>"

	dat += "<b>Навигация</b><br>"
	if (state.active)
		dat += "<a href='?src=\ref[src];regenerate=1'>Пересоздать граф секторов</a>"
		dat += " <i>(только до первого перехода)</i><br>"
		if (state.selected_sector_id && !state.transition_committed)
			dat += "<a href='?src=\ref[src];clear_destination=1'>Сбросить выбранный курс</a><br>"
	else
		dat += "<i>Нужна активная кампания.</i><br>"
	dat += "<br>"

	dat += "<b>Сейв / отладка</b><br>"
	dat += "<a href='?src=\ref[src];validate=1'>Validate save</a> | "
	dat += "<a href='?src=\ref[src];force_save=1'>Force save</a> | "
	dat += "<a href='?src=\ref[src];force_apply=1'><font color='cc5555'>Force apply</font></a> | "
	dat += "<a href='?src=\ref[src];capture_baseline=1'>Capture baseline</a>"
	dat += "</div>"

	var/datum/browser/popup = new(C.mob, "odyssey_panel", "Odyssey Panel", 780, 920, src)
	popup.set_content(jointext(dat, null))
	popup.open()


/datum/odyssey_panel/Topic(href, href_list)
	if (!check_rights(R_ADMIN|R_DEBUG|R_SERVER))
		return
	var/client/C = usr.client
	if (!C)
		return

	if (href_list["refresh"])
		show(C)
		return

	if (href_list["preview"])
		show_preview(C, href_list["preview"])
		return

	if (href_list["show_briefing"])
		var/brief = odyssey_continue_briefing(odyssey_load_meta(), FALSE)
		to_chat(usr, SPAN_NOTICE("<b>[replacetext(brief, "\n", "<br>")]</b>"))
		show(C)
		return

	if (href_list["show_stats"])
		var/list/meta = odyssey_load_meta()
		var/list/stats = meta?["campaign_stats"]
		if (!islist(stats))
			var/datum/odyssey_state/state = odyssey_ensure_state()
			if (state.active)
				stats = odyssey_build_campaign_stats(state.status, state.outcome_reason)
		if (islist(stats))
			to_chat(usr, SPAN_NOTICE("<b>[replacetext(odyssey_campaign_stats_text(stats, FALSE), "\n", "<br>")]</b>"))
		else
			to_chat(usr, SPAN_WARNING("Нет сохранённой статистики Одиссеи."))
		show(C)
		return

	if (href_list["objectives_regen"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		if (!state.active)
			to_chat(usr, SPAN_WARNING("Odyssey не активна."))
			show(C)
			return
		odyssey_ensure_campaign_contract()
		odyssey_generate_shift_objectives()
		log_and_message_admins("regenerated Odyssey shift objectives", usr)
		show(C)
		return

	if (href_list["sci_regen"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		if (!state.active)
			to_chat(usr, SPAN_WARNING("Odyssey не активна."))
			show(C)
			return
		odyssey_science_enabled = TRUE
		odyssey_generate_science_briefs()
		log_and_message_admins("regenerated Odyssey science briefs", usr)
		to_chat(usr, SPAN_NOTICE("Научные брифы пересозданы."))
		show(C)
		return

	if (href_list["sci_pay_test"])
		odyssey_science_admin_pay_test(1000, usr)
		log_and_message_admins("test-paid Odyssey science credits", usr)
		show(C)
		return

	if (href_list["sci_progress"])
		var/brief_id = href_list["sci_progress"]
		var/list/R = odyssey_research_ensure()
		for (var/i = 1 to length(R["active_briefs"]))
			var/list/entry = R["active_briefs"][i]
			if (!islist(entry) || entry["id"] != brief_id || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
				continue
			var/evidence = entry["target_gene"] || entry["target_type"] || "admin-progress-[world.time]"
			odyssey_science_progress(entry["kind"], 1, evidence, usr, usr)
			to_chat(usr, SPAN_NOTICE("Progress [entry["title"]] simulated."))
			break
		show(C)
		return

	if (href_list["sci_complete"])
		if (odyssey_science_admin_complete(href_list["sci_complete"], usr))
			log_and_message_admins("force-completed Odyssey science brief [href_list["sci_complete"]]", usr)
			to_chat(usr, SPAN_NOTICE("Бриф выполнен, таллеры зачислены."))
		else
			to_chat(usr, SPAN_WARNING("Бриф не найден или уже закрыт."))
		show(C)
		return

	if (href_list["sci_sim"])
		var/kind = href_list["sci_sim"]
		var/evidence = "admin-sim-[kind]-[world.time]"
		var/list/R = odyssey_research_ensure()
		for (var/list/entry in R["active_briefs"])
			if (!islist(entry) || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE || entry["kind"] != kind)
				continue
			if (entry["target_gene"])
				evidence = entry["target_gene"]
			else if (entry["target_type"])
				evidence = entry["target_type"]
			break
		switch (kind)
			if (ODYSSEY_SCI_BRIEF_SPECTRUM)
				odyssey_science_progress(ODYSSEY_SCI_BRIEF_SPECTRUM, 1, evidence, usr, usr)
			if (ODYSSEY_SCI_BRIEF_CATALOG)
				odyssey_science_note_anomaly(evidence)
				odyssey_science_progress(ODYSSEY_SCI_BRIEF_CATALOG, 1, evidence, usr, usr)
			if (ODYSSEY_SCI_BRIEF_FLORA)
				odyssey_science_progress(ODYSSEY_SCI_BRIEF_FLORA, 1, evidence, usr, usr)
			if (ODYSSEY_SCI_BRIEF_SLIME)
				odyssey_science_progress(ODYSSEY_SCI_BRIEF_SLIME, 1, evidence, usr, usr)
			else
				to_chat(usr, SPAN_WARNING("Неизвестный kind."))
				show(C)
				return
		log_and_message_admins("simulated Odyssey science progress kind=[kind]", usr)
		to_chat(usr, SPAN_NOTICE("Симуляция сдачи: [kind]."))
		show(C)
		return

	if (href_list["dept_regen"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		if (!state.active)
			to_chat(usr, SPAN_WARNING("Odyssey не активна."))
			show(C)
			return
		odyssey_generate_dept_briefs()
		log_and_message_admins("regenerated Odyssey dept briefs", usr)
		to_chat(usr, SPAN_NOTICE("Брифы отделов пересозданы."))
		show(C)
		return

	if (href_list["dept_progress"])
		if (odyssey_dept_admin_progress(href_list["dept_progress"], usr))
			log_and_message_admins("progressed Odyssey dept brief [href_list["dept_progress"]]", usr)
		else
			to_chat(usr, SPAN_WARNING("Бриф отдела не найден."))
		show(C)
		return

	if (href_list["dept_complete"])
		if (odyssey_dept_admin_complete(href_list["dept_complete"], usr))
			log_and_message_admins("force-completed Odyssey dept brief [href_list["dept_complete"]]", usr)
			to_chat(usr, SPAN_NOTICE("Бриф отдела выполнен, таллеры зачислены."))
		else
			to_chat(usr, SPAN_WARNING("Бриф отдела не найден или уже закрыт."))
		show(C)
		return

	if (href_list["chronicle_add"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		if (!state.active)
			to_chat(usr, SPAN_WARNING("Odyssey не активна."))
			show(C)
			return
		var/title = input(usr, "Заголовок записи хроники:", "Odyssey Chronicle") as text|null
		if (!title)
			show(C)
			return
		var/body = input(usr, "Текст (можно пусто):", "Odyssey Chronicle") as message|null
		var/vis = input(usr, "Видимость:", "Odyssey Chronicle") as null|anything in list(ODYSSEY_CHRONICLE_VIS_PUBLIC, ODYSSEY_CHRONICLE_VIS_COMMAND, ODYSSEY_CHRONICLE_VIS_ADMIN)
		if (!vis)
			show(C)
			return
		odyssey_chronicle_append(ODYSSEY_CHRONICLE_KIND_ADMIN, title, body || "", vis, list("admin" = usr.key))
		log_and_message_admins("added Odyssey chronicle entry '[title]' ([vis])", usr)
		show(C)
		return

	if (href_list["begin_new"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		if (state.active)
			to_chat(usr, SPAN_WARNING("Odyssey уже активна в этом раунде."))
			show(C)
			return
		if (alert(usr, "Включить новую Одиссею в этом раунде без голосования?", "Odyssey", "Да", "Нет") != "Да")
			return
		if (!odyssey_begin_campaign(FALSE, FALSE))
			to_chat(usr, SPAN_WARNING("Odyssey: не удалось начать новую кампанию."))
			show(C)
			return
		odyssey_announce_admin_campaign("new")
		log_and_message_admins("forced Odyssey begin_campaign(new)", usr)
		show(C)
		return

	if (href_list["begin_continue"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		if (state.active)
			to_chat(usr, SPAN_WARNING("Odyssey уже активна в этом раунде."))
			show(C)
			return
		if (alert(usr, "Включить продолжение из сейва? Apply выполнится на roundstart (или Force apply mid-round).", "Odyssey", "Да", "Нет") != "Да")
			return
		var/list/meta = odyssey_load_meta()
		if (islist(meta) && !meta["active"])
			var/disk_status = meta["status"]
			var/disk_reason = meta["archive_reason"] || meta["outcome_reason"] || "—"
			if (alert(usr, "На диске кампания неактивна (status=[disk_status], reason=[disk_reason]). Восстановить active и продолжить?", "Odyssey", "Восстановить", "Отмена") != "Восстановить")
				return
			if (!odyssey_reactivate_campaign_meta())
				to_chat(usr, SPAN_WARNING("Odyssey: не удалось записать campaign.json."))
				show(C)
				return
			log_and_message_admins("reactivated archived Odyssey campaign for continue", usr)
		if (!odyssey_begin_campaign(TRUE, FALSE))
			to_chat(usr, SPAN_WARNING("Odyssey: не удалось пометить продолжение: [odyssey_continue_fail_reason()]."))
			show(C)
			return
		odyssey_announce_admin_campaign("continue")
		log_and_message_admins("forced Odyssey begin_campaign(continue)", usr)
		show(C)
		return

	if (href_list["reactivate"])
		var/list/meta = odyssey_load_meta()
		if (!islist(meta))
			to_chat(usr, SPAN_WARNING("Odyssey: нет campaign.json."))
			show(C)
			return
		if (meta["active"])
			to_chat(usr, SPAN_NOTICE("Odyssey: сейв уже active."))
			show(C)
			return
		if (alert(usr, "Пометить архив как active? Следующий лобби предложит continue.", "Odyssey", "Восстановить", "Отмена") != "Восстановить")
			return
		if (!odyssey_reactivate_campaign_meta())
			to_chat(usr, SPAN_WARNING("Odyssey: не удалось записать campaign.json."))
			show(C)
			return
		log_and_message_admins("reactivated archived Odyssey campaign on disk", usr)
		show(C)
		return

	if (href_list["validate"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		state.validation_errors = odyssey_validate_save()
		to_chat(usr, length(state.validation_errors) ? SPAN_WARNING("Odyssey: validation errors: [json_encode(state.validation_errors)]") : SPAN_NOTICE("Odyssey: save validation OK."))
		show(C)
		return

	if (href_list["regenerate"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		if (!state.active)
			to_chat(usr, SPAN_WARNING("Нужна активная кампания."))
			return
		if (state.shift_number > 1 || length(state.route_history) > 1)
			to_chat(usr, SPAN_WARNING("Граф можно пересоздать только до первого перехода."))
			return
		if (alert(usr, "Пересоздать секторный граф с новым seed?", "Odyssey", "Да", "Нет") != "Да")
			return
		state.campaign_seed = "[state.campaign_id]:admin:[world.realtime]"
		state.sector_graph = odyssey_generate_sector_graph(state.campaign_seed)
		state.current_sector_id = ODYSSEY_SECTOR_START
		state.selected_sector_id = null
		state.selected_by = null
		state.validation_errors = odyssey_validate_graph(state.sector_graph)
		log_and_message_admins("regenerated Odyssey sector graph", usr)
		show(C)
		return

	if (href_list["force_destination"])
		var/dest = href_list["force_destination"]
		if (!odyssey_select_sector(dest, usr, TRUE))
			to_chat(usr, SPAN_WARNING("Odyssey: failed to set course (inactive or jump already committed)."))
			show(C)
			return
		log_and_message_admins("forced Odyssey destination [dest]", usr)
		show(C)
		return

	if (href_list["clear_destination"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		if (!state.active)
			to_chat(usr, SPAN_WARNING("Нужна активная кампания."))
			show(C)
			return
		if (state.transition_committed)
			to_chat(usr, SPAN_WARNING("Переход уже committed — курс сбросить нельзя."))
			show(C)
			return
		state.selected_sector_id = null
		state.selected_by = null
		log_and_message_admins("cleared Odyssey destination", usr)
		show(C)
		return

	if (href_list["queue_shift_end"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		if (!state.active)
			to_chat(usr, SPAN_WARNING("Нужна активная кампания."))
			show(C)
			return
		if (state.shift_end_queued)
			to_chat(usr, SPAN_NOTICE("Shift end уже в очереди."))
			show(C)
			return
		if (alert(usr, "Запланировать End the shift через [ODYSSEY_SHIFT_END_DELAY / (1 MINUTE)] мин (как после Transfer vote)?", "Odyssey", "Да", "Нет") != "Да")
			return
		if (odyssey_try_end_shift())
			log_and_message_admins("queued Odyssey shift end via panel", usr)
		else
			to_chat(usr, SPAN_WARNING("Odyssey: не удалось назначить shift end."))
		show(C)
		return

	if (href_list["finish"])
		if (alert(usr, "Завершить и архивировать текущую Одиссею?", "Odyssey", "Завершить", "Отмена") != "Завершить")
			return
		odyssey_finish_campaign(ODYSSEY_STATUS_ADMIN_ABORTED, "admin_panel:[usr.ckey]")
		log_and_message_admins("finished Odyssey campaign via panel", usr)
		show(C)
		return

	if (href_list["archive"])
		if (alert(usr, "Архивировать кампанию на диске? Continue-vote больше не предложится.", "Odyssey", "Архивировать", "Отмена") != "Архивировать")
			return
		odyssey_archive_campaign("admin_panel:[usr.ckey]")
		odyssey_announce_admin_campaign("archive")
		log_and_message_admins("archived Odyssey campaign via panel", usr)
		show(C)
		return

	if (href_list["make_sleeper"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		if (!state.active)
			to_chat(usr, SPAN_WARNING("Odyssey: кампания не активна."))
			return
		var/list/choices = list()
		for (var/mob/living/carbon/human/H in GLOB.player_list)
			if (!istype(H) || H.stat == DEAD || !H.mind || !H.client)
				continue
			if (!character_persist_ckey_of(H) || !character_persist_slot_of(H))
				continue
			choices["[H.real_name] ([H.ckey])"] = H.mind
		if (!length(choices))
			to_chat(usr, SPAN_WARNING("Odyssey: нет подходящих людей для спящего."))
			return
		var/pick = input(usr, "Кого сделать спящим агентом?", "Odyssey sleeper") as null|anything in choices
		if (!pick)
			return
		var/datum/mind/target = choices[pick]
		if (!istype(target) || !ishuman(target.current))
			to_chat(usr, SPAN_WARNING("Odyssey: цель недоступна."))
			return
		var/ok = FALSE
		if (target in GLOB.traitors.current_antagonists)
			ok = odyssey_register_sleeper(target.current, "admin")
			if (ok)
				odyssey_greet_sleeper(target.current, TRUE)
		else
			ok = odyssey_make_sleeper(target, "admin", FALSE)
		if (ok)
			to_chat(usr, SPAN_NOTICE("Odyssey: спящий записан — [target.current.real_name]."))
		else
			to_chat(usr, SPAN_WARNING("Odyssey: не удалось назначить спящего."))
		log_and_message_admins("assigned Odyssey sleeper via panel: [pick]", usr)
		show(C)
		return

	if (href_list["make_changeling"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		if (!state.active)
			to_chat(usr, SPAN_WARNING("Odyssey: кампания не активна."))
			return
		var/list/choices = list()
		for (var/mob/living/carbon/human/H in GLOB.player_list)
			if (!istype(H) || H.stat == DEAD || !H.mind || !H.client)
				continue
			if (!character_persist_ckey_of(H) || !character_persist_slot_of(H))
				continue
			choices["[H.real_name] ([H.ckey])"] = H.mind
		if (!length(choices))
			to_chat(usr, SPAN_WARNING("Odyssey: нет подходящих людей для генокрада."))
			return
		var/pick = input(usr, "Кого сделать генокрадом?", "Odyssey changeling") as null|anything in choices
		if (!pick)
			return
		var/datum/mind/target = choices[pick]
		if (!istype(target) || !ishuman(target.current))
			to_chat(usr, SPAN_WARNING("Odyssey: цель недоступна."))
			return
		var/ok = FALSE
		if (target in GLOB.changelings.current_antagonists)
			ok = odyssey_register_changeling(target.current, "admin")
			if (ok)
				odyssey_greet_changeling(target.current, TRUE)
		else
			ok = odyssey_make_changeling(target, "admin", FALSE)
		if (ok)
			to_chat(usr, SPAN_NOTICE("Odyssey: генокрад записан — [target.current.real_name]."))
		else
			to_chat(usr, SPAN_WARNING("Odyssey: не удалось назначить генокрада."))
		log_and_message_admins("assigned Odyssey changeling via panel: [pick]", usr)
		show(C)
		return

	if (href_list["force_save"])
		if (alert(usr, "Записать текущее состояние в data/odyssey? (force, даже если active=FALSE)", "Odyssey", "Сохранить", "Отмена") != "Сохранить")
			return
		if (odyssey_save_round(force = TRUE))
			to_chat(usr, SPAN_NOTICE("Odyssey: save OK."))
			log_and_message_admins("forced Odyssey save", usr)
		else
			to_chat(usr, SPAN_WARNING("Odyssey: save failed."))
		show(C)
		return

	if (href_list["force_apply"])
		if (alert(usr, "Наложить сейв на текущую карту? Это необратимо для тайлов/машин/меха/экономики.", "Odyssey", "Apply", "Отмена") != "Apply")
			return
		if (odyssey_apply_save(force = TRUE))
			to_chat(usr, SPAN_NOTICE("Odyssey: apply OK."))
			log_and_message_admins("forced Odyssey apply", usr)
		else
			to_chat(usr, SPAN_WARNING("Odyssey: apply failed (нет файлов?)."))
		show(C)
		return

	if (href_list["capture_baseline"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		if (state.persist_baselines_ready)
			if (alert(usr, "Baseline уже снят. Перезапись после apply сделает текущие повреждения «чистой картой» — они пропадут со следующего сейва. Перезаписать?", "Odyssey", "Перезаписать", "Отмена") != "Перезаписать")
				return
			odyssey_ensure_persist_baselines(overwrite = TRUE)
		else
			odyssey_ensure_persist_baselines()
		to_chat(usr, SPAN_NOTICE("Odyssey: baseline captured (turfs=[length(state.turf_baseline)] machinery=[length(state.machinery_baseline)])."))
		log_and_message_admins("captured Odyssey persist baselines", usr)
		show(C)
		return

	if (href_list["vote_start"])
		if (!odyssey_lobby_votes_allowed())
			to_chat(usr, SPAN_WARNING("Голосование о старте Одиссеи доступно только в лобби, до начала раунда."))
			return
		if (SSvote?.active_vote)
			to_chat(usr, SPAN_WARNING("Уже идёт другое голосование."))
			return
		SSvote.initiate_vote(/datum/vote/odyssey_start, usr, automatic = 0)
		log_and_message_admins("initiated Odyssey start vote", usr)
		show(C)
		return

	if (href_list["vote_continue"])
		if (!odyssey_lobby_votes_allowed())
			to_chat(usr, SPAN_WARNING("Голосование о продолжении Одиссеи доступно только в лобби, до начала раунда."))
			return
		if (SSvote?.active_vote)
			to_chat(usr, SPAN_WARNING("Уже идёт другое голосование."))
			return
		SSvote.initiate_vote(/datum/vote/odyssey_continue, usr, automatic = 0)
		log_and_message_admins("initiated Odyssey continue vote", usr)
		show(C)
		return


/datum/odyssey_panel/proc/show_preview(client/C, kind)
	if (!C || !kind)
		return
	var/list/meta = odyssey_load_meta()
	var/list/data = odyssey_read_json(odyssey_snapshot_path(kind, meta?["generation"]))
	var/list/dat = list()
	dat += "<a href='?src=\ref[src];refresh=1'>← Назад</a><hr>"
	dat += "<h3>Превью: [html_encode(kind)].json</h3>"
	if (!islist(data))
		dat += "<i>Не удалось прочитать.</i>"
	else
		var/preview
		if (kind == "economy" || kind == "research")
			preview = json_encode(data["data"] || data)
		else
			var/list/entries = data["entries"]
			if (!islist(entries))
				preview = json_encode(data)
			else
				var/list/slice = list()
				var/limit = min(20, length(entries))
				for (var/i = 1 to limit)
					slice += list(entries[i])
				preview = "entries=[length(entries)], first [limit]:\n[json_encode(slice)]"
		dat += "<pre style='white-space:pre-wrap; word-break:break-all;'>[html_encode(preview)]</pre>"

	var/datum/browser/popup = new(C.mob, "odyssey_panel", "Odyssey Panel", 760, 820, src)
	popup.set_content(jointext(dat, null))
	popup.open()


/proc/odyssey_snapshot_summary(kind)
	var/list/out = list("exists" = FALSE, "version" = null, "count" = 0)
	var/list/meta = odyssey_load_meta()
	var/path = odyssey_snapshot_path(kind, meta?["generation"])
	if (!fexists(path))
		return out
	out["exists"] = TRUE
	var/list/data = odyssey_read_json(path)
	if (!islist(data))
		return out
	out["version"] = data["version"]
	if (kind == "economy")
		var/list/econ = data["data"]
		var/dept_count = 0
		if (islist(econ?["departments"]))
			dept_count = length(econ["departments"])
		out["count"] = (econ?["station"] ? 1 : 0) + dept_count
	else if (kind == "research")
		var/list/research = data["data"]
		out["count"] = islist(research?["active_briefs"]) ? length(research["active_briefs"]) : 0
	else if (kind == "newscast")
		var/list/news = data["data"]
		out["count"] = islist(news?["channels"]) ? length(news["channels"]) : 0
	else if (kind == "chronicle")
		out["count"] = islist(data["entries"]) ? length(data["entries"]) : 0
	else if (islist(data["entries"]))
		out["count"] = length(data["entries"])
	return out
