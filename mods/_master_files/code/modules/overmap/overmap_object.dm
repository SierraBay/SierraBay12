#define COMSIG_OVERMAP_MOTION_COMPLETE "overmap_motion_complete"

/obj/overmap
	var/datum/overmap_motion/motion
	/// Whole map periods traversed, independent of sampling frequency or velocity changes.
	var/list/map_winding = list(0, 0)
	var/last_motion_time

/obj/overmap/Destroy()
	QDEL_NULL(motion)
	return ..()

/// Core rendering and movement use position / 2 cells, not position cells.
/obj/overmap/proc/get_map_position()
	return list(x + position[1] / 2, y + position[2] / 2, z)

/obj/overmap/proc/get_unwrapped_map_position()
	var/list/point = get_map_position()
	point[1] += map_winding[1]
	point[2] += map_winding[2]
	return point

/obj/overmap/handle_wraparound(nx, ny)
	var/old_x = x
	var/old_y = y
	. = ..()
	map_winding[1] += old_x - x
	map_winding[2] += old_y - y

/obj/overmap/proc/get_motion()
	RETURN_TYPE(/datum/overmap_motion)
	if (!motion)
		motion = new
		motion.begin(src, isnull(last_motion_time) ? world.time : last_motion_time)
	return motion

/obj/overmap/proc/watch_motion(datum/listener, callback)
	get_motion()
	listener.RegisterSignal(src, COMSIG_OVERMAP_MOTION_COMPLETE, callback)

/obj/overmap/proc/unwatch_motion(datum/listener)
	listener.UnregisterSignal(src, COMSIG_OVERMAP_MOTION_COMPLETE)

/obj/overmap/process_movement(elapsed = world.time - SSobj.last_fire, timestamp = world.time)
	if (!motion)
		. = ..(elapsed, timestamp)
		last_motion_time = timestamp
		return

	motion.begin(src, timestamp - max(0, elapsed))
	. = ..(elapsed, timestamp)
	if (QDELETED(src))
		return

	motion.finish(src, timestamp - max(0, .))
	if (. > 0 && record_stopped_motion())
		motion.finish(src, timestamp)
	last_motion_time = timestamp
	SEND_SIGNAL(src, COMSIG_OVERMAP_MOTION_COMPLETE)

/obj/overmap/proc/record_stopped_motion()
	return TRUE

#undef COMSIG_OVERMAP_MOTION_COMPLETE
