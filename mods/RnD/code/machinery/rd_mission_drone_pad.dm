/obj/machinery/drone_pad/rd_mission
	name = "R&D mission drone pad"
	desc = "A specialized landing pad for research drones. Used to submit mission samples and data to corporate receivers. Items must be packaged before submission using a drone designator. Use a multitool to set the pad ID, then link it from the R&D console."
	icon = 'icons/obj/machines/landing_pad.dmi'
	icon_state = "pad_base"
	req_access = list(access_research)
	initial_id_tag = "rd_missions"
	/// Numeric ID set via multitool — used by the R&D console to find this pad.
	var/pad_id = 0
	/// The R&D console (machinery or nano_module program) linked to this pad.
	/// Set by the console when a player links via ID entry. Untyped for duck typing.
	var/datum/linked_console = null

/obj/machinery/drone_pad/rd_mission/examine(mob/user)
	. = ..()
	if(pad_id)
		to_chat(user, SPAN_NOTICE("Pad ID: [pad_id]. Используйте R&D консоль для привязки."))
	else
		to_chat(user, SPAN_WARNING("ID не задан. Используйте мультитул для установки ID."))
	if(linked_console && !QDELETED(linked_console))
		to_chat(user, SPAN_NOTICE("Привязан к: [linked_console:name]."))
	else
		to_chat(user, SPAN_WARNING("Не привязан к R&D консоли."))

/obj/machinery/drone_pad/rd_mission/attack_hand(mob/user)
	if(!user || !Adjacent(user))
		return TRUE
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Недостаточно доступа."))
		return TRUE
	if(inoperable())
		to_chat(user, SPAN_WARNING("Дрон пад не получает питание."))
		return TRUE
	if(current_flight)
		to_chat(user, SPAN_WARNING("Дрон пад занят входящей доставкой."))
		return TRUE
	return TRUE

/obj/machinery/drone_pad/rd_mission/use_tool(obj/item/I, mob/living/user, list/click_params)
	// Мультитул — задать pad_id для этого пада
	if(isMultitool(I))
		var/entered_id = input(user, "Введите ID дрон пада (используется R&D консолью для привязки):", "Настройка дрон пада", pad_id) as num|null
		if(isnull(entered_id))
			return TRUE
		entered_id = round(entered_id)
		if(entered_id < 0)
			entered_id = 0
		pad_id = entered_id
		if(pad_id)
			to_chat(user, SPAN_NOTICE("ID дрон пада установлен: [pad_id]."))
		else
			to_chat(user, SPAN_NOTICE("ID дрон пада сброшен."))
		playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1, -3)
		return TRUE

	// Designator для синхронизации сети
	var/datum/extension/local_network_member/transport = get_extension(src, /datum/extension/local_network_member)
	var/obj/item/device/drone_designator/designator = I
	if (istype(designator))
		if (!transport.id_tag)
			to_chat(user, SPAN_WARNING("\The [src] has not yet been set up."))
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 1, -3)
		else if (designator.network == transport.id_tag)
			to_chat(user, SPAN_WARNING("\The [I] is already synchronized with this network."))
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 1, -3)
		else
			to_chat(user, SPAN_NOTICE("\The [I] was synchronized with the [transport.id_tag] network."))
			designator.network = transport.id_tag
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1, -3)
		update_icon()
		return TRUE

	return ..()

/obj/machinery/drone_pad/rd_mission/attempt_to_transport(obj/target, mob/user, obj/item/device/drone_designator/designator)
	if(!linked_console || QDELETED(linked_console))
		to_chat(user, SPAN_WARNING("Дрон пад не привязан к R&D консоли. Привяжите через консоль перед отправкой."))
		return FALSE

	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Недостаточно доступа для использования миссионного дрон пада."))
		return FALSE

	var/obj/item/smallDelivery/package = target
	if(!istype(package))
		to_chat(user, SPAN_WARNING("Для отправки миссионных предметов их нужно сначала упаковать в cargo wrap."))
		return FALSE

	if(!package.wrapped || !istype(package.wrapped, /obj/item))
		to_chat(user, SPAN_WARNING("Упаковка пуста или содержит недопустимый предмет."))
		return FALSE

	var/obj/item/wrapped_item = package.wrapped

	var/datum/derelict_mission/mission = find_derelict_mission_for_item(wrapped_item)
	if(!mission)
		to_chat(user, SPAN_WARNING("Данный предмет не соответствует ни одному активному контракту."))
		return FALSE

	if(!mission.try_submit_item(wrapped_item))
		to_chat(user, SPAN_WARNING("Контракт \"[mission.title]\" ещё не готов к сдаче. Выполните все предварительные задачи."))
		return FALSE

	pickup_animation(package)
	qdel(wrapped_item)
	qdel(package)

	if(mission.check_all_objectives_complete())
		addtimer(new Callback(src, PROC_REF(finalize_mission), mission, user), 5 SECONDS)
		to_chat(user, SPAN_NOTICE("Образец отправлен. Контракт \"[mission.title]\" выполнен! Обработка награды..."))
	else
		to_chat(user, SPAN_NOTICE("Образец отправлен по контракту \"[mission.title]\"."))

	update_rdconsole_uis()
	return TRUE

/obj/machinery/drone_pad/rd_mission/proc/finalize_mission(datum/derelict_mission/mission, mob/living/user)
	if(!mission)
		return FALSE
	if(!mission.check_all_objectives_complete())
		if(user)
			to_chat(user, SPAN_WARNING("Условия контракта ещё не выполнены."))
		return FALSE

	if(!linked_console || QDELETED(linked_console))
		if(user)
			to_chat(user, SPAN_WARNING("Дрон пад не привязан к R&D консоли. Привяжите через консоль."))
		return FALSE

	var/datum/research/console_files = linked_console:get_server_files()
	if(!console_files)
		if(user)
			to_chat(user, SPAN_WARNING("R&D консоль не подключена к серверу."))
		return FALSE

	if(!mission.finalize(console_files))
		if(user)
			to_chat(user, SPAN_WARNING("Не удалось обработать награду контракта."))
		return FALSE

	var/corp_name = get_rnd_mission_corporation_name(mission.corporation_id)
	if(user)
		to_chat(user, SPAN_NOTICE("Контракт \"[mission.title]\" завершён! Корпорация [corp_name] разблокировала технологии."))
	visible_message(SPAN_NOTICE("[src] издаёт подтверждающий сигнал. Контракт с [corp_name] успешно закрыт."))
	playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
	update_rdconsole_uis()
	return TRUE

/obj/machinery/drone_pad/rd_mission/proc/update_rdconsole_uis()
	if(linked_console && !QDELETED(linked_console))
		SSnano.update_uis(linked_console)

/obj/item/stock_parts/circuitboard/rd_mission_drone_pad
	name = "circuit board (R&D mission drone pad)"
	build_path = /obj/machinery/drone_pad/rd_mission
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3)
	req_components = list(
		/obj/item/stock_parts/scanning_module = 4,
		/obj/item/bluespace_crystal = 1
	)
	additional_spawn_components = list(
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/datum/design/circuit/rd_mission_drone_pad
	name = "R&D mission drone pad"
	id = "rd_mission_drone_pad"
	req_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3, TECH_BLUESPACE = 2)
	build_path = /obj/item/stock_parts/circuitboard/rd_mission_drone_pad
	sort_string = "MAAAN"
