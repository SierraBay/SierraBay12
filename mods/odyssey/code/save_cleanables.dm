/// Odyssey filth / blood atmosphere — cleanables.json (not Bay SSpersistence filth).


/proc/odyssey_cleanable_path_denylisted(path)
	if (!ispath(path, /obj/decal/cleanable))
		return TRUE
	// Crayon needs colour args in New; skip MVP.
	if (ispath(path, /obj/decal/cleanable/crayon))
		return TRUE
	return FALSE


/proc/odyssey_serialize_cleanable(obj/decal/cleanable/C)
	if (!istype(C) || QDELETED(C))
		return null
	if (odyssey_cleanable_path_denylisted(C.type))
		return null
	if (!odyssey_atom_in_persistable_area(C))
		return null
	var/turf/T = get_turf(C)
	if (!T)
		return null
	var/list/entry = list(
		"type" = "[C.type]",
		"x" = T.x,
		"y" = T.y,
		"z" = T.z,
		"dir" = C.dir,
		"icon_state" = C.icon_state,
		"age" = C.age
	)
	odyssey_write_pixel_offset(C, entry)
	if (istype(C, /obj/decal/cleanable/blood))
		var/obj/decal/cleanable/blood/B = C
		entry["amount"] = B.amount
		entry["basecolor"] = B.basecolor
		if (islist(B.blood_DNA) && length(B.blood_DNA))
			entry["blood_DNA"] = B.blood_DNA.Copy()
	return entry


/proc/odyssey_collect_cleanables()
	var/list/entries = list()
	for (var/turf/T in odyssey_get_persistable_turfs())
		for (var/obj/decal/cleanable/C in T)
			var/list/entry = odyssey_serialize_cleanable(C)
			if (entry)
				entries += list(entry)
		CHECK_TICK
	return entries


/proc/odyssey_strip_cleanables()
	var/removed = 0
	for (var/turf/T in odyssey_get_persistable_turfs())
		for (var/obj/decal/cleanable/C in T)
			if (odyssey_cleanable_path_denylisted(C.type))
				continue
			qdel(C)
			removed++
		CHECK_TICK
	log_debug("ODYSSEY: stripped [removed] cleanables")
	return removed


/proc/odyssey_apply_cleanable_entry(list/entry)
	if (!islist(entry))
		return FALSE
	var/path = character_persist_safe_resolve_path(entry["type"])
	if (odyssey_cleanable_path_denylisted(path))
		return FALSE
	var/turf/T = odyssey_locate_turf(entry)
	if (!T)
		return FALSE
	var/obj/decal/cleanable/C = new path(T)
	if (QDELETED(C) || !istype(C))
		return FALSE
	if (!isnull(entry["dir"]))
		C.set_dir(entry["dir"])
	odyssey_apply_pixel_offset(C, entry)
	if (entry["icon_state"])
		C.icon_state = entry["icon_state"]
	var/age = entry["age"]
	if (!isnum(age))
		age = text2num(age)
	if (isnum(age))
		C.age = age
	if (istype(C, /obj/decal/cleanable/blood))
		var/obj/decal/cleanable/blood/B = C
		var/amount = entry["amount"]
		if (!isnum(amount))
			amount = text2num(amount)
		if (isnum(amount))
			B.amount = amount
		if (entry["basecolor"])
			B.basecolor = entry["basecolor"]
		var/list/dna = entry["blood_DNA"]
		if (islist(dna))
			B.blood_DNA = dna.Copy()
		B.update_icon()
	return TRUE


/proc/odyssey_apply_cleanables(list/entries)
	if (!islist(entries) || !length(entries))
		return
	var/applied = 0
	for (var/list/entry in entries)
		if (odyssey_apply_cleanable_entry(entry))
			applied++
		CHECK_TICK
	log_debug("ODYSSEY: apply_cleanables applied=[applied]/[length(entries)]")
