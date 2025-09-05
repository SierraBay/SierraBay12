/datum/movement_handler/mob/exosuit/DoMove(direction, mob/mover, is_external)
	var/mob/living/exosuit/exosuit = host
	var/moving_dir = direction

	var/failed = FALSE
	var/fail_prob = mover != host ? (mover.skill_check(SKILL_MECH, HAS_PERK) ? 0 : 25) : 0
	if(prob(fail_prob))
		to_chat(mover, SPAN_DANGER("You clumsily fumble with the mech joystick."))
		failed = TRUE
	else if(exosuit.emp_damage >= EMP_MOVE_DISRUPT && prob(30))
		failed = TRUE
	if(failed)
		moving_dir = pick(GLOB.cardinal - exosuit.dir)

	exosuit.spend_power_for_step()

	if(direction & (UP|DOWN))
		var/txt_dir = direction & UP ? "upwards" : "downwards"
		exosuit.visible_message(SPAN_NOTICE("\The [exosuit] moves [txt_dir]."))
	if(exosuit.dir != moving_dir && !(direction & (UP|DOWN)) && !exosuit.strafe_status)
		exosuit.turn_mech(moving_dir)
	else
		if(exosuit.strafe_status)
			exosuit.strafe_mech(direction)
		else
			exosuit.step_mech()
	return MOVEMENT_HANDLED

/mob/living/exosuit
	//Используется чтоб менять шаги между собой
	var/current_leg = FALSE

/mob/living/exosuit/proc/do_mech_step_sound(volume = 40)
	if(current_leg)
		playsound(get_turf(src), R_leg.mech_step_sound, volume, 1)
		current_leg = FALSE
	else
		playsound(get_turf(src), L_leg.mech_step_sound, volume, 1)
		current_leg = TRUE

/mob/living/exosuit/proc/spend_power_for_step()
	var/obj/item/cell/my_cell = get_cell()
	if(!my_cell)
		return FALSE
	if(current_leg)
		my_cell.use(R_leg.power_use * CELLRATE)
	else
		my_cell.use(L_leg.power_use * CELLRATE)

/mob/living/exosuit/proc/do_mech_turn_sound(volume = 40)
	playsound(get_turf(src), pick(R_leg.mech_turn_sound, L_leg.mech_turn_sound), volume, 1)
