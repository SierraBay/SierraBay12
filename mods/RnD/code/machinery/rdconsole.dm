#define SCREEN_MAIN "main"
#define SCREEN_PROTO "protolathe"
#define SCREEN_IMPRINTER "circuit_imprinter"
#define SCREEN_WORKING "working"
#define SCREEN_TREES "tech_trees"
#define SCREEN_LOCKED "locked"
#define SCREEN_DISK_DESIGNS "disk_management_designs"
#define SCREEN_DISK_TECH "disk_management_tech"
#define SCREEN_MISSIONS "missions"
#define SCREEN_CORPS "corps"

/obj/machinery/computer/rdconsole
	name = "fabrication control console"
	icon_keyboard = "rd_key"
	icon_screen = "rdcomp"
	desc = "Console controlling the various fabrication devices. Uses self-learning matrix to hold and optimize blueprints. Prone to corrupting said matrix, so back up often."
	light_color = COLOR_PURPLE
	var/obj/item/stock_parts/computer/hard_drive/portable/disk = null	//Stores the data disk.

	var/obj/machinery/r_n_d/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
	var/obj/machinery/fabricator/rnd/protolathe/linked_lathe = null		//Linked Protolathe
	var/obj/machinery/fabricator/rnd/imprinter/linked_imprinter = null	//Linked Circuit Imprinter
	base_type = /obj/machinery/computer/rdconsole/core

	var/screen = SCREEN_MAIN	//Which screen is currently showing.
	var/id     = 0			//ID of the computer (for server restrictions).
	var/can_research = TRUE   //Is this console capable of researching

	/// Ключ счёта отдела для предзаданных подтипов (map-spawn). null = не задан.
	var/department_account_key = null
	/// Номер счёта, привязанного игроком через учётные данные. 0 = не привязан.
	var/linked_account_number = 0
	/// Если TRUE — в настройках доступна кнопка привязки счёта.
	var/can_switch_account = FALSE

	req_access = list(access_research) //Data and setting manipulation requires scientist access.

	var/datum/tech/selected_tech_tree
	var/datum/technology/selected_technology
	var/selected_corp_id
	var/selected_node_id
	var/selected_category_id
	var/selected_dialogue_corp_id
	var/selected_disk_category
	var/show_settings = FALSE
	var/show_link_menu = FALSE
	var/report_collapsed = FALSE
	var/selected_protolathe_category
	var/selected_imprinter_category
	var/searched_disk_design_text
	var/search_text
	var/quick_deconstruct = FALSE
	/// pad_id of the R&D mission drone pad linked to this console. 0 = not linked.
	var/linked_drone_pad_id = 0
	/// Set to TRUE when the player explicitly disconnects from a server, prevents auto-reconnect via fallback.
	var/server_disconnected = FALSE

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/r_n_d/destructive_analyzer/D in range(3, src))
		if(!isnull(D.linked_console) || D.panel_open)
			continue
		if(isnull(linked_destroy))
			linked_destroy = D
			D.linked_console = src

	for(var/obj/machinery/fabricator/rnd/D in range(3, src))
		if(!isnull(D.linked_console) || D.panel_open)
			continue

		if(istype(D, /obj/machinery/fabricator/rnd/protolathe))
			if(isnull(linked_lathe))
				linked_lathe = D
				D.linked_console = src
				linked_lathe.have_disk = FALSE
				linked_lathe.have_design_selector = FALSE
				linked_lathe.eject_disk()

		else if(istype(D, /obj/machinery/fabricator/rnd/imprinter))
			if(isnull(linked_imprinter))
				linked_imprinter = D
				D.linked_console = src
				linked_imprinter.have_disk = FALSE
				linked_imprinter.have_design_selector = FALSE
				linked_imprinter.eject_disk()


/obj/machinery/computer/rdconsole/Initialize()
	. = ..()
	SyncRDevices()

/obj/machinery/computer/rdconsole/Destroy()
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.have_disk = TRUE
		linked_lathe.have_design_selector = TRUE
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.have_disk = TRUE
		linked_imprinter.have_design_selector = TRUE
		linked_imprinter.linked_console = null
		linked_imprinter = null
	return ..()

/obj/machinery/computer/rdconsole/use_tool(obj/item/D, mob/living/user, list/click_params)
	if(!user.canUnEquip(D))
		return TRUE

	// Мультитул - сохранить консоль в буфер для привязки к трекеру
	if(istype(D, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = D
		M.set_buffer(src)
		to_chat(user, SPAN_NOTICE("Вы сохранили [src.name] в буфер мультитула."))
		return TRUE

	//Loading a disk into it.
	else if(istype(D, /obj/item/stock_parts/computer/hard_drive/portable))
		if(disk)
			to_chat(user, SPAN_NOTICE("A disk is already loaded into the machine."))
			return

		user.drop_item()
		D.forceMove(src)
		disk = D
		to_chat(user, SPAN_NOTICE("You add \the [D] to the machine."))

	// Physical photo — submit for photograph_object mission objective
	else if(istype(D, /obj/item/photo))
		submit_physical_photo(user, D)
		return TRUE

	// Artifact analysis report — submit for study_artifact mission objective
	else if(istype(D, /obj/item/paper/anomaly_scan/mission))
		submit_artifact_report(user, D)
		return TRUE

	SSnano.update_uis(src)
	update_icon()
	return ..()

/obj/machinery/computer/rdconsole/emag_act(remaining_charges)
	if(!emagged)
		playsound(loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = TRUE
		to_chat(usr, SPAN_NOTICE("You disable the security protocols."))
		return TRUE

/obj/machinery/computer/rdconsole/proc/reset_screen() // simply resets the screen to the main screen and updates the UIs
	screen = SCREEN_MAIN
	SSnano.update_uis(src)

/obj/machinery/computer/rdconsole/proc/handle_item_analysis(obj/item/I) // handles deconstructing items.
	var/datum/research/F = get_server_files()
	if(!F)
		return
	F.check_item_for_tech(I)
	// NOTE: Research points removed - new system uses money and missions instead
	// Players can now extract designs to disk using "Extract Design" button
	F.experiments.do_research_object(I)

/obj/machinery/computer/rdconsole/proc/get_science_account()
	if(linked_account_number)
		return get_account(linked_account_number)
	if(department_account_key)
		return department_accounts[department_account_key]
	return null

/// Returns the research datum of the connected R&D server, or null if no server is reachable.
/// The console no longer owns a local datum/research — the server is the sole authoritative storage.
/obj/machinery/computer/rdconsole/proc/get_server_files()
	var/obj/machinery/r_n_d/server/S = get_server()
	return S ? S.files : null

/obj/machinery/computer/rdconsole/proc/get_server()
	for(var/obj/machinery/r_n_d/server/S in SSresearch.rnd_server_list)
		if(!S.files || MACHINE_IS_BROKEN(S))
			continue
		if(GLOB.using_map.use_overmap && !(src.z in GetConnectedZlevels(S.z)))
			continue
		// Explicit access list configured — use it.
		if(id in S.id_with_download)
			return S
		// No explicit list: pair by server_id == console id (e.g. away-site servers).
		if(S.server_id == id && !length(S.id_with_download) && !server_disconnected)
			return S
	return null

/// Print an R&D sales invoice linking to the science department account
/obj/machinery/computer/rdconsole/proc/print_rnd_invoice(mob/living/user)
	var/datum/money_account/science_account = get_science_account()
	if(!science_account)
		to_chat(user, SPAN_WARNING("Не удалось получить доступ к счёту научного отдела."))
		return

	var/obj/item/paper/manifest/rnd_invoice/invoice = new(get_turf(src))
	invoice.target_account_number = science_account.account_number
	invoice.target_account_name = science_account.account_name
	invoice.is_copy = FALSE
	if(!invoice.stamped)
		invoice.stamped = list()
	invoice.stamped += /obj/machinery/computer/rdconsole
	invoice.info = {"<h3>R&D Sales Invoice</h3>
<hr>
<b>Department:</b> Research & Development<br>
<b>Account:</b> [science_account.account_name]<br>
<b>Account #:</b> [science_account.account_number]<br>
<hr>
<i>Place this invoice in a cargo crate. All proceeds from the crate's sale will be credited to the account above.</i>"}

	to_chat(user, SPAN_NOTICE("Накладная напечатана. Счёт: [science_account.account_name] (#[science_account.account_number])."))

/// Find /datum/tech by its string ID (e.g. "materials", "engineering")
/obj/machinery/computer/rdconsole/proc/find_tech_by_id(tech_id)
	var/datum/research/F = get_server_files()
	if(!F)
		return null
	for(var/datum/tech/T in F.researched_tech)
		if(T.id == tech_id)
			return T
	return null

/// Link this console to a drone pad by its pad_id. Called from settings UI.
/obj/machinery/computer/rdconsole/proc/link_drone_pad(mob/user)
	var/entered_id = input(user, "Введите ID дрон пада (задаётся мультитулом на самом паде):", "Привязка дрон пада", linked_drone_pad_id) as num|null
	if(isnull(entered_id))
		return
	entered_id = round(entered_id)
	if(!entered_id)
		linked_drone_pad_id = 0
		to_chat(user, SPAN_NOTICE("Привязка к дрон паду сброшена."))
		SSnano.update_uis(src)
		return
	var/obj/machinery/drone_pad/rd_mission/found = null
	for(var/obj/machinery/drone_pad/rd_mission/P in SSmachines.get_machinery_of_type(/obj/machinery/drone_pad/rd_mission))
		if(P.pad_id == entered_id)
			found = P
			break
	if(!found)
		to_chat(user, SPAN_WARNING("Дрон пад с ID [entered_id] не найден."))
		return
	linked_drone_pad_id = entered_id
	found.linked_console = src
	to_chat(user, SPAN_NOTICE("Консоль привязана к дрон паду ID [entered_id]."))
	SSnano.update_uis(src)

/// Compile deconstructed tech levels into a sellable research report disk
/obj/machinery/computer/rdconsole/proc/compile_research_report(mob/living/user)
	var/datum/research/F = get_server_files()
	if(!F || !F.experiments)
		return

	var/list/saved = F.experiments.saved_tech_levels
	if(!LAZYLEN(saved))
		to_chat(user, SPAN_WARNING("Нет данных деконструкции. Поместите предметы в деструктивный анализатор."))
		return

	var/list/tech_data = list()
	var/delta = 0
	var/cargo_value = 0

	for(var/tech_id in saved)
		var/list/levels = saved[tech_id]
		if(!LAZYLEN(levels))
			continue
		var/max_level = 0
		for(var/lvl in levels)
			if(lvl > max_level)
				max_level = lvl
		var/compiled = F.compiled_tech_levels[tech_id]
		if(!compiled)
			compiled = 0
		if(max_level > compiled)
			var/new_levels = max_level - compiled
			delta += new_levels
			var/datum/tech/T = find_tech_by_id(tech_id)
			var/rare = T ? T.rare : 1
			// Progressive pricing: each level costs level × rare
			for(var/i = compiled + 1 to max_level)
				cargo_value += i * rare
			tech_data[tech_id] = max_level

	if(delta <= 0)
		to_chat(user, SPAN_WARNING("Нет новых данных для компиляции. Деконструируйте предметы с более высокими тех-уровнями."))
		return

	// Create the report disk
	var/obj/item/disk/research_report/report = new(get_turf(src))
	report.tech_data = tech_data.Copy()
	report.delta_levels = delta
	report.cargo_value = max(1, cargo_value * 15)

	// Update compiled levels on server directly
	for(var/tech_id in tech_data)
		F.compiled_tech_levels[tech_id] = tech_data[tech_id]

	to_chat(user, SPAN_NOTICE("Отчёт скомпилирован: [delta] новых уровней. Оценочная стоимость: [report.cargo_value] таллеров."))
	SSnano.update_uis(src)

/obj/machinery/computer/rdconsole/proc/buy_corp_node(mob/living/user, node_id)
	var/datum/research/F = get_server_files()
	if(!F || !node_id)
		return

	var/list/corp_nodes = get_rnd_category_tree_nodes(selected_category_id, selected_corp_id)
	var/list/corp_node_set = list()
	for(var/node_id_entry in corp_nodes)
		corp_node_set[node_id_entry] = TRUE
	if(!(node_id in corp_nodes))
		return

	var/datum/technology/tech_node = SSresearch.get_tech_node(node_id)
	if(!tech_node)
		return
	if(!get_rnd_corp_node_requirements_met(F, tech_node, corp_node_set))
		to_chat(user, SPAN_WARNING("Условия узла ещё не выполнены."))
		return

	var/price = get_rnd_corp_node_price(tech_node, F)
	var/datum/money_account/science_account = get_science_account()
	if(!science_account)
		to_chat(user, SPAN_WARNING("Не удалось получить доступ к счёту научного отдела."))
		return
	if(!science_account.withdraw(price, "Corporate R&D unlock: [tech_node.name]", "R&D Console"))
		to_chat(user, SPAN_WARNING("Недостаточно средств на счёте научного отдела."))
		return

	F.UnlockTechology(tech_node, force = TRUE)
	SSnano.update_uis(src)

/obj/machinery/computer/rdconsole/Topic(href, href_list) // Oh boy here we go.
	if(..())
		return 1

	var/obj/machinery/fabricator/rnd/target_device
	if(screen == SCREEN_PROTO && linked_lathe)
		target_device = linked_lathe
	else if(screen == SCREEN_IMPRINTER && linked_imprinter)
		target_device = linked_imprinter

	if(href_list["select_corp"]) // User selected a corporation tree.
		var/new_corp = href_list["select_corp"]
		if(get_rnd_corp_tree(new_corp))
			selected_corp_id = new_corp
			selected_node_id = null
	if(href_list["select_corp_node"]) // User selected a corporate tech node.
		selected_node_id = href_list["select_corp_node"]
	if(href_list["buy_corp_node"]) // User attempts to buy a corporate tech node.
		buy_corp_node(usr, href_list["buy_corp_node"])
	if(href_list["select_tech_tree"]) // User selected a tech tree.
		var/datum/research/F_stt = get_server_files()
		if(F_stt)
			var/datum/tech/tech_tree = locate(href_list["select_tech_tree"]) in F_stt.researched_tech
			if(tech_tree && tech_tree.shown)
				selected_tech_tree = tech_tree
				selected_technology = null
	if(href_list["select_technology"]) // User selected a technology node.
		var/tech_node = locate(href_list["select_technology"]) in SSresearch.all_tech_nodes
		if(tech_node)
			selected_technology = tech_node
	if(href_list["unlock_technology"]) // User attempts to unlock a technology node (Safeties are within UnlockTechnology)
		var/datum/research/F_ut = get_server_files()
		if(F_ut)
			var/tech_node = locate(href_list["unlock_technology"]) in SSresearch.all_tech_nodes
			if(tech_node)
				F_ut.UnlockTechology(tech_node)
	if(href_list["go_screen"]) // User is changing the screen.
		var/where = href_list["go_screen"]
		if(href_list["need_access"])
			if(!allowed(usr) && !emagged)
				to_chat(usr, SPAN_WARNING("Unauthorized access."))
				return
		screen = where
		if(screen == SCREEN_PROTO || screen == SCREEN_IMPRINTER || screen == SCREEN_DISK_DESIGNS)
			search_text = ""
		if(screen == SCREEN_DISK_DESIGNS)
			selected_disk_category = null
	if(href_list["eject_disk"]) // User is ejecting the disk.
		if(disk)
			disk.forceMove(get_turf(src))
			disk = null
	if(href_list["delete_disk_file"]) // User is attempting to delete a file from the loaded disk.
		if(disk)
			var/datum/computer_file/file = locate(href_list["delete_disk_file"]) in disk.stored_files
			disk.remove_file(file)

	if(href_list["download_disk_design"]) // User is attempting to upload (disk -> server) a design from the disk.
		if(disk)
			var/datum/computer_file/binary/design/file = locate(href_list["download_disk_design"]) in disk.stored_files
			if(file)
				var/datum/research/F_dd = get_server_files()
				if(F_dd)
					F_dd.AddDesign2Known(file.design)
				else
					to_chat(usr, SPAN_WARNING("Нет подключения к серверу. Дизайн не загружен."))
	if(href_list["upload_disk_design"]) // User is attempting to save (server -> disk) a design to the disk.
		if(disk)
			var/obj/machinery/r_n_d/server/S_ud = get_server()
			if(S_ud)
				var/datum/computer_file/binary/design/src_file = locate(href_list["upload_disk_design"]) in S_ud.get_all_hdd_files()
				if(src_file)
					disk.save_file(src_file.clone())
	if(href_list["toggle_settings"]) // User wants to see the settings.
		if(allowed(usr) || emagged)
			show_settings = !show_settings
		else
			to_chat(usr, SPAN_WARNING("Unauthorized access."))
	if(href_list["link_account"]) // User wants to link a billing account by credentials.
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
	if(href_list["unlink_account"]) // User wants to unlink the billing account.
		if(!can_switch_account)
			return
		linked_account_number = 0
		department_account_key = null
		to_chat(usr, SPAN_NOTICE("Счёт отвязан."))
	if(href_list["link_drone_pad"])
		if(allowed(usr) || emagged)
			link_drone_pad(usr)
		else
			to_chat(usr, SPAN_WARNING("Unauthorized access."))
	if(href_list["toggle_link_menu"]) // User wants to see the device linkage menu.
		if(allowed(usr) || emagged)
			show_link_menu = !show_link_menu
		else
			to_chat(usr, SPAN_WARNING("Unauthorized access."))
	if(href_list["sync"])
		if(!get_server())
			to_chat(usr, SPAN_WARNING("Консоль не подключена к серверу R&D."))
		else
			screen = SCREEN_WORKING
			addtimer(new Callback(src, PROC_REF(sync_tech), usr), 3 SECONDS)
	if(href_list["togglesync"])
		var/obj/machinery/r_n_d/server/cur = get_server()
		if(cur)
			cur.id_with_download -= id
			server_disconnected = TRUE
			to_chat(usr, SPAN_NOTICE("Консоль отключена от [cur.name]."))
		else
			var/entered_id = input(usr, "Введите сетевой ID сервера (задаётся мультитулом):", "Подключение к серверу", 1) as num|null
			if(!isnull(entered_id))
				entered_id = round(entered_id)
				var/obj/machinery/r_n_d/server/found = null
				for(var/obj/machinery/r_n_d/server/FS in SSresearch.rnd_server_list)
					if(FS.server_id == entered_id && FS.files)
						if(GLOB.using_map.use_overmap && !(src.z in GetConnectedZlevels(FS.z)))
							continue
						found = FS
						break
				if(found)
					server_disconnected = FALSE
					if(!(id in found.id_with_download))
						found.id_with_download += id
					to_chat(usr, SPAN_NOTICE("Консоль подключена к [found.name] (ID: [found.server_id])."))
				else
					to_chat(usr, SPAN_WARNING("Сервер с ID [entered_id] не найден в сети."))
	if(href_list["select_category"]) // User is selecting a design category while in the protolathe/imprinter screen
		var/what_cat = href_list["select_category"]
		if(screen == SCREEN_PROTO)
			selected_protolathe_category = what_cat
		if(screen == SCREEN_IMPRINTER)
			selected_imprinter_category = what_cat
	if(href_list["select_tech_category"]) // User is selecting a tech tree category
		selected_category_id = href_list["select_tech_category"]
		selected_corp_id = null
		selected_node_id = null
	if(href_list["select_corp_dialogue"]) // User is selecting a corporation for dialogue
		selected_dialogue_corp_id = href_list["select_corp_dialogue"]
	if(href_list["select_disk_category"]) // User is selecting a disk design category
		selected_disk_category = href_list["select_disk_category"]
		if(selected_disk_category == "__all__")
			selected_disk_category = null
	if(href_list["search"]) // User is searching for a specific design.
		var/input = sanitizeSafe(input(usr, "Enter text to search", "Searching") as null|text, MAX_LNAME_LEN)
		search_text = input
		if(screen == SCREEN_PROTO)
			if(!search_text)
				selected_protolathe_category = null
			else
				selected_protolathe_category = "Search Results"
		if(screen == SCREEN_IMPRINTER)
			if(!search_text)
				selected_imprinter_category = null
			else
				selected_imprinter_category = "Search Results"
		if(screen == SCREEN_DISK_DESIGNS)
			if(!search_text)
				searched_disk_design_text = null
			else
				searched_disk_design_text = "Search Results"

	if(href_list["clear_search"]) // User is clearing the search.
		if(screen == SCREEN_PROTO)
			selected_protolathe_category = null
		if(screen == SCREEN_IMPRINTER)
			selected_imprinter_category = null
		if(screen == SCREEN_DISK_DESIGNS)
			searched_disk_design_text = null
		search_text = ""

	if(href_list["deconstruct"]) // User is deconstructing an item.
		if(linked_destroy)
			if(linked_destroy.deconstruct_item())
				screen = SCREEN_WORKING // Will be resetted by the linked_destroy.
	if(href_list["eject_item"]) // User is ejecting an item from the linked_destroy.
		if(linked_destroy)
			linked_destroy.eject_item()
	if(href_list["extract_design"]) // User is extracting design from item to disk.
		extract_design_to_disk(usr)

	// Spectral analysis handlers
	if(href_list["start_spectral"])
		start_spectral(usr)
	if(href_list["spectral_choice"])
		do_spectral_step(usr, href_list["spectral_choice"])
	if(href_list["cancel_spectral"])
		cancel_spectral()
	if(href_list["clear_spectral"])
		spectral_result_text = ""
		SSnano.update_uis(src)

	// Artifact catalogization handlers
	if(href_list["start_catalog"])
		start_catalog(usr, href_list["start_catalog"])
	if(href_list["catalog_choice"])
		do_catalog_step(usr, href_list["catalog_choice"])
	if(href_list["cancel_catalog"])
		cancel_catalog()
	if(href_list["clear_catalog"])
		catalog_result_text = ""
		SSnano.update_uis(src)

	// Research report compilation
	if(href_list["compile_report"])
		compile_research_report(usr)
	if(href_list["toggle_report_collapse"])
		report_collapsed = !report_collapsed
		SSnano.update_uis(src)
	if(href_list["print_invoice"])
		print_rnd_invoice(usr)

	if(href_list["build"])
		var/obj/machinery/r_n_d/server/S_b = get_server()
		if(S_b)
			var/datum/research/F_b = S_b.files
			var/amount = clamp(text2num(href_list["amount"]), 1, 10)
			var/datum/design/being_built = locate(href_list["build"]) in S_b.get_all_designs()
			if(being_built && target_device)
				if(("[being_built.id]" in F_b.banned_designs) || is_design_banned_on_server("[being_built.id]"))
					to_chat(usr, SPAN_WARNING("Производство этого дизайна запрещено."))
				else
					target_device.queue_design(being_built.file, amount)
	if(href_list["clear_queue"]) // Clearing a queue
		if(target_device)
			target_device.clear_queue()
	if(href_list["eject_sheet"]) // Removing material sheets
		if(target_device)
			target_device.eject(href_list["eject_sheet"], text2num(href_list["amount"]))

	if(href_list["find_device"]) // Connect with the local devices
		screen = SCREEN_WORKING
		addtimer(new Callback(src, PROC_REF(find_devices)), 2 SECONDS)
	if(href_list["disconnect"]) //The R&D console disconnects with a specific device.
		switch(href_list["disconnect"])
			if("destroy")
				linked_destroy.linked_console = null
				linked_destroy = null
			if("lathe")
				linked_lathe.have_disk = TRUE
				linked_lathe.have_design_selector = TRUE
				linked_lathe.linked_console = null
				linked_lathe = null
			if("imprinter")
				linked_imprinter.have_disk = TRUE
				linked_imprinter.have_design_selector = TRUE
				linked_imprinter.linked_console = null
				linked_imprinter = null

	if(href_list["reset"]) // Database is now on the server — cannot be reset from the console.
		to_chat(usr, SPAN_WARNING("База данных хранится на сервере R&D. Для сброса обратитесь к серверной машине напрямую."))
	if(href_list["lock"]) //Lock the console from use by anyone without tox access.
		if(allowed(usr) || emagged)
			screen = SCREEN_LOCKED
		else
			to_chat(usr, SPAN_WARNING("Unauthorized access."))
	if(href_list["unlock"]) // Unlock
		if(allowed(usr) || emagged)
			screen = SCREEN_MAIN
		else
			to_chat(usr, SPAN_WARNING("Unauthorized access."))

	// Submit RDF scan file from disk for scan_object mission objective
	if(href_list["submit_rdf"])
		submit_rdf_file(usr, href_list["submit_rdf"], href_list["submit_rdf_mission"])

	// Submit digital photo from disk for photograph_object mission objective
	if(href_list["submit_photo"])
		submit_digital_photo(usr, href_list["submit_photo"], href_list["submit_photo_mission"])

	return TRUE

/// Check if design is banned on any connected server
/obj/machinery/computer/rdconsole/proc/is_design_banned_on_server(design_id)
	for(var/obj/machinery/r_n_d/server/S in SSresearch.rnd_server_list)
		if(istype(S, /obj/machinery/r_n_d/server/centcom))
			continue
		if(GLOB.using_map.use_overmap && !(src.z in GetConnectedZlevels(S.z)))
			continue
		if(!(id in S.id_with_download))
			continue
		if(design_id in S.files.banned_designs)
			return TRUE
	return FALSE

/obj/machinery/computer/rdconsole/proc/find_devices()
	SyncRDevices()
	reset_screen()

/// Sync: if a disk is inserted, upload its designs to the server.
/// The console no longer has a local research datum, so there is nothing else to sync.
/obj/machinery/computer/rdconsole/proc/sync_tech(mob/user)
	var/datum/research/F = get_server_files()
	if(!F)
		to_chat(user, SPAN_WARNING("Нет подключения к серверу R&D."))
		reset_screen()
		return

	if(disk)
		var/uploaded = 0
		for(var/datum/computer_file/binary/design/file in disk.find_files_by_type(/datum/computer_file/binary/design))
			if(file.design)
				F.AddDesign2Known(file.design)
				uploaded++
		if(uploaded)
			to_chat(user, SPAN_NOTICE("Загружено [uploaded] дизайн(ов) с диска на сервер."))

	// Also notify any connected server to produce heat (legacy behaviour for balance)
	for(var/obj/machinery/r_n_d/server/S in SSresearch.rnd_server_list)
		if(GLOB.using_map.use_overmap && !(src.z in GetConnectedZlevels(S.z)))
			continue
		if((id in S.id_with_upload) || (id in S.id_with_download))
			S.produce_heat(400)
			break

	reset_screen()

// --- Mission data submission procs ---

/obj/machinery/computer/rdconsole/proc/submit_physical_photo(mob/user, obj/item/photo/P)
	if(!LAZYLEN(P.captured_object_types))
		to_chat(user, SPAN_WARNING("Фотография не содержит распознаваемых объектов."))
		return
	for(var/datum/derelict_mission/M in derelict_missions_list)
		if(M.state != RND_MISSION_STATE_AVAILABLE)
			continue
		for(var/datum/derelict_mission_objective/O in M.objectives)
			if(O.objective_type != "photograph_object" || O.completed)
				continue
			if(M.away_z && P.photo_z != M.away_z)
				continue
			for(var/captured_type in P.captured_object_types)
				if(ispath(captured_type, O.target_type))
					O.advance()
					to_chat(user, SPAN_NOTICE("Контракт \"[M.title]\": фотография принята. ([O.get_status_text()])"))
					user.drop_from_inventory(P)
					qdel(P)
					SSnano.update_uis(src)
					return
	to_chat(user, SPAN_WARNING("Фотография не соответствует ни одному активному контракту."))

/obj/machinery/computer/rdconsole/proc/submit_artifact_report(mob/user, obj/item/paper/anomaly_scan/mission/report)
	for(var/datum/derelict_mission/M in derelict_missions_list)
		if(M.state != RND_MISSION_STATE_AVAILABLE)
			continue
		if(!M.target_artifact_report_type)
			continue
		for(var/datum/derelict_mission_objective/O in M.objectives)
			if(O.objective_type != "study_artifact" || O.completed)
				continue
			if(istype(report, M.target_artifact_report_type))
				O.advance()
				to_chat(user, SPAN_NOTICE("Контракт \"[M.title]\": отчёт об артефакте принят. ([O.get_status_text()])"))
				user.drop_from_inventory(report)
				qdel(report)
				SSnano.update_uis(src)
				return
	to_chat(user, SPAN_WARNING("Отчёт не соответствует ни одному активному контракту."))

/obj/machinery/computer/rdconsole/proc/submit_rdf_file(mob/user, rdf_ref, mission_ref)
	if(!disk)
		return
	var/datum/computer_file/data/rdf/rdf_file = locate(rdf_ref) in disk.stored_files
	if(!istype(rdf_file))
		return
	var/target_type_str = rdf_file.metadata ? rdf_file.metadata["target_type"] : null
	var/scan_z = text2num(rdf_file.metadata ? rdf_file.metadata["scan_z"] : "0")
	if(!target_type_str)
		to_chat(user, SPAN_WARNING("Файл RDF повреждён: нет данных о цели сканирования."))
		return
	var/datum/derelict_mission/M = locate(mission_ref) in derelict_missions_list
	if(!M || M.state != RND_MISSION_STATE_AVAILABLE)
		to_chat(user, SPAN_WARNING("Контракт недоступен."))
		return
	for(var/datum/derelict_mission_objective/O in M.objectives)
		if(O.objective_type != "scan_object" || O.completed)
			continue
		if(M.away_z && scan_z != M.away_z)
			continue
		var/type_str = "[O.target_type]"
		if(target_type_str != type_str && !dd_hasprefix(target_type_str, "[type_str]/"))
			continue
		O.advance()
		to_chat(user, SPAN_NOTICE("Контракт \"[M.title]\": данные сканирования приняты. ([O.get_status_text()])"))
		disk.remove_file(rdf_file)
		SSnano.update_uis(src)
		return
	to_chat(user, SPAN_WARNING("Данные сканирования не соответствуют целям выбранного контракта."))

/obj/machinery/computer/rdconsole/proc/submit_digital_photo(mob/user, photo_ref, mission_ref)
	if(!disk)
		return
	var/datum/computer_file/binary/photo/photo_file = locate(photo_ref) in disk.stored_files
	if(!istype(photo_file) || !photo_file.photo)
		return
	var/datum/derelict_mission/M = locate(mission_ref) in derelict_missions_list
	if(!M || M.state != RND_MISSION_STATE_AVAILABLE)
		to_chat(user, SPAN_WARNING("Контракт недоступен."))
		return
	var/obj/item/photo/p = photo_file.photo
	if(!LAZYLEN(p.captured_object_types))
		to_chat(user, SPAN_WARNING("Фотография не содержит распознаваемых объектов."))
		return
	for(var/datum/derelict_mission_objective/O in M.objectives)
		if(O.objective_type != "photograph_object" || O.completed)
			continue
		if(M.away_z && p.photo_z != M.away_z)
			continue
		for(var/captured_type in p.captured_object_types)
			if(ispath(captured_type, O.target_type))
				O.advance()
				to_chat(user, SPAN_NOTICE("Контракт \"[M.title]\": фотография принята. ([O.get_status_text()])"))
				disk.remove_file(photo_file)
				SSnano.update_uis(src)
				return
	to_chat(user, SPAN_WARNING("Фотография не соответствует целям выбранного контракта."))


/obj/machinery/computer/rdconsole/proc/get_possible_designs_data(obj/machinery/fabricator/rnd/target_machine, category) // Builds the design list for the UI
	var/obj/machinery/r_n_d/server/S_gpd = get_server()
	if(!S_gpd)
		return list()
	var/datum/research/F = S_gpd.files
	var/list/designs_list = list()
	for(var/datum/design/D in S_gpd.get_all_designs())
		if(D.build_type & target_machine.build_type)
			var/cat = "Unspecified"
			if(D.category)
				cat = D.category
			if((category in cat) || (category == "Search Results" && findtext(D.name, search_text)))
				var/list/missing_materials = list()
				var/list/missing_chemicals = list()
				var/can_build = 50
				var/can_build_temp

				for(var/material in D.materials)
					can_build_temp = target_machine.check_craftable_amount_by_material(D, material)
					if(can_build_temp < 1)
						missing_materials += material
					can_build = min(can_build, can_build_temp)

				for(var/chemical in D.chemicals)
					can_build_temp = target_machine.check_craftable_amount_by_chemical(D, chemical)
					if(can_build_temp < 1)
						missing_chemicals += chemical
					can_build = min(can_build, can_build_temp)

				var/is_banned = ("[D.id]" in F.banned_designs) || is_design_banned_on_server("[D.id]")
				designs_list += list(list(
					"data" = D.ui_data(),
					"id" = "\ref[D]",
					"can_create" = is_banned ? 0 : can_build,
					"missing_materials" = missing_materials,
					"missing_chemicals" = missing_chemicals,
					"banned" = is_banned
				))
	return designs_list

/obj/machinery/computer/rdconsole/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)


/obj/machinery/computer/rdconsole/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null) // Here we go again
	if((screen == SCREEN_PROTO && !linked_lathe) || (screen == SCREEN_IMPRINTER && !linked_imprinter))
		screen = SCREEN_MAIN // Kick us from protolathe or imprinter screen if they were destroyed

	var/datum/research/F = get_server_files()

	var/list/data = list()
	data["screen"] = screen
	var/obj/machinery/r_n_d/server/connected_server = get_server()
	data["sync"] = !!connected_server
	data["has_disk"] = !!disk
	data["has_server"] = !!connected_server
	data["server_name"] = connected_server ? connected_server.name : ""

	// Science balance (shown on nav bar)
	var/datum/money_account/sci_acc = get_science_account()
	data["science_balance"] = sci_acc ? sci_acc.money : 0
	data["has_science_account"] = !!sci_acc
	data["science_account_name"] = sci_acc ? sci_acc.account_name : ""
	data["currency_short"] = GLOB.using_map.local_currency_name_short
	data["can_switch_account"] = can_switch_account
	data["linked_account_number"] = linked_account_number
	if(disk)
		data["disk_size"] = disk.max_capacity
		data["disk_used"] = disk.used_capacity
		data["disk_read_only"] = disk.read_only

	// Main screen needs info about tech levels
	if(!screen || screen == SCREEN_MAIN)
		data["show_settings"] = show_settings
		data["show_link_menu"] = show_link_menu
		data["has_dest_analyzer"] = !!linked_destroy
		data["has_protolathe"] = !!linked_lathe
		data["has_circuit_imprinter"] = !!linked_imprinter
		data["can_research"] = can_research
		data["linked_drone_pad_id"] = linked_drone_pad_id

		var/list/tech_tree_list = list()
		if(F)
			for(var/tree in F.researched_tech)
				var/datum/tech/tech_tree = tree
				if(!tech_tree.shown)
					continue
				var/list/tech_tree_data = list(
					"id" =             tech_tree.type,
					"name" =           "[tech_tree.name]",
					"shortname" =      "[tech_tree.shortname]",
					"level" =          tech_tree.level,
					"maxlevel" =       tech_tree.maxlevel,
				)
				tech_tree_list += list(tech_tree_data)
		data[SCREEN_TREES] = tech_tree_list

		if(linked_destroy)
			if(linked_destroy.loaded_item)
				// TODO: If you're refactoring origin_tech, remove this shit. Thank you from the past!
				var/list/tech_names = list(TECH_MATERIAL = "Materials", TECH_ENGINEERING = "Engineering", TECH_PHORON = "Phoron", TECH_POWER = "Power", TECH_BLUESPACE = "Blue-space", TECH_BIO = "Biotech", TECH_COMBAT = "Combat", TECH_MAGNET = "Electromagnetic", TECH_DATA = "Programming", TECH_ESOTERIC = "Esoteric")

				var/list/temp_tech = linked_destroy.loaded_item.origin_tech
				var/list/item_data = list()

				for(var/T in temp_tech)
					var/tech_name = tech_names[T]
					if(!tech_name)
						tech_name = T

					item_data += list(list(
						"id" =             T,
						"name" =           tech_name,
						"level" =          temp_tech[T],
					))

				var/list/destroy_list = list(
					"has_item" =              TRUE,
					"item_name" =             linked_destroy.loaded_item.name,
				)
				destroy_list["tech_data"] = item_data

				// Spectral analysis: can we analyze this item type?
				var/can_spectral = F ? !(linked_destroy.loaded_item.type in F.spectral_analyzed_types) : FALSE
				destroy_list["can_spectral"] = can_spectral

				data["destroy_data"] = destroy_list
			else
				var/list/destroy_list = list(
					"has_item" =             FALSE,
				)
				data["destroy_data"] = destroy_list

	if(screen == SCREEN_DISK_DESIGNS)
		if(disk)
			var/list/disk_design_files = disk.find_files_by_type(/datum/computer_file/binary/design)
			data["search_text"] = search_text

			// Collect categories from all HDD files on the server (including unregistered drives)
			var/list/all_disk_categories = list()
			var/obj/machinery/r_n_d/server/S_ddc = get_server()
			if(S_ddc)
				for(var/datum/computer_file/binary/design/cat_F in S_ddc.get_all_hdd_files())
					var/datum/design/cat_D = cat_F.design
					if(!cat_D || !cat_D.category)
						continue
					for(var/cat in cat_D.category)
						all_disk_categories |= cat
			data["disk_design_categories"] = all_disk_categories
			data["selected_disk_category"] = selected_disk_category

			// Build disk designs list
			var/list/disk_designs = list()
			for(var/f in disk_design_files)
				var/datum/computer_file/binary/design/d_file = f
				if(search_text && !findtext(d_file.design.name, search_text))
					continue
				if(selected_disk_category && !(selected_disk_category in d_file.design.category))
					continue
				disk_designs += list(list("name" = d_file.design.name, "id" = "\ref[d_file]"))
			data["disk_designs"] = disk_designs

			// Build server known designs list from all HDD files (including unregistered drives)
			var/list/known_designs = list()
			var/obj/machinery/r_n_d/server/S_kd = get_server()
			if(S_kd)
				for(var/datum/computer_file/binary/design/kd_F in S_kd.get_all_hdd_files())
					var/datum/design/D = kd_F.design
					if(!D)
						continue
					if(search_text && !findtext(D.name, search_text))
						continue
					if(selected_disk_category && !(selected_disk_category in D.category))
						continue
					known_designs += list(list("name" = D.name, "id" = "\ref[kd_F]"))
			data["known_designs"] = known_designs

	if(screen == SCREEN_DISK_TECH)
		if(disk)
			var/list/disk_tech_nodes = list()
			var/list/disk_technology_files = disk.find_files_by_type(/datum/computer_file/binary/design)
			for(var/f in disk_technology_files)
				var/datum/computer_file/binary/design/tech_file = f
				disk_tech_nodes += list(list("name" = tech_file.design.name, "id" = "\ref[tech_file]"))
			data["disk_tech_nodes"] = disk_tech_nodes
			var/list/known_nodes = list()
			if(F)
				for(var/i in F.researched_nodes)
					var/datum/technology/T = i
					known_nodes += list(list("name" = T.name, "id" = "\ref[T]"))
			data["known_nodes"] = known_nodes
	if(screen == SCREEN_PROTO || screen == SCREEN_IMPRINTER)
		var/obj/machinery/fabricator/rnd/target_device
		var/list/design_categories
		var/selected_category

		if(screen == SCREEN_PROTO && linked_lathe)
			target_device = linked_lathe
			design_categories = F ? F.design_categories_protolathe : list()
			selected_category = selected_protolathe_category
		else if(screen == SCREEN_IMPRINTER && linked_imprinter)
			target_device = linked_imprinter
			design_categories = F ? F.design_categories_imprinter : list()
			selected_category = selected_imprinter_category

		if(target_device)
			data["search_text"] = search_text
			data["materials_data"] = target_device.materials_data()

			data["all_categories"] = design_categories
			if(search_text)
				data["all_categories"] = list("Search Results") + data["all_categories"]

			// HDD capacity per original design category
			var/list/hdd_capacities = list()
			var/obj/machinery/r_n_d/server/S_hdd = get_server()
			if(S_hdd)
				for(var/orig_cat in design_categories)
					var/hdd_cat = S_hdd.get_hdd_category(orig_cat)
					var/obj/item/stock_parts/computer/hard_drive/HDD = S_hdd.rnd_drives[hdd_cat]
					if(HDD)
						hdd_capacities[orig_cat] = list("used" = HDD.used_capacity, "max" = HDD.max_capacity)
			data["hdd_capacities"] = hdd_capacities

			if((!selected_category || !(selected_category in data["all_categories"])) && LAZYLEN(design_categories))
				selected_category = design_categories[1]

			if(selected_category)
				data["selected_category"] = selected_category
				data["possible_designs"] = get_possible_designs_data(target_device, selected_category)

			if(target_device.current_file)
				data["device_current"] = target_device.current_file.design.name

			data["device_error"] = target_device.error

			var/list/queue_list = list()
			for(var/f in target_device.queue)
				var/datum/computer_file/binary/design/file = f
				queue_list += file.design.name
			data["queue"] = queue_list

	// All the info needed for displaying tech trees (category-based)
	if(screen == SCREEN_TREES)
		// Tech categories
		var/list/all_categories = get_rnd_tech_categories()
		var/list/categories_list = list()
		for(var/cat_id in all_categories)
			var/list/category = all_categories[cat_id]
			if(!category)
				continue
			categories_list += list(list("id" = cat_id, "name" = category["name"]))
		data["categories"] = categories_list

		var/sel_category = selected_category_id
		if(!sel_category || !get_rnd_category(sel_category))
			sel_category = all_categories && length(all_categories) ? all_categories[1] : null
			selected_category_id = sel_category
		data["selected_category"] = sel_category

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

		var/list/corp_node_ids = get_rnd_category_tree_nodes(sel_category, selected_corp)
		var/list/corp_node_set = list()
		for(var/node_id in corp_node_ids)
			corp_node_set[node_id] = TRUE

		var/list/corp_nodes = list()
		var/list/corp_lines = list()
		for(var/node_id in corp_node_ids)
			var/datum/technology/tech_node = SSresearch.get_tech_node(node_id)
			if(!tech_node)
				continue
			var/is_researched = F ? F.IsResearched(tech_node) : FALSE
			var/can_unlock = F ? get_rnd_corp_node_requirements_met(F, tech_node, corp_node_set) : FALSE
			var/list/node_data = list(
				"id" = node_id,
				"name" = tech_node.name,
				"x" = round(tech_node.x * 100),
				"y" = round(tech_node.y * 100),
				"icon" = "[tech_node.icon]",
				"isresearched" = is_researched,
				"canunlock" = can_unlock
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
			var/datum/technology/tech_node = SSresearch.get_tech_node(selected_node)
			if(tech_node)
				var/is_researched = F ? F.IsResearched(tech_node) : FALSE
				var/can_unlock = F ? get_rnd_corp_node_requirements_met(F, tech_node, corp_node_set) : FALSE
				var/price = get_rnd_corp_node_price(tech_node, F)
				var/list/technology_data = list(
					"name" = tech_node.name,
					"desc" = tech_node.desc,
					"price" = price,
					"isresearched" = is_researched,
					"canunlock" = can_unlock,
					"can_buy" = can_unlock
				)

				if(tech_node.required_corp_id)
					var/current_rep = F ? F.GetCorporationReputation(tech_node.required_corp_id) : 0
					var/required_rep = tech_node.min_reputation
					technology_data["current_reputation"] = current_rep
					technology_data["required_reputation"] = required_rep
					technology_data["reputation_met"] = (current_rep >= required_rep)
					technology_data["corp_id"] = get_rnd_mission_corporation_name(tech_node.required_corp_id)

				var/list/requirement_list = list()
				for(var/t in tech_node.required_tech_levels)
					var/datum/tech/tree = F ? (locate(t) in F.researched_tech) : null
					var/level = tech_node.required_tech_levels[t]
					var/list/req_data = list(
						"text" = "[tree ? tree.shortname : t] level [level]",
						"isgood" = (tree && tree.level >= level)
					)
					requirement_list += list(req_data)
				for(var/t in tech_node.required_technologies)
					var/datum/technology/other_tech = locate(t) in SSresearch.all_tech_nodes
					if(!other_tech)
						continue
					var/list/req_data = list(
						"text" = "[other_tech.name]",
						"isgood" = F ? F.IsResearched(other_tech) : FALSE
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

	// Derelict missions screen
	if(screen == SCREEN_MISSIONS)
		var/list/mission_list = list()
		for(var/datum/derelict_mission/M in derelict_missions_list)
			var/list/obj_list = list()
			for(var/datum/derelict_mission_objective/O in M.objectives)
				obj_list += list(list(
					"description" = O.description,
					"status" = O.get_status_text(),
					"completed" = O.completed
				))
			mission_list += list(list(
				"id" = M.id,
				"ref" = "\ref[M]",
				"title" = M.title,
				"description" = M.description,
				"corp_name" = get_rnd_mission_corporation_name(M.corporation_id),
				"site_name" = M.away_site_name,
				"mission_type" = M.mission_type,
				"state" = M.state,
				"objectives" = obj_list
			))
		data["missions"] = mission_list

		// Disk file data for submission UI
		data["has_disk"] = !!disk
		if(disk)
			var/list/rdf_files = list()
			for(var/datum/computer_file/data/rdf/rdf_file in disk.stored_files)
				rdf_files += list(list(
					"id" = "\ref[rdf_file]",
					"filename" = "[rdf_file.filename].[rdf_file.filetype]",
					"scan_area" = (rdf_file.metadata ? rdf_file.metadata["scan_area"] : "???")
				))
			data["rdf_files"] = rdf_files
			var/list/photo_files = list()
			for(var/datum/computer_file/binary/photo/photo_file in disk.stored_files)
				photo_files += list(list(
					"id" = "\ref[photo_file]",
					"filename" = "[photo_file.filename].[photo_file.filetype]"
				))
			data["photo_files"] = photo_files

	// Corporation reputation screen
	if(screen == SCREEN_CORPS)
		var/list/corporations = get_rnd_mission_corporations()
		var/list/corps_data = list()
		for(var/corp_id in corporations)
			var/corp_name = get_rnd_mission_corporation_name(corp_id)
			var/current_rep = F ? F.GetCorporationReputation(corp_id) : 0
			corps_data += list(list(
				"id" = corp_id,
				"name" = corp_name,
				"reputation" = current_rep
			))
		data["corporations"] = corps_data
		data["selected_dialogue_corp_id"] = selected_dialogue_corp_id

		if(selected_dialogue_corp_id)
			var/corp_name = get_rnd_mission_corporation_name(selected_dialogue_corp_id)
			var/current_rep = F ? F.GetCorporationReputation(selected_dialogue_corp_id) : 0
			var/corp_info_text = get_rdconsole_corp_info(selected_dialogue_corp_id)
			data["selected_corp_dialogue"] = list(
				"name" = corp_name,
				"reputation" = current_rep,
				"reputation_color" = (current_rep >= 0 ? "#00ff00" : "#ff0000"),
				"info" = corp_info_text
			)

	// Spectral analysis state
	data["spectral_active"] = spectral_active
	data["spectral_phase"] = spectral_phase
	data["spectral_flash"] = spectral_flash
	data["spectral_result_text"] = spectral_result_text
	if(spectral_active && LAZYLEN(spectral_sequence))
		data["spectral_total"] = LAZYLEN(spectral_sequence)
		data["spectral_index"] = spectral_index

	// Artifact catalogization state
	data["catalog_active"] = catalog_active
	data["catalog_step"] = catalog_step
	data["catalog_result_text"] = catalog_result_text
	if(catalog_active && catalog_step >= 1 && catalog_step <= 3)
		data["catalog_step_name"] = get_catalog_step_name(catalog_step)
		data["catalog_step_hint"] = get_catalog_step_hint(catalog_step)

	// Check for artifact RDF files on disk available for catalogization
	if(!catalog_active)
		var/list/artifact_files = find_artifact_rdf_files()
		if(LAZYLEN(artifact_files))
			var/list/file_list = list()
			for(var/datum/computer_file/data/rdf/rdf_file in artifact_files)
				file_list += list(list("name" = rdf_file.filename, "ref" = "\ref[rdf_file]", "artifact_id" = rdf_file.metadata["artifact_id"]))
			data["catalog_files"] = file_list
			data["can_catalog"] = TRUE
		else
			data["can_catalog"] = FALSE
	else
		data["can_catalog"] = FALSE

	// Research report compilation state — based on deconstructed item tech levels
	if(F && F.experiments)
		var/list/report_tech_data = list()
		var/report_delta = 0
		var/report_value = 0
		var/list/saved = F.experiments.saved_tech_levels
		for(var/tech_id in saved)
			var/list/levels = saved[tech_id]
			if(!LAZYLEN(levels))
				continue
			var/max_level = 0
			for(var/lvl in levels)
				if(lvl > max_level)
					max_level = lvl
			var/compiled = F.compiled_tech_levels[tech_id]
			if(!compiled)
				compiled = 0
			var/new_levels = max(0, max_level - compiled)
			var/datum/tech/T = find_tech_by_id(tech_id)
			var/tech_name = T ? T.shortname : tech_id
			var/rare = T ? T.rare : 1
			var/tech_value = 0
			for(var/i = compiled + 1 to max_level)
				tech_value += i * rare
			tech_value *= 15
			report_tech_data += list(list("name" = tech_name, "level" = max_level, "compiled" = compiled, "new_levels" = new_levels, "value" = tech_value))
			report_delta += new_levels
			report_value += tech_value
		data["report_tech_data"] = report_tech_data
		data["report_delta"] = report_delta
		data["report_value"] = report_value
		data["can_compile"] = (report_delta > 0)
		data["report_collapsed"] = report_collapsed

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "mods-rdconsole.tmpl", "R&D Console", 1200, 700)

		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/rdconsole/robotics
	name = "Robotics R&D Console"
	id = 2
	req_access = list(access_robotics)

/// Универсальная консоль без привязанного счёта (дереликты, авейки, колонии).
/// Игроки могут привязать любой счёт через учётные данные.
/obj/machinery/computer/rdconsole/core
	name = "Core R&D Console"
	id = 0
	can_switch_account = TRUE

/// Основная РнД-консоль НИО на станции. Привязана к счёту научного отдела.
/obj/machinery/computer/rdconsole/core/sierra
	name = "R&D Control Console"
	id = 1
	department_account_key = "Научный"
	can_switch_account = TRUE


/obj/machinery/computer/rdconsole/attack_ai(mob/user)
	return ui_interact(user)

/obj/machinery/computer/rdconsole/attack_ghost(mob/user)
	return ui_interact(user)

/obj/machinery/fabricator/attack_ai(mob/user)
	return ui_interact(user)

/obj/machinery/fabricator/attack_ghost(mob/user)
	return ui_interact(user)

/obj/machinery/computer/rdconsole/proc/get_rdconsole_corp_info(corp_id)
	switch(corp_id)
		if(RND_MISSION_CORP_NANOTRASEN)
			return "NanoTrasen — крупнейший работодатель и главный спонсор космических станций. Специализируется на передовых исследованиях и разработках."
		if(RND_MISSION_CORP_WARD_TAKAHASHI)
			return "Ward-Takahashi GMB — известна продвинутой электроникой, компьютерными системами и передовыми технологиями."
		if(RND_MISSION_CORP_GRAYSON)
			return "Grayson Manufactories Ltd. — производитель промышленного оборудования, горнодобывающих инструментов и систем переработки."
		if(RND_MISSION_CORP_AETHER)
			return "Aether Atmospherics — специализируется на атмосферных технологиях, газовых системах и средствах жизнеобеспечения."
		if(RND_MISSION_CORP_EINSTEIN)
			return "Einstein Engines — производитель высокопроизводительных двигателей, энергетических систем и силовых установок."
		if(RND_MISSION_CORP_XION)
			return "Xion Industrial — революционные методы производства, интегральные схемы и логистические системы."
		if(RND_MISSION_CORP_SLATE)
			return "Slate Sisters Engineering — лидер в области корабельного оборудования, навигации и щитовых систем."
		if(RND_MISSION_CORP_FOCAL)
			return "Focal Point Dynamics — разработка энергосистем нового поколения, солнечных панелей и накопителей энергии."
		if(RND_MISSION_CORP_DAIS)
			return "DAIS — специализируется на телекоммуникационных системах, сетевых технологиях и автоматизации."
		if(RND_MISSION_CORP_KAPPA)
			return "Kappa Communications — инновационные решения в области субкосмической связи и блюспейс-ретрансляторов."
		if(RND_MISSION_CORP_VEYMED)
			return "Vey-Med — разработчик передовых медицинских технологий, оборудования и хирургических инструментов."
		if(RND_MISSION_CORP_HEPHAESTUS)
			return "Hephaestus Industries — специализируется на оружейных системах, боевых платформах и оборонных технологиях."
		if(RND_MISSION_CORP_MORPHEUS)
			return "Morpheus Cybernetics — разработка позитронных мозгов, синтетических тел и систем искусственного интеллекта."
		if(RND_MISSION_CORP_SHELLGUARD)
			return "Shellguard — военная корпорация, специализирующаяся на тактическом оборудовании и боевых экзоскелетах."
		if(RND_MISSION_CORP_ZENG_HU)
			return "Zeng Hu Pharmaceuticals — один из крупнейших производителей лекарств, реагентов и медицинского оборудования."
		if(RND_MISSION_CORP_ALMALIKI)
			return "Al-Maliki & Mosley — производитель вооружений, систем безопасности и защитной экипировки."
		if(RND_MISSION_CORP_BISHOP)
			return "Bishop Cybernetics — лидер в области кибернетических имплантов, аугментаций и протезирования."
		if(RND_MISSION_CORP_HELTEK)
			return "HelTek Arms — производитель высокоточного стрелкового оружия, штурмовых винтовок и рельсотронных систем."
		if(RND_MISSION_CORP_FTU)
			return "Free Trade Union — торговый союз, поставляющий разнообразное вооружение от независимых производителей со всей галактики."
	return "Информация о корпорации недоступна."



/obj/machinery/computer/modular/preset/cardslot/science
	uncreated_component_parts = list(
		/obj/item/stock_parts/power/apc,
		/obj/item/stock_parts/computer/card_slot
		)
	default_software = list(
		/datum/computer_file/program/camera_monitor,
		/datum/computer_file/program/records,
		/datum/computer_file/program/email_client,
		/datum/computer_file/program/supply,
		/datum/computer_file/program/wordprocessor,
		/datum/computer_file/program/rnd_console,
		/datum/computer_file/program/ntnetdesign
	)

#undef SCREEN_MAIN
#undef SCREEN_PROTO
#undef SCREEN_IMPRINTER
#undef SCREEN_WORKING
#undef SCREEN_TREES
#undef SCREEN_LOCKED
#undef SCREEN_DISK_DESIGNS
#undef SCREEN_DISK_TECH
#undef SCREEN_MISSIONS
#undef SCREEN_CORPS
