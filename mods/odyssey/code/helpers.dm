/proc/odyssey_area_persistable(area/A)
	if (!istype(A))
		return FALSE
	if (A.area_flags & AREA_FLAG_IS_NOT_PERSISTENT)
		return FALSE
	return TRUE


/proc/odyssey_turf_persistable(turf/T)
	if (!istype(T))
		return FALSE
	if (!(T.z in GLOB.using_map.station_levels))
		return FALSE
	return odyssey_area_persistable(get_area(T))


/proc/odyssey_atom_persistable(atom/A)
	return odyssey_turf_persistable(get_turf(A))


/proc/odyssey_coord_key(x, y, z)
	return "[x],[y],[z]"


/proc/odyssey_locate_turf(list/entry)
	if (!islist(entry))
		return null
	var/x = entry["x"]
	var/y = entry["y"]
	var/z = entry["z"]
	if (isnull(x) || isnull(y) || isnull(z))
		return null
	return locate(x, y, z)


/obj/var/odyssey_persist_id


/proc/odyssey_machinery_whitelisted(obj/machinery/M)
	if (!istype(M))
		return FALSE
	return istype(M, /obj/machinery/computer) \
		|| istype(M, /obj/machinery/vending) \
		|| istype(M, /obj/machinery/fabricator) \
		|| istype(M, /obj/machinery/sleeper) \
		|| istype(M, /obj/machinery/door/airlock)


/proc/odyssey_structure_whitelisted(obj/structure/S)
	if (!istype(S))
		return FALSE
	return istype(S, /obj/structure/table) \
		|| istype(S, /obj/structure/bed) \
		|| istype(S, /obj/structure/bed/chair) \
		|| istype(S, /obj/structure/closet) \
		|| istype(S, /obj/structure/barricade) \
		|| istype(S, /obj/structure/broken_door) \
		|| istype(S, /obj/structure/catwalk)


/proc/odyssey_assign_runtime_id(obj/O)
	if (!istype(O))
		return null
	if (O.odyssey_persist_id)
		return O.odyssey_persist_id
	var/datum/odyssey_state/state = odyssey_ensure_state()
	O.odyssey_persist_id = "runtime-[state.campaign_id]-[state.next_object_id++]"
	return O.odyssey_persist_id


/proc/odyssey_base_object_entry(obj/O)
	var/turf/T = get_turf(O)
	if (!istype(O) || !T)
		return null
	return list(
		"id" = O.odyssey_persist_id,
		"type" = "[O.type]",
		"x" = T.x,
		"y" = T.y,
		"z" = T.z,
		"dir" = O.dir,
		"name" = O.name,
		"anchored" = O.anchored
	)


/// Assigns reproducible ids to clean-map objects before a continued save is applied.
/proc/odyssey_capture_object_baselines(force = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active && !force)
		return FALSE
	var/list/machines = list()
	var/list/structures = list()
	var/list/ordinals = list()
	for (var/obj/O in world)
		if (!odyssey_atom_persistable(O))
			continue
		var/kind
		if (istype(O, /obj/machinery) && odyssey_machinery_whitelisted(O))
			kind = "machinery"
		else if (istype(O, /obj/structure) && odyssey_structure_whitelisted(O))
			kind = "structure"
		else
			continue
		var/turf/T = get_turf(O)
		var/base_key = "[kind]:[O.type]@[odyssey_coord_key(T.x, T.y, T.z)]"
		var/ordinal = (ordinals[base_key] || 0) + 1
		ordinals[base_key] = ordinal
		O.odyssey_persist_id = "mapped:[base_key]#[ordinal]"
		var/list/entry = kind == "structure" ? odyssey_structure_snapshot(O) : odyssey_base_object_entry(O)
		if (kind == "machinery")
			machines[O.odyssey_persist_id] = entry
		else
			structures[O.odyssey_persist_id] = entry
	state.machinery_baseline = machines
	state.structure_baseline = structures
	log_debug("ODYSSEY: object baseline machinery=[length(machines)] structures=[length(structures)]")
	return TRUE
