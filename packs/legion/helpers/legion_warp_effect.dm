/**
 * Creates a warp effect on the given target turf.
 */
/proc/legion_warp_effect(turf/target)
	if (!target)
		return
	new /obj/explosion(target)
	playsound(target, GLOB.legion_warp_sound, 25, TRUE)
