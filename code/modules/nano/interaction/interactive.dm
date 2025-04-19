/*
	This state always returns STATUS_INTERACTIVE
*/
GLOBAL_TYPED_NEW(interactive_state, /datum/topic_state/interactive)

/datum/topic_state/interactive/can_use_topic(src_object, mob/user)
	return STATUS_INTERACTIVE
