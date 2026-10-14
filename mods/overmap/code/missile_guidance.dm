/datum/missile_guidance
	var/weakref/target_ref
	var/turf/last_known_position
	var/list/last_known_coordinates
	var/target_set_time = 0
	var/coasting = FALSE

/datum/missile_guidance/Destroy()
	target_ref = null
	last_known_position = null
	last_known_coordinates = null
	return ..()

/datum/missile_guidance/proc/get_target()
	var/atom/target = target_ref?.resolve()
	if (QDELETED(target))
		return null
	remember_target(target)
	return target

/datum/missile_guidance/proc/set_target(atom/new_target)
	target_ref = weakref(new_target)
	target_set_time = world.time
	remember_target(new_target)
	coasting = FALSE

/// Remember numerical coordinates without owning the target's movement history.
/datum/missile_guidance/proc/remember_target(atom/target)
	last_known_position = get_turf(target)
	last_known_coordinates = null
	if (!last_known_position)
		return
	var/obj/overmap/object = target
	last_known_coordinates = istype(object) ? object.get_map_position() : list(last_known_position.x, last_known_position.y, last_known_position.z)

/// Null preserves velocity; a zero vector stops. Other vectors supply a continuous bearing.
/datum/missile_guidance/proc/get_course(obj/overmap/projectile/projectile, pursuit_speed = 0)
	ASSERT(istype(projectile))
	var/atom/target = get_target()
	if (!last_known_position)
		return null
	if (coasting)
		return get_coasting_course(projectile)
	if (!target && has_reached_last_position(projectile))
		coasting = TRUE
		return get_coasting_course(projectile)
	if (isturf(target) && get_turf(projectile) == target)
		return list(0, 0)
	return get_pursuit_offset(projectile, target, pursuit_speed)

/datum/missile_guidance/proc/has_reached_last_position(obj/overmap/projectile/projectile)
	if (projectile.z != last_known_position.z)
		return FALSE
	var/list/offset = get_target_offset(projectile, last_known_position, last_known_coordinates)
	return offset[1] ** 2 + offset[2] ** 2 <= projectile.contact_radius ** 2

/datum/missile_guidance/proc/get_coasting_course(obj/overmap/projectile/projectile)
	if (projectile.is_moving())
		return null
	return list(SIGN((projectile.dir & EAST) - (projectile.dir & WEST)), SIGN((projectile.dir & NORTH) - (projectile.dir & SOUTH)))

/datum/missile_guidance/proc/get_pursuit_offset(obj/overmap/projectile/projectile, atom/target, pursuit_speed)
	var/list/offset = get_target_offset(projectile, last_known_position, last_known_coordinates)
	var/obj/overmap/moving_target = target
	if (!istype(moving_target) || !moving_target.movable || moving_target.halted || !moving_target.is_moving())
		return offset
	var/list/intercept = get_intercept_offset(projectile, moving_target, min(pursuit_speed, projectile.max_speed))
	if (intercept && (intercept[1] || intercept[2]))
		return intercept
	return offset

/// The edge turfs are skipped by handle_wraparound(): playable coordinates are 2..size-1.
/datum/missile_guidance/proc/get_wrap_period(obj/overmap/projectile/projectile, turf/destination)
	if (!projectile.wraparound || projectile.delete_on_edge || projectile.z != destination.z || projectile.z != GLOB.using_map.overmap_z)
		return 0
	return max(0, GLOB.using_map.overmap_size - 2)

/datum/missile_guidance/proc/get_target_offset(obj/overmap/projectile/projectile, turf/destination, list/coordinates)
	if (!coordinates)
		coordinates = list(destination.x, destination.y)
	var/list/origin = projectile.get_map_position()
	var/delta_x = coordinates[1] - origin[1]
	var/delta_y = coordinates[2] - origin[2]
	var/period = get_wrap_period(projectile, destination)
	if (period)
		delta_x = wrap_offset(delta_x, period, projectile.speed[1])
		delta_y = wrap_offset(delta_y, period, projectile.speed[2])
	return list(delta_x, delta_y)

/datum/missile_guidance/proc/wrap_offset(delta, period, current_speed)
	if (delta > period / 2)
		return delta - period
	if (delta < -period / 2)
		return delta + period
	if (abs(delta) == period / 2 && current_speed && SIGN(delta) != SIGN(current_speed))
		return -delta
	return delta

/// Check neighbouring images of the target so a meeting may also occur across an edge.
/datum/missile_guidance/proc/get_intercept_offset(obj/overmap/projectile/projectile, obj/overmap/target, pursuit_speed)
	if (projectile.z != target.z || pursuit_speed <= 0)
		return null
	var/list/offset = get_target_offset(projectile, get_turf(target), target.get_map_position())
	var/period = get_wrap_period(projectile, get_turf(target))
	var/list/images = period ? list(0, -period, period) : list(0)
	var/list/velocity = list(abs(target.speed[1]) >= target.min_speed ? target.speed[1] / 2 : 0, abs(target.speed[2]) >= target.min_speed ? target.speed[2] / 2 : 0)
	var/time_limit = get_prediction_limit(target, period)
	var/list/best
	for (var/image_x in images)
		for (var/image_y in images)
			var/list/candidate = get_intercept_candidate(offset[1] + image_x, offset[2] + image_y, velocity[1], velocity[2], pursuit_speed / 2, time_limit)
			if (candidate && (!best || candidate[1] < best[1]))
				best = candidate
	return best ? list(best[2], best[3]) : null

/datum/missile_guidance/proc/get_intercept_candidate(delta_x, delta_y, velocity_x, velocity_y, pursuit_speed, time_limit)
	var/meeting_time = get_intercept_time(delta_x, delta_y, velocity_x, velocity_y, pursuit_speed, time_limit)
	if (isnull(meeting_time))
		return null
	return list(meeting_time, delta_x + velocity_x * meeting_time, delta_y + velocity_y * meeting_time)

/// Straight-line interception uses the same scalar speed as normalized propulsion.
/datum/missile_guidance/proc/get_intercept_time(delta_x, delta_y, velocity_x, velocity_y, pursuit_speed, time_limit)
	var/a = velocity_x ** 2 + velocity_y ** 2 - pursuit_speed ** 2
	var/b = 2 * (delta_x * velocity_x + delta_y * velocity_y)
	var/c = delta_x ** 2 + delta_y ** 2
	var/meeting_time = c ? positive_intercept_root(a, b, c) : 0
	if (!isnull(time_limit) && !isnull(meeting_time) && meeting_time > time_limit)
		return null
	return meeting_time

/datum/missile_guidance/proc/positive_intercept_root(a, b, c)
	if (abs(a) < 0.000000001)
		return b < 0 ? -c / b : null
	var/discriminant = b ** 2 - 4 * a * c
	if (discriminant < 0)
		return null
	var/root = sqrt(discriminant)
	var/first = (-b - root) / (2 * a)
	var/second = (-b + root) / (2 * a)
	if (first < 0)
		return second >= 0 ? second : null
	return second >= 0 ? min(first, second) : first

/// Do not extrapolate a non-wrapping or disposable target beyond its map edge.
/datum/missile_guidance/proc/get_prediction_limit(obj/overmap/target, allow_wrap)
	if (allow_wrap && target.wraparound && !target.delete_on_edge)
		return null
	var/time_limit
	var/list/coordinates = target.get_map_position()
	for (var/axis in 1 to 2)
		var/velocity = target.speed[axis]
		if (abs(velocity) < target.min_speed)
			continue
		var/edge = velocity > 0 ? GLOB.using_map.overmap_size - 0.5 : 1.5
		var/edge_time = max(0, (edge - coordinates[axis]) / (velocity / 2))
		time_limit = isnull(time_limit) ? edge_time : min(time_limit, edge_time)
	return time_limit

/datum/missile_guidance/proc/is_target_valid(obj/overmap/site, obj/item/missile_equipment/thruster/thruster)
	if (istype(site, /obj/overmap/event/leviathan))
		return TRUE
	var/obj/overmap/visitable/visitable = site
	return istype(visitable) && (visitable.sector_flags & OVERMAP_SECTOR_IN_SPACE) && !(visitable.sector_flags & OVERMAP_SECTOR_UNTARGETABLE) && LAZYLEN(visitable.map_z) && !(thruster.z in visitable.map_z)

/datum/missile_guidance/proc/should_enter(obj/overmap/site)
	return site == get_target()

/datum/missile_guidance/proc/get_local_target(obj/structure/missile/missile, target_range, z_level)
	return pick_turf_in_range(get_turf(missile), target_range, list(
		GLOBAL_PROC_REF(is_not_space_turf),
		GLOBAL_PROC_REF(is_not_open_space)
	))

/// An impact request is executed by the missile, never by the guidance datum.
/datum/missile_guidance/proc/get_impact_turf(z_level)
	return null

/datum/missile_guidance/proc/get_sensors(obj/item/missile_equipment/thruster/thruster)
	var/turf/launcher_turf = get_turf(thruster)
	if (!launcher_turf)
		return null
	var/obj/overmap/visitable/ship/ship = waypoint_sector(launcher_turf)
	if (!istype(ship))
		return null
	for (var/obj/machinery/shipsensors/sensors in SSmachines.machinery)
		if (ship.check_ownership(sensors) && sensors.powered())
			return sensors
	return null

/datum/missile_guidance/proc/get_possible_targets(obj/item/missile_equipment/thruster/thruster, obj/machinery/shipsensors/sensors)
	var/list/possible_targets = list()
	var/turf/launcher_turf = get_turf(thruster)
	var/obj/overmap/visitable/ship/ship = waypoint_sector(launcher_turf)
	for (var/turf/location in trange(sensors.range, get_turf(ship)))
		for (var/obj/overmap/site in location)
			if (is_target_valid(site, thruster))
				possible_targets["[site.name] ([site.x]-[site.y])"] = site
	return possible_targets

/datum/missile_guidance/proc/select_target(obj/item/missile_equipment/thruster/thruster, mob/user)
	var/obj/machinery/shipsensors/sensors = get_sensors(thruster)
	if (!sensors)
		to_chat(user, SPAN_NOTICE("The targeting computer display indicates that there is no valid sensor array to utilize for target seeking."))
		return null
	var/list/possible_targets = get_possible_targets(thruster, sensors)
	if (!length(possible_targets))
		to_chat(user, SPAN_NOTICE("The targeting computer display indicates that there are no valid targets."))
		return null
	var/selected_target = input(user, "Select a target") as null|anything in possible_targets
	if (!selected_target || QDELETED(src) || QDELETED(thruster))
		return null
	return possible_targets[selected_target]

/datum/missile_guidance/proc/configure(obj/item/missile_equipment/thruster/thruster, mob/user)
	var/atom/selected_target = select_target(thruster, user)
	if (QDELETED(src) || QDELETED(thruster))
		return TRUE
	if (!QDELETED(selected_target) && is_target_valid(selected_target, thruster))
		set_target(selected_target)
		to_chat(user, SPAN_NOTICE("Target successfully set to [selected_target]."))
	return TRUE

/datum/missile_guidance/hunter/is_target_valid(obj/overmap/site, obj/item/missile_equipment/thruster/thruster)
	return istype(site, /obj/overmap/projectile)

/datum/missile_guidance/point/configure(obj/item/missile_equipment/thruster/thruster, mob/user)
	var/turf/destination = select_coordinates(user, "target", GLOB.using_map.overmap_size, GLOB.using_map.overmap_size, GLOB.using_map.overmap_z, 2, 2)
	if (QDELETED(src) || QDELETED(thruster))
		return TRUE
	if (!destination)
		to_chat(user, SPAN_NOTICE("The targeting computer display lets you know that's an invalid target."))
		return TRUE
	set_target(destination)
	to_chat(user, SPAN_NOTICE("Target successfully set to [destination]."))
	return TRUE

/datum/missile_guidance/point/should_enter(obj/overmap/site)
	var/atom/target = get_target()
	return target && site.x == target.x && site.y == target.y && site.z == target.z

/datum/missile_guidance/planet
	var/turf/planetary_target

/datum/missile_guidance/planet/Destroy()
	planetary_target = null
	return ..()

/datum/missile_guidance/planet/set_target(atom/new_target)
	planetary_target = null
	return ..()

/datum/missile_guidance/planet/is_target_valid(obj/overmap/site, obj/item/missile_equipment/thruster/thruster)
	return istype(site, /obj/overmap/visitable/sector/exoplanet)

/datum/missile_guidance/planet/get_impact_turf(z_level)
	if (!planetary_target || z_level != planetary_target.z)
		return null
	var/turf/impact_turf = planetary_target
	for (var/turf/location in shuffle(trange(3, planetary_target)))
		if (!location.contains_dense_objects())
			return location
	return impact_turf

/datum/missile_guidance/planet/configure(obj/item/missile_equipment/thruster/thruster, mob/user)
	var/obj/overmap/visitable/sector/exoplanet/planet = select_target(thruster, user)
	if (!istype(planet) || QDELETED(planet) || !LAZYLEN(planet.map_z))
		return TRUE
	var/turf/destination = select_coordinates(user, "planetary target", world.maxx, world.maxy, planet.map_z[length(planet.map_z)])
	if (QDELETED(src) || QDELETED(thruster) || QDELETED(planet))
		return TRUE
	if (!destination || destination.contains_dense_objects())
		to_chat(user, SPAN_NOTICE("The targeting computer display indicates that the target wasn't valid."))
		return TRUE
	set_target(planet)
	planetary_target = destination
	to_chat(user, SPAN_NOTICE("Planetary target successfully set to [destination.x]-[destination.y]."))
	return TRUE

/datum/missile_guidance/proc/select_coordinates(mob/user, prompt, max_x, max_y, target_z, min_x = 1, min_y = 1)
	var/target_x = input(user, "Enter [prompt] X coordinate", "Input coordinates") as null|num
	if (isnull(target_x))
		return null
	var/target_y = input(user, "Enter [prompt] Y coordinate", "Input coordinates") as null|num
	return resolve_coordinates(target_x, target_y, max_x, max_y, target_z, min_x, min_y)

/datum/missile_guidance/proc/resolve_coordinates(target_x, target_y, max_x, max_y, target_z, min_x = 1, min_y = 1)
	if (isnull(target_x) || isnull(target_y) || target_x < min_x || target_x >= max_x || target_y < min_y || target_y >= max_y)
		return null
	return locate(target_x, target_y, target_z)
