/mob/living/exosuit/proc/strafe_mech(direction)
	var/move_speed = L_leg.min_speed + R_leg.min_speed
	if(!L_leg.good_in_strafe || !R_leg.good_in_strafe)
		move_speed = L_leg.max_speed + R_leg.max_speed
	if(direction == NORTHWEST || direction == NORTHEAST || direction == SOUTHWEST || direction == SOUTHEAST)
		move_speed = sqrt((move_speed*move_speed) + (move_speed * move_speed)) //Гипотенуза
	if(move_speed > 12)
		move_speed = 12
	SetMoveCooldown(min_speed)
	var/turf/target_loc = get_step(src, direction)
	if(target_loc && L_leg && R_leg && L_leg.can_move_on(get_turf(src), target_loc) && MayEnterTurf(target_loc))
		Move(target_loc)
		add_heat(L_leg.heat_generation)
		add_heat(R_leg.heat_generation)
