/mob/living/exosuit/proc/process_speed()
	//Основная задача прока - убить скорость если мех не сдвинулся
	if((world.time - move_time_holder) < legs.lost_speed_colldown)
		return
	legs.current_speed = legs.min_speed
	process_move_speed = FALSE

/mob/living/exosuit/proc/add_speed(ammount)
	move_time_holder = world.time
	process_move_speed = TRUE

	if(ammount)
		legs.current_speed -=  ammount
	else
		legs.current_speed -=  total_acceleration

	if(legs.current_speed < legs.max_speed)
		legs.current_speed = legs.max_speed

/mob/living/exosuit/proc/sub_speed(ammount)
	//move_time_holder = world.time

	if(ammount)
		legs.current_speed += ammount
	else
		legs.current_speed += legs.turn_slowdown

	if(legs.current_speed < legs.min_speed)
		legs.current_speed = legs.min_speed
