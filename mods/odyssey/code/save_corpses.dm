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
	// Same volume as items/materials: persistable areas including docked shuttles off station Z.
	if (odyssey_atom_in_persistable_area(H))
		return TRUE
	// Closed morgue keeps the body in nullspace-like contents; still count it if the tray is on the ship.
	var/atom/storage = H.loc
	while (istype(storage) && !isturf(storage))
		if (istype(storage, /obj/structure/morgue) || istype(storage, /obj/structure/m_tray) || istype(storage, /obj/structure/closet))
			return odyssey_atom_in_persistable_area(storage)
		storage = storage.loc
	return FALSE


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
		var/list/gear = odyssey_capture_corpse_gear(H)
		entries += list(list(
			"id" = key,
			"name" = H.real_name,
			"species" = H.species?.name,
			"body" = body,
			"husked" = !!(MUTATION_HUSK in H.mutations),
			"gear" = gear
		))
		CHECK_TICK
	return entries


/proc/odyssey_station_morgues()
	var/list/morgues = list()
	for (var/turf/T in odyssey_get_persistable_turfs())
		for (var/obj/structure/morgue/M in T)
			if (QDELETED(M))
				continue
			morgues += M
		CHECK_TICK
	return morgues


/proc/odyssey_find_restored_corpse(id)
	if (!id)
		return null
	for (var/mob/living/carbon/human/H in GLOB.human_mobs)
		if (!QDELETED(H) && H.odyssey_corpse_restored && H.odyssey_corpse_key == id)
			return H
	return null


/proc/odyssey_capture_carried_tree(obj/item/I, list/entries, storage_id, storage_kind, storage_acc)
	var/list/entry = odyssey_serialize_item(I, storage_id, TRUE)
	if (!islist(entry))
		return
	if (storage_kind)
		entry["storage_kind"] = storage_kind
	if (storage_acc)
		entry["storage_acc"] = storage_acc
	entries += list(entry)
	var/pid = entry["id"]
	if (istype(I, /obj/item/storage))
		for (var/obj/item/child in I)
			odyssey_capture_carried_tree(child, entries, pid)
	if (istype(I, /obj/item/clothing/suit/storage))
		var/obj/item/clothing/suit/storage/S = I
		if (istype(S.pockets))
			for (var/obj/item/child in S.pockets)
				odyssey_capture_carried_tree(child, entries, pid, "pockets")
	if (istype(I, /obj/item/clothing))
		var/obj/item/clothing/C = I
		if (islist(C.accessories))
			for (var/obj/item/clothing/accessory/storage/A in C.accessories)
				if (!istype(A.container))
					continue
				var/acc_key = "[A.type]"
				for (var/obj/item/child in A.container)
					odyssey_capture_carried_tree(child, entries, pid, "accessory", acc_key)


/proc/odyssey_capture_corpse_gear(mob/living/carbon/human/H)
	var/list/entries = list()
	if (!istype(H))
		return entries
	for (var/obj/item/I in H.get_equipped_items(TRUE))
		odyssey_capture_carried_tree(I, entries, null)
	return entries


/proc/odyssey_morgue_gear_closet(obj/structure/morgue/M)
	var/turf/T = get_turf(M)
	if (!istype(T))
		return null
	for (var/dir in GLOB.cardinal)
		var/turf/neighbor = get_step(T, dir)
		if (!istype(neighbor))
			continue
		for (var/obj/structure/closet/C in neighbor)
			if (!QDELETED(C))
				return C
	var/area/here = get_area(M)
	if (!istype(here))
		return null
	var/obj/structure/closet/best
	var/best_dist = 999
	for (var/obj/structure/closet/C in here)
		if (QDELETED(C))
			continue
		var/dist = get_dist(T, C)
		if (!istype(best) || dist < best_dist)
			best = C
			best_dist = dist
	return best


/// Strip personal gear and put the body in a blue hospital patient gown.
/proc/odyssey_dress_corpse_as_patient(mob/living/carbon/human/H)
	if (!istype(H) || QDELETED(H))
		return
	for (var/obj/item/I in H.get_equipped_items(TRUE))
		H.drop_from_inventory(I)
		if (!QDELETED(I))
			qdel(I)
	var/obj/item/clothing/suit/hospital/blue/gown = new /obj/item/clothing/suit/hospital/blue(H)
	if (!H.equip_to_slot_if_possible(gown, slot_wear_suit, TRYEQUIP_REDRAW | TRYEQUIP_SILENT | TRYEQUIP_FORCE | TRYEQUIP_INSTANT | TRYEQUIP_DESTROY))
		if (!QDELETED(gown))
			qdel(gown)


/proc/odyssey_sanitize_corpse_appearance(mob/living/carbon/human/H)
	if (!istype(H))
		return
	if (H.pronouns && !GLOB.pronouns.by_key[H.pronouns])
		H.pronouns = null
	if (!H.dna)
		H.dna = new /datum/dna(null)
	H.dna.ready_dna(H)
	H.dna.real_name = H.real_name
	H.sync_organ_dna()
	H.force_update_limbs()
	H.update_body(0)
	H.update_hair(0)
	H.update_icons()


/proc/odyssey_apply_corpse_entry(list/entry, obj/structure/morgue/M)
	if (!islist(entry) || !istype(M))
		return FALSE
	if (odyssey_find_restored_corpse(entry["id"]))
		return FALSE
	var/species_name = entry["species"]
	var/mob/living/carbon/human/H = new /mob/living/carbon/human(M, species_name)
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
	odyssey_dress_corpse_as_patient(H)
	if (islist(entry["gear"]) && length(entry["gear"]))
		var/atom/gear_dest = odyssey_morgue_gear_closet(M) || M
		odyssey_apply_gear_list(entry["gear"], gear_dest)
	odyssey_sanitize_corpse_appearance(H)
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
		CHECK_TICK
	log_debug("ODYSSEY: apply_corpses applied=[applied]/[length(entries)] morgues=[length(morgues)]")
