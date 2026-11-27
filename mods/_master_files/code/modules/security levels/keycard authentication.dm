var/global/captain_access_claimed = FALSE

/obj/machinery/keycard_auth/trigger_event()
	. = ..()
	if(event == "Claim Captain Access")
		claim_captain_access()

/obj/machinery/keycard_auth/proc/claim_captain_access()
	if(captain_access_claimed)
		if(event_triggered_by)
			to_chat(event_triggered_by, SPAN_WARNING("Captain access has already been claimed by someone else."))
		return
	if(!event_triggered_by)
		return
	var/obj/item/card/id/ID = event_triggered_by.GetIdCard()
	if(!ID)
		to_chat(event_triggered_by, SPAN_WARNING("No ID card found to grant captain access to."))
		return
	captain_access_claimed = TRUE
	ID.access |= get_all_station_access()
	ID.access |= access_captain
	to_chat(event_triggered_by, SPAN_NOTICE("\The [src] grants you full captain access!"))
	visible_message(SPAN_NOTICE("\The [src] flashes green and prints a confirmation chit."))
	log_and_message_admins("claimed captain access through [src] with ID [ID.registered_name] ([ID.type]).", event_triggered_by)
	var/area/request_area = get_area(src)
	command_announcement.Announce("Emergency captain-level access request approved for [event_triggered_by.real_name] from [request_area ? request_area.name : "an unknown location"].", "Emergency Access Granted")

/obj/machinery/keycard_auth/interact(mob/user)
	user.set_machine(src)

	var/dat = "<h1>Keycard Authentication Device</h1>"

	dat += "This device is used to trigger some high security events. It requires the simultaneous swipe of two high-level ID cards."
	dat += "<br><hr><br>"

	if(screen == 1)
		dat += "Select an event to trigger:<ul>"

		var/singleton/security_state/security_state = GET_SINGLETON(GLOB.using_map.security_state)
		if(security_state.current_security_level == security_state.severe_security_level)
			dat += "<li>Cannot modify the alert level at this time: [security_state.severe_security_level.name] engaged.</li>"
		else
			if(security_state.current_security_level == security_state.high_security_level)
				dat += "<li><a href='byond://?src=\ref[src];triggerevent=Revert alert'>Disengage [security_state.high_security_level.name]</A></li>"
			else
				dat += "<li><a href='byond://?src=\ref[src];triggerevent=Red alert'>Engage [security_state.high_security_level.name]</A></li>"

		if(!config.ert_admin_call_only)
			dat += "<li><a href='byond://?src=\ref[src];triggerevent=Emergency Response Team'>Emergency Response Team</A></li>"

		dat += "<li><a href='byond://?src=\ref[src];triggerevent=Grant Emergency Maintenance Access'>Grant Emergency Maintenance Access</A></li>"
		dat += "<li><a href='byond://?src=\ref[src];triggerevent=Revoke Emergency Maintenance Access'>Revoke Emergency Maintenance Access</A></li>"
		dat += "<li><a href='byond://?src=\ref[src];triggerevent=Grant Nuclear Authorization Code'>Grant Nuclear Authorization Code</A></li>"
		if(captain_access_claimed)
			dat += "<li>Claim Captain Access - <i>already claimed</i></li>"
		else
			dat += "<li><a href='byond://?src=\ref[src];triggerevent=Claim Captain Access'>Claim Captain Access</A></li>"
		dat += "</ul>"
		show_browser(user, dat, "window=keycard_auth;size=500x250")
	if(screen == 2)
		dat += "Please swipe your card to authorize the following event: <b>[event]</b>"
		dat += "<p><a href='byond://?src=\ref[src];reset=1'>Back</A>"
		show_browser(user, dat, "window=keycard_auth;size=500x250")
	return
