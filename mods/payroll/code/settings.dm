// Independent balance values; economic_power and character wealth are deliberately unused.
/datum/payroll_settings
	var/interval = 15 MINUTES
	var/first_payment = 15 MINUTES
	var/raise_limit = 0.25
	var/bonus_limit = 500
	var/deduction_limit = 500
	var/eva_bonus = 40
	var/corporate_funding = TRUE
	var/initial_fund = 0
	var/latejoin_policy = "prorate"
	var/list/factions = list(MOB_FACTION_CREW)
	var/list/rates = list()
	var/list/scopes = list()
	var/list/head_reports = list()

/datum/payroll_settings/proc/default_rates()
	scopes = list(
		"[/datum/job]/hop" = list("Service", "Supply", "Civilian"),
		"[/datum/job]/rd" = list("Science", "Research", "Exploration"),
		"[/datum/job]/cmo" = list("Medical"),
		"[/datum/job]/chief_engineer" = list("Engineering"),
		"[/datum/job]/hos" = list("Security"),
		"[/datum/job]/qm" = list("Supply"),
		"[/datum/job]/chief_steward" = list("Service"),
		"[/datum/job]/exploration_leader" = list("Exploration"))
	head_reports = list(
		"[/datum/job]/hop" = list("[/datum/job]/qm", "[/datum/job]/chief_steward"),
		"[/datum/job]/rd" = list("[/datum/job]/exploration_leader"))
	set_rates(250, list("captain"))
	set_rates(180, list("hop", "rd", "cmo", "chief_engineer", "hos", "qm", "chief_steward", "exploration_leader"))
	set_rates(120, list("iaa", "iso", "adjutant", "senior_engineer", "engineer", "infsys", "roboticist", "warden", "detective", "officer"))
	set_rates(120, list("senior_doctor", "doctor", "chemist", "psychiatrist", "biomech", "senior_scientist", "scientist", "explorer", "explorer_pilot", "explorer_medic", "explorer_engineer", "mining"))
	set_rates(80, list("engineer_trainee", "doctor_trainee", "scientist_assistant", "security_assistant", "cargo_tech", "cargo_assistant"))
	set_rates(40, list("janitor", "cook", "bartender", "steward", "chaplain", "actor"))
	set_rates(0, list("assistant", "vagabond"))

/datum/payroll_settings/proc/set_rates(amount, list/jobs)
	for(var/job in jobs)
		rates["[/datum/job]/[job]"] = amount

/datum/payroll_settings/proc/load_file(path = "config/payroll.json")
	default_rates()
	if(!fexists(path))
		return
	var/list/data
	try
		data = json_decode(file2text(path))
	catch(var/exception/error)
		log_debug("PAYROLL: invalid configuration: [error]")
		return
	if(islist(data))
		apply_config(data)

/datum/payroll_settings/proc/apply_config(list/data)
	load_number(data, "interval", 1 MINUTE, 1 HOUR)
	load_number(data, "first_payment", 1 MINUTE, 1 HOUR)
	load_number(data, "raise_limit", 0, 1, FALSE)
	load_number(data, "bonus_limit", 0, 1000000)
	load_number(data, "deduction_limit", 0, 1000000)
	load_number(data, "eva_bonus", 0, 1000000)
	load_number(data, "initial_fund", 0, 1000000)
	if(data["corporate_funding"] in list(TRUE, FALSE))
		corporate_funding = data["corporate_funding"]
	if(data["latejoin_policy"] in list("prorate", "next_period"))
		latejoin_policy = data["latejoin_policy"]
	if(islist(data["factions"]))
		factions = data["factions"]
	load_rates(data["rates"])

/datum/payroll_settings/proc/load_number(list/data, key, minimum, maximum, integer = TRUE)
	var/value = data[key]
	if(isnum(value) && value >= minimum && value <= maximum && (!integer || round(value) == value))
		vars[key] = value

/datum/payroll_settings/proc/load_rates(list/data)
	if(!islist(data))
		return
	for(var/path in data)
		var/value = data[path]
		if(istext(path) && findtext(path, "[/datum/job]/") == 1 && payroll_valid_amount(value, TRUE))
			rates[path] = value

/datum/payroll_settings/proc/rate_for(datum/job/job)
	if(!job || !job.account_allowed || !(job.faction in factions))
		return 0
	var/value = isnull(job.payroll_rate) ? rates["[job.type]"] : job.payroll_rate
	return payroll_valid_amount(value, TRUE) ? value : 0

// BYOND integers are exact in this range. Never pass signed/fractional UI amounts to banking.
/proc/payroll_valid_amount(value, allow_zero = FALSE)
	return isnum(value) && value >= (allow_zero ? 0 : 1) && value <= 1000000 && round(value) == value
