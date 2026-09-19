/proc/odyssey_corpse_identity(mob/living/carbon/human/H)
	if (!istype(H))
		return null
	if (H.odyssey_corpse_key)
		return H.odyssey_corpse_key
	var/ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (ckey && slot)
		return odyssey_roster_key(ckey, slot)
	if (H.real_name && H.real_name != "unknown")
		return "name:[H.real_name]"
	return null


/proc/odyssey_corpse_on_ship(mob/living/carbon/human/H)
	if (!istype(H) || QDELETED(H))
		return FALSE
	var/turf/T = get_turf(H)
	if (!T)
		return FALSE
	if (odyssey_atom_persistable(H))
		return TRUE
	// Closed morgue keeps the body in nullspace-like contents; still count it if the tray is on the ship.
	var/atom/storage = H.loc
	while (istype(storage) && !isturf(storage))
		if (istype(storage, /obj/structure/morgue) || istype(storage, /obj/structure/m_tray) || istype(storage, /obj/structure/closet))
			return odyssey_turf_persistable(get_turf(storage))
		storage = storage.loc
	return FALSE


/proc/odyssey_corpse_uniform_entry(mob/living/carbon/human/H)
	var/obj/item/clothing/under/uniform = H.w_uniform
	if (!istype(uniform))
		return null
	var/list/entry = list("type" = "[uniform.type]")
	if (uniform.name != initial(uniform.name))
		entry["name"] = uniform.name
	if (uniform.color)
		entry["color"] = "[uniform.color]"
	return entry


/proc/odyssey_collect_corpses()
	var/list/entries = list()
	var/list/seen = list()
	for (var/mob/living/carbon/human/H in GLOB.human_mobs)
		if (QDELETED(H) || H.stat != DEAD)
			continue
		if (istype(H, /mob/living/carbon/human/dummy))
			continue
		if (character_persist_is_virtual_body(H))
			continue
		if (character_persist_is_offstation_antag(H))
			continue
		if (!odyssey_corpse_on_ship(H))
			continue
		var/key = odyssey_corpse_identity(H)
		if (!key || seen[key])
			continue
		var/list/body = character_persist_capture(H)
		if (!islist(body))
			continue
		seen[key] = TRUE
		H.odyssey_corpse_key = key
		var/list/entry = list(
			"id" = key,
			"name" = H.real_name,
			"species" = H.species?.name,
			"body" = body,
			"husked" = !!(MUTATION_HUSK in H.mutations)
		)
		var/list/uniform = odyssey_corpse_uniform_entry(H)
		if (islist(uniform))
			entry["uniform"] = uniform
		entries += list(entry)
	return entries


/proc/odyssey_station_morgues()
	var/list/morgues = list()
	for (var/obj/structure/morgue/M in world)
		if (QDELETED(M) || !odyssey_atom_persistable(M))
			continue
		morgues += M
	return morgues


/proc/odyssey_apply_corpse_uniform(mob/living/carbon/human/H, list/uniform)
	if (!istype(H) || !islist(uniform))
		return
	var/path = text2path(uniform["type"])
	if (!ispath(path, /obj/item/clothing/under))
		return
	var/obj/item/clothing/under/item = new path(H)
	if (uniform["name"])
		item.SetName(uniform["name"])
	if (uniform["color"])
		item.color = uniform["color"]
	if (!H.equip_to_slot_if_possible(item, slot_w_uniform, TRYEQUIP_REDRAW | TRYEQUIP_SILENT | TRYEQUIP_FORCE | TRYEQUIP_INSTANT | TRYEQUIP_DESTROY))
		if (!QDELETED(item))
			qdel(item)


/proc/odyssey_find_restored_corpse(id)
	if (!id)
		return null
	for (var/mob/living/carbon/human/H in GLOB.human_mobs)
		if (!QDELETED(H) && H.odyssey_corpse_restored && H.odyssey_corpse_key == id)
			return H
	return null


/proc/odyssey_apply_corpse_entry(list/entry, obj/structure/morgue/M)
	if (!islist(entry) || !istype(M))
		return FALSE
	if (odyssey_find_restored_corpse(entry["id"]))
		return FALSE
	var/mob/living/carbon/human/H = new /mob/living/carbon/human(M, entry["species"])
	H.odyssey_corpse_restored = TRUE
	H.odyssey_corpse_key = entry["id"]
	if (entry["name"])
		H.real_name = entry["name"]
		H.SetName(entry["name"])
		if (H.dna)
			H.dna.real_name = H.real_name
	character_persist_apply_snapshot(H, entry["body"])
	if (entry["husked"])
		H.ChangeToHusk()
	H.death(FALSE)
	odyssey_apply_corpse_uniform(H, entry["uniform"])
	if (get_turf(H) != get_turf(M) && H.loc != M)
		H.forceMove(M)
	M.update()
	return TRUE


/proc/odyssey_apply_corpses(list/entries)
	if (!islist(entries) || !length(entries))
		return
	var/list/morgues = odyssey_station_morgues()
	if (!length(morgues))
		log_error("ODYSSEY: cannot apply corpses, no ship morgues found")
		return
	var/applied = 0
	var/index = 1
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		if (odyssey_apply_corpse_entry(entry, morgues[index]))
			applied++
			index += 1
			if (index > length(morgues))
				index = 1
	log_debug("ODYSSEY: apply_corpses applied=[applied]/[length(entries)] morgues=[length(morgues)]")
