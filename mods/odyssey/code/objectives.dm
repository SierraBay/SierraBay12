/// Campaign contracts (whole Odyssey) and per-shift objectives.

/proc/odyssey_objective_next_id(prefix)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	return "[prefix]-[state.next_objective_id++]"


/proc/odyssey_count_shift_deaths(shift_number)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/count = 0
	for (var/key in state.roster)
		var/list/entry = state.roster[key]
		if (!islist(entry) || entry["status"] != "dead")
			continue
		if (text2num(entry["death_shift"]) == shift_number)
			count++
	return count


/proc/odyssey_abandoned_shuttle_names()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (islist(state.abandoned_shuttles))
		return state.abandoned_shuttles.Copy()
	return list()


/proc/odyssey_make_contract(kind, title, brief, list/extra)
	var/list/entry = list(
		"id" = odyssey_objective_next_id("ctr"),
		"kind" = kind,
		"scope" = "campaign",
		"title" = title,
		"brief" = brief,
		"status" = ODYSSEY_OBJ_STATUS_ACTIVE,
		"visibility" = ODYSSEY_OBJ_VIS_PUBLIC,
		"source" = "generated",
		"shift_issued" = odyssey_ensure_state().shift_number
	)
	if (islist(extra))
		entry += extra
	return entry


/proc/odyssey_make_objective(kind, title, brief, list/extra)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/entry = list(
		"id" = odyssey_objective_next_id("obj"),
		"kind" = kind,
		"scope" = "shift",
		"title" = title,
		"brief" = brief,
		"status" = ODYSSEY_OBJ_STATUS_ACTIVE,
		"progress" = 0,
		"target" = 1,
		"visibility" = ODYSSEY_OBJ_VIS_PUBLIC,
		"source" = "generated",
		"sector_id" = state.current_sector_id,
		"shift_issued" = state.shift_number
	)
	if (islist(extra))
		entry += extra
	return entry


/proc/odyssey_ensure_campaign_contract()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	if (!islist(state.contracts))
		state.contracts = list()
	for (var/list/entry in state.contracts)
		if (islist(entry) && entry["status"] == ODYSSEY_OBJ_STATUS_ACTIVE)
			return
	// Default campaign contract: reach a terminal sector.
	var/list/contract = odyssey_make_contract(
		ODYSSEY_OBJ_KIND_REACH_FINAL,
		"Дойти до конечного сектора",
		"Сьерра должна завершить маршрут Одиссеи в одном из финальных секторов эшелона.",
		list("complete_on" = list(ODYSSEY_STATUS_COMPLETED), "fail_on" = list(ODYSSEY_STATUS_SHIP_DESTROYED, ODYSSEY_STATUS_EVACUATED, ODYSSEY_STATUS_CREW_LOST))
	)
	state.contracts += list(contract)
	odyssey_chronicle_append(
		ODYSSEY_CHRONICLE_KIND_CONTRACT,
		"Контракт: [contract["title"]]",
		contract["brief"],
		ODYSSEY_CHRONICLE_VIS_PUBLIC,
		list("id" = contract["id"], "kind" = contract["kind"])
	)


/proc/odyssey_expire_shift_objectives(reason = "shift_ended")
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!islist(state.objectives))
		return
	for (var/i = 1 to length(state.objectives))
		var/list/entry = state.objectives[i]
		if (!islist(entry) || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
			continue
		if (entry["scope"] != "shift")
			continue
		entry["status"] = ODYSSEY_OBJ_STATUS_EXPIRED
		entry["result_reason"] = reason
		state.objectives[i] = entry


/proc/odyssey_generate_shift_objectives()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	if (!islist(state.objectives))
		state.objectives = list()
	odyssey_expire_shift_objectives("new_shift")

	var/list/sector = odyssey_get_sector(state.current_sector_id, state)
	var/danger = sector?["danger"] || ODYSSEY_DANGER_SAFE
	var/terminal = !!sector?["terminal"]
	var/list/picked = list()
	var/seed = state.campaign_seed || state.campaign_id
	var/roll = odyssey_seed_roll(seed, "shift_obj:[state.shift_number]:[state.current_sector_id]", 1, 100)

	if (danger == ODYSSEY_DANGER_HOSTILE)
		picked += list(odyssey_make_objective(
			ODYSSEY_OBJ_KIND_SURVIVE_HOSTILE,
			"Выжить в красной зоне",
			"Сектор враждебен. Завершите смену без уничтожения Сьерры и без аварийной эвакуации.",
			null
		))
		if (roll > 40)
			picked += list(odyssey_make_objective(
				ODYSSEY_OBJ_KIND_LIMIT_CASUALTIES,
				"Сдержать потери",
				"Не более [ODYSSEY_CASUALTY_HARD_LIMIT] погибших членов экипажа за эту смену.",
				list("target" = ODYSSEY_CASUALTY_HARD_LIMIT, "deaths_at_issue" = odyssey_count_shift_deaths(state.shift_number))
			))
		else
			picked += list(odyssey_make_objective(
				ODYSSEY_OBJ_KIND_NO_SHUTTLE_LOSS,
				"Удержать вспомогательный флот",
				"Не оставляйте tracked-шаттлы вне Сьерры к концу смены.",
				list("baseline_abandoned" = odyssey_abandoned_shuttle_names())
			))
	else if (danger == ODYSSEY_DANGER_DANGEROUS)
		picked += list(odyssey_make_objective(
			ODYSSEY_OBJ_KIND_NO_SHUTTLE_LOSS,
			"Удержать вспомогательный флот",
			"Туманность опасна для отрядов. Верните шаттлы на Сьерру до конца смены.",
			list("baseline_abandoned" = odyssey_abandoned_shuttle_names())
		))
		if (roll > 55)
			picked += list(odyssey_make_objective(
				ODYSSEY_OBJ_KIND_LIMIT_CASUALTIES,
				"Сдержать потери",
				"Не более [ODYSSEY_CASUALTY_SOFT_LIMIT] погибших за смену.",
				list("target" = ODYSSEY_CASUALTY_SOFT_LIMIT, "deaths_at_issue" = odyssey_count_shift_deaths(state.shift_number))
			))
	else
		// Safe / civilian: either hold or push onward (unless already terminal).
		if (terminal || roll <= 45)
			picked += list(odyssey_make_objective(
				ODYSSEY_OBJ_KIND_HOLD_SECTOR,
				"Отработать смену в секторе",
				"Оставайтесь в текущем секторе: завершите смену без Odyssey Jump.",
				null
			))
		else
			picked += list(odyssey_make_objective(
				ODYSSEY_OBJ_KIND_JUMP_ONWARD,
				"Продвинуть маршрут",
				"Командование должно выполнить Odyssey Jump в следующий сектор до конца смены.",
				null
			))
		if (roll > 70)
			picked += list(odyssey_make_objective(
				ODYSSEY_OBJ_KIND_SURVIVE_SHIFT,
				"Стабильная смена",
				"Завершите смену без гибели корабля и без потери всего экипажа.",
				null
			))

	while (length(picked) > ODYSSEY_SHIFT_OBJECTIVE_MAX)
		picked.Cut(length(picked), length(picked) + 1)

	for (var/list/entry in picked)
		state.objectives += list(entry)
		odyssey_chronicle_append(
			ODYSSEY_CHRONICLE_KIND_OBJECTIVE,
			"Цель смены: [entry["title"]]",
			entry["brief"],
			ODYSSEY_CHRONICLE_VIS_PUBLIC,
			list("id" = entry["id"], "kind" = entry["kind"])
		)
	log_game("ODYSSEY: generated [length(picked)] shift objectives danger=[danger] shift=[state.shift_number]")


/proc/odyssey_set_objective_status(list/entry, status, reason)
	if (!islist(entry))
		return
	entry["status"] = status
	entry["result_reason"] = reason
	entry["resolved_shift"] = odyssey_ensure_state().shift_number
	var/kind_label = entry["scope"] == "campaign" ? "Контракт" : "Цель"
	var/result_label = status == ODYSSEY_OBJ_STATUS_COMPLETED ? "выполнен" : (status == ODYSSEY_OBJ_STATUS_FAILED ? "провален" : status)
	odyssey_chronicle_append(
		entry["scope"] == "campaign" ? ODYSSEY_CHRONICLE_KIND_CONTRACT : ODYSSEY_CHRONICLE_KIND_OBJECTIVE,
		"[kind_label] [result_label]: [entry["title"]]",
		reason || "",
		ODYSSEY_CHRONICLE_VIS_PUBLIC,
		list("id" = entry["id"], "status" = status)
	)
	if (status == ODYSSEY_OBJ_STATUS_COMPLETED)
		odyssey_grant_objective_reward(entry)


/proc/odyssey_grant_objective_reward(list/entry)
	if (!islist(entry))
		return
	if (entry["reward_paid"])
		return
	var/list/reward = entry["reward"]
	if (!islist(reward))
		// Default small station payout for completed shift objectives.
		if (entry["scope"] != "shift")
			return
		reward = list("type" = "credits_station", "amount" = 1000)
	var/amount = text2num(reward["amount"]) || 0
	if (amount < 1)
		return
	var/datum/money_account/account
	if (reward["type"] == "credits_dept")
		account = department_accounts[reward["dept"]]
	if (!istype(account))
		account = station_account
	if (!istype(account))
		return
	account.deposit(amount, "Odyssey objective reward: [entry["title"]]", "Odyssey Campaign Systems")
	entry["reward_paid"] = amount


/proc/odyssey_evaluate_shift_objective(list/entry, list/outcome)
	if (!islist(entry) || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
		return
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/kind = entry["kind"]
	switch (kind)
		if (ODYSSEY_OBJ_KIND_HOLD_SECTOR)
			if (state.transition_committed)
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_FAILED, "Выполнен Odyssey Jump вместо удержания сектора.")
			else
				entry["progress"] = 1
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_COMPLETED, "Смена завершена в текущем секторе.")
		if (ODYSSEY_OBJ_KIND_JUMP_ONWARD)
			if (state.transition_committed && state.selected_sector_id && state.selected_sector_id != ODYSSEY_SECTOR_RETURN)
				entry["progress"] = 1
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_COMPLETED, "Совершён переход: [odyssey_sector_display_name(state.selected_sector_id)].")
			else if (state.transition_committed && state.selected_sector_id == ODYSSEY_SECTOR_RETURN)
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_FAILED, "Выбрано возвращение домой вместо продвижения.")
			else
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_FAILED, "Прыжок не выполнен.")
		if (ODYSSEY_OBJ_KIND_NO_SHUTTLE_LOSS)
			var/list/baseline = entry["baseline_abandoned"]
			if (!islist(baseline))
				baseline = list()
			var/list/now = odyssey_abandoned_shuttle_names()
			var/list/new_lost = list()
			for (var/name in now)
				if (!(name in baseline))
					new_lost += name
			entry["progress"] = length(baseline)
			entry["target"] = length(baseline)
			if (length(new_lost))
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_FAILED, "Утеряны шаттлы: [english_list(new_lost)].")
			else
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_COMPLETED, "Новых потерь шаттлов нет.")
		if (ODYSSEY_OBJ_KIND_LIMIT_CASUALTIES)
			var/limit = text2num(entry["target"]) || ODYSSEY_CASUALTY_SOFT_LIMIT
			var/deaths = odyssey_count_shift_deaths(state.shift_number)
			entry["progress"] = deaths
			entry["target"] = limit
			if (deaths > limit)
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_FAILED, "Погибших за смену: [deaths] (лимит [limit]).")
			else
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_COMPLETED, "Погибших за смену: [deaths] / [limit].")
		if (ODYSSEY_OBJ_KIND_SURVIVE_HOSTILE)
			if (islist(outcome) && (outcome["status"] in list(ODYSSEY_STATUS_SHIP_DESTROYED, ODYSSEY_STATUS_EVACUATED, ODYSSEY_STATUS_CREW_LOST)))
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_FAILED, "Корабль/экипаж потеряны в hostile-секторе ([outcome["status"]]).")
			else
				entry["progress"] = 1
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_COMPLETED, "Смена в hostile-секторе пережита.")
		if (ODYSSEY_OBJ_KIND_SURVIVE_SHIFT)
			if (islist(outcome) && (outcome["status"] in list(ODYSSEY_STATUS_SHIP_DESTROYED, ODYSSEY_STATUS_EVACUATED, ODYSSEY_STATUS_CREW_LOST)))
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_FAILED, "Катастрофический исход смены ([outcome["status"]]).")
			else
				entry["progress"] = 1
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_COMPLETED, "Смена завершена без потери корабля.")
		else
			odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_EXPIRED, "Неизвестный тип цели.")


/proc/odyssey_evaluate_contract(list/entry, list/outcome)
	if (!islist(entry) || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
		return
	if (!islist(outcome))
		return
	var/status = outcome["status"]
	var/list/complete_on = entry["complete_on"]
	var/list/fail_on = entry["fail_on"]
	if (islist(fail_on) && (status in fail_on))
		odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_FAILED, "Исход кампании: [status] ([outcome["reason"]]).")
		return
	if (islist(complete_on) && (status in complete_on))
		odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_COMPLETED, "Исход кампании: [status].")
		return
	// Special-case kinds without explicit lists.
	switch (entry["kind"])
		if (ODYSSEY_OBJ_KIND_REACH_FINAL)
			if (status == ODYSSEY_STATUS_COMPLETED)
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_COMPLETED, "Финальный сектор достигнут.")
			else if (status in list(ODYSSEY_STATUS_SHIP_DESTROYED, ODYSSEY_STATUS_EVACUATED, ODYSSEY_STATUS_CREW_LOST, ODYSSEY_STATUS_RETURNED))
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_FAILED, "Кампания закончилась без финального сектора ([status]).")
		if (ODYSSEY_OBJ_KIND_RETURN_HOME)
			if (status == ODYSSEY_STATUS_RETURNED)
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_COMPLETED, "Сьерра вернулась домой.")
			else if (status in list(ODYSSEY_STATUS_COMPLETED, ODYSSEY_STATUS_SHIP_DESTROYED, ODYSSEY_STATUS_EVACUATED, ODYSSEY_STATUS_CREW_LOST))
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_FAILED, "Возвращение не выполнено ([status]).")
		if (ODYSSEY_OBJ_KIND_SHIP_INTACT)
			if (status in list(ODYSSEY_STATUS_SHIP_DESTROYED, ODYSSEY_STATUS_EVACUATED))
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_FAILED, "Корабль потерян или эвакуирован.")
			else if (status in list(ODYSSEY_STATUS_COMPLETED, ODYSSEY_STATUS_RETURNED))
				odyssey_set_objective_status(entry, ODYSSEY_OBJ_STATUS_COMPLETED, "Корабль доведён до исхода кампании.")


/proc/odyssey_evaluate_objectives(list/outcome)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	if (islist(state.objectives))
		for (var/i = 1 to length(state.objectives))
			var/list/entry = state.objectives[i]
			if (!islist(entry) || entry["scope"] != "shift")
				continue
			odyssey_evaluate_shift_objective(entry, outcome)
			state.objectives[i] = entry
	if (islist(outcome) && islist(state.contracts))
		for (var/i = 1 to length(state.contracts))
			var/list/contract = state.contracts[i]
			if (!islist(contract))
				continue
			odyssey_evaluate_contract(contract, outcome)
			state.contracts[i] = contract


/proc/odyssey_objectives_ui_entries(min_visibility = ODYSSEY_OBJ_VIS_PUBLIC)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/allow_command = (min_visibility == ODYSSEY_OBJ_VIS_COMMAND || min_visibility == ODYSSEY_CHRONICLE_VIS_ADMIN)
	var/list/out = list()
	var/list/pools = list(state.contracts, state.objectives)
	for (var/list/pool in pools)
		if (!islist(pool))
			continue
		for (var/list/entry in pool)
			if (!islist(entry))
				continue
			var/vis = entry["visibility"] || ODYSSEY_OBJ_VIS_PUBLIC
			if (vis == ODYSSEY_OBJ_VIS_COMMAND && !allow_command)
				continue
			out += list(list(
				"id" = entry["id"],
				"scope" = entry["scope"],
				"kind" = entry["kind"],
				"title" = entry["title"],
				"brief" = entry["brief"],
				"status" = entry["status"],
				"progress" = entry["progress"],
				"target" = entry["target"],
				"shift_issued" = entry["shift_issued"]
			))
	return out
