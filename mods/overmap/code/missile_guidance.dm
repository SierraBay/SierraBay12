#define MISSILE_GUIDANCE_ACQUIRE_ANGLE 15
#define MISSILE_GUIDANCE_REACQUIRE_ANGLE 60
#define MISSILE_GUIDANCE_ROUTE_MARGIN 0.9
#define MISSILE_GUIDANCE_MAX_TURN 179
#define MISSILE_GUIDANCE_INTERCEPT_ITERATIONS 12
#define MISSILE_GUIDANCE_ANGLE_TOLERANCE 0.0001
#define MISSILE_GUIDANCE_ROUTE_TOLERANCE 0.001

/datum/missile_guidance
	var/weakref/target_ref
	var/turf/last_known_position
	var/list/last_known_coordinates
	var/target_set_time = 0
	var/coasting = FALSE
	/// Pure PN is used after acquiring a closing interception course.
	var/navigation_constant = 3
	var/navigation_locked = FALSE
	/// Relative position of the selected target image, in map cells.
	var/list/navigation_offset
	var/list/navigation_origin
	var/list/navigation_target
	var/navigation_plan_time
	var/list/navigation_velocity

/datum/missile_guidance/Destroy()
	target_ref = null
	last_known_position = null
	last_known_coordinates = null
	reset_navigation()
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
	reset_navigation()

/datum/missile_guidance/proc/reset_navigation()
	navigation_locked = FALSE
	navigation_offset = null
	navigation_origin = null
	navigation_target = null
	navigation_plan_time = null
	navigation_velocity = null

/// Remember numerical coordinates without owning the target's movement history.
/datum/missile_guidance/proc/remember_target(atom/target)
	last_known_position = get_turf(target)
	last_known_coordinates = null
	if (!last_known_position)
		return

	var/obj/overmap/object = target
	last_known_coordinates = istype(object) ? object.get_map_position() : list(last_known_position.x, last_known_position.y, last_known_position.z)

/// Null preserves velocity; a zero vector stops. Other vectors supply a continuous bearing.
/datum/missile_guidance/proc/get_course(obj/overmap/projectile/projectile, elapsed = 0, pursuit_speed = 0, turn_rate = 0, timestamp = world.time)
	ASSERT(istype(projectile))
	var/atom/target = get_target()
	if (!last_known_position)
		return null

	if (coasting)
		reset_navigation()
		return get_coasting_course(projectile)

	if (!target && has_reached_last_position(projectile))
		coasting = TRUE
		reset_navigation()
		return get_coasting_course(projectile)

	if (isturf(target) && get_turf(projectile) == target)
		return list(0, 0)

	return get_pursuit_offset(projectile, target, elapsed, pursuit_speed, turn_rate, timestamp)

/datum/missile_guidance/proc/has_reached_last_position(obj/overmap/projectile/projectile)
	if (projectile.z != last_known_position.z)
		return FALSE

	var/list/offset = get_target_offset(projectile, last_known_position, last_known_coordinates)
	return offset[1] ** 2 + offset[2] ** 2 <= projectile.contact_radius ** 2

/datum/missile_guidance/proc/get_coasting_course(obj/overmap/projectile/projectile)
	if (projectile.is_moving())
		return null

	return list(SIGN((projectile.dir & EAST) - (projectile.dir & WEST)), SIGN((projectile.dir & NORTH) - (projectile.dir & SOUTH)))

/datum/missile_guidance/proc/get_pursuit_offset(obj/overmap/projectile/projectile, atom/target, elapsed, pursuit_speed, turn_rate, timestamp)
	var/list/offset = get_target_offset(projectile, last_known_position, last_known_coordinates)
	// Propulsion queries must not acquire, reset, or switch an interception route.
	if (elapsed <= 0)
		return offset

	var/obj/overmap/moving_target = target
	if (!istype(moving_target) || !moving_target.movable || moving_target.halted || !moving_target.is_moving() || moving_target.z != projectile.z)
		reset_navigation()
		return offset

	if (!offset[1] && !offset[2])
		reset_navigation()
		return list(0, 0)

	return get_navigation_course(projectile, moving_target, offset, elapsed, min(pursuit_speed, projectile.max_speed), turn_rate, timestamp)

/datum/missile_guidance/proc/get_navigation_course(obj/overmap/projectile/projectile, obj/overmap/target, list/offset, elapsed, pursuit_speed, turn_rate, timestamp = world.time)
	var/period = get_wrap_period(projectile, get_turf(target))
	var/list/velocity = get_map_velocity(target)
	var/list/origin = projectile.get_unwrapped_map_position()
	var/list/target_point = get_target_point(target, timestamp, velocity)
	if (period)
		offset = list(
			wrap_offset(target_point[1] - origin[1], period, projectile.speed[1]),
			wrap_offset(target_point[2] - origin[2], period, projectile.speed[2]),
		)
	var/list/retained_offset = get_retained_offset(offset, period, origin, target_point)
	var/list/solution = get_navigation_solution(
		projectile,
		offset,
		velocity,
		pursuit_speed / 2,
		turn_rate,
		period,
		get_prediction_limit(target, period),
		retained_offset,
		timestamp,
	)
	if (!solution)
		reset_navigation()
		return offset

	var/list/selected_offset = list(solution[4], solution[5])
	if (retained_offset && ( \
		abs(selected_offset[1] - retained_offset[1]) > MISSILE_GUIDANCE_ROUTE_TOLERANCE \
		|| abs(selected_offset[2] - retained_offset[2]) > MISSILE_GUIDANCE_ROUTE_TOLERANCE \
	))
		navigation_locked = FALSE
	navigation_offset = selected_offset
	navigation_origin = origin
	navigation_target = target_point
	return get_proportional_navigation_course(projectile, selected_offset, velocity, list(solution[2], solution[3]), elapsed, turn_rate)

/// Search all images at the existing SSobj cadence; validate the retained arc on every substep.
/datum/missile_guidance/proc/get_navigation_solution(obj/overmap/projectile/projectile, list/offset, list/velocity, pursuit_speed, turn_rate, period, time_limit, list/retained_offset, timestamp)
	if (retained_offset && navigation_velocity && !isnull(navigation_plan_time) \
		&& timestamp >= navigation_plan_time && timestamp < navigation_plan_time + SSobj.wait)
		if (velocity[1] == navigation_velocity[1] && velocity[2] == navigation_velocity[2])
			var/list/retained = get_intercept_candidate(retained_offset[1], retained_offset[2], velocity, pursuit_speed, turn_rate, get_projectile_heading(projectile), time_limit)
			if (retained)
				return retained

	navigation_plan_time = timestamp
	navigation_velocity = velocity.Copy()
	return get_intercept_solution(projectile, offset, velocity, pursuit_speed, turn_rate, period, time_limit, retained_offset)

/// Use a completed path when available; otherwise rewind the current velocity, never an edge jump.
/datum/missile_guidance/proc/get_target_point(obj/overmap/target, timestamp, list/velocity)
	var/datum/overmap_motion/path = target.get_motion()
	var/current_path = path.matches_position(target, 0)
	if (timestamp >= path.start_time && timestamp <= path.end_time && current_path)
		return path.point_at(timestamp)

	var/list/point = target.get_unwrapped_map_position()
	var/reference_time = current_path ? path.end_time : world.time
	point[1] += velocity[1] * (timestamp - reference_time)
	point[2] += velocity[2] * (timestamp - reference_time)
	return point

/// Compute LOS rate from relative velocity, never from two different periodic images.
/datum/missile_guidance/proc/get_proportional_navigation_course(obj/overmap/projectile/projectile, list/offset, list/target_velocity, list/intercept, elapsed, turn_rate)
	var/distance_squared = offset[1] ** 2 + offset[2] ** 2
	if (!distance_squared)
		reset_navigation()
		return list(0, 0)

	var/list/relative_velocity = get_map_velocity(projectile)
	relative_velocity[1] = target_velocity[1] - relative_velocity[1]
	relative_velocity[2] = target_velocity[2] - relative_velocity[2]
	if (!update_navigation_lock(projectile, offset, relative_velocity, intercept))
		return intercept

	var/los_rate = (offset[1] * relative_velocity[2] - offset[2] * relative_velocity[1]) / distance_squared
	var/turn = navigation_constant * los_rate * (180 / M_PI) * elapsed
	return get_turn_course(projectile, turn, max(0, turn_rate * elapsed))

/datum/missile_guidance/proc/update_navigation_lock(obj/overmap/projectile/projectile, list/offset, list/relative_velocity, list/intercept)
	var/closing = offset[1] * relative_velocity[1] + offset[2] * relative_velocity[2] < 0
	var/error = abs(get_angle_delta(Atan2(intercept[1], intercept[2]), get_projectile_heading(projectile)))
	if (!projectile.is_moving() || !closing)
		navigation_locked = FALSE
	else if (navigation_locked)
		navigation_locked = error <= MISSILE_GUIDANCE_REACQUIRE_ANGLE
	else
		navigation_locked = error <= MISSILE_GUIDANCE_ACQUIRE_ANGLE
	return navigation_locked

/// Clamp the signed command before converting it to a bearing, which loses full turns.
/datum/missile_guidance/proc/get_turn_course(obj/overmap/projectile/projectile, turn, maximum_turn)
	var/limit = clamp(maximum_turn, 0, MISSILE_GUIDANCE_MAX_TURN)
	var/angle = get_projectile_heading(projectile) + clamp(turn, -limit, limit)
	return list(cos(angle), sin(angle))

/datum/missile_guidance/proc/get_angle_delta(desired_angle, current_angle)
	var/original_delta = desired_angle - current_angle
	// DM's % operator truncates fractional angles; use floating-point arithmetic.
	var/delta = original_delta - round(original_delta / 360) * 360
	if (delta > 180)
		delta -= 360
	if (delta == 180 && original_delta < 0)
		delta = -180
	return delta

/// Rendering and movement advance each active speed component by speed / 2 cells.
/datum/missile_guidance/proc/get_map_velocity(obj/overmap/object)
	if (!object.movable || object.halted)
		return list(0, 0)

	return list(abs(object.speed[1]) >= object.min_speed ? object.speed[1] / 2 : 0, abs(object.speed[2]) >= object.min_speed ? object.speed[2] / 2 : 0)

/// Keep the same physical target image through both object wraparound and the half-period cut.
/datum/missile_guidance/proc/get_retained_offset(list/offset, period, list/origin, list/target_point)
	if (!navigation_offset || !period)
		return null

	var/list/retained = offset.Copy()
	for (var/axis in 1 to 2)
		if (navigation_origin && navigation_target && origin && target_point)
			retained[axis] = navigation_offset[axis] + target_point[axis] - navigation_target[axis] - origin[axis] + navigation_origin[axis]
		else
			retained[axis] += round((navigation_offset[axis] - retained[axis]) / period + 0.5) * period
	return retained

/datum/missile_guidance/proc/get_projectile_heading(obj/overmap/projectile/projectile)
	if (projectile.is_moving())
		return Atan2(projectile.speed[1], projectile.speed[2])

	var/heading_x = SIGN((projectile.dir & EAST) - (projectile.dir & WEST))
	var/heading_y = SIGN((projectile.dir & NORTH) - (projectile.dir & SOUTH))
	return Atan2(heading_x, heading_y)

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
	if (!period)
		return delta

	var/original_delta = delta
	delta -= floor((delta + period / 2) / period) * period
	if (delta == -period / 2 && original_delta > 0)
		delta = -delta
	if (abs(delta) == period / 2 && current_speed && SIGN(delta) != SIGN(current_speed))
		return -delta

	return delta

/// Solutions contain turn-adjusted time, aim X/Y, and the selected image's offset X/Y.
/datum/missile_guidance/proc/get_intercept_solution(obj/overmap/projectile/projectile, list/offset, list/velocity, pursuit_speed, turn_rate, period, time_limit, list/retained_offset)
	if (pursuit_speed <= 0)
		return null

	var/current_angle = get_projectile_heading(projectile)
	var/list/retained = retained_offset ? get_intercept_candidate(retained_offset[1], retained_offset[2], velocity, pursuit_speed, turn_rate, current_angle, time_limit) : null
	var/list/x_images = get_intercept_images(velocity[1], period, turn_rate)
	var/list/y_images = get_intercept_images(velocity[2], period, turn_rate)
	var/list/best = retained
	for (var/image_x in x_images)
		for (var/image_y in y_images)
			var/list/candidate = get_intercept_candidate(offset[1] + image_x, offset[2] + image_y, velocity, pursuit_speed, turn_rate, current_angle, time_limit)
			if (candidate && (!best || candidate[1] < best[1]))
				best = candidate
	// A small apparent gain must not reverse a turn already in progress.
	return retained && best && best[1] >= retained[1] * MISSILE_GUIDANCE_ROUTE_MARGIN ? retained : best

/// Include images passed during the solver's maximum one-circle turn, not just adjacent images.
/datum/missile_guidance/proc/get_intercept_images(velocity, period, turn_rate)
	if (!period)
		return list(0)

	var/list/images = list(0, -period, period)
	var/windings = turn_rate > 0 ? ceil(abs(velocity) * 360 / (turn_rate * period)) : 0
	if (windings <= 1)
		return images

	for (var/index in 2 to windings)
		images += -SIGN(velocity) * index * period
	return images

/datum/missile_guidance/proc/get_intercept_candidate(delta_x, delta_y, list/velocity, pursuit_speed, turn_rate, current_angle, time_limit)
	var/meeting_time = get_intercept_time(delta_x, delta_y, velocity[1], velocity[2], pursuit_speed)
	if (isnull(meeting_time))
		return null

	var/angle = current_angle + get_angle_delta(Atan2(delta_x + velocity[1] * meeting_time, delta_y + velocity[2] * meeting_time), current_angle)
	// Solve a maximum-rate arc followed by a straight intercept. Unconverged routes are not promises.
	for (var/iteration in 1 to MISSILE_GUIDANCE_INTERCEPT_ITERATIONS)
		var/list/solution = get_turn_intercept(delta_x, delta_y, velocity, pursuit_speed, turn_rate, current_angle, angle)
		if (!solution)
			return null

		var/angle_error = get_angle_delta(solution[2], angle)
		if (abs(angle_error) < MISSILE_GUIDANCE_ANGLE_TOLERANCE)
			if (!isnull(time_limit) && solution[1] > time_limit)
				return null

			return make_intercept_candidate(solution[1], angle, current_angle, delta_x, delta_y)

		angle += angle_error
	return null

/// A tangent behind the nose can require slightly more than a half-turn. Preserve its turn side.
/datum/missile_guidance/proc/make_intercept_candidate(time, angle, current_angle, delta_x, delta_y)
	var/turn = angle - current_angle
	var/command = abs(turn) > 180 ? current_angle + SIGN(turn) * 90 : angle
	return list(time, cos(command), sin(command), delta_x, delta_y, turn)

/datum/missile_guidance/proc/get_turn_intercept(delta_x, delta_y, list/velocity, pursuit_speed, turn_rate, current_angle, angle)
	var/turn = angle - current_angle
	if (abs(turn) > 360)
		return null

	if (turn && turn_rate <= 0)
		return null

	var/turn_time = turn_rate > 0 ? abs(turn) / turn_rate : 0
	var/list/arc = get_turn_displacement(pursuit_speed, turn_rate, current_angle, turn)
	var/relative_x = delta_x + velocity[1] * turn_time - arc[1]
	var/relative_y = delta_y + velocity[2] * turn_time - arc[2]
	var/straight_time = get_intercept_time(relative_x, relative_y, velocity[1], velocity[2], pursuit_speed)
	if (isnull(straight_time))
		return null

	return list(turn_time + straight_time, Atan2(relative_x + velocity[1] * straight_time, relative_y + velocity[2] * straight_time))

/// Integrate velocity around a circle; speeds are map cells per decisecond.
/datum/missile_guidance/proc/get_turn_displacement(pursuit_speed, turn_rate, angle, turn)
	if (!turn || turn_rate <= 0)
		return list(0, 0)

	var/radius = pursuit_speed / (turn_rate * M_PI / 180 * SIGN(turn))
	return list(radius * (sin(angle + turn) - sin(angle)), radius * (cos(angle) - cos(angle + turn)))

/datum/missile_guidance/proc/get_intercept_time(delta_x, delta_y, velocity_x, velocity_y, pursuit_speed)
	var/a = velocity_x ** 2 + velocity_y ** 2 - pursuit_speed ** 2
	var/b = 2 * (delta_x * velocity_x + delta_y * velocity_y)
	var/c = delta_x ** 2 + delta_y ** 2
	return c ? positive_intercept_root(a, b, c) : 0

/// Use q/a and c/q to avoid cancellation when the target and missile have similar speeds.
/datum/missile_guidance/proc/positive_intercept_root(a, b, c)
	if (!a)
		return b < 0 ? -c / b : null

	var/discriminant = b ** 2 - 4 * a * c
	if (discriminant < 0)
		return null

	var/root = sqrt(discriminant)
	var/q = -0.5 * (b + (b >= 0 ? root : -root))
	if (!q)
		return null

	var/first = q / a
	var/second = c / q
	if (first < 0)
		return second >= 0 ? second : null

	return second >= 0 ? min(first, second) : first

/// A disposable or non-wrapping target cannot be intercepted beyond its map edge.
/datum/missile_guidance/proc/get_prediction_limit(obj/overmap/target, allow_wrap)
	if (allow_wrap && target.wraparound && !target.delete_on_edge)
		return null

	var/time_limit
	var/list/coordinates = target.get_map_position()
	var/list/velocity = get_map_velocity(target)
	for (var/axis in 1 to 2)
		if (!velocity[axis])
			continue

		var/edge = velocity[axis] > 0 ? GLOB.using_map.overmap_size - 0.5 : 1.5
		var/edge_time = max(0, (edge - coordinates[axis]) / velocity[axis])
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

#undef MISSILE_GUIDANCE_ACQUIRE_ANGLE
#undef MISSILE_GUIDANCE_REACQUIRE_ANGLE
#undef MISSILE_GUIDANCE_ROUTE_MARGIN
#undef MISSILE_GUIDANCE_MAX_TURN
#undef MISSILE_GUIDANCE_INTERCEPT_ITERATIONS
#undef MISSILE_GUIDANCE_ANGLE_TOLERANCE
#undef MISSILE_GUIDANCE_ROUTE_TOLERANCE
