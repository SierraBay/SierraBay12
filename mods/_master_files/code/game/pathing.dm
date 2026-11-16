// JPS_PATHFINDING: movement checks shared by bots, AI and circuit navigation.
/atom
	var/can_astar_pass = CANPATHINGPASS_DENSITY

/// Non-dense blockers must opt into CANPATHINGPASS_ALWAYS_PROC.
/atom/proc/CanPathingPass(obj/item/card/id/ID, to_dir, atom/movable/am_caller, no_id = FALSE)
	return !density

/turf
	var/pathing_pass_method = TURF_PATHING_PASS_DEFAULT

/turf/space
	pathing_pass_method = TURF_PATHING_PASS_PROC

/turf/simulated/open
	pathing_pass_method = TURF_PATHING_PASS_PROC

/turf/simulated/open/CanPathingPass(obj/item/card/id/ID, to_dir, atom/movable/am_caller, no_id = FALSE)
	return am_caller && (!has_gravity() || !am_caller.can_fall(location_override = src))

/obj/machinery/door/CanPathingPass(obj/item/card/id/ID, to_dir, atom/movable/am_caller, no_id = FALSE)
	return !density || (!no_id && check_access(ID))

/obj/machinery/door/airlock/CanPathingPass(obj/item/card/id/ID, to_dir, atom/movable/am_caller, no_id = FALSE)
	return !density || (!no_id && !locked && !welded && arePowerSystemsOn() && check_access(ID))

/obj/machinery/door/window/CanPathingPass(obj/item/card/id/ID, to_dir, atom/movable/am_caller, no_id = FALSE)
	return !density || (dir != to_dir) || (!no_id && check_access(ID))

// Bots cannot bump these open, regardless of their access.
/obj/machinery/door/firedoor/CanPathingPass(obj/item/card/id/ID, to_dir, atom/movable/am_caller, no_id = FALSE)
	return !density

/obj/machinery/door/blast/CanPathingPass(obj/item/card/id/ID, to_dir, atom/movable/am_caller, no_id = FALSE)
	return !density

// Includes the direction check corrected by Foundation-19 #1265.
/obj/structure/railing/CanPathingPass(obj/item/card/id/ID, to_dir, atom/movable/am_caller, no_id = FALSE)
	return !density || (dir != to_dir) || am_caller?.checkpass(PASS_FLAG_TABLE)

/obj/structure/window/CanPathingPass(obj/item/card/id/ID, to_dir, atom/movable/am_caller, no_id = FALSE)
	if(!density || am_caller?.checkpass(PASS_FLAG_GLASS))
		return TRUE
	return !is_fulltile() && dir != to_dir

/obj/structure/grille/CanPathingPass(obj/item/card/id/ID, to_dir, atom/movable/am_caller, no_id = FALSE)
	return !density || am_caller?.checkpass(PASS_FLAG_GRILLE)

/obj/structure/table/CanPathingPass(obj/item/card/id/ID, to_dir, atom/movable/am_caller, no_id = FALSE)
	return !density || am_caller?.checkpass(PASS_FLAG_TABLE) || (flipped && dir != to_dir)

/obj/structure/plasticflaps
	can_astar_pass = CANPATHINGPASS_ALWAYS_PROC

/obj/structure/plasticflaps/CanPathingPass(obj/item/card/id/ID, to_dir, atom/movable/am_caller, no_id = FALSE)
	if(!am_caller)
		return TRUE
	return CanPass(am_caller, get_step(src, to_dir))

/// Cardinal neighbours using the same checks as JPS; includes #1265's no_id argument.
/turf/proc/reachableAdjacentTurfs(atom/movable/am_caller, obj/item/card/id/ID, simulated_only = TRUE, no_id = FALSE)
	. = list()
	for(var/iter_dir in GLOB.cardinal)
		var/turf/next = get_step(src, iter_dir)
		if(!next || (simulated_only && SSpathfinder.space_type_cache[next.type]))
			continue
		if(!LinkBlockedWithAccess(next, am_caller, ID, no_id))
			. += next

/// Checks both sides of a link, including directional objects on its source turf.
/turf/proc/LinkBlockedWithAccess(turf/destination_turf, atom/movable/am_caller, obj/item/card/id/ID, no_id = FALSE, list/avoid, simulated_only = FALSE)
	if(!destination_turf || destination_turf.z != z || destination_turf.density || (destination_turf in avoid))
		return TRUE
	if(simulated_only && SSpathfinder.space_type_cache[destination_turf.type])
		return TRUE
	if(destination_turf.x != x && destination_turf.y != y)
		var/in_dir = get_dir(src, destination_turf)
		for(var/first_step_direction in list(in_dir & (NORTH | SOUTH), in_dir & (EAST | WEST)))
			var/turf/midstep = get_step(src, first_step_direction)
			if(midstep && !LinkBlockedWithAccess(midstep, am_caller, ID, no_id, avoid, simulated_only) && !midstep.LinkBlockedWithAccess(destination_turf, am_caller, ID, no_id, avoid, simulated_only))
				return FALSE
		return TRUE
	var/actual_dir = get_dir(src, destination_turf)
	switch(destination_turf.pathing_pass_method)
		if(TURF_PATHING_PASS_PROC)
			if(!destination_turf.CanPathingPass(ID, actual_dir, am_caller, no_id))
				return TRUE
		if(TURF_PATHING_PASS_NO)
			return TRUE
	var/static/list/directional_blocker_cache = typecacheof(list(/obj/structure/window, /obj/machinery/door/window, /obj/structure/railing, /obj/machinery/door/firedoor, /obj/structure/table))
	for(var/obj/border in src)
		if(!directional_blocker_cache[border.type])
			continue
		if(!border.density && border.can_astar_pass == CANPATHINGPASS_DENSITY)
			continue
		if(istype(border, /obj/structure/table))
			var/obj/structure/table/table = border
			if(!table.flipped)
				continue
		if(!border.CanPathingPass(ID, actual_dir, am_caller, no_id))
			return TRUE
	var/reverse_dir = get_dir(destination_turf, src)
	for(var/obj/blocker in destination_turf)
		if(!blocker.density && blocker.can_astar_pass == CANPATHINGPASS_DENSITY)
			continue
		if(!blocker.CanPathingPass(ID, reverse_dir, am_caller, no_id))
			return TRUE
	return FALSE
