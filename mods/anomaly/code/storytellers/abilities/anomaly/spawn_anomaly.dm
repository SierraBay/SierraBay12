/datum/storyteller_ability/spawn_anomaly
	ability_name = "Спавн аномалии"
	ability_desc = "Рассказчик размещает в определённом месте аномалию с видимой анимацией."
	var/list/possible_anomalies = list()
	var/spawning_range = 10
	proc_chance = 100	  // Базовый шанс вызова способности (0-100)
	point_price = 50	 // Стоимость в очках
	point_type = "anomaly" // Тип очков (SCAM/ANOMALY/MOB)

//Нам нужен какой угодно атом чтоб определить турф, атомом может быть и турф
/datum/storyteller_ability/spawn_anomaly/execute(atom/input_atom)
	var/turf/spawning_center = get_turf(input_atom)
	var/list/turfs_for_spawn = RANGE_TURFS(spawning_center, spawning_range)
	clean_unplayable_storyteller_zones(turfs_for_spawn, owner.my_area)
	clean_from_unplayable_turfs(turfs_for_spawn)
	var/list/spawned_anomalies = generate_anomalies_in_turfs(
		anomalies_types = possible_anomalies,
		all_turfs_for_spawn = turfs_for_spawn,
		min_anomalies_ammount = 1,
		max_anomalies_ammount = 1,
		min_artefacts_ammount = 0,
		max_artefacts_ammount = 0,
		source = "Действие сторителлера",
		visible_generation = TRUE)
	for(var/obj/anomaly/anom in spawned_anomalies)
		anom.go_sleep(10 SECONDS)
	.=..()

/datum/storyteller_ability/spawn_anomaly/electra
	possible_anomalies = list(
		/obj/anomaly/electra/three_and_three,
		/obj/anomaly/electra/three_and_three/tesla,
		/obj/anomaly/electra/three_and_three/tesla_second,
		/obj/anomaly/cooler/multisize
	)

/datum/storyteller_ability/spawn_anomaly/gravi
	possible_anomalies = list(
		/obj/anomaly/rvach/three_and_three,
		/obj/anomaly/tramplin
	)

/datum/storyteller_ability/spawn_anomaly/water
	possible_anomalies = list(
		/obj/anomaly/doubled_teleporter/with_second,
		/obj/anomaly/doubled_teleporter/with_second/oneway,
		/obj/anomaly/doubled_teleporter/with_second/changing
	)
