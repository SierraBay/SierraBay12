/// Odyssey changelings: persist across shifts only if alive on Sierra at round save.

/proc/odyssey_prepare_changelings(datum/game_mode/mode)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(mode))
		return
	var/datum/antagonist/ling = GLOB.all_antag_types_[MODE_CHANGELING]
	if (!istype(ling))
		return
	if (state.changeling_shift_count < 1)
		state.changeling_shift_count = rand(ODYSSEY_CHANGELING_MIN, ODYSSEY_CHANGELING_MAX)
	var/persisted = odyssey_count_active_changelings()
	var/new_slots = max(0, state.changeling_shift_count - persisted)
	ling.initial_spawn_req = new_slots > 0 ? min(1, new_slots) : 0
	ling.initial_spawn_target = new_slots
	ling.hard_cap = ODYSSEY_CHANGELING_MAX
	ling.hard_cap_round = ODYSSEY_CHANGELING_MAX
	log_game("ODYSSEY: changeling spawn target=[new_slots] (rolled=[state.changeling_shift_count] persisted=[persisted], cap [ODYSSEY_CHANGELING_MAX]) for [mode.config_tag]")


/proc/odyssey_setup_changelings()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	odyssey_register_current_changelings("roundstart")
	odyssey_reapply_changelings()
	addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_reapply_changelings)), 5 SECONDS)
	log_game("ODYSSEY: changeling setup shift=[state.shift_number] active=[odyssey_count_active_changelings()] saved=[length(state.changelings)]")


/// JSON [] loads as a plain list; keep a keyed map of roster_key → entry.
/proc/odyssey_normalize_changelings(list/raw)
	var/list/out = list()
	if (!islist(raw))
		return out
	for (var/key in raw)
		var/list/entry
		if (istext(key) && islist(raw[key]))
			entry = raw[key]
			out[key] = entry
			continue
		if (islist(key))
			entry = key
		else if (islist(raw[key]))
			entry = raw[key]
		else
			continue
		var/ckey = entry["ckey"]
		var/slot = entry["slot"]
		if (!ckey || !slot)
			continue
		out[odyssey_roster_key(ckey, slot)] = entry
	return out


/proc/odyssey_count_active_changelings()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/count = 0
	for (var/key in state.changelings)
		var/list/entry = state.changelings[key]
		if (islist(entry) && entry["status"] == ODYSSEY_CHANGELING_STATUS_ACTIVE)
			count++
	return count


/proc/odyssey_find_human_by_roster_key_any(key)
	if (!key)
		return null
	for (var/mob/living/carbon/human/H in GLOB.human_mobs)
		if (!istype(H) || QDELETED(H))
			continue
		var/player_ckey = character_persist_ckey_of(H)
		var/slot = character_persist_slot_of(H)
		if (!player_ckey || !slot)
			continue
		if (odyssey_roster_key(player_ckey, slot) == key)
			return H
	return null


/proc/odyssey_register_changeling(mob/living/carbon/human/H, source = "roundstart")
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(H))
		return FALSE
	var/player_ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!player_ckey || !slot)
		log_game("ODYSSEY: changeling register failed for [H.real_name]: missing ckey/slot")
		return FALSE
	if (!islist(state.changelings))
		state.changelings = list()
	var/key = odyssey_roster_key(player_ckey, slot)
	state.changelings[key] = list(
		"ckey" = player_ckey,
		"slot" = slot,
		"name" = H.real_name,
		"status" = ODYSSEY_CHANGELING_STATUS_ACTIVE,
		"assigned_shift" = state.shift_number,
		"source" = source
	)
	log_game("ODYSSEY: changeling registered [key] source=[source] active=[odyssey_count_active_changelings()]")
	return TRUE


/proc/odyssey_mark_changeling_lost(player_ckey, slot, reason)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !player_ckey || !slot)
		return FALSE
	var/key = odyssey_roster_key(player_ckey, slot)
	var/list/entry = state.changelings[key]
	if (!islist(entry) || entry["status"] != ODYSSEY_CHANGELING_STATUS_ACTIVE)
		return FALSE
	entry["status"] = ODYSSEY_CHANGELING_STATUS_LOST
	entry["lost_shift"] = state.shift_number
	entry["lost_reason"] = reason
	state.changelings[key] = entry
	log_game("ODYSSEY: changeling lost [key] reason=[reason]")
	return TRUE


/proc/odyssey_greet_changeling(mob/living/carbon/human/H, returning = FALSE)
	if (!istype(H))
		return
	if (returning)
		to_chat(H, SPAN_DANGER(FONT_LARGE("Вы снова чувствуете рой. Ваш статус генокрада Одиссеи сохранён.")))
	else
		to_chat(H, SPAN_DANGER(FONT_LARGE("Вы генокрад на борту Сьерры.")))
	to_chat(H, SPAN_NOTICE("Пока вы живы и остаётесь на Сьерре к концу смены, статус перейдёт со следующей сменой на той же кукле. Уход со станции или смерть снимают перенос."))


/proc/odyssey_make_changeling(datum/mind/player, source, returning = FALSE)
	if (!istype(player) || !ishuman(player.current))
		log_game("ODYSSEY: make_changeling failed ([source]): invalid mind/mob")
		return FALSE
	if (!GLOB.changelings.add_antagonist(player, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE))
		log_game("ODYSSEY: make_changeling failed ([source]): add_antagonist rejected [player.key]")
		return FALSE
	var/mob/living/carbon/human/H = player.current
	if (!odyssey_register_changeling(H, source))
		log_game("ODYSSEY: make_changeling ([source]) antag set but register failed for [key_name(H)]")
	odyssey_greet_changeling(H, returning)
	log_and_message_admins("ODYSSEY changeling ([source][returning ? ", returning" : ""]): [key_name(player.current)]")
	return TRUE


/proc/odyssey_register_current_changelings(source = "roundstart")
	if (!istype(GLOB.changelings))
		return 0
	var/registered = 0
	for (var/datum/mind/M in GLOB.changelings.current_antagonists)
		if (!ishuman(M.current))
			continue
		var/mob/living/carbon/human/H = M.current
		if (H.stat == DEAD)
			continue
		if (odyssey_register_changeling(H, source))
			registered++
	return registered


/proc/odyssey_reapply_changelings()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/reapplied = 0
	for (var/key in state.changelings)
		var/list/entry = state.changelings[key]
		if (!islist(entry) || entry["status"] != ODYSSEY_CHANGELING_STATUS_ACTIVE)
			continue
		var/mob/living/carbon/human/H = odyssey_find_human_by_roster_key(key)
		if (!istype(H) || !H.mind)
			continue
		if (H.mind in GLOB.changelings.current_antagonists)
			odyssey_register_changeling(H, "reapply_confirm")
			continue
		if (player_is_antag(H.mind))
			log_game("ODYSSEY: skip changeling reapply for [key], already antag")
			continue
		if (odyssey_make_changeling(H.mind, "reapply", TRUE))
			reapplied++
	log_game("ODYSSEY: reapplied [reapplied] changelings")
	return reapplied


/proc/odyssey_schedule_changeling_reapply(mob/living/carbon/human/H, attempt = 0)
	if (!istype(H) || QDELETED(H))
		return
	if (H.mind)
		odyssey_try_reapply_changeling_for(H)
		return
	if (attempt >= 20)
		log_game("ODYSSEY: changeling reapply gave up waiting for mind on [H.real_name] ([character_persist_ckey_of(H)])")
		return
	addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_schedule_changeling_reapply), H, attempt + 1), 1)


/proc/odyssey_try_reapply_changeling_for(mob/living/carbon/human/H)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(H) || QDELETED(H) || H.stat == DEAD)
		return FALSE
	if (!H.mind)
		// Do not restart the attempt counter — the schedule_* waiter owns retries.
		return FALSE
	var/player_ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!player_ckey || !slot)
		return FALSE
	var/key = odyssey_roster_key(player_ckey, slot)
	var/list/entry = state.changelings[key]
	if (!islist(entry) || entry["status"] != ODYSSEY_CHANGELING_STATUS_ACTIVE)
		return FALSE
	if (H.mind in GLOB.changelings.current_antagonists)
		return FALSE
	if (player_is_antag(H.mind))
		log_game("ODYSSEY: skip latejoin changeling reapply for [key], already antag")
		return FALSE
	return odyssey_make_changeling(H.mind, "latejoin_reapply", TRUE)


/// Persist only changelings who are alive on Sierra at save time.
/proc/odyssey_sync_changelings_for_save()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	if (!islist(state.changelings))
		state.changelings = list()

	var/list/kept = list()
	for (var/mob/living/carbon/human/H in GLOB.human_mobs)
		if (!istype(H) || QDELETED(H) || H.stat == DEAD || !H.mind)
			continue
		if (!(H.mind in GLOB.changelings.current_antagonists))
			continue
		if (!character_persist_on_sierra(H))
			var/player_ckey = character_persist_ckey_of(H)
			var/slot = character_persist_slot_of(H)
			if (player_ckey && slot)
				odyssey_mark_changeling_lost(player_ckey, slot, "off_sierra")
			continue
		if (odyssey_register_changeling(H, "save_sierra"))
			kept[odyssey_roster_key(character_persist_ckey_of(H), character_persist_slot_of(H))] = TRUE

	for (var/key in state.changelings)
		var/list/entry = state.changelings[key]
		if (!islist(entry) || entry["status"] != ODYSSEY_CHANGELING_STATUS_ACTIVE)
			continue
		if (kept[key])
			continue
		var/list/roster_entry = state.roster[key]
		if (islist(roster_entry) && roster_entry["status"] == "dead")
			entry["status"] = ODYSSEY_CHANGELING_STATUS_LOST
			entry["lost_reason"] = roster_entry["death_reason"] || "roster_dead"
			entry["lost_shift"] = state.shift_number
			state.changelings[key] = entry
			continue
		var/mob/living/carbon/human/H = odyssey_find_human_by_roster_key_any(key)
		if (istype(H) && H.stat == DEAD)
			entry["status"] = ODYSSEY_CHANGELING_STATUS_LOST
			entry["lost_reason"] = "death"
			entry["lost_shift"] = state.shift_number
			state.changelings[key] = entry
			continue
		// Absent from Sierra (or round) at save — do not carry over.
		entry["status"] = ODYSSEY_CHANGELING_STATUS_LOST
		entry["lost_reason"] = "not_on_sierra_at_save"
		entry["lost_shift"] = state.shift_number
		state.changelings[key] = entry

	log_game("ODYSSEY: changeling sync for save kept=[length(kept)] active=[odyssey_count_active_changelings()]")
