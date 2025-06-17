//Аномалия телепортирует к такому же телепортеру, связываясь с ним
/obj/anomaly/doubled_teleporter
	name = "Refractions of light"
	anomaly_tag = "Doubled teleporter"
	with_sound = TRUE
	admin_name = "Телепорт"
	sound_type = 'mods/anomaly/sounds/vspishka_activated.ogg'
	idle_effect_type = "rvach_idle"
	activation_effect_type = "gravy_anomaly_down"
	can_born_artefacts = TRUE
	can_be_preloaded = FALSE
	effect_type = MOMENTUM_ANOMALY_EFFECT
	min_coldown_time = 1 MINUTES
	max_coldown_time = 2 MINUTES
	iniciators = list(
		/mob/living,
		/obj/item
	)
	artefacts = list()
	artefact_spawn_chance = 20
	//Может быть найден лишь гарантированной зоной обнаружения
	chance_to_be_detected = 0
	detection_skill_req = SKILL_EXPERIENCED
	ranzomize_with_initialize = TRUE


	//Второй телепорт к которому присоединён телепортер
	var/obj/anomaly/doubled_teleporter/membered_second_teleporter
	var/distance_between_teleporters = 15
	///Отсовский телепортер, применяется при удалении телепртов
	var/is_father_teleporter = TRUE
	var/spawn_second_teleporter = FALSE
	//Телепортирует ли именно этот телепорт?
	var/teleport_status = TRUE
	var/obj/spawned_visual

//Этот заспавнит своего второго брата
/obj/anomaly/doubled_teleporter/with_second
	spawn_second_teleporter = TRUE

//Этот хоть и спавнит своего брата, но вот его "брат" уже телепортировать не умеет
//Но аномалию поставим, дабы генератор аномалий не ставил чего-то там ещё и турф был безопасен.
/obj/anomaly/doubled_teleporter/with_second/oneway/additional_spawn_action()
	if(spawn_second_teleporter)
		place_second_teleporter()
	var/list/possible_states = list(
		"1&0",
		"0&1"
	)
	var/result_state = pick(possible_states)
	switch(result_state)
		if("1&0")
			teleport_status = TRUE
			membered_second_teleporter.teleport_status = FALSE
		if("0&1")
			teleport_status = FALSE
			membered_second_teleporter.teleport_status = TRUE

/obj/anomaly/doubled_teleporter/do_momentum_animation()
	spawned_visual = new /obj/effect/warp/teleport(get_turf(src))
	addtimer(new Callback(src, PROC_REF(hide_momentum_animation)), 1 SECONDS)

/obj/anomaly/doubled_teleporter/hide_momentum_animation()
	spawned_visual.Destroy()

/obj/effect/warp/teleport
	icon = 'mods/anomaly/icons/effects.dmi'
	icon_state = "teleport"
	pixel_x = 0
	pixel_y = 0

/obj/anomaly/doubled_teleporter/additional_spawn_action()
	if(spawn_second_teleporter)
		place_second_teleporter()

/obj/anomaly/doubled_teleporter/proc/place_second_teleporter()
	var/fail_safe_number = 0
	var/list/possible_turfs = get_area_turfs(get_area(get_turf(src)))
	while(fail_safe_number < 100)
		var/turf/picked_turf = pick(possible_turfs)
		if(get_dist(picked_turf, get_turf(src)) < distance_between_teleporters || TurfBlocked(picked_turf, space_allowed = FALSE) || TurfBlockedByAnomaly(picked_turf))
			LAZYREMOVE(possible_turfs, picked_turf)
			fail_safe_number++
		else
			//Спавним второй телепортет и связываем их между собой
			membered_second_teleporter = new /obj/anomaly/doubled_teleporter(picked_turf)
			membered_second_teleporter.is_father_teleporter = FALSE
			membered_second_teleporter.membered_second_teleporter = src
			SSanom.AddImportantLog("Doubled_teleporter разместил своего собрата на координате : x: [x], y: [y], z: [z] в [round_duration_in_ticks/600]" )
			return

/obj/anomaly/doubled_teleporter/spawn_temp_spawn_effects()
	.=..()
	if(membered_second_teleporter && !membered_second_teleporter.is_father_teleporter)
		membered_second_teleporter.spawn_temp_spawn_effects()


/obj/anomaly/doubled_teleporter/activate_anomaly()
	//шпим
	if(!teleport_status)
		return
	for(var/obj/item/target in get_turf(src))
		get_effect_by_anomaly(target)
	for(var/mob/living/targetbam in get_turf(src))
		get_effect_by_anomaly(targetbam)
	.=..()

/obj/anomaly/doubled_teleporter/get_effect_by_anomaly(atom/movable/target)
	if(ishuman(target) || isitem(target))
		var/turf/brother_turf = get_turf(membered_second_teleporter)
		membered_second_teleporter.handle_after_activation()
		target.forceMove(brother_turf)

/obj/anomaly/doubled_teleporter/delete_anomaly()
	//Удаление уже выполнено, что-то не тааак
	if(anomaly_deleting_operation_completed)
		return
	SSanom.remove_anomaly_from_cores(src)
	if(membered_second_teleporter && is_father_teleporter)
		membered_second_teleporter.Destroy()
	anomaly_deleting_operation_completed = TRUE

/obj/anomaly/rvach/get_detection_icon(mob/living/viewer)
	return "rvach_detection"


//Этот телепортер всё время изменчив, то его брат не телепортирует, то он сам, то они оба, то они вновь оба телепортируют
/obj/anomaly/doubled_teleporter/with_second/changing/additional_spawn_action()
	if(spawn_second_teleporter)
		place_second_teleporter()
	addtimer(new Callback(src, PROC_REF(change_teleportation_state)), rand(5 MINUTES, 10 MINUTES))

/obj/anomaly/doubled_teleporter/with_second/changing/proc/change_teleportation_state()
	/*
	1&1 - оба телепортируют
	0&1 - первый не телепортирует, второй телепортирует
	1&0 - первый телепортирует, второй не телепортирует
	0&0 - оба не телепортируют
	*/
	if(!membered_second_teleporter)
		return
	var/list/possible_states = list(
		"1&1",
		"0&1",
		"1&0",
		"0&0"
	)
	var/state = pick(possible_states)
	switch(state)
		if("1&1")
			teleport_status = TRUE
			membered_second_teleporter.teleport_status = TRUE
		if("0&1")
			teleport_status = FALSE
			membered_second_teleporter.teleport_status = TRUE
		if("1&0")
			teleport_status = TRUE
			membered_second_teleporter.teleport_status = FALSE
		if("0&0")
			teleport_status = FALSE
			membered_second_teleporter.teleport_status = FALSE

	addtimer(new Callback(src, PROC_REF(change_teleportation_state)), rand(5 MINUTES, 10 MINUTES))
