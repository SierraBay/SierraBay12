/datum/movement_handler/mob/exosuit/MayMove(mob/mover, is_external)
	var/mob/living/exosuit/exosuit = host
	if((!(mover in exosuit.pilots) && mover != exosuit) || exosuit.incapacitated() || mover.incapacitated())
		return MOVEMENT_STOP
	if(LAZYLEN(exosuit.movement_blocked_by_shield))
		exosuit.undeploy_all_shields()
	if(!exosuit.L_leg && !exosuit.R_leg)
		to_chat(mover, SPAN_WARNING("У \The [exosuit] нет ни одной конечности, движение невозможно."))
		exosuit.SetMoveCooldown(3)
		return MOVEMENT_STOP
	if( (!exosuit.L_leg.motivator || !exosuit.L_leg.motivator.is_functional()) && (!exosuit.R_leg.motivator || !exosuit.R_leg.motivator.is_functional()))
		to_chat(mover, SPAN_WARNING("Обе конечности повреждены, движение невозможно"))
		exosuit.SetMoveCooldown(15)
		return MOVEMENT_STOP
	if(exosuit.maintenance_protocols)
		to_chat(mover, SPAN_WARNING("Протокол обслуживания активен."))
		exosuit.SetMoveCooldown(3)
		return MOVEMENT_STOP
	var/obj/item/cell/C = exosuit.get_cell()
	if(!C || !C.check_charge(exosuit.L_leg.power_use * CELLRATE) || !C.check_charge(exosuit.R_leg.power_use * CELLRATE))
		to_chat(mover, SPAN_WARNING("При движении джойстиком, кнопка Power мигает красным светом."))
		exosuit.SetMoveCooldown(3) //On fast exosuits this got annoying fast
		return MOVEMENT_STOP

/datum/movement_handler/mob/delay/exosuit/MayMove(mover, is_external)
	var/mob/living/exosuit/exosuit = host
	if(mover && (mover != exosuit) && (!(mover in exosuit.pilots)) && is_external)
		return MOVEMENT_PROCEED
	else if(world.time >= next_move)
		return MOVEMENT_PROCEED
	return MOVEMENT_STOP
