/obj/structure/missile/Destroy()
	// Detach before the core cleanup deletes the container and its contents.
	if (!QDELETED(overmap_missile) && loc == overmap_missile)
		forceMove(null)
	return ..()

/obj/structure/missile/arm(mob/user)
	// Build mode assigns an overmap projectile before arming a missile without a location.
	if (!armed && equipment[MISSILE_PART_THRUSTER] && QDELETED(overmap_missile) && !waypoint_sector(src))
		return FALSE
	. = ..()
	if (. && !QDELETED(overmap_missile))
		overmap_missile.dir = dir

/obj/structure/missile/touch_map_edge()
	if (loc != overmap_missile && armed && QDELETED(overmap_missile))
		if (!create_overmap_missile())
			self_destruct()
			return
		for (var/slot in equipment)
			var/obj/item/missile_equipment/part = equipment[slot]
			part?.on_missile_armed(overmap_missile)
	return ..()

/obj/structure/missile/get_target()
	var/obj/item/missile_equipment/thruster/thruster = equipment[MISSILE_PART_THRUSTER]
	return thruster?.get_target()

/obj/structure/missile/set_target(atom/new_target)
	var/obj/item/missile_equipment/thruster/thruster = equipment[MISSILE_PART_THRUSTER]
	thruster?.set_target(new_target)
	if (!QDELETED(overmap_missile))
		overmap_missile.update_motion_target()

/obj/structure/missile/proc/impact_at(turf/impact_turf)
	ASSERT(istype(impact_turf))
	forceMove(impact_turf)
	detonate(impact_turf)

/// Fuel exhaustion removes the missile without triggering its equipment.
/obj/structure/missile/proc/self_destruct()
	walk(src, 0)
	qdel_self()

/obj/structure/missile/proc/has_fuel()
	var/obj/item/missile_equipment/thruster/thruster = equipment[MISSILE_PART_THRUSTER]
	return thruster?.has_fuel()

/// Rebuild the overmap representation when returning from a local level.
/obj/structure/missile/proc/create_overmap_missile()
	if (!QDELETED(overmap_missile))
		return TRUE
	var/obj/overmap/start_object = waypoint_sector(src)
	if (!start_object)
		return FALSE
	overmap_missile = new /obj/overmap/projectile(start_object)
	overmap_missile.set_missile(src)
	overmap_missile.SetName(overmap_name)
	overmap_missile.dir = dir
	return TRUE

/// Replace core entry so a planetary impact cannot resume walking after deletion.
/obj/structure/missile/enter_level(z_level)
	overmap_missile.set_moving(FALSE)
	var/heading = get_entry_heading()
	var/turf/start = get_entry_turf(heading, z_level)
	if (overmap_missile.dangerous)
		log_and_message_admins("A dangerous missile has entered z level [z_level] (<A HREF='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
	var/should_detonate = start.contains_dense_objects()
	forceMove(start)
	qdel(overmap_missile)
	if (should_detonate)
		detonate()
		return
	start_local_flight(heading, z_level)

/obj/structure/missile/proc/get_entry_heading()
	var/heading = overmap_missile.dir
	if (!heading)
		var/datum/prng/rng = new()
		heading = rng.random_dir()
	return heading

/obj/structure/missile/proc/get_entry_turf(heading, z_level)
	var/start_x
	var/start_y
	if (heading & WEST)
		start_x = world.maxx - TRANSITIONEDGE - 2
	else if (heading & EAST)
		start_x = TRANSITIONEDGE + 2
	else
		start_x = floor(world.maxx / 2) + rand(-10, 10)
	if (heading & NORTH)
		start_y = TRANSITIONEDGE + 2
	else if (heading & SOUTH)
		start_y = world.maxy - TRANSITIONEDGE - 2
	else
		start_y = floor(world.maxy / 2) + rand(-10, 10)
	return locate(start_x, start_y, z_level)

/obj/structure/missile/proc/get_local_goal(z_level)
	for (var/slot in equipment)
		var/obj/item/missile_equipment/part = equipment[slot]
		if (part)
			var/list/coords = part.on_enter_level(z_level)
			if (QDELETED(src))
				return null
			if (coords)
				return locate(coords[1], coords[2], z_level)
	return null

/obj/structure/missile/proc/start_local_flight(heading, z_level)
	var/turf/goal = get_local_goal(z_level)
	if (QDELETED(src))
		return
	if (goal)
		walk_towards(src, goal, 1)
	else
		walk(src, heading, 1)
