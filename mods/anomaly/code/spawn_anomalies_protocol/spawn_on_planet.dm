/datum/map/build_exoplanets()
	//Игра заспавнит 1 обычную планету и 1 аномальную
	var/list/anomaly_planets_list = list(
		/obj/overmap/visitable/sector/exoplanet/flying = 40,
		/obj/overmap/visitable/sector/exoplanet/ice = 40,
		/obj/overmap/visitable/sector/exoplanet/water = 20
	)
	//Планеты которые сами по себе никогда не заспавнятся
	var/list/shitspawn_planets = list(
	)
	var/spawn_only_anomaly_planet = FALSE
	var/list/all_planets_list = subtypesof(/obj/overmap/visitable/sector/exoplanet)
	//Я не придумал как обьяснять игре какая планета обычная, а какая аномальная без
	//заранее подготовленных списков. Увы.

	if(!use_overmap)
		return
	if(LAZYLEN(anomaly_planets_list))
		LAZYREMOVE(all_planets_list, anomaly_planets_list)
	if(LAZYLEN(shitspawn_planets))
		LAZYREMOVE(all_planets_list, shitspawn_planets)


	if(LAZYLEN(anomaly_planets_list))
		LAZYREMOVE(all_planets_list, anomaly_planets_list)
		var/anomaly_planet_type = pickweight(anomaly_planets_list)
		//Почему тут выставлены world.maxx и world.maxy вместо того чтоб выставить подобные параметры в карте?
		//Потому что я пытался и игра спавнит планеты некорректно. Хотите исправить - убедитесь что ваш вариант реально
		//будет работать.
		var/obj/overmap/visitable/sector/exoplanet/anomaly_new_planet = new anomaly_planet_type(null, world.maxx, world.maxy)
		anomaly_new_planet.build_level()
	if(spawn_only_anomaly_planet)
		return
	for(var/i = 0, i < num_exoplanets, i++)
		var/normal_planet_type = pick(all_planets_list)
		var/obj/overmap/visitable/sector/exoplanet/new_planet = new normal_planet_type(null, world.maxx, world.maxy)
		new_planet.build_level()

/obj/overmap/visitable/sector/exoplanet/proc/generate_anomalies()
	set background = 1
	if(!LAZYLEN(anomalies_types))
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
	generate_anomalies_in_turfs(
		anomalies_types = anomalies_types,
		all_turfs_for_spawn = all_turfs,
		min_anomalies_ammount = min_anomalies_ammount,
		max_anomalies_ammount = max_anomalies_ammount,
		min_artefacts_ammount = min_artefacts_ammount,
		max_artefacts_ammount = max_artefacts_ammount,
		source =  "Планета [name]",
		visible_generation = FALSE)

///Проверяет, что турф находится в играбельной зоне планеты
/proc/turf_in_playable_place(turf/inputed_turf, x_limit, y_limit)
	if(!x_limit || !y_limit || !inputed_turf)
		return TRUE //x и y ограничений нет
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
			picked_anomaly.Destroy()
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
