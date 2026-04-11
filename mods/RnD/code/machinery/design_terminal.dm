/*
Design Terminal

A simplified terminal for non-research departments (Medical, Engineering, etc.) to:
- Sync fabrication designs with the RnD server
- Manage a portable disk: save/load designs
- Purchase corporate design licenses using a linked department account

Unlike the full R&D console, this has no tech trees, missions, destructive analyzer,
or protolathe controls — just design access, distribution, and corp purchasing.
*/

/obj/machinery/computer/design_terminal
	name = "design terminal"
	icon_keyboard = "rd_key"
	icon_screen = "rdcomp"
	desc = "A terminal for accessing and distributing fabrication designs. Can synchronize with a research server and transfer designs to portable disks."
	light_color = COLOR_CYAN

	uncreated_component_parts = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc = 1
	)

	var/datum/research/files
	var/obj/item/stock_parts/computer/hard_drive/portable/disk = null

	/// ID used to match against server id_with_upload / id_with_download lists.
	var/id = 1
	var/sync = 1

	/// Pre-configured department account key (set on map-placed subtypes).
	var/department_account_key = null
	/// Account number linked via credentials (player-entered). 0 = not set.
	var/linked_account_number = 0
	/// If TRUE — account binding controls are shown in the UI.
	var/can_switch_account = TRUE

	var/search_text = ""
	var/selected_category = null

	/// Current active screen: "designs" or "corps"
	var/dt_screen = "designs"
	var/selected_corp_id
	var/selected_node_id
	var/selected_category_id

/obj/machinery/computer/design_terminal/Initialize()
	. = ..()
	files = new /datum/research()

/obj/machinery/computer/design_terminal/Destroy()
	QDEL_NULL(files)
	if(disk)
		disk.forceMove(loc)
		disk = null
	. = ..()

/obj/machinery/computer/design_terminal/proc/get_linked_account()
	if(linked_account_number)
		return get_account(linked_account_number)
	if(department_account_key)
		return department_accounts[department_account_key]
	return null

/// Sync known_designs with the connected research server (designs only, no tech trees).
/obj/machinery/computer/design_terminal/proc/sync_designs()
	for(var/obj/machinery/r_n_d/server/S in SSresearch.rnd_server_list)
		if(!S.files || MACHINE_IS_BROKEN(S))
			continue
		if(GLOB.using_map.use_overmap && !(src.z in GetConnectedZlevels(S.z)))
			continue
		// Upload: push our tech nodes and designs to server
		if((id in S.id_with_upload) || istype(S, /obj/machinery/r_n_d/server/centcom))
			S.files.download_from(files)
		// Download: pull server tech nodes and designs to us
		if((id in S.id_with_download) && !istype(S, /obj/machinery/r_n_d/server/centcom))
			files.download_from(S.files)

/// Attempt to buy a corporate tech node using the linked account.
/obj/machinery/computer/design_terminal/proc/buy_corp_node(mob/living/user, node_id)
	if(!files || !node_id)
		return

	var/list/corp_nodes = get_rnd_category_tree_nodes(selected_category_id, selected_corp_id)
	var/list/corp_node_set = list()
	for(var/nid in corp_nodes)
		corp_node_set[nid] = TRUE
	if(!(node_id in corp_node_set))
		return

	var/datum/technology/tech_node = SSresearch.get_tech_node(node_id)
	if(!tech_node)
		return
	if(!get_rnd_corp_node_requirements_met(files, tech_node, corp_node_set))
		to_chat(user, SPAN_WARNING("Условия узла ещё не выполнены."))
		return

	var/price = get_rnd_corp_node_price(tech_node, files)
	var/datum/money_account/acc = get_linked_account()
	if(!acc)
		to_chat(user, SPAN_WARNING("Не удалось получить доступ к счёту отдела."))
		return
	if(!acc.withdraw(price, "Corporate R&D unlock: [tech_node.name]", "Design Terminal"))
		to_chat(user, SPAN_WARNING("Недостаточно средств на счёте отдела."))
		return

	files.UnlockTechology(tech_node, force = TRUE)
	to_chat(user, SPAN_GOOD("Куплен корп. узел: [tech_node.name] за [price] [GLOB.using_map.local_currency_name_short]."))
	SSnano.update_uis(src)

/obj/machinery/computer/design_terminal/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/design_terminal/attack_ghost(mob/user)
	return ui_interact(user)

/obj/machinery/computer/design_terminal/use_tool(obj/item/I, mob/living/user, params)
	var/obj/item/stock_parts/computer/hard_drive/portable/D = I
	if(istype(D))
		if(disk)
			to_chat(user, SPAN_NOTICE("В машину уже вставлен диск."))
			return
		user.drop_item()
		D.forceMove(src)
		disk = D
		to_chat(user, SPAN_NOTICE("Вы вставляете [D] в [src]."))
		SSnano.update_uis(src)
		return
	return ..()

/obj/machinery/computer/design_terminal/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(MACHINE_IS_BROKEN(src))
		return

	var/list/data = list()

	// Account info
	var/datum/money_account/acc = get_linked_account()
	data["has_account"] = !!acc
	data["account_name"] = acc ? acc.account_name : ""
	data["balance"] = acc ? acc.money : 0
	data["currency_short"] = GLOB.using_map.local_currency_name_short
	data["can_switch_account"] = can_switch_account
	data["linked_account_number"] = linked_account_number

	// Disk info
	data["has_disk"] = !!disk
	if(disk)
		data["disk_size"] = disk.max_capacity
		data["disk_used"] = disk.used_capacity

	data["dt_screen"] = dt_screen

	// ── Designs screen data ──────────────────────────────────────────────────
	if(dt_screen == "designs")
		// Collect unique categories from known designs
		var/list/categories = list()
		for(var/datum/design/D in files.known_designs)
			if(D.starts_unlocked)
				continue
			for(var/cat in D.category)
				categories |= cat
		data["categories"] = categories
		data["selected_category"] = selected_category
		data["search_text"] = search_text

		// Terminal designs list
		var/list/terminal_designs = list()
		for(var/datum/design/D in files.known_designs)
			if(D.starts_unlocked)
				continue
			if(search_text && !findtext(lowertext(D.name), lowertext(search_text)))
				continue
			if(selected_category && LAZYLEN(D.category) && !(selected_category in D.category))
				continue
			// Check if this design is already on the disk
			var/on_disk = FALSE
			if(disk)
				var/list/disk_files = disk.find_files_by_type(/datum/computer_file/binary/design)
				for(var/datum/computer_file/binary/design/F in disk_files)
					if(F.design && F.design == D)
						on_disk = TRUE
						break
			terminal_designs += list(list("name" = D.name, "id" = "\ref[D]", "on_disk" = on_disk))
		data["terminal_designs"] = terminal_designs

		// Disk designs list
		var/list/disk_designs = list()
		if(disk)
			var/list/disk_files = disk.find_files_by_type(/datum/computer_file/binary/design)
			for(var/datum/computer_file/binary/design/F in disk_files)
				if(!F.design)
					continue
				disk_designs += list(list("name" = F.design.name, "id" = "\ref[F]"))
		data["disk_designs"] = disk_designs

	// ── Corps screen data ────────────────────────────────────────────────────
	if(dt_screen == "corps")
		// Tech categories
		var/list/all_categories = get_rnd_tech_categories()
		var/list/categories_list = list()
		for(var/cat_id in all_categories)
			var/list/cat = all_categories[cat_id]
			if(!cat)
				continue
			categories_list += list(list("id" = cat_id, "name" = cat["name"]))
		data["corp_categories"] = categories_list

		var/sel_category = selected_category_id
		if(!sel_category || !get_rnd_category(sel_category))
			sel_category = all_categories && length(all_categories) ? all_categories[1] : null
			selected_category_id = sel_category
		data["selected_category_id"] = sel_category

		// Corporation trees within selected category
		var/list/corp_trees_in_cat = get_rnd_category_trees(sel_category)
		var/list/corp_trees = list()
		for(var/corp_id in corp_trees_in_cat)
			var/list/tree = corp_trees_in_cat[corp_id]
			if(!tree)
				continue
			corp_trees += list(list("id" = corp_id, "name" = tree["name"]))
		data["corp_trees"] = corp_trees

		var/selected_corp = selected_corp_id
		if(!selected_corp || !(selected_corp in corp_trees_in_cat))
			selected_corp = (corp_trees_in_cat && length(corp_trees_in_cat)) ? corp_trees_in_cat[1] : null
			selected_corp_id = selected_corp
		data["selected_corp"] = selected_corp

		data["selected_corp_logo"] = get_rnd_corp_logo(selected_corp)

		// Corp nodes in selected category + corp
		var/list/corp_node_ids = get_rnd_category_tree_nodes(sel_category, selected_corp)
		var/list/corp_node_set = list()
		for(var/nid in corp_node_ids)
			corp_node_set[nid] = TRUE

		var/list/corp_nodes = list()
		var/list/corp_lines = list()
		for(var/node_id in corp_node_ids)
			var/datum/technology/tech_node = SSresearch.get_tech_node(node_id)
			if(!tech_node)
				continue
			var/is_researched = files.IsResearched(tech_node)
			var/can_unlock = get_rnd_corp_node_requirements_met(files, tech_node, corp_node_set)
			corp_nodes += list(list(
				"id" = node_id,
				"name" = tech_node.name,
				"x" = round(tech_node.x * 100),
				"y" = round(tech_node.y * 100),
				"icon" = "[tech_node.icon]",
				"isresearched" = is_researched,
				"canunlock" = can_unlock
			))

			for(var/req_tech in tech_node.required_technologies)
				var/datum/technology/other_tech = locate(req_tech) in SSresearch.all_tech_nodes
				if(!other_tech || !(other_tech.id in corp_node_set))
					continue
				var/line_x = min(round(other_tech.x * 100), round(tech_node.x * 100))
				var/line_y = min(round(other_tech.y * 100), round(tech_node.y * 100))
				var/width  = abs(round(other_tech.x * 100) - round(tech_node.x * 100))
				var/height = abs(round(other_tech.y * 100) - round(tech_node.y * 100))
				corp_lines += list(list(
					"line_x"  = line_x,
					"line_y"  = line_y,
					"width"   = width,
					"height"  = height,
					"istop"   = (other_tech.y > tech_node.y),
					"isright" = (other_tech.x < tech_node.x)
				))

		data["corp_nodes"] = corp_nodes
		data["corp_lines"] = corp_lines

		// Selected node detail
		var/sel_node = selected_node_id
		if(!sel_node || !(sel_node in corp_node_set))
			sel_node = length(corp_node_ids) ? corp_node_ids[1] : null
			selected_node_id = sel_node
		data["selected_node_id"] = sel_node

		if(sel_node)
			var/datum/technology/tech_node = SSresearch.get_tech_node(sel_node)
			if(tech_node)
				var/is_researched = files.IsResearched(tech_node)
				var/can_unlock = get_rnd_corp_node_requirements_met(files, tech_node, corp_node_set)
				var/price = get_rnd_corp_node_price(tech_node, files)
				var/list/node_detail = list(
					"name"        = tech_node.name,
					"desc"        = tech_node.desc,
					"price"       = price,
					"isresearched"= is_researched,
					"canunlock"   = can_unlock,
					"can_buy"     = can_unlock
				)
				var/list/requirement_list = list()
				for(var/t in tech_node.required_tech_levels)
					var/datum/tech/tree = locate(t) in files.researched_tech
					var/level = tech_node.required_tech_levels[t]
					requirement_list += list(list(
						"text"   = "[tree ? tree.shortname : t] level [level]",
						"isgood" = (tree && tree.level >= level)
					))
				for(var/t in tech_node.required_technologies)
					var/datum/technology/other_tech = locate(t) in SSresearch.all_tech_nodes
					if(!other_tech)
						continue
					requirement_list += list(list(
						"text"   = other_tech.name,
						"isgood" = files.IsResearched(other_tech)
					))
				node_detail["requirements"] = requirement_list

				var/list/unlock_list = list()
				for(var/T in tech_node.unlocks_designs)
					var/datum/design/D = SSresearch.get_design(T)
					if(D)
						unlock_list += list(list("text" = "[D.shortname]"))
				node_detail["unlocks"] = unlock_list

				if(tech_node.required_corp_id)
					var/current_rep = files.GetCorporationReputation(tech_node.required_corp_id)
					node_detail["current_reputation"]  = current_rep
					node_detail["required_reputation"] = tech_node.min_reputation
					node_detail["reputation_met"]      = (current_rep >= tech_node.min_reputation)
					node_detail["corp_id"]             = get_rnd_mission_corporation_name(tech_node.required_corp_id)

				data["selected_node"] = node_detail

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data)
	if(!ui)
		ui = new(user, src, ui_key, "mods-design_terminal.tmpl", "Design Terminal", 820, 580)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/design_terminal/Topic(href, href_list)
	..()
	if(MACHINE_IS_BROKEN(src))
		return

	// Screen switching
	if(href_list["go_screen"])
		var/where = href_list["go_screen"]
		if(where == "designs" || where == "corps")
			dt_screen = where

	// Sync designs with research server
	if(href_list["sync"])
		if(!sync)
			to_chat(usr, SPAN_WARNING("Не подключён к сети."))
		else
			sync_designs()
			to_chat(usr, SPAN_NOTICE("Синхронизация завершена."))

	// Eject disk
	if(href_list["eject_disk"])
		if(disk)
			disk.forceMove(loc)
			disk = null
			to_chat(usr, SPAN_NOTICE("Диск извлечён."))

	// Save design from terminal → disk
	if(href_list["save_to_disk"])
		if(!disk)
			return
		var/datum/design/D = locate(href_list["save_to_disk"]) in files.known_designs
		if(!D)
			return
		if(!D.file)
			D.file = new /datum/computer_file/binary/design()
			D.file.design = D
			D.file.filename = sanitizeFileName("[D.id]")
			D.file.filetype = "design"
			D.file.size = 10
		disk.save_file(D.file.clone())

	// Load design from disk → terminal
	if(href_list["load_from_disk"])
		if(!disk)
			return
		var/list/disk_files = disk.find_files_by_type(/datum/computer_file/binary/design)
		var/datum/computer_file/binary/design/F = locate(href_list["load_from_disk"]) in disk_files
		if(F && F.design)
			files.AddDesign2Known(F.design)

	// Search / filter (designs screen)
	if(href_list["search"])
		search_text = sanitize(href_list["search_text"])

	if(href_list["set_category"])
		selected_category = href_list["category"] == "all" ? null : href_list["category"]

	// Corps screen: category / corp / node selection
	if(href_list["select_tech_category"])
		selected_category_id = href_list["select_tech_category"]
		selected_corp_id = null
		selected_node_id = null

	if(href_list["select_corp"])
		var/new_corp = href_list["select_corp"]
		if(get_rnd_corp_tree(new_corp))
			selected_corp_id = new_corp
			selected_node_id = null

	if(href_list["select_corp_node"])
		selected_node_id = href_list["select_corp_node"]

	if(href_list["buy_corp_node"])
		buy_corp_node(usr, href_list["buy_corp_node"])

	// Link billing account via credentials
	if(href_list["link_account"])
		if(!can_switch_account)
			return
		var/input_num = input(usr, "Введите номер счёта:", "Привязка счёта") as num|null
		if(!input_num)
			return
		var/datum/money_account/found = get_account(input_num)
		if(!found)
			to_chat(usr, SPAN_WARNING("Счёт не найден."))
			return
		if(found.security_level)
			var/input_pin = input(usr, "Введите PIN:", "Привязка счёта") as num|null
			if(isnull(input_pin))
				return
			found = attempt_account_access(input_num, input_pin, 1)
		if(!found)
			to_chat(usr, SPAN_WARNING("Неверный PIN."))
			return
		linked_account_number = found.account_number
		department_account_key = null
		to_chat(usr, SPAN_NOTICE("Счёт привязан: [found.account_name]."))

	// Unlink billing account
	if(href_list["unlink_account"])
		if(!can_switch_account)
			return
		linked_account_number = 0
		department_account_key = null
		to_chat(usr, SPAN_NOTICE("Счёт отвязан."))

	SSnano.update_uis(src)

// ── Subtypes ──────────────────────────────────────────────────────────────────

/// Design terminal for the Medical department. Account pre-linked, switchable via credentials.
/obj/machinery/computer/design_terminal/medical
	name = "medical design terminal"
	department_account_key = "Медицинский"
	can_switch_account = TRUE
	req_access = list(access_medical)

/// Design terminal for the Engineering department. Account pre-linked, switchable via credentials.
/obj/machinery/computer/design_terminal/engineering
	name = "engineering design terminal"
	department_account_key = "Инженерный"
	can_switch_account = TRUE
	req_access = list(access_engine)
