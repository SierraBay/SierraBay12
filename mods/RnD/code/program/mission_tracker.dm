/datum/computer_file/program/rnd_mission_tracker
	filename = "rnd_missions"
	filedesc = "R&D Mission Tracker"
	extended_desc = "Shows active corporate contracts from derelict exploration missions."
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

/datum/nano_module/program/rnd_mission_tracker
	name = "R&D Mission Tracker"

/datum/nano_module/program/rnd_mission_tracker/Topic(href, href_list)
	if(..())
		return TOPIC_HANDLED

	if(href_list["print_missions"])
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

		var/obj/item/paper/P = new(get_turf(program.computer.nano_host()))
		P.SetName("R&D Mission Report")
		P.info = dat
		to_chat(usr, SPAN_NOTICE("Отчёт по миссиям распечатан."))
		return TOPIC_HANDLED

	return TOPIC_NOACTION

/datum/nano_module/program/rnd_mission_tracker/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = host.initial_data(program)

	var/list/mission_list = list()
	if(LAZYLEN(derelict_missions_list))
		for(var/datum/derelict_mission/M in derelict_missions_list)
			var/list/obj_list = list()
			for(var/datum/derelict_mission_objective/O in M.objectives)
				obj_list += list(list(
					"description" = O.description,
					"status" = O.get_status_text(),
					"completed" = O.completed
				))
			var/status_text = "Доступен"
			if(M.state == RND_MISSION_STATE_REWARDED)
				status_text = "Выполнен"
			mission_list += list(list(
				"title" = M.title,
				"corp_name" = get_rnd_mission_corporation_name(M.corporation_id),
				"site_name" = M.away_site_name,
				"mission_type" = M.mission_type == DERELICT_MISSION_COMPLEX ? "Сложный" : "Простой",
				"status" = status_text,
				"state" = M.state,
				"objectives" = obj_list
			))
	data["missions"] = mission_list
	data["has_missions"] = LAZYLEN(derelict_missions_list) > 0

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-rnd_mission_tracker.tmpl", "R&D Mission Tracker", 600, 520)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
