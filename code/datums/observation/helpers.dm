/********************
* Movement Handling *
********************/
/atom/movable/Entered(atom/movable/am, atom/old_loc)
	. = ..()

	am.register_signal(src, SIGNAL_DIR_SET, /atom/proc/recursive_dir_set, TRUE)
	am.register_signal(src, SIGNAL_MOVED, /atom/movable/proc/recursive_move, TRUE)

/atom/movable/Exited(atom/movable/am, atom/old_loc)
	. = ..()

	am.unregister_signal(src, SIGNAL_DIR_SET)
	am.unregister_signal(src, SIGNAL_MOVED)

/atom/movable/proc/recursive_move(atom/movable/am, old_loc, new_loc)
	SEND_SIGNAL(src, SIGNAL_MOVED, src, old_loc, new_loc)

/atom/movable/proc/move_to_turf(atom/movable/am, old_loc, new_loc)
	var/turf/T = get_turf(new_loc)

	if(T && T != loc)
		forceMove(T)

/atom/movable/proc/move_to_loc_or_null(atom/movable/am, old_loc, new_loc)
	if(new_loc != loc)
		forceMove(new_loc)

// Similar to above but we also follow into nullspace
/atom/movable/proc/move_to_turf_or_null(atom/movable/am, old_loc, new_loc)
	var/turf/T = get_turf(new_loc)
	if(T != loc)
		forceMove(T)


/**
 * Handler for setting an atom's dir when mimicking movements. Calls `set_dir()`.
 *
 * **Parameters**:
 * - `a` - The atom triggering the event.
 * - `old_dir` - The atom's prior `dir`.
 * - `new_dir` - The new `dir` to set.
 */
/atom/proc/recursive_dir_set(atom/a, old_dir, new_dir)
	set_dir(new_dir)

// Sometimes you just want to end yourself
/datum/proc/qdel_self()
	qdel(src)
