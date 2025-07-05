/datum/weather_manager
	var/remain_power_ups = 6 //Каждый даёт по 15 минут

/datum/weather_manager/proc/calculate_power_up()
	powerup_time = 15 MINUTES + world.time

/datum/weather_manager/proc/ready_for_power_up()
	if(world.time > powerup_time)
		return TRUE
	else
		return FALSE

/datum/weather_manager/proc/power_up()
	calculate_power_up()
	remain_power_ups--
