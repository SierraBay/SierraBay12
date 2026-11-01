/// Odyssey generic item persist: items_<bucket>.json (strip + restore).


/proc/odyssey_item_snapshot_kind(bucket)
	return "items_[bucket]"


/proc/odyssey_next_item_persist_id()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	return "item-[state.campaign_id]-[state.next_object_id++]"


/proc/odyssey_serialize_item(obj/item/I, storage_id = null)
	if (!odyssey_item_persistable(I))
		return null
	var/turf/T = get_turf(I)
	if (!T)
		return null
	var/id = I.odyssey_persist_id
	if (!id)
		id = odyssey_next_item_persist_id()
		I.odyssey_persist_id = id
	var/list/entry = list(
		"id" = id,
		"type" = "[I.type]",
		"x" = T.x,
		"y" = T.y,
		"z" = T.z,
		"dir" = I.dir,
		"in_closet" = !!istype(I.loc, /obj/structure/closet)
	)
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
	return entry


/proc/odyssey_collect_item_into_buckets(obj/item/I, list/buckets, storage_id = null)
	if (!odyssey_item_persistable(I))
		return
	var/bucket = odyssey_item_persist_bucket(I.type)
	if (!bucket)
		return
	var/list/entry = odyssey_serialize_item(I, storage_id)
	if (!islist(entry))
		return
	if (!islist(buckets[bucket]))
		buckets[bucket] = list()
	buckets[bucket] += list(entry)
	if (istype(I, /obj/item/storage))
		var/obj/item/storage/ST = I
		var/pid = entry["id"]
		for (var/obj/item/child in ST)
			odyssey_collect_item_into_buckets(child, buckets, pid)


/proc/odyssey_collect_items_by_bucket()
	var/list/buckets = list()
	for (var/bucket in ODYSSEY_ITEM_BUCKETS)
		buckets[bucket] = list()
	for (var/turf/T in odyssey_get_persistable_turfs())
		for (var/obj/item/I in T)
			odyssey_collect_item_into_buckets(I, buckets, null)
		for (var/obj/structure/closet/C in T)
			for (var/obj/item/I in C)
				odyssey_collect_item_into_buckets(I, buckets, null)
		CHECK_TICK
	return buckets


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


/proc/odyssey_apply_item_entry(list/entry, list/created_by_id)
	if (!islist(entry) || !islist(created_by_id))
		return FALSE
	var/path = character_persist_safe_resolve_path(entry["type"])
	if (odyssey_item_path_denylisted(path))
		return FALSE
	var/turf/T = odyssey_locate_turf(entry)
	if (!T)
		return FALSE
	var/obj/item/I
	if (ispath(path, /obj/item/stack))
		var/amount = entry["amount"]
		if (!isnum(amount))
			amount = text2num(amount)
		if (!isnum(amount) || amount < 1)
			amount = 1
		I = new path(T, amount)
	else
		I = new path(T)
	if (QDELETED(I) || !istype(I))
		return FALSE
	if (!isnull(entry["dir"]))
		I.set_dir(entry["dir"])
	odyssey_apply_pixel_offset(I, entry)
	if (entry["name"])
		I.SetName(entry["name"])
	if (entry["id"])
		I.odyssey_persist_id = entry["id"]
		created_by_id[entry["id"]] = I
	if (entry["storage_id"])
		var/obj/item/storage/parent = created_by_id[entry["storage_id"]]
		if (istype(parent))
			I.forceMove(parent)
		else if (entry["in_closet"])
			var/obj/structure/closet/C = locate() in T
			if (istype(C))
				I.forceMove(C)
	else if (entry["in_closet"])
		var/obj/structure/closet/C = locate() in T
		if (istype(C))
			I.forceMove(C)
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
	for (var/list/entry in deferred)
		if (odyssey_apply_item_entry(entry, created_by_id))
			applied++
		CHECK_TICK
	log_debug("ODYSSEY: apply_items applied=[applied]/[length(entries)]")
	return applied


/proc/odyssey_apply_deferred_items(list/deferred, list/created_by_id)
	if (!islist(deferred) || !length(deferred) || !islist(created_by_id))
		return 0
	var/applied = 0
	for (var/list/entry in deferred)
		if (odyssey_apply_item_entry(entry, created_by_id))
			applied++
		CHECK_TICK
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
