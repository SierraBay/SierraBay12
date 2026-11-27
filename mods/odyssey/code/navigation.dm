/// Builds NanoUI payload for the Odyssey sector map.
/proc/odyssey_build_map_ui_data(viewed_sector_id, can_plot)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/current_sector = odyssey_get_sector(state.current_sector_id, state)
	var/list/data = list(
		"active" = state.active,
		"shift" = odyssey_campaign_echelon(state),
		"max_shifts" = state.max_shifts,
		"current_id" = state.current_sector_id,
		"current_name" = odyssey_sector_display_name(state.current_sector_id),
		"selected_id" = state.selected_sector_id,
		"selected_name" = state.selected_sector_id ? odyssey_sector_display_name(state.selected_sector_id) : "не выбран",
		"selected_by" = state.selected_by,
		"can_access" = !!can_plot,
		"terminal" = islist(current_sector) && !!current_sector["terminal"],
		"has_view" = FALSE
	)
	var/list/nodes = list()
	var/list/lines = list()
	var/choice_index = 0
	if (state.active && islist(state.sector_graph))
		for (var/id in state.sector_graph)
			var/list/node = state.sector_graph[id]
			var/available = odyssey_sector_is_available(id, state)
			var/choice_label = null
			if (available)
				choice_index += 1
				choice_label = "[choice_index]. [node["name"]]"
			nodes += list(list(
				"id" = id,
				"name" = node["name"],
				"danger" = node["danger"],
				"visual" = odyssey_danger_visual(node["danger"]),
				"danger_label" = odyssey_danger_label(node["danger"]),
				"x" = node["x"],
				"y" = node["y"],
				"available" = available,
				"choice_label" = choice_label,
				"current" = id == state.current_sector_id,
				"selected" = id == state.selected_sector_id,
				"viewed" = id == viewed_sector_id,
				"terminal" = node["terminal"]
			))
			var/list/links = node["links"]
			for (var/target_id in links)
				var/list/target_node = state.sector_graph[target_id]
				if (!islist(target_node))
					continue
				lines += list(list(
					"x1" = node["x"],
					"y1" = 100 - node["y"],
					"x2" = target_node["x"],
					"y2" = 100 - target_node["y"]
				))
	data["nodes"] = nodes
	data["lines"] = lines

	var/list/viewed = odyssey_get_sector(viewed_sector_id, state)
	if (islist(viewed))
		var/list/exit_names = list()
		var/list/view_links = viewed["links"]
		if (islist(view_links))
			for (var/exit_id in view_links)
				exit_names += odyssey_sector_display_name(exit_id)
		var/summary = viewed["summary"]
		if (!summary)
			summary = odyssey_sector_blurb(state.campaign_seed || viewed["seed"], viewed_sector_id, viewed["danger"], viewed["depth"], viewed["terminal"])
		data["has_view"] = TRUE
		data["view"] = list(
			"id" = viewed_sector_id,
			"name" = viewed["name"],
			"danger_label" = odyssey_danger_label(viewed["danger"]),
			"visual" = odyssey_danger_visual(viewed["danger"]),
			"depth" = viewed["depth"],
			"terminal" = !!viewed["terminal"],
			"summary" = summary,
			"exits" = length(exit_names) ? jointext(exit_names, ", ") : "нет исходящих гиперкоридоров",
			"available" = odyssey_sector_is_available(viewed_sector_id, state),
			"current" = viewed_sector_id == state.current_sector_id,
			"selected" = viewed_sector_id == state.selected_sector_id
		)
	return data


/// FTL-style map palette: civilian / hostile / nebula.
/proc/odyssey_danger_visual(danger)
	switch (danger)
		if (ODYSSEY_DANGER_SAFE, ODYSSEY_DANGER_CIVILIAN)
			return "civilian"
		if (ODYSSEY_DANGER_HOSTILE)
			return "hostile"
		if (ODYSSEY_DANGER_DANGEROUS)
			return "nebula"
	return "civilian"


/proc/odyssey_danger_label(danger)
	switch (danger)
		if (ODYSSEY_DANGER_SAFE, ODYSSEY_DANGER_CIVILIAN)
			return "гражданский"
		if (ODYSSEY_DANGER_DANGEROUS)
			return "туманность"
		if (ODYSSEY_DANGER_HOSTILE)
			return "враждебный"
	return "неизвестен"


/proc/odyssey_sector_display_name(sector_id)
	if (sector_id == ODYSSEY_SECTOR_RETURN)
		return "возвращение домой"
	if (sector_id == ODYSSEY_SECTOR_COMPLETE)
		return "завершение Одиссеи"
	var/list/sector = odyssey_get_sector(sector_id)
	if (islist(sector) && sector["name"])
		return sector["name"]
	return sector_id


/// IC destination text for bluespace jump announcements.
/proc/odyssey_jump_destination_text()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !state.selected_sector_id)
		return "следующий сектор"
	return odyssey_sector_display_name(state.selected_sector_id)


/// IC display name for navigation confirmations: worn ID registered name, else character name.
/proc/odyssey_actor_ic_name(mob/user)
	if (!user)
		return "неизвестно"
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		var/id_name = H.get_id_name("")
		if (id_name)
			return id_name
		if (H.real_name)
			return H.real_name
	if (user.real_name)
		return user.real_name
	return "неизвестно"
