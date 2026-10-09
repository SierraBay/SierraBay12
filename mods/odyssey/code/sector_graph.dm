/// Deterministic integer without changing BYOND's global RNG state.
/proc/odyssey_seed_roll(seed, salt, low, high)
	if (high <= low)
		return low
	var/hash = md5("[seed]:[salt]")
	var/value = 0
	for (var/i = 1 to length(hash))
		value += text2ascii(hash, i) * i
	return low + (value % (high - low + 1))


/proc/odyssey_sector_danger(seed, sector_id, depth, terminal = FALSE)
	if (sector_id == ODYSSEY_SECTOR_START)
		return ODYSSEY_DANGER_SAFE
	var/roll = odyssey_seed_roll(seed, "danger:[sector_id]", 1, 100)
	if (terminal)
		roll += 15
	roll += max(0, depth - 2) * 8
	if (roll >= 80)
		return ODYSSEY_DANGER_HOSTILE
	if (roll >= 55)
		return ODYSSEY_DANGER_DANGEROUS
	if (roll >= 25)
		return ODYSSEY_DANGER_CIVILIAN
	return ODYSSEY_DANGER_SAFE


/proc/odyssey_sector_blurb(seed, sector_id, danger, depth, terminal = FALSE)
	var/list/blurbs = list(
		ODYSSEY_DANGER_SAFE = list(
			"Сканеры отмечают спокойный вакуум и слабые навигационные маяки. Переход должен пройти без сюрпризов.",
			"Плотность трафика низкая. Местные карты рекомендуют этот участок как безопасный коридор.",
			"Космическая погода стабильна. На дальних частотах слышен только фоновый шум."
		),
		ODYSSEY_DANGER_CIVILIAN = list(
			"В секторе фиксируются гражданские сигналы и торговые буи. Возможны запросы о помощи или досмотре.",
			"Пограничный узел с активным судоходством. Власти сектора могут проявить интерес к Сьерре.",
			"Колониальные ретрансляторы работают нестабильно, но маршрут известен местным капитанам."
		),
		ODYSSEY_DANGER_DANGEROUS = list(
			"Туманность и электромагнитные бури ухудшают сенсоры. Ожидаются ионные и пылевые фронты.",
			"Обломки старых переходов засоряют гиперкоридор. Рекомендуется повышенная готовность инженерного состава.",
			"Аномальная плотность материи. Навигация возможна, но курс потребует постоянной коррекции."
		),
		ODYSSEY_DANGER_HOSTILE = list(
			"Сканеры ловят враждебные сигнатуры и следы недавних боёв. Сектор считается опасным для одиночных судов.",
			"Местные карты помечены алыми метками. Вероятны пиратские засады или хищная фауна.",
			"Сильный гравитационный и биотический фон. Командование советует считать любой контакт враждебным."
		)
	)
	var/list/pool = blurbs[danger] || blurbs[ODYSSEY_DANGER_SAFE]
	var/index = odyssey_seed_roll(seed, "blurb:[sector_id]", 1, length(pool))
	var/text = pool[index]
	if (terminal)
		text += " Это конечная точка текущего маршрута Одиссеи."
	else if (depth >= ODYSSEY_MAX_SHIFTS - 1)
		text += " Дальше остаётся лишь последний эшелон перехода."
	return text


/proc/odyssey_make_sector(seed, id, depth, terminal = FALSE)
	var/danger = odyssey_sector_danger(seed, id, depth, terminal)
	var/list/names = list(
		ODYSSEY_DANGER_SAFE = list("Тихая гавань", "Пустой рубеж", "Маяк"),
		ODYSSEY_DANGER_CIVILIAN = list("Колониальный узел", "Торговый коридор", "Пограничье"),
		ODYSSEY_DANGER_DANGEROUS = list("Ионный фронт", "Разбитый пояс", "Штормовой карман"),
		ODYSSEY_DANGER_HOSTILE = list("Красная зона", "Враждебный рубеж", "Гнездо Левиафана")
	)
	var/list/pool = names[danger]
	var/name_index = odyssey_seed_roll(seed, "name:[id]", 1, length(pool))
	return list(
		"id" = id,
		"name" = "[pool[name_index]] [depth]",
		"depth" = depth,
		"danger" = danger,
		"terminal" = terminal,
		"summary" = odyssey_sector_blurb(seed, id, danger, depth, terminal),
		"seed" = odyssey_seed_roll(seed, "sector:[id]", 1, 2000000000),
		"x" = 0,
		"y" = 0,
		"links" = list()
	)


/proc/odyssey_add_link(list/graph, from_id, to_id)
	if (!islist(graph[from_id]) || !islist(graph[to_id]))
		return
	var/list/links = graph[from_id]["links"]
	if (!islist(links))
		links = list()
		graph[from_id]["links"] = links
	if (!(to_id in links))
		links += to_id


/proc/odyssey_sort_ids_by_seed(list/ids, seed)
	var/list/ordered = ids.Copy()
	for (var/i = 1 to length(ordered))
		for (var/j = 1 to length(ordered) - i)
			var/left = ordered[j]
			var/right = ordered[j + 1]
			var/left_rank = odyssey_seed_roll(seed, "lane:[left]", 1, 100000)
			var/right_rank = odyssey_seed_roll(seed, "lane:[right]", 1, 100000)
			if (left_rank > right_rank || (left_rank == right_rank && left > right))
				ordered[j] = right
				ordered[j + 1] = left
	return ordered


/// Assigns percentage map coordinates from the campaign seed. No hardcoded fallbacks.
/proc/odyssey_layout_sector_graph(list/graph, seed)
	var/list/by_depth = list()
	for (var/id in graph)
		var/list/node = graph[id]
		var/depth = node["depth"]
		var/key = "[depth]"
		if (!islist(by_depth[key]))
			by_depth[key] = list()
		by_depth[key] += id

	for (var/key in by_depth)
		var/depth = text2num(key)
		var/list/ids = odyssey_sort_ids_by_seed(by_depth[key], seed)
		var/count = length(ids)
		var/base_x = 8 + round((depth - 1) * ((90 - 8) / max(1, ODYSSEY_MAX_SHIFTS - 1)))
		for (var/i = 1 to count)
			var/id = ids[i]
			var/list/node = graph[id]
			var/x = clamp(base_x + odyssey_seed_roll(seed, "pos-x:[id]", -4, 4), 6, 94)
			var/y
			if (count == 1)
				y = clamp(odyssey_seed_roll(seed, "pos-y:[id]", 38, 62), 10, 90)
			else
				var/span_low = 12
				var/span_high = 88
				var/step = (span_high - span_low) / (count - 1)
				var/base_y = span_high - round((i - 1) * step)
				y = clamp(base_y + odyssey_seed_roll(seed, "pos-y:[id]", -5, 5), 10, 90)
			node["x"] = x
			node["y"] = y


/// Generates an FTL-like branching mesh with cross-links and terminals at shifts 3, 4 and 5.
/proc/odyssey_generate_sector_graph(seed)
	var/list/graph = list()
	graph[ODYSSEY_SECTOR_START] = odyssey_make_sector(seed, ODYSSEY_SECTOR_START, 1)

	// Column 2 — opening fork.
	graph["d2_north"] = odyssey_make_sector(seed, "d2_north", 2)
	graph["d2_mid"] = odyssey_make_sector(seed, "d2_mid", 2)
	graph["d2_south"] = odyssey_make_sector(seed, "d2_south", 2)

	// Column 3 — short finish plus continuing branches.
	graph["finish_3"] = odyssey_make_sector(seed, "finish_3", 3, TRUE)
	graph["d3_high"] = odyssey_make_sector(seed, "d3_high", 3)
	graph["d3_mid"] = odyssey_make_sector(seed, "d3_mid", 3)
	graph["d3_low"] = odyssey_make_sector(seed, "d3_low", 3)

	// Column 4 — mid finish plus deep routes.
	graph["finish_4"] = odyssey_make_sector(seed, "finish_4", 4, TRUE)
	graph["d4_high"] = odyssey_make_sector(seed, "d4_high", 4)
	graph["d4_low"] = odyssey_make_sector(seed, "d4_low", 4)

	// Column 5 — long finish.
	graph["finish_5"] = odyssey_make_sector(seed, "finish_5", 5, TRUE)

	// Forward links with cross-branch hops so routes can merge and diverge.
	odyssey_add_link(graph, ODYSSEY_SECTOR_START, "d2_north")
	odyssey_add_link(graph, ODYSSEY_SECTOR_START, "d2_mid")
	odyssey_add_link(graph, ODYSSEY_SECTOR_START, "d2_south")

	odyssey_add_link(graph, "d2_north", "finish_3")
	odyssey_add_link(graph, "d2_north", "d3_high")
	odyssey_add_link(graph, "d2_mid", "d3_high")
	odyssey_add_link(graph, "d2_mid", "d3_mid")
	odyssey_add_link(graph, "d2_south", "d3_mid")
	odyssey_add_link(graph, "d2_south", "d3_low")
	if (odyssey_seed_roll(seed, "cross:d2_north_mid", 1, 100) > 35)
		odyssey_add_link(graph, "d2_north", "d3_mid")
	if (odyssey_seed_roll(seed, "cross:d2_mid_low", 1, 100) > 35)
		odyssey_add_link(graph, "d2_mid", "d3_low")

	odyssey_add_link(graph, "d3_high", "finish_4")
	odyssey_add_link(graph, "d3_high", "d4_high")
	odyssey_add_link(graph, "d3_mid", "d4_high")
	odyssey_add_link(graph, "d3_mid", "d4_low")
	odyssey_add_link(graph, "d3_low", "d4_low")
	if (odyssey_seed_roll(seed, "cross:d3_low_finish4", 1, 100) > 50)
		odyssey_add_link(graph, "d3_low", "finish_4")
	if (odyssey_seed_roll(seed, "cross:d3_high_low", 1, 100) > 45)
		odyssey_add_link(graph, "d3_high", "d4_low")

	odyssey_add_link(graph, "d4_high", "finish_5")
	odyssey_add_link(graph, "d4_low", "finish_5")
	odyssey_layout_sector_graph(graph, seed)
	return graph


/proc/odyssey_get_sector(sector_id, datum/odyssey_state/state = odyssey_ensure_state())
	if (!sector_id || !islist(state.sector_graph))
		return null
	var/list/sector = state.sector_graph[sector_id]
	return islist(sector) ? sector : null


/// Graph hop (1–5). Crew shift changes in the same sector do not advance this.
/proc/odyssey_sector_echelon(sector_id, list/graph)
	if (!sector_id || !islist(graph))
		return 1
	var/list/sector = graph[sector_id]
	if (islist(sector) && isnum(sector["depth"]))
		return sector["depth"]
	return 1


/proc/odyssey_campaign_echelon(datum/odyssey_state/state = odyssey_ensure_state())
	return odyssey_sector_echelon(state.current_sector_id, state.sector_graph)


/proc/odyssey_sector_is_available(sector_id, datum/odyssey_state/state = odyssey_ensure_state())
	if (sector_id == ODYSSEY_SECTOR_RETURN)
		return !!state.active
	var/list/current = odyssey_get_sector(state.current_sector_id, state)
	if (!islist(current))
		return FALSE
	if (sector_id == ODYSSEY_SECTOR_COMPLETE)
		return !!current["terminal"]
	var/list/links = current["links"]
	return islist(links) && (sector_id in links)


/proc/odyssey_select_sector(sector_id, mob/user, force = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || state.status != ODYSSEY_STATUS_ACTIVE || state.transition_committed)
		return FALSE
	if (!force && !odyssey_sector_is_available(sector_id, state))
		return FALSE
	if (!(sector_id in list(ODYSSEY_SECTOR_RETURN, ODYSSEY_SECTOR_COMPLETE)) && !odyssey_get_sector(sector_id, state))
		return FALSE
	state.selected_sector_id = sector_id
	state.selected_by = user ? odyssey_actor_ic_name(user) : "системный оператор"
	log_game("ODYSSEY: destination selected [sector_id] by [user ? key_name(user) : "admin/system"] (IC: [state.selected_by])")
	return TRUE


/proc/odyssey_validate_graph(list/graph)
	var/list/errors = list()
	if (!islist(graph) || !islist(graph[ODYSSEY_SECTOR_START]))
		errors += "sector graph has no start node"
		return errors
	for (var/id in graph)
		var/list/node = graph[id]
		if (!islist(node))
			errors += "sector [id] is not a list"
			continue
		var/depth = node["depth"]
		if (!isnum(depth) || depth < 1 || depth > ODYSSEY_MAX_SHIFTS)
			errors += "sector [id] has invalid depth"
		var/x = node["x"]
		var/y = node["y"]
		if (!isnum(x) || x < 0 || x > 100)
			errors += "sector [id] has invalid map x"
		if (!isnum(y) || y < 0 || y > 100)
			errors += "sector [id] has invalid map y"
		var/list/links = node["links"]
		if (!islist(links))
			errors += "sector [id] has invalid links"
			continue
		for (var/target in links)
			if (!islist(graph[target]))
				errors += "sector [id] links to missing [target]"
			else
				var/list/target_node = graph[target]
				if (target_node["depth"] <= depth)
					errors += "sector [id] links backward/sideways to [target]"
	return errors
