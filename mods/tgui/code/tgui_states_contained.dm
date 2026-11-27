/**
 * tgui state: contained_state
 *
 * Checks that the user is inside the src_object.
 */

GLOBAL_TYPED_NEW(tgui_contained_state, /datum/tgui_state/contained_state)

/datum/tgui_state/contained_state/can_use_topic(atom/src_object, mob/user)
	if(!src_object.contains(user))
		return STATUS_CLOSE
	return user.shared_tgui_interaction(src_object)
