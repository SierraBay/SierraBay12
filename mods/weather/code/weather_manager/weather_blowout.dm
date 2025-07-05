/datum/weather_manager/proc/prepare_to_blowout()
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
	prepare_to_blowout()
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		if(get_z(picked_human) == get_z(pick(connected_weather_turfs)))
			need_blowout = TRUE
			if(must_message_about_blowout)
				message_about_blowout_prepare(picked_human)
	if(!need_blowout)
		report_progress("DEBUG ANOM: Должен был случиться выброс, но нет игроков на Z уровне погоды. Отмена.")
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
