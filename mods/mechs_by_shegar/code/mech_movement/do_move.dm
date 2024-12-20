/datum/movement_handler/mob/exosuit/DoMove(direction, mob/mover, is_external)
	var/mob/living/exosuit/exosuit = host
	var/moving_dir = direction

	var/failed = FALSE
	var/fail_prob = mover != host ? (mover.skill_check(SKILL_MECH, HAS_PERK) ? 0 : 25) : 0
	if(prob(fail_prob))
		to_chat(mover, SPAN_DANGER("You clumsily fumble with the exosuit joystick."))
		failed = TRUE
	else if(exosuit.emp_damage >= EMP_MOVE_DISRUPT && prob(30))
		failed = TRUE
	if(failed)
		moving_dir = pick(GLOB.cardinal - exosuit.dir)

	exosuit.get_cell()?.use(exosuit.legs.power_use * CELLRATE)

	if(direction & (UP|DOWN))
		var/txt_dir = direction & UP ? "upwards" : "downwards"
		exosuit.visible_message(SPAN_NOTICE("\The [exosuit] moves [txt_dir]."))
	if(exosuit.legs.can_strafe)
		if(exosuit.strafe_status)
			var/move_speed = exosuit.legs.move_delay
			if(!exosuit.legs.good_in_strafe)
				move_speed = move_speed * 2.5
			if(direction == NORTHWEST || direction == NORTHEAST || direction == SOUTHWEST || direction == SOUTHEAST)
				move_speed = sqrt((move_speed*move_speed) + (move_speed * move_speed))
			if(move_speed > 12)
				move_speed = 12
			exosuit.SetMoveCooldown(exosuit.legs ? move_speed : 3)
			var/turf/target_loc = get_step(exosuit, direction)
			if(target_loc && exosuit.legs && exosuit.legs.can_move_on(exosuit.loc, target_loc) && exosuit.MayEnterTurf(target_loc))
				exosuit.Move(target_loc)
				exosuit.add_heat(exosuit.legs.heat_generation)
			return MOVEMENT_HANDLED

//TURN
	if(exosuit.dir != moving_dir && !(direction & (UP|DOWN)))
		playsound(exosuit.loc, exosuit.legs.mech_turn_sound, 40,1)
		if(exosuit.dir == turn(direction, 45) || exosuit.dir == turn(direction, -45))
			exosuit.sub_speed( exosuit.legs.turn_diogonal_slowdown)
		else if(exosuit.dir == turn(direction, 90) || exosuit.dir == turn(direction, -90))
			exosuit.sub_speed( exosuit.legs.turn_slowdown )
		else if(exosuit.dir == turn(direction, 135) || exosuit.dir == turn(direction, -135))
			exosuit.sub_speed( (exosuit.legs.turn_slowdown + exosuit.legs.turn_diogonal_slowdown)  )
		else if(exosuit.dir == turn(direction, 180) || exosuit.dir == turn(direction, -180))
			exosuit.legs.current_speed = exosuit.legs.min_speed
		exosuit.add_heat(exosuit.legs.heat_generation)
		exosuit.set_dir(moving_dir)
		exosuit.SetMoveCooldown(exosuit.legs.turn_delay)

//TURN

//MOVE
	else
		exosuit.SetMoveCooldown(exosuit.legs ? exosuit.legs.current_speed : 3)
		var/turf/target_loc = get_step(exosuit, direction)
		if(target_loc && exosuit.legs && exosuit.legs.can_move_on(exosuit.loc, target_loc) && exosuit.MayEnterTurf(target_loc))
			if(!exosuit.body.phazon)
				exosuit.Move(target_loc)
				exosuit.add_heat(exosuit.legs.heat_generation)
				exosuit.add_speed()
			else
				for(var/thing in exosuit.pilots) //Для всех пилотов внутри
					var/mob/pilot = thing
					if(pilot && pilot.client)
						for(var/key in pilot.client.keys_held)
							if (key == "Shift")
								var/move_speed = exosuit.legs.move_delay
								move_speed = move_speed * 2.5
								exosuit.SetMoveCooldown(exosuit.legs ? move_speed : 3)
								exosuit.forceMove(target_loc)

							else
								exosuit.Move(target_loc)
	return MOVEMENT_HANDLED
