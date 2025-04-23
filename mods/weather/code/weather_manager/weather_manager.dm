///Менеджер/контроллер управляет всей погодой что привязана к нему
/datum/weather_manager
	var/weather_turf_type
	var/list/connected_weather_turfs = list()
	//Время смены
	var/change_time
	var/blowout_time
	var/list/stages = list()
	var/current_stage
	var/area/my_area
	var/list/my_z
	//Выброс
	var/can_blowout = FALSE
	//Игрокам в зоне выброса сообщают о нём.
	var/must_message_about_blowout = TRUE
	var/blowout_change_stage
	var/delay_between_message_and_blowout
	var/list/blowout_prepare_messages = list()
	var/list/blowout_messages = list()
	var/activity_blocked_by_safe_protocol = FALSE

/datum/weather_manager/New(area/input_area)
	my_area = input_area
	calculate_change_time()
	calculate_blowout_time()
	calculate_next_safe_blowout()
	calculate_next_safe_change()
	calculate_affected_z()
	LAZYADD(SSweather.weather_managers_in_world, src)
	START_PROCESSING(SSweather, src)

/datum/weather_manager/Process()
	..()
	if(activity_blocked_by_safe_protocol)
		return
	if(world.time >= change_time)
		change_stage()
	if(can_blowout && world.time  >= blowout_time)
		start_blowout()

/datum/weather_manager/proc/change_stage()
	set waitfor = FALSE
	set background = TRUE
	if(activity_blocked_by_safe_protocol || !check_change_safety())
		return
	var/need_change = FALSE
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		if(get_z(picked_human) == get_z(pick(connected_weather_turfs)))
			need_change = TRUE
			break
	if(!need_change)
		return FALSE
	for(var/obj/weather/connected_weather in connected_weather_turfs)
		connected_weather.update()
	calculate_change_time()
	return TRUE

/datum/weather_manager/proc/start_blowout()
	set waitfor = FALSE
	set background = TRUE
	if(activity_blocked_by_safe_protocol || !check_blowout_safety()) //Основной и самый надёжный слой защиты от страшного цикла
		return
	var/need_blowout = FALSE
	calculate_blowout_message_delay_time()
	report_progress("DEBUG ANOM: Начинается выброс. Стадия - подготовка.")
	can_blowout = FALSE //Первый слой защиты от страшного цикла
	//Опасайтесь того что ваша команда STOP_PROCESSING просто не выполнится
	STOP_PROCESSING(SSweather, src) //Второй слой защиты от страшного цикла
	calculate_blowout_time() //Третий слой защиты от страшного цикла
	prepare_to_blowout()
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		if(get_z(picked_human) == get_z(pick(connected_weather_turfs)))
			need_blowout = TRUE
			if(must_message_about_blowout)
				message_about_blowout_prepare(picked_human)
	if(!need_blowout)
		report_progress("DEBUG ANOM: Должен был случиться выброс, но нет игроков на Z уровне погоды. Отмена.")
		calculate_blowout_time()
		can_blowout = initial(can_blowout) //Откатим состояние переменной до начального уровня
		START_PROCESSING(SSweather, src)
		return FALSE
	return TRUE

/datum/weather_manager/proc/message_about_blowout_prepare(mob/living/input_mob)
	if(LAZYLEN(blowout_prepare_messages))
		input_mob.client.play_screentext_on_client_screen(pick(blowout_prepare_messages))

/datum/weather_manager/proc/message_about_blowout(mob/living/input_mob)
	if(LAZYLEN(blowout_messages))
		input_mob.client.play_screentext_on_client_screen(pick(blowout_messages))


/datum/weather_manager/proc/prepare_to_blowout()
	return TRUE

/datum/weather_manager/proc/stop_blowout()
	if(!is_processing)
		report_progress("DEBUG: Выброс окончен.")
		START_PROCESSING(SSweather, src)
		calculate_blowout_time()

/datum/weather_manager/proc/regenerate_anomalies_on_planet() //Выполняет перереспавн всех аномалий которые были заспавнены стандартным генератором на планете
	set waitfor = FALSE
	for(var/z in my_z)
		var/obj/overmap/visitable/sector/exoplanet/my_planet = map_sectors["[z]"]
		if(!istype(my_planet))
			return
		my_planet.full_clear_from_anomalies()
		my_planet.generate_big_anomaly_artefacts()

/datum/weather_manager/proc/clean_anomalies_on_planet()
	set waitfor = FALSE
	for(var/z in my_z)
		var/obj/overmap/visitable/sector/exoplanet/my_planet = map_sectors["[z]"]
		my_planet.full_clear_from_anomalies()

/datum/weather_manager/proc/calculate_change_time()
	change_time = rand(8, 20 MINUTES) + world.time //Вычисляем во сколько будет следущая смена погоды

/datum/weather_manager/proc/calculate_blowout_time()
	blowout_time = rand(60 MINUTES, 85 MINUTES) + world.time //Вычисляем во сколько будет следущий выброс.

/datum/weather_manager/proc/calculate_blowout_message_delay_time()
	delay_between_message_and_blowout = rand(2 MINUTES, 4 MINUTES)

/proc/move_to_safe_turf(obj/input_obj)
	var/list/possible_turfs = get_area_turfs(get_area(input_obj))
	var/turf/my_turf = get_turf(input_obj)
	//Сдвинем турф минимум на 15 турфов подальше. Как ещё защитить его от посадки на него шаттла - не знаю.
	for(var/turf/picked_turf in possible_turfs)
		if(get_dist(picked_turf,my_turf) <= 15)
			LAZYREMOVE(possible_turfs,picked_turf)
	input_obj.forceMove(pick(possible_turfs))

/datum/weather_manager/proc/delete_manager()
	my_area.connected_weather_manager = null
	if(is_processing)
		STOP_PROCESSING(SSweather,src)
	for(var/obj/weather/detected_weather in connected_weather_turfs)
		detected_weather.delete_weather()
	qdel(src)

/proc/calculate_smallest_x(list/objects_list)
	var/smallest_x = 10000
	for(var/atom in objects_list)
		if(get_x(atom) < smallest_x)
			smallest_x = get_x(atom)
	return smallest_x

/proc/calculate_biggest_x(list/objects_list)
	var/biggest_x = 0
	for(var/atom in objects_list)
		if(get_x(atom) > biggest_x)
			biggest_x = get_x(atom)
	return biggest_x

/proc/collect_smallest_x_turfs(list/turfs_list)
	var/smallest_x = calculate_smallest_x(turfs_list)
	var/list/result_x_turfs = list()
	for(var/turf/T in turfs_list)
		if(get_x(T) == smallest_x)
			LAZYADD(result_x_turfs, T)
	return result_x_turfs

/datum/weather_manager/proc/calculate_affected_z()
	LAZYADD(my_z, get_z(pick(my_area.contents)))
