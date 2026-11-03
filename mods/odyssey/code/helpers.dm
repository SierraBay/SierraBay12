/// Station-relative date/time for IC surfaces (chronicle, briefing, lobby).
/proc/odyssey_ic_timestamp()
	return "[stationdate2text()] [stationtime2text()]"


/// Visitor / transient roots that must never enter the area snapshot (or persist even if somehow listed).
/proc/odyssey_area_excluded_from_snapshot(area/A)
	return istype(A, /area/space) \
		|| istype(A, /area/ship) \
		|| istype(A, /area/map_template) \
		|| istype(A, /area/supply) // cargo supply drone — docks onto hangar midround


/// Freeze areas present on station_levels at baseline time. Midround visitors are not included.
/// Tracked Sierra fleet areas are always unioned in — roundstart may run after abandon-apply
/// moved a craft off-station, and the craft can still return later the same shift.
/// Call before turf/object baselines (they consult this set).
/proc/odyssey_capture_persistable_areas(force = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.persistable_areas_ready && !force)
		return TRUE
	var/list/areas = list()
	for (var/z in GLOB.using_map.station_levels)
		for (var/turf/T in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			var/area/A = get_area(T)
			if (!istype(A))
				continue
			if (odyssey_area_excluded_from_snapshot(A))
				continue
			if (A.area_flags & AREA_FLAG_IS_NOT_PERSISTENT)
				continue
			areas[A] = TRUE
			CHECK_TICK
	// Guppy/Charon/Petrov/Phaethon — keep allowlisted even if already moved off for abandon.
	if (SSshuttle)
		for (var/shuttle_name in ODYSSEY_TRACKED_SHUTTLE_NAMES)
			var/datum/shuttle/S = SSshuttle.shuttles[shuttle_name]
			if (!istype(S) || !islist(S.shuttle_area))
				continue
			for (var/area/shuttle_area in S.shuttle_area)
				if (!istype(shuttle_area))
					continue
				if (odyssey_area_excluded_from_snapshot(shuttle_area))
					continue
				if (shuttle_area.area_flags & AREA_FLAG_IS_NOT_PERSISTENT)
					continue
				areas[shuttle_area] = TRUE
	state.persistable_areas = areas
	state.persistable_areas_ready = TRUE
	odyssey_invalidate_persistable_turfs_cache()
	log_debug("ODYSSEY: persistable areas captured ([length(areas)])")
	return TRUE


/proc/odyssey_area_persistable(area/A)
	if (!istype(A))
		return FALSE
	if (A.area_flags & AREA_FLAG_IS_NOT_PERSISTENT)
		return FALSE
	if (odyssey_area_excluded_from_snapshot(A))
		return FALSE
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.persistable_areas_ready)
		return FALSE
	return !!(state.persistable_areas[A])


/proc/odyssey_turf_persistable(turf/T)
	if (!istype(T))
		return FALSE
	if (!(T.z in GLOB.using_map.station_levels))
		return FALSE
	return odyssey_area_persistable(get_area(T))


/proc/odyssey_atom_persistable(atom/A)
	return odyssey_turf_persistable(get_turf(A))


/// TRUE if atom sits in a captured persistable area (shuttle areas may be off station z).
/proc/odyssey_atom_in_persistable_area(atom/A)
	var/turf/T = get_turf(A)
	if (!istype(T))
		return FALSE
	return odyssey_area_persistable(get_area(T))


/proc/odyssey_invalidate_persistable_turfs_cache()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	state.persistable_turfs_cache = null


/// All turfs belonging to captured persistable areas (source of truth for collect/strip walks).
/// Cached for the duration of one save/load session — call [odyssey_invalidate_persistable_turfs_cache] after.
/proc/odyssey_get_persistable_turfs()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.persistable_areas_ready)
		odyssey_capture_persistable_areas()
	if (islist(state.persistable_turfs_cache))
		return state.persistable_turfs_cache
	var/list/turfs = list()
	for (var/area/A in state.persistable_areas)
		if (!istype(A))
			continue
		for (var/turf/T in A)
			if (!istype(T))
				continue
			turfs += T
		CHECK_TICK
	state.persistable_turfs_cache = turfs
	return turfs


/// One turf walk for continue strip lanes (materials / cleanables / papers / items / remains).
/proc/odyssey_strip_persistable_lanes(strip_materials = FALSE, strip_cleanables = FALSE, strip_papers = FALSE, strip_items = FALSE, strip_remains = FALSE)
	if (!(strip_materials || strip_cleanables || strip_papers || strip_items || strip_remains))
		return
	var/mat_n = 0
	var/clean_n = 0
	var/paper_n = 0
	var/item_n = 0
	var/remain_n = 0
	for (var/turf/T in odyssey_get_persistable_turfs())
		if (strip_cleanables)
			for (var/obj/decal/cleanable/C in T)
				if (odyssey_cleanable_path_denylisted(C.type))
					continue
				qdel(C)
				clean_n++
		if (strip_materials || strip_items || strip_remains)
			for (var/obj/item/I in T)
				if (QDELETED(I))
					continue
				if (strip_materials && istype(I, /obj/item/stack/material))
					if (odyssey_atom_in_mob_inventory(I) || odyssey_atom_in_character_persist_safe(I))
						continue
					qdel(I)
					mat_n++
					continue
				if (strip_remains && istype(I, /obj/item/organ) && odyssey_organ_is_detached(I))
					qdel(I)
					remain_n++
					continue
				if (strip_items && istype(I, /obj/item) && odyssey_item_persistable(I))
					qdel(I)
					item_n++
		if (strip_materials || strip_items || strip_remains)
			for (var/obj/structure/closet/C in T)
				for (var/obj/item/I in C)
					if (QDELETED(I))
						continue
					if (strip_materials && istype(I, /obj/item/stack/material))
						qdel(I)
						mat_n++
						continue
					if (strip_remains && istype(I, /obj/item/organ) && odyssey_organ_is_detached(I))
						qdel(I)
						remain_n++
						continue
					if (strip_items && odyssey_item_persistable(I))
						qdel(I)
						item_n++
		if (strip_remains)
			for (var/obj/structure/morgue/M in T)
				remain_n += odyssey_strip_organs_from(M)
		if (strip_papers)
			for (var/obj/item/I in T)
				if (QDELETED(I) || !odyssey_paperwork_loose_persistable(I))
					continue
				qdel(I)
				paper_n++
			for (var/obj/structure/closet/C in T)
				for (var/obj/item/I in C)
					if (QDELETED(I) || !odyssey_paperwork_loose_persistable(I))
						continue
					qdel(I)
					paper_n++
			for (var/obj/structure/filingcabinet/FC in T)
				if (!odyssey_filingcabinet_persistable(FC))
					continue
				for (var/atom/thing in FC)
					if (!odyssey_is_paperwork_item(thing))
						continue
					qdel(thing)
					paper_n++
		CHECK_TICK
	log_debug("ODYSSEY: combined strip materials=[mat_n] cleanables=[clean_n] papers=[paper_n] items=[item_n] remains=[remain_n]")


/// TRUE if this atom's loc chain includes a living mob (equipped / inventory).
/proc/odyssey_atom_in_mob_inventory(atom/A)
	var/atom/L = A?.loc
	while (istype(L) && !isturf(L))
		if (ismob(L))
			return TRUE
		L = L.loc
	return FALSE


/// TRUE if inside a character_persist personal safe (those contents are another lane).
/proc/odyssey_atom_in_character_persist_safe(atom/A)
	var/atom/L = A
	while (istype(L) && !isturf(L))
		if (istype(L, /obj/item/storage/secure/safe/character_persist))
			return TRUE
		L = L.loc
	return FALSE


/proc/odyssey_coord_key(x, y, z)
	return "[x],[y],[z]"


/proc/odyssey_locate_turf(list/entry)
	if (!islist(entry))
		return null
	var/x = entry["x"]
	var/y = entry["y"]
	var/z = entry["z"]
	if (isnull(x) || isnull(y) || isnull(z))
		return null
	return locate(x, y, z)


/obj/var/odyssey_persist_id


/// Chemistry / medbay / virology refrigerated storage — contents saved on machinery entries.
/proc/odyssey_smartfridge_chemistry_persistable(obj/machinery/smartfridge/F)
	if (!istype(F))
		return FALSE
	return istype(F, /obj/machinery/smartfridge/chemistry) \
		|| istype(F, /obj/machinery/smartfridge/secure/medbay) \
		|| istype(F, /obj/machinery/smartfridge/secure/virology)


/proc/odyssey_machinery_whitelisted(obj/machinery/M)
	if (!istype(M))
		return FALSE
	return istype(M, /obj/machinery/computer) \
		|| istype(M, /obj/machinery/vending) \
		|| istype(M, /obj/machinery/fabricator) \
		|| istype(M, /obj/machinery/sleeper) \
		|| istype(M, /obj/machinery/door/airlock) \
		|| (istype(M, /obj/machinery/smartfridge) && odyssey_smartfridge_chemistry_persistable(M)) \
		|| istype(M, /obj/machinery/anomaly_container) \
		|| istype(M, /obj/machinery/artifact) \
		|| istype(M, /obj/machinery/power/smes) \
		|| istype(M, /obj/machinery/power/shield_generator) \
		|| istype(M, /obj/machinery/atmospherics/unary/cryo_cell) \
		|| (istype(M, /obj/machinery/portable_atmospherics) && !istype(M, /obj/machinery/portable_atmospherics/hydroponics/soil/invisible))


/// Structures that must not be snapshotted: powernet / disposal / multiz links need rebuild, not a blind new(turf).
/// Map furniture (tables/beds/chairs) — false «destroyed» tombstones + turf/type fallback wiped Charon/cargo tables on continue.
/// Atmospheric pipes are /obj/machinery/atmospherics — outside structure persist entirely.
/proc/odyssey_structure_path_denylisted(path)
	if (!ispath(path, /obj/structure))
		return TRUE
	return ispath(path, /obj/structure/cable) \
		|| ispath(path, /obj/structure/disposalpipe) \
		|| ispath(path, /obj/structure/disposalholder) \
		|| ispath(path, /obj/structure/disposaloutlet) \
		|| ispath(path, /obj/structure/ladder) \
		|| ispath(path, /obj/structure/stairs) \
		|| ispath(path, /obj/structure/transit_tube) \
		|| ispath(path, /obj/structure/transit_tube_pod) \
		|| ispath(path, /obj/structure/table) \
		|| ispath(path, /obj/structure/bed)


/proc/odyssey_structure_denylisted(obj/structure/S)
	if (!istype(S))
		return TRUE
	return odyssey_structure_path_denylisted(S.type)


/// Persist all ship structures in persistable areas, except denylisted types.
/proc/odyssey_structure_whitelisted(obj/structure/S)
	if (!istype(S))
		return FALSE
	if (odyssey_structure_denylisted(S))
		return FALSE
	return TRUE


/// Item types that must never enter items_*.json (junk, other pipelines, unstable new()).
/proc/odyssey_item_path_denylisted(path)
	if (!ispath(path, /obj/item))
		return TRUE
	// Other Odyssey / character_persist pipelines.
	if (ispath(path, /obj/item/stack/material))
		return TRUE
	if (ispath(path, /obj/item/organ))
		return TRUE
	if (ispath(path, /obj/item/storage/secure/safe/character_persist))
		return TRUE
	// Junk / floor noise.
	if (ispath(path, /obj/item/trash))
		return TRUE
	if (ispath(path, /obj/item/paper/cig))
		return TRUE
	if (ispath(path, /obj/item/material/shard))
		return TRUE
	if (ispath(path, /obj/item/ammo_casing))
		return TRUE
	// Abstracts / dangerous / deferred.
	if (ispath(path, /obj/item/grab))
		return TRUE
	if (ispath(path, /obj/item/grenade))
		return TRUE
	if (ispath(path, /obj/item/robot_parts) || ispath(path, /obj/item/aicard))
		return TRUE
	if (ispath(path, /obj/item/card/id))
		return TRUE
	if (ispath(path, /obj/item/reagent_containers/food/snacks/grown) || ispath(path, /obj/item/seeds))
		return TRUE
	if (ispath(path, /obj/item/device/uplink) || ispath(path, /obj/item/device/radio/uplink))
		return TRUE
	// Paperwork has its own lane (papers.json) with text/photos.
	if (ispath(path, /obj/item/paper) || ispath(path, /obj/item/photo) || ispath(path, /obj/item/folder) || ispath(path, /obj/item/paper_bundle))
		return TRUE
	// Round-critical uniques — must stay on the live map / respawn logic, not snapshot.
	if (ispath(path, /obj/item/disk/nuclear))
		return TRUE
	if (ispath(path, /obj/item/pinpointer))
		return TRUE
	if (ispath(path, /obj/item/blueprints))
		return TRUE
	if (ispath(path, /obj/item/storage/backpack/holding))
		return TRUE
	return FALSE


/proc/odyssey_item_denylisted(obj/item/I)
	if (!istype(I))
		return TRUE
	return odyssey_item_path_denylisted(I.type)


/// Bucket name for items_<bucket>.json, or null if not persisted here.
/proc/odyssey_item_persist_bucket(path)
	if (odyssey_item_path_denylisted(path))
		return null
	if (ispath(path, /obj/item/gun) || ispath(path, /obj/item/melee) || ispath(path, /obj/item/material/twohanded) || ispath(path, /obj/item/material/sword) || ispath(path, /obj/item/material/knife) || ispath(path, /obj/item/material/hatchet))
		return "weapons"
	if (ispath(path, /obj/item/clothing) || ispath(path, /obj/item/storage/backpack) || ispath(path, /obj/item/storage/belt))
		return "clothing"
	if (ispath(path, /obj/item/stack/cable_coil) || ispath(path, /obj/item/device/assembly) || ispath(path, /obj/item/weldingtool) || ispath(path, /obj/item/crowbar) || ispath(path, /obj/item/screwdriver) || ispath(path, /obj/item/wrench) || ispath(path, /obj/item/wirecutters) || ispath(path, /obj/item/device/multitool))
		return "tools"
	if (ispath(path, /obj/item/reagent_containers/syringe) || ispath(path, /obj/item/stack/medical) || ispath(path, /obj/item/reagent_containers/hypospray) || ispath(path, /obj/item/defibrillator) || ispath(path, /obj/item/reagent_containers/ivbag) || ispath(path, /obj/item/reagent_containers/glass) || ispath(path, /obj/item/reagent_containers/pill) || ispath(path, /obj/item/storage/pill_bottle))
		return "medical"
	if (ispath(path, /obj/item/reagent_containers/food))
		return "food"
	if (ispath(path, /obj/item/storage))
		return "storage"
	if (ispath(path, /obj/item/device) || ispath(path, /obj/item/modular_computer) || ispath(path, /obj/item/taperoll) || ispath(path, /obj/item/material/clipboard))
		return "devices"
	if (ispath(path, /obj/item/stack))
		return "stacks"
	return "misc"


/proc/odyssey_item_persistable(obj/item/I)
	if (!istype(I) || QDELETED(I))
		return FALSE
	if (odyssey_item_denylisted(I))
		return FALSE
	if (!odyssey_atom_in_persistable_area(I))
		return FALSE
	if (odyssey_atom_in_mob_inventory(I))
		return FALSE
	if (odyssey_atom_in_character_persist_safe(I))
		return FALSE
	return !!odyssey_item_persist_bucket(I.type)


/proc/odyssey_assign_runtime_id(obj/O)
	if (!istype(O))
		return null
	if (O.odyssey_persist_id)
		return O.odyssey_persist_id
	var/datum/odyssey_state/state = odyssey_ensure_state()
	O.odyssey_persist_id = "runtime-[state.campaign_id]-[state.next_object_id++]"
	return O.odyssey_persist_id


/// Map pixel shifts (DMM pixel_x/y). Only written when non-zero to keep JSON lean.
/proc/odyssey_write_pixel_offset(atom/A, list/entry)
	if (!istype(A) || !islist(entry))
		return
	if (A.pixel_x)
		entry["pixel_x"] = A.pixel_x
	if (A.pixel_y)
		entry["pixel_y"] = A.pixel_y


/proc/odyssey_apply_pixel_offset(atom/A, list/entry)
	if (!istype(A) || !islist(entry))
		return
	if (!isnull(entry["pixel_x"]))
		A.pixel_x = entry["pixel_x"]
	if (!isnull(entry["pixel_y"]))
		A.pixel_y = entry["pixel_y"]


/proc/odyssey_base_object_entry(obj/O)
	var/turf/T = get_turf(O)
	if (!istype(O) || !T)
		return null
	var/list/entry = list(
		"id" = O.odyssey_persist_id,
		"type" = "[O.type]",
		"x" = T.x,
		"y" = T.y,
		"z" = T.z,
		"dir" = O.dir,
		"name" = O.name,
		"anchored" = O.anchored
	)
	odyssey_write_pixel_offset(O, entry)
	return entry


/// Snapshots the clean DMM once so later roundend saves still diff against it, not against an already-applied world.
/// Must run before save apply: the lists are the clean-map diff base, and mapped ids are what machinery/structure entries look up.
/proc/odyssey_ensure_persist_baselines(overwrite = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.persist_baselines_ready && !overwrite)
		return TRUE
	odyssey_capture_persistable_areas(TRUE)
	odyssey_capture_map_baseline(TRUE)
	odyssey_capture_mech_baseline(TRUE)
	state.persist_baselines_ready = TRUE
	return TRUE


/// One persistable-turf walk: turf types, machinery/structure snapshots, and the live persist index.
/proc/odyssey_capture_map_baseline(force = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active && !force)
		return FALSE
	if (!force && islist(state.turf_baseline) && length(state.turf_baseline) && islist(state.machinery_baseline) && islist(state.structure_baseline))
		return TRUE
	var/list/turf_baseline = list()
	var/list/machines = list()
	var/list/structures = list()
	var/list/machine_index = list()
	var/list/structure_index = list()
	var/list/ordinals = list()
	for (var/turf/T in odyssey_get_persistable_turfs())
		if (odyssey_turf_persistable(T))
			turf_baseline[odyssey_coord_key(T.x, T.y, T.z)] = "[T.type]"
		for (var/obj/O in T)
			// Multi-tile airlocks sit in two turfs. Only the real loc is the object.
			if (O.loc != T)
				continue
			var/kind
			if (istype(O, /obj/machinery) && odyssey_machinery_whitelisted(O))
				kind = "machinery"
			else if (istype(O, /obj/structure) && odyssey_structure_whitelisted(O))
				kind = "structure"
			if (!kind)
				continue
			var/base_key = "[kind]:[O.type]@[odyssey_coord_key(T.x, T.y, T.z)]"
			var/ordinal = (ordinals[base_key] || 0) + 1
			ordinals[base_key] = ordinal
			O.odyssey_persist_id = "mapped:[base_key]#[ordinal]"
			var/list/entry = kind == "structure" ? odyssey_structure_snapshot(O) : odyssey_base_object_entry(O)
			if (kind == "machinery")
				machines[O.odyssey_persist_id] = entry
				machine_index[O.odyssey_persist_id] = O
			else
				structures[O.odyssey_persist_id] = entry
				structure_index[O.odyssey_persist_id] = O
		CHECK_TICK
	state.turf_baseline = turf_baseline
	state.machinery_baseline = machines
	state.structure_baseline = structures
	state.persist_index_machinery = machine_index
	state.persist_index_structures = structure_index
	log_debug("ODYSSEY: map baseline turfs=[length(turf_baseline)] machinery=[length(machines)] structures=[length(structures)]")
	return TRUE


/proc/odyssey_capture_object_baselines(force = FALSE)
	return odyssey_capture_map_baseline(force)
