/obj/machinery/computer/rd_mission_console
	name = "research mission console"
	desc = "Allows Science to take expedition missions and unlock additional designs."
	icon_keyboard = "rd_key"
	icon_screen = "rdcomp"
	req_access = list(access_research)
	uncreated_component_parts = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc/buildable = 1
	)

	var/list/active_missions = list()
	var/selected_category_id
	var/selected_corp_id
	var/selected_node_id
	var/selected_tab
	var/selected_dialogue_corp_id
	var/expanded_mission_corp_id  // Для открытия/закрытия блока миссии
	var/list/available_missions_cache
	var/list/mission_pool_cache

/obj/machinery/computer/rd_mission_console/attack_hand(mob/user)
	if(!user || !Adjacent(user))
		return TRUE
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Unauthorized access."))
		return TRUE
	if(CanUseTopic(user, DefaultTopicState()) <= STATUS_CLOSE)
		return TRUE

	user.set_machine(src)
	ui_interact(user)
	return TRUE

/obj/machinery/computer/rd_mission_console/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/computer/rd_mission_console/use_tool(obj/item/I, mob/living/user, list/click_params)
	// Мультитул - сохранить консоль в буфер для привязки к трекеру
	if(istype(I, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = I
		M.set_buffer(src)
		to_chat(user, SPAN_NOTICE("Вы сохранили [src.name] в буфер мультитула."))
		return TRUE
	if(LAZYLEN(active_missions))
		to_chat(user, SPAN_WARNING("Сдача контрактов выполняется через миссионный дрон пад."))
		return TRUE

	return ..()

/obj/machinery/computer/rd_mission_console/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = ui_data()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-rnd_mission_console.tmpl", "R&D Missions", 1200, 700)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(0)

/obj/machinery/computer/rd_mission_console/Topic(href, href_list)
	if(..())
		return 1

	if(!usr || !CanUseTopic(usr) || !allowed(usr))
		return 1

	usr.set_machine(src)

	var/needs_update = FALSE

	if(href_list["select_category"])
		var/new_category = href_list["select_category"]
		if(get_rnd_category(new_category))
			selected_category_id = new_category
			selected_corp_id = null
			selected_node_id = null
			needs_update = TRUE

	if(href_list["select_corp"])
		var/new_corp = href_list["select_corp"]
		var/category = selected_category_id
		if(get_rnd_category_tree(category, new_corp))
			selected_corp_id = new_corp
			selected_node_id = null
			needs_update = TRUE

	if(href_list["set_tab"])
		var/new_tab = href_list["set_tab"]
		if(new_tab in list("missions", "tech", "corps"))
			selected_tab = new_tab
			needs_update = TRUE

	if(href_list["select_corp_dialogue"])
		selected_dialogue_corp_id = href_list["select_corp_dialogue"]
		needs_update = TRUE

	if(href_list["select_corp_node"])
		selected_node_id = href_list["select_corp_node"]
		needs_update = TRUE

	if(href_list["take_mission"])
		if(LAZYLEN(active_missions) >= RND_MAX_ACTIVE_MISSIONS)
			to_chat(usr, SPAN_WARNING("Достигнут лимит активных заданий ([RND_MAX_ACTIVE_MISSIONS])."))
		else
			var/mission_index = text2num(href_list["take_mission"])
			var/list/mission_pool = get_mission_type_pool()
			if(mission_index >= 1 && mission_index <= length(mission_pool))
				var/mission_type = mission_pool[mission_index]
				var/datum/rnd_mission/chosen = new mission_type
				if(chosen.accept(src, usr))
					active_missions += chosen
					needs_update = TRUE
				else
					return 1

	if(href_list["turn_in"])
		turn_in_mission(usr, href_list["turn_in"])
		needs_update = TRUE

	if(href_list["cancel_mission"])
		cancel_mission(usr, href_list["cancel_mission"])
		needs_update = TRUE

	if(href_list["buy_design"])
		buy_design_by_id(usr, href_list["buy_design"])
		needs_update = TRUE

	if(href_list["buy_corp_node"])
		buy_corp_node(usr, href_list["buy_corp_node"])
		needs_update = TRUE

	if(href_list["take_corp_mission"])
		take_corp_mission(usr, href_list["take_corp_mission"])
		needs_update = TRUE

	if(href_list["print_mission"])
		print_mission(usr, href_list["print_mission"])

	if(href_list["toggle_mission_block"])
		var/corp_id = href_list["toggle_mission_block"]
		if(expanded_mission_corp_id == corp_id)
			expanded_mission_corp_id = null
		else
			expanded_mission_corp_id = corp_id
		needs_update = TRUE

	if(href_list["accept_corp_mission"])
		if(accept_corporation_mission(usr, href_list["accept_corp_mission"]))
			expanded_mission_corp_id = null
		needs_update = TRUE

	if(href_list["accept_special_mission"])
		if(accept_special_corporation_mission(usr, href_list["accept_special_mission"]))
			expanded_mission_corp_id = null
		needs_update = TRUE

	if(href_list["accept_corporate_deal"])
		if(accept_corporate_deal_mission(usr, href_list["accept_corporate_deal"]))
			expanded_mission_corp_id = null
		needs_update = TRUE

	if(href_list["learn_corp_info"])
		show_corporation_info(usr, href_list["learn_corp_info"])

	if(needs_update)
		SSnano.update_uis(src)
	return 1

/obj/machinery/computer/rd_mission_console/ui_data()
	var/list/data = list()
	var/active_count = LAZYLEN(active_missions)
	data["has_active_mission"] = active_count
	data["active_missions_count"] = active_count
	data["max_active_missions"] = RND_MAX_ACTIVE_MISSIONS
	data["currency_short"] = GLOB.using_map.local_currency_name_short

	// Баланс научного отдела
	var/datum/money_account/science_account = get_science_account()
	data["science_balance"] = science_account ? science_account.money : 0
	data["has_science_account"] = !!science_account

	if(!selected_tab)
		selected_tab = "missions"
	data["selected_tab"] = selected_tab

	var/list/active_missions_data = list()
	if(active_count)
		for(var/datum/rnd_mission/mission in active_missions)
			var/status_text = mission.is_complete() ? "Готово к отправке" : "В процессе"
			var/reward_node_name = null
			if(mission.reward_node_id)
				var/datum/technology/reward_node = get_rnd_reward_tech_node_by_id(mission.reward_node_id)
				if(reward_node)
					reward_node_name = reward_node.name
			var/list/mission_data = list(
				"ref" = "\ref[mission]",
				"title" = mission.title,
				"corp_name" = get_rnd_mission_corporation_name(mission.corporation_id),
				"description" = mission.description,
				"status" = status_text,
				"reward_pack_name" = mission.reward_pack_name,
				"reward_node_name" = reward_node_name,

				"location_type" = mission.target_location_type,
				"location_name" = mission.target_area_name,
				"location_coords" = mission.target_coords
			)
			if(mission.mission_type == RND_MISSION_TYPE_LIVE_CAPTURE)
				mission_data["creature_name"] = mission.target_mob_name
				mission_data["creature_desc"] = mission.target_mob_desc
				mission_data["creature_habitat"] = mission.target_mob_habitat
			active_missions_data += list(mission_data)
	data["active_missions"] = active_missions_data

	// Кешируем доступные миссии чтобы не создавать объекты каждый раз
	if(!available_missions_cache)
		available_missions_cache = list()
		var/list/mission_pool = get_mission_type_pool()
		for(var/i in 1 to length(mission_pool))
			var/mission_type = mission_pool[i]
			var/datum/rnd_mission/mission = new mission_type
			available_missions_cache += list(list(
				"index" = i,
				"brief" = mission.get_brief(),
				"reward_pack_name" = mission.reward_pack_name
			))
			qdel(mission)
	data["available_missions"] = available_missions_cache

	var/obj/machinery/computer/rdconsole/rd = find_nearest_rdconsole()
	data["has_rdconsole"] = !!rd

	// Обрабатываем корпоративные деревья только если открыта вкладка "tech"
	if(selected_tab == "tech")
		var/list/all_categories = get_rnd_tech_categories()
		var/list/categories_list = list()
		for(var/cat_id in all_categories)
			var/list/category = all_categories[cat_id]
			if(!category)
				continue
			categories_list += list(list(
				"id" = cat_id,
				"name" = category["name"]
			))
		data["categories"] = categories_list

		var/selected_category = selected_category_id
		if(!selected_category || !get_rnd_category(selected_category))
			selected_category = all_categories && length(all_categories) ? all_categories[1] : null
			selected_category_id = selected_category
		data["selected_category"] = selected_category

		// Получаем деревья для выбранной категории
		var/list/corp_trees = get_rnd_category_trees(selected_category)
		var/list/category_corp_trees = list()
		for(var/corp_id in corp_trees)
			var/list/tree = corp_trees[corp_id]
			if(!tree)
				continue
			category_corp_trees += list(list(
				"id" = corp_id,
				"name" = tree["name"]
			))
		data["category_corp_trees"] = category_corp_trees

		var/selected_corp = selected_corp_id
		if(!selected_corp || !corp_trees[selected_corp])
			selected_corp = (corp_trees && length(corp_trees)) ? corp_trees[1] : null
			selected_corp_id = selected_corp
		data["selected_corp"] = selected_corp
		data["selected_corp_logo"] = get_rnd_corp_logo(selected_corp)

		var/list/corp_node_ids = get_rnd_category_tree_nodes(selected_category, selected_corp)
		var/list/corp_node_set = list()
		for(var/node_id in corp_node_ids)
			corp_node_set[node_id] = TRUE

		// flag: does the selected corporation already have an active mission?
		var/has_active_corp_mission = FALSE
		if(LAZYLEN(active_missions))
			for(var/datum/rnd_mission/mission in active_missions)
				if(mission.corporation_id == selected_corp)
					has_active_corp_mission = TRUE
					break
		data["has_active_corp_mission"] = has_active_corp_mission

		var/list/active_node_ids = list()
		if(LAZYLEN(active_missions))
			for(var/datum/rnd_mission/mission in active_missions)
				if(mission.reward_node_id)
					active_node_ids[mission.reward_node_id] = TRUE

		var/list/corp_nodes = list()
		var/list/corp_lines = list()
		for(var/node_id in corp_node_ids)
			var/datum/technology/tech_node = get_rnd_reward_tech_node_by_id(node_id)
			if(!tech_node)
				continue
			var/is_researched = (rd && rd.files && rd.files.IsResearched(tech_node))
			var/can_unlock = (rd && rd.files && get_rnd_corp_node_requirements_met(rd.files, tech_node, corp_node_set))
			var/list/node_data = list(
				"id" = node_id,
				"name" = tech_node.name,
				"x" = round(tech_node.x * 100),
				"y" = round(tech_node.y * 100),
				"icon" = "[tech_node.icon]",
				"isresearched" = is_researched,
				"canunlock" = can_unlock,
				"mission_active" = (node_id in active_node_ids)
			)
			corp_nodes += list(node_data)

			for(var/req_tech in tech_node.required_technologies)
				var/datum/technology/other_tech = locate(req_tech) in SSresearch.all_tech_nodes
				if(!other_tech || !(other_tech.id in corp_node_set))
					continue
				var/line_x = (min(round(other_tech.x * 100), round(tech_node.x * 100)))
				var/line_y = (min(round(other_tech.y * 100), round(tech_node.y * 100)))
				var/width = (abs(round(other_tech.x * 100) - round(tech_node.x * 100)))
				var/height = (abs(round(other_tech.y * 100) - round(tech_node.y * 100)))

				var/istop = FALSE
				if(other_tech.y > tech_node.y)
					istop = TRUE
				var/isright = FALSE
				if(other_tech.x < tech_node.x)
					isright = TRUE

				var/list/line_data = list(
					"line_x" = line_x,
					"line_y" = line_y,
					"width" = width,
					"height" = height,
					"istop" = istop,
					"isright" = isright
				)
				corp_lines += list(line_data)

		data["corp_nodes"] = corp_nodes
		data["corp_lines"] = corp_lines

		var/selected_node = selected_node_id
		if(!selected_node || !(selected_node in corp_node_set))
			selected_node = length(corp_node_ids) ? corp_node_ids[1] : null
			selected_node_id = selected_node
		data["selected_node_id"] = selected_node

		if(selected_node)
			var/datum/technology/tech_node = get_rnd_reward_tech_node_by_id(selected_node)
			if(tech_node)
				var/is_researched = (rd && rd.files && rd.files.IsResearched(tech_node))
				var/can_unlock = (rd && rd.files && get_rnd_corp_node_requirements_met(rd.files, tech_node, corp_node_set))
				var/price = get_rnd_corp_node_price(tech_node, rd && rd.files ? rd.files : null)
				var/mission_active = (selected_node in active_node_ids)
				var/list/technology_data = list(
					"name" = tech_node.name,
					"desc" = tech_node.desc,
					"price" = price,
					"isresearched" = is_researched,
					"canunlock" = can_unlock,
					"can_buy" = can_unlock,
					"can_mission" = (can_unlock && !mission_active),
					"mission_active" = mission_active
				)

				// Add reputation information
				if(tech_node.required_corp_id && rd && rd.files)
					var/current_rep = rd.files.GetCorporationReputation(tech_node.required_corp_id)
					var/required_rep = tech_node.min_reputation
					technology_data["current_reputation"] = current_rep
					technology_data["required_reputation"] = required_rep
					technology_data["reputation_met"] = (current_rep >= required_rep)
					technology_data["corp_id"] = get_rnd_mission_corporation_name(tech_node.required_corp_id)

				var/list/requirement_list = list()
				if(rd && rd.files)
					for(var/t in tech_node.required_tech_levels)
						var/datum/tech/tree = locate(t) in rd.files.researched_tech
						var/level = tech_node.required_tech_levels[t]
						var/list/req_data = list(
							"text" = "[tree.shortname] level [level]",
							"isgood" = (tree && tree.level >= level)
						)
						requirement_list += list(req_data)
					for(var/t in tech_node.required_technologies)
						var/datum/technology/other_tech = locate(t) in SSresearch.all_tech_nodes
						if(!other_tech)
							continue
						var/list/req_data = list(
							"text" = "[other_tech.name]",
							"isgood" = rd.files.IsResearched(other_tech)
						)
						requirement_list += list(req_data)
				technology_data["requirements"] = requirement_list

				var/list/unlock_list = list()
				for(var/T in tech_node.unlocks_designs)
					var/datum/design/D = SSresearch.get_design(T)
					if(D)
						unlock_list += list(list("text" = "[D.shortname]"))
				technology_data["unlocks"] = unlock_list

				data["selected_node"] = technology_data
	else
		// Для вкладки missions просто возвращаем пустые данные
		data["categories"] = list()
		data["selected_category"] = null
		data["category_corp_trees"] = list()
		data["selected_corp"] = null
		data["corp_nodes"] = list()
		data["corp_lines"] = list()
		data["selected_node_id"] = null

	// Market offers тоже только для вкладки tech
	if(selected_tab == "tech")
		var/list/market_offers = get_market_offers_data(rd)
		data["market_offers"] = market_offers
	else
		data["market_offers"] = list()

	// Corp communication tab
	if(selected_tab == "corps")
		var/list/corporations = get_rnd_mission_corporations()
		var/list/corps_data = list()
		for(var/corp_id in corporations)
			var/corp_name = get_rnd_mission_corporation_name(corp_id)
			var/current_rep = rd && rd.files ? rd.files.GetCorporationReputation(corp_id) : 0
			var/list/corp_info = list(
				"id" = corp_id,
				"name" = corp_name,
				"reputation" = current_rep
			)
			corps_data += list(corp_info)
		data["corporations"] = corps_data
		data["selected_dialogue_corp_id"] = selected_dialogue_corp_id
		data["expanded_mission_corp_id"] = expanded_mission_corp_id

		// Get info about selected corporation
		if(selected_dialogue_corp_id)
			var/corp_name = get_rnd_mission_corporation_name(selected_dialogue_corp_id)
			var/current_rep = rd && rd.files ? rd.files.GetCorporationReputation(selected_dialogue_corp_id) : 0
			var/corp_info_text = get_corporation_info_text(selected_dialogue_corp_id)
			var/list/corp_dialogue = list(
				"name" = corp_name,
				"reputation" = current_rep,
				"reputation_color" = (current_rep >= 0 ? "#00FF00" : "#FF0000"),
				"info" = corp_info_text
			)
			data["selected_corp_dialogue"] = corp_dialogue
	else
		data["corporations"] = list()
		data["selected_dialogue_corp_id"] = null
		data["selected_corp_dialogue"] = null

	return data

/obj/machinery/computer/rd_mission_console/proc/get_mission_type_pool()
	if(mission_pool_cache)
		return mission_pool_cache

	var/list/pool = list()
	if(!rnd_mission_pool || !length(rnd_mission_pool))
		return pool
	for(var/mission_type in rnd_mission_pool)
		pool += mission_type

	mission_pool_cache = pool

	return pool

/obj/machinery/computer/rd_mission_console/proc/create_corp_mission(corp_id, node_id)
	var/list/pool = get_mission_type_pool()
	if(!length(pool))
		return null
	var/mission_type = pick(pool)
	var/datum/rnd_mission/mission = new mission_type
	mission.corporation_id = corp_id
	mission.reward_node_id = node_id
	mission.reward_pack_id = null
	mission.reward_design_ids = list()
	return mission

/obj/machinery/computer/rd_mission_console/proc/buy_corp_node(mob/living/user, node_id)
	var/obj/machinery/computer/rdconsole/rd = find_nearest_rdconsole()
	if(!rd || !rd.files)
		to_chat(user, SPAN_WARNING("Поблизости не найдена рабочая R&D консоль."))
		return

	if(!node_id)
		return

	var/selected_category = selected_category_id
	var/selected_corp = selected_corp_id
	var/list/corp_nodes = get_rnd_category_tree_nodes(selected_category, selected_corp)
	var/list/corp_node_set = list()
	for(var/node_id_entry in corp_nodes)
		corp_node_set[node_id_entry] = TRUE
	if(!(node_id in corp_nodes))
		return

	var/datum/technology/tech_node = get_rnd_reward_tech_node_by_id(node_id)
	if(!tech_node)
		return

	if(!get_rnd_corp_node_requirements_met(rd.files, tech_node, corp_node_set))
		to_chat(user, SPAN_WARNING("Условия узла ещё не выполнены."))
		return

	var/price = get_rnd_corp_node_price(tech_node)
	var/datum/money_account/science_account = get_science_account()
	if(!science_account)
		to_chat(user, SPAN_WARNING("Не удалось получить доступ к счёту научного отдела."))
		return
	if(!science_account.withdraw(price, "Corporate R&D unlock: [tech_node.name]", "R&D Mission Console"))
		to_chat(user, SPAN_WARNING("Недостаточно средств на счёте научного отдела."))
		return

	rd.files.UnlockTechology(tech_node, force = TRUE)
	SSnano.update_uis(rd)


/obj/machinery/computer/rd_mission_console/proc/take_corp_mission(mob/living/user, node_id, corp_id = null)

	var/obj/machinery/computer/rdconsole/rd = find_nearest_rdconsole()
	if(!rd || !rd.files)
		to_chat(user, SPAN_WARNING("Поблизости не найдена рабочая R&D консоль."))
		return

	if(!node_id)
		return

	if(LAZYLEN(active_missions) >= RND_MAX_ACTIVE_MISSIONS)
		to_chat(user, SPAN_WARNING("Достигнут лимит активных заданий ([RND_MAX_ACTIVE_MISSIONS])."))
		return

	var/selected_category = selected_category_id
	var/selected_corp = corp_id || selected_corp_id
	var/list/corp_nodes = get_rnd_category_tree_nodes(selected_category, selected_corp)
	var/list/corp_node_set = list()
	for(var/node_id_entry in corp_nodes)
		corp_node_set[node_id_entry] = TRUE
	if(!(node_id in corp_nodes))
		return

	var/datum/technology/tech_node = get_rnd_reward_tech_node_by_id(node_id)
	if(!tech_node)
		return
	if(!get_rnd_corp_node_requirements_met(rd.files, tech_node, corp_node_set))
		to_chat(user, SPAN_WARNING("Условия узла ещё не выполнены."))
		return
	// ensure only one mission per corporation active
	if(LAZYLEN(active_missions))
		for(var/datum/rnd_mission/mission in active_missions)
			if(mission.corporation_id == selected_corp)
				to_chat(user, SPAN_WARNING("Уже есть активная миссия этой корпорации."))
				return
	// prevent duplicate node missions as well
	if(LAZYLEN(active_missions))
		for(var/datum/rnd_mission/mission in active_missions)
			if(mission.reward_node_id == node_id)
				to_chat(user, SPAN_WARNING("Миссия для этого узла уже активна."))
				return

	var/datum/rnd_mission/mission = create_corp_mission(selected_corp, node_id)
	if(!mission)
		to_chat(user, SPAN_WARNING("Нет доступных миссий для выдачи."))
		return

	if(mission.accept(src, user))
		active_missions += mission

/obj/machinery/computer/rd_mission_console/proc/get_active_mission_by_ref(mission_ref)
	if(!mission_ref)
		return null
	for(var/datum/rnd_mission/mission in active_missions)
		if("\ref[mission]" == mission_ref)
			return mission
	return null

/obj/machinery/computer/rd_mission_console/proc/remove_active_mission(datum/rnd_mission/mission)
	if(!mission)
		return
	active_missions -= mission

/obj/machinery/computer/rd_mission_console/proc/cleanup_mission_targets(datum/rnd_mission/mission)
	if(!mission)
		return
	if(mission.target)
		qdel(mission.target)
	if(mission.target_mob)
		qdel(mission.target_mob)

/obj/machinery/computer/rd_mission_console/proc/print_mission(mob/living/user, mission_ref)
	var/datum/rnd_mission/mission = get_active_mission_by_ref(mission_ref)
	if(!mission)
		return
	var/title = "paper - R&D mission"
	var/info = {"
		<b>R&D контракт</b><br>
		<b>Корпорация:</b> [get_rnd_mission_corporation_name(mission.corporation_id)]<br>
		<b>Контракт:</b> [mission.title]<br>
		<b>Описание:</b> [mission.description]<br>
		<b>Локация:</b> [mission.target_location_type] [mission.target_area_name]<br>
		<b>Координаты:</b> [mission.target_coords]<br>
	"}
	if(mission.mission_type == RND_MISSION_TYPE_LIVE_CAPTURE)
		info += "<b>Цель:</b> [mission.target_mob_name]<br><b>Описание:</b> [mission.target_mob_desc]<br><b>Среда:</b> [mission.target_mob_habitat]<br><b>Сдача:</b> Стазис-клетка через карго-шаттл<br>"
	var/reward_text = mission.reward_pack_name
	if(mission.reward_node_id)
		var/datum/technology/reward_node = get_rnd_reward_tech_node_by_id(mission.reward_node_id)
		if(reward_node)
			reward_text = "Узел: [reward_node.name]"
	info += "<b>Награда:</b> [reward_text]<br>"
	info += "<hr><u>Заметки:</u> <field>"
	new /obj/item/paper(get_turf(src), info, title)

/obj/machinery/computer/rd_mission_console/proc/get_market_offers_data(obj/machinery/computer/rdconsole/rd)
	var/list/offers = list()
	if(!rd || !rd.files)
		return offers

	for(var/design_id in rnd_design_market)
		var/list/offer = rnd_design_market[design_id]
		if(!offer)
			continue
		var/price = offer["price"]

		var/datum/design/D = SSresearch.get_design(design_id)
		if(!D)
			continue

		var/is_owned = (D in rd.files.known_designs)

		offers += list(list(
			"id" = design_id,
			"name" = D.name,
			"price" = price,
			"owned" = is_owned,
			"locked" = FALSE,
			"can_buy" = !is_owned
		))

	return offers

/obj/machinery/computer/rd_mission_console/proc/take_mission(mob/living/user)
	if(LAZYLEN(active_missions) >= RND_MAX_ACTIVE_MISSIONS)
		to_chat(user, SPAN_WARNING("Достигнут лимит активных заданий ([RND_MAX_ACTIVE_MISSIONS])."))
		return

	var/list/choices = list()
	var/list/mission_pool = get_mission_type_pool()

	for(var/mission_type in mission_pool)
		var/datum/rnd_mission/mission = new mission_type
		choices[mission.get_brief()] = mission

	var/picked_key = input(user, "Выберите задание", "Research Missions") as null|anything in choices
	if(!picked_key || !CanUseTopic(user))
		for(var/datum/rnd_mission/m in choices)
			qdel(m)
		return

	var/datum/rnd_mission/chosen = choices[picked_key]
	if(chosen && chosen.accept(src, user))
		active_missions += chosen

	for(var/datum/rnd_mission/m in choices)
		if(m != chosen)
			qdel(m)


/obj/machinery/computer/rd_mission_console/proc/show_mission_status(mob/living/user)
	if(!LAZYLEN(active_missions))
		to_chat(user, SPAN_NOTICE("Активных заданий нет."))
		return

	for(var/datum/rnd_mission/mission in active_missions)
		var/status_text = "В процессе"
		if(mission.is_complete())
			status_text = "Готово к отправке"

		var/corp_name = get_rnd_mission_corporation_name(mission.corporation_id)
		to_chat(user, SPAN_NOTICE("[corp_name] [mission.title]: [mission.description] Статус: [status_text]."))


/obj/machinery/computer/rd_mission_console/proc/turn_in_mission(mob/living/user, mission_ref = null)
	if(!LAZYLEN(active_missions))
		to_chat(user, SPAN_WARNING("Нет активного задания."))
		return
	to_chat(user, SPAN_WARNING("Сдача контрактов выполняется через миссионный телепортер."))
	return


/obj/machinery/computer/rd_mission_console/proc/cancel_mission(mob/living/user, mission_ref = null)
	if(!LAZYLEN(active_missions))
		to_chat(user, SPAN_NOTICE("Нет активного задания."))
		return

	var/datum/rnd_mission/mission = mission_ref ? get_active_mission_by_ref(mission_ref) : active_missions[1]
	if(!mission)
		return
	cleanup_mission_targets(mission)
	remove_active_mission(mission)
	// penalize cancellation: -5 rep with that corp
	var/obj/machinery/computer/rdconsole/rd = find_nearest_rdconsole()
	if(mission.corporation_id && rd && rd.files)
		rd.files.ChangeCorporationReputation(mission.corporation_id, -5)
	to_chat(user, SPAN_NOTICE("Активное задание отменено. Репутация -5."))

/hook/sell_animal/proc/rnd_live_capture_delivery(obj/machinery/stasis_cage/sold, area/shuttle)
	// Live capture missions are completed via the mission teleporter now.
	return

/obj/machinery/computer/rd_mission_console/proc/find_nearest_rdconsole()
	for(var/obj/machinery/computer/rdconsole/RD in range(7, src))
		if(RD.can_research && RD.files)
			return RD
	return null

/obj/machinery/computer/rd_mission_console/proc/get_science_account()
	var/list/science_department_keys = list("Научный", "Science")
	for(var/key in science_department_keys)
		if(department_accounts[key])
			return department_accounts[key]
	return null

/obj/machinery/computer/rd_mission_console/proc/buy_design(mob/living/user)
	var/design_id = get_design_for_purchase(user)
	if(design_id)
		buy_design_by_id(user, design_id)

/obj/machinery/computer/rd_mission_console/proc/get_design_for_purchase(mob/living/user)
	var/obj/machinery/computer/rdconsole/rd = find_nearest_rdconsole()
	if(!rd || !rd.files)
		to_chat(user, SPAN_WARNING("Поблизости не найдена рабочая R&D консоль."))
		return null

	var/list/choices = list()
	for(var/design_id in rnd_design_market)
		var/list/offer = rnd_design_market[design_id]
		if(!offer)
			continue

		var/datum/design/D = SSresearch.get_design(design_id)
		if(!D || (D in rd.files.known_designs))
			continue

		var/price = offer["price"]
		var/entry = "[D.name] — [GLOB.using_map.local_currency_name_short][price]"
		choices[entry] = design_id

	if(!length(choices))
		to_chat(user, SPAN_NOTICE("Нет доступных к покупке дизайнов."))
		return null

	var/picked_key = input(user, "Выберите дизайн для покупки", "R&D Market") as null|anything in choices
	return (picked_key && CanUseTopic(user)) ? choices[picked_key] : null

/obj/machinery/computer/rd_mission_console/proc/buy_design_by_id(mob/living/user, chosen_design_id)
	if(!chosen_design_id)
		return FALSE

	var/obj/machinery/computer/rdconsole/rd = find_nearest_rdconsole()
	if(!rd || !rd.files)
		to_chat(user, SPAN_WARNING("Поблизости не найдена рабочая R&D консоль."))
		return FALSE

	var/datum/money_account/science_account = get_science_account()
	if(!science_account)
		to_chat(user, SPAN_WARNING("Не удалось получить доступ к счёту научного отдела."))
		return FALSE

	var/list/chosen_offer = rnd_design_market[chosen_design_id]
	if(!chosen_offer)
		return FALSE

	var/chosen_price = chosen_offer["price"]

	var/datum/design/chosen_design = SSresearch.get_design(chosen_design_id)
	if(!chosen_design)
		to_chat(user, SPAN_WARNING("Дизайн недоступен в базе."))
		return FALSE

	if(chosen_design in rd.files.known_designs)
		to_chat(user, SPAN_NOTICE("Этот дизайн уже открыт."))
		return FALSE

	if(science_account.money < chosen_price)
		to_chat(user, SPAN_WARNING("Недостаточно таллеров на счёте научного отдела. Требуется [GLOB.using_map.local_currency_name_short][chosen_price]."))
		return FALSE

	if(!science_account.withdraw(chosen_price, "R&D market purchase: [chosen_design.name]", "R&D Mission Console"))
		to_chat(user, SPAN_WARNING("Ошибка списания средств со счёта научного отдела."))
		return FALSE

	rd.files.AddDesign2Known(chosen_design)
	SSnano.update_uis(rd)
	to_chat(user, SPAN_NOTICE("Приобретён дизайн: [chosen_design.name] за [GLOB.using_map.local_currency_name_short][chosen_price]."))
	return TRUE

/obj/machinery/computer/rd_mission_console/proc/accept_corporation_mission(mob/living/user, corp_id)
	if(!user || !CanUseTopic(user))
		return FALSE

	if(LAZYLEN(active_missions) >= RND_MAX_ACTIVE_MISSIONS)
		to_chat(user, SPAN_WARNING("Достигнут лимит активных заданий ([RND_MAX_ACTIVE_MISSIONS])."))
		return FALSE

	var/obj/machinery/computer/rdconsole/rd = find_nearest_rdconsole()
	if(!rd || !rd.files)
		to_chat(user, SPAN_WARNING("Поблизости не найдена рабочая R&D консоль."))
		return FALSE

	var/corp_name = get_rnd_mission_corporation_name(corp_id)

	// Создаём миссию репутации
	var/datum/rnd_mission/mission = new /datum/rnd_mission
	mission.title = "Контракт с [corp_name]"
	mission.description = "Выполните задание корпорации для улучшения отношений."
	mission.corporation_id = corp_id
	mission.reward_pack_id = "reputation_reward"
	mission.is_reputation_mission = TRUE
	mission.reputation_reward = 15  // Награда: +15 репутации

	if(mission.accept(src, user))
		active_missions += mission
		to_chat(user, SPAN_NOTICE("Вы приняли контракт с корпорацией [corp_name]."))
		return TRUE
	return FALSE

/obj/machinery/computer/rd_mission_console/proc/accept_special_corporation_mission(mob/living/user, corp_id)
	if(!user || !CanUseTopic(user))
		return FALSE

	var/obj/machinery/computer/rdconsole/rd = find_nearest_rdconsole()
	if(!rd || !rd.files)
		to_chat(user, SPAN_WARNING("Поблизости не найдена рабочая R&D консоль."))
		return FALSE

	var/current_rep = rd.files.GetCorporationReputation(corp_id)
	if(current_rep < 30)
		to_chat(user, SPAN_WARNING("Недостаточно репутации! Требуется минимум 30 (текущая: [current_rep])."))
		return FALSE

	if(LAZYLEN(active_missions) >= RND_MAX_ACTIVE_MISSIONS)
		to_chat(user, SPAN_WARNING("Достигнут лимит активных заданий ([RND_MAX_ACTIVE_MISSIONS])."))
		return FALSE

	var/corp_name = get_rnd_mission_corporation_name(corp_id)

	// Создаём особую миссию
	var/datum/rnd_mission/mission = new /datum/rnd_mission
	mission.title = "ОСОБЫЙ: Контракт с [corp_name]"
	mission.description = "Высокоуровневое задание от корпорации. Требует выполнения специальных условий."
	mission.corporation_id = corp_id
	mission.reward_pack_id = "special_reputation_reward"
	mission.is_reputation_mission = TRUE
	mission.reputation_reward = 30  // +30 репутации за особую миссию

	if(mission.accept(src, user))
		active_missions += mission
		to_chat(user, SPAN_NOTICE("Вы приняли ОСОБЫЙ контракт с корпорацией [corp_name]!"))
		return TRUE
	return FALSE

/obj/machinery/computer/rd_mission_console/proc/accept_corporate_deal_mission(mob/living/user, corp_id)
	if(!user || !CanUseTopic(user))
		return FALSE

	var/obj/machinery/computer/rdconsole/rd = find_nearest_rdconsole()
	if(!rd || !rd.files)
		to_chat(user, SPAN_WARNING("Поблизости не найдена рабочая R&D консоль."))
		return FALSE

	if(LAZYLEN(active_missions) >= RND_MAX_ACTIVE_MISSIONS)
		to_chat(user, SPAN_WARNING("Достигнут лимит активных заданий ([RND_MAX_ACTIVE_MISSIONS])."))
		return FALSE

	var/corp_name = get_rnd_mission_corporation_name(corp_id)

	// Выбираем случайную конкурирующую корпорацию
	var/list/all_corps = get_rnd_mission_corporations()
	var/list/competitors = all_corps.Copy()
	competitors -= corp_id
	if(!length(competitors))
		to_chat(user, SPAN_WARNING("Не удалось найти конкурирующую корпорацию."))
		return FALSE

	var/competitor_corp_id = pick(competitors)
	var/competitor_name = get_rnd_mission_corporation_name(competitor_corp_id)

	// Получаем случайный дизайн от конкурента
	var/required_design = get_random_corporation_design(competitor_corp_id)
	if(!required_design)
		to_chat(user, SPAN_WARNING("Не удалось определить требования миссии."))
		return FALSE

	var/datum/design/design_data = SSresearch.get_design(required_design)
	var/design_name = design_data ? design_data.name : "предмет конкурента"

	// Создаём корпоративную сделку
	var/datum/rnd_mission/mission = new /datum/rnd_mission
	mission.title = "Корпоративная сделка: [corp_name]"
	mission.description = "Требуется доставить [design_name] от [competitor_name]. Награда: +5 репутации с [corp_name], -5 репутации с [competitor_name]. Предмет можно произвести самостоятельно. Сдача через миссионный дрон пад."
	mission.corporation_id = corp_id
	mission.competitor_corp_id = competitor_corp_id
	mission.is_corporate_deal = TRUE
	mission.reputation_reward = 5
	mission.reputation_penalty = 5
	mission.required_design_ids = list(required_design)

	if(mission.accept(src, user))
		active_missions += mission
		to_chat(user, SPAN_NOTICE("Вы приняли корпоративную сделку с [corp_name]. Требуется: [design_name] от [competitor_name]."))
		return TRUE
	return FALSE

/obj/machinery/computer/rd_mission_console/proc/show_corporation_info(mob/living/user, corp_id)
	if(!user || !CanUseTopic(user))
		return FALSE

	var/info_text = get_corporation_info_text(corp_id)
	alert(user, info_text, get_rnd_mission_corporation_name(corp_id), "ОК")
	return TRUE

/obj/machinery/computer/rd_mission_console/proc/get_corporation_info_text(corp_id)
	switch(corp_id)
		if(RND_MISSION_CORP_NANOTRASEN)
			return "NanoTrasen корпорация является крупнейшим работодателем и главным спонсором космических станций."
		if(RND_MISSION_CORP_WARD_TAKAHASHI)
			return "Ward-Takahashi известна своей продвинутой электроникой и передовыми технологиями."
		if(RND_MISSION_CORP_GRAYSON)
			return "Grayson Manufacturing занимается производством промышленного оборудования и инструментов."
		if(RND_MISSION_CORP_AETHER)
			return "Aether специализируется на передовых технологиях в области атмосферики и энергетики."
		if(RND_MISSION_CORP_EINSTEIN)
			return "Einstein Engines производит высокопроизводительные двигатели и системы пропульсии."
		if(RND_MISSION_CORP_XION)
			return "Xion Manufacturing разработала революционные методы производства и логистики."
		if(RND_MISSION_CORP_SLATE)
			return "Slate Corporation является лидером в области гражданского строительства и архитектуры."
		if(RND_MISSION_CORP_FOCAL)
			return "Focal Point занимается разработкой телекоммуникационных систем нового поколения."
		if(RND_MISSION_CORP_DAIS)
			return "DAIS специализируется на автоматизации и искусственном интеллекте."
		if(RND_MISSION_CORP_KAPPA)
			return "Kappa создаёт инновационные решения для безопасности и обороны."
		if(RND_MISSION_CORP_VEYMED)
			return "VeyMed разработчик передовых медицинских технологий и оборудования."
		if(RND_MISSION_CORP_HEPHAESTUS)
			return "Hephaestus Industries специализируется на оружейных системах и боевых платформах."
		if(RND_MISSION_CORP_MAHIMAKU)
			return "Mahimaku занимается разработкой экзотических материалов и композитов."
	return "Информация о корпорации недоступна."

/proc/get_rnd_corp_logo(corp_id)
	switch(corp_id)
		if(RND_MISSION_CORP_NANOTRASEN)
			return "ntlogo.png"
		if(RND_MISSION_CORP_WARD_TAKAHASHI)
			return "wardlogo.png"
		if(RND_MISSION_CORP_AETHER)
			return "aetherlogo.png"
		if(RND_MISSION_CORP_GRAYSON)
			return "graylogo.png"
		if(RND_MISSION_CORP_SLATE)
			return "slatelogo.png"
		if(RND_MISSION_CORP_EINSTEIN)
			return "eelogo.png"
		if(RND_MISSION_CORP_XION)
			return "xionlogo.png"
		if(RND_MISSION_CORP_KAPPA)
			return "kappalogo.png"
		if(RND_MISSION_CORP_DAIS)
			return "daisnlogo.png"
		if(RND_MISSION_CORP_MAHIMAKU)
			return "mmlogo.png"
		if(RND_MISSION_CORP_MORPHEUS)
			return "mklogo.png"
		if(RND_MISSION_CORP_SHELLGUARD)
			return "sglogo.png"
		if(RND_MISSION_CORP_VEYMED)
			return "vmlogo.png"
		if(RND_MISSION_CORP_ZENG_HU)
			return "zenhulogo.png"
		if(RND_MISSION_CORP_FOCAL)
			return "focallogo.png"
		if(RND_MISSION_CORP_BISHOP)
			return "bishoplogo.png"
	return null
