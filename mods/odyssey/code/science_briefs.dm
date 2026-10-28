/// Sector science briefs for Research during Odyssey campaigns.

/proc/odyssey_science_reward_for_kind(kind)
	switch (kind)
		if (ODYSSEY_SCI_BRIEF_SPECTRUM)
			return ODYSSEY_SCI_REWARD_SPECTRUM
		if (ODYSSEY_SCI_BRIEF_CATALOG)
			return ODYSSEY_SCI_REWARD_CATALOG
		if (ODYSSEY_SCI_BRIEF_FLORA)
			return ODYSSEY_SCI_REWARD_FLORA
		if (ODYSSEY_SCI_BRIEF_SLIME)
			return ODYSSEY_SCI_REWARD_SLIME
	return ODYSSEY_SCI_REWARD_SPECTRUM


/proc/odyssey_science_slime_pool(prefer_high = FALSE)
	var/list/tier3 = list(
		/obj/item/slime_extract/yellow,
		/obj/item/slime_extract/silver,
		/obj/item/slime_extract/darkblue,
		/obj/item/slime_extract/darkpurple
	)
	var/list/tier4 = list(
		/obj/item/slime_extract/pink,
		/obj/item/slime_extract/red,
		/obj/item/slime_extract/gold,
		/obj/item/slime_extract/green,
		/obj/item/slime_extract/sepia,
		/obj/item/slime_extract/bluespace,
		/obj/item/slime_extract/cerulean,
		/obj/item/slime_extract/pyrite
	)
	var/list/tier5 = list(
		/obj/item/slime_extract/lightpink,
		/obj/item/slime_extract/oil,
		/obj/item/slime_extract/adamantine,
		/obj/item/slime_extract/black
	)
	if (prefer_high)
		return tier4 + tier5
	return tier3 + tier4 + tier5


/proc/odyssey_science_flora_gene_pool()
	return list(GENE_SPECIAL, GENE_OUTPUT, GENE_FRUIT, GENE_DIET)


/proc/odyssey_science_gene_label(genetype)
	switch (genetype)
		if (GENE_SPECIAL)
			return "специальный (телепортация)"
		if (GENE_OUTPUT)
			return "выход (биолюминесценция / энергия)"
		if (GENE_FRUIT)
			return "плод (жгучий / взрывной)"
		if (GENE_DIET)
			return "диета (хищный / паразит)"
	return "[genetype]"


/proc/odyssey_science_extract_label(path)
	if (!ispath(path, /obj/item/slime_extract))
		return "[path]"
	var/obj/item/slime_extract/sample = path
	return initial(sample.name) || "[path]"


/proc/odyssey_science_pick_from_list(list/pool, seed_key)
	if (!length(pool))
		return null
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/seed = state.campaign_seed || state.campaign_id
	var/idx = odyssey_seed_roll(seed, seed_key, 1, length(pool))
	return pool[idx]


/proc/odyssey_science_make_brief(kind, title, brief, target, list/extra = null)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/R = odyssey_research_ensure()
	var/id = "sci-[R["next_brief_id"]++]"
	var/list/entry = list(
		"id" = id,
		"kind" = kind,
		"title" = title,
		"brief" = brief,
		"status" = ODYSSEY_OBJ_STATUS_ACTIVE,
		"progress" = 0,
		"target" = target,
		"sector_id" = state.current_sector_id,
		"shift_issued" = state.shift_number,
		"reward_credits" = odyssey_science_reward_for_kind(kind),
		"reward_paid" = FALSE
	)
	if (islist(extra))
		for (var/key in extra)
			entry[key] = extra[key]
	return entry


/proc/odyssey_science_make_spectrum_brief(seed_key)
	var/n = odyssey_science_spectrum_target(seed_key)
	return odyssey_science_make_brief(
		ODYSSEY_SCI_BRIEF_SPECTRUM,
		"Спектр аномального фона",
		"Проведите [n] полных спектральных анализов (разные типы образцов, perfect). Награда: [ODYSSEY_SCI_REWARD_SPECTRUM] таллеров Научному отделу.",
		n
	)


/proc/odyssey_science_make_catalog_brief()
	return odyssey_science_make_brief(
		ODYSSEY_SCI_BRIEF_CATALOG,
		"Каталог обломков",
		"Каталогизируйте 2 артефакта через консоль RnD (для каждого — минимум две верные классификации). Награда: [ODYSSEY_SCI_REWARD_CATALOG] таллеров Научному отделу.",
		2
	)


/proc/odyssey_science_make_flora_brief(seed_key)
	var/genetype = odyssey_science_pick_from_list(odyssey_science_flora_gene_pool(), "sci_flora:[seed_key]")
	var/label = odyssey_science_gene_label(genetype)
	return odyssey_science_make_brief(
		ODYSSEY_SCI_BRIEF_FLORA,
		"Ксеноботаника: экзотический ген",
		"Выделите ген «[label]» из мутировавшего сорта на lysis-isolation centrifuge (нужен выраженный экзотический признак). Награда: [ODYSSEY_SCI_REWARD_FLORA] таллеров Научному отделу.",
		1,
		list("target_gene" = genetype)
	)


/proc/odyssey_science_make_slime_brief(seed_key, prefer_high = FALSE)
	var/extract_path = odyssey_science_pick_from_list(odyssey_science_slime_pool(prefer_high), "sci_slime:[seed_key]")
	var/label = odyssey_science_extract_label(extract_path)
	return odyssey_science_make_brief(
		ODYSSEY_SCI_BRIEF_SLIME,
		"Ксенобиология: ядро слизня",
		"Добудьте и проанализируйте «[label]» (деконструкция в DA или активация extract). Награда: [ODYSSEY_SCI_REWARD_SLIME] таллеров Научному отделу.",
		1,
		list("target_type" = "[extract_path]")
	)


/proc/odyssey_science_spectrum_target(seed_key)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/seed = state.campaign_seed || state.campaign_id
	return odyssey_seed_roll(seed, "sci_spectrum_n:[seed_key]", 2, 5)


/proc/odyssey_science_expire_active_briefs(reason = "new_shift")
	var/list/R = odyssey_research_ensure()
	for (var/i = 1 to length(R["active_briefs"]))
		var/list/entry = R["active_briefs"][i]
		if (!islist(entry) || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
			continue
		entry["status"] = ODYSSEY_OBJ_STATUS_EXPIRED
		entry["result_reason"] = reason
		R["active_briefs"][i] = entry


/proc/odyssey_generate_science_briefs()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	var/list/R = odyssey_research_ensure()
	odyssey_science_expire_active_briefs("new_shift")

	var/list/sector = odyssey_get_sector(state.current_sector_id, state)
	var/danger = sector?["danger"] || ODYSSEY_DANGER_SAFE
	var/seed = state.campaign_seed || state.campaign_id
	var/roll = odyssey_seed_roll(seed, "sci_brief:[state.shift_number]:[state.current_sector_id]", 1, 100)
	var/key = "[state.shift_number]:[state.current_sector_id]"
	var/list/picked = list()

	if (danger == ODYSSEY_DANGER_HOSTILE)
		picked += list(odyssey_science_make_spectrum_brief("[key]:h"))
		if (roll > 35)
			if (roll > 55)
				picked += list(odyssey_science_make_slime_brief("[key]:h2", TRUE))
			else
				picked += list(odyssey_science_make_catalog_brief())
	else if (danger == ODYSSEY_DANGER_DANGEROUS)
		picked += list(odyssey_science_make_catalog_brief())
		if (roll > 45)
			if (roll > 70)
				picked += list(odyssey_science_make_flora_brief("[key]:d2"))
			else
				picked += list(odyssey_science_make_spectrum_brief("[key]:d2"))
	else
		if (roll <= 50)
			picked += list(odyssey_science_make_spectrum_brief("[key]:s1"))
		else
			picked += list(odyssey_science_make_flora_brief("[key]:s1"))
		if (roll > 65)
			if (roll > 82)
				picked += list(odyssey_science_make_slime_brief("[key]:s2", FALSE))
			else
				picked += list(odyssey_science_make_catalog_brief())

	while (length(picked) > ODYSSEY_SCI_BRIEFS_MAX)
		picked.Cut(length(picked), length(picked) + 1)

	for (var/list/entry in picked)
		R["active_briefs"] += list(entry)
		odyssey_chronicle_append(
			ODYSSEY_CHRONICLE_KIND_SCIENCE,
			"Научный бриф: [entry["title"]]",
			entry["brief"],
			ODYSSEY_CHRONICLE_VIS_PUBLIC,
			list("id" = entry["id"], "kind" = entry["kind"])
		)

	var/note_key = state.current_sector_id || "unknown"
	R["sector_notes"][note_key] = "Смена [state.shift_number]: выдано [length(picked)] научн. бриф(ов), класс [danger]."
	log_game("ODYSSEY: generated [length(picked)] science briefs danger=[danger] shift=[state.shift_number]")


/proc/odyssey_science_active_briefs_ui()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/out = list()
	var/list/R = odyssey_research_ensure()
	for (var/list/entry in R["active_briefs"])
		if (!islist(entry))
			continue
		if (text2num(entry["shift_issued"]) != state.shift_number)
			continue
		if (!(entry["status"] in list(ODYSSEY_OBJ_STATUS_ACTIVE, ODYSSEY_OBJ_STATUS_COMPLETED)))
			continue
		out += list(list(
			"id" = entry["id"],
			"kind" = entry["kind"],
			"title" = entry["title"],
			"brief" = entry["brief"],
			"status" = entry["status"],
			"progress" = entry["progress"],
			"target" = entry["target"],
			"reward_credits" = entry["reward_credits"],
			"target_gene" = entry["target_gene"],
			"target_type" = entry["target_type"]
		))
	return out


/proc/odyssey_science_note_sample(sample_id)
	if (!sample_id)
		return
	var/list/R = odyssey_research_ensure()
	R["samples_collected"] |= "[sample_id]"


/proc/odyssey_science_note_anomaly(anomaly_id)
	if (!anomaly_id)
		return
	var/list/R = odyssey_research_ensure()
	R["anomalies_catalogued"] |= "[anomaly_id]"


/proc/odyssey_science_progress(kind, amount = 1, evidence_id = null, atom/source = null, mob/user = null)
	if (!odyssey_science_enabled)
		return
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	var/list/R = odyssey_research_ensure()
	for (var/i = 1 to length(R["active_briefs"]))
		var/list/entry = R["active_briefs"][i]
		if (!islist(entry) || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
			continue
		if (entry["kind"] != kind)
			continue
		if (entry["target_gene"] && evidence_id != entry["target_gene"])
			continue
		if (entry["target_type"] && "[evidence_id]" != "[entry["target_type"]]")
			continue
		if (evidence_id)
			var/list/seen = entry["seen_ids"]
			if (!islist(seen))
				seen = list()
			if (evidence_id in seen)
				continue
			seen += evidence_id
			entry["seen_ids"] = seen
		entry["progress"] = min(text2num(entry["target"]) || 1, (text2num(entry["progress"]) || 0) + amount)
		R["active_briefs"][i] = entry
		log_game("ODYSSEY: science brief progress id=[entry["id"]] kind=[kind] [entry["progress"]]/[entry["target"]] evidence=[evidence_id]")
		if (entry["progress"] >= (text2num(entry["target"]) || 1))
			odyssey_science_complete_brief(entry, source, user)
		else if (user)
			to_chat(user, SPAN_NOTICE("Научный бриф «[entry["title"]]»: [entry["progress"]]/[entry["target"]]."))
		return


/proc/odyssey_science_complete_brief(list/entry, atom/source = null, mob/user = null)
	if (!islist(entry) || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
		return
	entry["status"] = ODYSSEY_OBJ_STATUS_COMPLETED
	entry["result_reason"] = "completed"
	entry["resolved_shift"] = odyssey_ensure_state().shift_number
	entry["progress"] = text2num(entry["target"]) || 1
	var/list/R = odyssey_research_ensure()
	R["completed_brief_ids"] |= entry["id"]
	// Ensure the list slot reflects completion (JSON save / UI).
	for (var/i = 1 to length(R["active_briefs"]))
		var/list/slot = R["active_briefs"][i]
		if (islist(slot) && slot["id"] == entry["id"])
			R["active_briefs"][i] = entry
			break

	odyssey_chronicle_append(
		ODYSSEY_CHRONICLE_KIND_SCIENCE,
		"Научный бриф выполнен: [entry["title"]]",
		entry["brief"],
		ODYSSEY_CHRONICLE_VIS_PUBLIC,
		list("id" = entry["id"], "kind" = entry["kind"])
	)

	var/paid = odyssey_science_pay_credits(entry)
	entry["reward_paid"] = paid
	log_game("ODYSSEY: science brief completed id=[entry["id"]] kind=[entry["kind"]] paid=[paid]")

	if (user)
		to_chat(user, SPAN_NOTICE("Научный бриф «[entry["title"]]» выполнен. На счёт Научного отдела зачислено [paid] таллеров."))
	priority_announcement.Announce("Research sector brief completed: [entry["title"]]. Science department account credited [paid] thallers.", "Odyssey Science Net")


/proc/odyssey_science_pay_credits(list/entry)
	var/amount = text2num(entry?["reward_credits"]) || odyssey_science_reward_for_kind(entry?["kind"])
	if (amount < 1)
		return 0
	var/datum/money_account/account = department_accounts["Science"] || department_accounts["Research"] || department_accounts["Научный"]
	if (!istype(account))
		account = station_account
	if (!istype(account))
		return 0
	account.deposit(amount, "Odyssey science brief: [entry["title"]]", "Odyssey Campaign Systems")
	return amount


/// Admin/debug: force-complete an active brief by id (grants credit reward).
/proc/odyssey_science_admin_complete(brief_id, mob/user)
	var/list/R = odyssey_research_ensure()
	for (var/i = 1 to length(R["active_briefs"]))
		var/list/entry = R["active_briefs"][i]
		if (!islist(entry) || entry["id"] != brief_id)
			continue
		if (entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
			return FALSE
		entry["progress"] = text2num(entry["target"]) || 1
		R["active_briefs"][i] = entry
		odyssey_science_complete_brief(entry, user, user)
		return TRUE
	return FALSE


/// Admin/debug: deposit test credits to Science.
/proc/odyssey_science_admin_pay_test(amount = 1000, mob/user = null)
	var/list/fake = list(
		"title" = "admin test payout",
		"kind" = ODYSSEY_SCI_BRIEF_SPECTRUM,
		"reward_credits" = amount
	)
	var/paid = odyssey_science_pay_credits(fake)
	if (user)
		to_chat(user, SPAN_NOTICE("Тестовая выплата Научному отделу: [paid] таллеров."))
	return paid
