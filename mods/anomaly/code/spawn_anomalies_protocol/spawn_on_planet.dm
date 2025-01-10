/datum/map/build_exoplanets()
	//Игра заспавнит 1 обычную планету и 1 аномальную
	var/list/anomaly_planets_list = list(
		/obj/overmap/visitable/sector/exoplanet/ice,
		/obj/overmap/visitable/sector/exoplanet/flying
	)
	var/list/all_planets_list = subtypesof(/obj/overmap/visitable/sector/exoplanet)
	//Я не придумал как обьяснять игре какая планета обычная, а какая аномальная без
	//заранее подготовленных списков. Увы.
	if(!use_overmap)
		return

	for(var/i = 0, i < num_exoplanets, i++)
		var/normal_planet_type = pick(all_planets_list)
		var/obj/overmap/visitable/sector/exoplanet/new_planet = new normal_planet_type(null, world.maxx, world.maxy)
		new_planet.build_level()
	if(LAZYLEN(anomaly_planets_list))
		LAZYREMOVE(all_planets_list, anomaly_planets_list)
		var/anomaly_planet_type = pick(anomaly_planets_list)
		var/obj/overmap/visitable/sector/exoplanet/anomaly_new_planet = new anomaly_planet_type(null, world.maxx, world.maxy)
		anomaly_new_planet.build_level()

//Данный код отвечает за размещение аномалий по всей планете.
/obj/overmap/visitable/sector/exoplanet
	///Спавнятся ли на подобном типе планет аномалии
	var/can_spawn_anomalies = FALSE
	var/list/anomalies_type = list(
		)
	var/obj/weather/monitor_effect_type
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

/obj/overmap/visitable/sector/exoplanet/proc/full_clear_from_anomalies()//Функция очищает планету от аномалий и аномальных больших артефактов
	set waitfor = FALSE
	var/deleted_anomalies = 0
	var/deleted_big_artefacts = 0
	var/list/planet_turfs = get_area_turfs(planetary_area)
	for(var/obj/anomaly/picked_anomaly in SSanom.all_anomalies_cores)
		if(!picked_anomaly.is_helper && planet_turfs.Find(get_turf(picked_anomaly)))
			picked_anomaly.delete_anomaly()
			deleted_anomalies++
	for(var/obj/structure/big_artefact/picked_big_artefact in SSanom.big_anomaly_artefacts)
		if(planet_turfs.Find(get_turf(picked_big_artefact)))
			qdel(picked_big_artefact)
			deleted_big_artefacts++
	report_progress("Выполнена очистка планеты [name]. Удалено аномалий: [deleted_anomalies]. Удалено больших артефактов: [deleted_big_artefacts].  ")




///Задача ивента - сменить скайбокс Z уровня любой ценой
/datum/event/change_z_skybox
	startWhen		= 30	// About one minute early warning
	endWhen 		= 999 HOURS	// Adjusted automatically in tick()
	has_skybox_image = TRUE
	var/skybox_type = 'icons/skybox/rockbox.dmi'
	var/skybox_icon_state = "rockbox"

/datum/event/change_z_skybox/get_skybox_image()
	var/image/res = overlay_image(skybox_type, skybox_icon_state, COLOR_ASTEROID_ROCK, RESET_COLOR)
	res.blend_mode = BLEND_OVERLAY
	return res

/datum/event/change_z_skybox/setup(input_skybox_type, input_skybox_icon_state)
	if(input_skybox_type)
		skybox_type = input_skybox_type
	if(input_skybox_icon_state)
		skybox_icon_state = input_skybox_icon_state
