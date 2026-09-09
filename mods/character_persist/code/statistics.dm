var/global/list/character_persist_round_stats = list()
var/global/character_persist_roundend_done = FALSE

/proc/character_persist_stat_key(ckey, slot)
	return "[ckey]_[slot]"


/proc/character_persist_record_stat(ckey, slot, char_name, outcome, shifts, med_record, farewell)
	if (!ckey || !slot)
		return
	var/key = character_persist_stat_key(ckey, slot)
	var/list/existing = character_persist_round_stats[key]
	if (islist(existing) && existing["outcome"] == "dead")
		return
	character_persist_round_stats[key] = list(
		"name" = char_name,
		"outcome" = outcome,
		"shifts" = shifts,
		"med_record" = med_record,
		"farewell" = farewell
	)


/proc/character_persist_farewell(char_name, shifts, reason)
	if (reason == "gibbed")
		if (shifts)
			return "[char_name] погиб. От тела почти ничего не осталось. После [shifts] смен на Сьерре эта история обрывается."
		return "[char_name] погиб в свою первую смену. От тела почти ничего не осталось."
	if (shifts)
		return "[char_name] не пережил эту смену. После [shifts] смен на Сьерре эта история обрывается."
	return "[char_name] не пережил свою первую смену на Сьерре."


/proc/character_persist_format_med_html(text)
	text = character_persist_pencode_to_text(text)
	if (!text)
		return "<i>Запись здравоохранения пуста.</i>"
	text = html_encode(text)
	return replacetext(text, "\n", "<br>")


/proc/character_persist_split_med_record(text)
	text = character_persist_pencode_to_text(text)
	if (!text)
		return list("", "")
	var/cutpoint = character_persist_med_cutpoint(text)
	if (!cutpoint)
		return list(trim_left(trim_right(text)), "")
	return list(
		trim_left(trim_right(copytext(text, 1, cutpoint))),
		trim_left(trim_right(copytext(text, cutpoint)))
	)


/proc/character_persist_format_stats_med(text)
	var/list/parts = character_persist_split_med_record(text)
	var/player_text = parts[1]
	var/auto_text = parts[2]
	var/list/blocks = list()
	if (auto_text)
		blocks += "<div style='margin-bottom:8px'><i>Автозапись:</i><br>[character_persist_format_med_html(auto_text)]</div>"
	if (player_text)
		blocks += "<details><summary style='cursor:pointer'><i>Медзапись</i></summary><div style='margin-top:6px'>[character_persist_format_med_html(player_text)]</div></details>"
	if (!length(blocks))
		return "<i>Запись здравоохранения пуста.</i>"
	return jointext(blocks, "")


/proc/character_persist_roundend_process()
	if (character_persist_roundend_done)
		return
	character_persist_roundend_done = TRUE
	for (var/mob/living/carbon/human/H in GLOB.human_mobs)
		if (QDELETED(H))
			continue
		if (character_persist_is_virtual_body(H))
			continue
		var/ckey = character_persist_ckey_of(H)
		var/slot = character_persist_slot_of(H)
		if (!ckey || !slot)
			continue
		var/datum/preferences/prefs = character_persist_prefs_of(ckey)
		if (!prefs || !prefs.character_persist)
			continue
		if (character_persist_is_offstation_antag(H))
			continue
		if (H.stat == DEAD)
			character_persist_try_clear(H, "death")
			continue
		if (character_persist_can_save_here(H) || istype(H.loc, /obj/machinery/cryopod))
			character_persist_try_save(H, "roundend")
			continue
		character_persist_try_clear(H, "abandoned")


/proc/character_persist_stats_body()
	character_persist_roundend_process()
	if (!length(character_persist_round_stats))
		return "<i>В этом раунде никто не использовал персистентность.</i>"
	var/list/lines = list()
	var/index = 0
	for (var/key in character_persist_round_stats)
		var/list/entry = character_persist_round_stats[key]
		if (!islist(entry))
			continue
		index += 1
		var/char_name = html_encode("[entry["name"] || "Неизвестный"]")
		var/shifts = character_persist_num(entry["shifts"])
		var/list/card = list()
		card += "<div style='border:1px solid #5a5a5a;margin:0 0 14px 0;padding:10px 12px'>"
		card += "<div style='border-bottom:1px solid #444;padding-bottom:6px;margin-bottom:8px'><b>[index]. [char_name]</b><br>Пережито смен: [shifts]</div>"
		if (entry["outcome"] == "dead")
			card += "<i>[html_encode("[entry["farewell"] || character_persist_farewell(entry["name"], shifts, "death")]")]</i>"
		else if (entry["outcome"] == "abandoned")
			card += "<i>[char_name] покинул Сьерру. Состояние тела не сохранено.</i>"
		else
			card += character_persist_format_stats_med(entry["med_record"])
		card += "</div>"
		lines += jointext(card, null)
	return jointext(lines, null)


/proc/character_persist_roundend_text()
	character_persist_roundend_process()
	if (!length(character_persist_round_stats))
		return null
	var/saved = 0
	var/dead = 0
	var/abandoned = 0
	for (var/key in character_persist_round_stats)
		var/list/entry = character_persist_round_stats[key]
		if (!islist(entry))
			continue
		switch (entry["outcome"])
			if ("dead")
				dead++
			if ("abandoned")
				abandoned++
			else
				saved++
	var/singleton/modpack/character_persist/pack = GET_SINGLETON(/singleton/modpack/character_persist)
	var/list/lines = list()
	lines += "<br><br><br><b>CHARACTER PERSIST STATISTIC.</b>"
	lines += "<br>Персонажей с персистентностью: [length(character_persist_round_stats)]. Сохранено: [saved]. Погибло: [dead]. Не сохранено: [abandoned]."
	lines += "<br><a href='byond://?src=\ref[pack];show_persist_stats=1'>\[Показать подробную статистику\]</a>"
	return jointext(lines, null)


/singleton/modpack/character_persist/Topic(href, href_list)
	if (!href_list["show_persist_stats"])
		return
	var/mob/user = usr
	if (!user)
		return
	var/datum/browser/popup = new(user, "character_persist_stats", "Character Persist Statistic", 650, 500)
	popup.set_content(character_persist_stats_body())
	popup.open()
