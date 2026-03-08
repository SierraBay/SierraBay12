/obj/machinery/status_display/supply_display
	ignore_friendc = 1
	var/last_rendered_mode
	var/last_rendered_message1
	var/last_rendered_message2
	var/last_rendered_border_signature

/obj/machinery/status_display/supply_display/proc/invalidate_custom_render_cache()
	last_rendered_mode = null
	last_rendered_message1 = null
	last_rendered_message2 = null
	last_rendered_border_signature = null

/obj/machinery/status_display/supply_display/remove_display()
	invalidate_custom_render_cache()
	return ..()

/obj/machinery/status_display/supply_display/update()
	if(mode == STATUS_DISPLAY_CUSTOM)
		var/border_signature = ""
		if(status_display_show_alert_border)
			var/singleton/security_state/security_state = GET_SINGLETON(GLOB.using_map.security_state)
			var/singleton/security_level/sl = security_state.current_security_level
			border_signature = sl ? "[sl.icon]|[sl.alert_border]" : ""

		var/new_message1 = "CARGO"
		var/new_message2 = ""

		var/datum/shuttle/autodock/ferry/supply/shuttle = SSsupply.shuttle
		if(!shuttle)
			new_message2 = "Error"
		else if(shuttle.has_arrive_time())
			new_message2 = get_supply_shuttle_timer()
			if(length(new_message2) > CHARS_PER_LINE)
				new_message2 = "Error"
		else if(shuttle.is_launching())
			if(shuttle.at_station())
				new_message2 = "Launch"
			else
				new_message2 = "ETA"
		else
			if(shuttle.at_station())
				new_message2 = "Docked"
			else
				new_message1 = ""

		message1 = new_message1
		message2 = new_message2
		if(last_rendered_mode != mode || last_rendered_message1 != message1 || last_rendered_message2 != message2 || last_rendered_border_signature != border_signature)
			remove_display()
			update_display(message1, message2)
			if(status_display_show_alert_border)
				add_alert_border_to_display()
			last_rendered_mode = mode
			last_rendered_message1 = message1
			last_rendered_message2 = message2
			last_rendered_border_signature = border_signature
		return 1

	invalidate_custom_render_cache()
	return ..()

/obj/machinery/status_display/supply_display/receive_signal/(datum/signal/signal)
	if(signal.data["command"] == "supply")
		mode = STATUS_DISPLAY_CUSTOM
	else
		..(signal)
