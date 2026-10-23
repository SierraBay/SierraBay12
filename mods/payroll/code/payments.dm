/datum/payroll_controller/proc/account_valid(datum/money_account/account)
	return istype(account) && !QDELETED(account) && (account in all_money_accounts)

/datum/payroll_controller/proc/account_ready(datum/money_account/account)
	return account_valid(account) && !account.suspended && isnum(account.money) && account.money >= 0 && account.money <= 8000000

/datum/payroll_controller/proc/safe_transfer(datum/money_account/source, datum/money_account/target, amount, reason)
	if(!payroll_valid_amount(amount) || source == target || !account_ready(source) || !account_ready(target))
		return FALSE
	if(source.money < amount || target.money + amount > 8000000)
		return FALSE
	// Sierra's transfer() is synchronous. Validation and both balance updates cannot interleave.
	return source.transfer(target, amount, reason)

/datum/payroll_controller/proc/period_stats(period)
	RETURN_TYPE(/list)
	var/key = "[period]"
	if(!period_totals[key])
		period_totals[key] = list("subsidy" = 0, "salary" = 0, "bonus" = 0)
	return period_totals[key]

/datum/payroll_controller/proc/subsidize(amount, period)
	if(!payroll_valid_amount(amount) || !account_ready(fund) || fund.money + amount > 8000000)
		return FALSE
	if(!fund.deposit(amount, "Corporate payroll subsidy; period [period]", "Corporate Payroll"))
		return FALSE
	total_subsidy += amount
	var/list/stats = period_stats(period)
	stats["subsidy"] += amount
	return TRUE

/datum/payroll_controller/proc/process_record(datum/payroll_record/record, period)
	if(!record || records[record.id] != record || period < 1 || period_end(period) > elapsed())
		return FALSE
	if(record.last_period < period)
		accrue(record, period_end(period))
		make_statement(record, period)
		record.last_period = period
	for(var/key in record.statements)
		var/datum/payroll_statement/statement = record.statements[key]
		if(statement.period <= period && statement.status != "paid")
			pay_salary(record, statement)
	process_adjustments(record, period)
	return TRUE

/datum/payroll_controller/proc/make_statement(datum/payroll_record/record, period)
	var/key = "[period]"
	if(record.statements[key])
		return
	var/datum/payroll_statement/statement = new
	statement.period = period
	var/list/parts = record.earnings[key]
	if(parts)
		statement.allocations = parts.Copy()
		for(var/department in parts)
			statement.gross += parts[department]
	statement.gross = round(statement.gross)
	record.earnings -= key
	record.statements[key] = statement

/datum/payroll_controller/proc/pay_salary(datum/payroll_record/record, datum/payroll_statement/statement)
	if(statement.status == "paid" || records[record.id] != record || record.statements["[statement.period]"] != statement || period_end(statement.period) > elapsed())
		return
	if(!account_ready(record.account))
		statement.status = "deferred: account unavailable"
		return
	var/amount = salary_after_deductions(record, statement)
	if(amount && !fund_salary(record, statement, amount))
		statement.status = "deferred: funding unavailable"
		return
	statement.salary = amount
	statement.status = "paid"
	apply_deductions(record, statement)
	total_salary += amount
	var/list/stats = period_stats(statement.period)
	stats["salary"] += amount
	track_departments(statement)
	if(amount)
		record.notify("Period [statement.period]: salary [amount] [GLOB.using_map.local_currency_name_short]; balance [record.account.money].")

/datum/payroll_controller/proc/fund_salary(datum/payroll_record/record, datum/payroll_statement/statement, amount)
	if(!payroll_valid_amount(amount) || !account_ready(fund) || record.account.money + amount > 8000000)
		return FALSE
	var/shortfall = max(0, amount - fund.money)
	if(shortfall && (!settings.corporate_funding || !subsidize(shortfall, statement.period)))
		return FALSE
	return safe_transfer(fund, record.account, amount, "Salary; period [statement.period]; [record.id]")

/datum/payroll_controller/proc/salary_after_deductions(datum/payroll_record/record, datum/payroll_statement/statement)
	var/amount = statement.gross
	statement.deductions.Cut()
	for(var/datum/payroll_adjustment/item as anything in record.adjustments)
		if(item.kind == "deduction" && item.status == "pending" && item.period == statement.period)
			amount = max(0, amount - item.amount)
			statement.deductions += item.id
	return amount

/datum/payroll_controller/proc/apply_deductions(datum/payroll_record/record, datum/payroll_statement/statement)
	for(var/datum/payroll_adjustment/item as anything in record.adjustments)
		if(item.id in statement.deductions)
			item.status = "applied"

/datum/payroll_controller/proc/track_departments(datum/payroll_statement/statement)
	var/total = 0
	for(var/department in statement.allocations)
		total += statement.allocations[department]
	if(!total)
		return
	for(var/department in statement.allocations)
		department_totals[department] += statement.salary * statement.allocations[department] / total

/datum/payroll_controller/proc/process_adjustments(datum/payroll_record/record, period)
	for(var/datum/payroll_adjustment/item as anything in record.adjustments)
		if(item.status == "refund pending")
			refund_bonus(item)
		else if(item.kind == "bonus" && item.status == "pending" && item.period <= period)
			pay_bonus(record, item)

/datum/payroll_controller/proc/pay_bonus(datum/payroll_record/record, datum/payroll_adjustment/item)
	if(records[record.id] != record || !(item in record.adjustments) || period_end(item.period) > elapsed())
		return FALSE
	if(item.status != "pending" || !safe_transfer(escrow, item.recipient, item.amount, "Bonus [item.id]; period [item.period]: [item.reason]"))
		return FALSE
	item.status = "paid"
	total_bonus += item.amount
	var/list/stats = period_stats(item.period)
	stats["bonus"] += item.amount
	department_totals[item.department] += item.amount
	record.notify("Bonus [item.amount] [GLOB.using_map.local_currency_name_short] paid: [item.reason].")
	return TRUE

/datum/payroll_controller/proc/refund_bonus(datum/payroll_adjustment/item)
	if(item.status != "refund pending")
		return FALSE
	if(!safe_transfer(escrow, item.source, item.amount, "Cancelled payroll bonus [item.id] refund"))
		return FALSE
	item.status = "cancelled"
	return TRUE
