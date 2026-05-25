/datum/event/psibreach
	announceWhen	= 30


/datum/event/psibreach/announce()
	priority_announcement.Announce( \
		"ПРИОРИТЕТНОЕ ОПОВЕЩЕНИЕ: Ф-[rand(20,40)] ОБНАРУЖЕН ЛОКАЛЬНЫЙ ВСПЛЕСК ПСИОНИЧЕСКОЙ АКТИВНОСТИ НА [rand(20,60)]% \
		(ИСТОЧНИК СИГНАЛА ТРИАНГУЛИРОВАН — СОСЕДНИЙ МЕСТНЫЙ УЧАСТОК): Всем псионически активным субъектам \
		рекомендуется избегать проявления псионической активности. В случае невозможности сдерживания активности или аномального поведения псиактивных \
		субъектов необходимо задействовать протоколы сдерживания псионической активности.", \
		"Автоматическое сообщение массива датчиков Фонда Кухулин" \
		)



/datum/event/psibreach/start()
	var/turf/start_location
	for(var/i=1 to 100)
		var/turf/T = pick_subarea_turf(/area/hallway, list(GLOBAL_PROC_REF(is_station_turf), GLOBAL_PROC_REF(not_turf_contains_dense_objects)))
		start_location = T
		if(!start_location && i == 100)
			log_and_message_admins("Psionic breach failed to find a viable turf.")
			kill()
			return
		if(start_location)
			break

	log_and_message_admins("Psionic breach spawned in \the [get_area(start_location)]", location = start_location)

	var/list/possible_types = typesof(/obj/psi_plane/psinomaly)
	var/picked_type = pick(possible_types)
	new picked_type(start_location)

	var/list/places_to_spawn = list()
	for(var/turf/T in orange(1, start_location))
		if(istype(T,/turf/space)) continue
		if(T.density) continue
		if(locate(/obj/structure/wall_frame) in T) continue
		places_to_spawn.Add(T)
	if(!LAZYLEN(places_to_spawn))
		places_to_spawn.Add(get_turf(start_location))

	var/mob_path
	var/amount = rand(1,3)

	var/squad = pick("spider", "vagrant")
	switch(squad)
		if("spider")
			mob_path = /mob/living/simple_animal/hostile/giant_spider/psi
		if("vagrant")
			mob_path = /mob/living/simple_animal/hostile/vagrant/psi

	for(var/i = 1 to amount)
		var/turf/spawn_loc = pick(places_to_spawn)
		new mob_path(spawn_loc)
		if(LAZYLEN(places_to_spawn) > 1)
			places_to_spawn -= spawn_loc
