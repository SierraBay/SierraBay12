/datum/computer_file/program/autolathe_monitor
	filename = "fabmon"
	filedesc = "Fabricator Telemetry"
	nanomodule_path = /datum/nano_module/program/autolathe_monitor
	program_icon_state = "generic"
	program_key_state = "generic_key"
	program_menu_icon = "gear"
	extended_desc = "Lists fabricators on the ship network and pulls their local print journals for audit. Supports paper and disk dumps for investigations."
	size = 8
	requires_ntnet = TRUE
	required_access = access_network
	network_destination = "fabricator telemetry array"
	available_on_ntnet = TRUE
	category = PROG_ENG


/datum/nano_module/program/autolathe_monitor
	name = "Fabricator Telemetry"
	available_to_ai = TRUE
	var/obj/machinery/fabricator/active


/datum/nano_module/program/autolathe_monitor/Destroy()
	active = null
	return ..()


/datum/nano_module/program/autolathe_monitor/proc/list_visible_fabricators()
	var/list/out = list()
	var/valid_z = GetConnectedZlevels(get_host_z())
	for (var/obj/machinery/fabricator/F as anything in SSmachines.get_machinery_of_type(/obj/machinery/fabricator))
		if (!istype(F) || !isturf(F.loc))
			continue
		if (!(F.z in valid_z))
			continue
		out += F
	return out


/datum/nano_module/program/autolathe_monitor/proc/format_active_log_text()
	if (!istype(active))
		return ""
	var/area/A = get_area(active)
	var/list/lines = list()
	lines += "<b>Fabricator journal dump</b><br>"
	lines += "Machine: [active.name]<br>"
	lines += "Area: [A ? A.name : "Unknown"]<br>"
	lines += "Status: [active.print_log_status_label()]<br>"
	lines += "Telemetry: [active.print_log_network ? "online" : "offline"]<br>"
	if (active.print_log_corrupt)
		lines += "<i>Journal flagged damaged / wiped.</i><br>"
	lines += "Dump time: [stationdate2text()] [stationtime2text()]<br><hr>"
	var/list/entries = active.print_log_ui_entries()
	if (!length(entries))
		lines += "<i>No entries.</i>"
	else
		for (var/list/entry in entries)
			if (!islist(entry))
				continue
			lines += "<b>[entry["item"]]</b><br>"
			lines += "[entry["user"]]<br>"
			lines += "<font size=1>[entry["at"]] · [entry["materials"]]</font><br><br>"
	return jointext(lines, "")


/datum/nano_module/program/autolathe_monitor/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/list/data = host.initial_data(program)

	if (istype(active))
		if (!active.is_print_log_remote_visible())
			active = null
		else
			var/area/A = get_area(active)
			data["active"] = TRUE
			data["active_name"] = active.name
			data["active_area"] = A ? A.name : "Unknown"
			data["active_status"] = active.print_log_status_label()
			data["active_corrupt"] = active.print_log_corrupt
			data["active_network"] = active.print_log_network
			data["active_log"] = active.print_log_ui_entries()
			data["materials"] = list()
			for (var/mat in active.stored_material)
				data["materials"] += list(list(
					"name" = "[mat]",
					"amount" = round(active.stored_material[mat])
				))

	if (!data["active"])
		var/list/rows = list()
		for (var/obj/machinery/fabricator/F in list_visible_fabricators())
			var/area/Ar = get_area(F)
			var/remote_ok = F.is_print_log_remote_visible()
			rows += list(list(
				"ref" = "\ref[F]",
				"name" = F.name,
				"area" = Ar ? Ar.name : "Unknown",
				"status" = F.print_log_status_label(),
				"online" = remote_ok,
				"entries" = length(F.print_log)
			))
		data["fabricators"] = rows

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mods-autolathe_monitor.tmpl", "Fabricator Telemetry", 640, 700, state = state)
		if (host.update_layout())
			ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/datum/nano_module/program/autolathe_monitor/Topic(href, href_list, state)
	if (..())
		return TOPIC_HANDLED
	if (href_list["refresh"])
		return TOPIC_REFRESH
	if (href_list["clear"])
		active = null
		return TOPIC_REFRESH
	if (href_list["select"])
		var/obj/machinery/fabricator/F = locate(href_list["select"])
		if (!istype(F) || !(F in list_visible_fabricators()))
			return TOPIC_HANDLED
		if (!F.is_print_log_remote_visible())
			to_chat(usr, SPAN_WARNING("Telemetry from \the [F] is unavailable."))
			return TOPIC_HANDLED
		active = F
		return TOPIC_REFRESH
	if (href_list["print_log"])
		if (!istype(active) || !active.is_print_log_remote_visible())
			to_chat(usr, SPAN_WARNING("Нет активного журнала для печати."))
			return TOPIC_HANDLED
		if (!program?.computer)
			return TOPIC_HANDLED
		var/title = "Fabricator journal — [active.name] — [stationtime2text()]"
		if (!program.computer.print_paper(format_active_log_text(), title))
			to_chat(usr, SPAN_WARNING("Печать не удалась — проверьте nano-printer и бумагу."))
			return TOPIC_HANDLED
		to_chat(usr, SPAN_NOTICE("Журнал отправлен на печать."))
		return TOPIC_REFRESH
	if (href_list["save_log"])
		if (!istype(active) || !active.is_print_log_remote_visible())
			to_chat(usr, SPAN_WARNING("Нет активного журнала для сохранения."))
			return TOPIC_HANDLED
		if (!program?.computer)
			return TOPIC_HANDLED
		var/mob/living/user = usr
		var/filename = input(user, "Имя файла (.LOG) или пусто для отмены:", "Сохранить журнал", "fab-[sanitize(active.name)]") as text|null
		if (!filename || !istype(active))
			return TOPIC_HANDLED
		filename = sanitize(filename)
		if (!length(filename))
			return TOPIC_HANDLED
		var/area/A = get_area(active)
		var/content = "Logfile dump from fabricator [active.name]\[BR\]"
		content += "Area: [A ? A.name : "Unknown"]\[BR\]"
		content += "Status: [active.print_log_status_label()]\[BR\]"
		content += "Dump: [stationdate2text()] [stationtime2text()]\[BR\]\[BR\]"
		for (var/list/entry in active.print_log_ui_entries())
			if (!islist(entry))
				continue
			content += "[entry["at"]] | [entry["user"]] | [entry["item"]] | [entry["materials"]]\[BR\]"
		if (!program.computer.create_data_file(filename, content, /datum/computer_file/data/logfile))
			to_chat(usr, SPAN_WARNING("I/O Error — проверьте жёсткий диск и свободное место."))
			return TOPIC_HANDLED
		to_chat(usr, SPAN_NOTICE("Журнал сохранён как [filename].LOG."))
		return TOPIC_REFRESH
	return TOPIC_NOACTION
