/// Odyssey paperwork persistence: only items inside /obj/structure/filingcabinet on persistable zones.
/// Photos go to a BYOND savefile next to papers.json (icons cannot travel through JSON).


/proc/odyssey_papers_photos_path(generation)
	if (generation)
		return "[ODYSSEY_DATA_DIR]_[odyssey_map_key()]_[generation]_papers_photos.sav"
	return "[ODYSSEY_DATA_DIR]_[odyssey_map_key()]_papers_photos.sav"


/proc/odyssey_paperwork_type_allowed(path)
	if (!ispath(path))
		return FALSE
	if (ispath(path, /obj/item/paper/admin))
		return FALSE
	return ispath(path, /obj/item/paper) \
		|| ispath(path, /obj/item/photo) \
		|| ispath(path, /obj/item/folder) \
		|| ispath(path, /obj/item/paper_bundle)


/proc/odyssey_is_paperwork_item(atom/A)
	if (!istype(A))
		return FALSE
	return odyssey_paperwork_type_allowed(A.type)


/proc/odyssey_papers_budget_ok(list/budget, add_items = 0, add_photos = 0, add_info = 0)
	if (!islist(budget))
		return FALSE
	if (budget["items"] + add_items > ODYSSEY_PAPERS_MAX_ITEMS)
		return FALSE
	if (budget["photos"] + add_photos > ODYSSEY_PAPERS_MAX_PHOTOS)
		return FALSE
	if (budget["info_bytes"] + add_info > ODYSSEY_PAPERS_MAX_INFO_BYTES)
		return FALSE
	return TRUE


/proc/odyssey_papers_budget_add(list/budget, add_items = 0, add_photos = 0, add_info = 0)
	budget["items"] += add_items
	budget["photos"] += add_photos
	budget["info_bytes"] += add_info


/proc/odyssey_write_paper_photo(savefile/photos, photo_id, obj/item/photo/P)
	if (!photos || !photo_id || !istype(P))
		return FALSE
	if (!isicon(P.img))
		return FALSE
	to_save(photos[photo_id], P.img)
	if (isicon(P.tiny))
		to_save(photos["[photo_id]_tiny"], P.tiny)
	if (isicon(P.icon))
		to_save(photos["[photo_id]_icon"], P.icon)
	return TRUE


/proc/odyssey_read_paper_photo_icon(savefile/photos, key)
	if (!photos || !key)
		return null
	if (!(key in photos.dir))
		return null
	var/icon/img
	from_save(photos[key], img)
	if (!isicon(img))
		return null
	return img


/proc/odyssey_serialize_paperwork_item(atom/A, savefile/photos, list/budget, photo_prefix)
	if (!odyssey_is_paperwork_item(A))
		return null

	if (istype(A, /obj/item/paper))
		if (istype(A, /obj/item/paper/admin))
			return null
		var/obj/item/paper/P = A
		var/info_len = length(P.info || "")
		if (!odyssey_papers_budget_ok(budget, 1, 0, info_len))
			return null
		odyssey_papers_budget_add(budget, 1, 0, info_len)
		var/list/stamped_paths = list()
		for (var/stamp_type in P.stamped)
			stamped_paths += "[stamp_type]"
		var/list/entry = list(
			"kind" = "paper",
			"type" = "[P.type]",
			"name" = P.name,
			"info" = P.info,
			"stamps" = P.stamps,
			"stamped" = stamped_paths,
			"language" = istype(P.language) ? P.language.name : null
		)
		return entry

	if (istype(A, /obj/item/photo))
		if (!odyssey_papers_budget_ok(budget, 1, 1, 0))
			return null
		var/obj/item/photo/Ph = A
		var/photo_id = "[photo_prefix]_[budget["photos"] + 1]"
		if (!odyssey_write_paper_photo(photos, photo_id, Ph))
			// Still persist metadata so the slot isn't silently empty next shift.
			photo_id = null
		odyssey_papers_budget_add(budget, 1, 1, 0)
		return list(
			"kind" = "photo",
			"type" = "[Ph.type]",
			"name" = Ph.name,
			"desc" = Ph.desc,
			"scribble" = Ph.scribble,
			"photo_size" = Ph.photo_size,
			"photo_id" = photo_id
		)

	if (istype(A, /obj/item/folder))
		if (!odyssey_papers_budget_ok(budget, 1, 0, 0))
			return null
		odyssey_papers_budget_add(budget, 1, 0, 0)
		var/obj/item/folder/F = A
		var/list/kids = list()
		for (var/atom/child in F)
			var/list/child_entry = odyssey_serialize_paperwork_item(child, photos, budget, photo_prefix)
			if (islist(child_entry))
				kids += list(child_entry)
		return list(
			"kind" = "folder",
			"type" = "[F.type]",
			"name" = F.name,
			"contents" = kids
		)

	if (istype(A, /obj/item/paper_bundle))
		if (!odyssey_papers_budget_ok(budget, 1, 0, 0))
			return null
		odyssey_papers_budget_add(budget, 1, 0, 0)
		var/obj/item/paper_bundle/B = A
		var/list/pages = list()
		for (var/atom/page in B.pages)
			var/list/page_entry = odyssey_serialize_paperwork_item(page, photos, budget, photo_prefix)
			if (islist(page_entry))
				pages += list(page_entry)
		return list(
			"kind" = "bundle",
			"type" = "[B.type]",
			"name" = B.name,
			"pages" = pages
		)

	return null


/proc/odyssey_collect_papers(generation)
	var/list/cabinets = list()
	var/list/budget = list("items" = 0, "photos" = 0, "info_bytes" = 0)
	var/savefile/photos
	var/photo_path = odyssey_papers_photos_path(generation)
	if (fexists(photo_path))
		fdel(photo_path)
	photos = new /savefile(photo_path)

	var/cabinet_index = 0
	for (var/obj/structure/filingcabinet/C in world)
		if (QDELETED(C) || !odyssey_atom_persistable(C))
			continue
		var/list/items = list()
		cabinet_index++
		var/prefix = "c[cabinet_index]"
		for (var/atom/thing in C)
			var/list/entry = odyssey_serialize_paperwork_item(thing, photos, budget, prefix)
			if (islist(entry))
				items += list(entry)
			CHECK_TICK
		if (!length(items))
			continue
		var/id = C.odyssey_persist_id || odyssey_assign_runtime_id(C)
		var/turf/T = get_turf(C)
		cabinets += list(list(
			"container_id" = id,
			"x" = T?.x,
			"y" = T?.y,
			"z" = T?.z,
			"items" = items
		))
		CHECK_TICK

	if (!budget["photos"] && fexists(photo_path))
		fdel(photo_path)

	if (budget["items"] >= ODYSSEY_PAPERS_MAX_ITEMS || budget["photos"] >= ODYSSEY_PAPERS_MAX_PHOTOS || budget["info_bytes"] >= ODYSSEY_PAPERS_MAX_INFO_BYTES)
		log_error("ODYSSEY: papers collect hit budget items=[budget["items"]] photos=[budget["photos"]] info_bytes=[budget["info_bytes"]]")

	log_debug("ODYSSEY: papers collect cabinets=[length(cabinets)] items=[budget["items"]] photos=[budget["photos"]] info_bytes=[budget["info_bytes"]]")
	return cabinets


/// Wipe mapped/player paperwork in persistable filing cabinets before restoring the snapshot.
/proc/odyssey_strip_filing_papers()
	var/removed = 0
	for (var/obj/structure/filingcabinet/C in world)
		if (QDELETED(C) || !odyssey_atom_persistable(C))
			continue
		for (var/atom/thing in C)
			if (!odyssey_is_paperwork_item(thing))
				continue
			qdel(thing)
			removed++
		CHECK_TICK
	log_debug("ODYSSEY: stripped [removed] filing-cabinet paperwork items on continue")
	return removed


/proc/odyssey_find_filingcabinet_for_entry(list/entry)
	if (!islist(entry))
		return null
	var/id = entry["container_id"]
	if (id)
		var/obj/structure/S = odyssey_find_structure_by_id(id)
		if (istype(S, /obj/structure/filingcabinet))
			return S
	var/turf/T = odyssey_locate_turf(entry)
	if (!T)
		return null
	return locate(/obj/structure/filingcabinet) in T


/proc/odyssey_spawn_paperwork_item(list/entry, savefile/photos)
	if (!islist(entry))
		return null
	var/path = text2path(entry["type"])
	if (!odyssey_paperwork_type_allowed(path))
		return null

	var/kind = entry["kind"]
	if (kind == "paper" || ispath(path, /obj/item/paper))
		var/obj/item/paper/P = new path(null)
		if (entry["name"])
			P.SetName(entry["name"])
		P.info = entry["info"]
		P.stamps = entry["stamps"]
		var/list/stamped_raw = entry["stamped"]
		P.stamped = list()
		if (islist(stamped_raw))
			for (var/stamp_text in stamped_raw)
				var/stamp_path = text2path(stamp_text)
				if (ispath(stamp_path))
					P.stamped += stamp_path
		var/lang_name = entry["language"]
		if (lang_name && all_languages[lang_name])
			P.language = all_languages[lang_name]
		P.updateinfolinks()
		P.update_icon()
		return P

	if (kind == "photo" || ispath(path, /obj/item/photo))
		var/obj/item/photo/Ph = new path(null)
		if (entry["name"])
			Ph.SetName(entry["name"])
		if (!isnull(entry["desc"]))
			Ph.desc = entry["desc"]
		if (!isnull(entry["scribble"]))
			Ph.scribble = entry["scribble"]
		if (isnum(entry["photo_size"]))
			Ph.photo_size = entry["photo_size"]
		var/photo_id = entry["photo_id"]
		if (photo_id)
			Ph.img = odyssey_read_paper_photo_icon(photos, photo_id)
			Ph.tiny = odyssey_read_paper_photo_icon(photos, "[photo_id]_tiny")
			var/icon/ic = odyssey_read_paper_photo_icon(photos, "[photo_id]_icon")
			if (isicon(ic))
				Ph.icon = ic
			else if (isicon(Ph.tiny))
				Ph.icon = Ph.tiny
			else if (isicon(Ph.img))
				Ph.icon = Ph.img
		return Ph

	if (kind == "folder" || ispath(path, /obj/item/folder))
		var/obj/item/folder/F = new path(null)
		if (entry["name"])
			F.SetName(entry["name"])
		for (var/list/child in entry["contents"])
			var/obj/item/I = odyssey_spawn_paperwork_item(child, photos)
			if (istype(I))
				I.forceMove(F)
		F.update_icon()
		return F

	if (kind == "bundle" || ispath(path, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/B = new path(null)
		if (entry["name"])
			B.SetName(entry["name"])
		B.pages = list()
		for (var/list/page in entry["pages"])
			var/obj/item/I = odyssey_spawn_paperwork_item(page, photos)
			if (!istype(I))
				continue
			I.forceMove(B)
			B.pages += I
		B.update_icon()
		return B

	return null


/proc/odyssey_apply_papers(list/cabinet_entries, generation)
	if (!islist(cabinet_entries) || !length(cabinet_entries))
		return
	var/savefile/photos
	var/photo_path = odyssey_papers_photos_path(generation)
	if (fexists(photo_path))
		photos = new /savefile(photo_path)
	var/applied = 0
	for (var/list/cabinet_entry in cabinet_entries)
		if (!islist(cabinet_entry))
			continue
		var/obj/structure/filingcabinet/C = odyssey_find_filingcabinet_for_entry(cabinet_entry)
		if (!istype(C))
			log_error("ODYSSEY: papers apply missing filing cabinet id=[cabinet_entry["container_id"]] at [cabinet_entry["x"]],[cabinet_entry["y"]],[cabinet_entry["z"]]")
			continue
		for (var/list/item_entry in cabinet_entry["items"])
			var/obj/item/I = odyssey_spawn_paperwork_item(item_entry, photos)
			if (!istype(I))
				continue
			I.forceMove(C)
			applied++
		CHECK_TICK
	log_debug("ODYSSEY: apply_papers items=[applied] cabinets=[length(cabinet_entries)]")
