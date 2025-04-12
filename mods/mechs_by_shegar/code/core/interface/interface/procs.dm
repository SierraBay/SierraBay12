/mob/living/exosuit/proc/stop_gps_ui(mob/user)
	if(GPS && GPS.tracking && user)
		GPS.toggle_tracking(user, silent = TRUE)
