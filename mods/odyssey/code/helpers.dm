/// Station-relative date/time for IC surfaces (chronicle, briefing, lobby).
/proc/odyssey_ic_timestamp()
	return "[stationdate2text()] [stationtime2text()]"


/// Visitor / transient roots that must never enter the area snapshot (or persist even if somehow listed).
/proc/odyssey_area_excluded_from_snapshot(area/A)
	return istype(A, /area/space) \
		|| istype(A, /area/ship) \
		|| istype(A, /area/map_template) \
		|| istype(A, /area/supply) // cargo supply drone — docks onto hangar midround


/// Freeze areas present on station_levels at baseline time. Midround visitors are not included.
/// Tracked Sierra fleet areas are always unioned in — roundstart may run after abandon-apply
/// moved a craft off-station, and the craft can still return later the same shift.
/// Call before turf/object baselines (they consult this set).
/proc/odyssey_capture_persistable_areas(force = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.persistable_areas_ready && !force)
		return TRUE
	var/list/areas = list()
	for (var/z in GLOB.using_map.station_levels)
		for (var/turf/T in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			var/area/A = get_area(T)
			if (!istype(A))
				continue
			if (odyssey_area_excluded_from_snapshot(A))
				continue
			if (A.area_flags & AREA_FLAG_IS_NOT_PERSISTENT)
				continue
			areas[A] = TRUE
			CHECK_TICK
	// Guppy/Charon/Petrov/Phaethon — keep allowlisted even if already moved off for abandon.
	if (SSshuttle)
		for (var/shuttle_name in ODYSSEY_TRACKED_SHUTTLE_NAMES)
			var/datum/shuttle/S = SSshuttle.shuttles[shuttle_name]
			if (!istype(S) || !islist(S.shuttle_area))
				continue
			for (var/area/shuttle_area in S.shuttle_area)
				if (!istype(shuttle_area))
					continue
				if (odyssey_area_excluded_from_snapshot(shuttle_area))
					continue
				if (shuttle_area.area_flags & AREA_FLAG_IS_NOT_PERSISTENT)
					continue
				areas[shuttle_area] = TRUE
	state.persistable_areas = areas
	state.persistable_areas_ready = TRUE
	log_debug("ODYSSEY: persistable areas captured ([length(areas)])")
	return TRUE


/proc/odyssey_area_persistable(area/A)
	if (!istype(A))
		return FALSE
	if (A.area_flags & AREA_FLAG_IS_NOT_PERSISTENT)
		return FALSE
	if (odyssey_area_excluded_from_snapshot(A))
		return FALSE
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.persistable_areas_ready)
		return FALSE
	return !!(state.persistable_areas[A])


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


/// Structures that must not be snapshotted: powernet / disposal / multiz links need rebuild, not a blind new(turf).
/// Atmospheric pipes are /obj/machinery/atmospherics — outside structure persist entirely.
/proc/odyssey_structure_path_denylisted(path)
	if (!ispath(path, /obj/structure))
		return TRUE
	return ispath(path, /obj/structure/cable) \
		|| ispath(path, /obj/structure/disposalpipe) \
		|| ispath(path, /obj/structure/disposalholder) \
		|| ispath(path, /obj/structure/disposaloutlet) \
		|| ispath(path, /obj/structure/ladder) \
		|| ispath(path, /obj/structure/stairs) \
		|| ispath(path, /obj/structure/transit_tube) \
		|| ispath(path, /obj/structure/transit_tube_pod)


/proc/odyssey_structure_denylisted(obj/structure/S)
	if (!istype(S))
		return TRUE
	return odyssey_structure_path_denylisted(S.type)


/// Persist all ship structures in persistable areas, except denylisted types.
/proc/odyssey_structure_whitelisted(obj/structure/S)
	if (!istype(S))
		return FALSE
	if (odyssey_structure_denylisted(S))
		return FALSE
	return TRUE


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


/// Snapshots the clean DMM once so later roundend saves still diff against it, not against an already-applied world.
/proc/odyssey_ensure_persist_baselines(overwrite = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.persist_baselines_ready && !overwrite)
		return TRUE
	odyssey_capture_persistable_areas(TRUE)
	odyssey_capture_turf_baseline(TRUE)
	odyssey_capture_object_baselines(TRUE)
	odyssey_capture_mech_baseline(TRUE)
	state.persist_baselines_ready = TRUE
	return TRUE


/// Assigns reproducible ids to clean-map objects before a continued save is applied.
/proc/odyssey_capture_object_baselines(force = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active && !force)
		return FALSE
	if (!force && islist(state.machinery_baseline) && length(state.machinery_baseline))
		return TRUE
	var/list/machines = list()
	var/list/structures = list()
	var/list/ordinals = list()
	for (var/obj/O in world)
		var/kind
		if (odyssey_atom_persistable(O))
			if (istype(O, /obj/machinery) && odyssey_machinery_whitelisted(O))
				kind = "machinery"
			else if (istype(O, /obj/structure) && odyssey_structure_whitelisted(O))
				kind = "structure"
		if (kind)
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
		CHECK_TICK
	state.machinery_baseline = machines
	state.structure_baseline = structures
	log_debug("ODYSSEY: object baseline machinery=[length(machines)] structures=[length(structures)]")
	return TRUE
