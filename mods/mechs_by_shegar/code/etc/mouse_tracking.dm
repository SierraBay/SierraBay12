/client
	var/list/mouse_move_handlers

/atom/proc/update_current_mouse_position(atom/input_mouse_position)
	return

/atom/MouseEntered(location, control, params)
	. = ..()
	var/client/C = usr && usr.client
	if(!C || !LAZYLEN(C.mouse_move_handlers))
		return
	for(var/atom/handler in C.mouse_move_handlers)
		handler.update_current_mouse_position(src)
