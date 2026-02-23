#ifndef RND_MISSION_TYPE_LIVE_CAPTURE
#define RND_MISSION_TYPE_LIVE_CAPTURE 4
#endif

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
	if(try_send_live_capture(user))
		return TRUE
	return transmit_mission_data(user)

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
		// Миссионный дрон пад принимает только упакованные предметы
		to_chat(user, SPAN_WARNING("Для отправки миссионных предметов их нужно сначала упаковать в cargo wrap."))
		return FALSE

	// Проверяем, есть ли что-то внутри упаковки
	if(!package.wrapped || !istype(package.wrapped, /obj/item))
		to_chat(user, SPAN_WARNING("Упаковка пуста или содержит недопустимый предмет."))
		return FALSE

	// Извлекаем предмет из упаковки
	var/obj/item/wrapped_item = package.wrapped

	// Пробуем найти подходящую миссию для этого предмета
	var/datum/rnd_mission/mission = null
	var/list/missions = get_active_missions()
	for(var/datum/rnd_mission/M in missions)
		// Временно извлекаем предмет для проверки
		wrapped_item.forceMove(src.loc)
		if(M.try_submit_item(src, wrapped_item, user))
			mission = M
			break
		// Возвращаем обратно в упаковку если не подошло
		wrapped_item.forceMove(package)

	if(!mission)
		// Предмет не подходит ни для одной миссии
		// Возвращаем его в упаковку
		wrapped_item.forceMove(package)
		to_chat(user, SPAN_WARNING("Данный предмет не соответствует ни одной активной миссии."))
		return FALSE

	// Успешно! Анимация отправки дрона
	pickup_animation(package)

	// Удаляем упаковку и предмет (отправлено корпорации)
	qdel(package)
	qdel(wrapped_item)

	// Проверяем завершение миссии
	if(mission.is_complete())
		// Небольшая задержка перед финализацией для реалистичности
		addtimer(new Callback(src, PROC_REF(finalize_mission), mission, user), 5 SECONDS)
		to_chat(user, SPAN_NOTICE("Миссионный предмет отправлен. Миссия готова к завершению."))
	else
		to_chat(user, SPAN_NOTICE("Миссионный предмет отправлен."))

	update_mission_uis(mission)
	return TRUE

/obj/machinery/drone_pad/rd_mission/proc/get_active_missions()
	var/list/missions = list()
	for(var/obj/machinery/computer/rd_mission_console/console in world)
		if(!LAZYLEN(console.active_missions))
			continue
		for(var/datum/rnd_mission/mission in console.active_missions)
			missions += mission
	return missions

/obj/machinery/drone_pad/rd_mission/proc/find_console_for_mission(datum/rnd_mission/mission)
	if(mission && mission.assigned_console)
		return mission.assigned_console
	for(var/obj/machinery/computer/rd_mission_console/console in world)
		if(mission in console.active_missions)
			return console
	return locate(/obj/machinery/computer/rd_mission_console) in world

/obj/machinery/drone_pad/rd_mission/proc/update_mission_uis(datum/rnd_mission/mission)
	for(var/obj/machinery/computer/rd_mission_console/console in world)
		if(mission in console.active_missions)
			SSnano.update_uis(console)

/obj/machinery/drone_pad/rd_mission/proc/remove_mission_from_consoles(datum/rnd_mission/mission)
	for(var/obj/machinery/computer/rd_mission_console/console in world)
		if(mission in console.active_missions)
			console.remove_active_mission(mission)
			SSnano.update_uis(console)

/obj/machinery/drone_pad/rd_mission/proc/finalize_mission(datum/rnd_mission/mission, mob/living/user)
	if(!mission)
		return FALSE
	if(!mission.is_complete())
		to_chat(user, SPAN_WARNING("Условия задания ещё не выполнены."))
		return FALSE
	var/obj/machinery/computer/rd_mission_console/console = find_console_for_mission(mission)
	if(!console)
		to_chat(user, SPAN_WARNING("Не найдена консоль миссий для выдачи награды."))
		return FALSE
	mission.complete_mission(console, user)
	remove_mission_from_consoles(mission)
	return TRUE

/obj/machinery/drone_pad/rd_mission/proc/try_send_live_capture(mob/living/user)
	var/turf/pad_turf = get_turf(src)
	if(!pad_turf)
		return FALSE
	var/obj/machinery/stasis_cage/cage = locate(/obj/machinery/stasis_cage) in pad_turf
	if(!cage || !cage.contained)
		return FALSE
	if(cage.contained.is_dead())
		to_chat(user, SPAN_WARNING("Образец мертв. Контракт не может быть выполнен."))
		return TRUE

	var/datum/rnd_mission/matched_mission = null
	for(var/datum/rnd_mission/mission in get_active_missions())
		if(mission.mission_type != RND_MISSION_TYPE_LIVE_CAPTURE)
			continue
		if(mission.target_mob == cage.contained)
			matched_mission = mission
			break

	if(!matched_mission)
		return FALSE

	var/choice = alert(user, "Отправить живой образец через миссионный дрон пад?", "Mission Drone Pad", "Отправить", "Отмена")
	if(choice != "Отправить")
		return TRUE

	matched_mission.live_capture_delivered = TRUE
	matched_mission.target_mob = null
	qdel(cage.contained)
	cage.contained = null
	cage.update_icon()
	cage.update_use_power(POWER_USE_IDLE)
	finalize_mission(matched_mission, user)
	return TRUE

/obj/machinery/drone_pad/rd_mission/proc/transmit_mission_data(mob/living/user)
	var/list/missions = get_active_missions()
	if(!length(missions))
		to_chat(user, SPAN_NOTICE("Активных заданий нет."))
		return TRUE

	var/list/choices = list()
	var/index = 1
	for(var/datum/rnd_mission/mission in missions)
		var/status = mission.is_complete() ? "готово" : "в процессе"
		choices["[mission.get_brief()] ([status]) #[index]"] = mission
		index += 1

	var/picked = input(user, "Выберите контракт для отправки", "Mission Drone Pad") as null|anything in choices
	if(!picked || !Adjacent(user))
		return TRUE

	var/datum/rnd_mission/mission = choices[picked]
	if(!mission)
		return TRUE
	if(!mission.is_complete())
		to_chat(user, SPAN_WARNING("Условия задания ещё не выполнены."))
		return TRUE
	finalize_mission(mission, user)
	return TRUE

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
