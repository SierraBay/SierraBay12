/proc/odyssey_snapshot_valid(list/snapshot)
	if (!islist(snapshot))
		return FALSE
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/snapshot_campaign = snapshot["odyssey_campaign_id"]
	if (!snapshot_campaign)
		return TRUE
	if (state.active)
		return snapshot_campaign == state.campaign_id
	return odyssey_campaign_matches(snapshot_campaign)


/datum/preferences/character_persist_is_locked()
	return islist(character_persist_snapshot) && length(character_persist_snapshot) && odyssey_snapshot_valid(character_persist_snapshot)


/datum/preferences/apply_character_persist(mob/living/carbon/human/character)
	if (!istype(character))
		return
	character.character_persist_ckey = client_ckey
	character.character_persist_slot = default_slot
	odyssey_register_character(character)
	if (character_persist && character_persist_is_locked())
		character_persist_apply_snapshot(character, character_persist_snapshot)
		if (!isnull(character_persist_snapshot["sec_record"]))
			character.sec_record = character_persist_snapshot["sec_record"]
		if (!isnull(character_persist_snapshot["gen_record"]))
			character.gen_record = character_persist_snapshot["gen_record"]
		if (!isnull(character_persist_snapshot["med_record"]))
			character.med_record = character_persist_snapshot["med_record"]
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (state.active)
		odyssey_apply_roster_records_to_human(character, state.roster[odyssey_roster_key(character.character_persist_ckey, character.character_persist_slot)])
	if (!character_persist || !character_persist_is_locked())
		return
	var/shifts = character_persist_num(character_persist_snapshot["shifts_survived"])
	// Restore the absolute balance, then award only the newly survived shift.
	if (!isnull(character_persist_snapshot["account_money"]))
		character.character_persist_bonus_money = CHARACTER_PERSIST_SHIFT_PAY
		character.odyssey_account_money = character_persist_num(character_persist_snapshot["account_money"])
	else
		character.character_persist_bonus_money = max(shifts, 0) * CHARACTER_PERSIST_SHIFT_PAY
	if (shifts)
		to_chat(character, SPAN_NOTICE("Состояние тела перенесено с прошлой смены. Пережито смен: [shifts]."))
	else
		to_chat(character, SPAN_NOTICE("Состояние тела перенесено с прошлой смены."))


/datum/category_item/player_setup_item/physical/character_persist/content(mob/user)
	. = list()
	. += "<b>Персистентность:</b> "
	. += BTN("toggle_character_persist", pref.character_persist ? "Включена" : "Выключена")
	. += " "
	. += BTN("toggle_persist_help", show_persist_help ? "Скрыть" : "Подробнее")
	. += "<br>"
	if (show_persist_help)
		. += "<div style='margin-left:1em;max-width:42em'><i>В конце смены состояние тела сохранится, если персонаж жив и находится на Сьерре. Во время эвакуации сохранение также срабатывает на спасательных капсулах, Хароне, Гуппи и любом другом корабле. Без эвакуации уход на шаттле со Сьерры сбрасывает состояние. Криосохранение тоже записывает состояние. Смерть или отключение опции сбрасывает его. За каждую пережитую смену на счёт начисляется 500 таллеров. Роли вне Сьерры (наёмник, рейдер, генокрад, маг и подобные) не сохраняют и не сбрасывают состояние: снимок экипажа остаётся как был.</i></div>"
	. += "<b>Автозаполнение мед. записей:</b> "
	. += BTN("toggle_character_persist_med_autofill", pref.character_persist_med_autofill ? "Включена" : "Выключена")
	. += " "
	. += BTN("toggle_med_help", show_med_help ? "Скрыть" : "Подробнее")
	. += "<br>"
	if (show_med_help)
		. += "<div style='margin-left:1em;max-width:42em'><i>В конце смены в запись здравоохранения будет добавлен осмотр: травмы, переломы, ампутации, протезы конечностей и механические органы. Импланты и аугменты в запись не попадают. Текст, который вы вписали сами, и правки врачей не затираются.</i></div>"
	if (pref.character_persist_is_locked())
		var/lock_bits = "Внешность и кибернетика"
		if (pref.character_persist_med_autofill)
			lock_bits = "Внешность, кибернетика и медицинские записи"
		. += "<b><span style='color:#cc5555'>Есть сохранённое состояние с прошлой смены. [lock_bits] заблокированы, пока персонаж не умрёт, не будет брошен или пока вы не выключите опцию.</span></b><br>"
		if (pref.character_persist_snapshot["saved_at"])
			. += "Снимок: [pref.character_persist_snapshot["saved_at"]]<br>"
		var/shifts = character_persist_num(pref.character_persist_snapshot["shifts_survived"])
		. += "Пережито смен: [shifts]<br>"
		if (shifts)
			var/pending_pay = isnull(pref.character_persist_snapshot["account_money"]) ? shifts * CHARACTER_PERSIST_SHIFT_PAY : CHARACTER_PERSIST_SHIFT_PAY
			. += "К выплате в следующей смене: [pending_pay] таллеров<br>"
		if (pref.character_persist_med_locked() && pref.character_persist_snapshot["med_record"])
			. += "<i>Медицинская запись переносится со снимком. Просмотреть её можно во вкладке Background рядом с «Записи здравоохранения».</i><br>"
	. = jointext(., null)
