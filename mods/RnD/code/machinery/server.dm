/obj/machinery/r_n_d/server
	name = "\improper R&D server"
	icon = 'icons/obj/machines/research/server.dmi'
	icon_state = "server"
	base_type = /obj/machinery/r_n_d/server
	construct_state = /singleton/machine_construction/default/panel_closed
	machine_name = "\improper R&D server"
	machine_desc = "A powerful piece of hardware used as the hub of a research matrix, containing every byte of data gleaned from an experiment."
	var/datum/research/files
	/// Associative list: category string => /obj/item/stock_parts/computer/hard_drive
	var/list/rnd_drives = list()
	var/health = 100
	/// Cooldown ticks before another forget_random_technology call after health bottoms out.
	var/health_punish_cooldown = 0
	var/list/id_with_upload = list()	//List of R&D consoles with upload to server access.
	var/list/id_with_download = list()	//List of R&D consoles with download from server access.
	var/id_with_upload_string = ""		//String versions for easy editing in map editor.
	var/id_with_download_string = ""
	var/server_id = 0
	/// If TRUE this server acts as the public design repository for NTNet Download Design.
	/// Only one server should have this flag set at a time.
	/// Can be toggled via R&D Server Control console → server list.
	var/is_public_server = FALSE
	var/produces_heat = 1
	idle_power_usage = 800
	var/delay = 10
	req_access = list()


/obj/machinery/r_n_d/server/Destroy()
	SSresearch.rnd_server_list -= src
	for(var/cat in rnd_drives)
		var/obj/item/stock_parts/computer/hard_drive/HDD = rnd_drives[cat]
		if(!QDELETED(HDD))
			HDD.forceMove(get_turf(src))
	rnd_drives.Cut()
	QDEL_NULL(files)
	return ..()


/obj/machinery/r_n_d/server/Initialize(mapload)
	. = ..()
	SSresearch.rnd_server_list += src

	if(!files)
		files = new /datum/research(src)

	// Create HDDs only on initial map load (pre-placed servers).
	// Player-built servers start empty — they reinsert HDDs manually.
	if(mapload)
		_populate_rnd_drives()

	// Now set physical_server so AddDesign2Known writes to HDD going forward
	files.physical_server = src

	// Migrate designs that landed in known_designs during New() (before physical_server was set)
	for(var/datum/design/D in files.known_designs)
		files.AddDesign2Known(D)
	files.known_designs.Cut()

	// Rebuild category cache from HDD files (needed when server is rebuilt with existing disks)
	_rebuild_design_categories()

	var/list/temp_list
	if(!length(id_with_upload))
		temp_list = list()
		temp_list = splittext(id_with_upload_string, ";")
		for(var/N in temp_list)
			id_with_upload += text2num(N)
	if(!length(id_with_download))
		temp_list = list()
		temp_list = splittext(id_with_download_string, ";")
		for(var/N in temp_list)
			id_with_download += text2num(N)
	update_icon()


/// Creates one super HDD per consolidated design category and registers them in rnd_drives.
/// Does NOT create a System disk — only /server/core overrides this to add one.
/// Called on mapload for pre-placed servers. Player-built servers start empty.
/obj/machinery/r_n_d/server/proc/_populate_rnd_drives()
	var/list/cats = list()
	for(var/datum/design/D in SSresearch.all_designs)
		if(!D.category)
			continue
		for(var/cat in D.category)
			cats |= get_hdd_category(cat)
	if(!length(cats))
		cats += "General"
	for(var/cat in cats)
		var/obj/item/stock_parts/computer/hard_drive/super/HDD = new(src)
		HDD.rnd_category = cat
		HDD.name = "[cat] R&D Drive"
		rnd_drives[cat] = HDD

/// Rebuilds design_categories_protolathe/imprinter cache from actual HDD file contents.
/// Call after inserting a disk into a server whose files datum was freshly created.
/obj/machinery/r_n_d/server/proc/_rebuild_design_categories()
	files.design_categories_protolathe = list()
	files.design_categories_imprinter = list()
	for(var/datum/computer_file/binary/design/F in get_all_hdd_files())
		var/datum/design/D = F.design
		if(!D || !D.category)
			continue
		for(var/cat in D.category)
			if(D.build_type & PROTOLATHE)
				files.design_categories_protolathe |= cat
			else if(D.build_type & IMPRINTER)
				files.design_categories_imprinter |= cat

/// Returns a flat list of all design files across all installed HDDs (including uncategorized).
/obj/machinery/r_n_d/server/proc/get_all_hdd_files()
	var/list/result = list()
	var/list/registered = list()
	for(var/cat in rnd_drives)
		var/obj/item/stock_parts/computer/hard_drive/HDD = rnd_drives[cat]
		registered += HDD
		for(var/datum/computer_file/binary/design/F in HDD.stored_files)
			result += F
	for(var/obj/item/stock_parts/computer/hard_drive/HDD in src)
		if(HDD in registered)
			continue
		for(var/datum/computer_file/binary/design/F in HDD.stored_files)
			result += F
	return result

/obj/machinery/r_n_d/server/operable()
	return !inoperable(MACHINE_STAT_EMPED)


/obj/machinery/r_n_d/server/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(isMultitool(I) && !panel_open)
		to_chat(user, SPAN_NOTICE("\The [src]: текущий сетевой ID — [server_id ? server_id : "не задан (0)"]."))
		var/new_id = input(user, "Введите новый числовой ID сервера (1–99). Текущий: [server_id]", "Сетевой ID сервера", server_id) as num|null
		if(!isnull(new_id))
			new_id = round(clamp(new_id, 0, 99))
			server_id = new_id
			to_chat(user, SPAN_NOTICE("\The [src]: сетевой ID установлен как [server_id]."))
		return TRUE
	// Insert an RnD HDD when panel is open
	if(panel_open && istype(I, /obj/item/stock_parts/computer/hard_drive))
		if(!user.unEquip(I, src))
			return TRUE
		if(files)
			_rebuild_design_categories()
		// Auto-detect system drive by state file presence
		var/obj/item/stock_parts/computer/hard_drive/HDD = I
		if(!rnd_drives["System"])
			for(var/datum/computer_file/data/rnd_state/state_file in HDD.stored_files)
				HDD.rnd_category = "System"
				HDD.name = "System R&D Drive"
				rnd_drives["System"] = HDD
				load_rnd_state()
				to_chat(user, SPAN_NOTICE("Системный диск установлен. Данные сервера восстановлены."))
				update_icon()
				return TRUE
		to_chat(user, SPAN_NOTICE("Установлен [I.name]. Назначьте категорию через интерфейс сервера."))
		update_icon()
		return TRUE
	return ..()

/obj/machinery/r_n_d/server/attack_hand(mob/user)
	return interface_interact(user)

/obj/machinery/r_n_d/server/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/r_n_d/server/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = list()
	data["server_id"]  = server_id
	data["health"]     = health
	data["operable"]   = operable()
	data["panel_open"] = panel_open

	var/list/hdd_list = list()
	var/list/registered_hdds = list()
	// Зарегистрированные диски (есть в rnd_drives)
	for(var/cat in rnd_drives)
		var/obj/item/stock_parts/computer/hard_drive/HDD = rnd_drives[cat]
		registered_hdds += HDD
		hdd_list += list(list(
			"ref"  = "\ref[HDD]",
			"name" = HDD.name,
			"category" = cat,
			"desc" = get_hdd_description(cat),
			"used" = HDD.used_capacity,
			"max"  = HDD.max_capacity,
			"pct"  = round(HDD.used_capacity / max(1, HDD.max_capacity) * 100)
		))
	// Диски физически в сервере, но не зарегистрированные в rnd_drives
	for(var/obj/item/stock_parts/computer/hard_drive/HDD in src)
		if(HDD in registered_hdds)
			continue
		hdd_list += list(list(
			"ref"      = "\ref[HDD]",
			"name"     = HDD.name,
			"category" = "—",
			"desc"     = "",
			"used"     = HDD.used_capacity,
			"max"      = HDD.max_capacity,
			"pct"      = round(HDD.used_capacity / max(1, HDD.max_capacity) * 100)
		))
	data["hdds"] = hdd_list

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-rdserver_panel.tmpl", "[src.name]", 500, 420)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/r_n_d/server/OnTopic(mob/user, list/href_list, datum/topic_state/state)
	if(href_list["eject"])
		if(!panel_open)
			return TOPIC_NOACTION
		var/obj/item/stock_parts/computer/hard_drive/HDD = locate(href_list["eject"]) in src
		if(HDD && !QDELETED(HDD))
			save_rnd_state()
			var/old_name = HDD.name
			rnd_drives -= HDD.rnd_category
			HDD.forceMove(get_turf(src))
			user.put_in_hands(HDD)
			to_chat(user, SPAN_NOTICE("Диск [old_name] извлечён."))
			update_icon()
		return TOPIC_REFRESH

	if(href_list["assign_cat"])
		if(!panel_open)
			return TOPIC_NOACTION
		var/obj/item/stock_parts/computer/hard_drive/HDD = locate(href_list["assign_cat"]) in src
		if(!HDD || QDELETED(HDD))
			return TOPIC_REFRESH
		var/list/cats = list("System")
		for(var/datum/design/D in SSresearch.all_designs)
			if(!D.category) continue
			for(var/c in D.category)
				cats |= get_hdd_category(c)
		for(var/c in rnd_drives)
			if(rnd_drives[c] != HDD)
				cats -= c
		if(!length(cats))
			to_chat(user, SPAN_WARNING("Нет свободных категорий."))
			return TOPIC_REFRESH
		var/old_cat = HDD.rnd_category
		var/choice = input(user, "Выберите категорию для диска:", "Назначение категории") as null|anything in cats
		if(!choice || QDELETED(src) || QDELETED(HDD))
			return TOPIC_REFRESH
		if(old_cat)
			rnd_drives -= old_cat
		HDD.rnd_category = choice
		HDD.name = "[choice] R&D Drive"
		rnd_drives[choice] = HDD
		to_chat(user, SPAN_NOTICE("Диск назначен категории \"[choice]\"."))
		if(choice == "System")
			load_rnd_state()
		return TOPIC_REFRESH

	if(href_list["load_rnd"])
		load_rnd_state()
		to_chat(user, SPAN_NOTICE("Данные с системного диска загружены на сервер."))
		return TOPIC_REFRESH

/obj/machinery/r_n_d/server/Exited(atom/movable/AM, direction)
	. = ..()
	if(istype(AM, /obj/item/stock_parts/computer/hard_drive))
		var/obj/item/stock_parts/computer/hard_drive/HDD = AM
		if(HDD.rnd_category && (HDD.rnd_category in rnd_drives))
			rnd_drives -= HDD.rnd_category
		HDD.rnd_category = null
		HDD.name = initial(HDD.name)

/// Returns a flat list of all /datum/design available across all installed RnD HDDs.
/obj/machinery/r_n_d/server/proc/get_all_designs()
	var/list/result = list()
	for(var/cat in rnd_drives)
		var/obj/item/stock_parts/computer/hard_drive/HDD = rnd_drives[cat]
		for(var/datum/computer_file/binary/design/F in HDD.stored_files)
			if(F.design)
				result |= F.design
	return result

/// Maps a raw design category to one of 5 consolidated HDD categories.
/// Autolathe / Medical / Exosuit / Electronics / Research
/obj/machinery/r_n_d/server/proc/get_hdd_category(cat)
	switch(cat)
		// ── Exosuit ──────────────────────────────────────────────────────────
		if("Mech Equipment", "Mech armour", "Mech cockpit", \
		   "Mech left arm", "Mech left leg", "Mech main", \
		   "Mech right arm", "Mech right leg", "Mech sensors", \
		   "Doubled legs", "Exosuit Equipment", "Exosuit", "Hardsuits")
			return "Exosuit"
		// ── Electronics ──────────────────────────────────────────────────────
		if("AI Module", "Computer Parts", \
		   "Robot", "Robot Upgrade", "Cyborg Upgrade Modules")
			return "Electronics"
		// ── Medical ──────────────────────────────────────────────────────────
		if("Medical", "Augments", "Optical")
			return "Medical"
		// ── Autolathe ────────────────────────────────────────────────────────
		if("Arms and Ammunition", "Drinking Glasses", "General", \
		   "Devices and Components", "Cutlery", "Food", \
		   "Tools", "Engineering")
			return "Autolathe"
		// ── Research (всё остальное: Weapon, Misc, RE) ────────────────────────
	return "Research"

/// Returns the list of original design categories stored on this consolidated HDD.
/obj/machinery/r_n_d/server/proc/get_hdd_description(cat)
	switch(cat)
		if("Autolathe")
			return "Arms and Ammunition, Drinking Glasses, General, Devices and Components, Cutlery, Food, Tools, Engineering"
		if("Medical")
			return "Medical, Augments, Optical"
		if("Exosuit")
			return "Exosuit, Exosuit Equipment, Hardsuits, Mech armour, Mech cockpit, Mech main, Mech left/right arm, Mech left/right leg, Mech sensors, Doubled legs"
		if("Electronics")
			return "Computer Parts, AI Module, Robot, Robot Upgrade, Cyborg Upgrade Modules"
		if("Research")
			return "Weapon, Misc, Reverse Engineered"
		if("System")
			return "Корневой раздел матрицы. Журнал исследований, сертификаты разработок, корпоративные соглашения"
	return ""



/obj/machinery/r_n_d/server/on_update_icon()
	ClearOverlays()
	if (operable())
		AddOverlays(list(
			"server_on",
			"server_lights_on",
			emissive_appearance(icon, "server_lights_on"),
		))
	else
		AddOverlays(list(
			"server_lights_off",
			emissive_appearance(icon, "server_lights_off")
		))
	if (panel_open)
		AddOverlays("server_panel")


/obj/machinery/r_n_d/server/RefreshParts()
	var/tot_rating = 0
	for(var/obj/item/stock_parts/SP in src)
		tot_rating += SP.rating
	change_power_consumption(initial(idle_power_usage)/max(1, tot_rating), POWER_USE_IDLE)


/obj/machinery/r_n_d/server/Process()
	..()
	var/datum/gas_mixture/environment = loc.return_air()
	var/temp = environment.temperature
	var/old_health = health
	if(temp >= (T0C + 70))
		health = max(0, health - 2)
	else if(temp >= (T20C + 20))
		health = max(0, health - 1)
	if(health <= 0)
		if(health_punish_cooldown <= 0)
			files.forget_random_technology()
			health = 30
			health_punish_cooldown = 30
		else
			health_punish_cooldown--
	else
		health_punish_cooldown = 0

	if(delay)
		delay--
	else
		produce_heat()
		delay = initial(delay)
	// Обновляем иконку только если здоровье изменилось
	if(health != old_health)
		update_icon()

/obj/machinery/r_n_d/server/proc/produce_heat()
	if(!produces_heat)
		return

	if(!use_power)
		return

	if(operable()) //Blatently stolen from telecoms
		var/turf/simulated/L = loc
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()

			var/transfer_moles = 0.25 * env.total_moles

			var/datum/gas_mixture/removed = env.remove(transfer_moles)

			if(removed)
				var/heat_produced = idle_power_usage	//obviously can't produce more heat than the machine draws from it's power source

				removed.add_thermal_energy(heat_produced)

			env.merge(removed)

/obj/machinery/r_n_d/server/centcom
	name = "central R&D database"
	server_id = -1

/obj/machinery/r_n_d/server/centcom/proc/update_connections()
	var/list/no_id_servers = list()
	var/list/server_ids = list()
	for(var/obj/machinery/r_n_d/server/S as anything in SSmachines.get_machinery_of_type(/obj/machinery/r_n_d/server))
		switch(S.server_id)
			if(-1)
				continue
			if(0)
				no_id_servers += S
			else
				server_ids += S.server_id

	for(var/obj/machinery/r_n_d/server/S in no_id_servers)
		var/num = 1
		while(!S.server_id)
			if(num in server_ids)
				num++
			else
				S.server_id = num
				server_ids += num
		no_id_servers -= S

/*
/obj/machinery/r_n_d/server/centcom/Process()
	return PROCESS_KILL //don't need process()
*/
/obj/machinery/computer/rdservercontrol
	name = "\improper R&D server controller"
	icon_keyboard = "rd_key"
	icon_screen = "rdcomp"
	light_color = "#a97faa"
	machine_name = "\improper R&D server control console"
	machine_desc = "If an R&D server is the heart of a research setup, this is the brain. Any kind of data manipulation on the server happens from this console."
	req_access = list(access_heads)
	var/screen = 0
	var/obj/machinery/r_n_d/server/temp_server
	var/list/servers = list()
	var/list/consoles = list()
	var/badmin = 0
	var/obj/item/disk/design_disk/loaded_disk = null
	var/selected_data_category = null // For filtering technologies by category
	var/design_search_text = null // For searching designs on screen 4
	var/selected_design_category = null // For filtering designs by category on screen 4

/obj/machinery/computer/rdservercontrol/CanUseTopic(user)
	if(!allowed(user) && !emagged)
		to_chat(user, SPAN_WARNING("You do not have the required access level"))
		return STATUS_CLOSE
	return ..()

/obj/machinery/computer/rdservercontrol/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(istype(I, /obj/item/disk/design_disk))
		if(loaded_disk)
			to_chat(user, SPAN_WARNING("A disk is already inserted."))
			return
		if(!user.unEquip(I))
			return
		I.forceMove(src)
		loaded_disk = I
		to_chat(user, SPAN_NOTICE("You insert \the [I] into \the [src]."))
		SSnano.update_uis(src)
		return

	return 	. = ..()

/obj/machinery/computer/rdservercontrol/OnTopic(user, href_list, state)
	if(href_list["go_screen"])
		screen = text2num(href_list["go_screen"])
		selected_data_category = null
		selected_design_category = null
		design_search_text = null
		. = TOPIC_REFRESH

	else if(href_list["select_server"])
		temp_server = null
		consoles = list()
		servers = list()
		// Locate by direct ref if provided (reliable, no server_id collisions)
		if(href_list["server_ref"])
			temp_server = locate(href_list["server_ref"])
			if(!istype(temp_server, /obj/machinery/r_n_d/server))
				temp_server = null
		// Fallback: search by server_id with z-level filter
		if(!temp_server)
			var/target_id = text2num(href_list["select_server"])
			var/turf/ctrl_turf = get_turf(src)
			for(var/obj/machinery/r_n_d/server/S as anything in SSmachines.get_machinery_of_type(/obj/machinery/r_n_d/server))
				var/turf/ST = get_turf(S)
				if(istype(S, /obj/machinery/r_n_d/server/centcom) && !badmin)
					continue
				if(ST && !AreConnectedZLevels(ST.z, ctrl_turf.z))
					continue
				if(S.server_id == target_id)
					temp_server = S
					break
		if(temp_server)
			var/target_screen = text2num(href_list["target_screen"])
			screen = target_screen
			selected_data_category = null
			if(target_screen == 1)
				for(var/obj/machinery/computer/rdconsole/C as anything in SSmachines.get_machinery_of_type(/obj/machinery/computer/rdconsole))
					if(C.get_server())
						consoles += C
			else if(target_screen == 3)
				for(var/obj/machinery/r_n_d/server/S as anything in SSmachines.get_machinery_of_type(/obj/machinery/r_n_d/server))
					if(S != temp_server)
						servers += S
		. = TOPIC_REFRESH

	else if(href_list["upload_toggle"])
		var/num = text2num(href_list["upload_toggle"])
		if(num in temp_server.id_with_upload)
			temp_server.id_with_upload -= num
		else
			temp_server.id_with_upload += num
		. = TOPIC_REFRESH

	else if(href_list["download_toggle"])
		var/num = text2num(href_list["download_toggle"])
		if(num in temp_server.id_with_download)
			temp_server.id_with_download -= num
		else
			temp_server.id_with_download += num
		. = TOPIC_REFRESH

//[SIERRA-EDIT] - MODPACK_RND
	else if(href_list["reset_tech"])
		var/choice = alert("Are you sure you want to reset this technology to its default data? Data lost cannot be recovered.", "Technology Data Reset", "Continue", "Cancel")
		if(choice == "Continue")
			temp_server.files.forget_all(href_list["reset_tech"])
		. = TOPIC_REFRESH

	else if(href_list["reset_technology"])
		var/choice = alert("Are you sure you want to delete this design? Data lost cannot be recovered.", "Techology Deletion", "Continue", "Cancel")
		var/techology = temp_server.files.researched_tech[href_list["reset_technology"]]
		if(choice == "Continue" && techology)
			temp_server.files.forget_techology(techology)
		. = TOPIC_REFRESH

	else if(href_list["select_data_category"])
		selected_data_category = href_list["select_data_category"]
		if(selected_data_category == "__all__")
			selected_data_category = null
		. = TOPIC_REFRESH

	else if(href_list["toggle_ban_design"])
		if(temp_server)
			var/datum/design/D = locate(href_list["toggle_ban_design"]) in temp_server.get_all_designs()
			if(D)
				var/design_id = "[D.id]"
				if(design_id in temp_server.files.banned_designs)
					temp_server.files.banned_designs -= design_id
				else
					temp_server.files.banned_designs += design_id
		. = TOPIC_REFRESH

	else if(href_list["download_design_to_disk"])
		if(!temp_server)
			return
		if(!loaded_disk)
			to_chat(user, SPAN_WARNING("Вставьте диск дизайнов."))
			. = TOPIC_REFRESH
			return
		if(loaded_disk.blueprint)
			to_chat(user, SPAN_WARNING("На диске уже есть дизайн. Извлеките диск или очистите его."))
			. = TOPIC_REFRESH
			return
		var/datum/design/D = locate(href_list["download_design_to_disk"]) in temp_server.get_all_designs()
		if(D)
			loaded_disk.blueprint = D
			to_chat(user, SPAN_NOTICE("Дизайн \"[D.name]\" записан на диск."))
		. = TOPIC_REFRESH

	else if(href_list["eject_disk"])
		if(loaded_disk)
			loaded_disk.forceMove(get_turf(src))
			to_chat(user, SPAN_NOTICE("Диск извлечён."))
			loaded_disk = null
		. = TOPIC_REFRESH

	else if(href_list["clear_disk"])
		if(loaded_disk && loaded_disk.blueprint)
			loaded_disk.blueprint = null
			to_chat(user, SPAN_NOTICE("Данные на диске очищены."))
		. = TOPIC_REFRESH

	else if(href_list["design_search"])
		var/input = sanitizeSafe(input(user, "Введите текст для поиска", "Поиск дизайна") as null|text, MAX_LNAME_LEN)
		design_search_text = input
		. = TOPIC_REFRESH

	else if(href_list["clear_design_search"])
		design_search_text = null
		. = TOPIC_REFRESH

	else if(href_list["select_design_category"])
		selected_design_category = href_list["select_design_category"]
		if(selected_design_category == "__all__")
			selected_design_category = null
		. = TOPIC_REFRESH

	else if(href_list["publish_design"])
		if(temp_server)
			var/datum/design/D = locate(href_list["publish_design"]) in temp_server.get_all_designs()
			if(D)
				var/turf/ctrl_turf = get_turf(src)
				for(var/obj/machinery/r_n_d/server/PS as anything in SSmachines.get_machinery_of_type(/obj/machinery/r_n_d/server))
					if(!PS.is_public_server)
						continue
					var/turf/ps_turf = get_turf(PS)
					if(ps_turf && AreConnectedZLevels(ps_turf.z, ctrl_turf.z) && PS.operable())
						PS.files.AddDesign2Known(D)
						to_chat(user, SPAN_NOTICE("Дизайн \"[D.name]\" опубликован на публичном сервере."))
						break
		. = TOPIC_REFRESH

	else if(href_list["delete_design"])
		if(temp_server)
			var/datum/design/D = locate(href_list["delete_design"]) in temp_server.get_all_designs()
			if(D)
				temp_server.files._remove_design_from_drives(D.id)
				to_chat(user, SPAN_NOTICE("Дизайн \"[D.name]\" удалён с сервера [temp_server.name]."))
		. = TOPIC_REFRESH

	else if(href_list["copy_design_choose"])
		if(temp_server)
			var/datum/design/D = locate(href_list["copy_design_choose"]) in temp_server.get_all_designs()
			if(D)
				var/turf/ctrl_turf = get_turf(src)
				var/list/available = list()
				for(var/obj/machinery/r_n_d/server/S as anything in SSmachines.get_machinery_of_type(/obj/machinery/r_n_d/server))
					if(S == temp_server)
						continue
					var/turf/s_turf = get_turf(S)
					if(!s_turf || !AreConnectedZLevels(s_turf.z, ctrl_turf.z))
						continue
					available[S.name] = S
				if(length(available))
					var/choice = input(user, "Выберите целевой сервер", "Копировать дизайн") as null|anything in available
					if(choice)
						var/obj/machinery/r_n_d/server/target = available[choice]
						target.files.AddDesign2Known(D)
						to_chat(user, SPAN_NOTICE("Дизайн \"[D.name]\" скопирован на [target.name]."))
				else
					to_chat(user, SPAN_WARNING("Нет доступных серверов для копирования."))
		. = TOPIC_REFRESH

	else if(href_list["send_to"])
		var/target_id = text2num(href_list["send_to"])
		var/turf/send_ctrl_turf = get_turf(src)
		for(var/obj/machinery/r_n_d/server/S as anything in SSmachines.get_machinery_of_type(/obj/machinery/r_n_d/server))
			var/turf/s_turf = get_turf(S)
			if(s_turf && !AreConnectedZLevels(s_turf.z, send_ctrl_turf.z))
				continue
			if(S.server_id == target_id && temp_server)
				S.files.download_from(temp_server.files)
				break
		. = TOPIC_REFRESH

	else if(href_list["set_public_server"])
		var/target_id = text2num(href_list["set_public_server"])
		var/turf/ctrl_turf = get_turf(src)
		for(var/obj/machinery/r_n_d/server/S as anything in SSmachines.get_machinery_of_type(/obj/machinery/r_n_d/server))
			var/turf/s_turf = get_turf(S)
			if(!s_turf || !AreConnectedZLevels(s_turf.z, ctrl_turf.z))
				continue
			var/was_public = S.is_public_server
			S.is_public_server = (S.server_id == target_id)
			if(!was_public && S.is_public_server)
				to_chat(user, SPAN_NOTICE("[S.name] назначен публичным сервером дизайнов."))
		. = TOPIC_REFRESH

/obj/machinery/computer/rdservercontrol/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/computer/rdservercontrol/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	// If the selected server was deconstructed, drop the reference and return to main screen.
	if(temp_server && (QDELETED(temp_server) || !temp_server.files))
		temp_server = null
		screen = 0

	var/list/data = list()
	data["screen"] = screen
	data["badmin"] = badmin
	data["has_disk"] = !!loaded_disk
	data["server_name"] = temp_server ? temp_server.name : ""
	if(loaded_disk)
		data["disk_has_blueprint"] = !!loaded_disk.blueprint
		data["disk_blueprint_name"] = loaded_disk.blueprint ? loaded_disk.blueprint.name : null

	switch(screen)
		if(0) // Main Menu
			var/list/server_list = list()
			var/turf/T = get_turf(src)
			for(var/obj/machinery/r_n_d/server/S as anything in SSmachines.get_machinery_of_type(/obj/machinery/r_n_d/server))
				var/turf/ST = get_turf(S)
				if((istype(S, /obj/machinery/r_n_d/server/centcom) && !badmin) || (ST && !AreConnectedZLevels(ST.z, T.z)))
					continue
				var/total_used = 0
				var/total_max = 0
				for(var/cat in S.rnd_drives)
					var/obj/item/stock_parts/computer/hard_drive/HDD = S.rnd_drives[cat]
					total_used += HDD.used_capacity
					total_max  += HDD.max_capacity
				server_list += list(list(
					"name"        = S.name,
					"id"          = S.server_id,
					"ref"         = "\ref[S]",
					"operable"    = S.operable(),
					"is_public"   = S.is_public_server,
					"health"      = S.health,
					"hdd_used"    = total_used,
					"hdd_max"     = total_max,
					"hdd_drives"  = length(S.rnd_drives)
				))
			data["servers"] = server_list

		if(1) // Access Rights
			if(temp_server)
				data["server_name"] = temp_server.name
				var/list/console_list = list()
				for(var/obj/machinery/computer/rdconsole/C in consoles)
					var/turf/console_turf = get_turf(C)
					console_list += list(list(
						"name" = "[console_turf.loc]",
						"id" = C.id,
						"has_upload" = (C.id in temp_server.id_with_upload),
						"has_download" = (C.id in temp_server.id_with_download)
					))
				data["consoles"] = console_list

		if(2) // Data Management
			if(temp_server)
				data["server_name"] = temp_server.name
				data["selected_data_category"] = selected_data_category

				var/list/tech_list = list()
				for(var/datum/tech/T in temp_server.files.researched_tech)
					tech_list += list(list(
						"name" = T.name,
						"level" = T.level,
						"ref" = "\ref[T]"
					))
				data["tech_trees"] = tech_list

				// Pre-build node_id -> category_id map
				var/list/node_category_map = list()
				for(var/cat_id in rnd_tech_categories)
					var/list/cat_data = rnd_tech_categories[cat_id]
					var/list/trees = cat_data["trees"]
					if(trees)
						for(var/corp_id in trees)
							var/list/tree = trees[corp_id]
							if(tree && tree["nodes"])
								for(var/node_id in tree["nodes"])
									node_category_map[node_id] = cat_id

				// Build category list and grouped technologies
				var/list/categories_list = list()
				for(var/cat_id in rnd_tech_categories)
					var/list/cat_data = rnd_tech_categories[cat_id]
					categories_list += list(list("id" = cat_id, "name" = cat_data["name"]))

				var/list/categorized_techs = list()
				// Group by category using the pre-built map
				var/list/cat_buckets = list()
				for(var/t in temp_server.files.researched_nodes)
					var/datum/technology/T = t
					var/cat_id = node_category_map[T.id]
					if(!cat_id)
						cat_id = "__other__"
					if(selected_data_category && selected_data_category != cat_id)
						continue
					if(!cat_buckets[cat_id])
						cat_buckets[cat_id] = list()
					var/list/bucket = cat_buckets[cat_id]
					bucket += list(list(
						"name" = T.name,
						"id" = T.id,
						"ref" = "\ref[T]"
					))

				for(var/cat_id in rnd_tech_categories)
					if(!cat_buckets[cat_id] || !LAZYLEN(cat_buckets[cat_id]))
						continue
					var/list/cat_data = rnd_tech_categories[cat_id]
					categorized_techs += list(list(
						"category_id" = cat_id,
						"category_name" = cat_data["name"],
						"nodes" = cat_buckets[cat_id]
					))

				data["categories"] = categories_list
				data["categorized_technologies"] = categorized_techs

		if(3) // Server Transfer
			if(temp_server)
				data["server_name"] = temp_server.name
				var/list/transfer_list = list()
				for(var/obj/machinery/r_n_d/server/S in servers)
					transfer_list += list(list(
						"name" = S.name,
						"id" = S.server_id
					))
				data["transfer_servers"] = transfer_list

		if(4) // Design Management
			if(temp_server)
				data["server_name"] = temp_server.name
				data["is_public_server"] = temp_server.is_public_server
				data["has_public_server"] = FALSE
				var/turf/ctrl_turf = get_turf(src)
				for(var/obj/machinery/r_n_d/server/PS as anything in SSmachines.get_machinery_of_type(/obj/machinery/r_n_d/server))
					if(!PS.is_public_server)
						continue
					var/turf/ps_turf = get_turf(PS)
					if(ps_turf && AreConnectedZLevels(ps_turf.z, ctrl_turf.z) && PS.operable())
						data["has_public_server"] = TRUE
						break
				data["design_search"] = design_search_text
				data["selected_design_category"] = selected_design_category

				// Always collect category list (lightweight pass, no ref building)
				var/list/all_categories = list()
				for(var/datum/design/D in temp_server.get_all_designs())
					if(D.category)
						for(var/cat in D.category)
							all_categories |= cat
					else
						all_categories |= "Unspecified"

				var/list/cat_filter = list()
				for(var/cat in all_categories)
					cat_filter += list(list("id" = cat, "name" = cat))
				data["design_categories"] = cat_filter

				// Only build design list when a category or search filter is active
				// (sending all designs at once causes "Invalid string length" in NanoUI)
				if(selected_design_category || design_search_text)
					var/list/categorized_designs = list()
					for(var/datum/design/D in temp_server.get_all_designs())
						if(design_search_text && !findtext(D.name, design_search_text))
							continue
						// Collect the categories this design belongs to
						var/list/design_cats = D.category ? D.category : list("Unspecified")
						// Filter by selected category
						if(selected_design_category && !(selected_design_category in design_cats))
							continue
						// Add to each matching category bucket
						for(var/cat_name in design_cats)
							if(selected_design_category && selected_design_category != cat_name)
								continue
							if(!categorized_designs[cat_name])
								categorized_designs[cat_name] = list()
							var/list/cat_list = categorized_designs[cat_name]
							cat_list += list(list(
								"name" = D.name,
								"id" = D.id,
								"ref" = "\ref[D]",
								"banned" = ("[D.id]" in temp_server.files.banned_designs),
								"starts_unlocked" = D.starts_unlocked
							))
					var/list/grouped = list()
					for(var/cat_name in categorized_designs)
						grouped += list(list(
							"category_name" = cat_name,
							"designs" = categorized_designs[cat_name]
						))
					data["design_groups"] = grouped
				else
					data["design_groups"] = list()
					data["require_filter"] = 1

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "rdservercontrol.tmpl", "R&D Server Control", 1300, 800)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/rdservercontrol/emag_act(remaining_charges, mob/user)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = TRUE
		req_access.Cut()
		to_chat(user, SPAN_NOTICE("You disable the security protocols."))
		src.updateUsrDialog()
		return 1

/obj/machinery/r_n_d/server/robotics
	name = "robotics R&D server"
	id_with_upload_string = "1;2;3"
	id_with_download_string = "1;2;3"
	server_id = 2

/obj/machinery/r_n_d/server/core
	name = "core R&D server"
	id_with_upload_string = "1;3"
	id_with_download_string = "1;3"
	server_id = 1

/obj/machinery/r_n_d/server/core/_populate_rnd_drives()
	..()
	var/obj/item/stock_parts/computer/hard_drive/super/sys_hdd = new(src)
	sys_hdd.rnd_category = "System"
	sys_hdd.name = "System R&D Drive"
	rnd_drives["System"] = sys_hdd

// Sierra variant: starts with all Nanotrasen technologies pre-researched.
// Used on the NanoTrasen vessel SSV Sierra.
/obj/machinery/r_n_d/server/core/sierra

/obj/machinery/r_n_d/server/core/sierra/Initialize()
	. = ..()
	files.SetCorporationReputation(RND_MISSION_CORP_NANOTRASEN, 50)
	for(var/datum/technology/T in SSresearch.all_tech_nodes)
		if(T.required_corp_id == RND_MISSION_CORP_NANOTRASEN)
			files.UnlockTechology(T, force = TRUE)

// ─── Public Design Server ──────────────────────────────────────────────────
// Stores designs that have been published for NTNet-wide distribution.
// NTNet Download Design program reads from any server with is_public_server = TRUE.
// Designs are pushed here via R&D Server Control (screen 4 → "→ Public" button).
// Role can be reassigned to any server via R&D Server Control → server list.
/obj/machinery/r_n_d/server/public
	name = "public design server"
	server_id = 3
	is_public_server = TRUE

/obj/machinery/r_n_d/server/public/_populate_rnd_drives()
	var/obj/item/stock_parts/computer/hard_drive/super/HDD = new(src)
	HDD.rnd_category = "Autolathe"
	HDD.name = "Autolathe R&D Drive"
	rnd_drives["Autolathe"] = HDD
