/// One walk of the persistable ship for a campaign save.
/// Separate collect procs stay for admin previews; the round save must not cross the map eight times.


/proc/odyssey_papers_context(generation)
	var/list/entries = list()
	var/list/budget = list("items" = 0, "photos" = 0, "info_bytes" = 0)
	var/photo_path = odyssey_papers_photos_path(generation)
	if (photo_path && fexists(photo_path))
		fdel(photo_path)
	var/savefile/photos = new /savefile(photo_path)
	return list(
		"entries" = entries,
		"budget" = budget,
		"photos" = photos,
		"photo_path" = photo_path,
		"cabinet_index" = 0,
		"loose_index" = 0,
		"cabinets_seen" = 0,
		"loose_count" = 0
	)


/proc/odyssey_collect_station(generation)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/turfs = list()
	var/list/turf_baseline = state.turf_baseline
	var/skip_turfs = !islist(turf_baseline) || !length(turf_baseline)
	if (skip_turfs)
		log_error("ODYSSEY: no turf baseline; skipping turf save")
	var/list/machinery = list()
	var/list/mach_live = list()
	var/list/structures = list()
	var/list/struct_live = list()
	var/list/materials = list()
	var/list/remains = list()
	var/list/cleanables = list()
	var/list/buckets = list()
	for (var/bucket in ODYSSEY_ITEM_BUCKETS)
		buckets[bucket] = list()
	var/list/paper_ctx = odyssey_papers_context(generation)

	for (var/turf/T in odyssey_get_persistable_turfs())
		if (!skip_turfs)
			odyssey_collect_turf_into(T, turfs, turf_baseline)
		odyssey_collect_machinery_turf(T, machinery, mach_live, state)
		odyssey_collect_structure_turf(T, structures, struct_live, state)
		odyssey_collect_material_turf(T, materials)
		odyssey_collect_papers_turf(T, paper_ctx)
		odyssey_collect_item_turf(T, buckets)
		odyssey_collect_remains_turf(T, remains)
		odyssey_collect_cleanable_turf(T, cleanables)
		CHECK_TICK

	odyssey_finish_machinery_destroyed(machinery, mach_live, state)
	odyssey_finish_structure_destroyed(structures, struct_live, state)
	var/list/papers = odyssey_finish_papers(paper_ctx, paper_ctx["photo_path"])
	return list(
		"turfs" = turfs,
		"machinery" = machinery,
		"structures" = structures,
		"materials" = materials,
		"papers" = papers,
		"items" = buckets,
		"remains" = remains,
		"cleanables" = cleanables
	)
