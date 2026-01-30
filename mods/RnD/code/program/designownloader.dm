/datum/computer_file/program/ntnetdesign
	filename = "dsgndownloader"
	filedesc = "Fabricator Design Downloader"
	program_icon_state = "generic"
	program_key_state = "generic_key"
	program_menu_icon = "arrowthickstop-1-s"
	extended_desc = "This program allows downloads of desings from official repositories"
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
	/// For logging, can be faked by antags.
	var/file_info
	var/server
	var/selected_autolathe_category
	var/show_desc_menu = FALSE
	usage_flags = PROGRAM_ALL
	size = 6
	available_on_ntnet = TRUE
	category = PROG_UTIL
	requires_ntnet = TRUE

/datum/computer_file/program/ntnetdesign/on_shutdown()
	..()
	downloaded_file = null
	download_completion = 0
	download_netspeed = 0
	downloaderror = ""
	ui_header = "downloader_finished.gif"

/datum/computer_file/program/ntnetdesign/proc/begin_file_download(build_path, skill)
	if(downloaded_file)
		return FALSE

	var/datum/design/autolathe/design = SSresearch.get_autolathe_design_by_build_path(build_path)

	var/datum/computer_file/binary/design/design_file = design.file

	if(!design_file)
		return

	if(!computer || !computer.try_create_file(design_file))
		return

	ui_header = "downloader_running.gif"
	file_info ="[design.file.filename].[design.file.filetype]"
	server = "Fabricator Design Repository"
	generate_network_log("Began downloading file [file_info] from [server].")
	downloaded_file = design_file.clone()

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
		// The download failed
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
			begin_file_download(downloads_queue[1], downloads_queue[downloads_queue[1]])
			downloads_queue.Remove(downloads_queue[1])

	// Download speed according to connectivity state. NTNet server is assumed to be on unlimited speed so we're limited by our local connectivity
	download_netspeed = computer.get_ntnet_speed(computer.get_ntnet_status())
	download_completion += download_netspeed

/datum/computer_file/program/ntnetdesign/Topic(href, href_list)
	if(..())
		return TOPIC_HANDLED
	if(href_list["PRG_downloadfile"])
		if(!downloaded_file)
			begin_file_download(href_list["PRG_downloadfile"], usr.get_skill_value(SKILL_COMPUTER))
		else if(!downloads_queue.Find(href_list["PRG_downloadfile"]) && downloaded_file.filename != href_list["PRG_downloadfile"])
			downloads_queue[href_list["PRG_downloadfile"]] = usr.get_skill_value(SKILL_COMPUTER)
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
		var/what_cat = href_list["select_category"]
		selected_autolathe_category = what_cat
		return TOPIC_HANDLED
	if(href_list["show_desc_menu"])
		show_desc_menu = !show_desc_menu
		return TOPIC_HANDLED
	return TOPIC_NOACTION

/datum/nano_module/program/computer_ntnetdesign
	name = "Network Downloader"
	var/lastusr

/datum/nano_module/program/computer_ntnetdesign/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/list/data = list()
	var/datum/computer_file/program/ntnetdesign/prog = program
	// For now limited to execution by the downloader program
	if(!prog || !istype(prog))
		return
	if(program)
		data = program.get_header_data()

	// This IF cuts on data transferred to client, so i guess it's worth it.
	if(prog.downloaderror) // Download errored. Wait until user resets the program.
		data["error"] = prog.downloaderror
	if(prog.downloaded_file) // Download running. Wait please..
		data["downloadname"] = prog.downloaded_file.filename
		//data["downloaddesc"] = prog.downloaded_file.filedesc
		data["downloadsize"] = prog.downloaded_file.size
		data["downloadspeed"] = prog.download_netspeed
		data["downloadcompletion"] = round(prog.download_completion, 0.1)

	data["disk_size"] = program.computer.max_disk_capacity()
	data["disk_used"] = program.computer.used_disk_capacity()
	data["all_categories"] = get_category()
	data["show_desc_menu"] = prog.show_desc_menu

	if((!prog.selected_autolathe_category || !(prog.selected_autolathe_category in data["all_categories"])) && LAZYLEN(SSresearch.design_categories_autolathe))
		prog.selected_autolathe_category = SSresearch.design_categories_autolathe[2]

	if(prog.selected_autolathe_category)
		data["selected_category"] = prog.selected_autolathe_category
		data["possible_designs"] = get_autolathe_designs_data(prog.selected_autolathe_category)

	var/list/all_entries[0]
	data["downloadable_programs"] = all_entries

	if(length(prog.downloads_queue) > 0)
		var/list/queue = list() // Nanoui can't iterate through assotiative lists, so we have to do this
		for(var/item in prog.downloads_queue)
			queue += item
		data["downloads_queue"] = queue

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mods-ntnetdsgn_downloader.tmpl", "NTNet Download Design", 600, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/program/computer_ntnetdesign/proc/get_category()
	var/list/categories = list()
	var/list/all_cat = SSresearch.design_categories_autolathe
	var/datum/computer_file/program/ntnetdesign/prog = program
	if(usr)
		lastusr = usr
	if(!lastusr)
		return all_cat
	var/mob/living/carbon/human/H = lastusr
	var/obj/item/card/id/I = H.GetIdCard()
	if(!prog.backdoor_access)
		if(!I)
			categories = all_cat + list("Arms and Ammunition")
			return categories
		if(!(access_security in I.access))
			categories = all_cat - list("Arms and Ammunition")
			return categories
	return all_cat



/datum/nano_module/program/computer_ntnetdesign/proc/get_autolathe_designs_data(category)
	var/list/designs_list = list()
	for(var/datum/design/autolathe/D in SSresearch.all_designs)
		if(D.build_type)
			var/cat = "Unspecified"
			if(D.category)
				cat = D.category
			if(category in cat)
				designs_list += list(list(
					"build_path" =     D.build_path,
					"name" =           D.shortname,
					"desc" =           D.desc,
					"size" =           D.file.size,
					"materials" =      D.materials,
				))
	return designs_list

/datum/computer_file/program/ntnetdesign/hacked
	filename = "dsgnfreearch"
	filedesc = "Free Design Archive"
	program_icon_state = "hostile"
	program_key_state = "security_key"
	extended_desc = "This program allows downloads of desings from unofficial and pirate net archives without access check."
	size = 18
	available_on_ntnet = FALSE
	available_on_syndinet = TRUE
	backdoor_access = TRUE
