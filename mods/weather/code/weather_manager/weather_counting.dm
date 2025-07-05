/datum/weather_manager/proc/calculate_count_time()
	count_time = rand(10 MINUTES) + world.time

/datum/weather_manager/proc/try_start_count()
	for(var/mob/living/carbon/human/picked_human in GLOB.living_players)
		var/temp_z = get_z(picked_human)
		if(temp_z in my_z)
			return TRUE
		if(temp_z in seconds_z_list)
			return TRUE

