/datum/payroll_controller/proc/operator_record(mob/user)
	RETURN_TYPE(/datum/payroll_record)
	if(!ishuman(user) || !user.mind || user.mind.current != user || user.incapacitated())
		return
	var/datum/payroll_record/record = find_record(user.mind)
	if(!record?.active || user.mind.assigned_job != record.job || user.mind.assigned_role != record.job.title)
		return
	var/obj/item/card/id/card = user.GetIdCard()
	if(!card || card.associated_account_number != record.account?.account_number)
		return
	if(!has_access(record.job.access, card.GetAccess()))
		return
	return record

/datum/payroll_controller/proc/can_manage(mob/user, datum/payroll_record/target)
	var/datum/payroll_record/actor = operator_record(user)
	if(!actor || !target || records[target.id] != target || actor == target)
		return FALSE
	if(istype(actor.job, /datum/job/captain))
		return TRUE
	var/list/scope = settings.scopes["[actor.job.type]"]
	if(!islist(scope) || !(target.department in scope) || !target.active)
		return FALSE
	var/list/reports = settings.head_reports["[actor.job.type]"]
	return !target.job.head_position || ("[target.job.type]" in reports)

/datum/payroll_controller/proc/can_transfer(mob/user, datum/payroll_record/target)
	var/datum/payroll_record/actor = operator_record(user)
	if(!actor || !target || records[target.id] != target || actor == target)
		return FALSE
	return istype(actor.job, /datum/job/captain) || (istype(actor.job, /datum/job/hop) && !target.job.head_position)

/datum/payroll_controller/proc/change_rate(mob/user, datum/payroll_record/record, amount, reason, revision)
	if(!can_manage(user, record) || revision != record.revision || !isnum(amount) || !payroll_valid_amount(abs(amount), TRUE))
		return FALSE
	if(abs(amount) > record.base_rate * settings.raise_limit || record.base_rate + amount > 1000000 || !valid_reason(reason))
		return FALSE
	accrue(record, elapsed())
	record.adjustment = amount
	record.revision++
	log_decision(record, key_name(user), "Salary adjustment set to [amount]", reason, user.real_name)
	record.notify("Your salary rate is now [record.current_rate()] per period: [reason].")
	return TRUE

/datum/payroll_controller/proc/valid_reason(reason)
	return istext(reason) && length(trimtext(reason)) > 0 && length(reason) <= 200

/datum/payroll_controller/proc/pending_total(datum/payroll_record/record, kind, period)
	var/total = 0
	for(var/datum/payroll_adjustment/item as anything in record.adjustments)
		if(item.kind == kind && item.period == period && item.status == "pending")
			total += item.amount
	return total

/datum/payroll_controller/proc/request_adjustment(mob/user, datum/payroll_record/record, kind, amount, reason, revision)
	if(!can_manage(user, record) || revision != record.revision || !payroll_valid_amount(amount) || !valid_reason(reason))
		return FALSE
	var/period = period_at(elapsed())
	if(kind == "bonus")
		return queue_bonus(record, department_accounts[record.department], amount, reason, key_name(user), "ui-[record.id]-[revision]", record.department, period, user.real_name)
	if(kind == "deduction")
		return queue_deduction(record, amount, reason, key_name(user), "ui-[record.id]-[revision]", period, user.real_name)
	return FALSE

// Trusted counterpart to queue_bonus(); deductions change future salary, never personal savings.
/datum/payroll_controller/proc/queue_deduction(datum/payroll_record/record, amount, reason, initiator, request_id, period, initiator_name = "Payroll service")
	if(!started || !record || records[record.id] != record || !record.active || !payroll_valid_amount(amount) || !valid_reason(reason))
		return FALSE
	if(!istext(initiator) || !length(initiator) || !istext(request_id) || !length(request_id) || length(request_id) > 200)
		return FALSE
	if(requests[request_id])
		return requests[request_id]
	if(period != period_at(elapsed()) || pending_total(record, "deduction", period) + amount > min(record.current_rate(), settings.deduction_limit))
		return FALSE
	var/datum/payroll_adjustment/item = make_adjustment(record, "deduction", amount, reason, initiator, period)
	requests[request_id] = item.id
	log_decision(record, initiator, "Deduction [item.id]: [amount], period [period]", reason, initiator_name)
	return item.id

// Trusted gameplay API, never dispatched directly by Topic(). Reserve real department money now.
// request_id must be stable for the originating event; retries return the original result.
/datum/payroll_controller/proc/queue_bonus(datum/payroll_record/record, datum/money_account/source, amount, reason, initiator, request_id, department, period, initiator_name = "Payroll service")
	if(!started || !record || records[record.id] != record || !record.active || !payroll_valid_amount(amount) || !valid_reason(reason))
		return FALSE
	if(!istext(initiator) || !length(initiator) || !istext(request_id) || !length(request_id) || length(request_id) > 200)
		return FALSE
	if(requests[request_id])
		return requests[request_id]
	if(department != record.department || source != department_accounts[department] || period != period_at(elapsed()))
		return FALSE
	if(pending_total(record, "bonus", period) + amount > settings.bonus_limit || !account_valid(record.account))
		return FALSE
	if(!safe_transfer(source, escrow, amount, "Payroll bonus reservation [request_id]: [reason]"))
		return FALSE
	var/datum/payroll_adjustment/item = make_adjustment(record, "bonus", amount, reason, initiator, period)
	item.source = source
	item.department = department
	requests[request_id] = item.id
	log_decision(record, initiator, "Reserved bonus [item.id]: [amount], period [period]", reason, initiator_name)
	return item.id

/datum/payroll_controller/proc/make_adjustment(datum/payroll_record/record, kind, amount, reason, initiator, period)
	RETURN_TYPE(/datum/payroll_adjustment)
	var/datum/payroll_adjustment/item = new
	item.id = "decision-[++next_id]"
	item.kind = kind
	item.amount = amount
	item.reason = reason
	item.initiator = initiator
	item.department = record.department
	item.recipient = record.account
	item.period = period
	record.adjustments += item
	record.revision++
	return item

/datum/payroll_controller/proc/cancel_adjustment(mob/user, datum/payroll_record/record, id, reason, revision)
	if(!can_manage(user, record) || revision != record.revision || !valid_reason(reason))
		return FALSE
	for(var/datum/payroll_adjustment/item as anything in record.adjustments)
		if(item.id != id || item.status != "pending")
			continue
		cancel_item(item)
		record.revision++
		log_decision(record, key_name(user), "Cancelled [item.id]", reason, user.real_name)
		return TRUE
	return FALSE

/datum/payroll_controller/proc/cancel_item(datum/payroll_adjustment/item)
	if(item.status != "pending")
		return
	item.status = item.kind == "bonus" ? "refund pending" : "cancelled"
	if(item.kind == "bonus")
		refund_bonus(item)

/datum/payroll_controller/proc/transfer_employee(mob/user, datum/payroll_record/record, datum/job/job, reason, revision)
	if(!can_transfer(user, record) || record.revision != revision || !job || !(job.type in GLOB.using_map.allowed_jobs) || !valid_reason(reason))
		return FALSE
	var/datum/payroll_record/actor = operator_record(user)
	if(job.head_position && !istype(actor.job, /datum/job/captain))
		return FALSE
	set_employment(record, job)
	log_decision(record, key_name(user), "Transferred to [job.title]", reason, user.real_name)
	return TRUE

/datum/payroll_controller/proc/set_employment(datum/payroll_record/record, datum/job/job)
	accrue(record, elapsed())
	for(var/datum/payroll_adjustment/item as anything in record.adjustments)
		cancel_item(item)
	record.adjustment = 0
	record.job = job
	record.department = job.department
	record.base_rate = settings.rate_for(job)
	record.active = TRUE
	record.revision++
	var/datum/mind/mind = record.employee?.resolve()
	if(mind)
		mind.assigned_job = job
		mind.assigned_role = job.title
	record.notify("Employment changed to [job.title]; salary rate [record.current_rate()].")

/datum/payroll_controller/proc/end_employment(datum/payroll_record/record, reason)
	if(!record?.active)
		return
	accrue(record, elapsed())
	record.active = FALSE
	record.revision++
	for(var/datum/payroll_adjustment/item as anything in record.adjustments)
		cancel_item(item)
	log_decision(record, "Employment lifecycle", "Employment ended", reason)

/datum/payroll_controller/proc/admin_rate(mob/user, datum/payroll_record/record, rate, reason, revision)
	if(!check_rights(R_ADMIN, FALSE, user) || records[record?.id] != record || !record || record.revision != revision)
		return FALSE
	if(!payroll_valid_amount(rate, TRUE) || !valid_reason(reason))
		return FALSE
	accrue(record, elapsed())
	record.adjustment = rate - record.base_rate
	record.revision++
	log_decision(record, key_name(user), "ADMIN salary correction: [rate]", reason, "Administration")
	message_admins("[key_name_admin(user)] corrected [record.name]'s payroll rate to [rate]: [html_encode(reason)]")
	return TRUE

/datum/payroll_controller/proc/bind_card(mob/user, datum/payroll_record/record, obj/item/card/id/card, reason, revision)
	if(!can_transfer(user, record) || revision != record.revision || !card || !valid_reason(reason))
		return FALSE
	if(card.registered_name != record.name || card.associated_account_number != record.account?.account_number)
		return FALSE
	card.payroll_id = record.id
	record.revision++
	log_decision(record, key_name(user), "Replacement ID bound to employment", reason, user.real_name)
	return TRUE
