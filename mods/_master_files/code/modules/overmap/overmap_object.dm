#define COMSIG_OVERMAP_MOTION_COMPLETE "overmap_motion_complete"

/obj/overmap
	var/datum/overmap_motion/motion

/obj/overmap/Destroy()
	QDEL_NULL(motion)
	return ..()

/// Core rendering and movement use position / 2 cells, not position cells.
/obj/overmap/proc/get_map_position()
	return list(x + position[1] / 2, y + position[2] / 2, z)

/obj/overmap/proc/get_motion()
	RETURN_TYPE(/datum/overmap_motion)
	if (!motion)
		motion = new
		motion.begin(src, world.time)
	return motion

/obj/overmap/proc/watch_motion(datum/listener, callback)
	get_motion()
	listener.RegisterSignal(src, COMSIG_OVERMAP_MOTION_COMPLETE, callback)

/obj/overmap/proc/unwatch_motion(datum/listener)
	listener.UnregisterSignal(src, COMSIG_OVERMAP_MOTION_COMPLETE)

/obj/overmap/process_movement(elapsed = world.time - SSobj.last_fire)
	if (!motion)
		return ..(elapsed)
	motion.begin(src, world.time - max(0, elapsed))
	. = ..(elapsed)
	if (QDELETED(src))
		return
	motion.finish(src, world.time)
	SEND_SIGNAL(src, COMSIG_OVERMAP_MOTION_COMPLETE)

#undef COMSIG_OVERMAP_MOTION_COMPLETE
