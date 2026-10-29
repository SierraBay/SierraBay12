/// Runtime state for the current round's Odyssey mode.
var/global/datum/odyssey_state/odyssey

/datum/odyssey_state
	/// True if this round was voted in as an Odyssey (start or continue).
	var/active = FALSE
	/// True if we loaded a previous campaign save this round.
	var/continued = FALSE
	/// Campaign id (map-scoped for now).
	var/campaign_id
	/// Shift index within the campaign (1-based).
	var/shift_number = 0
	/// Shortest and longest successful route length.
	var/min_shifts = ODYSSEY_MIN_SHIFTS
	var/max_shifts = ODYSSEY_MAX_SHIFTS
	/// Stable seed used by the route and sector threat generators.
	var/campaign_seed
	/// Campaign lifecycle status. Only ODYSSEY_STATUS_ACTIVE can continue.
	var/status = ODYSSEY_STATUS_ACTIVE
	var/outcome_reason
	/// Associative list: sector id = sector data.
	var/list/sector_graph
	var/current_sector_id
	var/selected_sector_id
	var/selected_by
	var/transition_committed = FALSE
	/// TRUE after a successful Odyssey bluespace-drive campaign jump this round.
	var/odyssey_bsd_jump_done = FALSE
	/// TRUE while the 5-minute End the shift countdown is running.
	var/shift_end_queued = FALSE
	var/list/route_history
	/// Campaign participant registry keyed by "ckey|slot".
	var/list/roster
	/// Schema version of the loaded/written save.
	var/save_version = ODYSSEY_VERSION
	var/save_generation
	/// True after the pregame Odyssey vote finished (or was skipped).
	var/pregame_vote_done = FALSE
	/// Path to the campaign meta JSON for the current map.
	var/meta_path
	/// Roundstart turf type baseline: "x,y,z" = type string. Used to emit only deltas.
	var/list/turf_baseline
	/// Baselines for whitelist-persisted machinery and structures.
	var/list/machinery_baseline
	var/list/structure_baseline
	var/list/mech_baseline
	/// TRUE after the clean-map persist baselines were taken this round. Blocks recapture after apply.
	var/persist_baselines_ready = FALSE
	var/next_object_id = 1
	/// Campaign sleeper traitors keyed by "ckey|slot".
	var/list/sleepers
	/// Campaign changelings keyed by "ckey|slot". Persist only if alive on Sierra at save.
	var/list/changelings
	/// True after the optional midround +1 sleeper for this shift was handled or skipped permanently.
	var/sleeper_midround_done = FALSE
	/// True after mercenaries successfully spawned once this campaign (persisted).
	var/merc_used = FALSE
	/// Shift number when merc_used was set.
	var/merc_used_shift = 0
	/// Why merc_used was set (odyssey_roll / gamemode / late_spawn / etc).
	var/merc_used_reason
	/// Per lobby-setup roll result for this shift; null until considered.
	var/merc_shift_decision
	/// Hostile-sector raider / ninja roll results for this shift.
	var/raider_shift_decision
	var/ninja_shift_decision
	/// Rolled changeling count for this lobby (1-2) while Odyssey is active.
	var/changeling_shift_count
	/// Shuttle names left behind off Sierra (Guppy/Charon/Petrov/Phaethon/escape pods). Derived from shuttle_reports.
	var/list/abandoned_shuttles
	/// Tracked shuttle reports: name = {status=abandoned|damaged, damage, repair_cost}.
	var/list/shuttle_reports
	/// Campaign chronicle entries (list of assoc lists).
	var/list/chronicle
	/// Next chronicle event id suffix.
	var/next_chronicle_id = 1
	/// Deaths recorded into chronicle this shift (for public aggregate).
	var/chronicle_deaths_this_shift = 0
	/// Named deaths buffered until shift close — live public chronicle would be meta.
	var/list/pending_chronicle_deaths
	/// Outcome already written to chronicle (avoid duplicate on save+finish).
	var/outcome_chronicled = FALSE
	/// Campaign-long contracts.
	var/list/contracts
	/// Per-shift objectives (history kept; active ones evaluated each roundend).
	var/list/objectives
	/// Next id suffix for contracts/objectives.
	var/next_objective_id = 1
	/// Campaign research progress (science briefs, notes) — research.json.
	var/list/research
	/// Last validation errors shown in the admin panel.
	var/list/validation_errors
	/// Temporary id → atom maps used during apply. Cleared after apply.
	var/list/persist_index_machinery
	var/list/persist_index_structures
	var/list/persist_index_mechs


/datum/odyssey_state/New()
	..()
	sector_graph = list()
	route_history = list()
	roster = list()
	sleepers = list()
	changelings = list()
	abandoned_shuttles = list()
	shuttle_reports = list()
	chronicle = list()
	pending_chronicle_deaths = list()
	contracts = list()
	objectives = list()
	research = null
	validation_errors = list()


/proc/odyssey_ensure_state() as /datum/odyssey_state
	if (!odyssey)
		odyssey = new /datum/odyssey_state
	return odyssey


/proc/odyssey_map_key()
	return GLOB.using_map?.path || GLOB.using_map?.name || "unknown"


/proc/odyssey_meta_path()
	return "[ODYSSEY_DATA_DIR]_[odyssey_map_key()]_campaign.json"


/proc/odyssey_build_persist_index()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/machines = list()
	var/list/structures = list()
	var/list/mechs = list()
	for (var/obj/O in world)
		if (QDELETED(O) || !O.odyssey_persist_id)
			continue
		if (istype(O, /obj/machinery))
			machines[O.odyssey_persist_id] = O
		else if (istype(O, /obj/structure))
			structures[O.odyssey_persist_id] = O
		CHECK_TICK
	for (var/mob/living/exosuit/M in world)
		if (QDELETED(M) || !M.odyssey_persist_id)
			continue
		mechs[M.odyssey_persist_id] = M
		CHECK_TICK
	state.persist_index_machinery = machines
	state.persist_index_structures = structures
	state.persist_index_mechs = mechs
	log_debug("ODYSSEY: persist index machinery=[length(machines)] structures=[length(structures)] mechs=[length(mechs)]")


/proc/odyssey_clear_persist_index()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	state.persist_index_machinery = null
	state.persist_index_structures = null
	state.persist_index_mechs = null


/proc/odyssey_index_get(list/index, id)
	if (!id || !islist(index))
		return null
	var/atom/A = index[id]
	if (QDELETED(A))
		index -= id
		return null
	return A


/proc/odyssey_index_put(list/index, id, atom/A)
	if (!id || !islist(index) || QDELETED(A))
		return
	index[id] = A


/proc/odyssey_index_remove(list/index, id)
	if (!id || !islist(index))
		return
	index -= id
