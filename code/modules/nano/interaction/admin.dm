/*
	This state checks that the user is an admin, end of story
*/
GLOBAL_TYPED_NEW(admin_state, /datum/topic_state/admin_state)
GLOBAL_TYPED_NEW(debug_admin_state, /datum/topic_state/debug_admin_state)

/datum/topic_state/admin_state/can_use_topic(src_object, mob/user)
	return check_rights(R_ADMIN, 0, user) ? STATUS_INTERACTIVE : STATUS_CLOSE

/datum/topic_state/debug_admin_state/can_use_topic(src_object, mob/user)
	return check_rights(R_DEBUG, 0, user) ? STATUS_INTERACTIVE : STATUS_CLOSE
