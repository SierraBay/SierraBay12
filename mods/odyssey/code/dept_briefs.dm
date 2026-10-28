/// Sector department briefs for Cargo and Medical during Odyssey campaigns.

/proc/odyssey_dept_reward_for_kind(kind)
	switch (kind)
		if (ODYSSEY_DEPT_BRIEF_MEDICAL)
			return ODYSSEY_DEPT_REWARD_MEDICAL
	return 0


/proc/odyssey_dept_pay_account_names(kind)
	switch (kind)
		if (ODYSSEY_DEPT_BRIEF_MEDICAL)
			return list("Medical", "Медицинский", "Медицина")
	return list()


/proc/odyssey_dept_medical_department_pool()
	return list(
		"Engineering",
		"Security",
		"Science",
		"Supply",
		"Service",
		"Command",
		"Exploration"
	)


/proc/odyssey_dept_department_label(dept)
	return get_default_department_display_name(dept) || dept


/proc/odyssey_human_department(mob/living/carbon/human/H)
	if (!istype(H))
		return null
	var/rank = H.mind?.assigned_role
	if (!rank)
		rank = H.job
	if (!rank)
		var/obj/item/card/id/id = H.GetIdCard()
		if (istype(id))
			rank = id.assignment
	if (!rank)
		return null
	var/datum/job/J = SSjobs.get_by_title(rank)
	if (!istype(J))
		return null
	return J.department


/proc/odyssey_dept_make_brief(kind, title, brief, target, list/extra = null)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/R = odyssey_research_ensure()
	var/id = "dept-[R["next_dept_brief_id"]++]"
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
		"reward_credits" = odyssey_dept_reward_for_kind(kind),
		"reward_paid" = FALSE
	)
	if (islist(extra))
		for (var/key in extra)
			entry[key] = extra[key]
	return entry


/proc/odyssey_dept_make_cargo_brief(seed_key)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/seed = state.campaign_seed || state.campaign_id
	var/amount = odyssey_seed_roll(seed, "dept_cargo:[seed_key]", ODYSSEY_DEPT_CARGO_THALLERS_MIN, ODYSSEY_DEPT_CARGO_THALLERS_MAX)
	// Round to nearest 50 thallers for cleaner brief text.
	amount = max(ODYSSEY_DEPT_CARGO_THALLERS_MIN, round(amount / 50) * 50)
	return odyssey_dept_make_brief(
		ODYSSEY_DEPT_BRIEF_CARGO,
		"Снабжение: экспортная квота",
		"Экспортируйте груз через шаттл снабжения на сумму [amount] таллеров.",
		amount
	)


/proc/odyssey_dept_make_medical_brief(seed_key)
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/seed = state.campaign_seed || state.campaign_id
	var/list/pool = odyssey_dept_medical_department_pool()
	var/idx = odyssey_seed_roll(seed, "dept_med_dept:[seed_key]", 1, length(pool))
	var/dept = pool[idx]
	var/count = odyssey_seed_roll(seed, "dept_med_n:[seed_key]", ODYSSEY_DEPT_MEDICAL_COUNT_MIN, ODYSSEY_DEPT_MEDICAL_COUNT_MAX)
	var/label = odyssey_dept_department_label(dept)
	return odyssey_dept_make_brief(
		ODYSSEY_DEPT_BRIEF_MEDICAL,
		"Медотсек: осмотр персонала",
		"Проведите полное сканирование (body scanner) [count] членов экипажа из отдела «[label]». Каждый человек учитывается один раз. Награда: [ODYSSEY_DEPT_REWARD_MEDICAL] таллеров Медицинскому отделу.",
		count,
		list("target_dept" = dept, "target_dept_label" = label)
	)


/proc/odyssey_dept_expire_active_briefs(reason = "new_shift")
	var/list/R = odyssey_research_ensure()
	for (var/i = 1 to length(R["dept_briefs"]))
		var/list/entry = R["dept_briefs"][i]
		if (!islist(entry) || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
			continue
		entry["status"] = ODYSSEY_OBJ_STATUS_EXPIRED
		entry["result_reason"] = reason
		R["dept_briefs"][i] = entry


/proc/odyssey_generate_dept_briefs()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	var/list/R = odyssey_research_ensure()
	odyssey_dept_expire_active_briefs("new_shift")

	var/seed = state.campaign_seed || state.campaign_id
	var/roll = odyssey_seed_roll(seed, "dept_brief:[state.shift_number]:[state.current_sector_id]", 1, 100)
	var/key = "[state.shift_number]:[state.current_sector_id]"
	var/list/picked = list()

	// First slot: cargo or medical by roll.
	if (roll <= 50)
		picked += list(odyssey_dept_make_cargo_brief("[key]:1"))
	else
		picked += list(odyssey_dept_make_medical_brief("[key]:1"))

	// Second slot often the other department.
	if (roll > 40)
		if (roll <= 50)
			picked += list(odyssey_dept_make_medical_brief("[key]:2"))
		else
			picked += list(odyssey_dept_make_cargo_brief("[key]:2"))

	while (length(picked) > ODYSSEY_DEPT_BRIEFS_MAX)
		picked.Cut(length(picked), length(picked) + 1)

	for (var/list/entry in picked)
		R["dept_briefs"] += list(entry)
		odyssey_chronicle_append(
			ODYSSEY_CHRONICLE_KIND_SCIENCE,
			"Бриф отдела: [entry["title"]]",
			entry["brief"],
			ODYSSEY_CHRONICLE_VIS_PUBLIC,
			list("id" = entry["id"], "kind" = entry["kind"])
		)

	log_game("ODYSSEY: generated [length(picked)] dept briefs shift=[state.shift_number]")


/proc/odyssey_dept_active_briefs_ui()
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/list/out = list()
	var/list/R = odyssey_research_ensure()
	for (var/list/entry in R["dept_briefs"])
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
			"target_dept" = entry["target_dept"],
			"target_dept_label" = entry["target_dept_label"]
		))
	return out


/proc/odyssey_dept_complete_brief(list/entry, atom/source = null, mob/user = null)
	if (!islist(entry) || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
		return
	entry["status"] = ODYSSEY_OBJ_STATUS_COMPLETED
	entry["result_reason"] = "completed"
	entry["resolved_shift"] = odyssey_ensure_state().shift_number
	entry["progress"] = text2num(entry["target"]) || 1
	var/list/R = odyssey_research_ensure()
	R["completed_dept_brief_ids"] |= entry["id"]
	for (var/i = 1 to length(R["dept_briefs"]))
		var/list/slot = R["dept_briefs"][i]
		if (islist(slot) && slot["id"] == entry["id"])
			R["dept_briefs"][i] = entry
			break

	odyssey_chronicle_append(
		ODYSSEY_CHRONICLE_KIND_SCIENCE,
		"Бриф отдела выполнен: [entry["title"]]",
		entry["brief"],
		ODYSSEY_CHRONICLE_VIS_PUBLIC,
		list("id" = entry["id"], "kind" = entry["kind"])
	)

	var/paid = odyssey_dept_pay_credits(entry)
	entry["reward_paid"] = paid
	log_game("ODYSSEY: dept brief completed id=[entry["id"]] kind=[entry["kind"]] paid=[paid]")

	if (user)
		if (paid > 0)
			to_chat(user, SPAN_NOTICE("Бриф «[entry["title"]]» выполнен. Зачислено [paid] таллеров."))
		else
			to_chat(user, SPAN_NOTICE("Бриф «[entry["title"]]» выполнен."))
	if (paid > 0)
		priority_announcement.Announce("Sector department brief completed: [entry["title"]]. Account credited [paid] thallers.", "Odyssey Logistics Net")
	else
		priority_announcement.Announce("Sector department brief completed: [entry["title"]].", "Odyssey Logistics Net")


/proc/odyssey_dept_pay_credits(list/entry)
	var/amount = text2num(entry?["reward_credits"]) || odyssey_dept_reward_for_kind(entry?["kind"])
	if (amount < 1)
		return 0
	var/datum/money_account/account
	for (var/name in odyssey_dept_pay_account_names(entry?["kind"]))
		account = department_accounts[name]
		if (istype(account))
			break
	if (!istype(account))
		account = station_account
	if (!istype(account))
		return 0
	account.deposit(amount, "Odyssey dept brief: [entry["title"]]", "Odyssey Campaign Systems")
	return amount


/proc/odyssey_dept_on_cargo_points(amount, source)
	if (!odyssey_science_enabled || !amount || amount < 1)
		return
	if (source == "time" || source == "total")
		return
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	var/list/R = odyssey_research_ensure()
	for (var/i = 1 to length(R["dept_briefs"]))
		var/list/entry = R["dept_briefs"][i]
		if (!islist(entry) || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
			continue
		if (entry["kind"] != ODYSSEY_DEPT_BRIEF_CARGO)
			continue
		entry["progress"] = min(text2num(entry["target"]) || 1, (text2num(entry["progress"]) || 0) + amount)
		R["dept_briefs"][i] = entry
		log_game("ODYSSEY: cargo brief progress id=[entry["id"]] [entry["progress"]]/[entry["target"]] source=[source]")
		if (entry["progress"] >= (text2num(entry["target"]) || 1))
			odyssey_dept_complete_brief(entry)
		return


/proc/odyssey_dept_on_bodyscan(mob/living/carbon/human/patient, mob/user = null, atom/source = null)
	if (!odyssey_science_enabled || !istype(patient))
		return
	var/datum/odyssey_state/state = odyssey_ensure_state()
	if (!state.active)
		return
	var/patient_dept = odyssey_human_department(patient)
	if (!patient_dept)
		return
	var/evidence = patient.real_name || patient.ckey || "\ref[patient]"
	var/list/R = odyssey_research_ensure()
	for (var/i = 1 to length(R["dept_briefs"]))
		var/list/entry = R["dept_briefs"][i]
		if (!islist(entry) || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
			continue
		if (entry["kind"] != ODYSSEY_DEPT_BRIEF_MEDICAL)
			continue
		if (entry["target_dept"] && patient_dept != entry["target_dept"])
			continue
		var/list/seen = entry["seen_ids"]
		if (!islist(seen))
			seen = list()
		if (evidence in seen)
			continue
		seen += evidence
		entry["seen_ids"] = seen
		entry["progress"] = min(text2num(entry["target"]) || 1, (text2num(entry["progress"]) || 0) + 1)
		R["dept_briefs"][i] = entry
		if (user)
			to_chat(user, SPAN_NOTICE("Осмотр учтён для брифа: [entry["progress"]]/[entry["target"]]."))
		if (entry["progress"] >= (text2num(entry["target"]) || 1))
			odyssey_dept_complete_brief(entry, source, user)
		return


/proc/odyssey_dept_admin_complete(brief_id, mob/user)
	var/list/R = odyssey_research_ensure()
	for (var/i = 1 to length(R["dept_briefs"]))
		var/list/entry = R["dept_briefs"][i]
		if (!islist(entry) || entry["id"] != brief_id)
			continue
		if (entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
			return FALSE
		entry["progress"] = text2num(entry["target"]) || 1
		R["dept_briefs"][i] = entry
		odyssey_dept_complete_brief(entry, user, user)
		return TRUE
	return FALSE


/proc/odyssey_dept_admin_progress(brief_id, mob/user)
	var/list/R = odyssey_research_ensure()
	for (var/i = 1 to length(R["dept_briefs"]))
		var/list/entry = R["dept_briefs"][i]
		if (!islist(entry) || entry["id"] != brief_id || entry["status"] != ODYSSEY_OBJ_STATUS_ACTIVE)
			continue
		if (entry["kind"] == ODYSSEY_DEPT_BRIEF_CARGO)
			var/step = max(50, round((text2num(entry["target"]) || 1000) / 4))
			odyssey_dept_on_cargo_points(step, "admin")
		else if (entry["kind"] == ODYSSEY_DEPT_BRIEF_MEDICAL)
			var/evidence = "admin-med-[world.time]-[entry["progress"]]"
			var/list/seen = entry["seen_ids"]
			if (!islist(seen))
				seen = list()
			seen += evidence
			entry["seen_ids"] = seen
			entry["progress"] = min(text2num(entry["target"]) || 1, (text2num(entry["progress"]) || 0) + 1)
			R["dept_briefs"][i] = entry
			if (entry["progress"] >= (text2num(entry["target"]) || 1))
				odyssey_dept_complete_brief(entry, user, user)
		if (user)
			to_chat(user, SPAN_NOTICE("Dept brief progress: [entry["title"]] [entry["progress"]]/[entry["target"]]"))
		return TRUE
	return FALSE
