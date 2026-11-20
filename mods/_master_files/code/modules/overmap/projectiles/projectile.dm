/obj/overmap/projectile
	var/weakref/motion_target_ref
	var/contact_radius = 0.5
	var/flight_start_time
	var/edge_pending = FALSE
	var/contact_checked_until
	var/contact_had_target

/obj/overmap/projectile/Destroy()
	clear_motion_target()
	return ..()

/obj/overmap/projectile/set_missile(obj/structure/missile/missile)
	. = ..()
	get_motion()
	update_motion_target()

/obj/overmap/projectile/set_moving(is_moving)
	var/was_moving = moving
	. = ..()
	if (is_moving)
		if (!was_moving)
			flight_start_time = world.time
		get_motion().begin(src, world.time)
		update_motion_target()
	else
		flight_start_time = null
		clear_motion_target()

/// A launch between SSobj fires must not include time spent on the local map.
/obj/overmap/projectile/process_movement(elapsed = world.time - SSobj.last_fire, timestamp = world.time)
	if (moving && !isnull(flight_start_time))
		elapsed = max(0, min(elapsed, world.time - flight_start_time))
	. = ..(elapsed, timestamp)
	if (edge_pending && !motion?.recording && !QDELETED(src))
		check_target_contact()
		finish_edge_movement()

/// Check the paid path up to the edge before deleting a disposable missile.
/obj/overmap/projectile/move_map_edge(turf/destination, list/delta)
	if (!delete_on_edge)
		return ..()

	edge_pending = TRUE
	return stop_map_movement(delta)

/obj/overmap/projectile/record_stopped_motion()
	return !edge_pending

/obj/overmap/projectile/proc/finish_edge_movement()
	if (!edge_pending || QDELETED(src))
		return

	edge_pending = FALSE
	if (!QDELETED(actual_missile))
		actual_missile.self_destruct()
	else
		qdel(src)

/obj/overmap/projectile/proc/set_flight_velocity(velocity_x, velocity_y)
	speed[1] = velocity_x
	speed[2] = velocity_y
	var/heading = get_heading()
	if (heading)
		dir = heading
	update_icon()

/// Intermediate substeps are not rendered; avoid rebuilding filters and overlays for each one.
/obj/overmap/projectile/on_update_icon()
	if (motion?.recording)
		return

	return ..()

/// Replace core processing to stop before sector entry or movement after deletion.
/obj/overmap/projectile/Process()
	if (QDELETED(actual_missile))
		qdel_self()
		return

	if (!moving)
		return process_movement()

	update_motion_target()
	get_motion()
	// Resolve arrival from the previous burn before requiring fuel for another one.
	if (resolve_arrival())
		return

	var/obj/item/missile_equipment/thruster/thruster = actual_missile.equipment[MISSILE_PART_THRUSTER]
	if (!thruster || (!thruster.has_fuel() && thruster.requires_propulsion(src)))
		actual_missile.self_destruct()
		return

	if (process_equipment())
		advance_flight()

/// Moving ships and missiles need simultaneous contact, not co-location at different times.
/obj/overmap/projectile/proc/resolve_arrival()
	if (check_target_contact())
		return TRUE

	var/atom/target = actual_missile.get_target()
	// Events such as leviathans move outside process_movement and retain their legacy entry hooks.
	if (!istype(target, /obj/overmap/visitable/ship) && !istype(target, /obj/overmap/projectile) && check_enter())
		qdel_self()
		return TRUE

	return FALSE

/obj/overmap/projectile/proc/advance_flight()
	var/elapsed = max(0, world.time - max(SSobj.last_fire, flight_start_time))
	var/obj/item/missile_equipment/thruster/thruster = actual_missile.equipment[MISSILE_PART_THRUSTER]
	integrate_flight(thruster, elapsed, world.time)

/// Equipment and fuel run once per SSobj fire; only steering and movement are subdivided.
/obj/overmap/projectile/proc/integrate_flight(obj/item/missile_equipment/thruster/thruster, elapsed, timestamp)
	var/datum/overmap_motion/path = get_motion()
	contact_checked_until = null
	path.begin(src, timestamp - elapsed)
	path.recording = TRUE
	var/time = timestamp - elapsed
	while (elapsed > 0 && !QDELETED(src) && moving)
		var/step_time = thruster.get_flight_step(src, elapsed)
		time += step_time
		elapsed = max(0, elapsed - step_time)
		move_flight_step(thruster, step_time, time)
		if (!QDELETED(src) && check_target_contact())
			break

		finish_edge_movement()
	if (!QDELETED(path))
		path.recording = FALSE
	if (!QDELETED(src))
		update_icon()

/// Integrate the arc endpoint with its mean velocity, then restore the physical end velocity.
/obj/overmap/projectile/proc/move_flight_step(obj/item/missile_equipment/thruster/thruster, elapsed, timestamp)
	var/start_angle = thruster.guidance.get_projectile_heading(src)
	thruster.steer(src, elapsed, timestamp - elapsed)
	var/list/end_velocity = speed.Copy()
	var/list/travel_velocity = thruster.get_average_velocity(src, start_angle)
	var/travel_x = travel_velocity[1]
	var/travel_y = travel_velocity[2]
	speed = travel_velocity
	process_movement(elapsed, timestamp)
	// A collision or a boundary stop overrides the planned end velocity.
	if (!QDELETED(src) && speed[1] == travel_x && speed[2] == travel_y)
		set_flight_velocity(end_velocity[1], end_velocity[2])

/obj/overmap/projectile/proc/process_equipment()
	for (var/slot in actual_missile.equipment)
		if (QDELETED(actual_missile))
			return FALSE

		var/obj/item/missile_equipment/part = actual_missile.equipment[slot]
		if (part)
			part.do_overmap_work(src)
			if (QDELETED(src) || QDELETED(actual_missile))
				return FALSE

	return TRUE

/obj/overmap/projectile/proc/clear_motion_target()
	var/obj/overmap/target = motion_target_ref?.resolve()
	if (!QDELETED(target))
		target.unwatch_motion(src)
	motion_target_ref = null

/obj/overmap/projectile/proc/update_motion_target()
	var/obj/overmap/target = actual_missile?.get_target()
	if (!istype(target) || QDELETED(target))
		target = null
	if (target == motion_target_ref?.resolve())
		return

	clear_motion_target()
	if (target && target != src)
		motion_target_ref = weakref(target)
		target.watch_motion(src, PROC_REF(on_target_moved))

/obj/overmap/projectile/proc/on_target_moved(obj/overmap/target)
	SIGNAL_HANDLER
	check_target_contact()

/obj/overmap/projectile/proc/check_target_contact()
	if (QDELETED(src) || QDELETED(actual_missile) || !moving || halted || !motion)
		return FALSE

	var/obj/item/missile_equipment/thruster/thruster = actual_missile.equipment[MISSILE_PART_THRUSTER]
	var/atom/target = thruster?.get_target()
	if (!!target != contact_had_target)
		contact_checked_until = null
	contact_had_target = !!target
	if (!thruster || !thruster.guidance.last_known_position)
		return FALSE

	// Winding frames must agree even when this missile stops or is deleted at an edge.
	var/period = z == GLOB.using_map.overmap_z ? GLOB.using_map.overmap_size - 2 : 0
	if (!motion.matches_position(src, period))
		return FALSE

	var/contact_time = get_target_contact_time(target, thruster.guidance, period)
	if (isnull(contact_time))
		return FALSE

	// This interval has already been paid for; fuel is checked before the next burn.
	return resolve_target_contact(target, thruster)

/obj/overmap/projectile/proc/get_target_contact_time(atom/target, datum/missile_guidance/guidance, period)
	var/not_before = max(guidance.target_set_time, motion.start_time)
	if (!isnull(contact_checked_until))
		not_before = max(not_before, contact_checked_until)
	var/obj/overmap/object = target
	if (!istype(object))
		return get_static_contact_time(guidance.last_known_coordinates, period, not_before)

	return get_object_contact_time(object, period, not_before)

/obj/overmap/projectile/proc/get_static_contact_time(list/point, period, not_before)
	contact_checked_until = motion.end_time
	return motion.static_contact_time(point, contact_radius, period, not_before)

/obj/overmap/projectile/proc/get_object_contact_time(obj/overmap/object, period, not_before)
	var/obj/overmap/projectile/other_missile = object
	if (istype(other_missile) && !other_missile.moving)
		return null

	var/datum/overmap_motion/other = object.get_motion()
	if (!other.matches_position(object, period))
		return null

	if (!object.movable || object.halted || !object.is_moving())
		if (other.end_time <= motion.start_time || (other.start_point[1] == other.end_point[1] && other.start_point[2] == other.end_point[2]))
			return get_static_contact_time(object.get_unwrapped_map_position(), period, not_before)

	. = motion.contact_time(other, contact_radius, period, not_before)
	// Advance only through contiguous known history; a later target update can fill a gap.
	if (other.start_time <= not_before && other.end_time >= not_before)
		contact_checked_until = min(motion.end_time, other.end_time)

/obj/overmap/projectile/proc/resolve_target_contact(atom/target, obj/item/missile_equipment/thruster/thruster)
	if (!target)
		thruster.guidance.coasting = TRUE
		return FALSE

	var/obj/overmap/projectile/other_missile = target
	if (istype(other_missile))
		var/obj/item/missile_equipment/payload/antimissile/payload = actual_missile.equipment[MISSILE_PART_PAYLOAD]
		return istype(payload) && payload.disable_target(src, other_missile)

	edge_pending = FALSE
	forceMove(get_turf(target))
	position[1] = 0
	position[2] = 0
	if (check_enter())
		qdel_self()
		return TRUE

	set_flight_velocity(0, 0)
	return FALSE
