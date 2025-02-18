/mob/living/exosuit
	///Текущая скорость меха
	var/current_speed = 0
	var/max_speed = 5
	var/total_acceleration = 0

/mob/living/exosuit/proc/process_speed()
	//Основная задача прока - убить скорость если мех не сдвинулся
	if((world.time - move_time_holder) < L_leg.lost_speed_colldown + R_leg.lost_speed_colldown)
		return
	current_speed = L_leg.min_speed + R_leg.min_speed
	process_move_speed = FALSE

/mob/living/exosuit/proc/add_speed(ammount)
	move_time_holder = world.time
	process_move_speed = TRUE

	if(ammount)
		current_speed -=  ammount
	else
		current_speed -=  total_acceleration

	if(current_speed < L_leg.max_speed + R_leg.max_speed)
		current_speed = L_leg.max_speed +  R_leg.max_speed

/mob/living/exosuit/proc/sub_speed(ammount)
	//move_time_holder = world.time

	if(ammount)
		current_speed += ammount
	else
		current_speed += L_leg.turn_slowdown + R_leg.turn_slowdown

	if(current_speed < L_leg.min_speed + R_leg.min_speed)
		current_speed = L_leg.min_speed + R_leg.min_speed
