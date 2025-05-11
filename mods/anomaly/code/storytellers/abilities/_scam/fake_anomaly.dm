/datum/storyteller_ability/spawn_fake_anomaly
	ability_name = "Спавн фейковой аномалии"
	ability_desc = "Создаёт аномалию которую видно на детекторе, но империческим путём её не существует."
	proc_chance = 33	  // Базовый шанс вызова способности (0-100)
	point_price = 50	 // Стоимость в очках
	point_type = "scam"
	var/list/possible_fake_anomalies = list()

/datum/storyteller_ability/spawn_fake_anomaly/execute(turf/input_turf)
	var/area/good_area = owner.my_area
	var/list/turfs_for_spawn = RANGE_TURFS(input_turf, 10)
	clean_unplayable_storyteller_zones(turfs_for_spawn, good_area)
	clean_from_unplayable_turfs(turfs_for_spawn)
	if(!LAZYLEN(turfs_for_spawn))
		return FALSE
	var/fake_anomaly_path = pick(possible_fake_anomalies)
	new fake_anomaly_path(pick(turfs_for_spawn))
	. = ..()

/datum/storyteller_ability/spawn_fake_anomaly/electra_ice
	possible_fake_anomalies = list(
		/obj/fake_anomaly/electra,
		/obj/fake_anomaly/unknown_anomaly
	)

/datum/storyteller_ability/spawn_fake_anomaly/gravi
	possible_fake_anomalies = list(
		/obj/fake_anomaly/rvach,
		/obj/fake_anomaly/tramplin,
		/obj/fake_anomaly/unknown_anomaly
	)

/datum/storyteller_ability/spawn_fake_anomaly/water
	possible_fake_anomalies = list(
		/obj/fake_anomaly/unknown_anomaly
	)

//Это ложная аномалия, она никак не влияет на игроков, её задача - улавливаться детектором чтоб запутать
//игрока
/obj/fake_anomaly
	name = "Мираж"
	anchored = TRUE
	invisibility = 60
	icon = 'mods/anomaly/icons/detection_icon.dmi'
	icon_state = "tesla_first_detection"
	var/multitile_range = 0
	var/multitile_parts_type = /obj/fake_anomaly/helper

/obj/fake_anomaly/New(loc, ...)
	. = ..()
	if(multitile_range > 0 || multitile_parts_type)
		deploy_parts()

/obj/fake_anomaly/proc/deploy_parts()
	var/turf/my_turf = get_turf(src)
	var/list/list_of_turfs = RANGE_TURFS(my_turf, multitile_range)
	LAZYREMOVE(list_of_turfs, my_turf)
	for(var/turf/T in list_of_turfs)
		var/obj/fake_anomaly/helper/spawned = new multitile_parts_type(T)
		spawned.fake_core = src

/obj/fake_anomaly/helper
	var/obj/fake_anomaly/fake_core

/obj/fake_anomaly/proc/get_detection_icon()
	return icon_state

/obj/fake_anomaly/helper/get_detection_icon()
	return fake_core.get_detection_icon()

/obj/fake_anomaly/electra
	name = "Электрический мираж"
	icon_state = "tesla_first_detection"
	multitile_range = 1
	multitile_parts_type = /obj/fake_anomaly/helper

/obj/fake_anomaly/electra/get_detection_icon()
	return pick(list("tesla_first_detection", "tesla_second_detection", "electra_detection"))

/obj/fake_anomaly/rvach
	name = "Грави мираж"
	icon_state = "rvach_detection"
	multitile_range = 1
	multitile_parts_type = /obj/fake_anomaly/helper

/obj/fake_anomaly/tramplin
	name = "Грави мираж слабый"
	icon_state = "trampline_detection"

/obj/fake_anomaly/unknown_anomaly
	name = "Нечто"
	icon_state = "any_anomaly"
	multitile_range = 1
	multitile_parts_type = /obj/fake_anomaly/helper
