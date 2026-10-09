/mob/living/exosuit/var/odyssey_persist_id


/proc/odyssey_capture_mech_baseline(force = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active && !force)
		return FALSE
	if (!force && islist(state.mech_baseline) && length(state.mech_baseline))
		return TRUE
	var/list/baseline = list()
	var/list/ordinals = list()
	for (var/mob/living/exosuit/M in world)
		if (!odyssey_atom_persistable(M))
			continue
		var/turf/T = get_turf(M)
		var/base_key = "[M.type]@[odyssey_coord_key(T.x, T.y, T.z)]"
		var/ordinal = (ordinals[base_key] || 0) + 1
		ordinals[base_key] = ordinal
		M.odyssey_persist_id = "mapped:mech:[base_key]#[ordinal]"
		baseline[M.odyssey_persist_id] = list("x" = T.x, "y" = T.y, "z" = T.z, "type" = "[M.type]")
	state.mech_baseline = baseline
	return TRUE


/proc/odyssey_collect_mechs()
	var/list/entries = list()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/live_ids = list()
	for (var/mob/living/exosuit/M in world)
		if (QDELETED(M) || !odyssey_atom_persistable(M))
			continue
		if (!M.odyssey_persist_id)
			M.odyssey_persist_id = "runtime-mech-[state.campaign_id]-[state.next_object_id++]"
		live_ids[M.odyssey_persist_id] = TRUE
		var/list/entry = odyssey_mech_entry(M)
		if (entry)
			var/list/baseline = state.mech_baseline?[M.odyssey_persist_id]
			entry["id"] = M.odyssey_persist_id
			entry["action"] = islist(baseline) ? "modified" : "created"
			if (islist(baseline) && (baseline["x"] != entry["x"] || baseline["y"] != entry["y"] || baseline["z"] != entry["z"]))
				entry["action"] = "moved"
			entries += list(entry)
	for (var/id in state.mech_baseline)
		if (!live_ids[id])
			entries += list(list("id" = id, "action" = "destroyed"))
	return entries


/proc/odyssey_mech_component_entry(obj/item/mech_component/C)
	if (!istype(C))
		return null
	return list(
		"brute" = C.brute_damage,
		"burn" = C.burn_damage,
		"current_hp" = C.current_hp,
		"max_hp" = C.max_hp,
		"unrepairable_damage" = C.unrepairable_damage
	)


/proc/odyssey_mech_entry(mob/living/exosuit/M)
	if (!istype(M))
		return null
	var/turf/T = get_turf(M)
	if (!T)
		return null
	var/list/components = list()
	if (M.L_arm)
		components["L_arm"] = odyssey_mech_component_entry(M.L_arm)
	if (M.R_arm)
		components["R_arm"] = odyssey_mech_component_entry(M.R_arm)
	if (M.L_leg)
		components["L_leg"] = odyssey_mech_component_entry(M.L_leg)
	if (M.R_leg)
		components["R_leg"] = odyssey_mech_component_entry(M.R_leg)
	if (M.head)
		components["head"] = odyssey_mech_component_entry(M.head)
	if (M.body)
		components["body"] = odyssey_mech_component_entry(M.body)
	var/list/hardpoints = list()
	for (var/slot in M.hardpoints)
		var/obj/item/mech_equipment/EQ = M.hardpoints[slot]
		if (istype(EQ))
			hardpoints[slot] = "[EQ.type]"
	var/obj/item/cell/cell = M.get_cell(TRUE)
	return list(
		"x" = T.x,
		"y" = T.y,
		"z" = T.z,
		"type" = "[M.type]",
		"name" = M.name,
		"hatch_closed" = M.hatch_closed,
		"hatch_locked" = M.hatch_locked,
		"power" = M.power,
		"cell_charge" = cell?.charge,
		"cell_max" = cell?.maxcharge,
		"components" = components,
		"hardpoints" = hardpoints
	)


/proc/odyssey_apply_mech_component(obj/item/mech_component/C, list/data)
	if (!istype(C) || !islist(data))
		return
	C.brute_damage = max(0, data["brute"] || 0)
	C.burn_damage = max(0, data["burn"] || 0)
	if (!isnull(data["unrepairable_damage"]))
		C.unrepairable_damage = max(0, data["unrepairable_damage"])
	C.update_health()


/proc/odyssey_apply_mech_destroy_entry(list/entry)
	if (!islist(entry) || entry["action"] != "destroyed")
		return FALSE
	var/mob/living/exosuit/M = odyssey_find_mech_by_id(entry["id"])
	if (!M)
		return FALSE
	odyssey_index_remove(odyssey_ensure_state().persist_index_mechs, entry["id"])
	qdel(M)
	return TRUE


/proc/odyssey_apply_mech_entry(list/entry)
	if (!islist(entry) || entry["action"] == "destroyed")
		return FALSE
	var/turf/T = odyssey_locate_turf(entry)
	if (!T)
		return FALSE
	var/path = text2path(entry["type"])
	if (!ispath(path, /mob/living/exosuit))
		return FALSE
	var/mob/living/exosuit/M = odyssey_find_mech_by_id(entry["id"])
	if (!M && !entry["action"])
		M = locate(path) in T
	if (!M && entry["action"] == "created")
		M = new path(T)
	if (!istype(M))
		return FALSE
	if (entry["id"])
		M.odyssey_persist_id = entry["id"]
		odyssey_index_put(odyssey_ensure_state().persist_index_mechs, entry["id"], M)
	if (get_turf(M) != T)
		M.forceMove(T)
	if (entry["name"])
		M.SetName(entry["name"])
	if (!isnull(entry["hatch_closed"]))
		M.hatch_closed = !!entry["hatch_closed"]
	if (!isnull(entry["hatch_locked"]))
		M.hatch_locked = !!entry["hatch_locked"]
	if (!isnull(entry["power"]))
		M.power = entry["power"]
	var/list/components = entry["components"]
	if (islist(components))
		odyssey_apply_mech_component(M.L_arm, components["L_arm"])
		odyssey_apply_mech_component(M.R_arm, components["R_arm"])
		odyssey_apply_mech_component(M.L_leg, components["L_leg"])
		odyssey_apply_mech_component(M.R_leg, components["R_leg"])
		odyssey_apply_mech_component(M.head, components["head"])
		odyssey_apply_mech_component(M.body, components["body"])
	var/obj/item/cell/cell = M.get_cell(TRUE)
	if (istype(cell) && !isnull(entry["cell_charge"]))
		cell.charge = clamp(entry["cell_charge"], 0, cell.maxcharge)
	var/list/hardpoints = entry["hardpoints"]
	if (islist(hardpoints))
		var/list/existing_slots = M.hardpoints?.Copy() || list()
		for (var/slot in existing_slots)
			var/obj/item/old_eq = M.hardpoints[slot]
			if (old_eq)
				M.remove_system(slot, null, TRUE)
				qdel(old_eq)
		for (var/slot in hardpoints)
			var/eq_path = text2path(hardpoints[slot])
			if (!ispath(eq_path, /obj/item/mech_equipment))
				continue
			var/obj/item/mech_equipment/EQ = new eq_path(M)
			M.install_system(EQ, slot, null)
	M.updatehealth()
	M.queue_icon_update()
	return TRUE


/proc/odyssey_apply_mechs(list/entries)
	if (!islist(entries) || !length(entries))
		return
	var/applied = 0
	for (var/list/entry in entries)
		if (odyssey_apply_mech_destroy_entry(entry))
			applied++
	for (var/list/entry in entries)
		if (odyssey_apply_mech_entry(entry))
			applied++
	log_debug("ODYSSEY: apply_mechs applied=[applied]/[length(entries)]")


/proc/odyssey_find_mech_by_id(id)
	if (!id)
		return null
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (islist(state.persist_index_mechs))
		return odyssey_index_get(state.persist_index_mechs, id)
	for (var/mob/living/exosuit/M in world)
		if (!QDELETED(M) && M.odyssey_persist_id == id)
			return M
	return null
