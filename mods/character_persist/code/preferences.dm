/datum/preferences
	/// Per-character toggle: carry body state to the next round.
	var/character_persist = FALSE
	/// Per-character toggle: append auto medical notes on persist save. Default on for existing slots.
	var/character_persist_med_autofill = TRUE
	/// Loaded overlay from disk. Null if this slot has no live persist state.
	var/list/character_persist_snapshot

/datum/preferences/character_persist_is_locked()
	return islist(character_persist_snapshot) && length(character_persist_snapshot)

/datum/preferences/character_persist_med_locked()
	return character_persist_is_locked() && character_persist_med_autofill

/datum/preferences/apply_character_persist(mob/living/carbon/human/character)
	if (!istype(character))
		return
	character.character_persist_ckey = client_ckey
	character.character_persist_slot = default_slot
	if (!character_persist || !character_persist_is_locked())
		return
	character_persist_apply_snapshot(character, character_persist_snapshot)
	if (character_persist_med_autofill && character_persist_snapshot["med_record"])
		character.med_record = character_persist_snapshot["med_record"]
	var/shifts = character_persist_num(character_persist_snapshot["shifts_survived"])
	character.character_persist_bonus_money = max(shifts, 0) * CHARACTER_PERSIST_SHIFT_PAY
	if (shifts)
		to_chat(character, SPAN_NOTICE("Состояние тела перенесено с прошлой смены. Пережито смен: [shifts]."))
	else
		to_chat(character, SPAN_NOTICE("Состояние тела перенесено с прошлой смены."))
