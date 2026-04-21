// ─── R&D Server Persistence ───────────────────────────────────────────────────
// A standard super hard drive assigned to the "System" category acts as the
// persistence drive. State is saved as a file on that drive and survives server
// destruction/rebuild. State includes:
//   • Researched technology nodes
//   • Compiled tech levels
//   • Corporation reputation
//   • Known design IDs (so stolen design HDDs can be re-populated)
//
// Usage: assign any HDD to the "System" category via the server panel UI.
//        The drive can be ejected and inserted into another server to transfer progress.

// ── State file type ───────────────────────────────────────────────────────────

/datum/computer_file/data/rnd_state
	filetype = "RDS"
	filename = "rnd_state"

// ── Additional server vars ────────────────────────────────────────────────────

/obj/machinery/r_n_d/server
	/// Suppresses save calls while loading state to avoid infinite loops.
	var/loading_rnd_state = FALSE
	/// Prevents spawning multiple deferred save procs simultaneously.
	var/save_rnd_queued = FALSE

// ── Server persistence procs ──────────────────────────────────────────────────

/// Returns the HDD assigned to the "System" category, or null if not present.
/obj/machinery/r_n_d/server/proc/get_system_drive()
	return rnd_drives["System"]

/// Schedules a deferred save (batches rapid successive changes into one write).
/obj/machinery/r_n_d/server/proc/queue_save_rnd_state()
	if(loading_rnd_state || save_rnd_queued || QDELETED(src))
		return
	save_rnd_queued = TRUE
	addtimer(CALLBACK(src, PROC_REF(_do_save_rnd_state)), 5)

/obj/machinery/r_n_d/server/proc/_do_save_rnd_state()
	save_rnd_queued = FALSE
	if(!QDELETED(src))
		save_rnd_state()

/// Serialises current R&D state and writes it to the system HDD.
/obj/machinery/r_n_d/server/proc/save_rnd_state()
	if(loading_rnd_state)
		return
	var/obj/item/stock_parts/computer/hard_drive/sys = get_system_drive()
	if(!sys || !files)
		return

	var/list/tech_ids = list()
	for(var/datum/technology/T in files.researched_nodes)
		tech_ids += T.id

	var/list/levels = list()
	for(var/ttype in files.compiled_tech_levels)
		levels[ttype] = files.compiled_tech_levels[ttype]

	var/list/reputation = list()
	for(var/corp_id in files.corporation_reputation)
		reputation[corp_id] = files.corporation_reputation[corp_id]

	var/list/design_ids = list()
	for(var/datum/computer_file/binary/design/F in get_all_hdd_files())
		if(F.design?.id)
			design_ids |= F.design.id

	var/list/data = list(
		"researched" = tech_ids,
		"levels"     = levels,
		"reputation" = reputation,
		"designs"    = design_ids
	)

	var/datum/computer_file/data/rnd_state/F = new
	F.stored_data = json_encode(data)
	sys.save_file(F)

/// Reads the system HDD state file and restores all R&D progress.
/obj/machinery/r_n_d/server/proc/load_rnd_state()
	var/obj/item/stock_parts/computer/hard_drive/sys = get_system_drive()
	if(!sys || !files)
		return

	var/datum/computer_file/data/rnd_state/state_file = sys.find_file_by_name("rnd_state")
	if(!state_file?.stored_data)
		return

	var/list/data = json_decode(state_file.stored_data)
	if(!islist(data))
		return

	loading_rnd_state = TRUE

	var/list/tech_ids = data["researched"]
	if(islist(tech_ids))
		for(var/tid in tech_ids)
			var/datum/technology/T = SSresearch.get_tech_node(tid)
			if(T && !files.IsResearched(T))
				files.UnlockTechology(T, force = TRUE)

	var/list/levels = data["levels"]
	if(islist(levels))
		for(var/ttype in levels)
			files.compiled_tech_levels[ttype] = levels[ttype]

	var/list/reputation = data["reputation"]
	if(islist(reputation))
		for(var/corp_id in reputation)
			var/saved = reputation[corp_id]
			if(!(corp_id in files.corporation_reputation) || saved > files.corporation_reputation[corp_id])
				files.corporation_reputation[corp_id] = saved

	var/list/design_ids = data["designs"]
	if(islist(design_ids))
		for(var/did in design_ids)
			var/datum/design/D = SSresearch.get_design(did)
			if(D)
				files.AddDesign2Known(D)

	loading_rnd_state = FALSE
	_rebuild_design_categories()
