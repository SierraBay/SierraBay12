// ─── R&D Server Persistence ───────────────────────────────────────────────────
// Only /server/core has a System HDD and full persistence. All other server
// types get stub no-ops.
//
// Cross-round ownership lives in Odyssey research.json (tech_tree). The System
// HDD rnd_state file is an IC mid-shift mirror and only save/loads while
// odyssey_rnd_active() is TRUE.

// ── State file type ───────────────────────────────────────────────────────────

/datum/computer_file/data/rnd_state
	filetype = "RDS"
	filename = "rnd_state"
	size = 20
	read_only = TRUE
	undeletable = TRUE

// ── Stub no-ops on base server ────────────────────────────────────────────────

/obj/machinery/r_n_d/server/proc/get_system_drive()
	return null

/obj/machinery/r_n_d/server/proc/load_rnd_state()
	return

/obj/machinery/r_n_d/server/proc/save_rnd_state()
	return

/obj/machinery/r_n_d/server/proc/queue_save_rnd_state()
	return

/obj/machinery/r_n_d/server/proc/apply_rnd_tech_tree_data(list/data)
	return

// ── Shared tech_tree serialize (catalog + reverse-engineered) ─────────────────

/proc/odyssey_rnd_resolve_key(key)
	if (ispath(key))
		return key
	if (!istext(key) || !length(key))
		return null
	var/path = text2path(key)
	if (ispath(path))
		return path
	return key


/proc/odyssey_rnd_serialize_re_design(datum/design/D)
	if (!istype(D) || !D.reverse_engineered)
		return null
	if (!D.build_path)
		return null
	var/list/mats = list()
	for (var/mat in D.materials)
		mats["[mat]"] = D.materials[mat]
	var/list/chems = list()
	for (var/chem in D.chemicals)
		chems["[chem]"] = D.chemicals[chem]
	return list(
		"id" = "[D.id]",
		"name" = D.name,
		"desc" = D.desc,
		"shortname" = D.shortname,
		"build_path" = "[D.build_path]",
		"build_type" = D.build_type,
		"materials" = mats,
		"chemicals" = chems,
		"category" = islist(D.category) ? D.category.Copy() : list("Reverse Engineered"),
		"quality" = D.quality,
		"reverse_engineered" = TRUE,
		"time" = D.time,
		"adjust_materials" = !!D.adjust_materials
	)


/proc/odyssey_rnd_restore_re_design(list/data)
	if (!islist(data))
		return null
	var/build_path = text2path(data["build_path"])
	if (!ispath(build_path, /obj/item) && !ispath(build_path, /atom))
		return null
	var/datum/design/D = new /datum/design()
	D.build_path = build_path
	D.reverse_engineered = TRUE
	D.id = data["id"] || "re_[replacetext("[build_path]", "/", "_")]"
	if (data["name"])
		D.name = data["name"]
	else
		var/atom/movable/path_atom = build_path
		D.name = initial(path_atom.name)
	D.desc = data["desc"] || "Reverse-engineered design."
	D.shortname = data["shortname"] || capitalize(D.name)
	var/bt = data["build_type"]
	if (istext(bt))
		bt = text2num(bt)
	if (isnum(bt))
		D.build_type = bt
	else
		D.build_type = PROTOLATHE
	if (islist(data["category"]))
		D.category = data["category"].Copy()
	else
		D.category = list("Reverse Engineered")
	var/q = data["quality"]
	if (istext(q))
		q = text2num(q)
	if (isnum(q))
		D.quality = q
	var/t = data["time"]
	if (istext(t))
		t = text2num(t)
	if (isnum(t))
		D.time = t
	if (!isnull(data["adjust_materials"]))
		D.adjust_materials = !!data["adjust_materials"]
	D.materials = list()
	if (islist(data["materials"]))
		for (var/key in data["materials"])
			var/resolved = odyssey_rnd_resolve_key(key)
			var/amount = data["materials"][key]
			if (istext(amount))
				amount = text2num(amount)
			if (isnull(resolved) || !isnum(amount))
				continue
			D.materials[resolved] = amount
	D.chemicals = list()
	if (islist(data["chemicals"]))
		for (var/key in data["chemicals"])
			var/resolved = odyssey_rnd_resolve_key(key)
			var/amount = data["chemicals"][key]
			if (istext(amount))
				amount = text2num(amount)
			if (isnull(resolved) || !isnum(amount))
				continue
			D.chemicals[resolved] = amount
	D.item_name = D.name
	// Drop material keys the material SS does not know — AssembleDesignUIData nullrefs otherwise.
	if (length(D.materials))
		var/list/valid_mats = list()
		for (var/mat in D.materials)
			if (SSmaterials.get_material_by_name(mat))
				valid_mats[mat] = D.materials[mat]
		D.materials = valid_mats
	D.file = new /datum/computer_file/binary/design()
	D.file.design = D
	D.file.filename = sanitizeFileName("[D.id]")
	D.file.filetype = "design"
	D.file.size = 10
	D.AssembleDesignUIData()
	return D


/proc/odyssey_rnd_build_tech_tree(obj/machinery/r_n_d/server/S)
	if (!istype(S) || !S.files)
		return null
	var/list/tech_ids = list()
	for (var/datum/technology/T in S.files.researched_nodes)
		tech_ids += T.id
	var/list/levels = list()
	for (var/ttype in S.files.compiled_tech_levels)
		levels[ttype] = S.files.compiled_tech_levels[ttype]
	var/list/reputation = list()
	for (var/corp_id in S.files.corporation_reputation)
		reputation[corp_id] = S.files.corporation_reputation[corp_id]
	var/list/design_ids = list()
	var/list/re_designs = list()
	var/list/seen_re = list()
	for (var/datum/computer_file/binary/design/F in S.get_all_hdd_files())
		var/datum/design/D = F.design
		if (!D?.id)
			continue
		if (D.reverse_engineered)
			var/reid = "[D.id]"
			if (seen_re[reid])
				continue
			seen_re[reid] = TRUE
			var/list/payload = odyssey_rnd_serialize_re_design(D)
			if (islist(payload))
				re_designs += list(payload)
			continue
		design_ids |= "[D.id]"
	return list(
		"researched" = tech_ids,
		"levels" = levels,
		"reputation" = reputation,
		"designs" = design_ids,
		"re_designs" = re_designs
	)


/proc/odyssey_rnd_primary_core()
	var/obj/machinery/r_n_d/server/core/fallback
	for (var/obj/machinery/r_n_d/server/core/C in SSresearch.rnd_server_list)
		if (QDELETED(C) || !C.files)
			continue
		if (C.server_id == 1)
			return C
		if (!fallback)
			fallback = C
	return fallback


/proc/odyssey_rnd_apply_tech_tree(list/data)
	if (!islist(data))
		return 0
	var/applied = 0
	for (var/obj/machinery/r_n_d/server/core/C in SSresearch.rnd_server_list)
		if (QDELETED(C) || !C.files)
			continue
		C.apply_rnd_tech_tree_data(data)
		if (odyssey_rnd_active())
			C.save_rnd_state()
		applied++
	return applied

// ── Core server — persistence vars ───────────────────────────────────────────

/obj/machinery/r_n_d/server/core
	/// Suppresses save calls while loading state to avoid infinite loops.
	var/loading_rnd_state = FALSE
	/// Prevents spawning multiple deferred save procs simultaneously.
	var/save_rnd_queued = FALSE

// ── Core server — real implementations ───────────────────────────────────────

/obj/machinery/r_n_d/server/core/dismantle()
	// dismantle() drops contents via dropInto() before qdel(src), which fires Exited and clears
	// rnd_drives. Save while HDDs are still registered, then let the base handle the rest.
	save_rnd_state()
	return ..()

/obj/machinery/r_n_d/server/core/Destroy()
	// Covers direct qdel/destruction (explosion, admin delete) where dismantle() wasn't called.
	// At this point HDDs haven't been force-moved yet, so rnd_drives is still intact.
	save_rnd_state()
	return ..()

/obj/machinery/r_n_d/server/core/get_system_drive()
	return rnd_drives["System"]

/obj/machinery/r_n_d/server/core/queue_save_rnd_state()
	if (!odyssey_rnd_active())
		return
	if (loading_rnd_state || save_rnd_queued || QDELETED(src))
		return
	save_rnd_queued = TRUE
	addtimer(new Callback(src, PROC_REF(_do_save_rnd_state)), 5)

/obj/machinery/r_n_d/server/core/proc/_do_save_rnd_state()
	save_rnd_queued = FALSE
	if (!QDELETED(src))
		save_rnd_state()

/obj/machinery/r_n_d/server/core/save_rnd_state()
	if (!odyssey_rnd_active())
		return
	if (loading_rnd_state)
		return
	var/obj/item/stock_parts/computer/hard_drive/sys = get_system_drive()
	if (!sys || !files)
		return
	var/list/data = odyssey_rnd_build_tech_tree(src)
	if (!islist(data))
		return
	var/datum/computer_file/data/rnd_state/F = new
	F.stored_data = json_encode(data)
	sys.save_file(F)

/obj/machinery/r_n_d/server/core/Initialize(mapload)
	. = ..()
	load_rnd_state()

/obj/machinery/r_n_d/server/core/load_rnd_state()
	if (!odyssey_rnd_active())
		return
	var/obj/item/stock_parts/computer/hard_drive/sys = get_system_drive()
	if (!sys || !files)
		return
	var/datum/computer_file/data/rnd_state/state_file = sys.find_file_by_name("rnd_state")
	if (!state_file?.stored_data)
		return
	var/list/data = json_decode(state_file.stored_data)
	if (!islist(data))
		return
	apply_rnd_tech_tree_data(data)

/// Quiet catalog lookup — SSresearch.get_design() logs error() on miss (noisy for stale save ids).
/proc/odyssey_rnd_find_catalog_design(id)
	if (isnull(id) || id == "")
		return null
	for (var/datum/design/D in SSresearch.all_designs)
		if (D.id == id || "[D.id]" == "[id]")
			return D
	return null


/obj/machinery/r_n_d/server/core/apply_rnd_tech_tree_data(list/data)
	if (!islist(data) || !files)
		return
	loading_rnd_state = TRUE

	var/list/tech_ids = data["researched"]
	if (islist(tech_ids))
		for (var/tid in tech_ids)
			var/datum/technology/T = SSresearch.get_tech_node(tid)
			if (T && !files.IsResearched(T))
				files.UnlockTechology(T, force = TRUE)

	var/list/levels = data["levels"]
	if (islist(levels))
		for (var/ttype in levels)
			var/lvl = levels[ttype]
			if (istext(lvl))
				lvl = text2num(lvl)
			if (!isnum(lvl))
				continue
			files.compiled_tech_levels[ttype] = lvl

	// Unlock first (may +5 corp rep), then take max with saved so campaign mission bonuses survive.
	var/list/reputation = data["reputation"]
	if (islist(reputation))
		for (var/corp_id in reputation)
			var/saved = reputation[corp_id]
			if (istext(saved))
				saved = text2num(saved)
			if (!isnum(saved))
				continue
			var/current = files.corporation_reputation[corp_id]
			if (!isnum(current) || saved > current)
				files.SetCorporationReputation(corp_id, saved)

	var/list/design_ids = data["designs"]
	if (islist(design_ids))
		for (var/did in design_ids)
			var/datum/design/D = odyssey_rnd_find_catalog_design(did)
			if (D?.file)
				files.AddDesign2Known(D)

	var/list/re_designs = data["re_designs"]
	if (islist(re_designs))
		for (var/entry in re_designs)
			if (!islist(entry))
				continue
			var/list/payload = entry
			var/datum/design/RE = odyssey_rnd_restore_re_design(payload)
			if (istype(RE) && RE.file)
				files.AddDesign2Known(RE)

	loading_rnd_state = FALSE
	_rebuild_design_categories()
