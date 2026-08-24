/datum/category_item/player_setup_item/physical/character_persist
	name = "Persistence"
	sort_order = 6

/datum/category_item/player_setup_item/physical/character_persist/load_character(datum/pref_record_reader/R)
	pref.character_persist = !!R.read("character_persist")
	pref.character_persist_snapshot = character_persist_read(pref.client_ckey, pref.default_slot)

/datum/category_item/player_setup_item/physical/character_persist/save_character(datum/pref_record_writer/W)
	W.write("character_persist", pref.character_persist)

/datum/category_item/player_setup_item/physical/character_persist/sanitize_character()
	pref.character_persist = !!pref.character_persist
	if (!pref.character_persist && pref.character_persist_is_locked())
		character_persist_delete(pref.client_ckey, pref.default_slot)
		pref.character_persist_snapshot = null

/datum/category_item/player_setup_item/physical/character_persist/content(mob/user)
	. = list()
	. += "<b>Персистентность:</b> "
	. += BTN("toggle_character_persist", pref.character_persist ? "Включена" : "Выключена")
	. += "<br>"
	if (pref.character_persist)
		. += "<i>В конце смены состояние тела сохранится, если персонаж жив и находится на Сьерре — не на эвакуационном шаттле. Криосохранение тоже записывает состояние. Смерть или отключение опции сбрасывает его. За каждую пережитую смену на счёт начисляется 500 таллеров.</i><br>"
	if (pref.character_persist_is_locked())
		. += "<b><span style='color:#cc5555'>Есть сохранённое состояние с прошлой смены. Внешность, кибернетика и медицинские записи заблокированы, пока персонаж не умрёт, не будет брошен или пока вы не выключите опцию.</span></b><br>"
		if (pref.character_persist_snapshot["saved_at"])
			. += "Снимок: [pref.character_persist_snapshot["saved_at"]]<br>"
		var/shifts = character_persist_num(pref.character_persist_snapshot["shifts_survived"])
		. += "Пережито смен: [shifts]<br>"
		if (shifts)
			. += "Накоплено к выплате: [shifts * CHARACTER_PERSIST_SHIFT_PAY] таллеров<br>"
		if (pref.character_persist_snapshot["med_record"])
			. += "<i>Медицинская запись переносится со снимком. Просмотреть её можно во вкладке Background рядом с «Записи здравоохранения».</i><br>"
	. = jointext(., null)

/datum/category_item/player_setup_item/physical/character_persist/OnTopic(href, list/href_list, mob/user)
	if (href_list["toggle_character_persist"])
		if (pref.character_persist && pref.character_persist_is_locked())
			if (alert(user, "Выключить персистентность и сбросить сохранённое состояние тела?", "Персистентность", "Сбросить", "Отмена") != "Сбросить")
				return TOPIC_NOACTION
			character_persist_clear_ckey(pref.client_ckey, pref.default_slot, "toggle_off")
		pref.character_persist = !pref.character_persist
		return TOPIC_REFRESH
	return ..()
