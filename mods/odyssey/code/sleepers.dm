/// Odyssey sleeper traitors: persisted across shifts, managed instead of vanilla traitor rolls.

/datum/game_mode/post_setup()
	. = ..()
	odyssey_setup_sleepers()
	odyssey_confirm_mercenaries()
	odyssey_confirm_hostile_outsiders()


/datum/antagonist/traitor/can_late_spawn()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.active)
		return FALSE
	return ..()


/// Odyssey owns traitor rolls: drop vanilla traitor templates and autotraitor before they spawn.
/proc/odyssey_prepare_station_antags(datum/game_mode/mode)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(mode))
		return

	additional_antag_types -= MODE_TRAITOR
	if (MODE_TRAITOR in mode.antag_tags)
		mode.antag_tags -= MODE_TRAITOR
		log_game("ODYSSEY: stripped vanilla traitor from [mode.config_tag]; sleepers will assign instead")
	if (MODE_TRAITOR in mode.latejoin_antag_tags)
		mode.latejoin_antag_tags -= MODE_TRAITOR
	if (!length(mode.latejoin_antag_tags))
		mode.round_autoantag = FALSE


/proc/odyssey_prepare_changelings(datum/game_mode/mode)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(mode))
		return
	var/datum/antagonist/ling = GLOB.all_antag_types_[MODE_CHANGELING]
	if (!istype(ling))
		return
	if (state.changeling_shift_count < 1)
		state.changeling_shift_count = rand(ODYSSEY_CHANGELING_MIN, ODYSSEY_CHANGELING_MAX)
	ling.initial_spawn_req = ODYSSEY_CHANGELING_MIN
	ling.initial_spawn_target = state.changeling_shift_count
	ling.hard_cap = ODYSSEY_CHANGELING_MAX
	ling.hard_cap_round = ODYSSEY_CHANGELING_MAX
	log_game("ODYSSEY: changeling spawn clamped to [state.changeling_shift_count] ([ODYSSEY_CHANGELING_MIN]-[ODYSSEY_CHANGELING_MAX]) for [mode.config_tag]")


/proc/odyssey_setup_sleepers()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	state.sleeper_midround_done = FALSE
	odyssey_clear_mode_traitors()
	odyssey_reapply_sleepers()
	odyssey_assign_new_sleepers(ODYSSEY_SLEEPER_ROUNDSTART_COUNT)
	addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_try_midround_sleeper), FALSE), ODYSSEY_SLEEPER_MIDROUND_DELAY)
	log_game("ODYSSEY: sleeper setup shift=[state.shift_number] active_sleepers=[odyssey_count_active_sleepers()]")


/proc/odyssey_clear_mode_traitors()
	if (!istype(GLOB.traitors))
		return
	for (var/datum/mind/M in GLOB.traitors.current_antagonists.Copy())
		GLOB.traitors.remove_antagonist(M, FALSE)


/proc/odyssey_count_active_sleepers()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/count = 0
	for (var/key in state.sleepers)
		var/list/entry = state.sleepers[key]
		if (islist(entry) && entry["status"] == ODYSSEY_SLEEPER_STATUS_ACTIVE)
			count++
	return count


/proc/odyssey_count_sierra_crew()
	var/count = 0
	for (var/mob/living/carbon/human/H in GLOB.player_list)
		if (!istype(H) || H.stat == DEAD || !H.mind || !H.client)
			continue
		var/turf/T = get_turf(H)
		if (!T || !isStationLevel(T.z))
			continue
		var/datum/job/job = SSjobs.get_by_title(H.mind.assigned_role)
		if (job && !job.create_record)
			continue
		count++
	return count


/proc/odyssey_find_human_by_roster_key(key)
	if (!key)
		return null
	for (var/mob/living/carbon/human/H in GLOB.player_list)
		if (!istype(H) || H.stat == DEAD)
			continue
		var/player_ckey = character_persist_ckey_of(H)
		var/slot = character_persist_slot_of(H)
		if (!player_ckey || !slot)
			continue
		if (odyssey_roster_key(player_ckey, slot) == key)
			return H
	return null


/proc/odyssey_sleeper_pref_rank(mob/living/carbon/human/H)
	if (!istype(H) || !H.client?.prefs)
		return 0
	var/datum/preferences/prefs = H.client.prefs
	if (MODE_TRAITOR in prefs.be_special_role)
		return 2
	if (MODE_TRAITOR in prefs.may_be_special_role)
		return 1
	return 0


/proc/odyssey_sleeper_candidates()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/high = list()
	var/list/low = list()
	for (var/mob/living/carbon/human/H in GLOB.player_list)
		if (!istype(H) || H.stat == DEAD || !H.mind || !H.client)
			continue
		var/turf/T = get_turf(H)
		if (!T || !isStationLevel(T.z))
			continue
		var/player_ckey = character_persist_ckey_of(H)
		var/slot = character_persist_slot_of(H)
		if (!player_ckey || !slot)
			continue
		var/key = odyssey_roster_key(player_ckey, slot)
		var/list/existing = state.sleepers[key]
		if (islist(existing) && existing["status"] == ODYSSEY_SLEEPER_STATUS_ACTIVE)
			continue
		if (H.mind in GLOB.traitors.current_antagonists)
			continue
		if (player_is_antag(H.mind))
			continue
		var/rank = odyssey_sleeper_pref_rank(H)
		if (!rank)
			continue
		if (!GLOB.traitors.can_become_antag(H.mind))
			continue
		if (rank >= 2)
			high += H.mind
		else
			low += H.mind
	return high + low


/proc/odyssey_register_sleeper(mob/living/carbon/human/H, source = "roundstart")
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(H))
		return FALSE
	var/player_ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!player_ckey || !slot)
		return FALSE
	var/key = odyssey_roster_key(player_ckey, slot)
	state.sleepers[key] = list(
		"ckey" = player_ckey,
		"slot" = slot,
		"name" = H.real_name,
		"status" = ODYSSEY_SLEEPER_STATUS_ACTIVE,
		"assigned_shift" = state.shift_number,
		"source" = source
	)
	return TRUE


/proc/odyssey_mark_sleeper_dead(player_ckey, slot, reason)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !player_ckey || !slot)
		return FALSE
	var/key = odyssey_roster_key(player_ckey, slot)
	var/list/entry = state.sleepers[key]
	if (!islist(entry))
		return FALSE
	entry["status"] = ODYSSEY_SLEEPER_STATUS_DEAD
	entry["death_shift"] = state.shift_number
	entry["death_reason"] = reason
	state.sleepers[key] = entry
	log_game("ODYSSEY: sleeper dead [key] reason=[reason]")
	return TRUE


/proc/odyssey_greet_sleeper(mob/living/carbon/human/H, returning = FALSE)
	if (!istype(H))
		return
	if (returning)
		to_chat(H, SPAN_DANGER(FONT_LARGE("Вы снова на связи. Ваш статус спящего агента Одиссеи сохранён.")))
	else
		to_chat(H, SPAN_DANGER(FONT_LARGE("Вы спящий агент Синдиката на борту Сьерры.")))
	to_chat(H, SPAN_NOTICE("Ваши задачи относятся ко всей кампании Одиссеи, а не только к этой смене. Пока вас не разоблачили и не убили, статус перейдёт со следующей сменой, если вы зайдёте той же куклой."))
	to_chat(H, SPAN_NOTICE("Опциональные цели на смену по-прежнему можно брать через Get Objective. Главное — выжить и продвигать интересы Синдиката на протяжении Одиссеи."))


/proc/odyssey_make_sleeper(datum/mind/player, source, returning = FALSE)
	if (!istype(player) || !ishuman(player.current))
		return FALSE
	if (!GLOB.traitors.add_antagonist(player, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE))
		return FALSE
	var/mob/living/carbon/human/H = player.current
	odyssey_register_sleeper(H, source)
	odyssey_greet_sleeper(H, returning)
	log_and_message_admins("ODYSSEY sleeper ([source][returning ? ", returning" : ""]): [key_name(player.current)]")
	return TRUE


/proc/odyssey_reapply_sleepers()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/reapplied = 0
	for (var/key in state.sleepers)
		var/list/entry = state.sleepers[key]
		if (!islist(entry) || entry["status"] != ODYSSEY_SLEEPER_STATUS_ACTIVE)
			continue
		var/mob/living/carbon/human/H = odyssey_find_human_by_roster_key(key)
		if (!istype(H) || !H.mind)
			continue
		if (H.mind in GLOB.traitors.current_antagonists)
			continue
		if (player_is_antag(H.mind))
			log_game("ODYSSEY: skip sleeper reapply for [key], already antag")
			continue
		if (odyssey_make_sleeper(H.mind, "reapply", TRUE))
			reapplied++
	log_game("ODYSSEY: reapplied [reapplied] sleepers")
	return reapplied


/proc/odyssey_assign_new_sleepers(count)
	if (count < 1)
		return 0
	var/list/candidates = odyssey_sleeper_candidates()
	if (!length(candidates))
		log_game("ODYSSEY: no sleeper candidates for [count] new assignment(s)")
		return 0
	var/assigned = 0
	candidates = shuffle(candidates)
	for (var/i = 1 to min(count, length(candidates)))
		var/datum/mind/M = candidates[i]
		if (odyssey_make_sleeper(M, "new"))
			assigned++
	log_game("ODYSSEY: assigned [assigned]/[count] new sleeper(s)")
	return assigned


/proc/odyssey_try_midround_sleeper(retrying = FALSE)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || state.sleeper_midround_done)
		return
	if (GAME_STATE < RUNLEVEL_GAME)
		return
	var/crew = odyssey_count_sierra_crew()
	if (crew <= ODYSSEY_SLEEPER_CREW_MIDROUND_THRESHOLD)
		if (!retrying)
			addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_try_midround_sleeper), TRUE), ODYSSEY_SLEEPER_MIDROUND_RETRY - ODYSSEY_SLEEPER_MIDROUND_DELAY)
			log_game("ODYSSEY: midround sleeper deferred, crew=[crew] threshold=[ODYSSEY_SLEEPER_CREW_MIDROUND_THRESHOLD]")
		else
			state.sleeper_midround_done = TRUE
			log_game("ODYSSEY: midround sleeper skipped, crew=[crew] still below threshold")
		return
	state.sleeper_midround_done = TRUE
	var/assigned = odyssey_assign_new_sleepers(1)
	log_game("ODYSSEY: midround sleeper attempt crew=[crew] assigned=[assigned]")


/proc/odyssey_sync_sleepers_for_save()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	for (var/key in state.sleepers)
		var/list/entry = state.sleepers[key]
		if (!islist(entry) || entry["status"] != ODYSSEY_SLEEPER_STATUS_ACTIVE)
			continue
		var/list/roster_entry = state.roster[key]
		if (islist(roster_entry) && roster_entry["status"] == "dead")
			entry["status"] = ODYSSEY_SLEEPER_STATUS_DEAD
			entry["death_reason"] = roster_entry["death_reason"] || "roster_dead"
			entry["death_shift"] = state.shift_number
			state.sleepers[key] = entry
			continue
		var/mob/living/carbon/human/H = odyssey_find_human_by_roster_key(key)
		if (!istype(H) || H.stat == DEAD || !(H.mind in GLOB.traitors.current_antagonists))
			// Not currently playing as traitor this shift, but keep active for next join with same doll
			// unless they died.
			if (istype(H) && H.stat == DEAD)
				entry["status"] = ODYSSEY_SLEEPER_STATUS_DEAD
				entry["death_reason"] = "death"
				entry["death_shift"] = state.shift_number
				state.sleepers[key] = entry
			continue
		entry["name"] = H.real_name
		state.sleepers[key] = entry
