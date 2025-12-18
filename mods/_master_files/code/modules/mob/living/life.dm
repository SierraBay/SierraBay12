//stop sight update
/mob
	var/stop_sight_update = FALSE //for update_sight()

/mob/living/update_sight()
	if(stop_sight_update) return
	..()
//