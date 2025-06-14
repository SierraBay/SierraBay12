/client
	var/list/mouse_move_handlers = list()

/client/MouseEntered(atom/hoverOn)
	. = ..()

	if (GAME_STATE <= RUNLEVEL_SETUP || !screentip.show)
		return

	screen |= screentip
	screentip.set_text(hoverOn.name)

	if(LAZYLEN(mouse_move_handlers))
		for(var/atom/handler in mouse_move_handlers)
			handler.update_current_mouse_position(hoverOn)

/atom/proc/update_current_mouse_position()
	return
