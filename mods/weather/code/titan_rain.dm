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
		"Вы слышите, чувствуете, видите...цунами...пизда!"
	)
	var/need_up_water = FALSE
	var/power_ups_counter = 0
	var/time_before_cunami = 0

/datum/weather_manager/titan_rain/no_cunami
	can_blowout = FALSE

//Каждые 15 минут будет усиление погоды
/datum/weather_manager/titan_rain/change_stage(force_state, monitor = FALSE, sound = FALSE)
	if(!need_up_water)
		need_up_water = TRUE
		return
	power_ups_counter++
	if(power_ups_counter >= 4)
		start_cunami()
		return
	power_up_water()

/datum/weather_manager/titan_rain/calculate_change_time()
	change_time_result = 15 MINUTES

/datum/weather_manager/titan_rain/proc/power_up_water()
	for(var/turf/T in get_area_turfs(my_area))
		if(istitanwater(T))
			var/turf/simulated/floor/exoplanet/titan_water/water = T
			water.get_better() //Вода становится глубже
	for(var/obj/item/clothing/gloves/anomaly_detector/detector in SSanom.detectors)
		detector.say_message("ВНИМАНИЕ: повышение уровня воды. Критический уровень воды через: [60 - power_ups_counter * 15] минут.")

/datum/weather_manager/titan_rain/proc/weak_all_weater()
	for(var/turf/T in get_area_turfs(my_area))
		var/turf/simulated/floor/exoplanet/titan_water/water = T
		water.get_worst() //Вода становится глубже

/datum/weather_manager/titan_rain/proc/start_cunami()
	weak_all_weater()
	time_before_cunami = rand(50, 180 SECONDS)
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

/obj/weather/rain
	recommended_weather_manager = /datum/weather_manager/titan_rain
	icon_state = "regular_rain"

/turf/unsimulated/wall/water_wall
	name = "VADA"
	color = COLOR_BLUE
