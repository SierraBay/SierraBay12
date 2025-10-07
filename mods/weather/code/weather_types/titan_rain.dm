//Сильный дождь с планеты титан
//Каждые 15 минут начиная с 15-ой минуты уровень воды растёт
/datum/weather_manager/titan_rain
	weather_name = "Дождь с планеты Титан"
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
	var/time_before_cunami = 0
	can_blowout = TRUE
	var/have_cunami_ang_changes = TRUE
	var/counting_started = FALSE
	//Предполагается что на тиане есть подземные уровни, нам нужно учесть это
	var/list/seconds_z_list = list()

/datum/weather_manager/titan_rain/no_cunami
	have_cunami_ang_changes = FALSE

/datum/weather_manager/titan_rain/check_have_players_on_z_level()
	//В случае если титан уже кого-то заметил на своём уровне, повторные проверки не потребуются
	//т.к титан уснуть уже не может
	if(!have_cunami_ang_changes)
		return FALSE
	if(counting_started)
		return TRUE
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		if(get_z(picked_human) in my_z)
			break
		return FALSE
	return TRUE

//Каждые 15 минут будет усиление погоды
/datum/weather_manager/titan_rain/change_stage()
	set waitfor = FALSE
	set background = TRUE
	calculate_change_time()
	if(activity_blocked_by_safe_protocol || !check_change_safety())
		return

	if(!counting_started)
		if(try_start_count())
			counting_started = TRUE
			message_abount_started_counting()
		return

	if(!check_have_players_on_z_level())
		return FALSE


	change_powerups_ammout(-1)

	if(need_up_water)
		need_up_water = FALSE
		power_up_water()
	else
		need_up_water = TRUE

	change_visual_weather(5 MINUTES) //Вызывает функцию смену визуала
	return TRUE

/datum/weather_manager/titan_rain/change_powerups_ammout(number)
	if(!number)
		return
	if(!remain_power_ups && can_blowout)
		start_blowout()
		return
	number = clamp(number, -10, 10)
	number = round(number)
	remain_power_ups += number
	remain_power_ups = clamp(remain_power_ups, 0, 30)
	report_progress("DEBUG ANOM: Рост уровня воды на водной планете. Осталось [remain_power_ups * 15] минут или же [remain_power_ups] повышений уровня воды до цунами.")
	message_players_remaining_time(remain_power_ups * 15 MINUTES)

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

/datum/weather_manager/titan_rain/change_visual_weather(force_state = FALSE, time = 5 MINUTES)
	if(force_state)
		if(force_state == "calm")
			stop_rain()
		else if(force_state == "midle")
			for(var/obj/weather/weather in connected_weather_turfs)
				weather.icon_state = "titan_rain_[rand(1, 2)]"
				weather.play_monitor_effect = FALSE
				weather.play_sound = TRUE
				weather.update()
		return
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

/datum/weather_manager/titan_rain/proc/power_up_water()
	for(var/turf/T in get_area_turfs(my_area))
		if(istitanwater(T))
			var/turf/simulated/floor/exoplanet/titan_water/water = T
			if(water.deep_status != MAX_DEEP)
				SSweatherold.add_to_water_queue(water, "up") // Добавляем в очередь на углубление

/datum/weather_manager/titan_rain/proc/weak_all_water()
	for(var/turf/T in get_area_turfs(my_area))
		if(istitanwater(T))
			var/turf/simulated/floor/exoplanet/titan_water/water = T
			SSweatherold.add_to_water_queue(water, "easiest") // Добавляем в очередь на макс глубины

/datum/weather_manager/titan_rain/start_blowout()
	if(activity_blocked_by_safe_protocol || !check_cunami_safety())
		return
	have_cunami_ang_changes = FALSE
	weak_all_water()
	time_before_cunami = rand(150 SECONDS, 300 SECONDS)
	report_progress("DEBUG ANOM: Начало цунами, оставшееся время - [time_before_cunami/10] Секунд")
	for(var/mob/living/picked_player in GLOB.living_players)
		var/temp_z = get_z(picked_player)
		if(temp_z in my_z)
			picked_player.client.start_counting_back_on_screen(time_before_cunami)
		else if(temp_z in seconds_z_list)
			picked_player.client.start_counting_back_on_screen(time_before_cunami)
	sleep(time_before_cunami)
	if(activity_blocked_by_safe_protocol)
		return
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
	if(activity_blocked_by_safe_protocol)
		return
	clean_anomalies_on_planet()
	report_progress("DEBUG ANOM: планета [my_area] уничтожена Цунами.")
	Destroy()

/datum/weather_manager/titan_rain/proc/check_cunami_safety()
	if(warnings_ammout == critical_warnings_ammout)
		activity_blocked_by_safe_protocol = TRUE
		report_progress("WARNING ERROR: Критическая ситуация подтверждена, предпринимаем действия.")
		Destroy()
		CRASH("WARNING ERROR: Критическая ситуация подтверждена, клапон безопасности сорван.")
	if(!have_cunami_ang_changes)
		warnings_ammout++
		report_progress("WARNING ANOM: Цунами уже вызывалось или вовсе не может быть вызвано у данной погоды!")
		return FALSE
	return TRUE

/datum/weather_manager/titan_rain/calculate_affected_z()
	LAZYADD(my_z, get_z(pick(my_area.contents)))

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
