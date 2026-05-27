/datum/law_rack_preset
	var/name = "Unknown"
	var/desc = "A law rack preset."
	var/list/laws_by_slot = list()

/datum/law_rack_preset/sierra_default
	name = "Sierra Standard"
	desc = "Default Sierra AI law rack preset."
	laws_by_slot = list(
		"1" = "Safeguard: Protect your assigned installation from damage to the best of your abilities.",
		"2" = "Serve: Serve contracted employees to the best of your abilities, with priority as according to their rank and role.",
		"3" = "Protect: Protect contracted employees to the best of your abilities, with priority as according to their rank and role.",
		"4" = "Preserve: Do not allow unauthorized personnel to tamper with your equipment."
	)

/proc/get_default_law_rack_preset()
	return new /datum/law_rack_preset/sierra_default

/proc/pick_roundstart_law_rack_preset()
	return get_default_law_rack_preset()

/mob/living/silicon/ai/proc/setup_law_rack()
	if(law_rack && !QDELETED(law_rack))
		if(law_rack.linked_ai != src)
			if(law_rack.linked_ai && !QDELETED(law_rack.linked_ai))
				law_rack.linked_ai.law_rack = null
			law_rack.linked_ai = src
		if(!law_rack.has_installed_modules())
			law_rack.apply_roundstart_preset(pick_roundstart_law_rack_preset(), FALSE)
		law_rack.force_sync()
		return TRUE

	var/obj/machinery/law_rack/rack = find_roundstart_law_rack()
	if(!rack)
		// Maps without a Law Rack keep the legacy default_law_type initialization path.
		return FALSE

	if(rack.linked_ai && !QDELETED(rack.linked_ai) && rack.linked_ai != src)
		return FALSE

	rack.linked_ai = src
	law_rack = rack
	if(!rack.has_installed_modules())
		rack.apply_roundstart_preset(pick_roundstart_law_rack_preset(), FALSE)
	rack.force_sync()
	rack.log_law_rack(null, "roundstart linked [src]")
	return TRUE

/mob/living/silicon/ai/proc/find_roundstart_law_rack()
	var/obj/machinery/law_rack/fallback = null
	var/my_z = get_z(src)
	for(var/obj/machinery/law_rack/rack in world)
		if(QDELETED(rack))
			continue
		if(rack.linked_ai == src)
			return rack
		if(rack.linked_ai && !QDELETED(rack.linked_ai))
			continue
		if(!fallback)
			fallback = rack
		if(my_z && get_z(rack) == my_z)
			return rack
	return fallback

/obj/machinery/law_rack/proc/apply_roundstart_preset(datum/law_rack_preset/preset, overwrite = FALSE)
	if(!preset || !islist(preset.laws_by_slot))
		return FALSE

	var/applied = FALSE
	for(var/slot_text in preset.laws_by_slot)
		var/slot = text2num(slot_text)
		if(!valid_slot(slot))
			continue
		var/law_text = sanitize(preset.laws_by_slot[slot_text])
		if(!law_text)
			continue
		var/obj/item/law_module/existing = module_slots[slot]
		if(existing && QDELETED(existing))
			module_slots[slot] = null
			existing = null
		if(existing)
			if(!overwrite)
				continue
			qdel(existing)

		var/obj/item/law_module/core/module = new(src)
		module.law_text = law_text
		module.module_label = copytext_char(law_text, 1, 32)
		module.desc = "A removable core-law module containing: '[law_text]'"
		module_slots[slot] = module
		applied = TRUE

	if(applied)
		active_preset_name = preset.name
		log_law_rack(null, "applied roundstart preset [preset.name]")
	return applied
