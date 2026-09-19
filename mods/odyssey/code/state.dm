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
	var/next_object_id = 1
	/// Campaign sleeper traitors keyed by "ckey|slot".
	var/list/sleepers
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
	/// Shuttle names left behind off Sierra (Guppy/Charon/Petrov/Phaethon/escape pods).
	var/list/abandoned_shuttles
	/// Last validation errors shown in the admin panel.
	var/list/validation_errors


/datum/odyssey_state/New()
	..()
	sector_graph = list()
	route_history = list()
	roster = list()
	sleepers = list()
	abandoned_shuttles = list()
	validation_errors = list()


/proc/odyssey_ensure_state() as /datum/odyssey_state
	if (!odyssey)
		odyssey = new /datum/odyssey_state
	return odyssey


/proc/odyssey_map_key()
	return GLOB.using_map?.path || GLOB.using_map?.name || "unknown"


/proc/odyssey_meta_path()
	return "[ODYSSEY_DATA_DIR]_[odyssey_map_key()]_campaign.json"
