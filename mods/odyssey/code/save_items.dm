/// Odyssey generic item persist: items_<bucket>.json (strip + restore).


/proc/odyssey_item_snapshot_kind(bucket)
	return "items_[bucket]"


/proc/odyssey_next_item_persist_id()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	return "item-[state.campaign_id]-[state.next_object_id++]"


/proc/odyssey_serialize_item(obj/item/I, storage_id = null, carried = FALSE)
	if (carried)
		if (!istype(I) || QDELETED(I))
			return null
		// Organs ride the corpse into the morgue locker. Loose organs stay on remains.json.
		if (odyssey_item_denylisted(I) && !istype(I, /obj/item/organ))
			return null
	else if (!odyssey_item_persistable(I))
		return null
	var/turf/T = get_turf(I)
	if (!T && !carried)
		return null
	var/id = I.odyssey_persist_id
	if (!id)
		id = odyssey_next_item_persist_id()
		I.odyssey_persist_id = id
	var/list/entry = list(
		"id" = id,
		"type" = "[I.type]",
		"x" = T ? T.x : 0,
		"y" = T ? T.y : 0,
		"z" = T ? T.z : 0,
		"dir" = I.dir,
		"in_closet" = FALSE
	)
	var/obj/structure/closet/host = I.loc
	if (istype(host))
		entry["in_closet"] = TRUE
		if (!host.odyssey_persist_id)
			odyssey_assign_runtime_id(host)
		entry["closet_id"] = host.odyssey_persist_id
	odyssey_write_pixel_offset(I, entry)
	if (storage_id)
		entry["storage_id"] = storage_id
	if (I.name != initial(I.name))
		entry["name"] = I.name
	if (istype(I, /obj/item/stack))
		var/obj/item/stack/S = I
		var/amount = S.get_amount()
		if (!isnum(amount) || amount < 1)
			return null
		entry["amount"] = amount
	if (istype(I, /obj/item/reagent_containers))
		// Always write (even empty) so emptied beakers/bottles do not refill from type New().
		entry["reagents"] = odyssey_serialize_reagents(I)
	if (istype(I, /obj/item/clothing))
		// Always write (even empty) so type-default plates/ties do not respawn on continue.
		entry["accessories"] = odyssey_serialize_clothing_accessories(I)
	if (istype(I, /obj/item/passport))
		var/obj/item/passport/P = I
		entry["passport_info"] = P.info || ""
		entry["passport_fingerprint"] = P.fingerprint || ""
	odyssey_write_item_extras(I, entry)
	return entry


/// World chemistry: keep toxins/drugs (unlike personal-safe gate).
/proc/odyssey_serialize_reagents(obj/item/reagent_containers/container)
	return character_persist_safe_serialize_reagents(container)


/proc/odyssey_apply_reagents(obj/item/reagent_containers/container, list/entries)
	if (!istype(container) || !container.reagents)
		return
	container.reagents.clear_reagents()
	if (!islist(entries))
		return
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		var/path = character_persist_safe_resolve_path(entry["type"])
		var/amount = entry["amount"]
		if (!isnum(amount))
			amount = text2num(amount)
		if (!ispath(path, /datum/reagent) || !isnum(amount) || amount <= 0)
			continue
		container.reagents.add_reagent(path, amount)


/proc/odyssey_serialize_clothing_accessories(obj/item/clothing/C)
	var/list/acc = list()
	if (!istype(C) || !islist(C.accessories))
		return acc
	for (var/obj/item/clothing/accessory/A in C.accessories)
		if (!istype(A) || odyssey_item_path_denylisted(A.type))
			continue
		acc += "[A.type]"
	return acc


/proc/odyssey_clear_clothing_accessories(obj/item/clothing/C)
	if (!istype(C) || !length(C.accessories))
		return
	for (var/obj/item/clothing/accessory/A in C.accessories.Copy())
		C.remove_accessory(null, A)
		qdel(A)


/// Wipe type New() defaults, then attach saved accessory types (null-user attach_accessory).
/proc/odyssey_apply_clothing_accessories(obj/item/clothing/C, list/acc_types)
	if (!istype(C) || !islist(acc_types))
		return
	odyssey_clear_clothing_accessories(C)
	for (var/acc_text in acc_types)
		var/acc_path = character_persist_safe_resolve_path(acc_text)
		if (!ispath(acc_path, /obj/item/clothing/accessory) || odyssey_item_path_denylisted(acc_path))
			continue
		var/obj/item/clothing/accessory/A = new acc_path(C)
		if (QDELETED(A) || !istype(A) || !C.can_attach_accessory(A))
			qdel(A)
			continue
		C.attach_accessory(null, A)
		// Webbing/holster New() autofill would block nested restore (gun into holster).
		if (istype(A, /obj/item/clothing/accessory/storage))
			var/obj/item/clothing/accessory/storage/SA = A
			if (istype(SA.container))
				odyssey_clear_storage_autofill(SA.container)


/proc/odyssey_collect_nested_item_contents(obj/item/I, list/buckets, parent_id)
	if (!istype(I) || !parent_id || !islist(buckets))
		return
	if (istype(I, /obj/item/storage))
		for (var/obj/item/child in I)
			odyssey_collect_item_into_buckets(child, buckets, parent_id)
	if (istype(I, /obj/item/clothing/suit/storage))
		var/obj/item/clothing/suit/storage/S = I
		if (istype(S.pockets))
			for (var/obj/item/child in S.pockets)
				odyssey_collect_item_into_buckets(child, buckets, parent_id, "pockets")
	if (istype(I, /obj/item/clothing))
		var/obj/item/clothing/C = I
		if (islist(C.accessories))
			for (var/obj/item/clothing/accessory/storage/A in C.accessories)
				if (!istype(A.container))
					continue
				var/acc_key = "[A.type]"
				for (var/obj/item/child in A.container)
					odyssey_collect_item_into_buckets(child, buckets, parent_id, "accessory", acc_key)


/proc/odyssey_collect_item_into_buckets(obj/item/I, list/buckets, storage_id = null, storage_kind = null, storage_acc = null)
	if (!odyssey_item_persistable(I))
		return
	var/bucket = odyssey_item_persist_bucket(I.type)
	if (!bucket)
		return
	var/list/entry = odyssey_serialize_item(I, storage_id)
	if (!islist(entry))
		return
	if (storage_kind)
		entry["storage_kind"] = storage_kind
	if (storage_acc)
		entry["storage_acc"] = storage_acc
	if (!islist(buckets[bucket]))
		buckets[bucket] = list()
	buckets[bucket] += list(entry)
	odyssey_collect_nested_item_contents(I, buckets, entry["id"])


/// Put restored nested item into storage, holster/pouch, or suit pockets (not loose on the clothing atom).
/proc/odyssey_place_item_in_parent(obj/item/I, obj/item/parent, storage_kind = null, storage_acc = null)
	if (!istype(I) || !istype(parent))
		return FALSE
	if (istype(parent, /obj/item/storage))
		I.forceMove(parent)
		return I.loc == parent
	if (istype(parent, /obj/item/clothing))
		var/obj/item/clothing/C = parent
		if (storage_kind == "pockets" && istype(C, /obj/item/clothing/suit/storage))
			var/obj/item/clothing/suit/storage/pocket_suit = C
			if (istype(pocket_suit.pockets))
				I.forceMove(pocket_suit.pockets)
				return I.loc == pocket_suit.pockets
		if (storage_kind == "accessory" || !storage_kind)
			if (islist(C.accessories))
				for (var/obj/item/clothing/accessory/storage/A in C.accessories)
					if (!istype(A.container))
						continue
					if (storage_acc && "[A.type]" != storage_acc)
						continue
					var/datum/extension/holster/H = get_extension(A, /datum/extension/holster)
					if (istype(H))
						if (H.holstered || !H.can_holster(I))
							continue
						I.forceMove(A.container)
						if (I.loc != A.container)
							continue
						H.holstered = I
						A.SetName("occupied [H.empty_name]")
						GLOB.moved_event.register(I, H, TYPE_PROC_REF(/datum/extension/holster, check_holster))
						GLOB.destroyed_event.register(I, H, TYPE_PROC_REF(/datum/extension/holster, clear_holster))
						A.update_icon()
						return TRUE
					if (!A.container.can_be_inserted(I, null, TRUE))
						continue
					I.forceMove(A.container)
					if (I.loc == A.container)
						return TRUE
		if (storage_kind != "accessory" && istype(C, /obj/item/clothing/suit/storage))
			var/obj/item/clothing/suit/storage/S = C
			if (istype(S.pockets))
				I.forceMove(S.pockets)
				return I.loc == S.pockets
	I.forceMove(parent)
	return I.loc == parent


/proc/odyssey_spawn_saved_item(list/entry, atom/dest)
	if (!islist(entry) || !dest)
		return null
	var/path = character_persist_safe_resolve_path(entry["type"])
	if (!ispath(path, /obj/item))
		return null
	if (odyssey_item_path_denylisted(path) && !ispath(path, /obj/item/organ))
		return null
	var/obj/item/I
	if (ispath(path, /obj/item/stack))
		var/amount = entry["amount"]
		if (!isnum(amount))
			amount = text2num(amount)
		if (!isnum(amount) || amount < 1)
			amount = 1
		I = new path(dest, amount)
	else
		I = new path(dest)
	if (QDELETED(I) || !istype(I))
		return null
	odyssey_clear_item_autofill(I)
	if (!isnull(entry["dir"]))
		I.set_dir(entry["dir"])
	if (istype(I, /obj/item/clothing) && ("accessories" in entry))
		odyssey_apply_clothing_accessories(I, entry["accessories"])
	if (istype(I, /obj/item/passport))
		var/obj/item/passport/P = I
		if (!isnull(entry["passport_info"]))
			P.info = entry["passport_info"]
		if (!isnull(entry["passport_fingerprint"]))
			P.fingerprint = entry["passport_fingerprint"]
	if (istype(I, /obj/item/reagent_containers) && ("reagents" in entry))
		odyssey_apply_reagents(I, entry["reagents"])
	odyssey_read_item_extras(I, entry)
	I.forceMove(dest)
	return I


/proc/odyssey_apply_gear_list(list/entries, atom/dest)
	if (!islist(entries) || !dest)
		return 0
	var/list/created = list()
	var/list/deferred = list()
	var/list/roots = list()
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		if (entry["storage_id"])
			deferred += list(entry)
		else
			roots += list(entry)
	var/applied = 0
	for (var/list/entry in roots)
		var/obj/item/I = odyssey_spawn_saved_item(entry, dest)
		if (!istype(I))
			continue
		if (entry["id"])
			created[entry["id"]] = I
		applied++
	var/list/pending = deferred.Copy()
	var/guard = 0
	while (length(pending) && guard < 16)
		guard++
		var/list/next = list()
		var/progress = 0
		for (var/list/entry in pending)
			if (!islist(entry))
				continue
			var/obj/item/parent = created[entry["storage_id"]]
			if (entry["storage_id"] && !istype(parent))
				next += list(entry)
				continue
			var/atom/spawn_at = parent || dest
			var/obj/item/I = odyssey_spawn_saved_item(entry, spawn_at)
			if (!istype(I))
				continue
			if (entry["id"])
				created[entry["id"]] = I
			if (istype(parent))
				odyssey_place_item_in_parent(I, parent, entry["storage_kind"], entry["storage_acc"])
			applied++
			progress++
		if (!progress)
			break
		pending = next
	return applied


/proc/odyssey_collect_items_by_bucket()
	var/list/buckets = list()
	for (var/bucket in ODYSSEY_ITEM_BUCKETS)
		buckets[bucket] = list()
	for (var/turf/T in odyssey_get_persistable_turfs())
		odyssey_collect_item_turf(T, buckets)
		CHECK_TICK
	return buckets


/proc/odyssey_collect_item_turf(turf/T, list/buckets)
	if (!istype(T) || !islist(buckets))
		return
	for (var/obj/item/I in T)
		odyssey_collect_item_into_buckets(I, buckets, null)
	for (var/obj/structure/closet/C in T)
		for (var/obj/item/I in C)
			odyssey_collect_item_into_buckets(I, buckets, null)


/// Lane marker — always written on save so empty-ship continue still strips DMM loot.
/proc/odyssey_items_manifest_kind()
	return "items"


/// TRUE if this generation ran the items lane (manifest and/or any bucket file).
/proc/odyssey_items_snapshot_present(generation)
	if (fexists(odyssey_snapshot_path(odyssey_items_manifest_kind(), generation)))
		return TRUE
	for (var/bucket in ODYSSEY_ITEM_BUCKETS)
		if (fexists(odyssey_snapshot_path(odyssey_item_snapshot_kind(bucket), generation)))
			return TRUE
	return FALSE


/proc/odyssey_strip_persistable_items()
	var/removed = 0
	for (var/turf/T in odyssey_get_persistable_turfs())
		for (var/obj/item/I in T)
			if (QDELETED(I) || !odyssey_item_persistable(I))
				continue
			qdel(I)
			removed++
		for (var/obj/structure/closet/C in T)
			for (var/obj/item/I in C)
				if (QDELETED(I) || !odyssey_item_persistable(I))
					continue
				qdel(I)
				removed++
		CHECK_TICK
	log_debug("ODYSSEY: stripped [removed] persistable items")
	return removed


/proc/odyssey_resolve_item_closet(list/entry, turf/T)
	if (!islist(entry) || !entry["in_closet"])
		return null
	var/closet_id = entry["closet_id"]
	if (closet_id)
		var/obj/structure/S = odyssey_find_structure_by_id(closet_id)
		if (istype(S, /obj/structure/closet))
			return S
	if (!istype(T))
		return null
	var/obj/structure/closet/found
	for (var/obj/structure/closet/C in T)
		if (C.loc != T)
			continue
		if (found)
			return found
		found = C
	return found


/proc/odyssey_insert_item_into_closet(obj/item/I, obj/structure/closet/C)
	if (!istype(I) || !istype(C))
		return FALSE
	if (I.loc != C)
		I.forceMove(C)
	// Floor spawns randomize pixel offset. Inside a closet that draws the item on top of it.
	I.pixel_x = 0
	I.pixel_y = 0
	I.pixel_z = 0
	return I.loc == C


/proc/odyssey_clear_storage_autofill(obj/item/storage/S)
	if (!istype(S))
		return
	// startswith / WillContain fillers land during New/Initialize. Wipe all of them —
	// filtering by persistable() left autofill in place (dupes) for pouches/MREs/firstaid.
	var/list/spawned = list()
	for (var/obj/item/child in S)
		spawned += child
	for (var/obj/item/child in spawned)
		qdel(child)


/proc/odyssey_clear_item_autofill(obj/item/I)
	if (!istype(I))
		return
	if (istype(I, /obj/item/storage))
		odyssey_clear_storage_autofill(I)
	if (istype(I, /obj/item/clothing/suit/storage))
		var/obj/item/clothing/suit/storage/S = I
		if (istype(S.pockets))
			odyssey_clear_storage_autofill(S.pockets)
	if (istype(I, /obj/item/clothing))
		var/obj/item/clothing/C = I
		if (islist(C.accessories))
			for (var/obj/item/clothing/accessory/storage/A in C.accessories)
				if (istype(A.container))
					odyssey_clear_storage_autofill(A.container)


/// TRUE when nested entry's parent is already in created_by_id (or entry is a root).
/proc/odyssey_item_entry_parent_ready(list/entry, list/created_by_id)
	if (!islist(entry) || !islist(created_by_id))
		return FALSE
	var/storage_id = entry["storage_id"]
	if (!storage_id)
		return TRUE
	return istype(created_by_id[storage_id], /obj/item)


/proc/odyssey_apply_item_entry(list/entry, list/created_by_id)
	if (!islist(entry) || !islist(created_by_id))
		return FALSE
	var/path = character_persist_safe_resolve_path(entry["type"])
	if (odyssey_item_path_denylisted(path))
		return FALSE
	var/turf/T = odyssey_locate_turf(entry)
	if (!T)
		return FALSE
	var/obj/item/parent
	var/storage_id = entry["storage_id"]
	if (storage_id)
		parent = created_by_id[storage_id]
		if (!istype(parent))
			return FALSE
	var/obj/structure/closet/host = odyssey_resolve_item_closet(entry, T)
	var/atom/spawn_at = parent || host || T
	var/obj/item/I
	if (ispath(path, /obj/item/stack))
		var/amount = entry["amount"]
		if (!isnum(amount))
			amount = text2num(amount)
		if (!isnum(amount) || amount < 1)
			amount = 1
		I = new path(spawn_at, amount)
	else
		I = new path(spawn_at)
	if (QDELETED(I) || !istype(I))
		return FALSE
	odyssey_clear_item_autofill(I)
	if (!isnull(entry["dir"]))
		I.set_dir(entry["dir"])
	if (istype(I, /obj/item/clothing) && ("accessories" in entry))
		odyssey_apply_clothing_accessories(I, entry["accessories"])
	if (istype(I, /obj/item/passport))
		var/obj/item/passport/P = I
		if (!isnull(entry["passport_info"]))
			P.info = entry["passport_info"]
		if (!isnull(entry["passport_fingerprint"]))
			P.fingerprint = entry["passport_fingerprint"]
	if (istype(parent))
		odyssey_place_item_in_parent(I, parent, entry["storage_kind"], entry["storage_acc"])
	else if (host)
		odyssey_insert_item_into_closet(I, host)
	else
		odyssey_apply_pixel_offset(I, entry)
	if (entry["name"])
		I.SetName(entry["name"])
	if (istype(I, /obj/item/reagent_containers) && ("reagents" in entry))
		odyssey_apply_reagents(I, entry["reagents"])
	odyssey_read_item_extras(I, entry)
	if (entry["id"])
		I.odyssey_persist_id = entry["id"]
		created_by_id[entry["id"]] = I
	return TRUE

/// Apply one bucket file. Roots go into created_by_id; nested (storage_id) go to deferred.
/proc/odyssey_apply_item_bucket_roots(list/entries, list/created_by_id, list/deferred)
	if (!islist(entries) || !islist(created_by_id) || !islist(deferred))
		return 0
	var/applied = 0
	for (var/list/entry in entries)
		if (entry["storage_id"])
			deferred += list(entry)
			continue
		if (odyssey_apply_item_entry(entry, created_by_id))
			applied++
		CHECK_TICK
	return applied


/proc/odyssey_apply_item_entries(list/entries, list/created_by_id = null)
	if (!islist(entries) || !length(entries))
		return 0
	if (!islist(created_by_id))
		created_by_id = list()
	var/list/deferred = list()
	var/applied = odyssey_apply_item_bucket_roots(entries, created_by_id, deferred)
	applied += odyssey_apply_deferred_items(deferred, created_by_id)
	log_debug("ODYSSEY: apply_items applied=[applied]/[length(entries)]")
	return applied


/// Nested items may reference parents from later buckets (food inside mrebag inside MRE).
/// Multi-pass until parents exist; never spawn orphans into closets/turfs.
/proc/odyssey_apply_deferred_items(list/deferred, list/created_by_id)
	if (!islist(deferred) || !length(deferred) || !islist(created_by_id))
		return 0
	var/list/pending = deferred.Copy()
	var/applied = 0
	var/guard = 0
	while (length(pending) && guard < 16)
		guard++
		var/list/next = list()
		var/progress = 0
		for (var/list/entry in pending)
			if (!odyssey_item_entry_parent_ready(entry, created_by_id))
				next += list(entry)
				continue
			if (odyssey_apply_item_entry(entry, created_by_id))
				applied++
				progress++
			CHECK_TICK
		if (!progress)
			break
		pending = next
	if (length(pending))
		log_debug("ODYSSEY: deferred items orphaned=[length(pending)] (missing storage parent)")
	return applied


/// Always written on save. Presence alone means «items lane ran» (even with 0 items).
/proc/odyssey_write_items_manifest(list/buckets, list/common)
	if (!islist(common))
		return FALSE
	var/list/written = list()
	var/total = 0
	if (islist(buckets))
		for (var/bucket in ODYSSEY_ITEM_BUCKETS)
			var/list/entries = buckets[bucket]
			if (!islist(entries) || !length(entries))
				continue
			written += bucket
			total += length(entries)
	return odyssey_write_json(
		odyssey_snapshot_path(odyssey_items_manifest_kind(), common["generation"]),
		common + list("item_count" = total, "buckets" = written)
	)


/proc/odyssey_write_item_buckets(list/buckets, list/common)
	if (!islist(buckets) || !islist(common))
		return FALSE
	var/ok = TRUE
	for (var/bucket in ODYSSEY_ITEM_BUCKETS)
		var/list/entries = buckets[bucket]
		if (!islist(entries) || !length(entries))
			continue
		var/kind = odyssey_item_snapshot_kind(bucket)
		ok = odyssey_write_json(odyssey_snapshot_path(kind, common["generation"]), common + list("bucket" = bucket, "entries" = entries)) && ok
	ok = odyssey_write_items_manifest(buckets, common) && ok
	return ok


/proc/odyssey_read_item_bucket(bucket, generation)
	return odyssey_read_json(odyssey_snapshot_path(odyssey_item_snapshot_kind(bucket), generation))


/// Count of non-empty item bucket files that match generation (for validate / logging).
/proc/odyssey_count_item_bucket_entries(list/buckets)
	if (!islist(buckets))
		return 0
	var/total = 0
	for (var/bucket in ODYSSEY_ITEM_BUCKETS)
		total += length(buckets[bucket])
	return total
