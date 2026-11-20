// TGUI
/obj/machinery/tgui_status(mob/user, datum/tgui_state/state)
	if(!user?.client)
		return STATUS_CLOSE
	// Sierra's machine state retains its physical, camera and wired AI rules.
	if(state == GLOB.tgui_default_state)
		return CanUseTopic(user)
	return min(..(), CanUseTopic(user))

/obj/machinery/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(!.)
		CouldUseTopic(usr)

