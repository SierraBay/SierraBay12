/hook/game_ready/proc/odyssey_on_game_ready()
	odyssey_ensure_state()
	return TRUE


/hook/roundstart/proc/odyssey_on_roundstart()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return TRUE
	if (state.continued)
		odyssey_apply_abandoned_shuttles()
	// Baseline from the freshly loaded DMM, after abandoned shuttles have left their hangars.
	// Never recapture after apply — that would treat loaded damage as the clean map.
	odyssey_ensure_persist_baselines()
	if (state.continued && !odyssey_apply_save())
		odyssey_finish_campaign(ODYSSEY_STATUS_ADMIN_ABORTED, "save_validation_or_apply_failed")
		to_world(SPAN_DANGER("<b>Одиссея остановлена: сохранение не прошло проверку. Администраторы уведомлены.</b>"))
		message_admins("ODYSSEY: campaign aborted because save validation/apply failed: [json_encode(state.validation_errors)]")
		return TRUE
	odyssey_apply_sector_threats()
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
