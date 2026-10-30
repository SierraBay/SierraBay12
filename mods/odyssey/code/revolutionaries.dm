/// Odyssey revolutionaries / loyalists: persist head and converted members across shifts.

/proc/odyssey_normalize_faction_map(list/raw)
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


/proc/odyssey_count_active_faction(list/store)
	var/count = 0
	for (var/key in store)
		var/list/entry = store[key]
		if (islist(entry) && entry["status"] == ODYSSEY_FACTION_STATUS_ACTIVE)
			count++
	return count


/proc/odyssey_count_active_faction_heads(list/store)
	var/count = 0
	for (var/key in store)
		var/list/entry = store[key]
		if (!islist(entry) || entry["status"] != ODYSSEY_FACTION_STATUS_ACTIVE)
			continue
		if (entry["rank"] == ODYSSEY_FACTION_RANK_HEAD)
			count++
	return count


/proc/odyssey_faction_rank_of(datum/antagonist/faction, datum/mind/player)
	if (!istype(faction) || !istype(player))
		return ODYSSEY_FACTION_RANK_MEMBER
	if (player in faction.faction_members)
		return ODYSSEY_FACTION_RANK_MEMBER
	return ODYSSEY_FACTION_RANK_HEAD


/proc/odyssey_prepare_revolution(datum/game_mode/mode)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(mode))
		return
	if (istype(GLOB.revs) && ((MODE_REVOLUTIONARY in mode.antag_tags) || (MODE_REVOLUTIONARY in additional_antag_types)))
		var/persisted_heads = odyssey_count_active_faction_heads(state.revolutionaries)
		if (persisted_heads > 0)
			GLOB.revs.initial_spawn_target = max(0, GLOB.revs.initial_spawn_target - persisted_heads)
			GLOB.revs.initial_spawn_req = min(GLOB.revs.initial_spawn_req, max(0, GLOB.revs.initial_spawn_target))
			log_game("ODYSSEY: revolutionary spawn reduced by [persisted_heads] persisted head(s); target=[GLOB.revs.initial_spawn_target]")
	if (istype(GLOB.loyalists) && ((MODE_LOYALIST in mode.antag_tags) || (MODE_LOYALIST in additional_antag_types)))
		var/persisted_heads = odyssey_count_active_faction_heads(state.loyalists)
		if (persisted_heads > 0)
			GLOB.loyalists.initial_spawn_target = max(0, GLOB.loyalists.initial_spawn_target - persisted_heads)
			GLOB.loyalists.initial_spawn_req = min(GLOB.loyalists.initial_spawn_req, max(0, GLOB.loyalists.initial_spawn_target))
			log_game("ODYSSEY: loyalist spawn reduced by [persisted_heads] persisted head(s); target=[GLOB.loyalists.initial_spawn_target]")


/proc/odyssey_setup_revolution()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	odyssey_register_current_faction(GLOB.revs, "revolutionaries", "roundstart")
	odyssey_register_current_faction(GLOB.loyalists, "loyalists", "roundstart")
	odyssey_reapply_faction(GLOB.revs, "revolutionaries")
	odyssey_reapply_faction(GLOB.loyalists, "loyalists")
	addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_reapply_faction), GLOB.revs, "revolutionaries"), 5 SECONDS)
	addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_reapply_faction), GLOB.loyalists, "loyalists"), 5 SECONDS)
	log_game("ODYSSEY: faction setup revs_active=[odyssey_count_active_faction(state.revolutionaries)] loyalists_active=[odyssey_count_active_faction(state.loyalists)]")


/proc/odyssey_faction_store(store_name)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (store_name == "loyalists")
		if (!islist(state.loyalists))
			state.loyalists = list()
		return state.loyalists
	if (!islist(state.revolutionaries))
		state.revolutionaries = list()
	return state.revolutionaries


/proc/odyssey_register_faction_member(datum/antagonist/faction, store_name, mob/living/carbon/human/H, source = "roundstart", rank_override = null)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(faction) || !istype(H) || !H.mind)
		return FALSE
	var/player_ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!player_ckey || !slot)
		log_game("ODYSSEY: [store_name] register failed for [H.real_name]: missing ckey/slot")
		return FALSE
	var/list/store = odyssey_faction_store(store_name)
	var/key = odyssey_roster_key(player_ckey, slot)
	var/rank = rank_override
	if (!rank)
		rank = odyssey_faction_rank_of(faction, H.mind)
	store[key] = list(
		"ckey" = player_ckey,
		"slot" = slot,
		"name" = H.real_name,
		"status" = ODYSSEY_FACTION_STATUS_ACTIVE,
		"rank" = rank,
		"assigned_shift" = state.shift_number,
		"source" = source
	)
	// One roster key cannot stay active in both rev and loyalist stores.
	var/other = (store_name == "loyalists") ? "revolutionaries" : "loyalists"
	odyssey_mark_faction_status(other, player_ckey, slot, ODYSSEY_FACTION_STATUS_LOST, "switched_to_[store_name]")
	log_game("ODYSSEY: [store_name] registered [key] rank=[rank] source=[source]")
	return TRUE


/proc/odyssey_mark_faction_status(store_name, player_ckey, slot, new_status, reason)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !player_ckey || !slot || !new_status)
		return FALSE
	var/list/store = odyssey_faction_store(store_name)
	var/key = odyssey_roster_key(player_ckey, slot)
	var/list/entry = store[key]
	if (!islist(entry) || entry["status"] != ODYSSEY_FACTION_STATUS_ACTIVE)
		return FALSE
	entry["status"] = new_status
	entry["lost_shift"] = state.shift_number
	entry["lost_reason"] = reason
	store[key] = entry
	log_game("ODYSSEY: [store_name] [key] -> [new_status] reason=[reason]")
	return TRUE


/proc/odyssey_mark_revolutionary_dead(player_ckey, slot, reason)
	return odyssey_mark_faction_status("revolutionaries", player_ckey, slot, ODYSSEY_FACTION_STATUS_DEAD, reason)


/proc/odyssey_mark_loyalist_dead(player_ckey, slot, reason)
	return odyssey_mark_faction_status("loyalists", player_ckey, slot, ODYSSEY_FACTION_STATUS_DEAD, reason)


/proc/odyssey_greet_faction(datum/antagonist/faction, mob/living/carbon/human/H, rank, returning = FALSE)
	if (!istype(faction) || !istype(H))
		return
	var/role_label = rank == ODYSSEY_FACTION_RANK_HEAD ? faction.role_text : faction.faction_role_text
	if (returning)
		to_chat(H, SPAN_DANGER(FONT_LARGE("Вы снова в строю. Ваш статус ([role_label]) сохранён между сменами Одиссеи.")))
	else
		to_chat(H, SPAN_DANGER(FONT_LARGE("Вы — [role_label].")))
	to_chat(H, SPAN_NOTICE("Пока вас не убили и не вывели из фракции, роль перейдёт на следующую смену на той же кукле — даже если режим раунда не Revolution."))


/proc/odyssey_make_faction_member(datum/antagonist/faction, store_name, datum/mind/player, rank, source, returning = FALSE)
	if (!istype(faction) || !istype(player) || !ishuman(player.current))
		log_game("ODYSSEY: make_[store_name] failed ([source]): invalid mind/mob")
		return FALSE
	if (rank == ODYSSEY_FACTION_RANK_HEAD)
		if (!faction.add_antagonist(player, FALSE, returning, FALSE, FALSE, FALSE, TRUE))
			log_game("ODYSSEY: make_[store_name] head failed ([source]): add_antagonist rejected [player.key]")
			return FALSE
	else
		if (!faction.add_antagonist_mind(player, TRUE, faction.faction_role_text, faction.faction_welcome, TRUE))
			log_game("ODYSSEY: make_[store_name] member failed ([source]): add_antagonist_mind rejected [player.key]")
			return FALSE
	var/mob/living/carbon/human/H = player.current
	if (!odyssey_register_faction_member(faction, store_name, H, source, rank))
		log_game("ODYSSEY: make_[store_name] ([source]) antag set but register failed for [key_name(H)]")
	odyssey_greet_faction(faction, H, rank, returning)
	log_and_message_admins("ODYSSEY [store_name] [rank] ([source][returning ? ", returning" : ""]): [key_name(player.current)]")
	return TRUE


/proc/odyssey_register_current_faction(datum/antagonist/faction, store_name, source = "roundstart")
	if (!istype(faction))
		return 0
	var/registered = 0
	for (var/datum/mind/M in faction.current_antagonists)
		if (!ishuman(M.current))
			continue
		var/mob/living/carbon/human/H = M.current
		if (H.stat == DEAD)
			continue
		if (odyssey_register_faction_member(faction, store_name, H, source))
			registered++
	return registered


/proc/odyssey_reapply_faction(datum/antagonist/faction, store_name)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(faction))
		return 0
	var/list/store = odyssey_faction_store(store_name)
	var/reapplied = 0
	for (var/key in store)
		var/list/entry = store[key]
		if (!islist(entry) || entry["status"] != ODYSSEY_FACTION_STATUS_ACTIVE)
			continue
		var/mob/living/carbon/human/H = odyssey_find_human_by_roster_key(key)
		if (!istype(H) || !H.mind)
			continue
		if (H.mind in faction.current_antagonists)
			odyssey_register_faction_member(faction, store_name, H, "reapply_confirm", entry["rank"])
			continue
		if (player_is_antag(H.mind))
			log_game("ODYSSEY: skip [store_name] reapply for [key], already antag")
			continue
		var/rank = entry["rank"] || ODYSSEY_FACTION_RANK_MEMBER
		if (odyssey_make_faction_member(faction, store_name, H.mind, rank, "reapply", TRUE))
			reapplied++
	log_game("ODYSSEY: reapplied [reapplied] [store_name]")
	return reapplied


/proc/odyssey_schedule_faction_reapply(mob/living/carbon/human/H, attempt = 0)
	if (!istype(H) || QDELETED(H))
		return
	if (H.mind)
		odyssey_try_reapply_faction_for(H, GLOB.revs, "revolutionaries")
		odyssey_try_reapply_faction_for(H, GLOB.loyalists, "loyalists")
		return
	if (attempt >= 20)
		log_game("ODYSSEY: faction reapply gave up waiting for mind on [H.real_name] ([character_persist_ckey_of(H)])")
		return
	addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(odyssey_schedule_faction_reapply), H, attempt + 1), 1)


/proc/odyssey_try_reapply_faction_for(mob/living/carbon/human/H, datum/antagonist/faction, store_name)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(H) || QDELETED(H) || H.stat == DEAD || !istype(faction))
		return FALSE
	if (!H.mind)
		// Do not restart the attempt counter — the schedule_* waiter owns retries.
		return FALSE
	var/player_ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!player_ckey || !slot)
		return FALSE
	var/key = odyssey_roster_key(player_ckey, slot)
	var/list/store = odyssey_faction_store(store_name)
	var/list/entry = store[key]
	if (!islist(entry) || entry["status"] != ODYSSEY_FACTION_STATUS_ACTIVE)
		return FALSE
	if (H.mind in faction.current_antagonists)
		return FALSE
	if (player_is_antag(H.mind))
		log_game("ODYSSEY: skip latejoin [store_name] reapply for [key], already antag")
		return FALSE
	var/rank = entry["rank"] || ODYSSEY_FACTION_RANK_MEMBER
	return odyssey_make_faction_member(faction, store_name, H.mind, rank, "latejoin_reapply", TRUE)


/proc/odyssey_sync_faction_for_save(datum/antagonist/faction, store_name)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active || !istype(faction))
		return
	var/list/store = odyssey_faction_store(store_name)
	var/list/kept = list()

	for (var/datum/mind/M in faction.current_antagonists)
		if (!ishuman(M.current))
			continue
		var/mob/living/carbon/human/H = M.current
		if (H.stat == DEAD || QDELETED(H))
			continue
		if (odyssey_register_faction_member(faction, store_name, H, "save"))
			var/key = odyssey_roster_key(character_persist_ckey_of(H), character_persist_slot_of(H))
			if (key)
				kept[key] = TRUE

	for (var/key in store)
		var/list/entry = store[key]
		if (!islist(entry) || entry["status"] != ODYSSEY_FACTION_STATUS_ACTIVE)
			continue
		if (kept[key])
			continue
		var/list/roster_entry = state.roster[key]
		if (islist(roster_entry) && roster_entry["status"] == "dead")
			entry["status"] = ODYSSEY_FACTION_STATUS_DEAD
			entry["lost_reason"] = roster_entry["death_reason"] || "roster_dead"
			entry["lost_shift"] = state.shift_number
			store[key] = entry
			continue
		var/mob/living/carbon/human/H = odyssey_find_human_by_roster_key_any(key)
		if (istype(H) && H.stat == DEAD)
			entry["status"] = ODYSSEY_FACTION_STATUS_DEAD
			entry["lost_reason"] = "death"
			entry["lost_shift"] = state.shift_number
			store[key] = entry
			continue
		if (istype(H) && H.mind && !(H.mind in faction.current_antagonists))
			entry["status"] = ODYSSEY_FACTION_STATUS_LOST
			entry["lost_reason"] = "deconverted"
			entry["lost_shift"] = state.shift_number
			store[key] = entry
			continue
		// Absent this shift — keep active for next join with the same doll.
		continue

	log_game("ODYSSEY: [store_name] sync for save kept=[length(kept)] active=[odyssey_count_active_faction(store)]")


/proc/odyssey_sync_revolutionaries_for_save()
	odyssey_sync_faction_for_save(GLOB.revs, "revolutionaries")
	odyssey_sync_faction_for_save(GLOB.loyalists, "loyalists")
