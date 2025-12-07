GLOBAL_TYPED_NEW(outside_state, /datum/topic_state/default/outside)

/datum/topic_state/default/outside/can_use_topic(src_object, mob/user)
	if(user in src_object)
		return STATUS_CLOSE
	return ..()
