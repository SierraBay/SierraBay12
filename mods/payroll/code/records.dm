/datum/payroll_record
	var/id
	var/weakref/employee
	var/datum/money_account/account
	var/datum/job/job
	var/name
	var/department
	var/base_rate = 0
	var/adjustment = 0
	var/checkpoint = 0
	var/active = TRUE
	var/revision = 0
	var/last_period = 0
	var/list/earnings = list()
	var/list/statements = list()
	var/list/adjustments = list()
	var/list/history = list()

/datum/payroll_record/proc/current_rate()
	return max(0, base_rate + adjustment)

/datum/payroll_record/Destroy()
	employee = null
	account = null
	job = null
	for(var/id in statements)
		qdel(statements[id])
	statements = null
	QDEL_NULL_LIST(adjustments)
	earnings = null
	history = null
	return ..()

/datum/payroll_statement
	var/period
	var/gross = 0
	var/salary = 0
	var/status = "pending"
	var/list/allocations = list()
	var/list/deductions = list()

/datum/payroll_statement/Destroy()
	allocations = null
	deductions = null
	return ..()

/datum/payroll_adjustment
	var/id
	var/kind
	var/amount = 0
	var/reason
	var/initiator
	var/department
	var/period
	var/status = "pending"
	var/datum/money_account/source
	var/datum/money_account/recipient

/datum/payroll_adjustment/Destroy()
	source = null
	recipient = null
	return ..()
