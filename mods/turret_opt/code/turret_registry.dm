#define TURRET_WATCH_MOBS (1)
#define TURRET_WATCH_METEORS (2)

/obj/machinery
	var/list/watched_turfs

/obj/machinery/proc/wake_up()
	return

/obj/machinery/proc/update_watch_area()
	return

var/global/list/turf_watched_by_mobs = list()
var/global/list/turf_watched_by_meteors = list()

/proc/register_turret_view(obj/machinery/turret, target_mask, list/view_turfs)
	unregister_turret_view(turret)

	if(!view_turfs || !length(view_turfs))
		return

	var/woken = FALSE

	if(target_mask & TURRET_WATCH_MOBS)
		for(var/turf/T in view_turfs)
			var/list/watchers = turf_watched_by_mobs[T]
			if(!watchers)
				watchers = list()
				turf_watched_by_mobs[T] = watchers
			watchers |= turret

			if(!woken && (locate(/mob/living) in T))
				turret.wake_up()
				woken = TRUE

	if(target_mask & TURRET_WATCH_METEORS)
		for(var/turf/T in view_turfs)
			var/list/watchers = turf_watched_by_meteors[T]
			if(!watchers)
				watchers = list()
				turf_watched_by_meteors[T] = watchers
			watchers |= turret

			if(!woken && (locate(/obj/meteor) in T))
				turret.wake_up()
				woken = TRUE

	turret.watched_turfs = view_turfs

/proc/unregister_turret_view(obj/machinery/turret)
	var/list/watched = turret.watched_turfs
	if(!watched)
		return

	for(var/turf/T in watched)
		var/list/watchers = turf_watched_by_mobs[T]
		if(watchers)
			watchers -= turret
			if(!length(watchers))
				turf_watched_by_mobs -= T

		watchers = turf_watched_by_meteors[T]
		if(watchers)
			watchers -= turret
			if(!length(watchers))
				turf_watched_by_meteors -= T

	turret.watched_turfs = null

// Event Handlers for dynamic LOS updates
/proc/on_turf_visibility_changed(turf/T)
	// When a turf's opacity or density changes, nearby turrets might need to refresh their view.
	// We scan a range around the changed turf.
	for(var/obj/machinery/porta_turret/PT in range(world.view, T))
		PT.update_watch_area()

	for(var/obj/machinery/pointdefense/PD in range(40, T))
		PD.update_watch_area()

/datum/turret_opt_init/New()
	GLOB.turf_changed_event.register(null, PROC_REF(on_turf_visibility_changed))
	GLOB.opacity_set_event.register(null, PROC_REF(on_turf_visibility_changed))
	GLOB.density_set_event.register(null, PROC_REF(on_turf_visibility_changed))

var/global/datum/turret_opt_init/turret_opt_init = new
