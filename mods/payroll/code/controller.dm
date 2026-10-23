SUBSYSTEM_DEF(payroll)
	name = "Payroll"
	wait = 1 SECOND
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	var/datum/payroll_controller/ledger

/datum/controller/subsystem/payroll/Initialize(start_uptime)
	if(!ledger)
		ledger = new
		ledger.settings.load_file()
	return ..()

/datum/controller/subsystem/payroll/Recover(datum/controller/subsystem/payroll/old)
	ledger = old.ledger
	old.ledger = null

/datum/controller/subsystem/payroll/Destroy()
	QDEL_NULL(ledger)
	return ..()

/datum/controller/subsystem/payroll/fire(resumed)
	if(!ledger?.started)
		return
	if(!length(ledger.queue) && ledger.elapsed() < ledger.period_end(ledger.closed_period + 1))
		return
	ledger.begin_batch()
	while(length(ledger.queue))
		ledger.process_next()
		if(MC_TICK_CHECK)
			return
	ledger.finish_batch()

/datum/payroll_controller
	var/datum/payroll_settings/settings
	var/datum/money_account/fund
	var/datum/money_account/escrow
	var/started = FALSE
	var/started_at = 0
	var/closed_period = 0
	var/batch_period = 0
	var/next_id = 0
	var/list/records = list()
	var/list/accounts = list()
	var/list/requests = list()
	var/list/queue = list()
	var/list/audit = list()
	var/list/list/period_totals = list()
	var/list/department_totals = list()
	var/total_subsidy = 0
	var/total_salary = 0
	var/total_bonus = 0

/datum/payroll_controller/New()
	..()
	settings = new
	settings.default_rates()

/datum/payroll_controller/Destroy()
	for(var/id in records)
		qdel(records[id])
	records = null
	QDEL_NULL(settings)
	accounts = null
	requests = null
	queue = null
	audit = null
	period_totals = null
	department_totals = null
	// Bank accounts and their transaction logs belong to the existing banking system.
	fund = null
	escrow = null
	return ..()

/datum/payroll_controller/proc/start()
	if(started)
		return
	started_at = world.time
	started = TRUE
	fund = create_account("Corporate Payroll Fund", "Corporate Payroll", 0, ACCOUNT_TYPE_DEPARTMENT)
	escrow = create_account("Payroll Bonus Escrow", "Corporate Payroll", 0, ACCOUNT_TYPE_DEPARTMENT)
	fund.security_level = 2
	escrow.security_level = 2
	if(settings.initial_fund)
		subsidize(settings.initial_fund, 0)

/datum/payroll_controller/proc/elapsed()
	return started ? max(0, world.time - started_at) : 0

/datum/payroll_controller/proc/period_at(time)
	return time < settings.first_payment ? 1 : 2 + round((time - settings.first_payment) / settings.interval)

/datum/payroll_controller/proc/period_end(period)
	return settings.first_payment + (period - 1) * settings.interval

/datum/payroll_controller/proc/find_record(datum/mind/mind)
	RETURN_TYPE(/datum/payroll_record)
	return mind ? records[mind.payroll_id] : null

/datum/payroll_controller/proc/register(datum/mind/mind, datum/job/job)
	if(!mind || !mind.key || !job || !ishuman(mind.current) || mind.current.mind != mind)
		return
	var/datum/payroll_record/record = find_record(mind)
	if(record)
		if(record.job != job)
			set_employment(record, job)
		return record
	if(!account_valid(mind.initial_account) || mind.initial_account.account_type != ACCOUNT_TYPE_PERSONAL || accounts[mind.initial_account])
		return
	record = new_record(mind, job)
	records[record.id] = record
	accounts[record.account] = record
	mind.payroll_id = record.id
	return record

/datum/payroll_controller/proc/new_record(datum/mind/mind, datum/job/job)
	RETURN_TYPE(/datum/payroll_record)
	var/datum/payroll_record/record = new
	record.id = "employee-[++next_id]"
	record.employee = weakref(mind)
	record.account = mind.initial_account
	record.name = mind.current.real_name
	record.checkpoint = elapsed()
	if(settings.latejoin_policy == "next_period" && record.checkpoint)
		record.checkpoint = period_end(period_at(record.checkpoint))
	record.job = job
	record.department = job.department
	record.base_rate = settings.rate_for(job)
	return record

/datum/payroll_controller/proc/accrue(datum/payroll_record/record, until)
	while(record.checkpoint < until)
		var/period = period_at(record.checkpoint)
		var/segment_end = min(until, period_end(period))
		var/key = "[period]"
		if(record.active && record.current_rate())
			var/list/parts = record.earnings[key]
			if(!parts)
				parts = list()
				record.earnings[key] = parts
			parts[record.department || "Independent"] += record.current_rate() * (segment_end - record.checkpoint) / settings.interval
		record.checkpoint = segment_end

/datum/payroll_controller/proc/begin_batch()
	if(batch_period || !started || elapsed() < period_end(closed_period + 1))
		return FALSE
	batch_period = closed_period + 1
	queue = records.Copy()
	return TRUE

/datum/payroll_controller/proc/process_next()
	var/key = queue[1]
	var/datum/payroll_record/record = records[key]
	if(record)
		process_record(record, batch_period)
	queue -= key

/datum/payroll_controller/proc/finish_batch()
	if(!batch_period || length(queue))
		return FALSE
	closed_period = batch_period
	batch_period = 0
	log_debug("PAYROLL: period [closed_period]; salary [total_salary], bonuses [total_bonus], corporate issuance [total_subsidy] this round")
	return TRUE

/datum/payroll_controller/proc/log_decision(datum/payroll_record/record, actor, action, reason, actor_name = "Payroll service")
	var/list/entry = list("id" = record.id, "time" = stationtime2text(), "employee" = record.name, "department" = record.department, "actor" = actor, "actor_name" = actor_name, "action" = action, "reason" = reason)
	audit.Add(list(entry))
	record.history.Add(list(entry))
	log_admin("PAYROLL: [actor]: [action] for [record.name] ([record.id]): [reason]")
