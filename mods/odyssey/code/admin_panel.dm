/// Admin debug/info panel for Odyssey campaign state and on-disk saves.
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
	set desc = "Просмотр состояния Одиссеи и отладочные действия."

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
	var/map_key = odyssey_map_key()

	var/list/dat = list()
	dat += "<div align='center'><h1>Одиссея</h1></div>"
	dat += "<a href='?src=\ref[src];refresh=1'>Обновить</a>"
	dat += "<hr>"

	dat += "<h3>Раунд (runtime)</h3>"
	dat += "<div class='statusDisplay'>"
	dat += "Карта: <b>[html_encode(map_key)]</b><br>"
	dat += "active: <b>[state.active ? "ДА" : "нет"]</b> | "
	dat += "continued: <b>[state.continued ? "ДА" : "нет"]</b> | "
	dat += "pregame_vote_done: <b>[state.pregame_vote_done ? "да" : "нет"]</b><br>"
	dat += "campaign_id: <code>[html_encode("[state.campaign_id]")]</code><br>"
	dat += "status: <b>[state.status]</b> | outcome: <b>[html_encode("[state.outcome_reason]")]</b><br>"
	dat += "эшелон: <b>[odyssey_campaign_echelon(state)]/[state.max_shifts]</b> | crew shift: <b>[state.shift_number]</b> | save_version: <b>[state.save_version]</b><br>"
	dat += "sector: <b>[html_encode("[state.current_sector_id]")]</b> → selected: <b>[html_encode("[state.selected_sector_id]")]</b> | committed: <b>[state.transition_committed]</b> | bsd jump: <b>[state.odyssey_bsd_jump_done]</b><br>"
	dat += "seed: <code>[html_encode("[state.campaign_seed]")]</code><br>"
	dat += "turf_baseline: <b>[length(state.turf_baseline)]</b> ключей<br>"
	dat += "machinery baseline: <b>[length(state.machinery_baseline)]</b> | structures: <b>[length(state.structure_baseline)]</b><br>"
	dat += "abandoned shuttles: <b>[length(state.abandoned_shuttles)]</b> <code>[html_encode(english_list(state.abandoned_shuttles) || "—")]</code><br>"
	dat += "Лобби сейчас: <b>[lobby_count]</b> (continue нужен ≥ [ODYSSEY_MIN_CONTINUE_PLAYERS] игроков; старт/continue — ≥ [ODYSSEY_MIN_YES_VOTES] голосов «За»)<br>"
	dat += "GAME_STATE: <b>[GAME_STATE]</b>"
	dat += "</div>"

	dat += "<h3>Диск (campaign.json)</h3>"
	dat += "<div class='statusDisplay'>"
	if (!islist(meta))
		dat += "<i>Нет meta / файл отсутствует.</i><br>"
		dat += "Путь: <code>[html_encode(odyssey_meta_path())]</code>"
	else
		dat += "exists/active для continue: <b>[has_campaign ? "ДА" : "нет"]</b><br>"
		dat += "version: <b>[meta["version"]]</b> | disk active: <b>[meta["active"] ? "ДА" : "нет"]</b><br>"
		dat += "campaign_id: <code>[html_encode("[meta["campaign_id"]]")]</code><br>"
		dat += "status: <b>[meta["status"]]</b> | shift: <b>[meta["shift_number"]]/[meta["max_shifts"]]</b><br>"
		dat += "sector: <b>[meta["current_sector_id"]]</b> → <b>[meta["selected_sector_id"]]</b><br>"
		dat += "map: <b>[html_encode("[meta["map"]]")]</b><br>"
		dat += "saved_at: <b>[html_encode("[meta["saved_at"]]")]</b><br>"
		if (meta["archived_at"])
			dat += "archived_at: <b>[html_encode("[meta["archived_at"]]")]</b> "
			dat += "reason: <b>[html_encode("[meta["archive_reason"]]")]</b><br>"
		dat += "parts: <code>[html_encode(json_encode(meta["parts"]))]</code><br>"
		dat += "Путь: <code>[html_encode(odyssey_meta_path())]</code>"
	dat += "</div>"

	dat += "<h3>Снапшоты</h3>"
	dat += "<div class='statusDisplay'>"
	dat += "<table width='100%'>"
	dat += "<tr><th>Файл</th><th>Есть</th><th>Версия</th><th>Записей</th><th></th></tr>"
	for (var/kind in list("turfs", "machinery", "structures", "mechs", "economy", "roster", "newscast", "corpses"))
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

	dat += "<h3>Маршрут и roster</h3><div class='statusDisplay'>"
	if (islist(state.sector_graph))
		for (var/id in state.sector_graph)
			var/list/node = state.sector_graph[id]
			dat += "<b>[id]</b>: [html_encode(node["name"])] depth=[node["depth"]] danger=[node["danger"]] links=[html_encode(json_encode(node["links"]))] "
			dat += "<a href='?src=\ref[src];force_destination=[url_encode(id)]'>force destination</a><br>"
	dat += "<hr>Участники: <b>[length(state.roster)]</b><br>"
	for (var/key in state.roster)
		var/list/member = state.roster[key]
		dat += "[html_encode(member["name"])] ([key]): <b>[member["status"]]</b>"
		if (member["death_shift"])
			dat += " — смерть в смене [member["death_shift"]] ([member["death_reason"]])"
		dat += "<br>"
	dat += "<hr>Спящие агенты: <b>[length(state.sleepers)]</b> (active [odyssey_count_active_sleepers()]) | midround done: <b>[state.sleeper_midround_done ? "да" : "нет"]</b><br>"
	for (var/skey in state.sleepers)
		var/list/sleeper = state.sleepers[skey]
		if (!islist(sleeper))
			continue
		dat += "[html_encode(sleeper["name"])] ([skey]): <b>[sleeper["status"]]</b> shift=[sleeper["assigned_shift"]] source=[sleeper["source"]]"
		if (sleeper["death_shift"])
			dat += " — снят в смене [sleeper["death_shift"]] ([sleeper["death_reason"]])"
		dat += "<br>"
	dat += "<hr>Mercenaries (nuke): <b>[state.merc_used ? "уже были" : "ещё нет"]</b>"
	if (state.merc_used)
		dat += " — смена [state.merc_used_shift] ([html_encode("[state.merc_used_reason]")])"
	else if (state.merc_shift_decision)
		dat += " | решение смены: <b>[html_encode(state.merc_shift_decision)]</b>"
	dat += "<br>"
	dat += "Hostile outsiders: raiders=<b>[html_encode("[state.raider_shift_decision || "—"]")]</b> | ninja=<b>[html_encode("[state.ninja_shift_decision || "—"]")]</b> | sector danger=<b>[html_encode(odyssey_current_sector_danger())]</b><br>"
	if (length(state.validation_errors))
		dat += "<hr><font color='cc5555'>Ошибки: [html_encode(json_encode(state.validation_errors))]</font>"
	dat += "</div>"

	dat += "<h3>Экономика (live)</h3>"
	dat += "<div class='statusDisplay'>"
	if (istype(station_account))
		dat += "Станция #[station_account.account_number]: <b>[station_account.money]</b><br>"
	else
		dat += "Станционный счёт: нет<br>"
	for (var/dept in department_accounts)
		var/datum/money_account/A = department_accounts[dept]
		if (!istype(A))
			continue
		dat += "[html_encode("[dept]")]: <b>[A.money]</b><br>"
	dat += "</div>"

	dat += "<h3>Действия</h3>"
	dat += "<div class='statusDisplay'>"
	dat += "<b>Флаги раунда:</b><br>"
	dat += "<a href='?src=\ref[src];toggle_active=1'>Toggle active</a> | "
	dat += "<a href='?src=\ref[src];toggle_continued=1'>Toggle continued</a> | "
	dat += "<a href='?src=\ref[src];reset_vote_flag=1'>Сбросить pregame_vote_done</a><br><br>"

	dat += "<b>Кампания:</b><br>"
	dat += "<a href='?src=\ref[src];begin_new=1'>Начать новую (active, не continued)</a> | "
	dat += "<a href='?src=\ref[src];begin_continue=1'>Пометить продолжение (active+continued)</a><br>"
	dat += "<a href='?src=\ref[src];archive=1'><font color='cc5555'>Архивировать кампанию на диске</font></a><br><br>"
	dat += "<a href='?src=\ref[src];validate=1'>Validate save (dry-run)</a> | "
	dat += "<a href='?src=\ref[src];regenerate=1'>Regenerate graph</a> | "
	dat += "<a href='?src=\ref[src];finish=1'><font color='cc5555'>Finish campaign</font></a><br><br>"

	dat += "<b>Сейв / apply:</b><br>"
	dat += "<a href='?src=\ref[src];force_save=1'>Force save</a> | "
	dat += "<a href='?src=\ref[src];force_apply=1'><font color='cc5555'>Force apply</font></a> | "
	dat += "<a href='?src=\ref[src];capture_baseline=1'>Capture turf baseline</a><br><br>"

	dat += "<b>Голосование:</b> только лобби, до старта раунда.<br>"
	if (GAME_STATE == RUNLEVEL_LOBBY)
		dat += "<a href='?src=\ref[src];vote_start=1'>Initiate start vote</a> | "
		dat += "<a href='?src=\ref[src];vote_continue=1'>Initiate continue vote</a>"
	else
		dat += "<i>Start / Continue недоступны: раунд уже идёт.</i>"
	dat += "</div>"

	var/datum/browser/popup = new(C.mob, "odyssey_panel", "Odyssey Panel", 720, 780, src)
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

	if (href_list["toggle_active"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		state.active = !state.active
		log_and_message_admins("toggled Odyssey active=[state.active]", usr)
		show(C)
		return

	if (href_list["toggle_continued"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		state.continued = !state.continued
		log_and_message_admins("toggled Odyssey continued=[state.continued]", usr)
		show(C)
		return

	if (href_list["reset_vote_flag"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		state.pregame_vote_done = FALSE
		log_and_message_admins("reset Odyssey pregame_vote_done", usr)
		show(C)
		return

	if (href_list["begin_new"])
		if (alert(usr, "Пометить раунд как новую Одиссею (без apply)?", "Odyssey", "Да", "Нет") != "Да")
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
		if (alert(usr, "Пометить раунд как продолжение? Apply сам не запустится — используйте Force apply.", "Odyssey", "Да", "Нет") != "Да")
			return
		var/list/meta = odyssey_load_meta()
		if (islist(meta) && !meta["active"])
			if (alert(usr, "На диске кампания неактивна (status=[meta["status"]], reason=[meta["archive_reason"] || meta["outcome_reason"] || "—"]). Восстановить active и продолжить?", "Odyssey", "Восстановить", "Отмена") != "Восстановить")
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

	if (href_list["validate"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		state.validation_errors = odyssey_validate_save()
		to_chat(usr, length(state.validation_errors) ? SPAN_WARNING("Odyssey: validation errors: [json_encode(state.validation_errors)]") : SPAN_NOTICE("Odyssey: save validation OK."))
		show(C)
		return

	if (href_list["regenerate"])
		var/datum/odyssey_state/state = odyssey_ensure_state()
		if (state.shift_number > 1 || length(state.route_history) > 1)
			to_chat(usr, SPAN_WARNING("Граф можно пересоздать только до первого перехода."))
			return
		if (alert(usr, "Пересоздать секторный граф с новым seed?", "Odyssey", "Да", "Нет") != "Да")
			return
		state.campaign_seed = "[state.campaign_id]:admin:[world.realtime]"
		state.sector_graph = odyssey_generate_sector_graph(state.campaign_seed)
		state.current_sector_id = ODYSSEY_SECTOR_START
		state.selected_sector_id = null
		state.validation_errors = odyssey_validate_graph(state.sector_graph)
		log_and_message_admins("regenerated Odyssey sector graph", usr)
		show(C)
		return

	if (href_list["force_destination"])
		if (odyssey_select_sector(href_list["force_destination"], usr, TRUE))
			log_and_message_admins("forced Odyssey destination [href_list["force_destination"]]", usr)
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
		if (kind == "economy")
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

	var/datum/browser/popup = new(C.mob, "odyssey_panel", "Odyssey Panel", 720, 780, src)
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
	else if (kind == "newscast")
		var/list/news = data["data"]
		out["count"] = islist(news?["channels"]) ? length(news["channels"]) : 0
	else if (islist(data["entries"]))
		out["count"] = length(data["entries"])
	return out
