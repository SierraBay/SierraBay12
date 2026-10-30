/// Odyssey sector-jump countdown on station status displays (same radio channel as shuttle ETA).

/proc/odyssey_status_display_jump_timeleft()
	var/obj/machinery/bluespace_drive/D = odyssey_find_ship_bluespace_drive()
	if (!istype(D) || !D.jumping || !D.odyssey_campaign_jump || !D.jump_end_time)
		return -1
	return max(0, round((D.jump_end_time - world.time) / 10))


/proc/odyssey_status_display_format_timer(timeleft)
	if (timeleft < 0)
		return ""
	return "[pad_left(num2text(round(timeleft / 60)), 2, "0")]:[pad_left(num2text(timeleft % 60), 2, "0")]"


/proc/odyssey_post_status_jump_countdown()
	post_status("bluespace")


/proc/odyssey_clear_status_jump_countdown()
	post_status("blank")


/obj/machinery/status_display/Process()
	if (mode == STATUS_DISPLAY_BLUESPACE_JUMP)
		if (MACHINE_IS_BROKEN(src))
			return PROCESS_KILL
		if (!is_powered())
			remove_display()
			set_light(0)
			return
		update()
		return
	return ..()


/obj/machinery/status_display/update()
	if (mode != STATUS_DISPLAY_BLUESPACE_JUMP)
		return ..()

	remove_display()
	if (MACHINE_IS_BROKEN(src))
		return
	if (friendc && !ignore_friendc)
		set_picture("ai_friend")
		return 1

	var/timeleft = odyssey_status_display_jump_timeleft()
	if (timeleft < 0)
		mode = STATUS_DISPLAY_BLANK
		return ..()

	message1 = "JUMP"
	message2 = timeleft > 0 ? odyssey_status_display_format_timer(timeleft) : "NOW"
	update_display(message1, message2)
	return 1


/obj/machinery/status_display/receive_signal(datum/signal/signal)
	if (signal?.data["command"] == "bluespace")
		mode = STATUS_DISPLAY_BLUESPACE_JUMP
		update()
		return
	return ..()
