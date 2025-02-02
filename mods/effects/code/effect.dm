//ANOMALIES EFFECT

#define GRAV_EFFECT_PLANE -35
#define GRAV_EFFECT_TARGET "*grav"

#define SPIRAL_EFFECT_PLANE -34
#define SPIRAL_EFFECT_TARGET "*spir"

/atom/movable/renderer/grav
	name = "Grav Effect"
	group = RENDER_GROUP_NONE
	plane = GRAV_EFFECT_PLANE
	render_target_name = GRAV_EFFECT_TARGET
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	renderer_flags = RENDERER_MAIN | RENDERER_SHARED



/atom/movable/renderer/spir
	name = "Spiral Effect"
	group = RENDER_GROUP_NONE
	plane = SPIRAL_EFFECT_PLANE
	render_target_name = SPIRAL_EFFECT_TARGET
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	renderer_flags = RENDERER_MAIN | RENDERER_SHARED



/atom/movable/renderer/scene_group/Initialize()
	. = ..()
	remove_filter("Grav Effect")
	remove_filter("Warp Effect")
	remove_filter("Spiral Effect")

	add_filter("Grav Effect", 5, displacement_map_filter(render_source = GRAV_EFFECT_TARGET, size = 3))
	add_filter("Warp Effect", 6, displacement_map_filter(render_source = "*warp", size = 5))
	add_filter("Spiral Effect", 7, displacement_map_filter(render_source = SPIRAL_EFFECT_TARGET, size = 3))


/obj/effect/gravity
	plane = GRAV_EFFECT_PLANE
	appearance_flags = PIXEL_SCALE | NO_CLIENT_COLOR
	icon = 'mods/effects/icons/288x288.dmi'
	icon_state = "gravitational_anti_lens"
	pixel_x = -128
	pixel_y = -128
	z_flags = ZMM_IGNORE

/obj/effect/gravity/New(loc, ...)
	. = ..()
	add_filter("ripple", 1, ripple_filter(radius = 0, size = 250, falloff = 0.5, repeat = 100))
	add_filter("layer", 2, layering_filter(icon = icon(icon, "gravitational_lens"), transform = matrix().Scale(0.15, 0.15)))
	START_PROCESSING(SSobj, src)

/obj/effect/gravity/Process()
	animate(src, time = 6, transform = matrix().Scale(0.5, 0.5))
	animate(time = 14, transform = matrix(), flags = ANIMATION_PARALLEL)
	animate(get_filter("ripple"), radius = 230, size = 0, time = 14, flags = ANIMATION_PARALLEL)
	animate(radius = 0, size = 150, time = 0)

/obj/effect/spiral
	plane = SPIRAL_EFFECT_PLANE
	appearance_flags = PIXEL_SCALE | NO_CLIENT_COLOR
	icon = 'mods/effects/icons/288x288.dmi'
	icon_state = "gravitational_swirl"
	pixel_x = -128
	pixel_y = -128
	z_flags = ZMM_IGNORE

/obj/effect/spiral/New(loc, ...)
	. = ..()
	add_filter("layer", 1, layering_filter(icon = icon(icon, "gravitational_spirl"), transform = matrix().Scale(0.15, 0.15)))
	add_filter("wave_filter", 2, wave_filter(x = 25, y = 25, size = 100, offset = 50))
	add_filter("ripple", 3, ripple_filter(radius = 0, size = 150, falloff = 0.5, repeat = 100))
	START_PROCESSING(SSobj, src)

/obj/effect/spiral/Process()
	animate(src, time = 6, transform = matrix().Scale(0.5, 0.5))
	animate(time = 14, transform = matrix(), flags = ANIMATION_PARALLEL)
	animate(get_filter("wave_filter"), radius = 50, size = 0, time = 14, flags = ANIMATION_PARALLEL)
	animate(get_filter("ripple"), radius = 230, size = 0, time = 14, flags = ANIMATION_PARALLEL)

/obj/machinery/bluespacedrive
	var/obj/effect/gravity/grav

/obj/machinery/bluespacedrive/New()
	. = ..()
	create_effect()

/obj/machinery/bluespacedrive/Destroy()
	. = ..()
	qdel(grav)

/obj/machinery/bluespacedrive/proc/create_effect()
	var/turf/turf = get_turf(src)
	grav = new(turf)

/**
 * This proc is called on a datum on every "cycle" if it is being processed by a subsystem. The time between each cycle is determined by the subsystem's "wait" setting.
 * You can start and stop processing a datum using the START_PROCESSING and STOP_PROCESSING defines.
 *
 * Since the wait setting of a subsystem can be changed at any time, it is important that any rate-of-change that you implement in this proc is multiplied by the seconds_per_tick that is sent as a parameter,
 * Additionally, any "prob" you use in this proc should instead use the SPT_PROB define to make sure that the final probability per second stays the same even if the subsystem's wait is altered.
 * Examples where this must be considered:
 * - Implementing a cooldown timer, use `mytimer -= seconds_per_tick`, not `mytimer -= 1`. This way, `mytimer` will always have the unit of seconds
 * - Damaging a mob, do `L.adjustFireLoss(20 * seconds_per_tick)`, not `L.adjustFireLoss(20)`. This way, the damage per second stays constant even if the wait of the subsystem is changed
 * - Probability of something happening, do `if(SPT_PROB(25, seconds_per_tick))`, not `if(prob(25))`. This way, if the subsystem wait is e.g. lowered, there won't be a higher chance of this event happening per second
 *
 * If you override this do not call parent, as it will return PROCESS_KILL. This is done to prevent objects that dont override process() from staying in the processing list
 */


/proc/cmp_filter_data_priority(list/A, list/B)
	return A["priority"] - B["priority"]

/datum
	var/list/filter_data

/datum/proc/add_filter(name, priority, list/params)
	LAZYINITLIST(filter_data)
	var/list/p = params.Copy()
	p["priority"] = priority
	filter_data[name] = p
	update_filters()

/datum/proc/update_filters()
	var/atom/A = src//Here's a "Fint Ushami" and this will work even with images.
	A.filters = null
	filter_data = sortTim(filter_data, GLOBAL_PROC_REF(cmp_filter_data_priority), TRUE)
	for(var/f in filter_data)
		var/list/data = filter_data[f]
		var/list/arguments = data.Copy()
		arguments -= "priority"
		A.filters += filter(arglist(arguments))
	UNSETEMPTY(filter_data)


/datum/proc/transition_filter(name, time, list/new_params, easing, loop)
	var/filter = get_filter(name)
	if(!filter)
		return

	var/list/old_filter_data = filter_data[name]

	var/list/params = old_filter_data.Copy()
	for(var/thing in new_params)
		params[thing] = new_params[thing]

	animate(filter, new_params, time = time, easing = easing, loop = loop)
	for(var/param in params)
		filter_data[name][param] = params[param]

/datum/proc/change_filter_priority(name, new_priority)
	if(!filter_data || !filter_data[name])
		return

	filter_data[name]["priority"] = new_priority
	update_filters()

/datum/proc/get_filter(name)
	var/atom/A = src//Here's a "Fint Ushami" and this will work even with images.
	if(filter_data && filter_data[name])
		return A.filters[filter_data.Find(name)]

/datum/proc/remove_filter(name_or_names)
	if(!filter_data)
		return

	var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)

	for(var/name in names)
		if(filter_data[name])
			filter_data -= name
	update_filters()

/datum/proc/clear_filters()
	var/atom/A = src//Here's a "Fint Ushami" and this will work even with images.
	filter_data = null
	A.filters = null



#undef GRAV_EFFECT_PLANE
#undef GRAV_EFFECT_TARGET
