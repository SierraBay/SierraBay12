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
		var/plated_path = odyssey_resolve_path(entry["plated_tile"])
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
	for (var/turf/T in odyssey_get_persistable_turfs())
		odyssey_collect_structure_turf(T, entries, live_ids, state)
		CHECK_TICK
	odyssey_finish_structure_destroyed(entries, live_ids, state)
	return entries


/proc/odyssey_collect_structure_turf(turf/T, list/entries, list/live_ids, datum/odyssey_state/state)
	if (!istype(T) || !islist(entries) || !islist(live_ids))
		return
	for (var/obj/structure/S in T)
		if (QDELETED(S) || S.loc != T || !odyssey_structure_whitelisted(S))
			continue
		var/id = S.odyssey_persist_id || odyssey_assign_runtime_id(S)
		live_ids[id] = TRUE
		var/list/baseline = state?.structure_baseline?[id]
		var/action = islist(baseline) ? "modified" : "created"
		if (islist(baseline) && (baseline["x"] != T.x || baseline["y"] != T.y || baseline["z"] != T.z))
			action = "moved"
		var/changed = action != "modified" || baseline["dir"] != S.dir || baseline["name"] != S.name || baseline["anchored"] != S.anchored \
			|| (baseline["pixel_x"] || 0) != S.pixel_x || (baseline["pixel_y"] || 0) != S.pixel_y
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


/proc/odyssey_finish_structure_destroyed(list/entries, list/live_ids, datum/odyssey_state/state)
	if (!islist(entries) || !islist(live_ids) || !istype(state))
		return
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


/proc/odyssey_apply_structure_destroy_entry(list/entry)
	if (!islist(entry) || entry["action"] != "destroyed")
		return FALSE
	// Legacy saves may tombstone tables/beds; never wipe DMM furniture via turf/type fallback.
	var/path = odyssey_resolve_path(entry["type"])
	if (odyssey_structure_path_denylisted(path))
		return FALSE
	var/obj/structure/S = odyssey_find_structure_by_id(entry["id"])
	if (!S)
		S = odyssey_find_structure_for_entry(entry)
	if (!S)
		return FALSE
	if (odyssey_structure_denylisted(S) || !odyssey_atom_persistable(S))
		return FALSE
	odyssey_index_remove(odyssey_ensure_state().persist_index_structures, entry["id"])
	qdel(S)
	return TRUE


/proc/odyssey_apply_structure_entry(list/entry)
	if (!islist(entry) || entry["action"] == "destroyed")
		return FALSE
	var/path = odyssey_resolve_path(entry["type"])
	var/turf/T = odyssey_locate_turf(entry)
	if (!ispath(path, /obj/structure) || !T || !odyssey_turf_persistable(T))
		return FALSE
	// Refuse before new() — stairs Initialize can ChangeTurf the deck above; tables self-destruct if doubled.
	if (odyssey_structure_path_denylisted(path))
		return FALSE
	var/obj/structure/S = odyssey_find_structure_by_id(entry["id"])
	// Continue remaps persist ids — always try turf+type before spawning a duplicate.
	if (!S)
		S = locate(path) in T
	if (!S && entry["action"] == "created")
		S = new path(T)
	if (!S || !odyssey_structure_whitelisted(S))
		if (S && entry["action"] == "created" && !QDELETED(S))
			qdel(S)
		return FALSE
	S.odyssey_persist_id = entry["id"]
	odyssey_index_put(odyssey_ensure_state().persist_index_structures, entry["id"], S)
	if (get_turf(S) != T)
		S.forceMove(T)
	if (!isnull(entry["dir"]))
		S.set_dir(entry["dir"])
	odyssey_apply_pixel_offset(S, entry)
	if (entry["name"])
		S.SetName(entry["name"])
	if (!isnull(entry["anchored"]))
		S.anchored = !!entry["anchored"]
	if (istype(S, /obj/structure/catwalk))
		odyssey_apply_catwalk_state(S, entry)
	S.update_icon()
	return TRUE


/proc/odyssey_structure_needs_connection_refresh(obj/structure/S)
	return istype(S, /obj/structure/window) \
		|| istype(S, /obj/structure/grille) \
		|| istype(S, /obj/structure/wall_frame) \
		|| istype(S, /obj/structure/table) \
		|| istype(S, /obj/structure/catwalk)


/// Recompute visual joins after strip/spawn — mid-apply update_icon used stale neighbor state.
/proc/odyssey_refresh_structure_connections()
	var/refreshed = 0
	for (var/turf/T in odyssey_get_persistable_turfs())
		for (var/obj/structure/S in T)
			if (QDELETED(S) || !odyssey_structure_needs_connection_refresh(S))
				continue
			S.update_connections(FALSE)
			S.update_icon()
			refreshed++
		CHECK_TICK
	log_debug("ODYSSEY: refreshed structure connections=[refreshed]")


/proc/odyssey_apply_structures(list/entries)
	if (!islist(entries))
		return
	var/applied = 0
	for (var/list/entry in entries)
		if (odyssey_apply_structure_destroy_entry(entry))
			applied++
		CHECK_TICK
	for (var/list/entry in entries)
		if (odyssey_apply_structure_entry(entry))
			applied++
		CHECK_TICK
	odyssey_refresh_structure_connections()
	log_debug("ODYSSEY: apply_structures applied=[applied]/[length(entries)]")


/proc/odyssey_find_structure_by_id(id)
	if (!id)
		return null
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (islist(state.persist_index_structures))
		return odyssey_index_get(state.persist_index_structures, id)
	for (var/obj/structure/S in world)
		if (!QDELETED(S) && S.odyssey_persist_id == id)
			return S
	return null


/proc/odyssey_find_structure_for_entry(list/entry)
	if (!islist(entry))
		return null
	var/turf/T = odyssey_locate_turf(entry)
	if (!T)
		return null
	var/path = odyssey_resolve_path(entry["type"])
	if (ispath(path, /obj/structure/catwalk))
		return locate(/obj/structure/catwalk) in T
	if (ispath(path, /obj/structure))
		return locate(path) in T
	return null
