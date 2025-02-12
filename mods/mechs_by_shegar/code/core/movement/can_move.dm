/datum/movement_handler/mob/exosuit/MayMove(mob/mover, is_external)
	var/mob/living/exosuit/exosuit = host
	if((!(mover in exosuit.pilots) && mover != exosuit) || exosuit.incapacitated() || mover.incapacitated())
		return MOVEMENT_STOP
	if(!exosuit.legs)
		to_chat(mover, SPAN_WARNING("\The [exosuit] has no means of propulsion!"))
		exosuit.SetMoveCooldown(3)
		return MOVEMENT_STOP
	if(!exosuit.legs.motivator || !exosuit.legs.motivator.is_functional())
		to_chat(mover, SPAN_WARNING("Your motivators are damaged! You can't move!"))
		exosuit.SetMoveCooldown(15)
		return MOVEMENT_STOP
	if(exosuit.maintenance_protocols)
		to_chat(mover, SPAN_WARNING("Maintenance protocols are in effect."))
		exosuit.SetMoveCooldown(3)
		return MOVEMENT_STOP
	var/obj/item/cell/C = exosuit.get_cell()
	if(!C || !C.check_charge(exosuit.legs.power_use * CELLRATE))
		to_chat(mover, SPAN_WARNING("The power indicator flashes briefly."))
		exosuit.SetMoveCooldown(3) //On fast exosuits this got annoying fast
		return MOVEMENT_STOP

/datum/movement_handler/mob/delay/exosuit_mod/MayMove(mover, is_external)
	var/mob/living/exosuit/exosuit = host
	if(mover && (mover != exosuit) && (!(mover in exosuit.pilots)) && is_external)
		return MOVEMENT_PROCEED
	else if(world.time >= next_move)
		return MOVEMENT_PROCEED
	return MOVEMENT_STOP
