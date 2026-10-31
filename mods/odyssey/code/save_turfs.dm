/// Captures clean-map turf types so roundend can emit only deltas.
/// Shares the object/index walk in [odyssey_capture_map_baseline].
/proc/odyssey_capture_turf_baseline(force = FALSE)
	return odyssey_capture_map_baseline(force)


/proc/odyssey_collect_turfs()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/baseline = state.turf_baseline
	var/list/entries = list()
	if (!islist(baseline) || !length(baseline))
		log_error("ODYSSEY: no turf baseline; skipping turf save")
		return entries

	for (var/turf/T in odyssey_get_persistable_turfs())
		if (!odyssey_turf_persistable(T))
			continue
		var/key = odyssey_coord_key(T.x, T.y, T.z)
		var/baseline_type = baseline[key]
		if (baseline_type)
			var/list/entry = odyssey_turf_delta_entry(T, baseline_type)
			if (entry)
				entries += list(entry)
		CHECK_TICK
	return entries


/proc/odyssey_turf_delta_entry(turf/T, baseline_type)
	var/current_type = "[T.type]"
	var/changed = current_type != baseline_type
	var/list/entry = list(
		"x" = T.x,
		"y" = T.y,
		"z" = T.z,
		"baseline_type" = baseline_type,
		"type" = current_type
	)
	if (istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/W = T
		var/max_health = W.get_max_health()
		var/cur_health = W.get_current_health()
		if (max_health > 0 && cur_health < max_health)
			entry["health"] = cur_health
			entry["max_health"] = max_health
			changed = TRUE
	else if (istype(T, /turf/simulated/floor))
		var/turf/simulated/floor/F = T
		if (!isnull(F.broken))
			entry["broken"] = F.broken
			changed = TRUE
		if (!isnull(F.burnt))
			entry["burnt"] = F.burnt
			changed = TRUE
	if (!changed)
		return null
	return entry


/proc/odyssey_apply_turf_entry(list/entry)
	if (!islist(entry))
		return FALSE
	var/turf/T = odyssey_locate_turf(entry)
	if (!T)
		return FALSE
	var/path = text2path(entry["type"])
	if (ispath(path, /turf) && T.type != path)
		T = T.ChangeTurf(path, tell_universe = FALSE, force_lighting_update = TRUE, keep_air = TRUE)
		if (!T)
			return FALSE
		odyssey_reindex_persist_turf(T)
	if (istype(T, /turf/simulated/wall) && !isnull(entry["health"]))
		T.set_health(entry["health"])
	else if (istype(T, /turf/simulated/floor))
		var/turf/simulated/floor/F = T
		if (!isnull(entry["broken"]))
			F.broken = entry["broken"]
		if (!isnull(entry["burnt"]))
			F.burnt = entry["burnt"]
		F.update_icon()
	return TRUE


/proc/odyssey_apply_turfs(list/entries)
	if (!islist(entries) || !length(entries))
		return
	var/applied = 0
	for (var/list/entry in entries)
		if (odyssey_apply_turf_entry(entry))
			applied++
		CHECK_TICK
	log_debug("ODYSSEY: apply_turfs applied=[applied]/[length(entries)]")
