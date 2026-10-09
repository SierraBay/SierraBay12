/datum/computer_file/program/comm/on_startup(mob/living/user, datum/extension/interactive/ntos/new_host)
	nanomodule_path = /datum/nano_module/program/comm/odyssey
	return ..()


/datum/nano_module/program/comm/odyssey
	/// Sector currently opened in the dossier panel.
	var/viewed_sector_id


/datum/nano_module/program/comm/odyssey/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/list/data = host.initial_data(program)
	var/authenticated = check_access(user, admin_access)

	if (program && program.computer)
		data["net_comms"] = program.computer.get_ntnet_capability(NTNET_COMMUNICATION)
		data["net_syscont"] = program.computer.get_ntnet_capability(NTNET_SYSTEMCONTROL)
		data["emagged"] = program.computer.emagged()
		data["have_printer"] = program.computer.has_component(PART_PRINTER)
	else
		data["emagged"] = 0
		data["net_comms"] = 1
		data["net_syscont"] = 1
		data["have_printer"] = 0

	data["message_line1"] = msg_line1
	data["message_line2"] = msg_line2
	data["state"] = current_status
	data["isAI"] = issilicon(usr)
	data["boss_short"] = GLOB.using_map.boss_short
	data["authenticated"] = authenticated

	var/singleton/security_state/security_state = GET_SINGLETON(GLOB.using_map.security_state)
	data["current_security_level_ref"] = any2ref(security_state.current_security_level)
	data["current_security_level_title"] = security_state.current_security_level.name
	data["cannot_change_security_level"] = !security_state.can_change_security_level()
	data["current_security_level_is_high_security_level"] = security_state.current_security_level == security_state.high_security_level
	var/list/security_levels = list()
	for (var/singleton/security_level/security_level in security_state.comm_console_security_levels)
		var/list/security_setup = list()
		security_setup["title"] = security_level.name
		security_setup["ref"] = any2ref(security_level)
		security_levels[LIST_PRE_INC(security_levels)] = security_setup
	data["security_levels"] = security_levels

	var/singleton/comm_message_listener/l = GET_SINGLETON(/singleton/comm_message_listener)
	data["messages"] = l.messages
	if (current_viewing_message)
		data["message_current"] = current_viewing_message

	var/list/processed_evac_options = list()
	if (!isnull(evacuation_controller))
		var/datum/odyssey_state/evac_state = odyssey_ensure_state()
		for (var/datum/evacuation_option/EO in evacuation_controller.available_evac_options())
			// String literals: EVAC_OPT_* macros live in evacuation_pods.dm and are not visible to dreamchecker here.
			if (evac_state.active && (EO.option_target == "bluespace_jump" || EO.option_target == "cancel_bluespace_jump"))
				continue
			var/list/option = list()
			option["option_text"] = EO.option_text
			option["option_target"] = EO.option_target
			option["needs_syscontrol"] = EO.needs_syscontrol
			option["silicon_allowed"] = EO.silicon_allowed
			processed_evac_options[LIST_PRE_INC(processed_evac_options)] = option
	data["evac_options"] = processed_evac_options

	odyssey_append_comm_ui_data(data, user)

	var/width = 550
	var/height = 420
	if (current_status == ODYSSEY_COMM_STATE)
		width = 1200
		height = 820
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (ui)
		ui.set_window_size(width, height)
	else
		ui = new(user, src, ui_key, "mods-odyssey_communication.tmpl", name, width, height, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/datum/nano_module/program/comm/odyssey/proc/odyssey_append_comm_ui_data(list/data, mob/user)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/current_sector = odyssey_get_sector(state.current_sector_id, state)
	if (!viewed_sector_id && state.current_sector_id)
		viewed_sector_id = state.current_sector_id

	data["odyssey_active"] = state.active
	data["odyssey"] = odyssey_build_map_ui_data(viewed_sector_id, data["authenticated"] && !data["isAI"])
	if (islist(current_sector))
		data["odyssey"]["terminal"] = !!current_sector["terminal"]

	var/list/drive_status = odyssey_bluespace_drive_status()
	data["odyssey_drive"] = drive_status
	data["odyssey_course"] = state.selected_sector_id ? odyssey_sector_display_name(state.selected_sector_id) : null


/datum/nano_module/program/comm/odyssey/Topic(href, href_list)
	var/mob/user = usr
	switch (href_list["action"])
		if ("odyssey_inspect")
			var/sector_id = href_list["target"]
			if (odyssey_get_sector(sector_id))
				viewed_sector_id = sector_id
			return TOPIC_REFRESH
		if ("odyssey_select")
			if (!is_authenticated(user) || issilicon(user))
				to_chat(user, SPAN_WARNING("Прокладка курса доступна только командному составу."))
				return TOPIC_HANDLED
			var/sector_id = href_list["target"]
			if (odyssey_select_sector(sector_id, user))
				viewed_sector_id = sector_id
				log_and_message_admins("selected Odyssey destination [sector_id]", user)
				to_world(SPAN_NOTICE("<b>Командование проложило курс Одиссеи: [odyssey_sector_display_name(sector_id)].</b>"))
			else
				to_chat(user, SPAN_WARNING("Этот сектор сейчас недоступен."))
			return TOPIC_REFRESH
		if ("odyssey_drive_jump")
			if (!is_authenticated(user) || issilicon(user))
				to_chat(user, SPAN_WARNING("Запуск блюспейс-прыжка доступен только командному составу."))
				return TOPIC_HANDLED
			var/ntn_cont = (program && program.computer) ? program.computer.get_ntnet_capability(NTNET_SYSTEMCONTROL) : TRUE
			if (!ntn_cont)
				to_chat(user, SPAN_WARNING("Нет доступа к системному контролю."))
				return TOPIC_HANDLED
			var/obj/machinery/bluespace_drive/D = odyssey_find_ship_bluespace_drive()
			if (!istype(D))
				to_chat(user, SPAN_WARNING("Bluespace Drive не найден."))
				return TOPIC_HANDLED
			if (!D.energized)
				to_chat(user, SPAN_WARNING("Привод должен быть energized."))
				return TOPIC_HANDLED
			if (!D.initiate_odyssey_jump(user))
				var/list/status = odyssey_bluespace_drive_status()
				to_chat(user, SPAN_WARNING(status["block_reason"] || "Не удалось запустить блюспейс-прыжок. Проверьте курс, топливо и статус привода."))
			return TOPIC_REFRESH
		if ("odyssey_drive_abort")
			if (!is_authenticated(user) || issilicon(user))
				to_chat(user, SPAN_WARNING("Отмена блюспейс-прыжка доступна только командному составу."))
				return TOPIC_HANDLED
			var/obj/machinery/bluespace_drive/D = odyssey_find_ship_bluespace_drive()
			if (!istype(D))
				to_chat(user, SPAN_WARNING("Bluespace Drive не найден."))
				return TOPIC_HANDLED
			if (D.jump_locked)
				to_chat(user, SPAN_WARNING("Последовательность прыжка заблокирована — слишком поздно."))
				return TOPIC_HANDLED
			if (!D.jumping)
				to_chat(user, SPAN_WARNING("Прыжок не запущен."))
				return TOPIC_HANDLED
			D.abort_jump(user)
			return TOPIC_REFRESH
	return ..()
