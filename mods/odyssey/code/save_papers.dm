/// Odyssey paperwork persistence: filing cabinets + loose paper/photo/folder/bundle on floor/closets.
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
	if (ispath(path, /obj/item/paper/cig))
		return FALSE
	return ispath(path, /obj/item/paper) \
		|| ispath(path, /obj/item/photo) \
		|| ispath(path, /obj/item/folder) \
		|| ispath(path, /obj/item/paper_bundle)


/proc/odyssey_is_paperwork_item(atom/A)
	if (!istype(A))
		return FALSE
	return odyssey_paperwork_type_allowed(A.type)


/proc/odyssey_filingcabinet_persistable(obj/structure/filingcabinet/C)
	if (!istype(C) || QDELETED(C))
		return FALSE
	return odyssey_atom_in_persistable_area(C)


/// Loose paperwork on a turf or in a closet (not nested in folder/bundle/cabinet/mob).
/proc/odyssey_paperwork_loose_persistable(obj/item/I)
	if (!odyssey_is_paperwork_item(I) || QDELETED(I))
		return FALSE
	if (!odyssey_atom_in_persistable_area(I))
		return FALSE
	if (odyssey_atom_in_mob_inventory(I))
		return FALSE
	if (odyssey_atom_in_character_persist_safe(I))
		return FALSE
	var/atom/L = I.loc
	if (!istype(L))
		return FALSE
	if (isturf(L))
		return TRUE
	if (istype(L, /obj/structure/closet))
		return TRUE
	return FALSE


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
		var/info_text = P.info || ""
		var/info_len = length(info_text)
		if (!odyssey_papers_budget_ok(budget, 1, 0, info_len))
			return null
		odyssey_papers_budget_add(budget, 1, 0, info_len)
		var/list/stamped_paths = list()
		if (islist(P.stamped))
			for (var/stamp_type in P.stamped)
				stamped_paths += "[stamp_type]"
		var/lang_name = null
		if (istype(P.language))
			lang_name = P.language.name
		else if (istext(P.language))
			lang_name = P.language
		var/list/entry = list(
			"kind" = "paper",
			"type" = "[P.type]",
			"name" = P.name,
			"info" = info_text,
			"stamps" = P.stamps,
			"stamped" = stamped_paths,
			"language" = lang_name
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
		if (islist(B.pages))
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


/proc/odyssey_collect_loose_paperwork_entry(obj/item/I, turf/T, savefile/photos, list/budget, photo_prefix)
	if (!odyssey_paperwork_loose_persistable(I) || !istype(T))
		return null
	var/list/item_entry = odyssey_serialize_paperwork_item(I, photos, budget, photo_prefix)
	if (!islist(item_entry))
		return null
	var/list/entry = list(
		"placement" = istype(I.loc, /obj/structure/closet) ? "closet" : "floor",
		"x" = T.x,
		"y" = T.y,
		"z" = T.z,
		"dir" = I.dir,
		"items" = list(item_entry)
	)
	odyssey_write_pixel_offset(I, entry)
	return entry


/proc/odyssey_collect_papers(generation)
	var/list/entries = list()
	var/list/budget = list("items" = 0, "photos" = 0, "info_bytes" = 0)
	var/savefile/photos
	var/photo_path = odyssey_papers_photos_path(generation)
	if (fexists(photo_path))
		fdel(photo_path)
	photos = new /savefile(photo_path)

	var/cabinet_index = 0
	var/loose_index = 0
	var/cabinets_seen = 0
	var/loose_count = 0
	for (var/turf/T in odyssey_get_persistable_turfs())
		for (var/obj/structure/filingcabinet/C in T)
			if (!odyssey_filingcabinet_persistable(C))
				continue
			cabinets_seen++
			var/list/items = list()
			cabinet_index++
			var/prefix = "c[cabinet_index]"
			for (var/atom/thing in C)
				var/list/entry = odyssey_serialize_paperwork_item(thing, photos, budget, prefix)
				if (islist(entry))
					items += list(entry)
			if (!length(items))
				continue
			var/id = C.odyssey_persist_id || odyssey_assign_runtime_id(C)
			entries += list(list(
				"placement" = "cabinet",
				"container_id" = id,
				"container_type" = "[C.type]",
				"x" = T.x,
				"y" = T.y,
				"z" = T.z,
				"items" = items
			))
		for (var/obj/item/I in T)
			loose_index++
			var/list/loose = odyssey_collect_loose_paperwork_entry(I, T, photos, budget, "f[loose_index]")
			if (!islist(loose))
				continue
			entries += list(loose)
			loose_count++
		for (var/obj/structure/closet/Closet in T)
			for (var/obj/item/I in Closet)
				loose_index++
				var/list/loose = odyssey_collect_loose_paperwork_entry(I, T, photos, budget, "k[loose_index]")
				if (!islist(loose))
					continue
				entries += list(loose)
				loose_count++
		CHECK_TICK

	if (!budget["photos"] && fexists(photo_path))
		fdel(photo_path)

	if (budget["items"] >= ODYSSEY_PAPERS_MAX_ITEMS || budget["photos"] >= ODYSSEY_PAPERS_MAX_PHOTOS || budget["info_bytes"] >= ODYSSEY_PAPERS_MAX_INFO_BYTES)
		log_error("ODYSSEY: papers collect hit budget items=[budget["items"]] photos=[budget["photos"]] info_bytes=[budget["info_bytes"]]")

	log_game("ODYSSEY: papers collect cabinets_seen=[cabinets_seen] loose=[loose_count] entries=[length(entries)] items=[budget["items"]] photos=[budget["photos"]] info_bytes=[budget["info_bytes"]]")
	return entries


/// Wipe mapped/player paperwork in cabinets, on floors, and in closets before restore.
/proc/odyssey_strip_filing_papers()
	var/removed = 0
	for (var/turf/T in odyssey_get_persistable_turfs())
		for (var/obj/item/I in T)
			if (!odyssey_paperwork_loose_persistable(I))
				continue
			qdel(I)
			removed++
		for (var/obj/structure/closet/Closet in T)
			for (var/obj/item/I in Closet)
				if (!odyssey_paperwork_loose_persistable(I))
					continue
				qdel(I)
				removed++
		for (var/obj/structure/filingcabinet/C in T)
			if (!odyssey_filingcabinet_persistable(C))
				continue
			for (var/atom/thing in C)
				if (!odyssey_is_paperwork_item(thing))
					continue
				qdel(thing)
				removed++
		CHECK_TICK
	log_debug("ODYSSEY: stripped [removed] paperwork items on continue")
	return removed


/proc/odyssey_find_filingcabinet_for_entry(list/entry, list/claimed = null)
	if (!islist(entry))
		return null
	var/id = entry["container_id"]
	if (id)
		var/obj/structure/S = odyssey_find_structure_by_id(id)
		if (istype(S, /obj/structure/filingcabinet) && odyssey_filingcabinet_persistable(S))
			if (!islist(claimed) || !claimed[S])
				return S
	var/turf/T = odyssey_locate_turf(entry)
	if (!T)
		return null
	var/want_path = character_persist_safe_resolve_path(entry["container_type"])
	var/obj/structure/filingcabinet/fallback
	for (var/obj/structure/filingcabinet/C in T)
		if (!odyssey_filingcabinet_persistable(C))
			continue
		if (islist(claimed) && claimed[C])
			continue
		if (want_path && C.type == want_path)
			return C
		if (!fallback)
			fallback = C
	return fallback


/proc/odyssey_spawn_paperwork_item(list/entry, savefile/photos)
	if (!islist(entry))
		return null
	var/path = odyssey_resolve_path(entry["type"])
	if (!odyssey_paperwork_type_allowed(path))
		return null

	var/kind = entry["kind"]
	if (kind == "paper" || ispath(path, /obj/item/paper))
		var/obj/item/paper/P = new path(null)
		// info is already HTML from the previous shift — do not re-parse pencode.
		P.set_content(entry["info"] || "", entry["name"], FALSE)
		P.stamps = entry["stamps"]
		var/list/stamped_raw = entry["stamped"]
		P.stamped = list()
		if (islist(stamped_raw))
			for (var/stamp_text in stamped_raw)
				var/stamp_path = odyssey_resolve_path(stamp_text)
				if (ispath(stamp_path))
					P.stamped += stamp_path
		var/lang_name = entry["language"]
		if (lang_name)
			P.set_language(lang_name, TRUE)
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


/proc/odyssey_apply_loose_paperwork_entry(list/entry, savefile/photos)
	if (!islist(entry))
		return 0
	var/turf/T = odyssey_locate_turf(entry)
	if (!T)
		return 0
	var/applied = 0
	var/placement = entry["placement"]
	for (var/list/item_entry in entry["items"])
		var/obj/item/I = odyssey_spawn_paperwork_item(item_entry, photos)
		if (!istype(I))
			continue
		I.forceMove(T)
		if (!isnull(entry["dir"]))
			I.set_dir(entry["dir"])
		odyssey_apply_pixel_offset(I, entry)
		if (placement == "closet" || entry["in_closet"])
			var/obj/structure/closet/C = locate() in T
			if (istype(C))
				I.forceMove(C)
		applied++
	return applied


/proc/odyssey_apply_papers(list/cabinet_entries, generation)
	if (!islist(cabinet_entries) || !length(cabinet_entries))
		return
	var/savefile/photos
	var/photo_path = odyssey_papers_photos_path(generation)
	if (fexists(photo_path))
		photos = new /savefile(photo_path)
	var/applied = 0
	var/loose_applied = 0
	var/missing = 0
	var/list/claimed = list()
	for (var/list/cabinet_entry in cabinet_entries)
		if (!islist(cabinet_entry))
			continue
		var/placement = cabinet_entry["placement"]
		// Legacy entries omit placement and always meant filing cabinets.
		if (placement == "floor" || placement == "closet")
			loose_applied += odyssey_apply_loose_paperwork_entry(cabinet_entry, photos)
			CHECK_TICK
			continue
		var/obj/structure/filingcabinet/C = odyssey_find_filingcabinet_for_entry(cabinet_entry, claimed)
		if (!istype(C))
			missing++
			log_error("ODYSSEY: papers apply missing filing cabinet id=[cabinet_entry["container_id"]] type=[cabinet_entry["container_type"]] at [cabinet_entry["x"]],[cabinet_entry["y"]],[cabinet_entry["z"]]")
			continue
		claimed[C] = TRUE
		if (cabinet_entry["container_id"])
			C.odyssey_persist_id = cabinet_entry["container_id"]
		for (var/list/item_entry in cabinet_entry["items"])
			var/obj/item/I = odyssey_spawn_paperwork_item(item_entry, photos)
			if (!istype(I))
				continue
			I.forceMove(C)
			applied++
		CHECK_TICK
	log_game("ODYSSEY: apply_papers cabinet_items=[applied] loose_items=[loose_applied] entries=[length(cabinet_entries)] missing_cabinets=[missing]")
