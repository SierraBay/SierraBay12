#ifndef RND_MISSION_TYPE_LIVE_CAPTURE
#define RND_MISSION_TYPE_LIVE_CAPTURE 4
#endif

/obj/machinery/rd_mission_teleporter
	name = "mission teleporter"
	desc = "Transmits mission samples and data to corporate receivers."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	density = FALSE
	anchored = TRUE
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null
	use_power = POWER_USE_IDLE
	idle_power_usage = 200
	active_power_usage = 2000
	req_access = list(access_research)

/obj/machinery/rd_mission_teleporter/attack_hand(mob/user)
	if(!user || !Adjacent(user))
		return TRUE
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Недостаточно доступа."))
		return TRUE
	if(!is_powered())
		to_chat(user, SPAN_WARNING("Телепортер не получает питание."))
		return TRUE
	if(try_send_live_capture(user))
		return TRUE
	return transmit_mission_data(user)


/obj/machinery/rd_mission_teleporter/use_tool(obj/item/I, mob/living/user, list/click_params)
	.=..()
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Недостаточно доступа."))
		return TRUE
	if(!is_powered())
		to_chat(user, SPAN_WARNING("Телепортер не получает питание."))
		return TRUE
	var/datum/rnd_mission/mission = submit_item_to_missions(I, user)
	if(!mission)
		to_chat(user, SPAN_WARNING("Этот объект не подходит для активных контрактов."))
		return TRUE
	if(mission.is_complete())
		finalize_mission(mission, user)
	return TRUE

/obj/machinery/rd_mission_teleporter/proc/get_active_missions()
	var/list/missions = list()
	for(var/obj/machinery/computer/rd_mission_console/console in world)
		if(!LAZYLEN(console.active_missions))
			continue
		for(var/datum/rnd_mission/mission in console.active_missions)
			missions += mission
	return missions

/obj/machinery/rd_mission_teleporter/proc/submit_item_to_missions(obj/item/I, mob/living/user)
	var/list/missions = get_active_missions()
	for(var/datum/rnd_mission/mission in missions)
		if(mission.try_submit_item(src, I, user))
			update_mission_uis(mission)
			return mission
	return null

/obj/machinery/rd_mission_teleporter/proc/find_console_for_mission(datum/rnd_mission/mission)
	if(mission && mission.assigned_console)
		return mission.assigned_console
	for(var/obj/machinery/computer/rd_mission_console/console in world)
		if(mission in console.active_missions)
			return console
	return locate(/obj/machinery/computer/rd_mission_console) in world

/obj/machinery/rd_mission_teleporter/proc/update_mission_uis(datum/rnd_mission/mission)
	for(var/obj/machinery/computer/rd_mission_console/console in world)
		if(mission in console.active_missions)
			SSnano.update_uis(console)

/obj/machinery/rd_mission_teleporter/proc/remove_mission_from_consoles(datum/rnd_mission/mission)
	for(var/obj/machinery/computer/rd_mission_console/console in world)
		if(mission in console.active_missions)
			console.remove_active_mission(mission)
			SSnano.update_uis(console)

/obj/machinery/rd_mission_teleporter/proc/finalize_mission(datum/rnd_mission/mission, mob/living/user)
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

/obj/machinery/rd_mission_teleporter/proc/try_send_live_capture(mob/living/user)
	var/turf/teleport_turf = get_turf(src)
	if(!teleport_turf)
		return FALSE
	var/obj/machinery/stasis_cage/cage = locate(/obj/machinery/stasis_cage) in teleport_turf
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

	var/choice = alert(user, "Отправить живой образец через миссионный телепортер?", "Mission Teleporter", "Отправить", "Отмена")
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

/obj/machinery/rd_mission_teleporter/proc/transmit_mission_data(mob/living/user)
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

	var/picked = input(user, "Выберите контракт для отправки", "Mission Teleporter") as null|anything in choices
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

/obj/item/stock_parts/circuitboard/rd_mission_teleporter
	name = "circuit board (mission teleporter)"
	build_path = /obj/machinery/rd_mission_teleporter
	board_type = "machine"
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 3, TECH_BLUESPACE = 3)
	req_components = list(
		/obj/item/bluespace_crystal = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/matter_bin = 1
	)
	additional_spawn_components = list(
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/datum/design/circuit/rd_mission_teleporter
	name = "mission teleporter"
	id = "rd_mission_teleporter"
	req_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 3, TECH_BLUESPACE = 3)
	build_path = /obj/item/stock_parts/circuitboard/rd_mission_teleporter
	sort_string = "MAAAM"
