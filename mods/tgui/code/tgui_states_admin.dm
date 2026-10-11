/**
 * tgui state: admin_state
 *
 * Checks that the user is an admin, end-of-story.
 */

GLOBAL_TYPED_NEW(tgui_admin_state, /datum/tgui_state/admin_state)

/datum/tgui_state/admin_state/can_use_topic(src_object, mob/user)
	if(check_rights(user.client, R_ADMIN))
		return STATUS_INTERACTIVE
	return STATUS_CLOSE
