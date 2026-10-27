/// Personal persist safe: whitelist, reagent gate, serialize/deserialize, photo sidecar.

/proc/character_persist_safe_photos_path(ckey, slot, for_odyssey = FALSE)
	if (!ckey || !slot)
		return null
	var/map_key = GLOB.using_map?.preferences_key()
	if (!map_key)
		return null
	var/suffix = for_odyssey ? "_odyssey" : ""
	return "data/player_saves/[copytext_char(ckey, 1, 2)]/[ckey]/character_persist_[map_key]_[slot][suffix]_safe_photos.sav"


/proc/character_persist_safe_write_photo(savefile/photos, photo_id, icon/img)
	if (!photos || !photo_id || !isicon(img))
		return FALSE
	to_save(photos[photo_id], img)
	return TRUE


/proc/character_persist_safe_read_photo(savefile/photos, photo_id)
	if (!photos || !photo_id)
		return null
	if (!(photo_id in photos.dir))
		return null
	var/icon/img
	from_save(photos[photo_id], img)
	if (!isicon(img))
		return null
	return img


/proc/character_persist_safe_reagent_path_forbidden(path)
	if (!ispath(path, /datum/reagent))
		return TRUE
	if (ispath(path, /datum/reagent/toxin))
		return TRUE
	if (ispath(path, /datum/reagent/chloralhydrate))
		return TRUE
	if (ispath(path, /datum/reagent/mutagen) || ispath(path, /datum/reagent/radium))
		return TRUE
	if (ispath(path, /datum/reagent/hyperzine))
		return TRUE
	if (ispath(path, /datum/reagent/drugs))
		return TRUE
	return FALSE


/proc/character_persist_safe_reagents_ok(obj/item/reagent_containers/container)
	if (!istype(container))
		return TRUE
	if (!container.reagents || !container.reagents.total_volume)
		return TRUE
	for (var/datum/reagent/R in container.reagents.reagent_list)
		if (!istype(R) || character_persist_safe_reagent_path_forbidden(R.type))
			return FALSE
	return TRUE


/// Returns null if allowed, otherwise a short Russian reason string.
/proc/character_persist_safe_item_block_reason(obj/item/I)
	if (!istype(I))
		return "не предмет"
	if (I.anchored)
		return "закреплено"
	// Nested storage — packs of cigarettes count as storage; ban all storage.
	if (istype(I, /obj/item/storage))
		return "контейнеры нельзя класть в сейф"
	if (istype(I, /obj/item/implant) || istype(I, /obj/item/implanter))
		return "импланты запрещены"
	if (istype(I, /obj/item/card/id) || istype(I, /obj/item/modular_computer))
		return "ID и компьютеры запрещены"
	if (istype(I, /obj/item/disk) || istype(I, /obj/item/stock_parts/circuitboard))
		return "диски и платы запрещены"
	if (istype(I, /obj/item/gun) || istype(I, /obj/item/ammo_casing) || istype(I, /obj/item/ammo_magazine) || istype(I, /obj/item/material/knife) || istype(I, /obj/item/melee))
		return "оружие запрещено"
	if (istype(I, /obj/item/clothing) && !istype(I, /obj/item/clothing/mask/smokable))
		return "одежда и броня запрещены"
	if (istype(I, /obj/item/reagent_containers/syringe) || istype(I, /obj/item/reagent_containers/pill) || istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/storage/pill_bottle) || istype(I, /obj/item/storage/firstaid))
		return "медицина и химическая посуда запрещены"
	if (istype(I, /obj/item/crowbar) || istype(I, /obj/item/screwdriver) || istype(I, /obj/item/wrench) || istype(I, /obj/item/wirecutters) || istype(I, /obj/item/weldingtool) || istype(I, /obj/item/device/multitool))
		return "инструменты запрещены"

	var/allowed = FALSE
	if (istype(I, /obj/item/paper) || istype(I, /obj/item/pen))
		allowed = TRUE
	else if (istype(I, /obj/item/photo))
		allowed = TRUE
	else if (istype(I, /obj/item/clothing/mask/smokable/cigarette) || istype(I, /obj/item/flame))
		allowed = TRUE

	else if (istype(I, /obj/item/toy))
		allowed = TRUE
	else if (istype(I, /obj/item/lipstick) || istype(I, /obj/item/haircomb) || istype(I, /obj/item/soap))
		allowed = TRUE
	else if (istype(I, /obj/item/deck) || istype(I, /obj/item/pack))
		allowed = TRUE
	else if (istype(I, /obj/item/spacecash))
		allowed = TRUE
	else if (istype(I, /obj/item/reagent_containers/food/snacks) || istype(I, /obj/item/reagent_containers/food/drinks))
		if (!character_persist_safe_reagents_ok(I))
			return "опасные реагенты (яды/токсины)"
		allowed = TRUE
	else if (istype(I, /obj/item/reagent_containers/food/snacks/grown) || istype(I, /obj/item/towel))
		allowed = TRUE

	if (!allowed)
		return "предмет не из разрешённого списка"
	return null


/proc/character_persist_safe_can_store(obj/item/I)
	return !character_persist_safe_item_block_reason(I)


/proc/character_persist_safe_serialize_reagents(obj/item/reagent_containers/container)
	var/list/out = list()
	if (!istype(container) || !container.reagents)
		return out
	for (var/datum/reagent/R in container.reagents.reagent_list)
		if (!istype(R) || R.volume <= 0)
			continue
		out += list(list("type" = "[R.type]", "amount" = R.volume))
	return out


/proc/character_persist_safe_apply_reagents(obj/item/reagent_containers/container, list/entries)
	if (!istype(container) || !islist(entries) || !container.reagents)
		return
	container.reagents.clear_reagents()
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		var/path = text2path(entry["type"])
		var/amount = text2num(entry["amount"])
		if (!ispath(path, /datum/reagent) || amount <= 0)
			continue
		if (character_persist_safe_reagent_path_forbidden(path))
			continue
		container.reagents.add_reagent(path, amount)


/proc/character_persist_safe_serialize_item(obj/item/I, savefile/photos, list/photo_counter)
	if (!character_persist_safe_can_store(I))
		return null
	var/list/entry = list("type" = "[I.type]")
	if (I.name && I.name != initial(I.name))
		entry["name"] = I.name

	if (istype(I, /obj/item/paper))
		var/obj/item/paper/P = I
		entry["info"] = P.info || ""
		entry["title"] = P.name
		if (P.stamps)
			entry["stamps"] = P.stamps

	else if (istype(I, /obj/item/photo))
		var/obj/item/photo/Ph = I
		entry["scribble"] = Ph.scribble || ""
		entry["photo_size"] = Ph.photo_size || 3
		var/pid = "p[photo_counter[1]++]"
		entry["photo_id"] = pid
		if (isicon(Ph.img))
			character_persist_safe_write_photo(photos, pid, Ph.img)
		if (isicon(Ph.tiny))
			character_persist_safe_write_photo(photos, "[pid]_tiny", Ph.tiny)

	else if (istype(I, /obj/item/spacecash))
		var/obj/item/spacecash/cash = I
		entry["worth"] = cash.worth
		if (istype(cash, /obj/item/spacecash/ewallet))
			var/obj/item/spacecash/ewallet/E = cash
			entry["owner_name"] = E.owner_name || ""

	else if (istype(I, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/F = I
		entry["reagents"] = character_persist_safe_serialize_reagents(F)

	return entry


/proc/character_persist_safe_deserialize_item(list/entry, turf/T, savefile/photos)
	if (!islist(entry) || !T)
		return null
	var/path = text2path(entry["type"])
	if (!ispath(path, /obj/item))
		return null
	if (ispath(path, /obj/item/storage))
		return null
	if (ispath(path, /obj/item/gun) || ispath(path, /obj/item/card/id) || ispath(path, /obj/item/modular_computer))
		return null

	var/obj/item/I
	if (ispath(path, /obj/item/spacecash))
		var/worth = text2num(entry["worth"]) || 0
		if (ispath(path, /obj/item/spacecash/ewallet))
			var/obj/item/spacecash/ewallet/E = new path(T)
			E.worth = worth
			E.owner_name = entry["owner_name"] || ""
			I = E
		else
			var/obj/item/spacecash/bundle/bundle = new /obj/item/spacecash/bundle(T)
			bundle.worth = max(0, worth)
			bundle.update_icon()
			I = bundle
	else if (ispath(path, /obj/item/paper))
		var/obj/item/paper/P = new path(T)
		var/title = entry["title"] || entry["name"]
		P.set_content(entry["info"] || "", title, FALSE)
		if (entry["stamps"])
			P.stamps = entry["stamps"]
		I = P
	else if (ispath(path, /obj/item/photo))
		var/obj/item/photo/Ph = new path(T)
		Ph.scribble = entry["scribble"] || ""
		Ph.photo_size = text2num(entry["photo_size"]) || 3
		if (entry["name"])
			Ph.SetName(entry["name"])
		var/pid = entry["photo_id"]
		if (pid)
			Ph.img = character_persist_safe_read_photo(photos, pid)
			Ph.tiny = character_persist_safe_read_photo(photos, "[pid]_tiny")
		I = Ph
	else
		I = new path(T)
		if (entry["name"])
			I.SetName(entry["name"])
		if (istype(I, /obj/item/reagent_containers/food) && islist(entry["reagents"]))
			character_persist_safe_apply_reagents(I, entry["reagents"])
			if (!character_persist_safe_reagents_ok(I))
				qdel(I)
				return null

	if (!istype(I) || !character_persist_safe_can_store(I))
		if (istype(I))
			qdel(I)
		return null
	return I


/proc/character_persist_safe_collect_contents(obj/item/storage/secure/safe/character_persist/safe)
	if (!istype(safe))
		return list()
	var/list/entries = list()
	var/list/photo_counter = list(1)
	var/savefile/photos
	var/photo_path = character_persist_safe_photos_path(safe.owner_ckey, safe.owner_slot, safe.bound_odyssey)
	if (photo_path)
		if (fexists(photo_path))
			fdel(photo_path)
		photos = new /savefile(photo_path)
	for (var/obj/item/I in safe)
		if (length(entries) >= CHARACTER_PERSIST_SAFE_MAX_ITEMS)
			break
		var/list/entry = character_persist_safe_serialize_item(I, photos, photo_counter)
		if (islist(entry))
			entries += list(entry)
	if (!length(entries) && photo_path && fexists(photo_path))
		fdel(photo_path)
	return entries


/proc/character_persist_safe_access_ok(mob/living/carbon/human/H)
	if (!istype(H))
		return "нужен человек"
	var/ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!ckey || !slot)
		return "нет привязки персонажа"
	var/datum/preferences/prefs = character_persist_prefs_of(ckey)
	if (!prefs?.character_persist)
		return "включите персистентность персонажа"
	if (character_persist_use_odyssey_lane())
		return null
	var/shifts = 0
	if (islist(prefs.character_persist_snapshot))
		shifts = character_persist_num(prefs.character_persist_snapshot["shifts_survived"])
	if (shifts < CHARACTER_PERSIST_SAFE_MIN_SHIFTS)
		return "сейф откроется после [CHARACTER_PERSIST_SAFE_MIN_SHIFTS] пережитых смен (сейчас [shifts]; доступ с 3-й смены)"
	return null
