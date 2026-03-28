/obj/machinery/drone_pad/rd_mission
	name = "R&D mission drone pad"
	desc = "A specialized landing pad for research drones. Used to submit mission samples and data to corporate receivers. Items must be packaged before submission using a drone designator."
	icon = 'icons/obj/machines/landing_pad.dmi'
	icon_state = "pad_base"
	req_access = list(access_research)
	initial_id_tag = "rd_missions"

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
	// Мультитул для настройки сети
	var/datum/extension/local_network_member/transport = get_extension(src, /datum/extension/local_network_member)
	if (isMultitool(I))
		transport.get_new_tag(user)
		update_icon()
		return TRUE

	// Designator для синхронизации сети (не для отправки предметов)
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

	// Все остальное обрабатывается базовым классом
	return ..()

/obj/machinery/drone_pad/rd_mission/attempt_to_transport(obj/target, mob/user, obj/item/device/drone_designator/designator)
	// Проверяем доступ
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Недостаточно доступа для использования миссионного дрон пада."))
		return FALSE

	// Проверяем, это ли обернутый предмет
	var/obj/item/smallDelivery/package = target
	if(!istype(package))
		to_chat(user, SPAN_WARNING("Для отправки миссионных предметов их нужно сначала упаковать в cargo wrap."))
		return FALSE

	// Проверяем, есть ли что-то внутри упаковки
	if(!package.wrapped || !istype(package.wrapped, /obj/item))
		to_chat(user, SPAN_WARNING("Упаковка пуста или содержит недопустимый предмет."))
		return FALSE

	// Извлекаем предмет из упаковки
	var/obj/item/wrapped_item = package.wrapped

	// Ищем подходящую дереликтовую миссию
	var/datum/derelict_mission/mission = find_derelict_mission_for_item(wrapped_item)
	if(!mission)
		to_chat(user, SPAN_WARNING("Данный предмет не соответствует ни одному активному контракту."))
		return FALSE

	// Проверяем сдачу предмета (проверит пререквизиты)
	if(!mission.try_submit_item(wrapped_item))
		to_chat(user, SPAN_WARNING("Контракт \"[mission.title]\" ещё не готов к сдаче. Выполните все предварительные задачи."))
		return FALSE

	// Успешно! Анимация отправки дрона
	pickup_animation(package)

	// Удаляем упаковку и предмет (отправлено корпорации)
	qdel(wrapped_item)
	qdel(package)

	// Проверяем завершение миссии
	if(mission.check_all_objectives_complete())
		addtimer(new Callback(src, PROC_REF(finalize_mission), mission, user), 5 SECONDS)
		to_chat(user, SPAN_NOTICE("Образец отправлен. Контракт \"[mission.title]\" выполнен! Обработка награды..."))
	else
		to_chat(user, SPAN_NOTICE("Образец отправлен по контракту \"[mission.title]\"."))

	update_rdconsole_uis()
	return TRUE

/obj/machinery/drone_pad/rd_mission/proc/find_nearest_rdconsole()
	var/obj/machinery/computer/rdconsole/nearest = null
	var/best_dist = INFINITY
	for(var/obj/machinery/computer/rdconsole/console in range(7, src))
		var/d = get_dist(src, console)
		if(d < best_dist)
			best_dist = d
			nearest = console
	if(!nearest)
		nearest = locate(/obj/machinery/computer/rdconsole) in world
	return nearest

/obj/machinery/drone_pad/rd_mission/proc/finalize_mission(datum/derelict_mission/mission, mob/living/user)
	if(!mission)
		return FALSE
	if(!mission.check_all_objectives_complete())
		if(user)
			to_chat(user, SPAN_WARNING("Условия контракта ещё не выполнены."))
		return FALSE

	var/obj/machinery/computer/rdconsole/console = find_nearest_rdconsole()
	if(!console || !console.files)
		if(user)
			to_chat(user, SPAN_WARNING("Не найдена РнД консоль для обработки награды."))
		return FALSE

	if(!mission.finalize(console.files))
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
	for(var/obj/machinery/computer/rdconsole/console in range(7, src))
		SSnano.update_uis(console)

/obj/machinery/drone_pad/rd_mission/proc/show_mission_status(mob/living/user)
	if(!LAZYLEN(derelict_missions_list))
		to_chat(user, SPAN_NOTICE("Нет активных корпоративных контрактов."))
		return

	var/has_active = FALSE
	for(var/datum/derelict_mission/M in derelict_missions_list)
		if(M.state == RND_MISSION_STATE_AVAILABLE)
			var/corp_name = get_rnd_mission_corporation_name(M.corporation_id)
			var/obj_status = ""
			for(var/datum/derelict_mission_objective/O in M.objectives)
				obj_status += "\n  - [O.description]: [O.get_status_text()]"
			to_chat(user, SPAN_NOTICE("<b>[M.title]</b> ([corp_name]) — [M.away_site_name][obj_status]"))
			has_active = TRUE
		else if(M.state == RND_MISSION_STATE_REWARDED)
			var/corp_name = get_rnd_mission_corporation_name(M.corporation_id)
			to_chat(user, SPAN_NOTICE("<b>[M.title]</b> ([corp_name]) — <span style='color: #44ff44;'>Выполнен</span>"))

	if(!has_active)
		to_chat(user, SPAN_NOTICE("Все контракты выполнены."))

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
