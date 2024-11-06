//Данный код отвечает за размещение аномалий по всей планете.
/obj/overmap/visitable/sector/exoplanet
	///Спавнятся ли на подобном типе планет аномалии
	var/can_spawn_anomalies = FALSE
	var/list/anomalies_type = list(
		)
	var/min_anomaly_size = 1
	var/max_anomaly_size = 3
	///Минимальное количество заспавненных артов
	var/min_artefacts_ammount = 4
	///Максимальное количество заспавненных артов
	var/max_artefacts_ammount = 8

	var/min_anomalies_ammout = 40
	var/max_anomalies_ammout = 100



/obj/overmap/visitable/sector/exoplanet/proc/generate_anomalies()
	set background = 1
	var/started_in = world.time
	if(!LAZYLEN(anomalies_type))
		return
	var/list/all_turfs = list() //Все турфы на планете
	var/biggest_x = 0
	var/biggest_y = 0
	for(var/turf/choosed_turf in planetary_area)
		if(choosed_turf.x > biggest_x)
			biggest_x = choosed_turf.x
		if(choosed_turf.y > biggest_y)
			biggest_y = choosed_turf.y
	biggest_x -= 9
	biggest_y -= 9
	for(var/turf/choosed_turf in planetary_area)
		//Фильтруем
		//НЕ НУЖНО выходить за пределы планеты
		if(!TurfBlocked(choosed_turf) && !TurfBlockedByAnomaly(choosed_turf) && turf_in_playable_place(choosed_turf, biggest_x, biggest_y))
			LAZYADD(all_turfs, choosed_turf)
	//если каким-то чудом у нас нет хороших турфов
	if(!LAZYLEN(all_turfs))
		log_and_message_admins("ОШИБКА. В результате анализа планеты, код отвечающий за размещение аномалий на планете не нашёл подходящих турфов.")
		CRASH("ОШИБКА. В результате анализа планеты, код отвечающий за размещение аномалий на планете не нашёл подходящих турфов.")
	generate_anomalies_in_turfs(anomalies_type, all_turfs, min_anomalies_ammout, max_anomalies_ammout, min_artefacts_ammount, max_artefacts_ammount, min_anomaly_size, max_anomaly_size, "planet generation protocol", started_in)

///Проверяет, что турф находится в играбельно зоне планеты
/obj/overmap/visitable/sector/exoplanet/proc/turf_in_playable_place(turf/inputed_turf, x_limit, y_limit)
	if(inputed_turf.x < 17)
		return FALSE
	else if(inputed_turf.x > x_limit)
		return FALSE
	else if(inputed_turf.y < 17)
		return FALSE
	else if(inputed_turf.y > y_limit)
		return FALSE
	return TRUE
