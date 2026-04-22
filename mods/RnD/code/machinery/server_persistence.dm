// ─── R&D Server Persistence ───────────────────────────────────────────────────
// Only /server/core has a System HDD and full persistence. All other server
// types get stub no-op procs so call sites in server.dm and research.dm stay
// clean without null-checks everywhere.
//
// Usage: assign any HDD to the "System" category via the server panel UI on a
//        core server. The drive can be ejected and moved to another core server
//        to transfer progress. State includes:
//   • Researched technology nodes
//   • Compiled tech levels
//   • Corporation reputation
//   • Known design IDs (so stolen design HDDs can be re-populated)

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
	if(loading_rnd_state || save_rnd_queued || QDELETED(src))
		return
	save_rnd_queued = TRUE
	addtimer(new Callback(src, PROC_REF(_do_save_rnd_state)), 5)

/obj/machinery/r_n_d/server/core/proc/_do_save_rnd_state()
	save_rnd_queued = FALSE
	if(!QDELETED(src))
		save_rnd_state()

/obj/machinery/r_n_d/server/core/save_rnd_state()
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

/obj/machinery/r_n_d/server/core/Initialize(mapload)
	. = ..()
	load_rnd_state()

/obj/machinery/r_n_d/server/core/load_rnd_state()
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
