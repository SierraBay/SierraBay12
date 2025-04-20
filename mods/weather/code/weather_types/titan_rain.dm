//Сильный дождь с планеты титан
//Каждые 15 минут начиная с 15-ой минуты уровень воды растёт
/datum/weather_manager/titan_rain
	weather_turf_type = /obj/weather/rain
	stages = list()
	can_blowout = TRUE
	blowout_prepare_messages = list(
		"Дождь всё сильней и сильней, держаться в воде всё сложней и сложней, дрянь!",
		"Вода всё плотней, ноги с трудом пробираются через воду! Плохо дело!",
		"Похоже что уровень воды близок к критическому, нужно сматываться!"
	)
	blowout_messages = list(
		"Что-то вдали...это....это не горы...это стена воды!",
		"Вы слышите, чувствуете, видите...цунами...огромное, прямо таки до небес..."
	)
	var/need_up_water = FALSE
	var/remain_power_ups = 4
	var/time_before_cunami = 0
	can_blowout = FALSE
	var/counting_started = FALSE

/datum/weather_manager/titan_rain/no_cunami
	can_blowout = FALSE

//Каждые 15 минут будет усиление погоды
/datum/weather_manager/titan_rain/change_stage(force_state, monitor = FALSE, sound = FALSE)
	calculate_change_time()
	if(!counting_started)
		if(try_start_count())
			counting_started = TRUE
			message_abount_started_counting()
		return
	remain_power_ups--
	report_progress("DEBUG ANOM: Рост уровня воды на водной планете. Осталось [remain_power_ups * 15] минут или же [remain_power_ups] повышений уровня воды до цунами.")
	message_players_remaining_time(remain_power_ups * 15 MINUTES)
	temp_rain(rand(5, 10) MINUTES)
	if(need_up_water)
		need_up_water = FALSE
		power_up_water()
	else
		need_up_water = TRUE
		power_up_water()
	if(remain_power_ups <= 0)
		STOP_PROCESSING(SSweather, src)
		start_cunami()
		return

//Игра показывает игрокам сколько осталось времени
/datum/weather_manager/titan_rain/proc/message_players_remaining_time(remain_time)
	var/list/ticks_list = list('mods/weather/sounds/TICK_1.ogg', 'mods/weather/sounds/TICK_2.ogg', 'mods/weather/sounds/TICK_3.ogg')
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		if(get_z(picked_human) == get_z(pick(connected_weather_turfs))) //Нужный нам Z уровень
			var/obj/item/clothing/gloves/anomaly_detector/detector = locate(/obj/item/clothing/gloves/anomaly_detector) in picked_human
			if(detector && detector.digital && detector.is_processing)
				sound_to(picked_human, sound(pick(ticks_list), volume = 100))
				picked_human.client.start_counting_back_on_screen(time = remain_time, text_color = "#4d4545", delete_after_time = 5 SECONDS)

/datum/weather_manager/titan_rain/proc/message_abount_started_counting()
	report_progress("DEBUG ANOM: Планета Титан обнаружила на своей поверхности игроков и начала отсчёт, у игроков осталось [remain_power_ups * 15] минут")
	message_players_remaining_time(remain_power_ups * 15 MINUTES)


/datum/weather_manager/titan_rain/proc/try_start_count()
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		if(get_z(picked_human) == get_z(pick(connected_weather_turfs)))
			return TRUE

/datum/weather_manager/titan_rain/proc/temp_rain(time = 5 MINUTES)
	for(var/obj/weather/weather in connected_weather_turfs)
		weather.icon_state = "titan_rain_[rand(1, 2)]"
		weather.play_monitor_effect = FALSE
		weather.play_sound = TRUE
		weather.update()
	addtimer(new Callback(src, PROC_REF(stop_rain)), time)

/datum/weather_manager/titan_rain/proc/stop_rain()
	for(var/obj/weather/weather in connected_weather_turfs)
		weather.icon_state = null
		weather.play_monitor_effect = FALSE
		weather.play_sound = FALSE
		weather.update()

/datum/weather_manager/titan_rain/calculate_change_time()
	change_time = 15 MINUTES + world.time

/datum/weather_manager/titan_rain/proc/power_up_water()
	for(var/turf/T in get_area_turfs(my_area))
		if(istitanwater(T))
			var/turf/simulated/floor/exoplanet/titan_water/water = T
			if(water.deep_status != MAX_DEEP)
				SSweather.add_to_water_queue(water, "up") // Добавляем в очередь на углубление

/datum/weather_manager/titan_rain/proc/weak_all_weater()
	for(var/turf/T in get_area_turfs(my_area))
		if(istitanwater(T))
			var/turf/simulated/floor/exoplanet/titan_water/water = T
			SSweather.add_to_water_queue(water, "easiest") // Добавляем в очередь на макс глубины

/datum/weather_manager/titan_rain/proc/start_cunami()
	weak_all_weater()
	time_before_cunami = rand(150 SECONDS, 300 SECONDS)
	report_progress("DEBUG ANOM: Начало цунами, оставшееся время - [time_before_cunami/10] Секунд")
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		if(get_z(picked_human) == get_z(pick(connected_weather_turfs)))
			picked_human.client.start_counting_back_on_screen(time_before_cunami)
	sleep(time_before_cunami)
	var/list/turfs = Z_ALL_TURFS(get_z(pick(connected_weather_turfs)))
	var/list/edge_turfs = collect_smallest_x_turfs(turfs)
	var/current_x = 0
	var/max_x = calculate_biggest_x(turfs)
	while(current_x <= max_x)
		for(var/turf/T in edge_turfs)
			T.ChangeTurf(/turf/unsimulated/wall/water_wall)
			for(var/atom in T)
				if(!isghost(atom) || !is_abstract(atom))
					qdel(atom)
			LAZYREMOVE(edge_turfs, T)
			T = get_step(T, EAST)
			LAZYADD(edge_turfs, T)
		sleep(0.05 SECONDS)
		current_x++
	clean_anomalies_on_planet()
	report_progress("DEBUG ANOM: планета [my_area] уничтожена Цунами.")

/obj/weather/rain
	recommended_weather_manager = /datum/weather_manager/titan_rain
	icon_state = "regular_rain"
	must_react_at_enter = TRUE
	play_sound = FALSE
	sound_type = list(
		'mods/weather/sounds/RAIN.ogg'
	)

/turf/unsimulated/wall/water_wall
	name = "VADA"
	color = COLOR_BLUE
