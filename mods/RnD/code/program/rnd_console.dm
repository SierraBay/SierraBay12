/*
R&D Console - Downloadable Program
===================================
A modular computer program that provides full R&D console functionality.

Architecture:
datum/computer_file/program/rnd_console - the downloadable program file
datum/nano_module/program/rnd_console   - owns all state and logic directly; no proxy obj is created.

PROGRAM_CONSOLE - full interface: analyzer, protolathe, imprinter, trees, missions, corporations, disk management.
PROGRAM_LAPTOP  - lite mode: designs/disk/corporations/trees only (read-only tech tree, no fabricator/analyzer screens).

The nano_module datum itself is assigned as linked_console on nearby devices
(destructive_analyzer, protolathe, imprinter). BYOND's duck-typed proc calls
mean this works transparently - the datum implements every proc/var that
those devices access via linked_console.
*/

// ═══════════════════════════════════════════════════════════════════════════
// Program file
// ═══════════════════════════════════════════════════════════════════════════

/datum/computer_file/program/rnd_console
	filename      = "rndconsole"
	filedesc      = "R&D Console"
	extended_desc = "Research and development management software. Provides server access, technology trees, corporate networks, and fabricator control."
	nanomodule_path = /datum/nano_module/program/rnd_console
	usage_flags   = PROGRAM_CONSOLE | PROGRAM_LAPTOP
	required_access = access_rnd_network
	program_icon_state = "research"
	program_key_state = "tech_key"

	category      = PROG_ENG
	size          = 12
	/// Saved billing account number — persists while the program file stays on the HDD.
	var/saved_account_number = 0
	var/saved_account_key    = null
	/// Default department account key — used if no personal account is linked.
	/// Set on subtypes to pre-configure a console for a specific department.
	var/default_account_key  = null

/datum/computer_file/program/rnd_console/robotics_console
	filename      = "robofab_console"
	filedesc      = "Robotics Design Console"
	extended_desc = "Robotics fabrication management software. Provides access to robotics/mech design catalogs, syncing, and corporate unlock purchases."
	nanomodule_path = /datum/nano_module/program/rnd_console/robotics_console
	required_access = access_robotics
	program_icon_state = "research"
	program_key_state = "tech_key"
	size = 8

/datum/computer_file/program/rnd_console/biomech_console
	filename      = "augfab_console"
	filedesc      = "Augmentation Design Console"
	extended_desc = "Biomechanical fabrication management software. Provides access to augments design catalogs, syncing, and corporate unlock purchases."
	nanomodule_path = /datum/nano_module/program/rnd_console/robotics_console/biomech
	required_access = access_biomech
	program_icon_state = "research"
	program_key_state = "tech_key"
	size = 8

/datum/computer_file/program/rnd_console/public_console
	filename      = "pubdes_console"
	filedesc      = "Common Design Console"
	extended_desc = "Public design repository access. Provides public network access to published design files."
	nanomodule_path = /datum/nano_module/program/rnd_console/robotics_console/public
	required_access = null
	program_icon_state = "research"
	program_key_state = "tech_key"
	size = 8

// ═══════════════════════════════════════════════════════════════════════════
// Screen constants (mirrors rdconsole.dm — redefined here because that file
// #undef's them at its end)
// ═══════════════════════════════════════════════════════════════════════════

#define RND_SCREEN_MAIN          "main"
#define RND_SCREEN_PROTO         "protolathe"
#define RND_SCREEN_IMPRINTER     "circuit_imprinter"
#define RND_SCREEN_WORKING       "working"
#define RND_SCREEN_TREES         "tech_trees"
#define RND_SCREEN_LOCKED        "locked"
#define RND_SCREEN_DISK_DESIGNS  "disk_management_designs"
#define RND_SCREEN_DISK_TECH     "disk_management_tech"
#define RND_SCREEN_MISSIONS      "missions"
#define RND_SCREEN_CORPS         "corps"

// ═══════════════════════════════════════════════════════════════════════════
// Nano module
// ═══════════════════════════════════════════════════════════════════════════

/datum/nano_module/program/rnd_console

	// ── Linked fabrication devices ───────────────────────────────────────
	/// Linked Destructive Analyzer (also stored as linked_console on the device)
	var/obj/machinery/r_n_d/destructive_analyzer/linked_destroy = null
	/// Linked Protolathe
	var/obj/machinery/fabricator/rnd/protolathe/linked_lathe = null
	/// Linked Circuit Imprinter
	var/obj/machinery/fabricator/rnd/imprinter/linked_imprinter = null

	// ── Console identity ─────────────────────────────────────────────────
	/// Console ID used for server access control (1 = main science server)
	var/id = 1
	/// If FALSE, this console is excluded from network sync and server lists
	var/sync = 1
	/// If FALSE, the tech-research tab is hidden
	var/can_research = TRUE
	/// If TRUE, security checks are bypassed
	var/emagged = FALSE
	/// If FALSE, console can't switch form initial server
	var/can_switch_server = TRUE

	// ── Billing account ──────────────────────────────────────────────────
	var/department_account_key = null
	var/linked_account_number  = 0
	var/can_switch_account     = TRUE

	// ── UI state ─────────────────────────────────────────────────────────
	var/screen = RND_SCREEN_MAIN
	var/datum/tech/selected_tech_tree
	var/datum/technology/selected_technology
	var/selected_corp_id
	var/selected_node_id
	var/selected_category_id
	var/selected_dialogue_corp_id
	var/selected_disk_category
	/// Designs category filter used in laptop (lite) mode
	var/lite_selected_category = null
	/// Design terminal colour theme for lite mode: "neutral" | "medical" | "engineering"
	var/lite_theme = "neutral"
	var/show_settings              = FALSE
	var/show_link_menu             = FALSE
	var/report_collapsed           = FALSE
	var/selected_protolathe_category
	var/selected_imprinter_category
	var/selected_robotics_category
	var/selected_mech_category
	var/searched_disk_design_text
	var/search_text
	var/quick_deconstruct = FALSE
	/// pad_id of the R&D mission drone pad linked to this console. 0 = not linked.
	var/linked_drone_pad_id = 0

	// ── Spectral analysis state ───────────────────────────────────────────
	var/spectral_active       = FALSE
	var/spectral_phase        = null
	var/list/spectral_sequence = list()
	var/spectral_index        = 0
	var/spectral_correct      = 0
	var/spectral_flash        = null
	var/spectral_result_text  = ""
	var/spectral_reward_corp  = null
	var/mob/spectral_user     = null

	// ── Artifact catalogization state ────────────────────────────────────
	var/catalog_active       = FALSE
	var/catalog_step         = 0
	var/catalog_correct      = 0
	var/catalog_result_text  = ""
	var/catalog_reward_corp  = null
	var/catalog_artifact_id  = null
	var/catalog_effect_type  = 0
	var/catalog_effect_mode  = 0
	var/catalog_effectrange  = 0

/datum/nano_module/program/rnd_console/robotics_console
	/// Temporary solution for sync problem
	id = 1
	can_research = FALSE
	lite_theme = "engineering"
	var/obj/machinery/fabricator/rnd/robotics/linked_robotics_fab = null
	var/obj/machinery/fabricator/rnd/robotics/mech/linked_mech_fab = null

/datum/nano_module/program/rnd_console/robotics_console/New(host, topic_manager, datum/computer_file/program/prog)
	. = ..()
	screen = RND_SCREEN_MAIN

/datum/nano_module/program/rnd_console/robotics_console/Destroy()
	if(linked_robotics_fab)
		if(linked_robotics_fab.linked_console == src)
			linked_robotics_fab.linked_console = null
		linked_robotics_fab = null
	if(linked_mech_fab)
		if(linked_mech_fab.linked_console == src)
			linked_mech_fab.linked_console = null
		linked_mech_fab = null
	. = ..()

/datum/nano_module/program/rnd_console/robotics_console/is_allowed(mob/user)
	if(emagged)
		return TRUE
	return check_access(user, list(access_robotics))

/datum/nano_module/program/rnd_console/robotics_console/SyncRDevices()
	var/atom/host = get_host()
	if(!host)
		return
	// Destructive analyzer, protolathe, circuit imprinter — same as full R&D console.
	..()

	for(var/obj/machinery/fabricator/rnd/robotics/F in range(3, host))
		if(!isnull(F.linked_console) || F.panel_open)
			continue
		if(istype(F, /obj/machinery/fabricator/rnd/robotics/mech))
			if(isnull(linked_mech_fab))
				linked_mech_fab = F
				F.linked_console = src
		else
			if(isnull(linked_robotics_fab))
				linked_robotics_fab = F
				F.linked_console = src

/datum/nano_module/program/rnd_console/robotics_console/proc/get_robotics_target_fab(target)
	if(target == "mech")
		return linked_mech_fab
	return linked_robotics_fab

// Biomech

/datum/nano_module/program/rnd_console/robotics_console/biomech
	id = 1
	can_research = FALSE
	lite_theme = "medical"

/datum/nano_module/program/rnd_console/robotics_console/biomech/is_allowed(mob/user)
	if(emagged)
		return TRUE
	return check_access(user, list(access_biomech))

// Public domain

/datum/nano_module/program/rnd_console/robotics_console/public
	id = 3
	can_research = FALSE
	can_switch_server = FALSE
	// You can't purchase things
	can_switch_account = FALSE

/datum/nano_module/program/rnd_console/robotics_console/public/is_allowed(mob/user)
	return TRUE

// ─────────────────────────────────────────────────────────────────────────────
// Lifecycle
// ─────────────────────────────────────────────────────────────────────────────

/datum/nano_module/program/rnd_console/New(host, topic_manager, datum/computer_file/program/prog)
	. = ..()
	if(is_lite())
		can_research = FALSE
	// Restore billing account from the program file (survives app restarts).
	// Priority: saved personal account number > saved dept key > default dept key.
	var/datum/computer_file/program/rnd_console/prog_file = program
	if(prog_file)
		if(prog_file.saved_account_number)
			linked_account_number  = prog_file.saved_account_number
			department_account_key = prog_file.saved_account_key
		else if(prog_file.saved_account_key)
			department_account_key = prog_file.saved_account_key
		else if(prog_file.default_account_key)
			department_account_key = prog_file.default_account_key
	SyncRDevices()

/datum/nano_module/program/rnd_console/Destroy()
	if(linked_destroy)
		if(linked_destroy.linked_console == src)
			linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.have_disk = TRUE
		linked_lathe.have_design_selector = TRUE
		if(linked_lathe.linked_console == src)
			linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.have_disk = TRUE
		linked_imprinter.have_design_selector = TRUE
		if(linked_imprinter.linked_console == src)
			linked_imprinter.linked_console = null
		linked_imprinter = null
	. = ..()

// ─────────────────────────────────────────────────────────────────────────────
// Adapter procs — bridge between nano_module and physical host
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the physical modular computer atom hosting this program.
/datum/nano_module/program/rnd_console/proc/get_host()
	if(program && program.computer)
		return program.computer.get_physical_host()
	return null

/// Returns the portable drive inserted into the host computer (used as R&D disk).
/// Works for both stationary modular consoles (/obj/machinery/computer/modular)
/// and laptops/PDAs (/obj/item/modular_computer).
/datum/nano_module/program/rnd_console/proc/get_disk()
	var/host = get_host()
	if(istype(host, /obj/machinery/computer/modular))
		return host:portable_drive
	if(istype(host, /obj/item/modular_computer))
		return host:portable_drive
	return null

/// Returns TRUE when running in laptop / lite mode.
/datum/nano_module/program/rnd_console/proc/is_lite()
	if(program && program.computer)
		return program.computer.get_hardware_flag() == PROGRAM_LAPTOP
	return FALSE

/// Returns TRUE if the user has research access (or the console is emagged).
/datum/nano_module/program/rnd_console/proc/is_allowed(mob/user)
	if(emagged)
		return TRUE
	return check_access(user, list(access_research))

/// Compatibility shim so fabricators can call linked_console.updateUsrDialog().
/datum/nano_module/program/rnd_console/proc/updateUsrDialog()
	SSnano.update_uis(src)

/// Reset screen to main and push a UI update.
/datum/nano_module/program/rnd_console/proc/reset_screen()
	screen = RND_SCREEN_MAIN
	SSnano.update_uis(src)

// ─────────────────────────────────────────────────────────────────────────────
// Device sync
// ─────────────────────────────────────────────────────────────────────────────

/datum/nano_module/program/rnd_console/proc/SyncRDevices()
	var/atom/host = get_host()
	if(!host)
		return

	for(var/obj/machinery/r_n_d/destructive_analyzer/D in range(3, host))
		if(!isnull(D.linked_console) || D.panel_open)
			continue
		if(isnull(linked_destroy))
			linked_destroy = D
			D.linked_console = src

	for(var/obj/machinery/fabricator/rnd/D in range(3, host))
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

/datum/nano_module/program/rnd_console/proc/find_devices()
	SyncRDevices()
	reset_screen()

// ─────────────────────────────────────────────────────────────────────────────
// Server access
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the R&D server object this console is connected to, or null.
/datum/nano_module/program/rnd_console/proc/get_server()
	var/atom/host = get_host()
	for(var/obj/machinery/r_n_d/server/S in SSresearch.rnd_server_list)
		if(!S.files || MACHINE_IS_BROKEN(S))
			continue
		if(GLOB.using_map.use_overmap && host && !(host.z in GetConnectedZlevels(S.z)))
			continue
		// Explicit access list configured — use it.
		if(id in S.id_with_download)
			return S
		// No explicit list: pair by server_id == console id (e.g. away-site servers).
		if(S.server_id == id && !length(S.id_with_download))
			return S
	return null

/// Returns the research datum of the connected R&D server, or null.
/datum/nano_module/program/rnd_console/proc/get_server_files()
	var/obj/machinery/r_n_d/server/S = get_server()
	return S ? S.files : null

/// Check if a design is banned on any server this console can reach.
/datum/nano_module/program/rnd_console/proc/is_design_banned_on_server(design_id)
	var/atom/host = get_host()
	for(var/obj/machinery/r_n_d/server/S in SSresearch.rnd_server_list)
		if(istype(S, /obj/machinery/r_n_d/server/centcom))
			continue
		if(GLOB.using_map.use_overmap && host && !(host.z in GetConnectedZlevels(S.z)))
			continue
		var/reachable = (id in S.id_with_download) || (S.server_id == id && !length(S.id_with_download))
		if(!reachable)
			continue
		if(design_id in S.files.banned_designs)
			return TRUE
	return FALSE

// ─────────────────────────────────────────────────────────────────────────────
// Billing / science account
// ─────────────────────────────────────────────────────────────────────────────

/datum/nano_module/program/rnd_console/proc/get_science_account()
	if(linked_account_number)
		return get_account(linked_account_number)
	if(department_account_key)
		return department_accounts[department_account_key]
	return null

/datum/nano_module/program/rnd_console/proc/print_rnd_invoice(mob/living/user)
	var/datum/money_account/science_account = get_science_account()
	if(!science_account)
		to_chat(user, SPAN_WARNING("Не удалось получить доступ к счёту научного отдела."))
		return

	var/obj/item/paper/manifest/rnd_invoice/invoice = new(get_turf(get_host()))
	invoice.target_account_number = science_account.account_number
	invoice.target_account_name = science_account.account_name
	invoice.is_copy = FALSE
	if(!invoice.stamped)
		invoice.stamped = list()
	invoice.stamped += /datum/nano_module/program/rnd_console
	invoice.info = {"<h3>R&D Sales Invoice</h3>
<hr>
<b>Department:</b> Research & Development<br>
<b>Account:</b> [science_account.account_name]<br>
<b>Account #:</b> [science_account.account_number]<br>
<hr>
<i>Place this invoice in a cargo crate. All proceeds from the crate's sale will be credited to the account above.</i>"}

	to_chat(user, SPAN_NOTICE("Накладная напечатана. Счёт: [science_account.account_name] (#[science_account.account_number])."))

/datum/nano_module/program/rnd_console/proc/print_missions(mob/living/user)
	var/dat = "<h3>R&D Mission Tracker</h3><hr>"
	dat += "<b>Дата:</b> [stationtime2text()]<br><hr>"
	if(LAZYLEN(derelict_missions_list))
		for(var/datum/derelict_mission/M in derelict_missions_list)
			var/status = (M.state == RND_MISSION_STATE_REWARDED) ? "Выполнен" : "Активен"
			dat += "<b>[M.title]</b> ([get_rnd_mission_corporation_name(M.corporation_id)])<br>"
			dat += "&nbsp;Объект: [M.away_site_name] | Статус: [status]<br>"
			for(var/datum/derelict_mission_objective/O in M.objectives)
				dat += "&nbsp;&nbsp;- [O.description]: [O.get_status_text()]<br>"
			dat += "<br>"
	else
		dat += "<i>Нет активных миссий.</i><br>"
	var/obj/item/paper/P = new(get_turf(get_host()))
	P.SetName("R&D Mission Report")
	P.info = dat
	to_chat(user, SPAN_NOTICE("Отчёт по миссиям распечатан."))

// ─────────────────────────────────────────────────────────────────────────────
// Tech / research helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Link this console to a drone pad by its pad_id. Called from settings UI.
/datum/nano_module/program/rnd_console/proc/link_drone_pad(mob/user)
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

/datum/nano_module/program/rnd_console/proc/find_tech_by_id(tech_id)
	var/datum/research/F = get_server_files()
	if(!F)
		return null
	for(var/datum/tech/T in F.researched_tech)
		if(T.id == tech_id)
			return T
	return null

/datum/nano_module/program/rnd_console/proc/compile_research_report(mob/living/user)
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
			for(var/i = compiled + 1 to max_level)
				cargo_value += i * rare
			tech_data[tech_id] = max_level

	if(delta <= 0)
		to_chat(user, SPAN_WARNING("Нет новых данных для компиляции."))
		return

	var/obj/item/disk/research_report/report = new(get_turf(get_host()))
	report.tech_data = tech_data.Copy()
	report.delta_levels = delta
	report.cargo_value = max(1, cargo_value * 15)

	for(var/tech_id in tech_data)
		F.compiled_tech_levels[tech_id] = tech_data[tech_id]

	to_chat(user, SPAN_NOTICE("Отчёт скомпилирован: [delta] новых уровней. Оценочная стоимость: [report.cargo_value] таллеров."))
	SSnano.update_uis(src)

/datum/nano_module/program/rnd_console/proc/buy_corp_node(mob/living/user, node_id)
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

// ─────────────────────────────────────────────────────────────────────────────
// Item analysis (called by destructive_analyzer via linked_console)
// ─────────────────────────────────────────────────────────────────────────────

/datum/nano_module/program/rnd_console/proc/handle_item_analysis(obj/item/I)
	var/datum/research/F = get_server_files()
	if(!F)
		return
	F.check_item_for_tech(I)
	F.experiments.do_research_object(I)

// ─────────────────────────────────────────────────────────────────────────────
// Sync
// ─────────────────────────────────────────────────────────────────────────────

/datum/nano_module/program/rnd_console/proc/sync_tech()
	var/datum/research/F = get_server_files()
	if(!F)
		to_chat(usr, SPAN_WARNING("Нет подключения к серверу R&D."))
		reset_screen()
		return

	var/obj/item/stock_parts/computer/hard_drive/portable/disk = get_disk()
	if(disk)
		var/uploaded = 0
		var/blocked = 0
		for(var/datum/computer_file/binary/design/file in disk.find_files_by_type(/datum/computer_file/binary/design))
			if(!file.design)
				continue
			// Hidden designs are flagged as too dangerous to distribute — block upload to server.
			if(istype(file.design, /datum/design/autolathe) && (file.design:hidden))
				blocked++
				continue
			// Banned designs cannot be uploaded back to the server.
			if("[file.design.id]" in F.banned_designs)
				blocked++
				continue
			F.AddDesign2Known(file.design)
			uploaded++
		if(uploaded)
			to_chat(usr, SPAN_NOTICE("Загружено [uploaded] дизайн(ов) с диска на сервер."))
		if(blocked)
			to_chat(usr, SPAN_WARNING("[blocked] дизайн(ов) заблокировано: запрещены к распространению."))

	var/atom/host = get_host()
	for(var/obj/machinery/r_n_d/server/S in SSresearch.rnd_server_list)
		if(GLOB.using_map.use_overmap && host && !(host.z in GetConnectedZlevels(S.z)))
			continue
		if((id in S.id_with_upload) || (id in S.id_with_download))
			S.produce_heat(400)
			break

	reset_screen()

// ─────────────────────────────────────────────────────────────────────────────
// Design data for fabricator screens
// ─────────────────────────────────────────────────────────────────────────────

/datum/nano_module/program/rnd_console/proc/get_possible_designs_data(obj/machinery/fabricator/rnd/target_machine, category)
	var/obj/machinery/r_n_d/server/S = get_server()
	if(!S)
		return list()
	var/datum/research/F = S.files
	var/list/designs_list = list()
	for(var/datum/design/D in S.get_all_designs())
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

// ─────────────────────────────────────────────────────────────────────────────
// Mission submission procs
// ─────────────────────────────────────────────────────────────────────────────

/datum/nano_module/program/rnd_console/proc/submit_physical_photo(mob/user, obj/item/photo/P)
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

/datum/nano_module/program/rnd_console/proc/submit_artifact_report(mob/user, obj/item/paper/anomaly_scan/mission/report)
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

/datum/nano_module/program/rnd_console/proc/submit_rdf_file(mob/user, rdf_ref, mission_ref)
	var/obj/item/stock_parts/computer/hard_drive/portable/disk = get_disk()
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

/datum/nano_module/program/rnd_console/proc/submit_digital_photo(mob/user, photo_ref, mission_ref)
	var/obj/item/stock_parts/computer/hard_drive/portable/disk = get_disk()
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

// ─────────────────────────────────────────────────────────────────────────────
// Reverse engineering (ported from reverse_engineering.dm)
// ─────────────────────────────────────────────────────────────────────────────

/datum/nano_module/program/rnd_console/proc/extract_design_to_disk(mob/living/user)
	if(!linked_destroy || !linked_destroy.loaded_item)
		to_chat(user, SPAN_WARNING("В деструктивном анализаторе нет предмета."))
		return FALSE

	var/obj/item/stock_parts/computer/hard_drive/portable/disk = get_disk()
	if(!disk)
		to_chat(user, SPAN_WARNING("В консоли нет диска для сохранения дизайна."))
		return FALSE

	if(disk.read_only)
		to_chat(user, SPAN_WARNING("Диск защищен от записи."))
		return FALSE

	var/datum/research/F = get_server_files()
	if(!F)
		to_chat(user, SPAN_WARNING("Нет подключения к серверу R&D."))
		return FALSE

	var/obj/item/I = linked_destroy.loaded_item
	var/datum/design/new_design = F.generate_design_from_item(I, user)
	if(!new_design)
		to_chat(user, SPAN_WARNING("Не удалось извлечь дизайн из [I.name]."))
		return FALSE

	var/list/disk_designs = disk.find_files_by_type(/datum/computer_file/binary/design)
	for(var/datum/computer_file/binary/design/existing_file in disk_designs)
		if(existing_file.design.build_path == new_design.build_path)
			to_chat(user, SPAN_NOTICE("Дизайн [new_design.name] уже сохранен на диске."))
			return TRUE

	if((disk.used_capacity + new_design.file.size) > disk.max_capacity)
		to_chat(user, SPAN_WARNING("Недостаточно места на диске ([disk.used_capacity]/[disk.max_capacity] GQ)."))
		return FALSE

	var/datum/computer_file/binary/design/file_copy = new_design.file.clone()
	if(disk.save_file(file_copy))
		F.AddDesign2Known(new_design)

		var/quality_message = ""
		if(new_design.quality >= 100)
			quality_message = SPAN_GOOD("Качество: ИДЕАЛЬНОЕ ([new_design.quality]%)")
		else if(new_design.quality >= 75)
			quality_message = SPAN_NOTICE("Качество: Хорошее ([new_design.quality]%)")
		else if(new_design.quality >= 50)
			quality_message = SPAN_NOTICE("Качество: Среднее ([new_design.quality]%)")
		else
			quality_message = SPAN_WARNING("Качество: ДЕФЕКТНОЕ ([new_design.quality]%). Изделия могут быть опасны!")

		var/skill_sum_info = ishuman(user) ? (user.get_skill_value(SKILL_SCIENCE) + user.get_skill_value(SKILL_DEVICES)) : 0
		to_chat(user, SPAN_GOOD("Дизайн [new_design.name] успешно извлечен и сохранен на диске. [quality_message] (Суммарный навык: [skill_sum_info])"))
		log_and_message_admins("extracted design [new_design.name] (quality: [new_design.quality]%) from [I.name].", user)

		linked_destroy.deconstruct_item()
		return TRUE
	else
		to_chat(user, SPAN_WARNING("Ошибка записи на диск."))
		return FALSE

// ─────────────────────────────────────────────────────────────────────────────
// Artifact catalogization (ported from artifact_catalogization.dm)
// ─────────────────────────────────────────────────────────────────────────────

/// Returns list of RDF files on the disk that contain uncatalogized artifact scan data.
/datum/nano_module/program/rnd_console/proc/find_artifact_rdf_files()
	var/obj/item/stock_parts/computer/hard_drive/portable/disk = get_disk()
	if(!disk)
		return list()
	var/datum/research/server_files = get_server_files()
	var/list/result = list()
	for(var/datum/computer_file/data/rdf/rdf_file in disk.stored_files)
		if(!rdf_file.metadata)
			continue
		var/art_id = rdf_file.metadata["artifact_id"]
		if(!art_id)
			continue
		if(server_files && (art_id in server_files.catalogized_artifact_ids))
			continue
		result += rdf_file
	return result

/datum/nano_module/program/rnd_console/proc/start_catalog(mob/living/user, rdf_ref)
	if(catalog_active)
		to_chat(user, SPAN_WARNING("Каталогизация уже запущена."))
		return
	var/obj/item/stock_parts/computer/hard_drive/portable/disk = get_disk()
	if(!disk)
		to_chat(user, SPAN_WARNING("Вставьте диск с данными сканирования артефакта."))
		return

	var/datum/computer_file/data/rdf/rdf_file = locate(rdf_ref) in disk.stored_files
	if(!istype(rdf_file) || !rdf_file.metadata)
		to_chat(user, SPAN_WARNING("Файл повреждён или не найден."))
		return

	var/art_id = rdf_file.metadata["artifact_id"]
	if(!art_id)
		to_chat(user, SPAN_WARNING("Файл не содержит данных сканирования артефакта."))
		return

	var/datum/research/F = get_server_files()
	if(!F)
		return
	if(art_id in F.catalogized_artifact_ids)
		to_chat(user, SPAN_WARNING("Этот артефакт уже каталогизирован."))
		return

	catalog_artifact_id = art_id
	catalog_effect_type = text2num(rdf_file.metadata["artifact_effect_type"])
	catalog_effect_mode = text2num(rdf_file.metadata["artifact_effect_mode"])
	catalog_effectrange = text2num(rdf_file.metadata["artifact_effectrange"])

	catalog_active = TRUE
	catalog_step = 1
	catalog_correct = 0
	catalog_result_text = ""
	catalog_reward_corp = get_catalog_effect_corporation(catalog_effect_type)

	to_chat(user, SPAN_NOTICE("Каталогизация артефакта начата. Следуйте инструкциям на консоли."))
	SSnano.update_uis(src)

/datum/nano_module/program/rnd_console/proc/do_catalog_step(mob/living/user, chosen_value)
	if(!catalog_active || catalog_step < 1 || catalog_step > 3)
		return
	if(!catalog_artifact_id)
		cancel_catalog()
		return

	var/step_name = get_catalog_step_name(catalog_step)
	var/is_correct = FALSE

	switch(catalog_step)
		if(1)
			var/chosen_type = text2num(chosen_value)
			is_correct = (chosen_type == catalog_effect_type)
			var/chosen_name = get_catalog_effect_type_name(chosen_type)
			var/correct_name = get_catalog_effect_type_name(catalog_effect_type)
			if(is_correct)
				catalog_correct++
				catalog_result_text += "<span class='good'>[step_name]: [chosen_name] — Верно!</span><br>"
			else
				catalog_result_text += "<span class='bad'>[step_name]: [chosen_name] — Неверно (правильно: [correct_name])</span><br>"
		if(2)
			var/chosen_mode = text2num(chosen_value)
			is_correct = (chosen_mode == catalog_effect_mode)
			var/chosen_name = get_catalog_effect_mode_name(chosen_mode)
			var/correct_name = get_catalog_effect_mode_name(catalog_effect_mode)
			if(is_correct)
				catalog_correct++
				catalog_result_text += "<span class='good'>[step_name]: [chosen_name] — Верно!</span><br>"
			else
				catalog_result_text += "<span class='bad'>[step_name]: [chosen_name] — Неверно (правильно: [correct_name])</span><br>"
		if(3)
			var/correct_range = get_catalog_range_category(catalog_effectrange)
			is_correct = (chosen_value == correct_range)
			var/chosen_name = get_catalog_range_name(chosen_value)
			var/correct_range_name = get_catalog_range_name(correct_range)
			if(is_correct)
				catalog_correct++
				catalog_result_text += "<span class='good'>[step_name]: [chosen_name] — Верно!</span><br>"
			else
				catalog_result_text += "<span class='bad'>[step_name]: [chosen_name] — Неверно (правильно: [correct_range_name])</span><br>"

	if(catalog_step >= 3)
		finish_catalog(user)
		return

	catalog_step++
	SSnano.update_uis(src)

/datum/nano_module/program/rnd_console/proc/finish_catalog(mob/living/user)
	var/total_rep = catalog_correct * 5
	if(catalog_correct >= 3)
		total_rep += 10

	var/datum/research/F = get_server_files()
	if(total_rep > 0 && catalog_reward_corp && F)
		F.ChangeCorporationReputation(catalog_reward_corp, total_rep)
		var/corp_name = get_rnd_mission_corporation_name(catalog_reward_corp)
		catalog_result_text += "<br><span class='good'>Каталогизация завершена. Репутация с [corp_name]: +[total_rep]</span>"
		if(user)
			to_chat(user, SPAN_NOTICE("Каталогизация артефакта завершена. Репутация с [corp_name]: +[total_rep]."))
	else
		catalog_result_text += "<br><span class='average'>Каталогизация завершена. Классификация неточна — данные не представляют ценности.</span>"
		if(user)
			to_chat(user, SPAN_NOTICE("Каталогизация завершена, но классификация слишком неточна."))

	if(catalog_artifact_id && F)
		F.catalogized_artifact_ids += catalog_artifact_id

	catalog_active = FALSE
	catalog_step = 0
	catalog_artifact_id = null
	SSnano.update_uis(src)

/datum/nano_module/program/rnd_console/proc/cancel_catalog()
	catalog_active = FALSE
	catalog_step = 0
	catalog_correct = 0
	catalog_result_text = ""
	catalog_reward_corp = null
	catalog_artifact_id = null
	SSnano.update_uis(src)

// ─────────────────────────────────────────────────────────────────────────────
// Spectral analysis (ported from spectral_analysis.dm)
// ─────────────────────────────────────────────────────────────────────────────

/datum/nano_module/program/rnd_console/proc/start_spectral(mob/living/user)
	if(spectral_active)
		to_chat(user, SPAN_WARNING("Спектральный анализ уже запущен."))
		return
	if(!linked_destroy || !linked_destroy.start_spectral_analysis(user))
		return

	var/obj/item/I = linked_destroy.loaded_item
	if(I && I.origin_tech && LAZYLEN(I.origin_tech))
		var/best_tech = null
		var/best_level = 0
		for(var/T in I.origin_tech)
			if(I.origin_tech[T] > best_level)
				best_tech = T
				best_level = I.origin_tech[T]
		spectral_reward_corp = get_spectral_tech_corporation(best_tech)

	spectral_user = user
	spectral_active = TRUE
	spectral_correct = 0
	spectral_result_text = ""
	spectral_index = 1
	spectral_phase = "playback"

	generate_spectral_sequence(I)
	SSnano.update_uis(src)

/datum/nano_module/program/rnd_console/proc/generate_spectral_sequence(obj/item/I)
	var/length = 4
	if(I && I.origin_tech)
		var/total = 0
		for(var/T in I.origin_tech)
			total += I.origin_tech[T]
		if(total >= 15)
			length = 8
		else if(total >= 8)
			length = 6
		else if(total >= 4)
			length = 5

	spectral_sequence = list()
	var/last_color = null
	var/i = 1
	while(i <= length)
		var/c = pick("red", "green", "blue", "yellow")
		while(c == last_color)
			c = pick("red", "green", "blue", "yellow")
		spectral_sequence += c
		last_color = c
		i++

	play_simon_sequence()

/datum/nano_module/program/rnd_console/proc/play_simon_sequence()
	set waitfor = FALSE

	spectral_phase = "playback"
	spectral_flash = null
	SSnano.update_uis(src)
	sleep(5)

	for(var/i = 1; i <= LAZYLEN(spectral_sequence); i++)
		if(!spectral_active)
			return
		spectral_flash = null
		SSnano.update_uis(src)
		sleep(3)
		spectral_flash = spectral_sequence[i]
		SSnano.update_uis(src)
		sleep(10)

	spectral_flash = null
	spectral_phase = "input"
	SSnano.update_uis(src)

/datum/nano_module/program/rnd_console/proc/do_spectral_step(mob/living/user, chosen_color)
	if(!spectral_active)
		return
	if(spectral_phase != "input")
		return
	if(!linked_destroy)
		cancel_spectral()
		return
	if(!LAZYLEN(spectral_sequence))
		cancel_spectral()
		return

	var/expected = spectral_sequence[spectral_index]

	if(chosen_color != expected)
		spectral_result_text += "<span class='bad'>Ошибка на шаге [spectral_index]/[LAZYLEN(spectral_sequence)]: ожидалось [expected].</span><br>"
		finish_spectral(user)
		return

	spectral_correct++
	spectral_result_text += "<span class='good'>Шаг [spectral_index]/[LAZYLEN(spectral_sequence)]: [chosen_color] — верно.</span><br>"
	spectral_index++

	if(spectral_index > LAZYLEN(spectral_sequence))
		finish_spectral(user)
		return

	SSnano.update_uis(src)

/datum/nano_module/program/rnd_console/proc/finish_spectral(mob/living/user)
	if(!linked_destroy)
		cancel_spectral()
		return

	var/total_rep = spectral_correct
	if(spectral_correct >= LAZYLEN(spectral_sequence))
		total_rep += 3

	var/datum/research/F = get_server_files()
	if(total_rep > 0 && spectral_reward_corp && F)
		F.ChangeCorporationReputation(spectral_reward_corp, total_rep)
		var/corp_name = get_rnd_mission_corporation_name(spectral_reward_corp)
		spectral_result_text += "<br><span class='good'>Анализ завершён. Репутация с [corp_name]: +[total_rep]</span>"
		if(user)
			to_chat(user, SPAN_NOTICE("Спектральный анализ завершён. Репутация с [corp_name]: +[total_rep]."))
	else
		spectral_result_text += "<br><span class='average'>Анализ завершён. Недостаточно данных для репутации.</span>"
		if(user)
			to_chat(user, SPAN_NOTICE("Спектральный анализ завершён, но данных недостаточно."))

	if(linked_destroy.loaded_item && F)
		F.spectral_analyzed_types += linked_destroy.loaded_item.type
		F.experiments.do_research_object(linked_destroy.loaded_item)

	linked_destroy.finish_spectral()
	spectral_active = FALSE
	spectral_phase = null
	spectral_sequence = list()
	spectral_index = 0
	spectral_flash = null
	SSnano.update_uis(src)

/datum/nano_module/program/rnd_console/proc/cancel_spectral()
	spectral_active = FALSE
	spectral_phase = null
	spectral_correct = 0
	spectral_result_text = ""
	spectral_reward_corp = null
	spectral_sequence = list()
	spectral_index = 0
	spectral_flash = null
	spectral_user = null
	if(linked_destroy)
		linked_destroy.finish_spectral()
	SSnano.update_uis(src)

// ─────────────────────────────────────────────────────────────────────────────
// Corporation info
// ─────────────────────────────────────────────────────────────────────────────

/datum/nano_module/program/rnd_console/proc/get_rdconsole_corp_info(corp_id)
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

// ─────────────────────────────────────────────────────────────────────────────
// Topic handler
// ─────────────────────────────────────────────────────────────────────────────

/datum/nano_module/program/rnd_console/Topic(href, href_list)
	if(..())
		return 1

	var/obj/item/stock_parts/computer/hard_drive/portable/disk = get_disk()
	var/lite = is_lite()

	var/obj/machinery/fabricator/rnd/target_device
	if(!lite)
		if(screen == RND_SCREEN_PROTO && linked_lathe)
			target_device = linked_lathe
		else if(screen == RND_SCREEN_IMPRINTER && linked_imprinter)
			target_device = linked_imprinter
		else if(screen == "robotics_fabricator" && istype(src, /datum/nano_module/program/rnd_console/robotics_console))
			var/datum/nano_module/program/rnd_console/robotics_console/RC_TS = src
			target_device = RC_TS.linked_robotics_fab
		else if(screen == "mech_fabricator" && istype(src, /datum/nano_module/program/rnd_console/robotics_console))
			var/datum/nano_module/program/rnd_console/robotics_console/RC_TM = src
			target_device = RC_TM.linked_mech_fab

	if(href_list["select_corp"])
		var/new_corp = href_list["select_corp"]
		if(get_rnd_corp_tree(new_corp))
			selected_corp_id = new_corp
			selected_node_id = null
	if(href_list["select_corp_node"])
		selected_node_id = href_list["select_corp_node"]
	if(href_list["buy_corp_node"])
		buy_corp_node(usr, href_list["buy_corp_node"])
	if(href_list["select_tech_tree"])
		var/datum/research/F_stt = get_server_files()
		if(F_stt)
			var/datum/tech/tech_tree = locate(href_list["select_tech_tree"]) in F_stt.researched_tech
			if(tech_tree && tech_tree.shown)
				selected_tech_tree = tech_tree
				selected_technology = null
	if(href_list["select_technology"])
		var/tech_node = locate(href_list["select_technology"]) in SSresearch.all_tech_nodes
		if(tech_node)
			selected_technology = tech_node
	if(href_list["unlock_technology"])
		var/datum/research/F_ut = get_server_files()
		if(F_ut)
			var/tech_node = locate(href_list["unlock_technology"]) in SSresearch.all_tech_nodes
			if(tech_node)
				F_ut.UnlockTechology(tech_node)
	if(href_list["go_screen"])
		var/where = href_list["go_screen"]
		if(lite && (where == RND_SCREEN_PROTO || where == RND_SCREEN_IMPRINTER))
			return TRUE
		if(istype(src, /datum/nano_module/program/rnd_console/robotics_console) && where == RND_SCREEN_MISSIONS)
			where = RND_SCREEN_MAIN
		if(href_list["need_access"])
			if(!is_allowed(usr))
				to_chat(usr, SPAN_WARNING("Unauthorized access."))
				return
		screen = where
		if(screen == RND_SCREEN_PROTO || screen == RND_SCREEN_IMPRINTER || screen == "robotics_fabricator" || screen == "mech_fabricator" || screen == RND_SCREEN_DISK_DESIGNS)
			search_text = ""
		if(screen == RND_SCREEN_DISK_DESIGNS)
			selected_disk_category = null
	if(href_list["eject_disk"])
		if(disk)
			var/host = get_host()
			var/turf/T = get_turf(host)
			if(istype(host, /obj/machinery/computer/modular))
				// Stationary console — clear its own portable_drive var
				host:portable_drive = null
				disk.forceMove(T)
			else if(istype(host, /obj/item/modular_computer))
				// Laptop — use the proper uninstall proc which clears portable_drive
				host:uninstall_component(usr, disk)
			else
				disk.forceMove(T)
	if(href_list["delete_disk_file"])
		if(disk)
			var/datum/computer_file/file = locate(href_list["delete_disk_file"]) in disk.stored_files
			disk.remove_file(file)

	if(href_list["download_disk_design"])
		if(disk)
			var/datum/computer_file/binary/design/file = locate(href_list["download_disk_design"]) in disk.stored_files
			if(file && file.design)
				if(istype(file.design, /datum/design/autolathe) && (file.design:hidden))
					to_chat(usr, SPAN_WARNING("Этот дизайн запрещён к распространению."))
				else
					var/datum/research/F_dd = get_server_files()
					if(F_dd)
						if("[file.design.id]" in F_dd.banned_designs)
							to_chat(usr, SPAN_WARNING("Загрузка этого дизайна на сервер запрещена администратором."))
						else
							F_dd.AddDesign2Known(file.design)
					else
						to_chat(usr, SPAN_WARNING("Нет подключения к серверу. Дизайн не загружен."))
	if(href_list["upload_disk_design"])
		if(disk)
			var/obj/machinery/r_n_d/server/S_ud = get_server()
			var/datum/research/F_ud = S_ud ? S_ud.files : null
			if(F_ud && S_ud)
				var/datum/design/D = locate(href_list["upload_disk_design"]) in S_ud.get_all_designs()
				if(D)
					if(istype(D, /datum/design/autolathe) && (D:hidden))
						to_chat(usr, SPAN_WARNING("Этот дизайн запрещён к сохранению на диск."))
					else if("[D.id]" in F_ud.banned_designs)
						to_chat(usr, SPAN_WARNING("Сохранение этого дизайна на диск запрещено администратором."))
					else
						disk.save_file(D.file.clone())

	if(href_list["toggle_settings"])
		if(is_allowed(usr))
			show_settings = !show_settings
		else
			to_chat(usr, SPAN_WARNING("Unauthorized access."))
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
		var/datum/computer_file/program/rnd_console/pf = program
		if(pf)
			pf.saved_account_number = linked_account_number
			pf.saved_account_key    = null
		to_chat(usr, SPAN_NOTICE("Счёт привязан: [found.account_name]."))
	if(href_list["unlink_account"])
		if(!can_switch_account)
			return
		linked_account_number = 0
		var/datum/computer_file/program/rnd_console/pf2 = program
		if(pf2)
			pf2.saved_account_number = 0
			pf2.saved_account_key    = null
			// Restore department default if one was preset
			department_account_key = pf2.default_account_key
		else
			department_account_key = null
		to_chat(usr, SPAN_NOTICE("Счёт отвязан."))
	if(href_list["link_drone_pad"])
		if(is_allowed(usr))
			link_drone_pad(usr)
		else
			to_chat(usr, SPAN_WARNING("Unauthorized access."))
	if(href_list["toggle_link_menu"])
		if(is_allowed(usr))
			show_link_menu = !show_link_menu
		else
			to_chat(usr, SPAN_WARNING("Unauthorized access."))
	if(href_list["sync"])
		if(!get_server())
			to_chat(usr, SPAN_WARNING("Консоль не подключена к серверу R&D."))
		else
			screen = RND_SCREEN_WORKING
			addtimer(new Callback(src, PROC_REF(sync_tech)), 3 SECONDS)
	if(href_list["togglesync"])
		var/obj/machinery/r_n_d/server/cur = get_server()
		if(cur)
			cur.id_with_download -= id
			to_chat(usr, SPAN_NOTICE("Консоль отключена от [cur.name]."))
		else
			var/entered_id = input(usr, "Введите сетевой ID сервера (задаётся мультитулом):", "Подключение к серверу", 1) as num|null
			if(!isnull(entered_id))
				entered_id = round(entered_id)
				var/atom/host = get_host()
				var/obj/machinery/r_n_d/server/found = null
				for(var/obj/machinery/r_n_d/server/FS in SSresearch.rnd_server_list)
					if(FS.server_id == entered_id && FS.files)
						if(GLOB.using_map.use_overmap && host && !(host.z in GetConnectedZlevels(FS.z)))
							continue
						found = FS
						break
				if(found)
					if(!(id in found.id_with_download))
						found.id_with_download += id
					to_chat(usr, SPAN_NOTICE("Консоль подключена к [found.name] (ID: [found.server_id])."))
				else
					to_chat(usr, SPAN_WARNING("Сервер с ID [entered_id] не найден в сети."))
	if(href_list["select_category"])
		var/what_cat = href_list["select_category"]
		if(screen == RND_SCREEN_PROTO)
			selected_protolathe_category = what_cat
		if(screen == RND_SCREEN_IMPRINTER)
			selected_imprinter_category = what_cat
		if(screen == "robotics_fabricator")
			selected_robotics_category = what_cat
		if(screen == "mech_fabricator")
			selected_mech_category = what_cat
	if(href_list["select_tech_category"])
		selected_category_id = href_list["select_tech_category"]
		selected_corp_id = null
		selected_node_id = null
	if(href_list["select_corp_dialogue"])
		selected_dialogue_corp_id = href_list["select_corp_dialogue"]
	if(href_list["select_disk_category"])
		selected_disk_category = href_list["select_disk_category"]
		if(selected_disk_category == "__all__")
			selected_disk_category = null
	if(href_list["set_theme"])
		var/new_theme = href_list["set_theme"]
		if(new_theme == "neutral" || new_theme == "medical" || new_theme == "engineering")
			lite_theme = new_theme

	if(href_list["search"])
		if(lite)
			// Lite (laptop) mode: inline search from template input field
			search_text = sanitize(href_list["search_text"])
		else
			var/input = sanitizeSafe(input(usr, "Enter text to search", "Searching") as null|text, MAX_LNAME_LEN)
			search_text = input
			if(screen == RND_SCREEN_PROTO)
				if(!search_text)
					selected_protolathe_category = null
				else
					selected_protolathe_category = "Search Results"
			if(screen == RND_SCREEN_IMPRINTER)
				if(!search_text)
					selected_imprinter_category = null
				else
					selected_imprinter_category = "Search Results"
			if(screen == "robotics_fabricator")
				if(!search_text)
					selected_robotics_category = null
				else
					selected_robotics_category = "Search Results"
			if(screen == "mech_fabricator")
				if(!search_text)
					selected_mech_category = null
				else
					selected_mech_category = "Search Results"
			if(screen == RND_SCREEN_DISK_DESIGNS)
				if(!search_text)
					searched_disk_design_text = null
				else
					searched_disk_design_text = "Search Results"

	if(href_list["clear_search"])
		search_text = ""
		if(!lite)
			if(screen == RND_SCREEN_PROTO)
				selected_protolathe_category = null
			if(screen == RND_SCREEN_IMPRINTER)
				selected_imprinter_category = null
			if(screen == "robotics_fabricator")
				selected_robotics_category = null
			if(screen == "mech_fabricator")
				selected_mech_category = null
			if(screen == RND_SCREEN_DISK_DESIGNS)
				searched_disk_design_text = null

	// ── Lite (laptop) mode — design terminal actions ───────────────────────────
	if(lite)
		if(href_list["set_category"])
			lite_selected_category = (href_list["category"] == "all") ? null : href_list["category"]

		// Save design from server → disk
		if(href_list["save_to_disk"])
			if(disk)
				var/obj/machinery/r_n_d/server/S_std = get_server()
				var/datum/research/F_std = S_std ? S_std.files : null
				var/datum/design/D = S_std ? (locate(href_list["save_to_disk"]) in S_std.get_all_designs()) : null
				if(D)
					if(istype(D, /datum/design/autolathe) && (D:hidden))
						to_chat(usr, SPAN_WARNING("Этот дизайн запрещён к сохранению на диск."))
					else if("[D.id]" in F_std.banned_designs)
						to_chat(usr, SPAN_WARNING("Сохранение этого дизайна на диск запрещено администратором."))
					else
						if(!D.file)
							D.file = new /datum/computer_file/binary/design()
							D.file.design = D
							D.file.filename = sanitizeFileName("[D.id]")
							D.file.filetype = "design"
							D.file.size = 10
						disk.save_file(D.file.clone())

		// Load design from disk → server
		if(href_list["load_from_disk"])
			if(disk)
				var/list/disk_files = disk.find_files_by_type(/datum/computer_file/binary/design)
				var/datum/computer_file/binary/design/file = locate(href_list["load_from_disk"]) in disk_files
				if(file && file.design)
					if(istype(file.design, /datum/design/autolathe) && (file.design:hidden))
						to_chat(usr, SPAN_WARNING("Этот дизайн запрещён к распространению."))
					else
						var/datum/research/F_lfd = get_server_files()
						if(F_lfd)
							if("[file.design.id]" in F_lfd.banned_designs)
								to_chat(usr, SPAN_WARNING("Загрузка этого дизайна на сервер запрещена администратором."))
							else
								F_lfd.AddDesign2Known(file.design)

		if(istype(src, /datum/nano_module/program/rnd_console/robotics_console))
			if(href_list["build_to_fab"])
				var/datum/nano_module/program/rnd_console/robotics_console/RC = src
				var/obj/machinery/fabricator/rnd/robotics/target_fab = RC.get_robotics_target_fab(href_list["fab_target"])
				var/obj/machinery/r_n_d/server/S_rf = get_server()
				if(target_fab && S_rf)
					var/datum/design/D_rf = locate(href_list["build_to_fab"]) in S_rf.get_all_designs()
					if(D_rf)
						var/amount_rf = clamp(text2num(href_list["amount"]), 1, 10)
						if(D_rf.build_type & target_fab.build_type)
							target_fab.queue_design(D_rf.file, amount_rf)
			if(href_list["clear_fab_queue"])
				var/datum/nano_module/program/rnd_console/robotics_console/RCQ = src
				var/obj/machinery/fabricator/rnd/robotics/target_fab_q = RCQ.get_robotics_target_fab(href_list["fab_target"])
				if(target_fab_q)
					target_fab_q.clear_queue()
			if(href_list["fab_eject_sheet"])
				var/datum/nano_module/program/rnd_console/robotics_console/RCE = src
				var/obj/machinery/fabricator/rnd/robotics/target_fab_e = RCE.get_robotics_target_fab(href_list["fab_target"])
				if(target_fab_e)
					target_fab_e.eject(href_list["fab_eject_sheet"], text2num(href_list["amount"]))

	if(!lite)
		if(href_list["deconstruct"])
			if(linked_destroy)
				if(linked_destroy.deconstruct_item())
					screen = RND_SCREEN_WORKING
		if(href_list["eject_item"])
			if(linked_destroy)
				linked_destroy.eject_item()
		if(href_list["extract_design"])
			extract_design_to_disk(usr)

		if(href_list["start_spectral"])
			start_spectral(usr)
		if(href_list["spectral_choice"])
			do_spectral_step(usr, href_list["spectral_choice"])
		if(href_list["cancel_spectral"])
			cancel_spectral()
		if(href_list["clear_spectral"])
			spectral_result_text = ""
			SSnano.update_uis(src)

		if(href_list["build"])
			var/obj/machinery/r_n_d/server/S_b = get_server()
			var/datum/research/F_b = S_b ? S_b.files : null
			if(F_b && S_b)
				var/amount = clamp(text2num(href_list["amount"]), 1, 10)
				var/datum/design/being_built = locate(href_list["build"]) in S_b.get_all_designs()
				if(being_built && target_device)
					if(("[being_built.id]" in F_b.banned_designs) || is_design_banned_on_server("[being_built.id]"))
						to_chat(usr, SPAN_WARNING("Производство этого дизайна запрещено."))
					else
						target_device.queue_design(being_built.file, amount)
		if(href_list["clear_queue"])
			if(target_device)
				target_device.clear_queue()
		if(href_list["eject_sheet"])
			if(target_device)
				target_device.eject(href_list["eject_sheet"], text2num(href_list["amount"]))

		if(href_list["find_device"])
			screen = RND_SCREEN_WORKING
			addtimer(new Callback(src, PROC_REF(find_devices)), 2 SECONDS)
		if(href_list["disconnect"])
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

	if(href_list["start_catalog"])
		start_catalog(usr, href_list["start_catalog"])
	if(href_list["catalog_choice"])
		do_catalog_step(usr, href_list["catalog_choice"])
	if(href_list["cancel_catalog"])
		cancel_catalog()
	if(href_list["clear_catalog"])
		catalog_result_text = ""
		SSnano.update_uis(src)

	if(href_list["compile_report"])
		compile_research_report(usr)
	if(href_list["toggle_report_collapse"])
		report_collapsed = !report_collapsed
		SSnano.update_uis(src)
	if(href_list["print_invoice"])
		print_rnd_invoice(usr)
	if(href_list["print_missions"])
		print_missions(usr)

	if(href_list["reset"])
		to_chat(usr, SPAN_WARNING("База данных хранится на сервере R&D. Для сброса обратитесь к серверной машине напрямую."))
	if(href_list["lock"])
		if(is_allowed(usr))
			screen = RND_SCREEN_LOCKED
		else
			to_chat(usr, SPAN_WARNING("Unauthorized access."))
	if(href_list["unlock"])
		if(is_allowed(usr))
			screen = RND_SCREEN_MAIN
		else
			to_chat(usr, SPAN_WARNING("Unauthorized access."))

	if(href_list["submit_rdf"])
		submit_rdf_file(usr, href_list["submit_rdf"], href_list["submit_rdf_mission"])
	if(href_list["submit_photo"])
		submit_digital_photo(usr, href_list["submit_photo"], href_list["submit_photo_mission"])

	SSnano.update_uis(src)
	return TRUE

// ─────────────────────────────────────────────────────────────────────────────
// UI
// ─────────────────────────────────────────────────────────────────────────────

/datum/nano_module/program/rnd_console/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/lite = is_lite()
	var/obj/item/stock_parts/computer/hard_drive/portable/disk = get_disk()

	if(!lite)
		if((screen == RND_SCREEN_PROTO && !linked_lathe) || (screen == RND_SCREEN_IMPRINTER && !linked_imprinter))
			screen = RND_SCREEN_MAIN
		if(istype(src, /datum/nano_module/program/rnd_console/robotics_console))
			var/datum/nano_module/program/rnd_console/robotics_console/RCU = src
			if(screen == "robotics_fabricator" && !RCU.linked_robotics_fab)
				screen = RND_SCREEN_MAIN
			if(screen == "mech_fabricator" && !RCU.linked_mech_fab)
				screen = RND_SCREEN_MAIN
	else
		// In lite mode only "designs" and "corps" are valid screens
		if(screen != "corps")
			screen = "designs"

	var/datum/research/F = get_server_files()

	// ── Laptop / lite mode: render as design terminal ─────────────────────
	if(lite)
		var/datum/money_account/lite_acc = get_science_account()
		var/list/lite_data = list()

		var/obj/machinery/r_n_d/server/lite_server = get_server()
		lite_data["ui_theme"]             = lite_theme
		lite_data["has_theme_selector"]   = TRUE
		lite_data["has_server"]           = !!lite_server
		lite_data["server_name"]          = lite_server ? lite_server.name : ""
		lite_data["has_account"]          = !!lite_acc
		lite_data["account_name"]         = lite_acc ? lite_acc.account_name : ""
		lite_data["balance"]              = lite_acc ? lite_acc.money : 0
		lite_data["currency_short"]       = GLOB.using_map.local_currency_name_short
		lite_data["can_switch_server"]    = can_switch_server
		lite_data["can_switch_account"]   = can_switch_account
		lite_data["linked_account_number"]= linked_account_number
		lite_data["has_disk"]             = !!disk
		if(disk)
			lite_data["disk_size"] = disk.max_capacity
			lite_data["disk_used"] = disk.used_capacity

		lite_data["dt_screen"] = screen  // "designs" or "corps"

		// ── Designs screen ────────────────────────────────────────────────
		if(screen == "designs")
			var/obj/machinery/r_n_d/server/S_lite = get_server()
			var/list/lite_designs = S_lite ? S_lite.get_all_designs() : list()
			var/list/categories = list()
			for(var/datum/design/D in lite_designs)
				if(D.starts_unlocked)
					continue
				for(var/cat in D.category)
					categories |= cat
			lite_data["categories"]        = categories
			lite_data["selected_category"] = lite_selected_category
			lite_data["search_text"]       = search_text

			var/list/terminal_designs = list()
			for(var/datum/design/D in lite_designs)
				if(D.starts_unlocked)
					continue
				if(search_text && !findtext(lowertext(D.name), lowertext(search_text)))
					continue
				if(lite_selected_category && LAZYLEN(D.category) && !(lite_selected_category in D.category))
					continue
				var/on_disk = FALSE
				if(disk)
					var/list/disk_files = disk.find_files_by_type(/datum/computer_file/binary/design)
					for(var/datum/computer_file/binary/design/file in disk_files)
						if(file.design && file.design == D)
							on_disk = TRUE
							break
				terminal_designs += list(list("name" = D.name, "id" = "\ref[D]", "on_disk" = on_disk))
			lite_data["terminal_designs"] = terminal_designs

			var/list/disk_designs = list()
			if(disk)
				var/list/disk_files = disk.find_files_by_type(/datum/computer_file/binary/design)
				for(var/datum/computer_file/binary/design/file in disk_files)
					if(!file.design)
						continue
					disk_designs += list(list("name" = file.design.name, "id" = "\ref[file]"))
			lite_data["disk_designs"] = disk_designs

			if(istype(src, /datum/nano_module/program/rnd_console/robotics_console))
				var/datum/nano_module/program/rnd_console/robotics_console/RCUI = src
				var/list/robotics_designs = list()
				var/list/mech_designs = list()
				for(var/datum/design/D_rf in lite_designs)
					if(D_rf.starts_unlocked)
						continue
					if(search_text && !findtext(lowertext(D_rf.name), lowertext(search_text)))
						continue
					if(lite_selected_category && LAZYLEN(D_rf.category) && !(lite_selected_category in D_rf.category))
						continue
					var/list/entry = list("name" = D_rf.name, "id" = "\ref[D_rf]")
					if(D_rf.build_type & ROBOTFAB)
						robotics_designs += list(entry)
					if(D_rf.build_type & MECHFAB)
						mech_designs += list(entry)
				lite_data["robotics_designs"] = robotics_designs
				lite_data["mech_designs"] = mech_designs

				var/list/r_queue = list()
				if(RCUI.linked_robotics_fab)
					for(var/datum/computer_file/binary/design/rf in RCUI.linked_robotics_fab.queue)
						if(rf.design)
							r_queue += rf.design.name
				lite_data["robotics_queue"] = r_queue

				var/list/m_queue = list()
				if(RCUI.linked_mech_fab)
					for(var/datum/computer_file/binary/design/mf in RCUI.linked_mech_fab.queue)
						if(mf.design)
							m_queue += mf.design.name
				lite_data["mech_queue"] = m_queue

				lite_data["has_robotics_fab"] = !!RCUI.linked_robotics_fab
				lite_data["has_mech_fab"] = !!RCUI.linked_mech_fab

		// ── Corps screen ──────────────────────────────────────────────────
		if(screen == "corps")
			var/list/all_categories = get_rnd_tech_categories()
			var/list/categories_list = list()
			for(var/cat_id in all_categories)
				var/list/cat = all_categories[cat_id]
				if(!cat)
					continue
				categories_list += list(list("id" = cat_id, "name" = cat["name"]))
			lite_data["corp_categories"] = categories_list

			var/sel_category = selected_category_id
			if(!sel_category || !get_rnd_category(sel_category))
				sel_category = all_categories && length(all_categories) ? all_categories[1] : null
				selected_category_id = sel_category
			lite_data["selected_category_id"] = sel_category

			var/list/corp_trees_in_cat = get_rnd_category_trees(sel_category)
			var/list/corp_trees = list()
			for(var/corp_id in corp_trees_in_cat)
				var/list/tree = corp_trees_in_cat[corp_id]
				if(!tree)
					continue
				corp_trees += list(list("id" = corp_id, "name" = tree["name"]))
			lite_data["corp_trees"] = corp_trees

			var/selected_corp = selected_corp_id
			if(!selected_corp || !(selected_corp in corp_trees_in_cat))
				selected_corp = (corp_trees_in_cat && length(corp_trees_in_cat)) ? corp_trees_in_cat[1] : null
				selected_corp_id = selected_corp
			lite_data["selected_corp"]      = selected_corp
			lite_data["selected_corp_logo"] = get_rnd_corp_logo(selected_corp)

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
				var/is_researched = F ? F.IsResearched(tech_node) : FALSE
				var/can_unlock = F ? get_rnd_corp_node_requirements_met(F, tech_node, corp_node_set) : FALSE
				corp_nodes += list(list(
					"id"           = node_id,
					"name"         = tech_node.name,
					"x"            = round(tech_node.x * 100),
					"y"            = round(tech_node.y * 100),
					"icon"         = "[tech_node.icon]",
					"isresearched" = is_researched,
					"canunlock"    = can_unlock
				))
				for(var/req_tech in tech_node.required_technologies)
					var/datum/technology/other_tech = locate(req_tech) in SSresearch.all_tech_nodes
					if(!other_tech || !(other_tech.id in corp_node_set))
						continue
					corp_lines += list(list(
						"line_x"  = min(round(other_tech.x * 100), round(tech_node.x * 100)),
						"line_y"  = min(round(other_tech.y * 100), round(tech_node.y * 100)),
						"width"   = abs(round(other_tech.x * 100) - round(tech_node.x * 100)),
						"height"  = abs(round(other_tech.y * 100) - round(tech_node.y * 100)),
						"istop"   = (other_tech.y > tech_node.y),
						"isright" = (other_tech.x < tech_node.x)
					))
			lite_data["corp_nodes"] = corp_nodes
			lite_data["corp_lines"] = corp_lines

			var/sel_node = selected_node_id
			if(!sel_node || !(sel_node in corp_node_set))
				sel_node = length(corp_node_ids) ? corp_node_ids[1] : null
				selected_node_id = sel_node
			lite_data["selected_node_id"] = sel_node

			if(sel_node)
				var/datum/technology/tech_node = SSresearch.get_tech_node(sel_node)
				if(tech_node)
					var/is_researched = F ? F.IsResearched(tech_node) : FALSE
					var/can_unlock = F ? get_rnd_corp_node_requirements_met(F, tech_node, corp_node_set) : FALSE
					var/price = get_rnd_corp_node_price(tech_node, F)
					var/list/node_detail = list(
						"name"         = tech_node.name,
						"desc"         = tech_node.desc,
						"price"        = price,
						"isresearched" = is_researched,
						"canunlock"    = can_unlock,
						"can_buy"      = can_unlock
					)
					var/list/requirement_list = list()
					for(var/t in tech_node.required_tech_levels)
						var/datum/tech/tree = F ? (locate(t) in F.researched_tech) : null
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
							"isgood" = F ? F.IsResearched(other_tech) : FALSE
						))
					node_detail["requirements"] = requirement_list

					var/list/unlock_list = list()
					for(var/T in tech_node.unlocks_designs)
						var/datum/design/D = SSresearch.get_design(T)
						if(D)
							unlock_list += list(list("text" = "[D.shortname]"))
					node_detail["unlocks"] = unlock_list

					if(tech_node.required_corp_id)
						var/current_rep = F ? F.GetCorporationReputation(tech_node.required_corp_id) : 0
						node_detail["current_reputation"]  = current_rep
						node_detail["required_reputation"] = tech_node.min_reputation
						node_detail["reputation_met"]      = (current_rep >= tech_node.min_reputation)
						node_detail["corp_id"]             = get_rnd_mission_corporation_name(tech_node.required_corp_id)

					lite_data["selected_node"] = node_detail

		if(program)
			var/list/header = program.get_header_data()
			for(var/k in header)
				lite_data[k] = header[k]

		ui = SSnano.try_update_ui(user, src, ui_key, ui, lite_data)
		if(!ui)
			ui = new(user, src, ui_key, "mods-design_terminal.tmpl", "R&D Console", 1300, 800)
			ui.auto_update_layout = 1
			ui.set_initial_data(lite_data)
			ui.open()
			ui.set_auto_update(1)
		return

	var/obj/machinery/r_n_d/server/connected_server = get_server()
	var/list/data = program ? program.get_header_data() : list()
	data["screen"] = screen
	data["is_robotics_console"] = istype(src, /datum/nano_module/program/rnd_console/robotics_console)
	data["ui_theme"] = lite_theme
	data["has_theme_selector"] = TRUE
	data["sync"] = !!connected_server
	data["has_disk"] = !!disk
	data["has_server"] = !!connected_server
	data["server_name"] = connected_server ? connected_server.name : ""

	var/datum/money_account/sci_acc = get_science_account()
	data["science_balance"]       = sci_acc ? sci_acc.money : 0
	data["has_science_account"]   = !!sci_acc
	data["science_account_name"]  = sci_acc ? sci_acc.account_name : ""
	data["currency_short"]        = GLOB.using_map.local_currency_name_short
	data["can_switch_server"]    = can_switch_server
	data["can_switch_account"]    = can_switch_account
	data["linked_account_number"] = linked_account_number

	if(disk)
		data["disk_size"]      = disk.max_capacity
		data["disk_used"]      = disk.used_capacity
		data["disk_read_only"] = disk.read_only

	if(!screen || screen == RND_SCREEN_MAIN)
		data["show_settings"]         = show_settings
		data["show_link_menu"]        = show_link_menu
		data["has_dest_analyzer"]     = !!linked_destroy && !lite
		data["has_protolathe"]        = !!linked_lathe && !lite
		data["has_circuit_imprinter"] = !!linked_imprinter && !lite
		data["can_research"]          = can_research
		data["linked_drone_pad_id"]   = linked_drone_pad_id

		var/list/tech_tree_list = list()
		if(F)
			for(var/tree in F.researched_tech)
				var/datum/tech/tech_tree = tree
				if(!tech_tree.shown)
					continue
				tech_tree_list += list(list(
					"id" =        tech_tree.type,
					"name" =      "[tech_tree.name]",
					"shortname" = "[tech_tree.shortname]",
					"level" =     tech_tree.level,
					"maxlevel" =  tech_tree.maxlevel
				))
		data[RND_SCREEN_TREES] = tech_tree_list

		if(data["is_robotics_console"])
			var/datum/nano_module/program/rnd_console/robotics_console/RC_MAIN = src
			data["has_robotics_fab"] = !!RC_MAIN.linked_robotics_fab
			data["has_mech_fab"] = !!RC_MAIN.linked_mech_fab

		if(!lite && linked_destroy)
			if(linked_destroy.loaded_item)
				var/list/tech_names = list(TECH_MATERIAL = "Materials", TECH_ENGINEERING = "Engineering", TECH_PHORON = "Phoron", TECH_POWER = "Power", TECH_BLUESPACE = "Blue-space", TECH_BIO = "Biotech", TECH_COMBAT = "Combat", TECH_MAGNET = "Electromagnetic", TECH_DATA = "Programming", TECH_ESOTERIC = "Esoteric")
				var/list/temp_tech = linked_destroy.loaded_item.origin_tech
				var/list/item_data = list()
				for(var/T in temp_tech)
					var/tech_name = tech_names[T]
					if(!tech_name)
						tech_name = T
					item_data += list(list("id" = T, "name" = tech_name, "level" = temp_tech[T]))

				var/can_spectral = F ? !(linked_destroy.loaded_item.type in F.spectral_analyzed_types) : FALSE
				var/list/destroy_list = list(
					"has_item" =     TRUE,
					"item_name" =    linked_destroy.loaded_item.name,
					"can_spectral" = can_spectral
				)
				destroy_list["tech_data"] = item_data
				data["destroy_data"] = destroy_list
			else
				data["destroy_data"] = list("has_item" = FALSE)

	if(screen == RND_SCREEN_DISK_DESIGNS)
		if(disk)
			var/list/disk_design_files = disk.find_files_by_type(/datum/computer_file/binary/design)
			data["search_text"] = search_text

			var/list/all_disk_categories = list()
			var/obj/machinery/r_n_d/server/S_ddc = get_server()
			if(S_ddc)
				for(var/datum/design/cat_D in S_ddc.get_all_designs())
					if(cat_D.starts_unlocked)
						continue
					if(LAZYLEN(cat_D.category))
						for(var/cat in cat_D.category)
							all_disk_categories |= cat
			data["disk_design_categories"] = all_disk_categories
			data["selected_disk_category"] = selected_disk_category

			var/list/disk_designs = list()
			for(var/f in disk_design_files)
				var/datum/computer_file/binary/design/d_file = f
				if(!d_file.design)
					continue
				if(search_text && !findtext(d_file.design.name, search_text))
					continue
				if(selected_disk_category && LAZYLEN(d_file.design.category) && !(selected_disk_category in d_file.design.category))
					continue
				var/is_hidden = istype(d_file.design, /datum/design/autolathe) && (d_file.design:hidden)
				disk_designs += list(list(
					"name"   = d_file.design.name,
					"id"     = "\ref[d_file]",
					"banned" = (is_hidden || (F && ("[d_file.design.id]" in F.banned_designs))),
				))
			data["disk_designs"] = disk_designs

			var/list/known_designs = list()
			var/obj/machinery/r_n_d/server/S_kd = get_server()
			if(S_kd)
				for(var/datum/design/D in S_kd.get_all_designs())
					if(D.starts_unlocked)
						continue
					if(search_text && !findtext(D.name, search_text))
						continue
					if(selected_disk_category && LAZYLEN(D.category) && !(selected_disk_category in D.category))
						continue
					var/is_hidden = istype(D, /datum/design/autolathe) && (D:hidden)
					known_designs += list(list(
						"name"   = D.name,
						"id"     = "\ref[D]",
						"banned" = (is_hidden || (F && ("[D.id]" in F.banned_designs))),
					))
			data["known_designs"] = known_designs

	if(screen == RND_SCREEN_DISK_TECH)
		if(disk)
			var/list/disk_tech_nodes = list()
			for(var/f in disk.find_files_by_type(/datum/computer_file/binary/design))
				var/datum/computer_file/binary/design/tech_file = f
				disk_tech_nodes += list(list("name" = tech_file.design.name, "id" = "\ref[tech_file]"))
			data["disk_tech_nodes"] = disk_tech_nodes
			var/list/known_nodes = list()
			if(F)
				for(var/i in F.researched_nodes)
					var/datum/technology/T = i
					known_nodes += list(list("name" = T.name, "id" = "\ref[T]"))
			data["known_nodes"] = known_nodes

	if(!lite && (screen == RND_SCREEN_PROTO || screen == RND_SCREEN_IMPRINTER || screen == "robotics_fabricator" || screen == "mech_fabricator"))
		var/obj/machinery/fabricator/rnd/target_device
		var/list/design_categories
		var/selected_category

		if(screen == RND_SCREEN_PROTO && linked_lathe)
			target_device = linked_lathe
			design_categories = F ? F.design_categories_protolathe : list()
			selected_category = selected_protolathe_category
		else if(screen == RND_SCREEN_IMPRINTER && linked_imprinter)
			target_device = linked_imprinter
			design_categories = F ? F.design_categories_imprinter : list()
			selected_category = selected_imprinter_category
		else if(screen == "robotics_fabricator" && istype(src, /datum/nano_module/program/rnd_console/robotics_console))
			var/datum/nano_module/program/rnd_console/robotics_console/RC_RF = src
			target_device = RC_RF.linked_robotics_fab
			selected_category = selected_robotics_category
		else if(screen == "mech_fabricator" && istype(src, /datum/nano_module/program/rnd_console/robotics_console))
			var/datum/nano_module/program/rnd_console/robotics_console/RC_MF = src
			target_device = RC_MF.linked_mech_fab
			selected_category = selected_mech_category

		if(target_device)
			if(!design_categories)
				design_categories = list()
				var/obj/machinery/r_n_d/server/S_dc = get_server()
				if(S_dc)
					for(var/datum/design/D_dc in S_dc.get_all_designs())
						if(D_dc.starts_unlocked)
							continue
						if(!(D_dc.build_type & target_device.build_type))
							continue
						if(LAZYLEN(D_dc.category))
							for(var/cat in D_dc.category)
								design_categories |= cat
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

	if(screen == RND_SCREEN_TREES)
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
			corp_nodes += list(list(
				"id" =          node_id,
				"name" =        tech_node.name,
				"x" =           round(tech_node.x * 100),
				"y" =           round(tech_node.y * 100),
				"icon" =        "[tech_node.icon]",
				"isresearched" = is_researched,
				"canunlock" =   can_unlock
			))
			for(var/req_tech in tech_node.required_technologies)
				var/datum/technology/other_tech = locate(req_tech) in SSresearch.all_tech_nodes
				if(!other_tech || !(other_tech.id in corp_node_set))
					continue
				corp_lines += list(list(
					"line_x" =  (min(round(other_tech.x * 100), round(tech_node.x * 100))),
					"line_y" =  (min(round(other_tech.y * 100), round(tech_node.y * 100))),
					"width" =   (abs(round(other_tech.x * 100) - round(tech_node.x * 100))),
					"height" =  (abs(round(other_tech.y * 100) - round(tech_node.y * 100))),
					"istop" =   (other_tech.y > tech_node.y),
					"isright" = (other_tech.x < tech_node.x)
				))
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
					"name" =         tech_node.name,
					"desc" =         tech_node.desc,
					"price" =        price,
					"isresearched" = is_researched,
					"canunlock" =    can_unlock,
					"can_buy" =      can_unlock
				)
				if(tech_node.required_corp_id)
					var/current_rep  = F ? F.GetCorporationReputation(tech_node.required_corp_id) : 0
					var/required_rep = tech_node.min_reputation
					technology_data["current_reputation"]  = current_rep
					technology_data["required_reputation"] = required_rep
					technology_data["reputation_met"]      = (current_rep >= required_rep)
					technology_data["corp_id"] = get_rnd_mission_corporation_name(tech_node.required_corp_id)

				var/list/requirement_list = list()
				for(var/t in tech_node.required_tech_levels)
					var/datum/tech/tree = F ? (locate(t) in F.researched_tech) : null
					var/level = tech_node.required_tech_levels[t]
					requirement_list += list(list(
						"text" =   "[tree ? tree.shortname : t] level [level]",
						"isgood" = (tree && tree.level >= level)
					))
				for(var/t in tech_node.required_technologies)
					var/datum/technology/other_tech = locate(t) in SSresearch.all_tech_nodes
					if(!other_tech)
						continue
					requirement_list += list(list(
						"text" =   "[other_tech.name]",
						"isgood" = F ? F.IsResearched(other_tech) : FALSE
					))
				technology_data["requirements"] = requirement_list

				var/list/unlock_list = list()
				for(var/T in tech_node.unlocks_designs)
					var/datum/design/D = SSresearch.get_design(T)
					if(D)
						unlock_list += list(list("text" = "[D.shortname]"))
				technology_data["unlocks"] = unlock_list
				data["selected_node"] = technology_data

	if(screen == RND_SCREEN_MISSIONS)
		var/list/mission_list = list()
		for(var/datum/derelict_mission/M in derelict_missions_list)
			var/list/obj_list = list()
			for(var/datum/derelict_mission_objective/O in M.objectives)
				obj_list += list(list(
					"description" = O.description,
					"status" =      O.get_status_text(),
					"completed" =   O.completed
				))
			mission_list += list(list(
				"id" =           M.id,
				"ref" =          "\ref[M]",
				"title" =        M.title,
				"description" =  M.description,
				"corp_name" =    get_rnd_mission_corporation_name(M.corporation_id),
				"site_name" =    M.away_site_name,
				"mission_type" = M.mission_type,
				"state" =        M.state,
				"objectives" =   obj_list
			))
		data["missions"] = mission_list
		data["has_disk"] = !!disk
		if(disk)
			var/list/rdf_files = list()
			for(var/datum/computer_file/data/rdf/rdf_file in disk.stored_files)
				rdf_files += list(list(
					"id" =       "\ref[rdf_file]",
					"filename" = "[rdf_file.filename].[rdf_file.filetype]",
					"scan_area" = (rdf_file.metadata ? rdf_file.metadata["scan_area"] : "???")
				))
			data["rdf_files"] = rdf_files
			var/list/photo_files = list()
			for(var/datum/computer_file/binary/photo/photo_file in disk.stored_files)
				photo_files += list(list(
					"id" =       "\ref[photo_file]",
					"filename" = "[photo_file.filename].[photo_file.filetype]"
				))
			data["photo_files"] = photo_files

	if(screen == RND_SCREEN_CORPS)
		var/list/corporations = get_rnd_mission_corporations()
		var/list/corps_data = list()
		for(var/corp_id in corporations)
			corps_data += list(list(
				"id" =         corp_id,
				"name" =       get_rnd_mission_corporation_name(corp_id),
				"reputation" = F ? F.GetCorporationReputation(corp_id) : 0
			))
		data["corporations"] = corps_data
		data["selected_dialogue_corp_id"] = selected_dialogue_corp_id

		if(selected_dialogue_corp_id)
			var/current_rep = F ? F.GetCorporationReputation(selected_dialogue_corp_id) : 0
			data["selected_corp_dialogue"] = list(
				"name" =             get_rnd_mission_corporation_name(selected_dialogue_corp_id),
				"reputation" =       current_rep,
				"reputation_color" = (current_rep >= 0 ? "#00ff00" : "#ff0000"),
				"info" =             get_rdconsole_corp_info(selected_dialogue_corp_id)
			)

	data["spectral_active"]      = spectral_active
	data["spectral_phase"]       = spectral_phase
	data["spectral_flash"]       = spectral_flash
	data["spectral_result_text"] = spectral_result_text
	if(spectral_active && LAZYLEN(spectral_sequence))
		data["spectral_total"] = LAZYLEN(spectral_sequence)
		data["spectral_index"] = spectral_index

	data["catalog_active"]      = catalog_active
	data["catalog_step"]        = catalog_step
	data["catalog_result_text"] = catalog_result_text
	if(catalog_active && catalog_step >= 1 && catalog_step <= 3)
		data["catalog_step_name"] = get_catalog_step_name(catalog_step)
		data["catalog_step_hint"] = get_catalog_step_hint(catalog_step)

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
		data["report_delta"]     = report_delta
		data["report_value"]     = (report_value * 15)
		data["can_compile"]      = (report_delta > 0)
		data["report_collapsed"] = report_collapsed

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-rdconsole.tmpl", "R&D Console", 1300, 800)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

// ─────────────────────────────────────────────────────────────────────────────
// Clean up defines
// ─────────────────────────────────────────────────────────────────────────────

#undef RND_SCREEN_MAIN
#undef RND_SCREEN_PROTO
#undef RND_SCREEN_IMPRINTER
#undef RND_SCREEN_WORKING
#undef RND_SCREEN_TREES
#undef RND_SCREEN_LOCKED
#undef RND_SCREEN_DISK_DESIGNS
#undef RND_SCREEN_DISK_TECH
#undef RND_SCREEN_MISSIONS
#undef RND_SCREEN_CORPS
