/// Detached organs as crew remains — remains.json (not items_*).


/proc/odyssey_organ_is_detached(obj/item/organ/O)
	if (!istype(O) || QDELETED(O))
		return FALSE
	if (odyssey_atom_in_mob_inventory(O))
		return FALSE
	if (iscarbon(O.loc))
		return FALSE
	if (odyssey_atom_in_character_persist_safe(O))
		return FALSE
	if (!odyssey_atom_in_persistable_area(O))
		return FALSE
	return TRUE


/proc/odyssey_dna_compact_snapshot(datum/dna/D)
	if (!istype(D))
		return null
	return list(
		"unique_enzymes" = D.unique_enzymes,
		"b_type" = D.b_type,
		"species" = D.species,
		"real_name" = D.real_name
	)


/proc/odyssey_dna_from_compact(list/data)
	if (!islist(data) || !data["unique_enzymes"])
		return null
	var/datum/dna/D = new
	D.unique_enzymes = data["unique_enzymes"]
	D.b_type = data["b_type"] || "A+"
	D.species = data["species"] || SPECIES_HUMAN
	D.real_name = data["real_name"]
	return D


/proc/odyssey_remains_roster_key(owner_name)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!length(state.roster))
		return null
	for (var/key in state.roster)
		var/list/entry = state.roster[key]
		if (!islist(entry) || entry["status"] != "dead")
			continue
		if (owner_name && entry["name"] == owner_name)
			return key
	return null


/proc/odyssey_organ_container_flags(obj/item/organ/O)
	var/list/flags = list("in_closet" = FALSE, "in_morgue" = FALSE)
	if (istype(O.loc, /obj/structure/closet))
		flags["in_closet"] = TRUE
	else if (istype(O.loc, /obj/structure/morgue))
		flags["in_morgue"] = TRUE
	return flags


/proc/odyssey_serialize_organ_remain(obj/item/organ/O)
	if (!odyssey_organ_is_detached(O))
		return null
	var/turf/T = get_turf(O)
	if (!T)
		return null
	var/list/dna_snap = odyssey_dna_compact_snapshot(O.dna)
	var/owner_name = islist(dna_snap) ? dna_snap["real_name"] : null
	if (!owner_name)
		owner_name = O.dna?.real_name
	var/list/container = odyssey_organ_container_flags(O)
	var/list/entry = list(
		"type" = "[O.type]",
		"organ_tag" = O.organ_tag,
		"x" = T.x,
		"y" = T.y,
		"z" = T.z,
		"dir" = O.dir,
		"name" = O.name,
		"damage" = O.damage,
		"in_closet" = container["in_closet"],
		"in_morgue" = container["in_morgue"],
		"owner_name" = owner_name,
		"dna" = dna_snap,
		"roster_key" = odyssey_remains_roster_key(owner_name)
	)
	odyssey_write_pixel_offset(O, entry)
	if (istype(O, /obj/item/organ/external))
		var/obj/item/organ/external/E = O
		entry["brute"] = E.brute_dam
		entry["burn"] = E.burn_dam
		if (BP_IS_ROBOTIC(E))
			entry["robotic"] = TRUE
			if (E.model)
				entry["model"] = E.model
	else if (BP_IS_ROBOTIC(O))
		entry["robotic"] = TRUE
	if (O.species)
		entry["species"] = O.species.name
	return entry


/proc/odyssey_collect_organs_from(atom/container, list/entries)
	for (var/obj/item/organ/O in container)
		var/list/entry = odyssey_serialize_organ_remain(O)
		if (entry)
			entries += list(entry)


/proc/odyssey_collect_remains()
	var/list/entries = list()
	for (var/turf/T in odyssey_get_persistable_turfs())
		odyssey_collect_remains_turf(T, entries)
		CHECK_TICK
	return entries


/proc/odyssey_collect_remains_turf(turf/T, list/entries)
	if (!istype(T) || !islist(entries))
		return
	odyssey_collect_organs_from(T, entries)
	for (var/obj/structure/closet/C in T)
		odyssey_collect_organs_from(C, entries)
	for (var/obj/structure/morgue/M in T)
		odyssey_collect_organs_from(M, entries)


/proc/odyssey_strip_organs_from(atom/container)
	var/removed = 0
	for (var/obj/item/organ/O in container)
		if (!odyssey_organ_is_detached(O))
			continue
		qdel(O)
		removed++
	return removed


/proc/odyssey_strip_remains()
	var/removed = 0
	for (var/turf/T in odyssey_get_persistable_turfs())
		removed += odyssey_strip_organs_from(T)
		for (var/obj/structure/closet/C in T)
			removed += odyssey_strip_organs_from(C)
		for (var/obj/structure/morgue/M in T)
			removed += odyssey_strip_organs_from(M)
		CHECK_TICK
	log_debug("ODYSSEY: stripped [removed] organ remains")
	return removed


/proc/odyssey_place_organ_remain(obj/item/organ/O, list/entry, turf/T)
	if (entry["in_closet"])
		var/obj/structure/closet/C = locate() in T
		if (istype(C))
			O.forceMove(C)
			return
	if (entry["in_morgue"])
		var/obj/structure/morgue/M = locate() in T
		if (istype(M))
			O.forceMove(M)


/proc/odyssey_apply_remain_entry(list/entry)
	if (!islist(entry))
		return FALSE
	var/path = character_persist_safe_resolve_path(entry["type"])
	if (!ispath(path, /obj/item/organ))
		return FALSE
	var/turf/T = odyssey_locate_turf(entry)
	if (!T)
		return FALSE
	var/datum/dna/given = odyssey_dna_from_compact(entry["dna"])
	var/obj/item/organ/O = new path(T, given)
	if (QDELETED(O))
		return FALSE
	if (!isnull(entry["dir"]))
		O.set_dir(entry["dir"])
	odyssey_apply_pixel_offset(O, entry)
	if (entry["name"])
		O.SetName(entry["name"])
	else if (entry["owner_name"])
		O.SetName("[entry["owner_name"]]'s [initial(O.name)]")
	var/dmg = entry["damage"]
	if (!isnum(dmg))
		dmg = text2num(dmg)
	if (isnum(dmg))
		O.damage = dmg
	if (istype(O, /obj/item/organ/external))
		var/obj/item/organ/external/E = O
		var/brute = entry["brute"]
		var/burn = entry["burn"]
		if (!isnum(brute))
			brute = text2num(brute)
		if (!isnum(burn))
			burn = text2num(burn)
		if (isnum(brute) && brute > 0)
			E.createwound(INJURY_TYPE_BRUISE, brute, TRUE)
		if (isnum(burn) && burn > 0)
			E.createwound(INJURY_TYPE_BURN, burn, TRUE)
		if (entry["robotic"] && entry["model"])
			E.model = entry["model"]
	odyssey_place_organ_remain(O, entry, T)
	return TRUE


/proc/odyssey_apply_remains(list/entries)
	if (!islist(entries) || !length(entries))
		return
	var/applied = 0
	for (var/list/entry in entries)
		if (odyssey_apply_remain_entry(entry))
			applied++
		CHECK_TICK
	log_debug("ODYSSEY: apply_remains applied=[applied]/[length(entries)]")
