/proc/odyssey_roster_key(player_ckey, slot)
	return "[ckey(player_ckey)]|[slot]"


/proc/odyssey_campaign_matches(campaign_id)
	if (!campaign_id)
		return FALSE
	var/list/meta = odyssey_load_meta()
	return islist(meta) && meta["active"] && (!meta["status"] || meta["status"] == ODYSSEY_STATUS_ACTIVE) && campaign_id == meta["campaign_id"]


/proc/odyssey_load_roster()
	var/list/meta = odyssey_load_meta()
	var/list/data = odyssey_read_json(odyssey_snapshot_path("roster", meta?["generation"]))
	if (!islist(data) || !islist(data["entries"]))
		return list()
	return data["entries"]


/proc/odyssey_register_character(mob/living/carbon/human/H)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(H))
		return FALSE
	var/player_ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!player_ckey || !slot)
		return FALSE
	var/key = odyssey_roster_key(player_ckey, slot)
	var/list/entry = state.roster[key]
	if (islist(entry) && entry["status"] == "dead")
		return FALSE
	if (!islist(entry))
		entry = list()
	entry["campaign_id"] = state.campaign_id
	entry["ckey"] = player_ckey
	entry["slot"] = slot
	entry["name"] = H.real_name
	entry["status"] = "alive"
	entry["joined_shift"] = entry["joined_shift"] || state.shift_number
	entry["last_seen_shift"] = state.shift_number
	var/job_title = H.mind?.role_alt_title || H.mind?.assigned_role || H.job || "Unknown"
	entry["job"] = job_title
	var/list/seen = entry["seen_shifts"]
	if (!islist(seen))
		seen = list()
	if (!(state.shift_number in seen))
		seen += state.shift_number
	entry["seen_shifts"] = seen
	var/list/shift_jobs = entry["shift_jobs"]
	if (!islist(shift_jobs))
		shift_jobs = list()
	shift_jobs["[state.shift_number]"] = job_title
	entry["shift_jobs"] = shift_jobs
	state.roster[key] = entry
	odyssey_try_reapply_sleeper_for(H)
	return TRUE


/proc/odyssey_try_reapply_sleeper_for(mob/living/carbon/human/H)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(H) || !H.mind || H.stat == DEAD)
		return FALSE
	var/player_ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!player_ckey || !slot)
		return FALSE
	var/key = odyssey_roster_key(player_ckey, slot)
	var/list/entry = state.sleepers[key]
	if (!islist(entry) || entry["status"] != ODYSSEY_SLEEPER_STATUS_ACTIVE)
		return FALSE
	if (H.mind in GLOB.traitors.current_antagonists)
		return FALSE
	return odyssey_make_sleeper(H.mind, "latejoin_reapply", TRUE)


/proc/odyssey_mark_character_dead(mob/living/carbon/human/H, reason)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(H) || character_persist_is_offstation_antag(H))
		return FALSE
	var/player_ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!player_ckey || !slot)
		return FALSE
	var/key = odyssey_roster_key(player_ckey, slot)
	var/list/entry = state.roster[key]
	if (!islist(entry))
		entry = list(
			"campaign_id" = state.campaign_id,
			"ckey" = player_ckey,
			"slot" = slot,
			"name" = H.real_name,
			"joined_shift" = state.shift_number
		)
	entry["status"] = "dead"
	entry["death_shift"] = state.shift_number
	entry["death_reason"] = reason
	entry["died_at"] = time2text(world.realtime, "YYYY-MM-DD hh:mm")
	entry["name"] = H.real_name || entry["name"]
	var/job_title = H.mind?.role_alt_title || H.mind?.assigned_role || H.job || entry["job"]
	if (job_title)
		entry["job"] = job_title
		var/list/shift_jobs = entry["shift_jobs"]
		if (!islist(shift_jobs))
			shift_jobs = list()
		shift_jobs["[state.shift_number]"] = job_title
		entry["shift_jobs"] = shift_jobs
	var/list/seen = entry["seen_shifts"]
	if (!islist(seen))
		seen = list()
	if (!(state.shift_number in seen))
		seen += state.shift_number
	entry["seen_shifts"] = seen
	state.roster[key] = entry
	odyssey_mark_sleeper_dead(player_ckey, slot, reason)
	log_game("ODYSSEY: character died [player_ckey] slot=[slot] name=[H.real_name] shift=[state.shift_number]")
	// Journal the tombstone immediately so a crash cannot resurrect the slot.
	odyssey_write_json(odyssey_snapshot_path("roster", state.save_generation), list(
		"version" = ODYSSEY_VERSION,
		"campaign_id" = state.campaign_id,
		"generation" = state.save_generation,
		"entries" = state.roster
	))
	return TRUE


/proc/odyssey_slot_locked(player_ckey, slot)
	if (!player_ckey || !slot)
		return FALSE
	var/key = odyssey_roster_key(player_ckey, slot)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/entry
	if (state.active && state.campaign_id)
		entry = state.roster?[key]
	else
		var/list/meta = odyssey_load_meta()
		if (!islist(meta) || !meta["active"] || (meta["status"] && meta["status"] != ODYSSEY_STATUS_ACTIVE))
			return FALSE
		var/list/roster = odyssey_load_roster()
		entry = roster[key]
	return islist(entry) && entry["status"] == "dead"


/proc/odyssey_campaign_crew_lost()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !length(state.roster))
		return FALSE
	for (var/key in state.roster)
		var/list/entry = state.roster[key]
		if (islist(entry) && entry["status"] == "alive")
			return FALSE
	return TRUE


/proc/odyssey_roster_seen_shifts(list/entry)
	if (!islist(entry))
		return list()
	var/list/seen = entry["seen_shifts"]
	if (islist(seen) && length(seen))
		var/list/normalized = list()
		for (var/value in seen)
			var/shift = text2num(value)
			if (!isnum(shift))
				shift = value
			if (isnum(shift) && !(shift in normalized))
				normalized += shift
		return normalized
	var/joined = text2num(entry["joined_shift"]) || 1
	var/last = text2num(entry["last_seen_shift"]) || joined
	var/list/fallback = list()
	for (var/shift = joined to last)
		fallback += shift
	return fallback


/proc/odyssey_roster_job_for_shift(list/entry, shift)
	if (!islist(entry))
		return "Unknown"
	var/list/shift_jobs = entry["shift_jobs"]
	if (islist(shift_jobs) && shift_jobs["[shift]"])
		return shift_jobs["[shift]"]
	return entry["job"] || "Unknown"


/proc/odyssey_html_past_crew_manifest(monochrome)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || state.shift_number <= 1 || !length(state.roster))
		return ""

	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;width:100%;}
		.manifest td, th {border:1px solid [monochrome?"black":"black; background-color:#272727; color:white"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #40628a; color:white"]}
		.manifest tr.head th { background-color: #013D3B; }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #373737; color:white"]}
	</style></head>
	"}
	dat += "<h3>Previous Odyssey Shifts</h3>"
	var/any_shift = FALSE
	for (var/shift = 1 to state.shift_number - 1)
		var/list/rows = list()
		for (var/key in state.roster)
			var/list/entry = state.roster[key]
			if (!islist(entry))
				continue
			if (!(shift in odyssey_roster_seen_shifts(entry)))
				continue
			rows += entry
		if (!length(rows))
			continue
		any_shift = TRUE
		dat += "<table class='manifest' width='350px'>"
		dat += "<tr class='head'><th colspan='3'>Shift [shift]</th></tr>"
		dat += "<tr><th>Name</th><th>Position</th><th>Status</th></tr>"
		for (var/list/entry in rows)
			var/status = "Active"
			var/death_shift = text2num(entry["death_shift"])
			if (entry["status"] == "dead" && death_shift && death_shift <= shift)
				status = "Deceased"
			dat += "<tr class='candystripe'><td>[html_encode("[entry["name"] || "Unknown"]")]</td><td>[html_encode("[odyssey_roster_job_for_shift(entry, shift)]")]</td><td>[status]</td></tr>"
		dat += "</table><br>"
	if (!any_shift)
		return ""
	dat = replacetext(dat, "\n", "")
	dat = replacetext(dat, "\t", "")
	return dat


/proc/odyssey_apply_roster_records_to_human(mob/living/carbon/human/H, list/entry)
	if (!istype(H) || !islist(entry))
		return
	if (entry["sec_record"])
		H.sec_record = entry["sec_record"]
	if (entry["gen_record"])
		H.gen_record = entry["gen_record"]
	if (entry["med_record"])
		H.med_record = entry["med_record"]


/proc/odyssey_apply_roster_records_to_crew_record(datum/computer_file/report/crew_record/CR, mob/living/carbon/human/H)
	if (!istype(CR) || !istype(H))
		return
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	var/player_ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!player_ckey || !slot)
		return
	var/list/entry = state.roster[odyssey_roster_key(player_ckey, slot)]
	if (!islist(entry))
		return
	if (entry["sec_record"])
		CR.set_secRecord(entry["sec_record"])
	if (entry["gen_record"])
		CR.set_emplRecord(entry["gen_record"])
	if (entry["med_record"])
		CR.set_medRecord(entry["med_record"])
	var/status = entry["physical_status"]
	if (status && (status in GLOB.physical_statuses))
		CR.set_status(status)
	var/sec_status = entry["criminal_status"]
	if (sec_status && (sec_status in GLOB.security_statuses))
		CR.set_criminalStatus(sec_status)


/proc/odyssey_capture_records_to_roster(mob/living/carbon/human/H)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(H))
		return
	var/player_ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!player_ckey || !slot)
		return
	var/key = odyssey_roster_key(player_ckey, slot)
	var/list/entry = state.roster[key]
	if (!islist(entry) || entry["status"] == "dead")
		return
	entry["sec_record"] = character_persist_current_sec_record(H)
	entry["gen_record"] = character_persist_current_gen_record(H)
	entry["med_record"] = character_persist_current_med_record(H)
	var/criminal_status = character_persist_current_criminal_status(H)
	if (criminal_status)
		entry["criminal_status"] = criminal_status
	var/physical_status = character_persist_crew_physical_status(H)
	if (physical_status)
		entry["physical_status"] = physical_status
	state.roster[key] = entry


/proc/odyssey_sync_roster_for_save()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	for (var/mob/living/carbon/human/H in GLOB.human_mobs)
		if (QDELETED(H) || H.stat == DEAD)
			continue
		if (character_persist_is_offstation_antag(H))
			continue
		odyssey_register_character(H)
		odyssey_capture_records_to_roster(H)
