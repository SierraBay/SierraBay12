/datum/movement_handler/mob/space/exosuit
	expected_host_type = /mob/living/exosuit

/datum/movement_handler/mob/space/exosuit/MayMove(mob/mover, is_external)
	if((mover != host) && is_external)
		return MOVEMENT_PROCEED

	if(!mob.has_gravity())
		allow_move = mob.Process_Spacemove(1)
		if(!allow_move)
			return MOVEMENT_STOP

	return MOVEMENT_PROCEED

//Функция попросту не нужна меху, но для того чтоб исключить рантайм вызываемый при стрельбе - поставил.
/mob/living/exosuit/proc/get_jetpack()
	return
