/// Wall-mounted personal stowage for character_persist. Place on map manually.

/obj/item/storage/secure/safe/character_persist
	name = "personal stowage safe"
	desc = "A biometric wall safe linked to a crew member's continuity profile. Unlocks after two survived shifts, or during an Odyssey expedition."
	startswith = null
	max_w_class = ITEM_SIZE_NORMAL
	storage_slots = CHARACTER_PERSIST_SAFE_MAX_ITEMS
	max_storage_space = null
	contents_banned = list(/obj/item/storage)
	var/owner_ckey
	var/owner_slot
	var/owner_name
	var/bound_odyssey = FALSE
	var/contents_loaded = FALSE


/obj/item/storage/secure/safe/character_persist/Initialize()
	. = ..()
	locked = TRUE
	l_set = 1
	l_code = "*****"


/obj/item/storage/secure/safe/character_persist/examine(mob/user, distance)
	. = ..()
	if (distance > 2)
		return
	if (owner_ckey)
		to_chat(user, SPAN_NOTICE("Registered to: [owner_name || owner_ckey]."))
	else
		to_chat(user, SPAN_NOTICE("Unclaimed. A qualifying crew member can bind it on first open."))


/obj/item/storage/secure/safe/character_persist/can_be_inserted(obj/item/W, mob/user, stop_messages = 0)
	var/reason = character_persist_safe_item_block_reason(W)
	if (reason)
		if (!stop_messages && user)
			to_chat(user, SPAN_WARNING("\The [src] rejects \the [W]: [reason]."))
		return 0
	if (length(contents) >= CHARACTER_PERSIST_SAFE_MAX_ITEMS)
		if (!stop_messages && user)
			to_chat(user, SPAN_NOTICE("\The [src] is full."))
		return 0
	// Pocket loot must not ride into the safe; drop it at the user/turf first.
	if (istype(W, /obj/item/clothing))
		character_persist_safe_empty_clothing_storage(W, user || get_turf(src))
	return ..()


/obj/item/storage/secure/safe/character_persist/use_tool(obj/item/W, mob/living/user, list/click_params)
	if (!locked)
		return ..()
	to_chat(user, SPAN_WARNING("\The [src] is locked. Biometric access only."))
	return TRUE


/obj/item/storage/secure/safe/character_persist/attack_hand(mob/user)
	return attack_self(user)


/obj/item/storage/secure/safe/character_persist/attack_self(mob/user)
	try_open_persist_safe(user)


/obj/item/storage/secure/safe/character_persist/MouseDrop(over_object, src_location, over_location)
	if (locked)
		add_fingerprint(usr)
		to_chat(usr, SPAN_WARNING("\The [src] is locked."))
		return
	return ..()


/obj/item/storage/secure/safe/character_persist/AltClick(mob/user)
	if (locked)
		return FALSE
	return ..()


/obj/item/storage/secure/safe/character_persist/proc/is_bound_owner(mob/living/carbon/human/H)
	if (!istype(H) || !owner_ckey || !owner_slot)
		return FALSE
	return character_persist_ckey_of(H) == owner_ckey && character_persist_slot_of(H) == owner_slot


/// Another physical safe already claimed by this ckey+slot (excluding `except`).
/proc/character_persist_safe_find_bound(ckey, slot, obj/item/storage/secure/safe/character_persist/except = null)
	if (!ckey || !slot)
		return null
	for (var/obj/item/storage/secure/safe/character_persist/S)
		if (S == except || !S.owner_ckey)
			continue
		if (S.owner_ckey == ckey && S.owner_slot == slot)
			return S
	return null


/obj/item/storage/secure/safe/character_persist/proc/try_open_persist_safe(mob/user)
	if (!istype(user, /mob/living/carbon/human))
		to_chat(user, SPAN_WARNING("Биометрия не считывается."))
		return
	var/mob/living/carbon/human/H = user
	add_fingerprint(H)

	var/deny = character_persist_safe_access_ok(H)
	if (deny)
		to_chat(H, SPAN_WARNING("[deny]."))
		return

	var/ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (owner_ckey && (owner_ckey != ckey || owner_slot != slot))
		to_chat(H, SPAN_WARNING("Сейф зарегистрирован на другого члена экипажа."))
		return

	if (!owner_ckey)
		if (character_persist_safe_find_bound(ckey, slot, src))
			to_chat(H, SPAN_WARNING("У вас уже есть привязанный личный сейф. Второй зарегистрировать нельзя."))
			return
		owner_ckey = ckey
		owner_slot = slot
		owner_name = H.real_name || ckey
		bound_odyssey = character_persist_use_odyssey_lane()
		to_chat(H, SPAN_NOTICE("Биометрия принята. Сейф привязан к вашему профилю."))

	locked = FALSE
	ensure_contents_loaded()
	open(H)


/obj/item/storage/secure/safe/character_persist/proc/ensure_contents_loaded()
	if (contents_loaded || !owner_ckey || !owner_slot)
		return
	contents_loaded = TRUE
	var/list/snapshot = character_persist_read(owner_ckey, owner_slot, bound_odyssey)
	if (!islist(snapshot))
		return
	var/list/entries = snapshot["personal_safe"]
	if (!islist(entries) || !length(entries))
		return
	var/savefile/photos
	var/photo_path = character_persist_safe_photos_path(owner_ckey, owner_slot, bound_odyssey)
	if (photo_path && fexists(photo_path))
		photos = new /savefile(photo_path)
	var/turf/T = get_turf(src)
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		if (length(contents) >= CHARACTER_PERSIST_SAFE_MAX_ITEMS)
			break
		var/obj/item/I = character_persist_safe_deserialize_item(entry, T, photos)
		if (!istype(I))
			continue
		if (!can_be_inserted(I, null, TRUE))
			qdel(I)
			continue
		handle_item_insertion(I, TRUE, TRUE)


/obj/item/storage/secure/safe/character_persist/close(mob/user)
	. = ..()
	locked = TRUE
	ClearOverlays()
	flush_to_snapshot()


/obj/item/storage/secure/safe/character_persist/proc/flush_to_snapshot()
	if (!owner_ckey || !owner_slot || !contents_loaded)
		return
	// Never create a body-less snapshot — wait until try_save has written one.
	var/list/snapshot = character_persist_read(owner_ckey, owner_slot, bound_odyssey)
	if (!islist(snapshot))
		return
	snapshot["personal_safe"] = character_persist_safe_collect_contents(src)
	character_persist_write(owner_ckey, owner_slot, snapshot, bound_odyssey)
	var/datum/preferences/P = character_persist_prefs_of(owner_ckey)
	if (P && P.default_slot == owner_slot)
		P.character_persist_snapshot = snapshot


// Crack/emag disabled for now — re-enable later (biometric owner-only).
/obj/item/storage/secure/safe/character_persist/emag_act(remaining_charges, mob/user, feedback)
	to_chat(user, SPAN_WARNING("The biometric lock of \the [src] resists tampering."))
	return


/obj/item/storage/secure/safe/character_persist/proc/wipe_binding()
	owner_ckey = null
	owner_slot = null
	owner_name = null
	bound_odyssey = FALSE
	contents_loaded = FALSE
	emagged = FALSE
	locked = TRUE
	ClearOverlays()
	for (var/obj/item/I in src)
		qdel(I)


/obj/item/storage/secure/safe/character_persist/Destroy()
	if (contents_loaded && owner_ckey)
		flush_to_snapshot()
	return ..()


/proc/character_persist_safe_flush_owner(ckey, slot, for_odyssey)
	if (!ckey || !slot)
		return
	for (var/obj/item/storage/secure/safe/character_persist/S)
		if (S.owner_ckey != ckey || S.owner_slot != slot)
			continue
		if (!!S.bound_odyssey != !!for_odyssey)
			continue
		if (S.contents_loaded)
			S.flush_to_snapshot()


/// Live contents for try_save when the body snapshot is being written for the first time this lane.
/proc/character_persist_safe_live_contents(ckey, slot, for_odyssey)
	if (!ckey || !slot)
		return null
	for (var/obj/item/storage/secure/safe/character_persist/S)
		if (S.owner_ckey != ckey || S.owner_slot != slot)
			continue
		if (!!S.bound_odyssey != !!for_odyssey)
			continue
		if (!S.contents_loaded)
			continue
		return character_persist_safe_collect_contents(S)
	return null


/proc/character_persist_safe_wipe_owner(ckey, slot, for_odyssey)
	if (!ckey || !slot)
		return
	var/photo_path = character_persist_safe_photos_path(ckey, slot, for_odyssey)
	if (photo_path && fexists(photo_path))
		fdel(photo_path)
	for (var/obj/item/storage/secure/safe/character_persist/S)
		if (S.owner_ckey != ckey || S.owner_slot != slot)
			continue
		if (!!S.bound_odyssey != !!for_odyssey)
			continue
		S.wipe_binding()
