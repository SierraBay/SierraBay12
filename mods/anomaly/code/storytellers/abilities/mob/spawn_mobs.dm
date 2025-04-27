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
	var/list/possible_victims = list()
	for(var/mob/living/carbon/human/human in GLOB.living_players)
		if(get_z(human) in owner.my_z)
			LAZYADD(possible_victims, human)
	//Очистка от невалидной зоны
	for(var/turf/T in turfs_for_spawn)
		if(T.loc != good_area)
			LAZYREMOVE(turfs_for_spawn, src)

	var/list/unseen_turfs = list()
	//Основной цикл поиска хороших турфов
	for(var/turf/T in turfs_for_spawn)
		var/failed = FALSE
		var/list/temp_list = oviewers(10, T)
		for(var/atom/I in possible_victims)
			if(I in temp_list)
				failed = TRUE
			else if(get_turf(I) == T)
				failed = TRUE
		if(failed)
			continue
		if(!TurfBlocked(loc = T, space_allowed = FALSE))
			LAZYADD(unseen_turfs, T)
	var/result_spawn_ammout
	if(min_ammout && max_ammout)
		result_spawn_ammout = rand(min_ammout, max_ammout)
	else
		result_spawn_ammout = mobs_ammout
	if(!result_spawn_ammout || !LAZYLEN(unseen_turfs))
		CRASH("Некорректные результаты расчётов у спавна мобов рассказчика.")
	while(LAZYLEN(unseen_turfs) && result_spawn_ammout)
		var/turf/temp_spawn_turf = pick(unseen_turfs)
		var/spawn_mob_type = pick(possible_mobs)
		new spawn_mob_type(temp_spawn_turf)
		result_spawn_ammout--
		LAZYREMOVE(unseen_turfs, temp_spawn_turf)
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
