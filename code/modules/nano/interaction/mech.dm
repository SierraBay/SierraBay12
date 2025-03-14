GLOBAL_TYPED_NEW(mech_state, /datum/topic_state/physical/mech)

/datum/topic_state/physical/mech/can_use_topic(mob/living/exosuit/src_object, mob/user)
	if(istype(src_object))
		if((user in src_object.pilots) || (user == src_object))
			return ..()
	return STATUS_CLOSE
