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
	var/power_ups_counter = 0
	var/time_before_cunami = 0
	var/counting_started = FALSE

/datum/weather_manager/titan_rain/no_cunami
	can_blowout = FALSE

//Каждые 15 минут будет усиление погоды
/datum/weather_manager/titan_rain/change_stage(force_state, monitor = FALSE, sound = FALSE)
	if(!counting_started && !try_start_count())
		return
	counting_started = TRUE
	power_ups_counter++
	report_progress("DEBUG ANOM: Рост уровня воды на водной планете. Осталось [60 - power_ups_counter*15] минут или же [3 - power_ups_counter] повышений до цунами.")
	var/list/ticks_list = list('mods/weather/sounds/TICK_1.ogg', 'mods/weather/sounds/TICK_2.ogg', 'mods/weather/sounds/TICK_3.ogg')
	SSanom.announce_to_all_detectors_on_z_level(get_z(pick(connected_weather_turfs)), "Зафкисировано повышение уровня воды. Оставшееся расчётное время до критического уровня воды: [60 - power_ups_counter*15]", ticks_list)
	temp_rain(5 MINUTES)
	if(need_up_water)
		need_up_water = FALSE
		power_up_water()
	else
		need_up_water = TRUE
		power_up_water()
	if(power_ups_counter >= 3)
		STOP_PROCESSING(SSweather, src)
		start_cunami()
		return

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
	change_time_result = 15 MINUTES

/datum/weather_manager/titan_rain/proc/power_up_water()
	for(var/turf/T in get_area_turfs(my_area))
		if(istitanwater(T))
			var/turf/simulated/floor/exoplanet/titan_water/water = T
			if(water.deep_status != MAX_DEEP)
				water.get_better() //Вода становится глубже

/datum/weather_manager/titan_rain/proc/weak_all_weater()
	for(var/turf/T in get_area_turfs(my_area))
		var/turf/simulated/floor/exoplanet/titan_water/water = T
		water.get_worst() //Вода становится глубже

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
