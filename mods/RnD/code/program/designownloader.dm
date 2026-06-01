/*
NTNet Download Design
=====================
Downloads research designs published on the public R&D server
(/obj/machinery/r_n_d/server/public) to the local hard drive.

Previously this program read from the hardcoded SSresearch.all_designs
autolathe list. Now it connects to the public server, enabling server
admins to curate what designs are available station-wide.

Flow:
  1. RD publishes designs: rdservercontrol screen 4 → "→ Public" button
  2. Crew opens this program on any NTOS computer with NTNet access
  3. Program shows designs from public server, crew downloads to HDD
  4. Designs on HDD can be loaded into protolathe via rnd_console
*/

/datum/computer_file/program/ntnetdesign
	filename = "dsgndownloader"
	filedesc = "Fabricator Design Downloader"
	program_icon_state = "generic"
	program_key_state = "generic_key"
	program_menu_icon = "arrowthickstop-1-s"
	extended_desc = "This program allows downloads of designs from the station's public design repository."
	size = 6
	processing_size = 0.5
	requires_ntnet = TRUE
	requires_ntnet_feature = NTNET_SOFTWAREDOWNLOAD
	nanomodule_path = /datum/nano_module/program/computer_ntnetdesign
	ui_header = "downloader_finished.gif"
	var/datum/computer_file/binary/design/downloaded_file = null
	var/backdoor_access = FALSE
	/// GQ of downloaded data.
	var/download_completion = 0
	var/download_netspeed = 0
	var/downloaderror = ""
	var/list/downloads_queue[0]
	/// For logging.
	var/file_info
	var/server
	var/selected_autolathe_category
	var/show_desc_menu = FALSE
	/// Current search query for filtering designs by name.
	var/search_query = ""
	usage_flags = PROGRAM_ALL
	available_on_ntnet = TRUE
	category = PROG_UTIL
	requires_ntnet = TRUE

// ─── Helpers ────────────────────────────────────────────────────────────────

/// Returns the first operable server with is_public_server = TRUE, or null if none found.
/// Works with any server type — players can reassign the public role via rdservercontrol.
/datum/computer_file/program/ntnetdesign/proc/get_public_server()
	for(var/obj/machinery/r_n_d/server/S in SSmachines.get_machinery_of_type(/obj/machinery/r_n_d/server))
		if(S.is_public_server && S.operable())
			return S
	return null

// ─── Lifecycle ──────────────────────────────────────────────────────────────

/datum/computer_file/program/ntnetdesign/on_shutdown()
	..()
	downloaded_file = null
	download_completion = 0
	download_netspeed = 0
	downloaderror = ""
	ui_header = "downloader_finished.gif"
	search_query = ""

// ─── Download logic ─────────────────────────────────────────────────────────

/// Begin downloading a design from the public server.
/// design_ref — BYOND \ref string pointing to a datum/design on the public server.
/datum/computer_file/program/ntnetdesign/proc/begin_design_download(design_ref)
	if(downloaded_file)
		return FALSE

	var/datum/design/D = locate(design_ref)
	if(!D || !istype(D, /datum/design))
		return FALSE

	// Hidden designs are too dangerous to distribute — block even if ref was obtained externally
	if(!backdoor_access && istype(D, /datum/design/autolathe) && (D:hidden))
		return FALSE

	// Banned designs cannot be downloaded from the public server
	if(!backdoor_access)
		var/obj/machinery/r_n_d/server/pub = get_public_server()
		if(pub && ("[D.id]" in pub.files.banned_designs))
			return FALSE

	// Create a computer file for this design if it doesn't have one yet.
	if(!D.file)
		D.file = new /datum/computer_file/binary/design()
		D.file.design = D
		D.file.filename = sanitizeFileName("[D.id]")
		D.file.filetype = "design"
		D.file.size = 10

	if(!computer || !computer.try_create_file(D.file))
		return FALSE

	ui_header = "downloader_running.gif"
	file_info = "[D.file.filename].[D.file.filetype]"
	server = "Public Design Repository"
	generate_network_log("Began downloading file [file_info] from [server].")
	downloaded_file = D.file.clone()
	return TRUE

/datum/computer_file/program/ntnetdesign/proc/abort_file_download()
	if(!downloaded_file)
		return
	generate_network_log("Aborted download of file [file_info].")
	downloaded_file = null
	download_completion = 0
	ui_header = "downloader_finished.gif"

/datum/computer_file/program/ntnetdesign/proc/complete_file_download()
	if(!downloaded_file)
		return
	generate_network_log("Completed download of file [file_info].")
	if(!computer || !computer.create_file(downloaded_file))
		downloaderror = "I/O ERROR - Unable to save file. Check whether you have enough free space on your hard drive and whether your hard drive is properly connected. If the issue persists contact your system administrator for assistance."
	downloaded_file = null
	download_completion = 0
	ui_header = "downloader_finished.gif"

/datum/computer_file/program/ntnetdesign/process_tick()
	if(!downloaded_file)
		return
	if(download_completion >= downloaded_file.size)
		complete_file_download()
		if(length(downloads_queue) > 0)
			var/next_ref = downloads_queue[1]
			begin_design_download(next_ref)
			downloads_queue.Remove(next_ref)

	download_netspeed = computer.get_ntnet_speed(computer.get_ntnet_status())
	download_completion += download_netspeed

// ─── Topic ──────────────────────────────────────────────────────────────────

/datum/computer_file/program/ntnetdesign/Topic(href, href_list)
	if(..())
		return TOPIC_HANDLED

	if(href_list["PRG_downloadfile"])
		var/design_ref = href_list["PRG_downloadfile"]
		if(!downloaded_file)
			begin_design_download(design_ref)
		else if(!downloads_queue[design_ref])
			var/datum/design/D = locate(design_ref)
			if(!downloaded_file.design || downloaded_file.design != D)
				downloads_queue[design_ref] = TRUE
		return TOPIC_HANDLED

	if(href_list["PRG_removequeued"])
		downloads_queue.Remove(href_list["PRG_removequeued"])
		return TOPIC_HANDLED

	if(href_list["PRG_reseterror"])
		if(downloaderror)
			download_completion = 0
			download_netspeed = 0
			downloaded_file = null
			downloaderror = ""
		return TOPIC_HANDLED

	if(href_list["select_category"])
		selected_autolathe_category = href_list["select_category"]
		return TOPIC_HANDLED

	if(href_list["show_desc_menu"])
		show_desc_menu = !show_desc_menu
		return TOPIC_HANDLED

	if(href_list["PRG_searchdesign"])
		var/query = input(usr, "Enter design name:", "Search", search_query) as text|null
		if(query != null)
			search_query = lowertext(query)
		return TOPIC_HANDLED

	if(href_list["PRG_clearsearch"])
		search_query = ""
		return TOPIC_HANDLED

	if(href_list["PRG_downloadcategory"])
		var/cat = href_list["PRG_downloadcategory"]
		// Autolathe designs
		for(var/datum/design/autolathe/D in SSresearch.all_designs)
			if(!D.build_type)
				continue
			var/dcat = LAZYLEN(D.category) ? D.category[1] : "Unspecified"
			if(dcat != cat)
				continue
			var/dref = "\ref[D]"
			if(!downloaded_file)
				begin_design_download(dref)
			else if(!downloads_queue[dref] && (!downloaded_file.design || downloaded_file.design != D))
				downloads_queue[dref] = TRUE
		// Research designs from public server
		var/obj/machinery/r_n_d/server/public/pub = get_public_server()
		if(pub)
			for(var/datum/design/D in pub.get_all_designs())
				if(D.starts_unlocked || istype(D, /datum/design/autolathe))
					continue
				var/dcat = LAZYLEN(D.category) ? D.category[1] : "Unspecified"
				if(dcat != cat)
					continue
				var/dref = "\ref[D]"
				if(!downloaded_file)
					begin_design_download(dref)
				else if(!downloads_queue[dref] && (!downloaded_file.design || downloaded_file.design != D))
					downloads_queue[dref] = TRUE
		return TOPIC_HANDLED

	return TOPIC_NOACTION

// ─── Nano module ─────────────────────────────────────────────────────────────

/datum/nano_module/program/computer_ntnetdesign
	name = "Network Downloader"

/datum/nano_module/program/computer_ntnetdesign/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/list/data = list()
	var/datum/computer_file/program/ntnetdesign/prog = program
	if(!prog || !istype(prog))
		return
	if(program)
		data = program.get_header_data()

	var/obj/machinery/r_n_d/server/public/pub = prog.get_public_server()
	data["server_online"] = !!pub

	if(prog.downloaderror)
		data["error"] = prog.downloaderror
	if(prog.downloaded_file)
		data["downloadname"] = prog.downloaded_file.filename
		data["downloadsize"] = prog.downloaded_file.size
		data["downloadspeed"] = prog.download_netspeed
		data["downloadcompletion"] = round(prog.download_completion, 0.1)

	data["disk_size"] = program.computer.max_disk_capacity()
	data["disk_used"] = program.computer.used_disk_capacity()
	data["show_desc_menu"] = prog.show_desc_menu
	data["search_query"] = prog.search_query

	if(pub)
		var/list/all_cats = get_category(pub)
		data["all_categories"] = all_cats

		if(!prog.selected_autolathe_category || !(prog.selected_autolathe_category in all_cats))
			prog.selected_autolathe_category = LAZYLEN(all_cats) ? all_cats[1] : null

		if(prog.search_query)
			data["possible_designs"] = get_public_designs_data(pub, null, prog.search_query)
		else if(prog.selected_autolathe_category)
			data["selected_category"] = prog.selected_autolathe_category
			data["possible_designs"] = get_public_designs_data(pub, prog.selected_autolathe_category)
	else
		data["all_categories"] = list()

	if(length(prog.downloads_queue) > 0)
		var/list/queue = list()
		for(var/design_ref in prog.downloads_queue)
			var/datum/design/D = locate(design_ref)
			queue += list(list(
				"path" = design_ref,
				"name" = D ? D.name : design_ref,
			))
		data["downloads_queue"] = queue

	var/list/all_entries[0]
	data["downloadable_programs"] = all_entries

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-ntnetdsgn_downloader.tmpl", "NTNet Download Design", 600, 700, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/// Returns category list from the public server's designs.
/// Respects access_security check for "Arms and Ammunition" unless backdoor_access.
/datum/nano_module/program/computer_ntnetdesign/proc/get_category(obj/machinery/r_n_d/server/public/pub)
	var/list/categories = list()

	for(var/datum/design/D in pub.get_all_designs())
		var/cat = LAZYLEN(D.category) ? D.category[1] : "Unspecified"
		categories |= cat

	var/datum/computer_file/program/ntnetdesign/prog = program
	if(prog && prog.backdoor_access)
		return categories

	// Strip arms/ammo if user lacks security access.
	var/mob/living/carbon/human/H = usr
	if(istype(H))
		var/obj/item/card/id/I = H.GetIdCard()
		if(I && (access_security in I.access))
			return categories
	categories -= "Arms and Ammunition"
	return categories

/// Returns design rows from the public server's designs.
/datum/nano_module/program/computer_ntnetdesign/proc/get_public_designs_data(obj/machinery/r_n_d/server/public/pub, category, search_query)
	var/list/designs_list = list()

	for(var/datum/design/D in pub.get_all_designs())
		var/dname = lowertext(D.shortname || D.name || "")
		if(search_query)
			if(!findtext(dname, search_query))
				continue
		else if(category)
			var/cat = LAZYLEN(D.category) ? D.category[1] : "Unspecified"
			if(cat != category)
				continue
		var/is_hidden = istype(D, /datum/design/autolathe) && (D:hidden)
		designs_list += list(list(
			"design_ref" = "\ref[D]",
			"name"       = D.shortname || D.name,
			"desc"       = D.desc,
			"size"       = D.file ? D.file.size : 2,
			"banned"     = (is_hidden || ("[D.id]" in pub.files.banned_designs)),
		))

	return designs_list

// ─── Hacked variant ──────────────────────────────────────────────────────────

/datum/computer_file/program/ntnetdesign/hacked
	filename = "dsgnfreearch"
	filedesc = "Free Design Archive"
	program_icon_state = "hostile"
	program_key_state = "security_key"
	extended_desc = "This program allows downloads of designs from unofficial and pirate net archives without access check."
	size = 18
	available_on_ntnet = FALSE
	available_on_syndinet = TRUE
	backdoor_access = TRUE
