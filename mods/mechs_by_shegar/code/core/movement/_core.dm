/mob/living/exosuit
	var/list/movement_blocked_by_shield = list()
	///Требуется обработка скорости?
	var/process_move_speed = FALSE
	///Холдер, содержит время когда был сделан последний шаг
	var/move_time_holder = 0
	///Итоговый общий вес меха
	var/total_weight = 0
	var/strafe_status = FALSE

/mob/living/exosuit/Move()
	. = ..()
	if(. && !istype(loc, /turf/space))
		do_mech_step_sound()

/mob/living/exosuit/can_ztravel()
	if(Process_Spacemove()) //Handle here
		return TRUE

//Inertia drift making us face direction makes exosuit flight a bit difficult, plus newtonian flight model yo
/mob/living/exosuit/set_dir(ndir)
	if(inertia_dir && inertia_dir == ndir)
		return ..(dir)
	return ..(ndir)

/mob/living/exosuit/can_fall(anchor_bypass = FALSE, turf/location_override = src.loc)
	//mechs are always anchored, so falling should always ignore it
	if(..(TRUE, location_override))
		return !(can_overcome_gravity())

/mob/living/exosuit/can_float()
	return FALSE //Nope

/datum/movement_handler/mob/delay/exosuit/DoMove(direction, mover, is_external) //Delay must be handled by other handlers.
	return

/mob/living/exosuit/SetMoveCooldown(timeout)
	var/datum/movement_handler/mob/delay/delay = GetMovementHandler(/datum/movement_handler/mob/delay/exosuit)
	if(delay)
		delay.SetDelay(timeout)

/mob/living/exosuit/ExtraMoveCooldown(timeout)
	var/datum/movement_handler/mob/delay/delay = GetMovementHandler(/datum/movement_handler/mob/delay/exosuit)
	if(delay)
		delay.AddDelay(timeout)

/mob/living/exosuit/Check_Shoegrip()//mechs are always magbooting
	return TRUE

/mob/living/exosuit/Process_Spacemove(allow_movement)
	if(has_gravity() || throwing || !isturf(loc) || length(grabbed_by) || check_space_footing() || locate(/obj/structure/lattice) in range(1, get_turf(src)))
		anchored = TRUE
		return TRUE

	anchored = FALSE

	//Regardless of modules, emp prevents control
	if(emp_damage >= EMP_MOVE_DISRUPT && prob(25))
		return FALSE

	var/obj/item/mech_equipment/ionjets/J = hardpoints[HARDPOINT_BACK]
	if(istype(J))
		if(J.allowSpaceMove() && (allow_movement || J.stabilizers))
			return TRUE

/mob/living/exosuit/check_space_footing()//mechs can't push off things to move around in space, they stick to hull or float away
	for(var/thing in trange(1,src))
		var/turf/T = thing
		if(T.density || T.is_wall() || T.is_floor())
			return T

/mob/living/exosuit/space_do_move()
	return 1


/mob/living/exosuit/lost_in_space()
	for(var/atom/movable/AM in contents)
		if(!AM.lost_in_space())
			return FALSE
	return !length(pilots)

/mob/living/exosuit/fall_damage()
	return 175 //Exosuits are big and heavy

/mob/living/exosuit/handle_fall_effect(turf/landing)
	// Return here if for any reason you shouldn´t take damage
	..()
	if(L_leg)
		L_leg.handle_vehicle_fall()
	if(R_leg)
		R_leg.handle_vehicle_fall()
