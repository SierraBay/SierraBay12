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


/proc/odyssey_register_character(mob/living/carbon/human/H, try_sleeper = TRUE)
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
	// copy_to/apply_persist runs before mind.transfer_to — defer antag reapply.
	if (try_sleeper)
		odyssey_schedule_sleeper_reapply(H)
		odyssey_schedule_changeling_reapply(H)
	return TRUE


/// copy_to registers the roster entry before mind exists; retry until mind is ready.
/proc/odyssey_schedule_sleeper_reapply(mob/living/carbon/human/H, attempt = 0)
	if (!istype(H) || QDELETED(H))
		return
	if (H.mind)
		odyssey_try_reapply_sleeper_for(H)
		return
	if (attempt >= 20)
		log_game("ODYSSEY: sleeper reapply gave up waiting for mind on [H.real_name] ([character_persist_ckey_of(H)])")
		return
	addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_schedule_sleeper_reapply), H, attempt + 1), 1)


/proc/odyssey_try_reapply_sleeper_for(mob/living/carbon/human/H)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(H) || QDELETED(H) || H.stat == DEAD)
		return FALSE
	if (!H.mind)
		odyssey_schedule_sleeper_reapply(H)
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
	if (player_is_antag(H.mind))
		log_game("ODYSSEY: skip latejoin sleeper reapply for [key], already antag")
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
	entry["died_at"] = odyssey_ic_timestamp()
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
	odyssey_mark_changeling_lost(player_ckey, slot, reason)
	odyssey_chronicle_note_death(H, reason, job_title)
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


/// Admin: clear Odyssey death tombstone so the same ckey|slot can join again.
/proc/odyssey_admin_clear_roster_death(roster_key, mob/user)
	if (!roster_key)
		return FALSE
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/roster
	var/generation
	var/campaign_id
	if (state.active && state.campaign_id)
		roster = state.roster
		generation = state.save_generation
		campaign_id = state.campaign_id
	else
		var/list/meta = odyssey_load_meta()
		if (!islist(meta) || !meta["active"])
			return FALSE
		generation = meta["generation"]
		campaign_id = meta["campaign_id"]
		roster = odyssey_load_roster()
		if (!islist(roster))
			return FALSE
	var/list/entry = roster[roster_key]
	if (!islist(entry) || entry["status"] != "dead")
		return FALSE
	var/char_name = entry["name"] || roster_key
	entry["status"] = "alive"
	entry["death_shift"] = null
	entry["death_reason"] = null
	entry["died_at"] = null
	roster[roster_key] = entry
	if (state.active)
		state.roster = roster
		odyssey_admin_restore_antags_after_revive(roster_key)
	if (generation)
		odyssey_write_json(odyssey_snapshot_path("roster", generation), list(
			"version" = ODYSSEY_VERSION,
			"campaign_id" = campaign_id,
			"generation" = generation,
			"entries" = roster
		))
	log_and_message_admins("cleared Odyssey death for [char_name] ([roster_key])", user)
	log_game("ODYSSEY: admin cleared roster death key=[roster_key] by=[user?.ckey]")
	return TRUE


/proc/odyssey_admin_restore_antags_after_revive(roster_key)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !roster_key)
		return
	var/list/sleeper = state.sleepers?[roster_key]
	if (islist(sleeper) && sleeper["status"] == ODYSSEY_SLEEPER_STATUS_DEAD)
		sleeper["status"] = ODYSSEY_SLEEPER_STATUS_ACTIVE
		sleeper["death_shift"] = null
		sleeper["death_reason"] = null
		state.sleepers[roster_key] = sleeper
		log_game("ODYSSEY: admin restored sleeper [roster_key] after roster revive")
	var/list/cling = state.changelings?[roster_key]
	if (islist(cling) && cling["status"] == ODYSSEY_CHANGELING_STATUS_LOST)
		cling["status"] = ODYSSEY_CHANGELING_STATUS_ACTIVE
		cling["lost_shift"] = null
		cling["lost_reason"] = null
		state.changelings[roster_key] = cling
		log_game("ODYSSEY: admin restored changeling [roster_key] after roster revive")


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


/// Past-shift accordion for the crew manifest program.
/// open_shifts / nano_src keep expansion across NanoUI auto-refresh (HTML <details> cannot).
/// Layout uses a flat table + inline styles — nested div/head CSS inside NanoUI becomes a staircase.
/proc/odyssey_html_past_crew_manifest(monochrome, list/open_shifts, datum/nano_module/nano_src)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || state.shift_number <= 1 || !length(state.roster))
		return ""

	var/border = monochrome ? "black" : "#013D3B"
	var/cell_border = monochrome ? "black" : "black; background-color:#272727; color:white"
	var/th_style = monochrome ? "border-top-width:3px" : "background-color:#40628a; color:white"
	var/toggle_style = "display:block;width:100%;box-sizing:border-box;padding:0.45em 0.6em;font-weight:bold;color:white;background:#013D3B;text-decoration:none;border:0;text-align:left"
	var/dat = "<h3>Previous Odyssey Shifts</h3>"
	dat += "<table width='100%' style='border-collapse:collapse;margin:0;padding:0;'>"
	var/any_shift = FALSE
	for (var/shift = 1 to state.shift_number - 1)
		var/list/rows = list()
		for (var/key in state.roster)
			var/list/entry = state.roster[key]
			if (!islist(entry))
				continue
			if (!(shift in odyssey_roster_seen_shifts(entry)))
				continue
			rows += list(entry)
		if (!length(rows))
			continue
		any_shift = TRUE
		var/is_open = islist(open_shifts) && open_shifts["[shift]"]
		var/label = "[is_open ? "▼" : "▶"] Shift [shift] ([length(rows)])"
		dat += "<tr><td style='padding:0 0 0.6em 0;border:1px solid [border];background:[monochrome ? "transparent" : "#1a1a1a"];'>"
		if (istype(nano_src))
			dat += "<a style='[toggle_style]' href='?src=\ref[nano_src];odyssey_toggle_past=[shift]'>[label]</a>"
		else
			dat += "<div style='[toggle_style]'>[label]</div>"
			is_open = TRUE
		if (is_open)
			dat += "<table class='manifest' width='100%' style='border-collapse:collapse;margin:0;'>"
			dat += "<tr><th style='border:1px solid [cell_border];padding:0.25em;[th_style]'>Name</th>"
			dat += "<th style='border:1px solid [cell_border];padding:0.25em;[th_style]'>Position</th>"
			dat += "<th style='border:1px solid [cell_border];padding:0.25em;[th_style]'>Status</th></tr>"
			for (var/list/entry in rows)
				var/status = "Active"
				var/death_shift = text2num(entry["death_shift"])
				if (entry["status"] == "dead" && death_shift && death_shift <= shift)
					status = "Deceased"
				dat += "<tr class='candystripe'><td style='border:1px solid [cell_border];padding:0.25em'>[html_encode("[entry["name"] || "Unknown"]")]</td>"
				dat += "<td style='border:1px solid [cell_border];padding:0.25em'>[html_encode("[odyssey_roster_job_for_shift(entry, shift)]")]</td>"
				dat += "<td style='border:1px solid [cell_border];padding:0.25em'>[status]</td></tr>"
			dat += "</table>"
		dat += "</td></tr>"
	dat += "</table>"
	if (!any_shift)
		return ""
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
		odyssey_register_character(H, FALSE)
		odyssey_capture_records_to_roster(H)
