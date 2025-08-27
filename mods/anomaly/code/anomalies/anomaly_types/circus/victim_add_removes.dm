/obj/anomaly/circus/Crossed(atom/movable/O)
	if(!currently_active && can_be_activated(O))
		activate_anomaly()
	else if(currently_active)
		add_victim(O)

/obj/anomaly/circus/proc/add_victim(atom/movable/victim)
	if(!victim || isghost(victim) || isobserver(victim))
		return
	if(victim in victims_inside)
		return

	victims_inside[victim] = 1 // Начинаем с первого угла
	start_movement(victim)
	/*
	if(!animation_timer)
		animation_timer = addtimer(new callback(src, PROC_REF(update_animation)), movement_duration, TIMER_LOOP)
	*/

// Убираем жертву из анимации
/obj/anomaly/circus/proc/remove_victim(atom/movable/victim)
	if(!(victim in victims_inside))
		return

	animate(victim, pixel_x = 0, pixel_y = 0, time = 0.5 SECONDS)
	victims_inside -= victim

	if(!length(victims_inside) && animation_timer)
		deltimer(animation_timer)
		animation_timer = null
