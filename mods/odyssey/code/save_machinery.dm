/// Collects whitelist machinery as created/modified/moved/destroyed deltas.
/proc/odyssey_collect_machinery()
	var/list/entries = list()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/live_ids = list()
	for (var/obj/machinery/M in world)
		if (QDELETED(M) || !odyssey_atom_persistable(M) || !odyssey_machinery_whitelisted(M))
			continue
		var/id = M.odyssey_persist_id || odyssey_assign_runtime_id(M)
		live_ids[id] = TRUE
		var/list/baseline = state.machinery_baseline?[id]
		var/list/entry = odyssey_machinery_entry(M, baseline)
		if (entry)
			entries += list(entry)
	for (var/id in state.machinery_baseline)
		if (!live_ids[id])
			entries += list(list("id" = id, "action" = "destroyed"))
	return entries


/proc/odyssey_machinery_entry(obj/machinery/M, list/baseline)
	if (!istype(M))
		return null
	var/max_health = M.get_max_health()
	var/cur_health = M.get_current_health()
	var/damaged = max_health > 0 && cur_health < max_health
	var/broken = !!M.reason_broken
	var/turf/T = get_turf(M)
	if (!T)
		return null
	var/action = islist(baseline) ? "modified" : "created"
	if (islist(baseline) && (baseline["x"] != T.x || baseline["y"] != T.y || baseline["z"] != T.z))
		action = "moved"
	var/list/airlock_state
	if (istype(M, /obj/machinery/door/airlock))
		airlock_state = odyssey_airlock_state(M)
	var/changed = action != "modified" || damaged || broken || M.emagged || M.panel_open \
		|| baseline["dir"] != M.dir || baseline["name"] != M.name || baseline["anchored"] != M.anchored \
		|| islist(airlock_state)
	if (!changed)
		return null
	var/list/entry = odyssey_base_object_entry(M)
	entry += list(
		"action" = action,
		"x" = T.x,
		"y" = T.y,
		"z" = T.z,
		"health" = cur_health,
		"max_health" = max_health,
		"reason_broken" = M.reason_broken,
		"emagged" = M.emagged,
		"panel_open" = M.panel_open
	)
	if (islist(airlock_state))
		entry["airlock"] = airlock_state
	return entry


/proc/odyssey_airlock_state(obj/machinery/door/airlock/A)
	if (!istype(A))
		return null
	var/open = !A.density
	if (!A.welded && !A.locked && !A.p_open && !open && !A.lock_cut_state)
		return null
	return list(
		"welded" = !!A.welded,
		"locked" = !!A.locked,
		"p_open" = !!A.p_open,
		"open" = open,
		"lock_cut_state" = A.lock_cut_state
	)


/proc/odyssey_apply_airlock_state(obj/machinery/door/airlock/A, list/data)
	if (!istype(A) || !islist(data))
		return
	A.welded = !!data["welded"]
	A.locked = !!data["locked"]
	A.p_open = !!data["p_open"]
	if (!isnull(data["lock_cut_state"]))
		A.lock_cut_state = data["lock_cut_state"]
	var/want_open = !!data["open"]
	if (want_open == !A.density)
		A.update_icon()
		return
	A.set_density(!want_open)
	if (A.width > 1)
		A.set_fillers_density(A.density)
	if (want_open)
		A.set_opacity(0)
		if (A.width > 1)
			A.set_fillers_opacity(0)
		A.layer = A.open_layer
	else
		A.layer = A.closed_layer
		if (A.visible && !A.glass)
			A.set_opacity(1)
			if (A.width > 1)
				A.set_fillers_opacity(1)
	A.update_nearby_tiles()
	A.update_icon()


/proc/odyssey_apply_machinery_destroy_entry(list/entry)
	if (!islist(entry) || entry["action"] != "destroyed")
		return FALSE
	var/obj/machinery/M = odyssey_find_machine_by_id(entry["id"])
	if (!M)
		return FALSE
	odyssey_index_remove(odyssey_ensure_state().persist_index_machinery, entry["id"])
	qdel(M)
	return TRUE


/proc/odyssey_apply_machinery_entry(list/entry)
	if (!islist(entry) || entry["action"] == "destroyed")
		return FALSE
	var/turf/T = odyssey_locate_turf(entry)
	if (!T)
		return FALSE
	var/path = text2path(entry["type"])
	if (!ispath(path, /obj/machinery))
		return FALSE
	var/obj/machinery/M = odyssey_find_machine_by_id(entry["id"])
	if (!M && !entry["action"])
		M = locate(path) in T
	if (!M && entry["action"] == "created")
		M = new path(T)
	if (!istype(M))
		return FALSE
	if (entry["id"])
		M.odyssey_persist_id = entry["id"]
		odyssey_index_put(odyssey_ensure_state().persist_index_machinery, entry["id"], M)
	if (get_turf(M) != T)
		M.forceMove(T)
	if (!isnull(entry["dir"]))
		M.set_dir(entry["dir"])
	if (entry["name"])
		M.SetName(entry["name"])
	if (!isnull(entry["anchored"]))
		M.anchored = !!entry["anchored"]
	if (!isnull(entry["emagged"]))
		M.emagged = !!entry["emagged"]
	if (!isnull(entry["panel_open"]))
		M.panel_open = !!entry["panel_open"]
	var/saved_health = entry["health"]
	if (!isnull(saved_health) && M.get_max_health() > 0)
		M.set_health(saved_health)
	var/desired_broken = entry["reason_broken"] || 0
	for (var/cause in list(MACHINE_BROKEN_GENERIC, MACHINE_BROKEN_NO_PARTS, MACHINE_BROKEN_HEALTH))
		var/has = !!(M.reason_broken & cause)
		var/want = !!(desired_broken & cause)
		if (has != want)
			M.set_broken(want, cause)
	if (istype(M, /obj/machinery/door/airlock) && islist(entry["airlock"]))
		odyssey_apply_airlock_state(M, entry["airlock"])
	else
		M.update_icon()
	return TRUE


/proc/odyssey_apply_machinery(list/entries)
	if (!islist(entries) || !length(entries))
		return
	var/applied = 0
	for (var/list/entry in entries)
		if (odyssey_apply_machinery_destroy_entry(entry))
			applied++
	for (var/list/entry in entries)
		if (odyssey_apply_machinery_entry(entry))
			applied++
	log_debug("ODYSSEY: apply_machinery applied=[applied]/[length(entries)]")


/proc/odyssey_find_machine_by_id(id)
	if (!id)
		return null
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (islist(state.persist_index_machinery))
		return odyssey_index_get(state.persist_index_machinery, id)
	for (var/obj/machinery/M in world)
		if (!QDELETED(M) && M.odyssey_persist_id == id)
			return M
	return null
