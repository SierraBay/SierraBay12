/datum/category_item/player_setup_item/physical/character_persist
	name = "Persistence"
	sort_order = 6
	var/show_persist_help = FALSE
	var/show_med_help = FALSE

/datum/category_item/player_setup_item/physical/character_persist/load_character(datum/pref_record_reader/R)
	pref.character_persist = !!R.read("character_persist")
	var/med_autofill = R.read("character_persist_med_autofill")
	pref.character_persist_med_autofill = isnull(med_autofill) ? TRUE : !!med_autofill
	pref.character_persist_snapshot = character_persist_read(pref.client_ckey, pref.default_slot)

/datum/category_item/player_setup_item/physical/character_persist/save_character(datum/pref_record_writer/W)
	W.write("character_persist", pref.character_persist)
	W.write("character_persist_med_autofill", pref.character_persist_med_autofill)

/datum/category_item/player_setup_item/physical/character_persist/sanitize_character()
	pref.character_persist = !!pref.character_persist
	pref.character_persist_med_autofill = !!pref.character_persist_med_autofill
	if (!pref.character_persist && pref.character_persist_is_locked())
		character_persist_delete(pref.client_ckey, pref.default_slot)
		pref.character_persist_snapshot = null

/datum/category_item/player_setup_item/physical/character_persist/content(mob/user)
	. = list()
	. += "<b>Персистентность:</b> "
	. += BTN("toggle_character_persist", pref.character_persist ? "Включена" : "Выключена")
	. += " "
	. += BTN("toggle_persist_help", show_persist_help ? "Скрыть" : "Подробнее")
	. += "<br>"
	if (show_persist_help)
		. += "<div style='margin-left:1em;max-width:42em'><i>В конце смены состояние тела сохранится, если персонаж жив и находится на Сьерре. Во время эвакуации сохранение также срабатывает на спасательных капсулах, Хароне, Гуппи и любом другом корабле. Без эвакуации уход на шаттле со Сьерры сбрасывает состояние. Криосохранение тоже записывает состояние. Смерть или отключение опции сбрасывает его. За каждую пережитую смену на счёт начисляется 500 таллеров. Роли вне Сьерры (наёмник, рейдер, маг и подобные) не сохраняют и не сбрасывают состояние: снимок экипажа остаётся как был.</i></div>"
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
			. += "Накоплено к выплате: [shifts * CHARACTER_PERSIST_SHIFT_PAY] таллеров<br>"
		if (pref.character_persist_med_locked() && pref.character_persist_snapshot["med_record"])
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
	if (href_list["toggle_character_persist_med_autofill"])
		pref.character_persist_med_autofill = !pref.character_persist_med_autofill
		return TOPIC_REFRESH
	if (href_list["toggle_persist_help"])
		show_persist_help = !show_persist_help
		return TOPIC_REFRESH
	if (href_list["toggle_med_help"])
		show_med_help = !show_med_help
		return TOPIC_REFRESH
	return ..()
