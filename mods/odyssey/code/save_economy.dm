/// Collects Sierra station + department account balances.
/// Personal balances are stored in character_persist snapshots.
/proc/odyssey_collect_economy()
	var/list/data = list(
		"station" = null,
		"departments" = list()
	)
	if (istype(station_account))
		data["station"] = list(
			"account_number" = station_account.account_number,
			"money" = station_account.money
		)
	for (var/dept in department_accounts)
		var/datum/money_account/A = department_accounts[dept]
		if (!istype(A))
			continue
		data["departments"][dept] = list(
			"account_number" = A.account_number,
			"money" = A.money
		)
	return data


/proc/odyssey_apply_economy(list/data)
	if (!islist(data))
		return
	var/list/station = data["station"]
	if (islist(station) && istype(station_account) && !isnull(station["money"]))
		station_account.money = station["money"]
	var/list/departments = data["departments"]
	if (!islist(departments))
		return
	for (var/dept in departments)
		var/datum/money_account/A = department_accounts[dept]
		var/list/entry = departments[dept]
		if (!istype(A) || !islist(entry) || isnull(entry["money"]))
			continue
		A.money = entry["money"]
	log_debug("ODYSSEY: economy balances applied")
