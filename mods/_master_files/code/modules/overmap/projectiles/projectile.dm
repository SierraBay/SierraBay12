/obj/overmap/projectile
	var/weakref/motion_target_ref
	var/contact_radius = 0.5
	var/flight_start_time

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
/obj/overmap/projectile/process_movement(elapsed = world.time - SSobj.last_fire)
	if (moving && !isnull(flight_start_time))
		elapsed = max(0, min(elapsed, world.time - flight_start_time))
	return ..(elapsed)

/obj/overmap/projectile/proc/set_flight_velocity(velocity_x, velocity_y)
	speed[1] = velocity_x
	speed[2] = velocity_y
	var/heading = get_heading()
	if (heading)
		dir = heading
	update_icon()

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
	if (check_enter())
		qdel_self()
		return
	var/obj/item/missile_equipment/thruster/thruster = actual_missile.equipment[MISSILE_PART_THRUSTER]
	if (!thruster || (!thruster.has_fuel() && thruster.requires_propulsion(src)))
		actual_missile.self_destruct()
		return
	if (process_equipment())
		advance_flight()

/obj/overmap/projectile/proc/advance_flight()
	process_movement()
	if (!QDELETED(src))
		check_target_contact()

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
	if (!thruster || !thruster.guidance.last_known_position)
		return FALSE
	var/period = thruster.guidance.get_wrap_period(src, thruster.guidance.last_known_position)
	if (!motion.matches_position(src, period))
		return FALSE
	var/contact_time = get_target_contact_time(target, thruster.guidance, period)
	if (isnull(contact_time))
		return FALSE
	// This interval has already been paid for; fuel is checked before the next burn.
	return resolve_target_contact(target, thruster)

/obj/overmap/projectile/proc/get_target_contact_time(atom/target, datum/missile_guidance/guidance, period)
	var/obj/overmap/object = target
	if (!istype(object))
		return motion.static_contact_time(guidance.last_known_coordinates, contact_radius, period, guidance.target_set_time)
	var/obj/overmap/projectile/other_missile = object
	if (istype(other_missile) && !other_missile.moving)
		return null
	var/datum/overmap_motion/other = object.get_motion()
	if (!other.matches_position(object, period))
		return null
	if (!object.movable || object.halted || !object.is_moving())
		if (other.end_time <= motion.start_time || (other.start_point[1] == other.end_point[1] && other.start_point[2] == other.end_point[2]))
			return motion.static_contact_time(object.get_map_position(), contact_radius, period, guidance.target_set_time)
	return motion.contact_time(other, contact_radius, period, guidance.target_set_time)

/obj/overmap/projectile/proc/resolve_target_contact(atom/target, obj/item/missile_equipment/thruster/thruster)
	if (!target)
		thruster.guidance.coasting = TRUE
		return FALSE
	var/obj/overmap/projectile/other_missile = target
	if (istype(other_missile))
		var/obj/item/missile_equipment/payload/antimissile/payload = actual_missile.equipment[MISSILE_PART_PAYLOAD]
		return istype(payload) && payload.disable_target(src, other_missile)
	forceMove(get_turf(target))
	position[1] = 0
	position[2] = 0
	if (check_enter())
		qdel_self()
		return TRUE
	set_flight_velocity(0, 0)
	return FALSE
