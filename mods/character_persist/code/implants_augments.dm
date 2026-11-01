/// Odyssey body lane: surgical augments + implants on the doll.
/// Written only into Odyssey snapshots; normal persist strips these keys on save.

/proc/character_persist_implant_denied(path)
	if (!ispath(path, /obj/item/implant))
		return TRUE
	if (ispath(path, /obj/item/implant/uplink))
		return TRUE
	if (ispath(path, /obj/item/implant/explosive))
		return TRUE
	if (ispath(path, /obj/item/implant/compressed))
		return TRUE
	if (ispath(path, /obj/item/implant/freedom))
		return TRUE
	if (ispath(path, /obj/item/implant/imprinting))
		return TRUE
	if (ispath(path, /obj/item/implant/adrenalin))
		return TRUE
	if (ispath(path, /obj/item/implant/processing/mobspawner))
		return TRUE
	// Job.equip reinstalls dampeners for registered psionics; avoid doubles.
	if (ispath(path, /obj/item/implant/psi_control))
		return TRUE
	return FALSE


/proc/character_persist_serialize_atom_reagents(atom/A)
	var/list/out = list()
	if (!istype(A) || !A.reagents)
		return out
	for (var/datum/reagent/R in A.reagents.reagent_list)
		if (!istype(R) || R.volume <= 0)
			continue
		out += list(list("type" = "[R.type]", "amount" = R.volume))
	return out


/proc/character_persist_apply_atom_reagents(atom/A, list/entries)
	if (!istype(A) || !islist(entries) || !A.reagents)
		return
	A.reagents.clear_reagents()
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		var/path = character_persist_safe_resolve_path(entry["type"])
		var/amount = text2num(entry["amount"])
		if (!ispath(path, /datum/reagent) || !(amount > 0))
			continue
		if (character_persist_safe_reagent_path_forbidden(path))
			continue
		A.reagents.add_reagent(path, amount)


/proc/character_persist_capture_augments(mob/living/carbon/human/H)
	var/list/out = list()
	if (!istype(H))
		return out
	for (var/tag in H.internal_organs_by_name)
		var/obj/item/organ/internal/augment/A = H.internal_organs_by_name[tag]
		if (!istype(A) || QDELETED(A))
			continue
		var/list/entry = list(
			"type" = "[A.type]",
			"organ_tag" = A.organ_tag,
			"parent_organ" = A.parent_organ,
			"damage" = A.damage
		)
		out += list(entry)
	return out


/proc/character_persist_capture_implants(mob/living/carbon/human/H)
	var/list/out = list()
	if (!istype(H))
		return out
	for (var/obj/item/organ/external/O in H.organs)
		if (!istype(O) || !length(O.implants))
			continue
		for (var/obj/item/implant/imp in O.implants)
			if (!istype(imp) || QDELETED(imp))
				continue
			if (character_persist_implant_denied(imp.type))
				continue
			var/list/entry = list(
				"type" = "[imp.type]",
				"zone" = O.organ_tag
			)
			if (istype(imp, /obj/item/implant/tracking))
				var/obj/item/implant/tracking/T = imp
				entry["id"] = T.id
			if (imp.reagents?.total_volume)
				entry["reagents"] = character_persist_serialize_atom_reagents(imp)
			out += list(entry)
	return out


/proc/character_persist_apply_augments(mob/living/carbon/human/H, list/entries)
	if (!istype(H) || !islist(entries))
		return
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		var/path = character_persist_safe_resolve_path(entry["type"])
		if (!ispath(path, /obj/item/organ/internal/augment))
			continue
		var/organ_tag = entry["organ_tag"]
		var/parent_tag = entry["parent_organ"]
		if (!organ_tag || !parent_tag)
			continue
		var/obj/item/organ/external/parent = H.get_organ(parent_tag)
		if (!istype(parent))
			continue
		var/obj/item/organ/internal/existing = H.internal_organs_by_name[organ_tag]
		if (istype(existing))
			existing.removed(null, FALSE)
			qdel(existing)
		var/obj/item/organ/internal/augment/A = new path(null)
		if (QDELETED(A))
			continue
		A.organ_tag = organ_tag
		A.parent_organ = parent_tag
		A.status &= ~ORGAN_CUT_AWAY
		var/cap = A.max_damage * CHARACTER_PERSIST_DAMAGE_RATIO
		A.damage = clamp(character_persist_num(entry["damage"]), 0, cap)
		A.forceMove(H)
		if (!A.replaced(H, parent))
			qdel(A)
			continue
		A.onRoundstart()


/proc/character_persist_apply_implants(mob/living/carbon/human/H, list/entries)
	if (!istype(H) || !islist(entries))
		return
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		var/path = character_persist_safe_resolve_path(entry["type"])
		if (character_persist_implant_denied(path))
			continue
		var/zone = entry["zone"]
		if (!zone || !H.get_organ(zone))
			continue
		var/obj/item/implant/imp = new path(null)
		if (QDELETED(imp))
			continue
		if (istype(imp, /obj/item/implant/tracking) && !isnull(entry["id"]))
			var/obj/item/implant/tracking/T = imp
			T.id = clamp(character_persist_num(entry["id"]), 1, 100)
		if (islist(entry["reagents"]) && imp.reagents)
			character_persist_apply_atom_reagents(imp, entry["reagents"])
		if (!imp.implant_in_mob(H, zone))
			qdel(imp)
