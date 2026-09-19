/proc/odyssey_catwalk_plated_type(obj/structure/catwalk/C)
	if (!istype(C) || !C.plated_tile)
		return null
	return "[C.plated_tile.type]"


/proc/odyssey_structure_snapshot(obj/structure/S)
	var/list/entry = odyssey_base_object_entry(S)
	if (!islist(entry))
		return null
	if (istype(S, /obj/structure/catwalk))
		var/obj/structure/catwalk/C = S
		entry["hatch_open"] = !!C.hatch_open
		entry["plated_tile"] = odyssey_catwalk_plated_type(C)
	return entry


/proc/odyssey_apply_catwalk_state(obj/structure/catwalk/C, list/entry)
	if (!istype(C) || !islist(entry))
		return
	if ("hatch_open" in entry)
		C.hatch_open = !!entry["hatch_open"]
	if ("plated_tile" in entry)
		var/plated_path = text2path(entry["plated_tile"])
		if (ispath(plated_path, /singleton/flooring))
			C.plated_tile = GET_SINGLETON(plated_path)
		else
			C.plated_tile = null
	if (C.plated_tile && C.name == initial(C.name))
		C.SetName("plated catwalk")


/proc/odyssey_collect_structures()
	var/list/entries = list()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/live_ids = list()
	for (var/obj/structure/S in world)
		if (QDELETED(S) || !odyssey_atom_persistable(S) || !odyssey_structure_whitelisted(S))
			continue
		var/id = S.odyssey_persist_id || odyssey_assign_runtime_id(S)
		live_ids[id] = TRUE
		var/list/baseline = state.structure_baseline?[id]
		var/turf/T = get_turf(S)
		if (!T)
			continue
		var/action = islist(baseline) ? "modified" : "created"
		if (islist(baseline) && (baseline["x"] != T.x || baseline["y"] != T.y || baseline["z"] != T.z))
			action = "moved"
		var/changed = action != "modified" || baseline["dir"] != S.dir || baseline["name"] != S.name || baseline["anchored"] != S.anchored
		if (istype(S, /obj/structure/catwalk))
			var/obj/structure/catwalk/C = S
			changed = changed || !!baseline["hatch_open"] != !!C.hatch_open || "[baseline["plated_tile"]]" != "[odyssey_catwalk_plated_type(C)]"
		if (!changed)
			continue
		var/list/entry = odyssey_structure_snapshot(S)
		if (!entry)
			continue
		entry["action"] = action
		entries += list(entry)
	for (var/id in state.structure_baseline)
		if (live_ids[id])
			continue
		var/list/baseline = state.structure_baseline[id]
		var/list/tombstone = list("id" = id, "action" = "destroyed")
		if (islist(baseline))
			tombstone["x"] = baseline["x"]
			tombstone["y"] = baseline["y"]
			tombstone["z"] = baseline["z"]
			tombstone["type"] = baseline["type"]
		entries += list(tombstone)
	return entries


/proc/odyssey_apply_structures(list/entries)
	if (!islist(entries))
		return
	var/applied = 0
	for (var/list/entry in entries)
		if (!islist(entry) || entry["action"] != "destroyed")
			continue
		var/obj/structure/S = odyssey_find_structure_by_id(entry["id"])
		if (!S)
			S = odyssey_find_structure_for_entry(entry)
		if (S)
			qdel(S)
			applied++
	for (var/list/entry in entries)
		if (!islist(entry) || entry["action"] == "destroyed")
			continue
		var/path = text2path(entry["type"])
		var/turf/T = odyssey_locate_turf(entry)
		if (!ispath(path, /obj/structure) || !T)
			continue
		var/obj/structure/S = odyssey_find_structure_by_id(entry["id"])
		if (!S && entry["action"] == "created")
			S = new path(T)
		if (!S || !odyssey_structure_whitelisted(S))
			continue
		S.odyssey_persist_id = entry["id"]
		if (get_turf(S) != T)
			S.forceMove(T)
		if (!isnull(entry["dir"]))
			S.set_dir(entry["dir"])
		if (entry["name"])
			S.SetName(entry["name"])
		if (!isnull(entry["anchored"]))
			S.anchored = !!entry["anchored"]
		if (istype(S, /obj/structure/catwalk))
			odyssey_apply_catwalk_state(S, entry)
		S.update_icon()
		applied++
	log_debug("ODYSSEY: apply_structures applied=[applied]/[length(entries)]")


/proc/odyssey_find_structure_by_id(id)
	if (!id)
		return null
	for (var/obj/structure/S in world)
		if (S.odyssey_persist_id == id)
			return S
	return null


/proc/odyssey_find_structure_for_entry(list/entry)
	if (!islist(entry))
		return null
	var/turf/T = odyssey_locate_turf(entry)
	if (!T)
		return null
	var/path = text2path(entry["type"])
	if (ispath(path, /obj/structure/catwalk))
		return locate(/obj/structure/catwalk) in T
	if (ispath(path, /obj/structure))
		return locate(path) in T
	return null
