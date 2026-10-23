/datum/computer_file/program/payroll
	filename = "payroll"
	filedesc = "Finance Management"
	extended_desc = "Personal payslips and authorized staff salary management."
	program_icon_state = "generic"
	program_key_state = "generic_key"
	size = 4
	requires_ntnet = FALSE
	available_on_ntnet = TRUE
	nanomodule_path = /datum/nano_module/program/payroll
	usage_flags = PROGRAM_ALL
	category = PROG_OFFICE

/datum/nano_module/program/payroll
	name = "Finance Management"
	available_to_ai = FALSE

/datum/nano_module/program/payroll/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, state = GLOB.default_state)
	ui ||= SSnano.get_open_ui(user, src, ui_key)
	var/opening = !ui
	if(opening)
		ui = new /datum/nanoui/payroll(user, src, ui_key, "mods-payroll.tmpl", name, 850, 700, state = state)
	var/datum/nanoui/payroll/window = ui
	ASSERT(istype(window))
	var/list/data = host.initial_data(program)
	SSpayroll.ledger.finance_data(user, data)
	window.view.apply(data)
	if(opening)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
	else
		SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

// Presentation state belongs to one viewer's open window, never to the shared program.
/datum/nanoui/payroll
	var/datum/payroll_view/view = new

/datum/nanoui/payroll/Destroy()
	QDEL_NULL(view)
	return ..()

/datum/payroll_view
	var/active_tab
	var/list/expanded = list()

/datum/payroll_view/proc/allowed_tabs(list/data)
	var/list/tabs = list("personal", "audit")
	if(data["can_view_staff"])
		tabs += "staff"
	if(data["captain"])
		tabs += "overview"
	return tabs

/datum/payroll_view/proc/apply(list/data)
	if(!(active_tab in allowed_tabs(data)))
		active_tab = data["captain"] ? "overview" : (data["can_view_staff"] ? "staff" : "personal")
	for(var/section in expanded.Copy())
		if(!can_expand(section, data))
			expanded -= section
	data["active_tab"] = active_tab
	data["expanded"] = expanded.Copy()

/datum/payroll_view/proc/select_tab(tab, list/data)
	if(!(tab in allowed_tabs(data)))
		return FALSE
	active_tab = tab
	return TRUE

/datum/payroll_view/proc/can_expand(section, list/data)
	if(section == "help")
		return TRUE
	if(section in list("budgets", "departments", "periods"))
		return !!data["captain"]
	for(var/list/record as anything in data["staff"])
		if(section == "staff-[record["id"]]" && length(record["adjustments"]))
			return TRUE
	return FALSE

/datum/payroll_view/proc/toggle(section, list/data)
	if(!can_expand(section, data))
		return FALSE
	if(expanded[section])
		expanded -= section
	else
		expanded[section] = TRUE
	return TRUE

/datum/payroll_controller/proc/finance_data(mob/user, list/data)
	var/datum/payroll_record/personal = find_record(user.mind)
	data["personal"] = personal ? record_data(personal) : null
	data["next_payment"] = max(0, round((period_end(period_at(elapsed())) - elapsed()) / 10))
	data["period"] = period_at(elapsed())
	data["staff"] = list()
	for(var/id in records)
		var/datum/payroll_record/record = records[id]
		if(can_manage(user, record) || can_transfer(user, record))
			data["staff"] += list(staff_data(user, record))
	data["staff_groups"] = group_staff(data["staff"])
	add_audit_data(user, data)
	add_authority_data(user, data)
	if(data["captain"])
		add_overview(data)

/datum/payroll_controller/proc/add_authority_data(mob/user, list/data)
	var/datum/payroll_record/actor = operator_record(user)
	data["captain"] = actor && istype(actor.job, /datum/job/captain)
	data["can_view_staff"] = actor && (data["captain"] || istype(actor.job, /datum/job/hop) || length(settings.scopes["[actor.job.type]"]))

/datum/payroll_controller/proc/group_staff(list/staff)
	var/list/groups = list()
	for(var/list/row as anything in sortByKey(staff, "name"))
		var/department = row["department"]
		if(!groups[department])
			groups[department] = list("name" = department, "budget" = row["budget"], "staff" = list())
		var/list/group = groups[department]
		var/list/members = group["staff"]
		members += list(row)
	var/list/result = list()
	for(var/department in sortList(groups))
		result += list(groups[department])
	return result

/datum/payroll_controller/proc/record_data(datum/payroll_record/record, include_statements = TRUE)
	var/list/data = list("id" = record.id, "revision" = record.revision, "name" = html_encode(record.name), "job" = html_encode(record.job.title))
	data["department"] = html_encode(record.department || "Independent")
	data["base"] = record.base_rate
	data["rate"] = record.current_rate()
	data["active"] = record.active
	data["balance"] = account_valid(record.account) ? record.account.money : "Unavailable"
	data["adjustment"] = record.adjustment
	data["adjustments"] = adjustment_data(record)
	data["statements"] = include_statements ? statement_data(record) : list()
	return data

/datum/payroll_controller/proc/staff_data(mob/user, datum/payroll_record/record)
	var/list/data = record_data(record, FALSE)
	data["can_transfer"] = can_transfer(user, record)
	data["can_manage"] = can_manage(user, record)
	var/datum/money_account/budget = department_accounts[record.department]
	data["budget"] = account_valid(budget) ? budget.money : 0
	return data

/datum/payroll_controller/proc/adjustment_data(datum/payroll_record/record)
	var/list/rows = list()
	for(var/datum/payroll_adjustment/item as anything in record.adjustments)
		if(!(item.status in list("pending", "refund pending")))
			continue
		rows.Add(list(list("id" = item.id, "kind" = item.kind, "amount" = item.amount, "period" = item.period, "status" = item.status, "reason" = html_encode(item.reason), "employee" = record.id, "revision" = record.revision)))
	return rows

/datum/payroll_controller/proc/statement_data(datum/payroll_record/record)
	var/list/rows = list()
	var/first = max(1, length(record.statements) - 19)
	for(var/i = length(record.statements) to first step -1)
		var/datum/payroll_statement/statement = record.statements[record.statements[i]]
		rows.Add(list(list("period" = statement.period, "gross" = statement.gross, "salary" = statement.salary, "bonus" = paid_bonus(record, statement.period), "status" = statement.status)))
	return rows

/datum/payroll_controller/proc/paid_bonus(datum/payroll_record/record, period)
	var/total = 0
	for(var/datum/payroll_adjustment/item as anything in record.adjustments)
		if(item.period == period && item.kind == "bonus" && item.status == "paid")
			total += item.amount
	return total

/datum/payroll_controller/proc/add_audit_data(mob/user, list/data)
	var/list/rows = list()
	var/show_actor_keys = check_rights(R_ADMIN, FALSE, user)
	for(var/i = length(audit) to 1 step -1)
		var/list/entry = audit[i]
		var/datum/payroll_record/record = records[entry["id"]]
		if(!record || (record != find_record(user.mind) && !can_manage(user, record)))
			continue
		var/list/row = list()
		for(var/key in list("id", "time", "employee", "department", "action", "reason"))
			row[key] = html_encode("[entry[key]]")
		row["actor"] = html_encode(show_actor_keys ? entry["actor"] : (entry["actor_name"] || "Payroll service"))
		rows.Add(list(row))
		if(length(rows) >= 30)
			break
	data["audit"] = rows

/datum/payroll_controller/proc/add_overview(list/data)
	add_budget_overview(data)
	data["subsidy"] = total_subsidy
	data["salary_paid"] = total_salary
	data["bonus_paid"] = total_bonus
	data["fund_balance"] = account_valid(fund) ? fund.money : 0
	data["escrow_balance"] = account_valid(escrow) ? escrow.money : 0
	data["departments"] = list()
	data["periods"] = list()
	for(var/department in department_totals)
		data["departments"] += list(list("name" = html_encode(department), "paid" = round(department_totals[department], 0.01)))
	for(var/period in period_totals)
		var/list/row = period_totals[period].Copy()
		row["period"] = period
		data["periods"] += list(row)

/datum/payroll_controller/proc/add_budget_overview(list/data)
	data["wage_bill"] = 0
	data["budgets"] = list()
	for(var/id in records)
		var/datum/payroll_record/record = records[id]
		if(record.active)
			data["wage_bill"] += record.current_rate()
	var/list/seen = list()
	for(var/key in department_accounts)
		var/datum/money_account/account = department_accounts[key]
		if(!account_valid(account) || (account in seen))
			continue
		seen += account
		data["budgets"] += list(list("name" = html_encode(account.account_name), "balance" = account.money))

/datum/nano_module/program/payroll/Topic(href, href_list)
	if(..())
		return TRUE
	if(!action_allowed(usr))
		return FALSE
	if(href_list["payroll_tab"] || href_list["payroll_toggle"] || href_list["payroll_refresh"])
		return navigate(usr, href_list)
	if(!href_list["payroll_action"])
		return FALSE
	var/datum/payroll_controller/ledger = SSpayroll.ledger
	var/datum/payroll_record/record = ledger.records[href_list["employee"]]
	if(!ledger.can_manage(usr, record) && !ledger.can_transfer(usr, record))
		return TRUE
	var/revision = text2num(href_list["revision"])
	if(revision != record.revision)
		to_chat(usr, SPAN_WARNING("Payroll changed. Refresh and try again."))
		return TRUE
	prompt_action(usr, record, href_list, revision)
	return TRUE

/datum/nano_module/program/payroll/proc/navigate(mob/user, list/params)
	var/datum/nanoui/payroll/window = SSnano.get_open_ui(user, src, "main")
	if(!istype(window))
		return FALSE
	var/list/data = list()
	SSpayroll.ledger.finance_data(user, data)
	if(params["payroll_tab"])
		window.view.select_tab(params["payroll_tab"], data)
	if(params["payroll_toggle"])
		window.view.toggle(params["payroll_toggle"], data)
	return TRUE

/datum/nano_module/program/payroll/proc/action_allowed(mob/user)
	return program?.computer && SSnano.get_open_ui(user, src, "main") && CanUseTopic(user, GLOB.default_state) == STATUS_INTERACTIVE

/datum/nano_module/program/payroll/proc/prompt_action(mob/user, datum/payroll_record/record, list/params, revision)
	var/action = params["payroll_action"]
	var/amount = 0
	var/datum/job/job
	if(action in list("rate", "bonus", "deduction"))
		amount = input(user, action == "rate" ? "Fixed adjustment to base pay (positive or negative)." : "Amount in whole currency units.", "Payroll") as num|null
		if(isnull(amount))
			return
	else if(action == "transfer")
		job = select_job(user)
		if(!job)
			return
	var/reason = input(user, "Reason for this decision (1-200 characters).", "Payroll") as text|null
	if(!action_allowed(user) || !istext(reason))
		return
	if(!submit_action(user, record, action, amount, sanitize(reason, 200), revision, params["decision"], job))
		to_chat(user, SPAN_WARNING("Payroll request rejected. Check authority, limits, revision, and available budget."))
	SSnano.update_uis(src)

/datum/nano_module/program/payroll/proc/select_job(mob/user)
	RETURN_TYPE(/datum/job)
	var/list/jobs = list()
	for(var/type in GLOB.using_map.allowed_jobs)
		var/datum/job/job = SSjobs.get_by_path(type)
		if(job)
			jobs[job.title] = job
	var/title = input(user, "Select the new employment. This does not change physical ID access.", "Payroll transfer") as null|anything in jobs
	return jobs[title]

/datum/nano_module/program/payroll/proc/submit_action(mob/user, datum/payroll_record/record, action, amount, reason, revision, decision, datum/job/job)
	var/datum/payroll_controller/ledger = SSpayroll.ledger
	switch(action)
		if("rate")
			return ledger.change_rate(user, record, amount, reason, revision)
		if("reset")
			return ledger.change_rate(user, record, 0, reason, revision)
		if("bonus", "deduction")
			return ledger.request_adjustment(user, record, action, amount, reason, revision)
		if("cancel")
			return ledger.cancel_adjustment(user, record, decision, reason, revision)
		if("transfer")
			return ledger.transfer_employee(user, record, job, reason, revision)
		if("bind")
			return ledger.bind_card(user, record, program.computer.get_inserted_id(), reason, revision)
	return FALSE
