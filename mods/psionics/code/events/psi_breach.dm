/datum/event/psibreach
	announceWhen	= 180


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
	new /obj/psi_plane/psinomaly(start_location)
