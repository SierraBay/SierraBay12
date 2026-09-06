#define CHARACTER_PERSIST_MED_MARKER "Автозапись персистентности"
#define CHARACTER_PERSIST_MED_HEADER "Осмотр"
#define CHARACTER_PERSIST_MED_DAMAGE_NOTICE 10

/proc/character_persist_organ_label(tag)
	switch (tag)
		if (BP_HEAD) return "голова"
		if (BP_CHEST) return "торс"
		if (BP_GROIN) return "пах"
		if (BP_L_ARM) return "левая рука"
		if (BP_R_ARM) return "правая рука"
		if (BP_L_HAND) return "левая кисть"
		if (BP_R_HAND) return "правая кисть"
		if (BP_L_LEG) return "левая нога"
		if (BP_R_LEG) return "правая нога"
		if (BP_L_FOOT) return "левая стопа"
		if (BP_R_FOOT) return "правая стопа"
		if (BP_HEART) return "сердце"
		if (BP_LUNGS) return "лёгкие"
		if (BP_LIVER) return "печень"
		if (BP_KIDNEYS) return "почки"
		if (BP_BRAIN) return "мозг"
		if (BP_EYES) return "глаза"
		if (BP_STOMACH) return "желудок"
	return tag


/proc/character_persist_reason_label(reason)
	switch (reason)
		if ("cryo")
			return "Пациент помещён в криокамеру"
		if ("roundend")
			return "Осмотр по окончании смены"
	return reason


/proc/character_persist_status_label(status)
	switch (status)
		if ("Active")
			return "в строю"
		if ("Disabled")
			return "ограниченно трудоспособен"
		if ("SSD")
			return "недоступен для контакта"
		if ("Deceased")
			return "смерть"
		if ("MIA")
			return "пропал без вести"
		if ("Stored")
			return "криохранение"
	return status


/proc/character_persist_injury_grade(amount, max_damage)
	if (amount <= 0)
		return 0
	var/ratio = max_damage > 0 ? amount / max_damage : 0
	if (amount < 8 && ratio < 0.12)
		return 0
	if (amount < 20 && (max_damage <= 0 || ratio < 0.35))
		return 1
	if (amount < 35 && (max_damage <= 0 || ratio < 0.6))
		return 2
	if (amount < 50 && (max_damage <= 0 || ratio < 0.8))
		return 3
	return 4


/proc/character_persist_brute_words(amount, max_damage)
	switch (character_persist_injury_grade(amount, max_damage))
		if (0)
			return "повреждений нет"
		if (1)
			return "малые повреждения"
		if (2)
			return "умеренные повреждения"
		if (3)
			return "тяжёлые повреждения"
	return "критические повреждения"


/proc/character_persist_burn_words(amount, max_damage)
	switch (character_persist_injury_grade(amount, max_damage))
		if (0)
			return "нет ожогов"
		if (1)
			return "поверхностные ожоги"
		if (2)
			return "ожоги средней степени"
		if (3)
			return "тяжёлые ожоги"
	return "критические ожоги"


/proc/character_persist_limb_wound_line(obj/item/organ/external/O)
	if (!istype(O))
		return null
	if (O.brute_dam < CHARACTER_PERSIST_MED_DAMAGE_NOTICE && O.burn_dam < CHARACTER_PERSIST_MED_DAMAGE_NOTICE)
		return null
	return "повреждения [character_persist_organ_label(O.organ_tag)]: [character_persist_brute_words(O.brute_dam, O.max_damage)], [character_persist_burn_words(O.burn_dam, O.max_damage)]"


/proc/character_persist_organ_wound_line(obj/item/organ/internal/I, tag)
	if (!istype(I) || I.damage < CHARACTER_PERSIST_MED_DAMAGE_NOTICE)
		return null
	return "повреждения [character_persist_organ_label(tag)]: [character_persist_brute_words(I.damage, I.max_damage)]"


/proc/character_persist_pencode_to_text(text)
	if (!text)
		return ""
	text = html_decode("[text]")
	text = replacetext(text, "\[br\]", "\n")
	return text


/proc/character_persist_crew_field_raw(datum/computer_file/report/crew_record/CR, field_type)
	if (!istype(CR) || !field_type)
		return null
	var/datum/report_field/F = locate(field_type) in CR.fields
	return F?.value


/proc/character_persist_current_med_record(mob/living/carbon/human/H)
	if (!istype(H))
		return ""
	var/datum/computer_file/report/crew_record/CR = get_crewmember_record(H.real_name)
	if (CR)
		var/raw = character_persist_crew_field_raw(CR, /datum/report_field/pencode_text/crew_record/medRecord)
		raw = character_persist_pencode_to_text(raw)
		if (raw && raw != "No record supplied")
			return raw
	return H.med_record || ""


/proc/character_persist_crew_physical_status(mob/living/carbon/human/H)
	if (!istype(H))
		return null
	var/datum/computer_file/report/crew_record/CR = get_crewmember_record(H.real_name)
	if (!CR)
		return null
	var/status = CR.get_status()
	if (!status || !(status in GLOB.physical_statuses))
		return null
	return status


/proc/character_persist_apply_crew_record(datum/computer_file/report/crew_record/CR, mob/living/carbon/human/H)
	if (!istype(CR) || !istype(H))
		return
	var/datum/preferences/prefs = character_persist_prefs_of(H.character_persist_ckey)
	if (!prefs || !prefs.character_persist_is_locked())
		return
	var/list/snapshot = prefs.character_persist_snapshot
	if (!islist(snapshot))
		return
	if (prefs.character_persist_med_autofill && snapshot["med_record"])
		CR.set_medRecord(snapshot["med_record"])
	var/status = snapshot["physical_status"]
	if (status && (status in GLOB.physical_statuses))
		CR.set_status(status)


/proc/character_persist_med_cutpoint(text)
	var/cutpoint = findtext(text, "\n[CHARACTER_PERSIST_MED_HEADER] (")
	if (cutpoint)
		return cutpoint
	cutpoint = findtext(text, "[CHARACTER_PERSIST_MED_HEADER] (")
	if (cutpoint)
		return cutpoint
	return findtext(text, "\[[CHARACTER_PERSIST_MED_MARKER]\]")


/proc/character_persist_append_med_record(existing, note)
	if (!note)
		return character_persist_pencode_to_text(existing)
	var/base = character_persist_pencode_to_text(existing)
	if (!base)
		return note
	var/entry = "\n\n[note]"
	var/combined = "[base][entry]"
	if (length(combined) > MAX_PAPER_MESSAGE_LEN)
		var/overflow = length(combined) - MAX_PAPER_MESSAGE_LEN
		var/cutpoint = character_persist_med_cutpoint(base)
		if (cutpoint && cutpoint > overflow)
			base = copytext(base, 1, cutpoint) + copytext(base, cutpoint + overflow)
			combined = "[base][entry]"
		if (length(combined) > MAX_PAPER_MESSAGE_LEN)
			combined = copytext(combined, length(combined) - MAX_PAPER_MESSAGE_LEN + 1)
	return combined


/proc/character_persist_build_med_note(mob/living/carbon/human/H, list/previous, reason)
	if (!istype(H))
		return null
	var/list/lines = list()
	if (islist(previous) && length(previous))
		lines = character_persist_med_diff(H, previous)
		if (!length(lines))
			lines += "новых травм и протезирования не отмечено"
	else
		lines = character_persist_med_baseline(H)
		if (!length(lines))
			lines += "клинически значимых травм и протезов нет"
	var/header = "[CHARACTER_PERSIST_MED_HEADER] ([stationdate2text()], [stationtime2text()]). [character_persist_reason_label(reason)]."
	return "[header]\n— [jointext(lines, "\n— ")]"


/proc/character_persist_med_baseline(mob/living/carbon/human/H)
	var/list/lines = list()
	for (var/name in BP_BY_DEPTH)
		var/obj/item/organ/external/O = H.organs_by_name[name]
		var/label = character_persist_organ_label(name)
		if (!O || O.is_stump())
			lines += "ампутация: [label]"
			continue
		if (BP_IS_ROBOTIC(O))
			lines += "протез: [label][O.model ? " ([O.model])" : ""]"
		if (O.status & ORGAN_BROKEN)
			lines += "перелом: [label]"
		if (O.status & ORGAN_DISFIGURED)
			lines += "обезображивание: [label]"
		var/wound_line = character_persist_limb_wound_line(O)
		if (wound_line)
			lines += wound_line
	for (var/tag in H.internal_organs_by_name)
		var/obj/item/organ/internal/I = H.internal_organs_by_name[tag]
		if (istype(I, /obj/item/organ/internal/augment))
			continue
		if (!I)
			continue
		var/label = character_persist_organ_label(tag)
		if (BP_IS_ROBOTIC(I))
			lines += "механический орган: [label]"
		else if (BP_IS_ASSISTED(I))
			lines += "ассистированный орган: [label]"
		var/organ_wound = character_persist_organ_wound_line(I, tag)
		if (organ_wound)
			lines += organ_wound
	if (H.species?.has_organ)
		for (var/tag in H.species.has_organ)
			if (istype(H.internal_organs_by_name[tag], /obj/item/organ/internal/augment))
				continue
			if (!H.internal_organs_by_name[tag])
				lines += "отсутствует орган: [character_persist_organ_label(tag)]"
	var/status = character_persist_crew_physical_status(H)
	if (status && status != GLOB.default_physical_status)
		lines += "состояние: [character_persist_status_label(status)]"
	return lines


/proc/character_persist_med_diff(mob/living/carbon/human/H, list/previous)
	var/list/lines = list()
	var/list/old_organs = islist(previous["organs"]) ? previous["organs"] : list()
	for (var/name in BP_BY_DEPTH)
		var/list/old = old_organs[name]
		var/obj/item/organ/external/O = H.organs_by_name[name]
		var/label = character_persist_organ_label(name)
		var/old_status = islist(old) ? old["status"] : "normal"
		if ((!O || O.is_stump()) && old_status != "amputated")
			lines += "ампутация: [label]"
			continue
		if (!O)
			continue
		if (old_status == "amputated")
			if (BP_IS_ROBOTIC(O))
				lines += "установлен протез: [label][O.model ? " ([O.model])" : ""]"
			else
				lines += "реконструкция конечности: [label]"
		else if (BP_IS_ROBOTIC(O) && old_status != "cyborg")
			lines += "установлен протез: [label][O.model ? " ([O.model])" : ""]"
		else if (!BP_IS_ROBOTIC(O) && old_status == "cyborg")
			lines += "протез заменён живой тканью: [label]"
		else if (BP_IS_ROBOTIC(O) && old_status == "cyborg" && old["model"] && O.model && old["model"] != O.model)
			lines += "замена протеза: [label] ([old["model"]] → [O.model])"
		if ((O.status & ORGAN_BROKEN) && !old["broken"])
			lines += "перелом: [label]"
		else if (!(O.status & ORGAN_BROKEN) && old["broken"])
			lines += "перелом сращён: [label]"
		if ((O.status & ORGAN_DISFIGURED) && !old["disfigured"])
			lines += "обезображивание: [label]"
		var/old_brute = character_persist_num(old["brute"])
		var/old_burn = character_persist_num(old["burn"])
		var/brute_changed = O.brute_dam >= CHARACTER_PERSIST_MED_DAMAGE_NOTICE && O.brute_dam > old_brute + 5
		var/burn_changed = O.burn_dam >= CHARACTER_PERSIST_MED_DAMAGE_NOTICE && O.burn_dam > old_burn + 5
		if (brute_changed || burn_changed)
			var/wound_line = character_persist_limb_wound_line(O)
			if (wound_line)
				lines += wound_line

	var/list/old_internals = islist(previous["internals"]) ? previous["internals"] : list()
	var/list/internal_tags = list()
	if (H.species?.has_organ)
		internal_tags = H.species.has_organ.Copy()
	for (var/tag in H.internal_organs_by_name)
		internal_tags |= tag
	for (var/tag in old_internals)
		internal_tags |= tag
	for (var/tag in internal_tags)
		var/list/old = old_internals[tag]
		var/obj/item/organ/internal/I = H.internal_organs_by_name[tag]
		if (istype(I, /obj/item/organ/internal/augment))
			continue
		var/label = character_persist_organ_label(tag)
		var/old_status = islist(old) ? old["status"] : "normal"
		if (!I && old_status != "missing")
			lines += "удалён орган: [label]"
			continue
		if (!I)
			continue
		if (BP_IS_ROBOTIC(I) && old_status != "mechanical")
			lines += "установлен механический орган: [label]"
		else if (BP_IS_ASSISTED(I) && old_status != "assisted")
			lines += "установлен ассистированный орган: [label]"
		else if (!BP_IS_ROBOTIC(I) && !BP_IS_ASSISTED(I) && (old_status == "mechanical" || old_status == "assisted"))
			lines += "орган заменён биологическим: [label]"
		var/old_damage = character_persist_num(old["damage"])
		if (I.damage >= CHARACTER_PERSIST_MED_DAMAGE_NOTICE && I.damage > old_damage + 5)
			var/organ_wound = character_persist_organ_wound_line(I, tag)
			if (organ_wound)
				lines += organ_wound
	var/old_phys = islist(previous) ? previous["physical_status"] : null
	var/new_phys = character_persist_crew_physical_status(H)
	if (new_phys && new_phys != old_phys)
		if (old_phys)
			lines += "состояние: [character_persist_status_label(old_phys)] → [character_persist_status_label(new_phys)]"
		else if (new_phys != GLOB.default_physical_status)
			lines += "состояние: [character_persist_status_label(new_phys)]"
	return lines
