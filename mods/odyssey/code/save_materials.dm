/// True for sheet stacks left on the ship (floor, rack, crate) — not in a mob inventory.
/proc/odyssey_material_stack_persistable(obj/item/stack/material/S)
	if (!istype(S) || QDELETED(S) || S.uses_charge)
		return FALSE
	if (!odyssey_atom_persistable(S))
		return FALSE
	var/atom/A = S.loc
	while (A && !isturf(A))
		if (ismob(A))
			return FALSE
		A = A.loc
	return TRUE


/proc/odyssey_collect_materials()
	var/list/entries = list()
	for (var/obj/item/stack/material/S in world)
		if (!odyssey_material_stack_persistable(S))
			continue
		var/turf/T = get_turf(S)
		if (!T)
			continue
		var/amount = S.get_amount()
		if (!isnum(amount) || amount < 1)
			continue
		entries += list(list(
			"type" = "[S.type]",
			"amount" = amount,
			"x" = T.x,
			"y" = T.y,
			"z" = T.z,
			"in_closet" = !!istype(S.loc, /obj/structure/closet)
		))
		CHECK_TICK
	return entries


/// Map DMM stacks would refill every continue; wipe persistable station stacks first.
/proc/odyssey_strip_map_materials()
	var/removed = 0
	for (var/obj/item/stack/material/S in world)
		if (QDELETED(S))
			continue
		if (!odyssey_atom_persistable(S))
			continue
		qdel(S)
		removed++
		CHECK_TICK
	log_debug("ODYSSEY: stripped [removed] map material stacks on continue")
	return removed


/proc/odyssey_apply_material_entry(list/entry)
	if (!islist(entry))
		return FALSE
	var/turf/T = odyssey_locate_turf(entry)
	if (!T)
		return FALSE
	var/path = text2path(entry["type"])
	if (!ispath(path, /obj/item/stack/material))
		return FALSE
	var/amount = entry["amount"]
	if (!isnum(amount))
		amount = text2num(amount)
	if (!isnum(amount) || amount < 1)
		return FALSE
	var/obj/item/stack/material/S = new path(T, amount)
	if (QDELETED(S))
		return FALSE
	if (S.amount != amount)
		S.amount = min(amount, S.max_amount || amount)
	if (entry["in_closet"])
		var/obj/structure/closet/C = locate() in T
		if (istype(C))
			S.forceMove(C)
	return TRUE


/proc/odyssey_apply_materials(list/entries)
	if (!islist(entries) || !length(entries))
		return
	var/applied = 0
	for (var/list/entry in entries)
		if (odyssey_apply_material_entry(entry))
			applied++
		CHECK_TICK
	log_debug("ODYSSEY: apply_materials applied=[applied]/[length(entries)]")
