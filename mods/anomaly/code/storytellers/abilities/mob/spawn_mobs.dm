/datum/storyteller_ability/spawn_mobs
	ability_name = "Спавн мобья"
	ability_desc = "Рассказчик размещает за полем зрения игроков мобиков и натравливает на местоположение игроков."
	var/list/possible_mobs = list(
		/mob/living/simple_animal/hostile/retaliate/beast/shantak
	)
	var/mobs_ammout = 3
	var/min_ammout
	var/max_ammout
	var/spawning_range = 10
	proc_chance = 100	  // Базовый шанс вызова способности (0-100)
	point_price = 50	 // Стоимость в очках
	point_type = "mob" // Тип очков (SCAM/ANOMALY/MOB)

/datum/storyteller_ability/spawn_mobs/execute(atom/input_atom)
	var/turf/spawning_center = get_turf(input_atom)
	var/area/good_area = owner.my_area
	var/list/turfs_for_spawn = RANGE_TURFS(spawning_center, spawning_range)
	var/list/possible_victims = collect_possible_victims_classic()
	clean_unplayable_storyteller_zones(turfs_for_spawn, good_area)
	clean_from_unplayable_turfs(turfs_for_spawn)
	clean_from_visibled_turfs(turfs_for_spawn, possible_victims)
	var/result_spawn_ammout
	if(min_ammout && max_ammout)
		result_spawn_ammout = rand(min_ammout, max_ammout)
	else
		result_spawn_ammout = mobs_ammout
	if(!result_spawn_ammout || !LAZYLEN(turfs_for_spawn))
		CRASH("Некорректные результаты расчётов у спавна мобов рассказчика.")
	while(LAZYLEN(turfs_for_spawn) && result_spawn_ammout)
		var/turf/temp_spawn_turf = pick(turfs_for_spawn)
		var/spawn_mob_type = pick(possible_mobs)
		new spawn_mob_type(temp_spawn_turf)
		result_spawn_ammout--
		LAZYREMOVE(turfs_for_spawn, temp_spawn_turf)
	return TRUE


/datum/storyteller_ability/spawn_mobs/ice
	possible_mobs = list(
		/mob/living/simple_animal/hostile/electra_wolf
	)

/datum/storyteller_ability/spawn_mobs/gravi
	possible_mobs = list(
		/mob/living/simple_animal/hostile/scarybat,
		/mob/living/simple_animal/hostile/scarybat/cult/strong
	)

/datum/storyteller_ability/spawn_mobs/water
	possible_mobs = list(
		/mob/living/simple_animal/hostile/titan_crab
	)
