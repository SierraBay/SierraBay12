/proc/device_fingerprint_enabled()
	return sqlenabled && config && config.device_fingerprint_secret

/proc/make_device_fingerprint_hash(kind, value)
	if(!config || !config.device_fingerprint_secret || !value)
		return null
	return sha1("[config.device_fingerprint_secret]|[kind]|[value]")

/proc/device_fingerprint_ip_prefix(ip)
	if(!istext(ip) || !length(ip))
		return ""
	if(findtext(ip, "."))
		var/list/parts = splittext(ip, ".")
		if(length(parts) >= 3)
			return "[parts[1]].[parts[2]].[parts[3]].0"
	if(findtext(ip, ":"))
		var/list/parts = splittext(ip, ":")
		if(length(parts) >= 4)
			return "[parts[1]]:[parts[2]]:[parts[3]]:[parts[4]]::"
	return ip

/proc/device_fingerprint_sql_value(value)
	if(isnull(value))
		return "NULL"
	return "'[sql_sanitize_text("[value]")]'"

/proc/device_fingerprint_active_ban_clause()
	return "(bantype = 'PERMABAN' OR (bantype = 'TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)"

/proc/device_fingerprint_cleanup_old_records()
	if(!device_fingerprint_enabled())
		return FALSE
	if(!config.device_fingerprint_retention_days)
		return FALSE
	if(!establish_db_connection() || !dbcon.IsConnected())
		log_debug("Device Fingerprint: retention cleanup skipped; database connection failed.")
		return FALSE
	var/retention_days = max(1, round(config.device_fingerprint_retention_days))
	var/DBQuery/query = dbcon.NewQuery("DELETE FROM erro_device_fingerprint WHERE last_seen < DATE_SUB(Now(), INTERVAL [retention_days] DAY)")
	if(!query.Execute())
		log_debug("Device Fingerprint: retention cleanup failed: [query.ErrorMsg()]")
		return FALSE
	log_debug("Device Fingerprint: retention cleanup removed records older than [retention_days] days.")
	return TRUE

/client/proc/device_fingerprint_related_count(column, value)
	if(!value || !dbcon || !dbcon.IsConnected())
		return 0
	var/safe_column
	switch(column)
		if("fingerprint_hash")
			safe_column = "fingerprint_hash"
		if("computerid_hash")
			safe_column = "computerid_hash"
		if("ip_prefix_hash")
			safe_column = "ip_prefix_hash"
		if("browser_hash")
			safe_column = "browser_hash"
		else
			return 0
	var/DBQuery/query = dbcon.NewQuery("SELECT COUNT(DISTINCT ckey) FROM erro_device_fingerprint WHERE [safe_column] = '[sql_sanitize_text(value)]' AND ckey != '[sql_sanitize_text(ckey)]'")
	if(!query.Execute())
		log_debug("Device Fingerprint: related count failed: [query.ErrorMsg()]")
		return 0
	if(query.NextRow())
		return text2num(query.item[1])
	return 0

/client/proc/device_fingerprint_distinct_count(filter_column, filter_value, count_column)
	if(!filter_value || !dbcon || !dbcon.IsConnected())
		return 0
	var/safe_filter_column
	switch(filter_column)
		if("ckey")
			safe_filter_column = "ckey"
		if("computerid_hash")
			safe_filter_column = "computerid_hash"
		if("browser_hash")
			safe_filter_column = "browser_hash"
		else
			return 0
	var/safe_count_column
	switch(count_column)
		if("ip_prefix_hash")
			safe_count_column = "ip_prefix_hash"
		if("ckey")
			safe_count_column = "ckey"
		else
			return 0
	var/DBQuery/query = dbcon.NewQuery("SELECT COUNT(DISTINCT [safe_count_column]) FROM erro_device_fingerprint WHERE [safe_filter_column] = '[sql_sanitize_text(filter_value)]' AND [safe_count_column] IS NOT NULL AND [safe_count_column] != ''")
	if(!query.Execute())
		log_debug("Device Fingerprint: distinct count failed: [query.ErrorMsg()]")
		return 0
	if(query.NextRow())
		return text2num(query.item[1])
	return 0

/client/proc/device_fingerprint_active_ban_matches(column = "fingerprint_hash", value = null)
	if(!dbcon || !dbcon.IsConnected())
		return 0
	if(isnull(value))
		value = device_fingerprint_hash
	if(!value)
		return 0
	var/safe_column
	switch(column)
		if("fingerprint_hash")
			safe_column = "fingerprint_hash"
		if("computerid_hash")
			safe_column = "computerid_hash"
		if("browser_hash")
			safe_column = "browser_hash"
		else
			return 0
	var/DBQuery/query = dbcon.NewQuery("SELECT COUNT(DISTINCT b.ckey) FROM erro_ban b INNER JOIN erro_device_fingerprint f ON f.ckey = b.ckey WHERE f.[safe_column] = '[sql_sanitize_text(value)]' AND b.ckey != '[sql_sanitize_text(ckey)]' AND [device_fingerprint_active_ban_clause()]")
	if(!query.Execute())
		log_debug("Device Fingerprint: active ban match failed: [query.ErrorMsg()]")
		return 0
	if(query.NextRow())
		return text2num(query.item[1])
	return 0

/client/proc/device_fingerprint_connection_ban_matches()
	if(!dbcon || !dbcon.IsConnected())
		return 0
	var/list/selection = list()
	if(address)
		selection += "ip = '[sql_sanitize_text(address)]'"
	if(computer_id)
		selection += "computerid = '[sql_sanitize_text(computer_id)]'"
	if(!length(selection))
		return 0
	selection = jointext(selection, " OR ")
	var/DBQuery/query = dbcon.NewQuery("SELECT COUNT(DISTINCT ckey) FROM erro_ban WHERE ([selection]) AND [device_fingerprint_active_ban_clause()]")
	if(!query.Execute())
		log_debug("Device Fingerprint: connection ban match failed: [query.ErrorMsg()]")
		return 0
	if(query.NextRow())
		return text2num(query.item[1])
	return 0

/client/proc/device_fingerprint_previous_browser_changed(new_browser_hash)
	if(!dbcon || !dbcon.IsConnected() || !new_browser_hash)
		return FALSE
	var/DBQuery/query = dbcon.NewQuery("SELECT browser_hash FROM erro_device_fingerprint WHERE ckey = '[sql_sanitize_text(ckey)]' AND browser_hash IS NOT NULL ORDER BY last_seen DESC LIMIT 1")
	if(!query.Execute())
		log_debug("Device Fingerprint: previous browser lookup failed: [query.ErrorMsg()]")
		return FALSE
	if(query.NextRow())
		return query.item[1] != new_browser_hash
	return FALSE

/client/proc/device_fingerprint_delete_browser_missing_rows()
	if(!dbcon || !dbcon.IsConnected() || !browser_fingerprint_hash)
		return
	var/list/conditions = list()
	conditions += "ckey = '[sql_sanitize_text(ckey)]'"
	if(device_computerid_hash)
		conditions += "computerid_hash = '[sql_sanitize_text(device_computerid_hash)]'"
	else
		conditions += "computerid_hash IS NULL"
	if(device_ip_prefix_hash)
		conditions += "ip_prefix_hash = '[sql_sanitize_text(device_ip_prefix_hash)]'"
	else
		conditions += "ip_prefix_hash IS NULL"
	var/selection = jointext(conditions, " AND ")
	var/DBQuery/query = dbcon.NewQuery("DELETE FROM erro_device_fingerprint WHERE [selection] AND browser_hash IS NULL AND flags LIKE '%browser_payload_missing%'")
	if(!query.Execute())
		log_debug("Device Fingerprint: stale browser-missing cleanup failed: [query.ErrorMsg()]")

/client/proc/device_fingerprint_upsert()
	if(!dbcon || !dbcon.IsConnected() || !device_fingerprint_hash)
		return FALSE

	var/raw_computerid = config.device_fingerprint_raw_storage ? computer_id : null
	var/raw_ip = config.device_fingerprint_raw_storage ? address : null
	var/raw_browser_payload = config.device_fingerprint_raw_storage ? device_browser_payload_raw : null
	var/flags = length(device_risk_flags) ? jointext(device_risk_flags, ",") : ""
	var/sql_ckey = sql_sanitize_text(ckey)
	var/sql_fingerprint = sql_sanitize_text(device_fingerprint_hash)
	var/sql_schema = sql_sanitize_text(DEVICE_FINGERPRINT_SCHEMA)

	device_fingerprint_delete_browser_missing_rows()

	var/DBQuery/find_query = dbcon.NewQuery("SELECT id FROM erro_device_fingerprint WHERE ckey_key = '[sql_ckey]' AND fingerprint_hash = '[sql_fingerprint]' LIMIT 1")
	if(!find_query.Execute())
		log_debug("Device Fingerprint: lookup failed: [find_query.ErrorMsg()]")
		return FALSE
	if(find_query.NextRow())
		var/id = text2num(find_query.item[1])
		var/DBQuery/update_query = dbcon.NewQuery("UPDATE erro_device_fingerprint SET last_seen = Now(), ckey = '[sql_ckey]', schema_version = '[sql_schema]', computerid_hash = [device_fingerprint_sql_value(device_computerid_hash)], ip_prefix_hash = [device_fingerprint_sql_value(device_ip_prefix_hash)], browser_hash = [device_fingerprint_sql_value(browser_fingerprint_hash)], raw_computerid = [device_fingerprint_sql_value(raw_computerid)], raw_ip = [device_fingerprint_sql_value(raw_ip)], raw_browser_payload = [device_fingerprint_sql_value(raw_browser_payload)], byond_version = [device_fingerprint_sql_value(byond_version)], byond_build = [device_fingerprint_sql_value(byond_build)], risk_score = [device_risk_score], flags = [device_fingerprint_sql_value(flags)] WHERE id = [id]")
		if(!update_query.Execute())
			log_debug("Device Fingerprint: update failed: [update_query.ErrorMsg()]")
			return FALSE
		return TRUE

	var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO erro_device_fingerprint (created_at, last_seen, ckey, ckey_key, schema_version, fingerprint_hash, computerid_hash, ip_prefix_hash, browser_hash, raw_computerid, raw_ip, raw_browser_payload, byond_version, byond_build, risk_score, flags) VALUES (Now(), Now(), '[sql_ckey]', '[sql_ckey]', '[sql_schema]', '[sql_fingerprint]', [device_fingerprint_sql_value(device_computerid_hash)], [device_fingerprint_sql_value(device_ip_prefix_hash)], [device_fingerprint_sql_value(browser_fingerprint_hash)], [device_fingerprint_sql_value(raw_computerid)], [device_fingerprint_sql_value(raw_ip)], [device_fingerprint_sql_value(raw_browser_payload)], [device_fingerprint_sql_value(byond_version)], [device_fingerprint_sql_value(byond_build)], [device_risk_score], [device_fingerprint_sql_value(flags)]) ON DUPLICATE KEY UPDATE last_seen = Now(), ckey = VALUES(ckey), schema_version = VALUES(schema_version), computerid_hash = VALUES(computerid_hash), ip_prefix_hash = VALUES(ip_prefix_hash), browser_hash = VALUES(browser_hash), raw_computerid = VALUES(raw_computerid), raw_ip = VALUES(raw_ip), raw_browser_payload = VALUES(raw_browser_payload), byond_version = VALUES(byond_version), byond_build = VALUES(byond_build), risk_score = VALUES(risk_score), flags = VALUES(flags)")
	if(!insert_query.Execute())
		log_debug("Device Fingerprint: insert failed: [insert_query.ErrorMsg()]")
		return FALSE
	return TRUE
