/singleton/modpack/payroll/initialize()
	admin_verbs_admin |= /client/proc/payroll_correction
	for(var/client/admin as anything in GLOB.admins)
		if(admin.holder?.rights & R_ADMIN)
			admin.verbs |= /client/proc/payroll_correction
	return ..()

/hook/roundstart/proc/start_payroll()
	SSpayroll.ledger.start()
	return TRUE

/datum/payroll_controller/proc/card_record(obj/item/card/id/card)
	RETURN_TYPE(/datum/payroll_record)
	var/datum/payroll_record/record = records[card?.payroll_id]
	if(record && record.account?.account_number == card.associated_account_number)
		return record

/hook/reassign_employee/proc/payroll_reassign(obj/item/card/id/card)
	SSpayroll.ledger.reassign_card(usr, card)
	return TRUE

/datum/payroll_controller/proc/reassign_card(mob/user, obj/item/card/id/card)
	var/datum/payroll_record/record = card_record(card)
	if(!record)
		return FALSE
	var/datum/job/job = SSjobs.get_by_title(card.rank)
	if(job && (job != record.job || !record.active))
		return transfer_employee(user, record, job, "Authorized ID employment reassignment", record.revision)
	return FALSE

/hook/terminate_employee/proc/payroll_terminate(obj/item/card/id/card)
	var/datum/payroll_controller/ledger = SSpayroll.ledger
	var/datum/payroll_record/record = ledger.card_record(card)
	if(record && ledger.can_transfer(usr, record))
		ledger.log_decision(record, key_name(usr), "Termination authorized", "ID employment termination", usr.real_name)
		ledger.end_employment(record, "ID employment termination")
	return TRUE

// Minimal existing-goal integration: a completed EVA walking goal can earn a department-funded award.
/datum/payroll_controller/proc/reward_eva(datum/goal/movement/walk/eva/goal)
	if(!istype(goal) || !goal.check_success() || !istype(goal.owner, /datum/mind))
		return FALSE
	var/datum/payroll_record/record = find_record(goal.owner)
	if(record?.department != "Exploration")
		return FALSE
	return queue_bonus(record, department_accounts[record.department], settings.eva_bonus, "EVA mobility goal completed", "Exploration goal system", "eva-\ref[goal]", record.department, period_at(elapsed()), "Exploration goal system")

/client/proc/payroll_correction()
	set name = "Correct Payroll Rate"
	set category = "Admin"
	if(!check_rights(R_ADMIN))
		return
	var/datum/payroll_controller/ledger = SSpayroll.ledger
	var/list/employees = list()
	for(var/id in ledger.records)
		var/datum/payroll_record/record = ledger.records[id]
		employees["[record.name] ([id])"] = record
	var/choice = input(src, "Employee", "Payroll correction") as null|anything in employees
	var/datum/payroll_record/record = employees[choice]
	if(!record)
		return
	prompt_payroll_correction(record)

/client/proc/prompt_payroll_correction(datum/payroll_record/record)
	var/revision = record.revision
	var/rate = input(src, "New absolute salary rate (whole units, 0-1000000).", "Payroll correction", record.current_rate()) as num|null
	var/reason = input(src, "Reason (1-200 characters)", "Payroll correction") as text|null
	if(!isnull(rate) && istext(reason))
		if(!SSpayroll.ledger.admin_rate(mob, record, rate, sanitize(reason, 200), revision))
			to_chat(src, SPAN_WARNING("Payroll correction rejected: permissions, amount, or revision changed."))
