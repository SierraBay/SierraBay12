/// department_accounts has EN/RU alias keys for the same datum (Science/Research/Научный, …).
/// Returns assoc dept_name → account with one entry per unique account (first key wins).
/proc/odyssey_unique_department_accounts()
	var/list/seen = list()
	var/list/out = list()
	for (var/dept in department_accounts)
		var/datum/money_account/A = department_accounts[dept]
		if (!istype(A))
			continue
		var/token = "\ref[A]"
		if (seen[token])
			continue
		seen[token] = TRUE
		out[dept] = A
	return out


#define ODYSSEY_TX_LOG_MAX 100

/// Frozen display-only transaction for restored history (must not change balances).
/datum/transaction/archive
	var/display_target = ""
	var/display_source = ""


/datum/transaction/archive/New()
	// Skip /datum/transaction/New — we set fields from JSON ourselves.
	return


/datum/transaction/archive/get_target_name()
	return display_target


/datum/transaction/archive/get_source_name()
	return display_source


/datum/transaction/archive/valid()
	return TRUE


/datum/transaction/archive/perform()
	return FALSE


/proc/odyssey_serialize_transaction(datum/transaction/T)
	if (!istype(T))
		return null
	return list(
		"purpose" = T.purpose || "",
		"amount" = T.amount,
		"date" = T.date || "",
		"time" = T.time || "",
		"target_name" = T.get_target_name() || "",
		"source_name" = T.get_source_name() || ""
	)


/proc/odyssey_serialize_transaction_log(datum/money_account/A)
	var/list/out = list()
	if (!istype(A) || !length(A.transaction_log))
		return out
	var/start = 1
	var/total = length(A.transaction_log)
	if (total > ODYSSEY_TX_LOG_MAX)
		start = total - ODYSSEY_TX_LOG_MAX + 1
	for (var/i = start; i <= total; i++)
		var/list/entry = odyssey_serialize_transaction(A.transaction_log[i])
		if (islist(entry))
			out += list(entry)
	return out


/proc/odyssey_apply_transaction_log(datum/money_account/A, list/entries)
	if (!istype(A))
		return
	A.transaction_log.Cut()
	if (!islist(entries))
		return
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		var/datum/transaction/archive/T = new
		T.purpose = entry["purpose"] || ""
		T.amount = text2num(entry["amount"])
		if (isnull(T.amount))
			T.amount = 0
		T.date = entry["date"] || ""
		T.time = entry["time"] || ""
		T.display_target = entry["target_name"] || ""
		T.display_source = entry["source_name"] || ""
		A.transaction_log += T


/// Collects Sierra ship + department account balances and transaction history.
/// Personal balances/logs are stored in character_persist snapshots.
/proc/odyssey_collect_economy()
	var/list/data = list(
		"station" = null,
		"departments" = list()
	)
	if (istype(station_account))
		data["station"] = list(
			"account_number" = station_account.account_number,
			"money" = station_account.money,
			"transactions" = odyssey_serialize_transaction_log(station_account)
		)
	var/list/unique = odyssey_unique_department_accounts()
	for (var/dept in unique)
		var/datum/money_account/A = unique[dept]
		data["departments"][dept] = list(
			"account_number" = A.account_number,
			"money" = A.money,
			"transactions" = odyssey_serialize_transaction_log(A)
		)
	return data


/proc/odyssey_apply_economy(list/data)
	if (!islist(data))
		return
	var/list/station = data["station"]
	if (islist(station) && istype(station_account) && !isnull(station["money"]))
		station_account.money = station["money"]
		odyssey_apply_transaction_log(station_account, station["transactions"])
	var/list/departments = data["departments"]
	if (!islist(departments))
		return
	var/list/applied = list()
	for (var/dept in departments)
		var/datum/money_account/A = department_accounts[dept]
		var/list/entry = departments[dept]
		if (!istype(A) || !islist(entry) || isnull(entry["money"]))
			continue
		var/token = "\ref[A]"
		if (applied[token])
			continue
		applied[token] = TRUE
		A.money = entry["money"]
		odyssey_apply_transaction_log(A, entry["transactions"])
	log_debug("ODYSSEY: economy balances and transaction logs applied")

#undef ODYSSEY_TX_LOG_MAX
