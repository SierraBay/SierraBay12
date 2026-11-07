/// Character setup category: Odyssey campaign status for the selected prefs slot.

/datum/category_group/player_setup_category/odyssey_preferences
	name = "Odyssey"
	sort_order = 7
	category_item_type = /datum/category_item/player_setup_item/odyssey

/datum/category_group/player_setup_category/global_preferences
	sort_order = 8

/datum/category_group/player_setup_category/law_pref
	sort_order = 9


/datum/category_item/player_setup_item/odyssey
	name = "Campaign"
	sort_order = 1


/datum/category_item/player_setup_item/odyssey/content(mob/user)
	. = list()
	. += odyssey_character_setup_tab_html(pref)
	. = jointext(., null)


/datum/category_collection/player_setup_collection/Topic(href, list/href_list)
	var/datum/category_group/player_setup_category/old_cat = selected_category
	. = ..()
	if (!href_list["category"])
		return
	if (old_cat == selected_category)
		return
	// Entering or leaving Odyssey swaps mannequin body/inventory — one rebuild, not every content().
	var/refresh_preview = istype(old_cat, /datum/category_group/player_setup_category/odyssey_preferences) \
		|| istype(selected_category, /datum/category_group/player_setup_category/odyssey_preferences)
	if (refresh_preview && preferences)
		preferences.update_preview_icon()


/// TRUE while the Odyssey setup tab is selected (drives mannequin body overlay).
/proc/odyssey_prefs_preview_tab_active(datum/preferences/pref)
	if (!istype(pref?.player_setup))
		return FALSE
	return istype(pref.player_setup.selected_category, /datum/category_group/player_setup_category/odyssey_preferences)


/proc/odyssey_setup_load_context(datum/preferences/pref)
	if (!istype(pref) || !pref.client_ckey || !pref.default_slot)
		return null
	var/list/ctx = list(
		"key" = odyssey_roster_key(pref.client_ckey, pref.default_slot),
		"ckey" = pref.client_ckey,
		"slot" = pref.default_slot,
		"live" = FALSE
	)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	// Prefer live RAM while a campaign is running this round.
	if (state.active && state.campaign_id)
		ctx["meta"] = odyssey_state_meta(TRUE)
		ctx["roster"] = state.roster
		ctx["sleepers"] = state.sleepers
		ctx["changelings"] = state.changelings
		ctx["revolutionaries"] = state.revolutionaries
		ctx["loyalists"] = state.loyalists
		ctx["live"] = TRUE
		return ctx
	// Otherwise show whatever campaign file is on disk (active or archived).
	var/list/meta = odyssey_load_meta()
	if (!islist(meta) || !meta["campaign_id"])
		return ctx
	ctx["meta"] = meta
	ctx["roster"] = odyssey_load_roster()
	ctx["sleepers"] = islist(meta["sleepers"]) ? meta["sleepers"] : list()
	ctx["changelings"] = islist(meta["changelings"]) ? meta["changelings"] : list()
	ctx["revolutionaries"] = islist(meta["revolutionaries"]) ? meta["revolutionaries"] : list()
	ctx["loyalists"] = islist(meta["loyalists"]) ? meta["loyalists"] : list()
	return ctx


/proc/odyssey_setup_antag_labels(list/ctx, roster_key)
	var/list/labels = list()
	if (!islist(ctx) || !roster_key)
		return labels
	var/list/sleeper = ctx["sleepers"]?[roster_key]
	if (islist(sleeper) && sleeper["status"] == ODYSSEY_SLEEPER_STATUS_ACTIVE)
		labels += "Спящий агент (sleeper)"
	var/list/cling = ctx["changelings"]?[roster_key]
	if (islist(cling) && cling["status"] == ODYSSEY_CHANGELING_STATUS_ACTIVE)
		labels += "Генокрад"
	var/list/rev = ctx["revolutionaries"]?[roster_key]
	if (islist(rev) && rev["status"] == ODYSSEY_FACTION_STATUS_ACTIVE)
		labels += "Революционер"
	var/list/loy = ctx["loyalists"]?[roster_key]
	if (islist(loy) && loy["status"] == ODYSSEY_FACTION_STATUS_ACTIVE)
		labels += "Лоялист"
	return labels


/proc/odyssey_setup_item_label(list/item)
	if (!islist(item))
		return "?"
	var/label = item["name"]
	if (!label)
		var/path = item["type"]
		if (istext(path))
			var/item_path = odyssey_resolve_path(path)
			if (ispath(item_path, /obj/item))
				var/obj/item/prototype = item_path
				label = initial(prototype.name)
			if (!label)
				var/slash = findlasttext(path, "/")
				label = slash ? copytext(path, slash + 1) : path
	if (!label)
		label = "?"
	if (isnum(item["amount"]) && item["amount"] > 1)
		label = "[label] ×[item["amount"]]"
	else if (isnum(item["worth"]) && item["worth"] > 0)
		label = "[label] ([item["worth"]]₮)"
	return label


/proc/odyssey_setup_slot_label(slot_id)
	switch (slot_id)
		if (slot_w_uniform)
			return "Униформа"
		if (slot_wear_suit)
			return "Верхняя одежда"
		if (slot_back)
			return "Спина"
		if (slot_belt)
			return "Пояс"
		if (slot_head)
			return "Голова"
		if (slot_wear_mask)
			return "Маска / лицо"
		if (slot_glasses)
			return "Глаза"
		if (slot_gloves)
			return "Перчатки"
		if (slot_shoes)
			return "Обувь"
		if (slot_l_ear)
			return "Левое ухо"
		if (slot_r_ear)
			return "Правое ухо"
		if (slot_wear_id)
			return "ID"
		if (slot_l_store)
			return "Левый карман"
		if (slot_r_store)
			return "Правый карман"
		if (slot_s_store)
			return "На костюме"
		if (slot_l_hand)
			return "Левая рука"
		if (slot_r_hand)
			return "Правая рука"
		if (slot_handcuffed)
			return "Наручники"
		if (slot_tie)
			return "Аксессуар"
	return "Прочее"


/proc/odyssey_setup_inventory_descendant_count(list/children_by_parent, parent_id)
	if (!islist(children_by_parent) || !parent_id)
		return 0
	var/list/kids = children_by_parent[parent_id]
	if (!islist(kids) || !length(kids))
		return 0
	var/n = length(kids)
	for (var/list/child in kids)
		if (!islist(child) || !child["id"])
			continue
		n += odyssey_setup_inventory_descendant_count(children_by_parent, child["id"])
	return n


/proc/odyssey_setup_inventory_accessories_html(list/acc)
	if (!islist(acc) || !length(acc))
		return ""
	var/list/labels = list()
	for (var/acc_path in acc)
		var/acc_label = acc_path
		if (istext(acc_path))
			var/acc_type = odyssey_resolve_path(acc_path)
			if (ispath(acc_type, /obj/item))
				var/obj/item/acc_proto = acc_type
				acc_label = initial(acc_proto.name) || acc_path
		labels += html_encode("[acc_label]")
	return "<div style='margin-top:0.25em;color:#9eb0c0;font-size:0.9em'>Аксессуары: [jointext(labels, ", ")]</div>"


/proc/odyssey_setup_inventory_children_html(list/children_by_parent, parent_id, depth)
	if (!islist(children_by_parent) || !parent_id)
		return ""
	var/list/kids = children_by_parent[parent_id]
	if (!islist(kids) || !length(kids))
		return ""
	var/list/out = list()
	out += "<ul style='margin:0.2em 0 0.2em 1.1em;padding:0;color:#c8d0d8;font-size:0.92em'>"
	for (var/list/child in kids)
		if (!islist(child))
			continue
		var/nested = child["id"] ? odyssey_setup_inventory_descendant_count(children_by_parent, child["id"]) : 0
		out += "<li style='margin:0.12em 0'>"
		out += html_encode(odyssey_setup_item_label(child))
		if (nested)
			out += " <span style='color:#7a8a9a'>([nested])</span>"
			out += odyssey_setup_inventory_children_html(children_by_parent, child["id"], depth + 1)
		out += "</li>"
	out += "</ul>"
	return jointext(out, null)


/proc/odyssey_setup_inventory_root_card_html(list/root, list/children_by_parent, slot_title)
	if (!islist(root))
		return ""
	var/label = html_encode(odyssey_setup_item_label(root))
	var/nested = root["id"] ? odyssey_setup_inventory_descendant_count(children_by_parent, root["id"]) : 0
	var/list/acc = root["accessories"]
	var/has_acc = islist(acc) && length(acc)
	var/list/out = list()
	out += "<div style='box-sizing:border-box;padding:0.4em 0.55em;background:#1a2430;border:1px solid #2a3a4a;border-radius:4px;min-width:0'>"
	out += "<div style='color:#8aa4b8;font-size:0.78em;text-transform:uppercase;letter-spacing:0.04em;margin-bottom:0.15em'>[html_encode(slot_title)]</div>"
	out += "<div style='color:#e8eef4;font-weight:bold;line-height:1.25'>[label]</div>"
	if (has_acc)
		out += odyssey_setup_inventory_accessories_html(acc)
	if (nested)
		out += "<details style='margin-top:0.35em'>"
		out += "<summary style='cursor:pointer;color:#9ec4e0;font-size:0.9em'>Содержимое — [nested]</summary>"
		out += "<div style='margin-top:0.25em;padding:0.25em 0.35em;background:#121820;border-radius:3px;border:1px solid #243040'>"
		out += odyssey_setup_inventory_children_html(children_by_parent, root["id"], 1)
		out += "</div></details>"
	out += "</div>"
	return jointext(out, null)


/proc/odyssey_setup_inventory_html(list/inv)
	if (!islist(inv) || !length(inv))
		return "<i>Пусто / не сохранён.</i><br>"

	var/list/children_by_parent = list()
	var/list/roots = list()
	for (var/list/item in inv)
		if (!islist(item))
			continue
		if (item["storage_id"])
			var/pid = item["storage_id"]
			if (!islist(children_by_parent[pid]))
				children_by_parent[pid] = list()
			children_by_parent[pid] += list(item)
		else
			roots += list(item)

	var/list/slot_order = list(
		slot_w_uniform, slot_wear_suit, slot_back, slot_belt, slot_head, slot_wear_mask, slot_glasses,
		slot_gloves, slot_shoes, slot_l_ear, slot_r_ear, slot_wear_id, slot_l_store, slot_r_store,
		slot_s_store, slot_l_hand, slot_r_hand, slot_handcuffed, slot_tie
	)
	var/list/roots_by_slot = list()
	var/list/unslotted = list()
	for (var/list/root in roots)
		if (!islist(root))
			continue
		var/slot_id = root["slot"]
		if (isnum(slot_id))
			var/key = "[slot_id]"
			if (!islist(roots_by_slot[key]))
				roots_by_slot[key] = list()
			roots_by_slot[key] += list(root)
		else
			unslotted += list(root)

	var/list/out = list()
	out += "<div style='display:grid;grid-template-columns:1fr 1fr;gap:0.45em;margin:0.35em 0 0.5em 0;max-width:48em'>"
	for (var/slot_id in slot_order)
		var/key = "[slot_id]"
		var/list/slot_roots = roots_by_slot[key]
		if (!islist(slot_roots) || !length(slot_roots))
			continue
		roots_by_slot -= key
		var/slot_title = odyssey_setup_slot_label(slot_id)
		for (var/list/root in slot_roots)
			out += odyssey_setup_inventory_root_card_html(root, children_by_parent, slot_title)

	for (var/leftover_key in roots_by_slot)
		var/list/slot_roots = roots_by_slot[leftover_key]
		if (!islist(slot_roots) || !length(slot_roots))
			continue
		for (var/list/root in slot_roots)
			out += odyssey_setup_inventory_root_card_html(root, children_by_parent, "Прочее")

	for (var/list/root in unslotted)
		out += odyssey_setup_inventory_root_card_html(root, children_by_parent, "Без слота")

	out += "</div>"
	out += "<span style='color:#7a8a9a'>Слотов: [length(roots)]. Всего записей: [length(inv)]. Содержимое сумок — по клику.</span><br>"
	return jointext(out, null)


/proc/odyssey_character_setup_tab_html(datum/preferences/pref)
	if (!istype(pref))
		return "<i>Нет данных слота.</i>"
	var/list/ctx = odyssey_setup_load_context(pref)
	if (!islist(ctx))
		return "<i>Нет данных слота.</i>"
	var/list/out = list()
	out += "<b>Одиссея — слот [pref.default_slot]</b><br>"
	out += "<i>Превью справа показывает тело и вещи со снимка Одиссеи, пока открыта эта вкладка. Не зависит от того, выбрана ли Одиссея сейчас.</i><br><br>"

	var/list/meta = ctx["meta"]
	var/key = ctx["key"]
	var/list/roster = ctx["roster"]
	var/list/entry = islist(roster) ? roster[key] : null
	var/list/ody_snap = character_persist_read_odyssey_disk(pref.client_ckey, pref.default_slot)
	var/has_body = islist(ody_snap) && length(ody_snap) && ody_snap["odyssey_campaign_id"]

	if (!islist(meta) || !meta["campaign_id"])
		if (!has_body)
			out += "<i>Нет сохранённых данных Одиссеи для этого слота.</i>"
			return jointext(out, null)
		out += "<i>Файла кампании на диске нет — ниже только снимок тела слота.</i><br><br>"
	else
		out += "Кампания: <code>[html_encode("[meta["campaign_id"]]")]</code>"
		if (ctx["live"])
			out += " <b>(сейчас идёт)</b>"
		else if (meta["active"])
			out += " <b>(на диске, continue доступен)</b>"
		else
			out += " <span style='color:#cc8844'>(архив / неактивна)</span>"
		out += "<br>"
		out += "Смена: <b>[meta["shift_number"] || "?"]</b>"
		if (meta["current_sector_id"])
			out += " | Сектор: [html_encode("[meta["current_sector_id"]]")]"
		out += "<br>"
		out += "Статус кампании: <b>[html_encode("[meta["status"] || "?"]")]</b>"
		if (meta["archive_reason"] || meta["outcome_reason"])
			out += "<br>Причина: [html_encode("[meta["archive_reason"] || meta["outcome_reason"]]")]"
		out += "<br><br>"

	if (!islist(entry) && !has_body)
		out += "<i>Этот слот не участвовал в сохранённой кампании.</i>"
		return jointext(out, null)

	out += "<b>Персонаж</b><br>"
	if (islist(entry))
		out += "Имя: <b>[html_encode("[entry["name"] || "?"]")]</b><br>"
		var/job = entry["job"] || entry["assigned_job"]
		if (job)
			out += "Должность: [html_encode("[job]")]<br>"
		var/status = entry["status"] || "?"
		out += "Статус: <b>[html_encode("[status]")]</b>"
		if (status == "dead")
			out += " <span style='color:#cc5555'>(слот заблокирован в раундах Одиссеи)</span>"
			if (entry["death_reason"])
				out += "<br>Причина смерти: [html_encode("[entry["death_reason"]]")]"
			if (entry["died_at"])
				out += "<br>Когда: [html_encode("[entry["died_at"]]")]"
			if (entry["death_shift"])
				out += " (смена [entry["death_shift"]])"
		out += "<br>"
		if (entry["joined_shift"])
			out += "Вступил на смене: [entry["joined_shift"]]"
			if (entry["last_seen_shift"])
				out += " | Последняя смена: [entry["last_seen_shift"]]"
			out += "<br>"
		if (entry["custody"] == ODYSSEY_CUSTODY_BRIG)
			out += "<span style='color:#cc8844'><b>Под стражей (бриг)</b></span>"
			if (entry["custody_shift"])
				out += " с смены [entry["custody_shift"]]"
			out += "<br>"
		else
			out += "Под стражей: нет<br>"
		if (entry["criminal_status"])
			out += "Criminal status: [html_encode("[entry["criminal_status"]]")]<br>"
		if (entry["physical_status"])
			out += "Physical status: [html_encode("[entry["physical_status"]]")]<br>"
	else
		out += "<i>Нет записи roster — есть только снимок тела.</i><br>"

	var/list/antags = odyssey_setup_antag_labels(ctx, key)
	out += "<br><b>Антагонист</b><br>"
	if (length(antags))
		out += jointext(antags, "<br>")
		out += "<br>"
	else
		out += "Нет / не сохранён<br>"

	out += "<br><b>Тело</b><br>"
	if (has_body)
		if (ody_snap["saved_at"])
			out += "Снимок: [html_encode("[ody_snap["saved_at"]]")]<br>"
		var/shifts = character_persist_num(ody_snap["shifts_survived"])
		out += "Пережито смен (снимок): [shifts]<br>"
		if (ody_snap["species"])
			out += "Раса (снимок): <b>[html_encode("[ody_snap["species"]]")]</b><br>"
		out += "<b>Осмотр</b><br>"
		for (var/line in character_persist_snapshot_med_lines(ody_snap))
			out += "— [html_encode("[line]")]<br>"
	else
		out += "<i>Снимка тела Одиссеи нет.</i><br>"

	out += "<br><b>Инвентарь</b><br>"
	if (has_body)
		out += odyssey_setup_inventory_html(ody_snap["inventory"])
	else
		out += "<i>Нет снимка.</i><br>"

	out += "<br><b>История смен</b><br>"
	if (islist(entry))
		var/list/shift_jobs = entry["shift_jobs"]
		var/list/seen = entry["seen_shifts"]
		if (islist(shift_jobs) && length(shift_jobs))
			var/list/shift_keys = list()
			for (var/sk in shift_jobs)
				shift_keys += sk
			for (var/i = 1 to length(shift_keys))
				for (var/j = i + 1 to length(shift_keys))
					if (text2num(shift_keys[j]) < text2num(shift_keys[i]))
						var/tmp = shift_keys[i]
						shift_keys[i] = shift_keys[j]
						shift_keys[j] = tmp
			for (var/sk in shift_keys)
				out += "Смена [html_encode("[sk]")]: [html_encode("[shift_jobs[sk]]")]<br>"
		else if (islist(seen) && length(seen))
			out += "Смены: [html_encode(jointext(seen, ", "))]<br>"
		else
			out += "<i>Пока нет истории смен.</i><br>"
	else
		out += "<i>Нет roster.</i><br>"

	return jointext(out, null)
