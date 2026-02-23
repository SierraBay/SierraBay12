/datum/computer_file/program/rnd_mission_tracker
	filename = "rnd_missions"
	filedesc = "R&D Mission Tracker"
	extended_desc = "Shows active R&D missions and researched technologies. Use multitool to link with consoles."
	program_icon_state = "generic"
	program_key_state = "generic_key"
	program_menu_icon = "clipboard"
	size = 4
	usage_flags = PROGRAM_ALL
	category = PROG_UTIL
	available_on_ntnet = TRUE
	requires_ntnet = FALSE
	required_access = access_research
	nanomodule_path = /datum/nano_module/program/rnd_mission_tracker

	var/linked_mission_console_id
	var/linked_rdconsole_id

/datum/computer_file/program/rnd_mission_tracker/proc/get_host_atom()
	if(!computer)
		return null
	return computer.get_physical_host()

/datum/computer_file/program/rnd_mission_tracker/proc/link_console(obj/item/device/multitool/M, mob/user)
	if(!M || !M.get_buffer())
		to_chat(user, SPAN_WARNING("Буфер мультитула пуст."))
		return FALSE

	var/atom/buffered = M.get_buffer()

	if(istype(buffered, /obj/machinery/computer/rd_mission_console))
		var/obj/machinery/computer/rd_mission_console/console = buffered
		linked_mission_console_id = "\ref[console]"
		to_chat(user, SPAN_NOTICE("Консоль миссий [console.name] привязана к трекеру."))
		return TRUE

	if(istype(buffered, /obj/machinery/computer/rdconsole))
		var/obj/machinery/computer/rdconsole/console = buffered
		linked_rdconsole_id = "\ref[console]"
		to_chat(user, SPAN_NOTICE("Консоль РнД [console.name] привязана к трекеру."))
		return TRUE

	to_chat(user, SPAN_WARNING("В буфере мультитула нет подходящей консоли."))
	return FALSE

/datum/computer_file/program/rnd_mission_tracker/proc/find_nearest_mission_console()
	if(!linked_mission_console_id)
		return null
	var/obj/machinery/computer/rd_mission_console/console = locate(linked_mission_console_id)
	return console

/datum/computer_file/program/rnd_mission_tracker/proc/find_nearest_rdconsole()
	if(!linked_rdconsole_id)
		return null
	var/obj/machinery/computer/rdconsole/console = locate(linked_rdconsole_id)
	if(console && console.can_research && console.files)
		return console
	return null

/datum/nano_module/program/rnd_mission_tracker
	name = "R&D Mission Tracker"

/datum/nano_module/program/rnd_mission_tracker/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = host.initial_data(program)
	var/datum/computer_file/program/rnd_mission_tracker/PRG = program
	if(!PRG)
		return

	data["linked_mission_console"] = PRG.linked_mission_console_id ? TRUE : FALSE
	data["linked_rdconsole"] = PRG.linked_rdconsole_id ? TRUE : FALSE

	var/obj/machinery/computer/rd_mission_console/mission_console = PRG.find_nearest_mission_console()
	data["has_mission_console"] = !!mission_console

	var/list/active_missions = list()
	if(mission_console && LAZYLEN(mission_console.active_missions))
		for(var/datum/rnd_mission/mission in mission_console.active_missions)
			var/status_text = mission.is_complete() ? "Готово к сдаче" : "В процессе"
			active_missions += list(list(
				"title" = mission.title,
				"corp_name" = get_rnd_mission_corporation_name(mission.corporation_id),
				"status" = status_text,
				"location" = "[mission.target_location_type] [mission.target_area_name]",
				"coords" = mission.target_coords
			))
	data["active_missions"] = active_missions

	var/obj/machinery/computer/rdconsole/rdconsole = PRG.find_nearest_rdconsole()
	data["has_rdconsole"] = !!rdconsole

	var/list/researched_nodes = list()
	if(rdconsole && rdconsole.files)
		for(var/datum/technology/tech_node in rdconsole.files.researched_nodes)
			researched_nodes += list(list(
				"name" = tech_node.name,
				"desc" = tech_node.desc
			))
	data["researched_nodes"] = researched_nodes

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-rnd_mission_tracker.tmpl", "R&D Mission Tracker", 600, 520)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
