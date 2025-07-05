/datum/weather_manager/proc/calculate_change_time()
	change_time = rand(8, 20 MINUTES) + world.time //Вычисляем во сколько будет следущая смена погоды

///Смена типа погоды.
/datum/weather_manager/proc/change_stage()
	set waitfor = FALSE
	set background = TRUE
	calculate_change_time()
	if(activity_blocked_by_safe_protocol || !check_change_safety())
		return
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		if(get_z(picked_human) in my_z)
			break
		return FALSE
	for(var/obj/weather/connected_weather in connected_weather_turfs)
		connected_weather.update()
	return TRUE
