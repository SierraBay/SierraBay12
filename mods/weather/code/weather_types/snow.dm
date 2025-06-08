/datum/weather_manager/snow
	weather_name = "Белая мгла"
	weather_turf_type = /obj/weather/snow
	stages = list(
		"calm",
		"midle",
		"storm"
	)
	can_blowout = TRUE
	blowout_prepare_messages = list(
		"...всё резко стихло...затишье перед бурей?...не к добру...",
		"Всё стихло, а в небе что-то словно зажигается...это не есть хорошо.",
		"Все чувства, даже шестое, проснулось в тебе...что-то грядёт."
	)
	blowout_messages = list(
		"Вы видете в небе северное сияние и разряды молний в небе! Нужно укрыться!",
		"Вы слышите треск и шорох словно от статического электричества, а по полу расползаются малые электродуги! Нужно укрыться!"
	)

/datum/weather_manager/snow/no_blowout
	can_blowout = FALSE

/datum/weather_manager/snow/calculate_power_ups()
	remain_power_ups = rand(4, 6)

/datum/weather_manager/snow/prepare_to_blowout()
	change_visual_weather(force_state = "calm")

/datum/weather_manager/snow/change_visual_weather(force_state = FALSE, override_parameters = FALSE, monitor = FALSE, sound = FALSE, blowout_status = FALSE, new_icon_state = "void")
	var/possible_stages = stages.Copy()
	LAZYREMOVE(possible_stages, current_stage)
	if(force_state)
		current_stage = force_state
	else
		current_stage = pick(possible_stages)
	if(override_parameters)
		for(var/obj/weather/weather in connected_weather_turfs)
			weather.icon_state = new_icon_state
			weather.play_monitor_effect = monitor
			weather.play_sound = sound
			weather.blowout_status = blowout_status
			weather.update()
	else if(current_stage == "calm")
		for(var/obj/weather/weather in connected_weather_turfs)
			weather.icon_state = "void"
			weather.play_monitor_effect = FALSE
			weather.play_sound = FALSE
			weather.update()
	else if(current_stage == "midle")
		for(var/obj/weather/weather in connected_weather_turfs)
			weather.icon_state = "light_snow"
			weather.play_monitor_effect = FALSE
			weather.play_sound = FALSE
			weather.update()
	else if(current_stage == "storm")
		for(var/obj/weather/weather in connected_weather_turfs)
			weather.icon_state = "snow_storm"
			weather.play_monitor_effect = TRUE
			weather.play_sound = TRUE
			weather.update()

/obj/weather/snow/flick_weather_icon(state)
	flick("[icon_state]_to_[state]", src)


/datum/weather_manager/snow/start_blowout()
	.=..()
	if(!.) //Родитель сказал Баста, выброс не нужен
		return
	if(activity_blocked_by_safe_protocol)
		return
	sleep(delay_between_message_and_blowout)
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		if(get_z(picked_human) == get_z(src))
			if(must_message_about_blowout)
				message_about_blowout(picked_human)
	//Выброс в виде белой мглы медленно перекатывается слева направо
	var/start_x
	var/list/blowout_weather_turfs = connected_weather_turfs.Copy()
	start_x = calculate_smallest_x(blowout_weather_turfs)
	SSanom.announce_to_all_detectors_on_z_level(get_z(pick(connected_weather_turfs)) , "Зафиксировано критическое повышение электромагнитного поля.")
	while(LAZYLEN(blowout_weather_turfs))
		for(var/obj/weather/weather in blowout_weather_turfs)
			if(weather.x == start_x)
				weather.icon_state = weather.blowout_icon_state
				weather.play_monitor_effect = FALSE
				weather.play_sound = FALSE
				weather.blowout_status = TRUE
				weather.update()
				weather.blowout_check_turf()
				LAZYREMOVE(blowout_weather_turfs, weather)
		sleep(1.5 SECONDS)
		if(activity_blocked_by_safe_protocol)
			return
		start_x++
	sleep(rand(10 SECONDS,20 SECONDS))
	if(activity_blocked_by_safe_protocol)
		return
	SSanom.announce_to_all_detectors_on_z_level(get_z(pick(connected_weather_turfs)) , "Зафиксировано спадение электромагнитного поля.")
	report_progress("DEBUG ANOM: Выброс в процессе. Начинается стадия авроры, пробуждаем технику и устройства.")
	//Перестаёт жечь ЭМИшкой
	change_visual_weather(force_state = "calm")
	for(var/obj/structure/aurora/aurora_structure in SSweather.aurora_sctructures)
		if(my_area.z == aurora_structure.z)
			aurora_structure.wake_up(rand(5 MINUTES, 9 MINUTES))
	sleep(rand(10 MINUTES, 15 MINUTES))
	if(activity_blocked_by_safe_protocol)
		return
	report_progress("DEBUG ANOM: Выброс в процессе. Аврора окончена. Начинается перереспавн аномалий и артефактов.")
	to_world(SPAN_BAD("WARNING: Моду аномалий требуются значительные ресурсы для перереспавна. Ожидайте затупа игры через 10 секунд."))
	SSanom.announce_to_all_detectors_on_z_level(get_z(pick(connected_weather_turfs)) , "Зафиксирована огромная аномальная активность, показания зашкаливают.")
	sleep(10 SECONDS)
	if(activity_blocked_by_safe_protocol)
		return
	//regenerate_anomalies_on_planet() //TODO разработать менее ресурсозатратный способ реализации
	stop_blowout()

/datum/weather_manager/snow/stop_blowout()
	if(!is_processing)
		START_PROCESSING(SSweather, src)
	for(var/obj/weather/weather in connected_weather_turfs)
		weather.blowout_status = FALSE
		weather.icon_state = initial(weather.icon_state)
	report_progress("DEBUG ANOM: Работа выброса окончена.")
	calculate_change_time()
	calculate_power_ups()
	calculate_next_safe_blowout()
	calculate_next_safe_change()
	can_blowout = TRUE

//Эффект снежной вьюги
/obj/weather/snow
	icon_state = "snow_storm"
	icon = 'mods/weather/icons/weather_effects.dmi'
	recommended_weather_manager = /datum/weather_manager/snow
	must_react_at_enter = TRUE
	sound_type = list(
		'mods/weather/sounds/snowstorm.ogg'
	)
	blowout_icon_state = "snow_blowout"




//Эффект снега на экране
/obj/screen/fullscreen/snow_effect
	icon = 'mods/weather/icons/snow_screen.dmi'
	icon_state = "snow"
	layer = BLIND_LAYER
	scale_to_view = TRUE



/obj/weather/snow/add_monitor_effect(mob/living/input_mob)
	input_mob.overlay_fullscreen("snow_monitor", /obj/screen/fullscreen/snow_effect)
	//Логируем пользователя в глобальный список

/obj/weather/snow/remove_monitor_effect(mob/living/input_mob)
	input_mob.clear_fullscreen("snow_monitor")

/obj/weather/snow/react_at_enter_in_blowout(atom/movable/atom)
	if(isliving(atom))
		var/mob/input_mob = atom
		input_mob.emp_act(1)
	return

/obj/weather/snow/react_at_leave_from_blowout(atom/movable/atom)
	return

/obj/weather/snow/blowout_check_turf()
	for(var/mob/living/somebody in get_turf(src))
		somebody.emp_act(1)
