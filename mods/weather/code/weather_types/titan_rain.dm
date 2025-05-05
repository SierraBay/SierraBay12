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
	var/have_cunami_ang_changes = TRUE
	var/counting_started = FALSE
	//Предполагается что на тиане есть подземные уровни, нам нужно учесть это
	var/list/seconds_z_list = list()

/datum/weather_manager/titan_rain/no_cunami
	have_cunami_ang_changes = FALSE

//Каждые 15 минут будет усиление погоды
/datum/weather_manager/titan_rain/change_stage(force_state, monitor = FALSE, sound = FALSE)
	if(!have_cunami_ang_changes || activity_blocked_by_safe_protocol || !check_change_safety())
		return
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
	var/list/list_effected_humans = list()
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		var/temp_z = get_z(picked_human)
		if(temp_z in my_z) //Нужный нам Z уровень
			LAZYADD(list_effected_humans, picked_human)
		else if(temp_z in seconds_z_list)
			LAZYADD(list_effected_humans, picked_human)
	for(var/mob/living/carbon/human/human in list_effected_humans)
		var/obj/item/clothing/gloves/anomaly_detector/detector = locate(/obj/item/clothing/gloves/anomaly_detector) in human
		if(detector && detector.digital && detector.is_processing)
			sound_to(human, sound(pick(ticks_list), volume = 100))
			human.client.start_counting_back_on_screen(time = remain_time, text_color = "#4d4545", delete_after_time = 5 SECONDS)

/datum/weather_manager/titan_rain/proc/message_abount_started_counting()
	report_progress("DEBUG ANOM: Планета Титан обнаружила на своей поверхности игроков и начала отсчёт, у игроков осталось [remain_power_ups * 15] минут")
	message_players_remaining_time(remain_power_ups * 15 MINUTES)


/datum/weather_manager/titan_rain/proc/try_start_count()
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		var/temp_z = get_z(picked_human)
		if(temp_z in my_z)
			return TRUE
		if(temp_z in seconds_z_list)
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

/datum/weather_manager/titan_rain/proc/weak_all_water()
	for(var/turf/T in get_area_turfs(my_area))
		if(istitanwater(T))
			var/turf/simulated/floor/exoplanet/titan_water/water = T
			SSweather.add_to_water_queue(water, "easiest") // Добавляем в очередь на макс глубины

/datum/weather_manager/titan_rain/proc/start_cunami()
	if(activity_blocked_by_safe_protocol || !check_cunami_safety())
		return
	have_cunami_ang_changes = FALSE
	weak_all_water()
	time_before_cunami = rand(150 SECONDS, 300 SECONDS)
	report_progress("DEBUG ANOM: Начало цунами, оставшееся время - [time_before_cunami/10] Секунд")
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		var/temp_z = get_z(picked_human)
		if(temp_z in my_z)
			picked_human.client.start_counting_back_on_screen(time_before_cunami)
		else if(temp_z in seconds_z_list)
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
	delete_manager()

/datum/weather_manager/titan_rain/proc/check_cunami_safety()
	if(warnings_ammout == critical_warnings_ammout)
		activity_blocked_by_safe_protocol = TRUE
		report_progress("WARNING ERROR: Критическая ситуация подтверждена, предпринимаем действия.")
		delete_manager()
		QDEL_NULL(src) //Если delete_manager не сработает
		CRASH("WARNING ERROR: Критическая ситуация подтверждена, клапон безопасности сорван.")
	if(!have_cunami_ang_changes)
		warnings_ammout++
		report_progress("WARNING ANOM: Цунами уже вызывалось или вовсе не может быть вызвано у данной погоды!")
		return FALSE
	return TRUE

/datum/weather_manager/titan_rain/calculate_affected_z()
	LAZYADD(my_z, get_z(pick(my_area.contents)))
	//теперь соберём все ландмарки
	collect_landmarks()

/datum/weather_manager/titan_rain/proc/collect_landmarks()
	seconds_z_list = list()
	var/list/processed_landmarks = list() // Чтобы не зациклиться
	// Начинаем с ландмарк, находящихся на my_z
	for(var/obj/landmark/teleport_to_z_level/landmark in teleport_landmarks_list)
		if(get_z(landmark) in my_z)
			if(!(landmark in processed_landmarks))
				process_landmark_recursively(landmark, processed_landmarks)

	// Удаляем дубликаты (если uniqueList() есть)
	seconds_z_list = uniquelist(seconds_z_list)
	LAZYREMOVE(seconds_z_list, my_z)

/datum/weather_manager/titan_rain/proc/process_landmark_recursively(obj/landmark/teleport_to_z_level/landmark, list/processed_landmarks, depth = 5)
	// Если уже обрабатывали или достигли максимальной глубины — пропускаем
	if(landmark in processed_landmarks || depth <= 0)
		return

	processed_landmarks += landmark
	if(!landmark.connected_landmark && !landmark.spawn_started)
		landmark.deploy_map()
	var/current_z = get_z(landmark)
	var/target_z = get_z(landmark.connected_landmark)

	// Добавляем оба Z-уровня (текущий и связанный)
	seconds_z_list |= current_z
	seconds_z_list |= target_z

	// Рекурсивно обрабатываем связанную ландмарку с уменьшенной глубиной
	process_landmark_recursively(landmark.connected_landmark, processed_landmarks, depth - 1)

	// Ищем все ландмарки на целевом Z-уровне (для матрёшки) с уменьшенной глубиной
	for(var/obj/landmark/teleport_to_z_level/adjacent_landmark in teleport_landmarks_list)
		if(get_z(adjacent_landmark) == target_z && !(adjacent_landmark in processed_landmarks))
			process_landmark_recursively(adjacent_landmark, processed_landmarks, depth - 1)

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

/turf/unsimulated/wall/water_wall/Enter(atom/movable/mover, atom/forget)
	. = ..()
	if(isghost(mover) || IsAbstract(mover) || isobserver(mover))
		return
	qdel(mover)
