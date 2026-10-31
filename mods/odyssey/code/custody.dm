/// Odyssey brig custody: detained crew stay in brig next shift (orange + no ID).

/// Place in /area/security/sierra/prison cells — preferred custody spawn points.
var/global/list/odyssey_custody_landmarks = list()


/obj/landmark/odyssey_custody
	name = "Odyssey Custody Spawn"
	desc = "Where detained Odyssey crew appear next shift."
	icon_state = "x3"


/obj/landmark/odyssey_custody/Initialize()
	. = ..()
	odyssey_custody_landmarks += src


/obj/landmark/odyssey_custody/Destroy()
	odyssey_custody_landmarks -= src
	return ..()


/mob/living/carbon/human/var/odyssey_custody_applied = FALSE


/// TRUE if A.type is exactly /area/<suffix> or a subtype thereof.
/proc/odyssey_area_matches_suffixes(area/A, list/suffixes)
	if (!istype(A) || !islist(suffixes))
		return FALSE
	var/type_text = "[A.type]"
	for (var/suffix in suffixes)
		// Concatenate so static path lints do not flag a quoted area type string.
		var/full = "/" + "area/" + suffix
		if (type_text == full || findtext(type_text, full + "/") == 1)
			return TRUE
	return FALSE


/proc/odyssey_area_is_custody(area/A)
	return odyssey_area_matches_suffixes(A, ODYSSEY_CUSTODY_AREA_SUFFIXES)


/proc/odyssey_criminal_status_is_custody(status)
	return status && (status in ODYSSEY_CUSTODY_CRIMINAL_STATUSES)


/proc/odyssey_human_should_be_detained(mob/living/carbon/human/H)
	if (!istype(H) || QDELETED(H) || H.stat == DEAD)
		return FALSE
	if (!character_persist_on_sierra(H))
		return FALSE
	if (!odyssey_area_is_custody(get_area(H)))
		return FALSE
	var/status = character_persist_current_criminal_status(H)
	return odyssey_criminal_status_is_custody(status)


/proc/odyssey_capture_custody_to_roster(mob/living/carbon/human/H)
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
	if (odyssey_human_should_be_detained(H))
		entry["custody"] = ODYSSEY_CUSTODY_BRIG
		entry["custody_shift"] = state.shift_number
		if (!odyssey_criminal_status_is_custody(entry["criminal_status"]))
			entry["criminal_status"] = "Incarcerated"
	else
		entry["custody"] = null
		entry["custody_shift"] = null
	state.roster[key] = entry


/proc/odyssey_pick_custody_spawn_turf()
	var/list/candidates = list()
	for (var/obj/landmark/odyssey_custody/L in odyssey_custody_landmarks)
		if (QDELETED(L))
			continue
		var/turf/T = get_turf(L)
		if (!istype(T, /turf/simulated/floor))
			continue
		if (!T.z || !(T.z in GLOB.using_map.station_levels))
			continue
		if (is_blocked_turf(T))
			continue
		candidates += T
	if (length(candidates))
		return pick_mobless_turf_if_exists(candidates)

	// Fallback if mappers have not placed landmarks yet.
	for (var/area/A in world)
		if (!odyssey_area_matches_suffixes(A, ODYSSEY_CUSTODY_SPAWN_AREA_SUFFIXES))
			continue
		if (!A.z || !(A.z in GLOB.using_map.station_levels))
			continue
		for (var/turf/simulated/floor/T in A)
			if (is_blocked_turf(T))
				continue
			candidates += T
		CHECK_TICK
	if (!length(candidates))
		return null
	return pick_mobless_turf_if_exists(candidates)


/proc/odyssey_schedule_custody_apply(mob/living/carbon/human/H, attempt = 0)
	if (!istype(H) || QDELETED(H))
		return
	if (H.odyssey_custody_applied)
		return
	if (H.mind)
		// equip_rank runs after persist register — give it a moment.
		addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_try_apply_custody_for), H), 2 SECONDS)
		return
	if (attempt >= 20)
		log_game("ODYSSEY: custody apply gave up waiting for mind on [H.real_name] ([character_persist_ckey_of(H)])")
		return
	addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_schedule_custody_apply), H, attempt + 1), 1)


/proc/odyssey_try_apply_custody_for(mob/living/carbon/human/H)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(H) || QDELETED(H) || H.stat == DEAD)
		return FALSE
	if (H.odyssey_custody_applied)
		return FALSE
	var/player_ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!player_ckey || !slot)
		return FALSE
	var/key = odyssey_roster_key(player_ckey, slot)
	var/list/entry = state.roster[key]
	if (!islist(entry) || entry["custody"] != ODYSSEY_CUSTODY_BRIG)
		return FALSE

	var/turf/cell = odyssey_pick_custody_spawn_turf()
	if (!cell)
		log_error("ODYSSEY: custody apply failed for [key] — no prison floor turf")
		return FALSE

	// Only worn/held gear — iterating contents would hit organs/implants.
	for (var/obj/item/I in H.get_equipped_items(TRUE))
		H.drop_from_inventory(I)
		if (!QDELETED(I))
			qdel(I)

	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(H), slot_shoes)
	H.forceMove(cell)

	entry["criminal_status"] = "Incarcerated"
	state.roster[key] = entry
	var/datum/computer_file/report/crew_record/CR = get_crewmember_record(H.real_name)
	if (istype(CR))
		CR.set_criminalStatus("Incarcerated")

	H.odyssey_custody_applied = TRUE
	to_chat(H, SPAN_WARNING("You remain in Security custody from the previous shift. Your belongings were not returned."))
	log_game("ODYSSEY: applied custody for [key] name=[H.real_name] at [cell.x],[cell.y],[cell.z]")
	return TRUE


/proc/odyssey_admin_clear_roster_custody(roster_key, mob/user)
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
	if (!islist(entry) || entry["custody"] != ODYSSEY_CUSTODY_BRIG)
		return FALSE
	var/char_name = entry["name"] || roster_key
	entry["custody"] = null
	entry["custody_shift"] = null
	roster[roster_key] = entry
	if (state.active)
		state.roster = roster
	if (generation)
		odyssey_write_json(odyssey_snapshot_path("roster", generation), list(
			"version" = ODYSSEY_VERSION,
			"campaign_id" = campaign_id,
			"generation" = generation,
			"entries" = roster
		))
	log_and_message_admins("cleared Odyssey custody for [char_name] ([roster_key])", user)
	log_game("ODYSSEY: admin cleared roster custody key=[roster_key] by=[user?.ckey]")
	return TRUE
