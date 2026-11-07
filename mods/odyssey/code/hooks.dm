/hook/game_ready/proc/odyssey_on_game_ready()
	odyssey_ensure_state()
	return TRUE


/// Before create_characters: load continued save so nobody watches the map mutate.
/hook/pre_characters/proc/odyssey_on_pre_characters()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return TRUE
	character_persist_reload_connected_snapshots()
	if (state.continued)
		if (!odyssey_bootstrap_continued_save())
			odyssey_finish_campaign(ODYSSEY_STATUS_ADMIN_ABORTED, "save_validation_or_apply_failed")
			to_world(SPAN_DANGER("<b>Одиссея остановлена: сохранение не прошло проверку. Администраторы уведомлены.</b>"))
			message_admins("ODYSSEY: campaign aborted because save validation/apply failed: [json_encode(state.validation_errors)]")
		return TRUE
	// New campaign — baseline clean DMM before anyone can damage it.
	odyssey_ensure_persist_baselines()
	return TRUE


/hook/roundstart/proc/odyssey_on_roundstart()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return TRUE
	// Prefs may have connected during pre_characters hitch — refresh Odyssey lane again.
	character_persist_reload_connected_snapshots()
	if (!state.persist_baselines_ready)
		odyssey_ensure_persist_baselines()
	odyssey_apply_bsd_post_jump_cooldown()
	odyssey_apply_sector_threats()
	odyssey_ensure_campaign_contract()
	odyssey_generate_shift_objectives()
	odyssey_science_enabled = TRUE
	odyssey_rnd_sync_campaign_tech_tree()
	odyssey_generate_science_briefs()
	odyssey_generate_dept_briefs()
	return TRUE


/hook/roundend/proc/odyssey_on_roundend()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return TRUE
	var/list/outcome = odyssey_roundend_outcome()
	var/saved = odyssey_save_round()
	if (!saved)
		log_error("ODYSSEY: roundend save failed campaign=[state.campaign_id] shift=[state.shift_number]")
	if (islist(outcome))
		odyssey_finish_campaign(outcome["status"], outcome["reason"])
	return TRUE


/hook/death/proc/odyssey_character_death(mob/living/carbon/human/H, gibbed)
	if (istype(H) && !H.odyssey_corpse_restored)
		odyssey_mark_character_dead(H, gibbed ? "gibbed" : "death")
	return TRUE


/mob/living/carbon/human/set_stat(new_stat)
	var/old_stat = stat
	. = ..()
	if (stat)
		update_skin(1)
	if (client && client.is_afk())
		if (old_stat == UNCONSCIOUS && stat == CONSCIOUS)
			playsound_local(null, 'sound/effects/bells.ogg', 100, is_global = TRUE)
	if (old_stat == DEAD && stat != DEAD)
		odyssey_mark_character_alive(src)


/datum/mind/transfer_to(mob/living/new_character)
	var/mob/living/old_body = current
	if (!istype(new_character))
		to_world_log("## DEBUG: transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob. Please inform Carn.")
	if (current)
		if (changeling)
			current.remove_changeling_powers()
			current.verbs -= /datum/changeling/proc/EvolutionTree
		current.mind = null
		SSnano.user_transferred(current, new_character)
	if (new_character.mind)
		new_character.mind.current = null
	var/datum/skillset/skillset = new_character.skillset
	if (skillset && !ispath(skillset))
		skillset.obtain_from_mob(current)
	current = new_character
	new_character.mind = src
	if (learned_spells && length(learned_spells))
		restore_spells(new_character)
	if (active)
		new_character.key = key
	if (!ishuman(old_body) || !ishuman(new_character))
		return
	var/mob/living/carbon/human/old_human = old_body
	var/mob/living/carbon/human/new_human = new_character
	if (!new_human.character_persist_ckey && old_human.character_persist_ckey)
		new_human.character_persist_ckey = old_human.character_persist_ckey
	if (!new_human.character_persist_slot && old_human.character_persist_slot)
		new_human.character_persist_slot = old_human.character_persist_slot
	if (new_human.stat != DEAD)
		odyssey_mark_character_alive(new_human)
