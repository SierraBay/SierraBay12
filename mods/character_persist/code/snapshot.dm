/proc/character_persist_path(ckey, slot)
	if (!ckey || !slot)
		return null
	var/map_key = GLOB.using_map?.preferences_key()
	if (!map_key)
		return null
	return "data/player_saves/[copytext_char(ckey, 1, 2)]/[ckey]/character_persist_[map_key]_[slot].json"


/proc/character_persist_read(ckey, slot)
	var/path = character_persist_path(ckey, slot)
	if (!path || !fexists(path))
		return null
	var/text = file2text(path)
	if (!text)
		return null
	var/list/data = json_decode(text)
	if (!islist(data) || !data["version"])
		return null
	return data


/proc/character_persist_write(ckey, slot, list/data)
	var/path = character_persist_path(ckey, slot)
	if (!path || !islist(data))
		return FALSE
	var/text = json_encode(data)
	if (isnull(text))
		log_error("CHARACTER_PERSIST: failed to encode snapshot for [ckey] slot [slot]")
		return FALSE
	var/error = rustg_file_write(text, path)
	if (error)
		log_error("CHARACTER_PERSIST: failed to write [path]: [error]")
		return FALSE
	return TRUE


/proc/character_persist_delete(ckey, slot)
	var/path = character_persist_path(ckey, slot)
	if (!path || !fexists(path))
		return
	fdel(path)


/proc/character_persist_prefs_of(ckey)
	if (!ckey || !SScharacter_setup)
		return null
	return SScharacter_setup.preferences_datums[ckey]


/proc/character_persist_ckey_of(mob/living/carbon/human/H)
	if (!istype(H))
		return null
	if (H.character_persist_ckey)
		return H.character_persist_ckey
	if (H.ckey)
		return H.ckey
	if (H.last_ckey)
		return H.last_ckey
	if (H.mind?.key)
		return ckey(H.mind.key)
	return null


/proc/character_persist_slot_of(mob/living/carbon/human/H)
	if (!istype(H))
		return null
	if (H.character_persist_slot)
		return H.character_persist_slot
	var/ckey = character_persist_ckey_of(H)
	var/datum/preferences/prefs = character_persist_prefs_of(ckey)
	return prefs?.default_slot


/proc/character_persist_evac_active()
	if (!evacuation_controller)
		return FALSE
	if (!evacuation_controller.emergency_evacuation)
		return FALSE
	return evacuation_controller.is_evacuating()


/proc/character_persist_on_ship(atom/A)
	var/area/area = get_area(A)
	if (istype(area, /area/shuttle/escape_pod))
		return TRUE
	if (istype(area) && !istype(area, /area/turbolift) && (area in SSshuttle.shuttle_areas))
		return TRUE
	var/turf/T = get_turf(A)
	if (!T)
		return FALSE
	return istype(map_sectors["[T.z]"], /obj/overmap/visitable/ship)


/proc/character_persist_on_sierra(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	if (!T)
		return FALSE
	if (!isStationLevel(T.z))
		return FALSE
	if (isAdminLevel(T.z) || isEscapeLevel(T.z))
		return FALSE
	return TRUE


/proc/character_persist_can_save_here(mob/living/carbon/human/H)
	if (character_persist_on_sierra(H))
		return TRUE
	return character_persist_evac_active() && character_persist_on_ship(H)


/proc/character_persist_is_offstation_antag(mob/living/carbon/human/H)
	if (!istype(H) || !H.mind)
		return FALSE
	return !!player_is_antag(H.mind, TRUE)


/proc/character_persist_num(value)
	if (isnum(value))
		return value
	var/num = text2num(value)
	if (!isnum(num))
		return 0
	return num


/proc/character_persist_capture(mob/living/carbon/human/H)
	if (!istype(H))
		return null

	var/list/organs = list()
	for (var/name in BP_BY_DEPTH)
		var/obj/item/organ/external/O = H.organs_by_name[name]
		if (!O || O.is_stump())
			organs[name] = list("status" = "amputated")
			continue
		var/list/entry = list(
			"status" = "normal",
			"brute" = O.brute_dam,
			"burn" = O.burn_dam
		)
		if (BP_IS_ROBOTIC(O))
			entry["status"] = "cyborg"
			if (O.model)
				entry["model"] = O.model
		if (O.status & ORGAN_BROKEN)
			entry["broken"] = TRUE
		if (O.status & ORGAN_DISFIGURED)
			entry["disfigured"] = TRUE
		organs[name] = entry

	var/list/internals = list()
	var/list/organ_tags = list()
	if (H.species?.has_organ)
		organ_tags = H.species.has_organ.Copy()
	for (var/tag in H.internal_organs_by_name)
		organ_tags |= tag
	for (var/tag in organ_tags)
		var/obj/item/organ/internal/I = H.internal_organs_by_name[tag]
		if (istype(I, /obj/item/organ/internal/augment))
			continue
		if (!I)
			internals[tag] = list("status" = "missing")
			continue
		var/list/entry = list("status" = "normal", "damage" = I.damage)
		if (BP_IS_ROBOTIC(I))
			entry["status"] = "mechanical"
		else if (BP_IS_ASSISTED(I))
			entry["status"] = "assisted"
		internals[tag] = entry

	var/list/markings = list()
	for (var/obj/item/organ/external/E in H.organs)
		for (var/entry in E.markings)
			var/datum/sprite_accessory/marking/mark_datum = entry
			if (istype(mark_datum))
				markings[mark_datum.name] = E.markings[entry]
			else
				markings[entry] = E.markings[entry]

	return list(
		"version" = CHARACTER_PERSIST_VERSION,
		"saved_at" = time2text(world.realtime, "YYYY-MM-DD hh:mm"),
		"gender" = H.gender,
		"pronouns" = H.pronouns,
		"head_hair_style" = H.head_hair_style,
		"head_hair_color" = H.head_hair_color,
		"facial_hair_style" = H.facial_hair_style,
		"facial_hair_color" = H.facial_hair_color,
		"eye_color" = H.eye_color,
		"skin_tone" = H.skin_tone,
		"skin_color" = H.skin_color,
		"base_skin" = H.base_skin,
		"body_markings" = markings,
		"organs" = organs,
		"internals" = internals
	)


/proc/character_persist_apply_snapshot(mob/living/carbon/human/H, list/snapshot)
	if (!istype(H) || !islist(snapshot))
		return

	if (snapshot["gender"])
		H.gender = snapshot["gender"]
	if (snapshot["pronouns"])
		H.pronouns = snapshot["pronouns"]
	if (snapshot["head_hair_style"] && (snapshot["head_hair_style"] in GLOB.hair_styles_list))
		H.head_hair_style = snapshot["head_hair_style"]
	if (snapshot["head_hair_color"])
		H.head_hair_color = snapshot["head_hair_color"]
	if (snapshot["facial_hair_style"] && (snapshot["facial_hair_style"] in GLOB.facial_hair_styles_list))
		H.facial_hair_style = snapshot["facial_hair_style"]
	if (snapshot["facial_hair_color"])
		H.facial_hair_color = snapshot["facial_hair_color"]
	if (snapshot["eye_color"])
		H.eye_color = snapshot["eye_color"]
	if (!isnull(snapshot["skin_tone"]))
		H.skin_tone = snapshot["skin_tone"]
	if (snapshot["skin_color"])
		H.skin_color = snapshot["skin_color"]
	if (snapshot["base_skin"])
		H.base_skin = snapshot["base_skin"]

	var/list/markings = snapshot["body_markings"]
	if (islist(markings))
		for (var/name in H.organs_by_name)
			var/obj/item/organ/external/O = H.organs_by_name[name]
			if (O)
				O.markings.Cut()
		for (var/M in markings)
			var/datum/sprite_accessory/marking/mark_datum = GLOB.body_marking_styles_list[M]
			if (!istype(mark_datum))
				continue
			var/mark_color = "[markings[M]]"
			for (var/BP in mark_datum.body_parts)
				var/obj/item/organ/external/O = H.organs_by_name[BP]
				if (O)
					O.markings[mark_datum] = mark_color

	var/list/organs = snapshot["organs"]
	if (islist(organs))
		for (var/name in BP_BY_DEPTH)
			var/list/entry = organs[name]
			if (!islist(entry))
				continue
			var/obj/item/organ/external/O = H.organs_by_name[name]
			if (entry["status"] == "amputated")
				if (!O)
					continue
				H.organs_by_name[O.organ_tag] = null
				H.organs -= O
				if (O.children)
					for (var/obj/item/organ/external/child in O.children)
						H.organs_by_name[child.organ_tag] = null
						H.organs -= child
						qdel(child)
				qdel(O)
				continue
			if (!O)
				continue
			if (entry["status"] == "cyborg")
				var/model = entry["model"]
				if (model && all_robolimbs[model])
					O.robotize(model)
				else
					O.robotize()
			var/max_keep = O.max_damage * CHARACTER_PERSIST_DAMAGE_RATIO
			var/brute = character_persist_num(entry["brute"])
			var/burn = character_persist_num(entry["burn"])
			var/total = brute + burn
			if (total > max_keep && total > 0)
				var/scale = max_keep / total
				brute *= scale
				burn *= scale
			if (brute > 0)
				O.createwound(INJURY_TYPE_BRUISE, brute)
			if (burn > 0)
				O.createwound(INJURY_TYPE_BURN, burn)
			if (entry["broken"])
				O.status |= ORGAN_BROKEN
				if (!O.broken_description)
					O.broken_description = "broken"
			if (entry["disfigured"])
				O.status |= ORGAN_DISFIGURED
			O.update_damages()

	var/list/internals = snapshot["internals"]
	if (islist(internals))
		for (var/tag in internals)
			var/list/entry = internals[tag]
			if (!islist(entry))
				continue
			var/obj/item/organ/internal/I = H.internal_organs_by_name[tag]
			if (istype(I, /obj/item/organ/internal/augment))
				continue
			if (entry["status"] == "missing")
				if (!I || I.vital)
					continue
				H.internal_organs_by_name[tag] = null
				H.internal_organs_by_name -= tag
				H.internal_organs -= I
				var/obj/item/organ/external/parent = H.organs_by_name[I.parent_organ]
				if (istype(parent))
					parent.internal_organs -= I
				qdel(I)
				continue
			if (!I)
				continue
			if (entry["status"] == "mechanical")
				I.robotize()
			else if (entry["status"] == "assisted")
				I.mechassist()
			var/cap = I.max_damage * CHARACTER_PERSIST_DAMAGE_RATIO
			I.damage = clamp(character_persist_num(entry["damage"]), 0, cap)

	H.force_update_limbs()
	H.update_body(0)
	H.update_hair(0)
	H.update_icons()


/proc/character_persist_try_save(mob/living/carbon/human/H, reason)
	if (!istype(H) || H.stat == DEAD)
		return FALSE
	if (character_persist_is_offstation_antag(H))
		return FALSE
	var/ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!ckey || !slot)
		return FALSE
	var/datum/preferences/prefs = character_persist_prefs_of(ckey)
	if (!prefs || !prefs.character_persist)
		return FALSE
	if (reason != "cryo" && !character_persist_can_save_here(H))
		return FALSE
	if (H.character_persist_saved)
		return TRUE

	var/list/previous = prefs.character_persist_snapshot
	var/list/snapshot = character_persist_capture(H)
	if (!islist(snapshot))
		return FALSE
	var/shifts = 1
	if (islist(previous))
		shifts = character_persist_num(previous["shifts_survived"]) + 1
	snapshot["shifts_survived"] = shifts
	var/physical_status = character_persist_crew_physical_status(H)
	if (physical_status)
		snapshot["physical_status"] = physical_status
	if (prefs.character_persist_med_autofill)
		var/note = character_persist_build_med_note(H, previous, reason)
		snapshot["med_record"] = character_persist_append_med_record(character_persist_current_med_record(H), note)
	else
		snapshot["med_record"] = character_persist_current_med_record(H)
	if (!character_persist_write(ckey, slot, snapshot))
		return FALSE
	prefs.character_persist_snapshot = snapshot
	H.character_persist_saved = TRUE
	character_persist_record_stat(ckey, slot, H.real_name, "saved", shifts, snapshot["med_record"], null)
	log_game("CHARACTER_PERSIST: saved [ckey] slot [slot] ([H.real_name]) reason=[reason] shifts=[shifts]")
	if (H.client)
		to_chat(H, SPAN_NOTICE("Состояние тела сохранено для следующей смены ([reason]). Пережито смен: [shifts]. На счёт будет начислено [shifts * CHARACTER_PERSIST_SHIFT_PAY] таллеров."))
	return TRUE


/proc/character_persist_clear_ckey(ckey, slot, reason)
	if (!ckey || !slot)
		return
	character_persist_delete(ckey, slot)
	var/datum/preferences/prefs = character_persist_prefs_of(ckey)
	if (prefs && prefs.default_slot == slot)
		prefs.character_persist_snapshot = null
	log_game("CHARACTER_PERSIST: cleared [ckey] slot [slot] reason=[reason]")


/proc/character_persist_try_clear(mob/living/carbon/human/H, reason)
	if (character_persist_is_offstation_antag(H))
		return
	var/ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	var/datum/preferences/prefs = character_persist_prefs_of(ckey)
	if (prefs?.character_persist && reason != "toggle_off")
		var/shifts = 0
		if (islist(prefs.character_persist_snapshot))
			shifts = character_persist_num(prefs.character_persist_snapshot["shifts_survived"])
		if (reason == "death" || reason == "gibbed")
			character_persist_record_stat(ckey, slot, H.real_name, "dead", shifts, null, character_persist_farewell(H.real_name, shifts, reason))
		else
			character_persist_record_stat(ckey, slot, H.real_name, "abandoned", shifts, null, null)
	character_persist_clear_ckey(ckey, slot, reason)
	if (H?.client)
		to_chat(H, SPAN_WARNING("Состояние тела сброшено ([reason])."))
