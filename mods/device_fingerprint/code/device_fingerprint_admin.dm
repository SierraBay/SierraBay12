var/global/list/admin_verbs_device_fingerprint = list(
	/client/proc/check_device_fingerprint,
	/client/proc/check_device_fingerprint_ckey,
	/client/proc/check_device_fingerprint_overview
)

/proc/device_fingerprint_short_hash(value)
	if(isnull(value) || !length("[value]"))
		return ""
	var/text_value = "[value]"
	if(length(text_value) <= 12)
		return text_value
	return "[copytext(text_value, 1, 13)]..."

/proc/device_fingerprint_admin_link_ip(ip)
	if(isnull(ip) || !length("[ip]"))
		return ""
	var/safe_ip = url_encode("[ip]")
	return "<a href='https://ipinfo.io/[safe_ip]'>ipinfo</a> | <a href='https://api.ipquery.io/[safe_ip]'>ipquery</a> | <a href='https://proxycheck.io/v2/[safe_ip]?vpn=1&asn=1'>proxycheck</a>"

/proc/device_fingerprint_admin_browser_summary(raw_payload)
	if(isnull(raw_payload) || !length("[raw_payload]"))
		return "<em>No browser payload stored.</em>"
	var/list/decoded
	try
		decoded = json_decode(raw_payload)
	catch
		decoded = null
	if(!islist(decoded))
		return "<pre>[html_encode(raw_payload)]</pre>"
	var/body = "<table border='1' cellspacing='0' cellpadding='4'>"
	for(var/key in list("ua", "platform", "lang", "tz", "screen", "dpr", "dnt", "hardware_concurrency", "device_memory", "webdriver", "webgl_vendor", "webgl_renderer", "persistent_token_present"))
		var/value = decoded[key]
		if(isnull(value))
			continue
		body += "<tr><th>[html_encode(key)]</th><td><code>[html_encode(value)]</code></td></tr>"
	body += "</table>"
	return body

/proc/device_fingerprint_confidence_badge(label, value, color)
	if(isnull(value) || !length("[value]"))
		return ""
	return "<span style='display:inline-block;padding:2px 5px;border-radius:3px;background:[color];color:#fff;font-weight:bold'>[html_encode(label)]</span> <code>[html_encode(device_fingerprint_short_hash(value))]</code>"

/client/add_admin_verbs()
	..()
	if(holder && (holder.rights & (R_INVESTIGATE|R_DEBUG)))
		verbs += admin_verbs_device_fingerprint

/client/remove_admin_verbs()
	..()
	verbs.Remove(admin_verbs_device_fingerprint)

/client/proc/check_device_fingerprint(mob/M in SSmobs.mob_list)
	set name = "Check Device Fingerprint"
	set category = "Admin"
	set desc = "Shows device fingerprint records associated with a player."

	if(!check_rights(R_INVESTIGATE|R_DEBUG))
		return
	if(!M)
		return
	var/client/target = M.client
	var/target_ckey = target ? target.ckey : (M.ckey ? M.ckey : M.last_ckey)
	if(!target_ckey)
		to_chat(src, SPAN_WARNING("No ckey is available for that mob."))
		return
	show_device_fingerprint_report(target_ckey)

/client/proc/check_device_fingerprint_ckey()
	set name = "Check Device Fingerprint By CKEY"
	set category = "Admin"
	set desc = "Shows device fingerprint records associated with an offline or online ckey."

	if(!check_rights(R_INVESTIGATE|R_DEBUG))
		return
	var/target_ckey = ckey(input(src, "Enter ckey to inspect.", "Device Fingerprint") as null|text)
	if(!target_ckey)
		return
	show_device_fingerprint_report(target_ckey)

/client/proc/check_device_fingerprint_overview(risk_filter = 0, shared_only = FALSE, active_ban_only = FALSE)
	set name = "Device Fingerprint Overview"
	set category = "Admin"
	set desc = "Shows recent device fingerprint records across players."

	if(!check_rights(R_INVESTIGATE|R_DEBUG))
		return
	if(!establish_db_connection() || !dbcon.IsConnected())
		to_chat(src, SPAN_WARNING("Database connection failed."))
		return

	var/body = "<html><head><title>Device Fingerprint Overview</title></head><body>"
	body += "<h2>Device Fingerprint Overview</h2>"
	body += "<p><a href='byond://?src=\ref[src];device_fp_manual=1'>Manual ckey lookup</a></p>"
	body += "<p>Filters: "
	body += "<a href='byond://?src=\ref[src];device_fp_overview=1'>all</a> | "
	body += "<a href='byond://?src=\ref[src];device_fp_overview=1;min_risk=25'>risk >= 25</a> | "
	body += "<a href='byond://?src=\ref[src];device_fp_overview=1;shared_only=1'>shared flags</a> | "
	body += "<a href='byond://?src=\ref[src];device_fp_overview=1;active_ban_only=1'>active ban matches</a>"
	body += "</p>"
	body += "<table border='1' cellspacing='0' cellpadding='4'>"
	body += "<tr><th>CKEY</th><th>Last Seen</th><th>Schema</th><th>Risk</th><th>Flags</th><th>Confidence</th><th>Raw CID</th><th>Raw IP</th></tr>"

	var/list/where = list()
	if(risk_filter)
		where += "f.risk_score >= [max(0, round(text2num(risk_filter)))]"
	if(shared_only)
		where += "f.flags LIKE '%shared_%'"
	if(active_ban_only)
		where += "f.flags LIKE '%active_ban%'"
	var/where_clause = length(where) ? "WHERE [english_list(where, "", "", " AND ", " AND ")]" : ""
	var/DBQuery/query = dbcon.NewQuery("SELECT f.ckey, f.last_seen, f.schema_version, f.risk_score, f.flags, f.fingerprint_hash, f.computerid_hash, f.ip_prefix_hash, f.browser_hash, f.browser_token_hash, f.raw_computerid, f.raw_ip FROM erro_device_fingerprint f INNER JOIN (SELECT ckey_key, MAX(last_seen) AS last_seen FROM erro_device_fingerprint GROUP BY ckey_key) latest ON latest.ckey_key = f.ckey_key AND latest.last_seen = f.last_seen [where_clause] ORDER BY f.risk_score DESC, f.last_seen DESC LIMIT 100")
	if(!query.Execute())
		body += "<tr><td colspan='8'><b>Overview query failed:</b> [html_encode(query.ErrorMsg())]</td></tr>"
	else
		while(query.NextRow())
			var/target_ckey = "[query.item[1]]"
			var/safe_ckey = url_encode(target_ckey)
			var/list/confidence_badges = list()
			var/token_badge = device_fingerprint_confidence_badge("TOKEN", query.item[10], "#7b1fa2")
			if(length(token_badge))
				confidence_badges += token_badge
			var/cid_badge = device_fingerprint_confidence_badge("CID", query.item[7], "#2e7d32")
			if(length(cid_badge))
				confidence_badges += cid_badge
			var/ip_badge = device_fingerprint_confidence_badge("IP", query.item[8], "#ef6c00")
			if(length(ip_badge))
				confidence_badges += ip_badge
			var/confidence = jointext(confidence_badges, "<br>")
			body += "<tr>"
			body += "<td><a href='byond://?src=\ref[src];device_fp_admin_ckey=[safe_ckey]'>[html_encode(target_ckey)]</a></td>"
			body += "<td>[html_encode(query.item[2])]</td>"
			body += "<td>[html_encode(query.item[3])]</td>"
			body += "<td>[html_encode(query.item[4])]</td>"
			body += "<td>[html_encode(query.item[5])]</td>"
			body += "<td>[confidence]</td>"
			body += "<td>[html_encode(query.item[11])]</td>"
			body += "<td>[html_encode(query.item[12])]</td>"
			body += "</tr>"
	body += "</table>"
	body += "</body></html>"
	show_browser(src, body, "window=device_fingerprint_overview;size=1200x700")

/client/proc/show_device_fingerprint_report(target_ckey)
	if(!target_ckey)
		return
	if(!establish_db_connection() || !dbcon.IsConnected())
		to_chat(src, SPAN_WARNING("Database connection failed."))
		return

	var/sql_ckey = sql_sanitize_text(target_ckey)
	var/body = "<html><head><title>Device Fingerprint - [html_encode(target_ckey)]</title></head><body>"
	body += "<h2>Device Fingerprint for [html_encode(target_ckey)]</h2>"

	var/DBQuery/query = dbcon.NewQuery("SELECT created_at, last_seen, ckey, schema_version, fingerprint_hash, computerid_hash, ip_prefix_hash, browser_hash, browser_token_hash, raw_computerid, raw_ip, raw_browser_payload, byond_version, byond_build, risk_score, flags FROM erro_device_fingerprint WHERE ckey = '[sql_ckey]' ORDER BY last_seen DESC LIMIT 50")
	if(!query.Execute())
		body += "<p><b>Query failed:</b> [html_encode(query.ErrorMsg())]</p>"
		body += "</body></html>"
		show_browser(src, body, "window=device_fingerprint_admin;size=1000x700")
		return

	body += "<table border='1' cellspacing='0' cellpadding='4'>"
	body += "<tr><th>Created</th><th>Last Seen</th><th>CKEY</th><th>Schema</th><th>Fingerprint</th><th>Browser</th><th>Browser Token</th><th>BYOND</th><th>Risk</th><th>Flags</th><th>Raw CID</th><th>Raw IP</th></tr>"
	var/list/fingerprints = list()
	var/list/computerids = list()
	var/list/ip_prefixes = list()
	var/list/browsers = list()
	var/list/browser_tokens = list()
	var/list/raw_ips = list()
	var/list/raw_computerids = list()
	var/latest_browser_payload
	var/latest_raw_ip
	var/latest_raw_computerid
	var/latest_byond
	var/latest_flags
	var/max_risk = 0
	var/row_count = 0
	while(query.NextRow())
		row_count++
		var/fingerprint = "[query.item[5]]"
		fingerprints |= fingerprint
		var/computerid_hash = query.item[6]
		if(!isnull(computerid_hash) && length("[computerid_hash]"))
			computerids |= computerid_hash
		var/ip_prefix_hash = query.item[7]
		if(!isnull(ip_prefix_hash) && length("[ip_prefix_hash]"))
			ip_prefixes |= ip_prefix_hash
		var/browser_hash = query.item[8]
		if(!isnull(browser_hash) && length("[browser_hash]"))
			browsers |= browser_hash
		var/browser_token = query.item[9]
		if(!isnull(browser_token) && length("[browser_token]"))
			browser_tokens |= browser_token
		var/raw_computerid = query.item[10]
		if(!isnull(raw_computerid) && length("[raw_computerid]"))
			raw_computerids |= raw_computerid
		var/raw_ip = query.item[11]
		if(!isnull(raw_ip) && length("[raw_ip]"))
			raw_ips |= raw_ip
		if(row_count == 1)
			latest_browser_payload = query.item[12]
			latest_raw_ip = query.item[11]
			latest_raw_computerid = query.item[10]
			latest_byond = "[query.item[13]].[query.item[14]]"
			latest_flags = query.item[16]
		max_risk = max(max_risk, text2num(query.item[15]))
		body += "<tr>"
		body += "<td>[html_encode(query.item[1])]</td>"
		body += "<td>[html_encode(query.item[2])]</td>"
		body += "<td>[html_encode(query.item[3])]</td>"
		body += "<td>[html_encode(query.item[4])]</td>"
		body += "<td><code>[html_encode(fingerprint)]</code></td>"
		body += "<td><code>[html_encode(query.item[8])]</code></td>"
		body += "<td>[html_encode(query.item[9])]</td>"
		body += "<td>[html_encode(query.item[13])].[html_encode(query.item[14])]</td>"
		body += "<td>[html_encode(query.item[15])]</td>"
		body += "<td>[html_encode(query.item[16])]</td>"
		body += "<td>[html_encode(query.item[10])]</td>"
		body += "<td>[html_encode(query.item[11])]</td>"
		body += "</tr>"
	body += "</table>"
	if(!row_count)
		body += "<p>No fingerprint records found for <code>[html_encode(target_ckey)]</code>.</p>"
	else
		body += "<h3>Summary</h3><table border='1' cellspacing='0' cellpadding='4'>"
		body += "<tr><th>Recent rows loaded</th><td>[row_count]</td></tr>"
		body += "<tr><th>Distinct fingerprints</th><td>[length(fingerprints)]</td></tr>"
		body += "<tr><th>Distinct CID hashes</th><td>[length(computerids)]</td></tr>"
		body += "<tr><th>Distinct browser hashes</th><td>[length(browsers)]</td></tr>"
		body += "<tr><th>Distinct browser token hashes</th><td>[length(browser_tokens)]</td></tr>"
		body += "<tr><th>Browser token present</th><td>[length(browser_tokens) ? "yes" : "no"]</td></tr>"
		body += "<tr><th>Distinct IP prefixes</th><td>[length(ip_prefixes)]</td></tr>"
		body += "<tr><th>Raw CIDs</th><td><code>[html_encode(jointext(raw_computerids, ", "))]</code></td></tr>"
		body += "<tr><th>Raw IPs</th><td><code>[html_encode(jointext(raw_ips, ", "))]</code></td></tr>"
		body += "<tr><th>Latest IP lookup</th><td>[device_fingerprint_admin_link_ip(latest_raw_ip)]</td></tr>"
		body += "<tr><th>Latest BYOND</th><td>[html_encode(latest_byond)]</td></tr>"
		body += "<tr><th>Latest raw CID</th><td><code>[html_encode(latest_raw_computerid)]</code></td></tr>"
		body += "<tr><th>Max risk</th><td>[max_risk]</td></tr>"
		body += "<tr><th>Latest flags</th><td>[html_encode(latest_flags)]</td></tr>"
		body += "</table>"
		body += "<h3>Latest Browser Payload</h3>"
		body += device_fingerprint_admin_browser_summary(latest_browser_payload)

	if(length(fingerprints) || length(computerids) || length(ip_prefixes) || length(browsers) || length(browser_tokens))
		var/list/conditions = list()
		for(var/fingerprint in fingerprints)
			conditions += "fingerprint_hash = '[sql_sanitize_text(fingerprint)]'"
		for(var/computerid in computerids)
			conditions += "computerid_hash = '[sql_sanitize_text(computerid)]'"
		for(var/ip_prefix in ip_prefixes)
			conditions += "ip_prefix_hash = '[sql_sanitize_text(ip_prefix)]'"
		for(var/browser in browsers)
			conditions += "browser_hash = '[sql_sanitize_text(browser)]'"
		for(var/browser_token in browser_tokens)
			conditions += "browser_token_hash = '[sql_sanitize_text(browser_token)]'"
		var/selection = english_list(conditions, "", "", " OR ", " OR ")

		body += "<h3>High Confidence Related Bans</h3><table border='1' cellspacing='0' cellpadding='4'>"
		body += "<tr><th>Match Type</th><th>Banned CKEY</th><th>Type</th><th>Reason</th><th>Admin</th><th>Time</th></tr>"
		for(var/browser_token in browser_tokens)
			var/DBQuery/token_ban_query = dbcon.NewQuery("SELECT DISTINCT b.ckey, b.bantype, b.reason, b.a_ckey, b.bantime FROM erro_ban b INNER JOIN erro_device_fingerprint f ON f.ckey = b.ckey WHERE f.browser_token_hash = '[sql_sanitize_text(browser_token)]' AND b.ckey != '[sql_ckey]' AND [device_fingerprint_active_ban_clause()] ORDER BY b.bantime DESC LIMIT 25")
			if(!token_ban_query.Execute())
				body += "<tr><td colspan='6'><b>Browser token ban query failed:</b> [html_encode(token_ban_query.ErrorMsg())]</td></tr>"
				continue
			while(token_ban_query.NextRow())
				body += "<tr><td>browser token <code>[html_encode(device_fingerprint_short_hash(browser_token))]</code></td><td>[html_encode(token_ban_query.item[1])]</td><td>[html_encode(token_ban_query.item[2])]</td><td>[html_encode(token_ban_query.item[3])]</td><td>[html_encode(token_ban_query.item[4])]</td><td>[html_encode(token_ban_query.item[5])]</td></tr>"
		for(var/computerid in computerids)
			var/DBQuery/cid_ban_query = dbcon.NewQuery("SELECT DISTINCT b.ckey, b.bantype, b.reason, b.a_ckey, b.bantime FROM erro_ban b INNER JOIN erro_device_fingerprint f ON f.ckey = b.ckey WHERE f.computerid_hash = '[sql_sanitize_text(computerid)]' AND b.ckey != '[sql_ckey]' AND [device_fingerprint_active_ban_clause()] ORDER BY b.bantime DESC LIMIT 25")
			if(!cid_ban_query.Execute())
				body += "<tr><td colspan='6'><b>CID ban query failed:</b> [html_encode(cid_ban_query.ErrorMsg())]</td></tr>"
				continue
			while(cid_ban_query.NextRow())
				body += "<tr><td>CID <code>[html_encode(device_fingerprint_short_hash(computerid))]</code></td><td>[html_encode(cid_ban_query.item[1])]</td><td>[html_encode(cid_ban_query.item[2])]</td><td>[html_encode(cid_ban_query.item[3])]</td><td>[html_encode(cid_ban_query.item[4])]</td><td>[html_encode(cid_ban_query.item[5])]</td></tr>"
		for(var/fingerprint in fingerprints)
			var/DBQuery/fingerprint_ban_query = dbcon.NewQuery("SELECT DISTINCT b.ckey, b.bantype, b.reason, b.a_ckey, b.bantime FROM erro_ban b INNER JOIN erro_device_fingerprint f ON f.ckey = b.ckey WHERE f.fingerprint_hash = '[sql_sanitize_text(fingerprint)]' AND b.ckey != '[sql_ckey]' AND [device_fingerprint_active_ban_clause()] ORDER BY b.bantime DESC LIMIT 25")
			if(!fingerprint_ban_query.Execute())
				body += "<tr><td colspan='6'><b>Fingerprint ban query failed:</b> [html_encode(fingerprint_ban_query.ErrorMsg())]</td></tr>"
				continue
			while(fingerprint_ban_query.NextRow())
				body += "<tr><td>fingerprint <code>[html_encode(device_fingerprint_short_hash(fingerprint))]</code></td><td>[html_encode(fingerprint_ban_query.item[1])]</td><td>[html_encode(fingerprint_ban_query.item[2])]</td><td>[html_encode(fingerprint_ban_query.item[3])]</td><td>[html_encode(fingerprint_ban_query.item[4])]</td><td>[html_encode(fingerprint_ban_query.item[5])]</td></tr>"
		body += "</table>"

		var/DBQuery/related_query = dbcon.NewQuery("SELECT DISTINCT ckey, last_seen, risk_score, flags FROM erro_device_fingerprint WHERE ([selection]) AND ckey != '[sql_ckey]' ORDER BY last_seen DESC LIMIT 50")
		body += "<h3>Related CKEYs</h3><table border='1' cellspacing='0' cellpadding='4'>"
		body += "<tr><th>CKEY</th><th>Last Seen</th><th>Risk</th><th>Flags</th></tr>"
		if(!related_query.Execute())
			body += "<tr><td colspan='4'><b>Related query failed:</b> [html_encode(related_query.ErrorMsg())]</td></tr>"
		else
			while(related_query.NextRow())
				body += "<tr><td>[html_encode(related_query.item[1])]</td><td>[html_encode(related_query.item[2])]</td><td>[html_encode(related_query.item[3])]</td><td>[html_encode(related_query.item[4])]</td></tr>"
		body += "</table>"

		body += "<h3>Related Match Details</h3><table border='1' cellspacing='0' cellpadding='4'>"
		body += "<tr><th>Match Type</th><th>CKEYs</th><th>Count</th></tr>"
		for(var/fingerprint in fingerprints)
			var/DBQuery/fingerprint_match_query = dbcon.NewQuery("SELECT GROUP_CONCAT(DISTINCT ckey ORDER BY ckey SEPARATOR ', '), COUNT(DISTINCT ckey) FROM erro_device_fingerprint WHERE fingerprint_hash = '[sql_sanitize_text(fingerprint)]' AND ckey != '[sql_ckey]'")
			if(!fingerprint_match_query.Execute())
				body += "<tr><td colspan='3'><b>Fingerprint match query failed:</b> [html_encode(fingerprint_match_query.ErrorMsg())]</td></tr>"
				continue
			if(fingerprint_match_query.NextRow() && text2num(fingerprint_match_query.item[2]))
				body += "<tr><td>fingerprint <code>[html_encode(device_fingerprint_short_hash(fingerprint))]</code></td><td>[html_encode(fingerprint_match_query.item[1])]</td><td>[html_encode(fingerprint_match_query.item[2])]</td></tr>"
		for(var/computerid in computerids)
			var/DBQuery/computerid_match_query = dbcon.NewQuery("SELECT GROUP_CONCAT(DISTINCT ckey ORDER BY ckey SEPARATOR ', '), COUNT(DISTINCT ckey) FROM erro_device_fingerprint WHERE computerid_hash = '[sql_sanitize_text(computerid)]' AND ckey != '[sql_ckey]'")
			if(!computerid_match_query.Execute())
				body += "<tr><td colspan='3'><b>CID match query failed:</b> [html_encode(computerid_match_query.ErrorMsg())]</td></tr>"
				continue
			if(computerid_match_query.NextRow() && text2num(computerid_match_query.item[2]))
				body += "<tr><td>CID <code>[html_encode(device_fingerprint_short_hash(computerid))]</code></td><td>[html_encode(computerid_match_query.item[1])]</td><td>[html_encode(computerid_match_query.item[2])]</td></tr>"
		for(var/ip_prefix in ip_prefixes)
			var/DBQuery/ip_prefix_match_query = dbcon.NewQuery("SELECT GROUP_CONCAT(DISTINCT ckey ORDER BY ckey SEPARATOR ', '), COUNT(DISTINCT ckey) FROM erro_device_fingerprint WHERE ip_prefix_hash = '[sql_sanitize_text(ip_prefix)]' AND ckey != '[sql_ckey]'")
			if(!ip_prefix_match_query.Execute())
				body += "<tr><td colspan='3'><b>IP prefix match query failed:</b> [html_encode(ip_prefix_match_query.ErrorMsg())]</td></tr>"
				continue
			if(ip_prefix_match_query.NextRow() && text2num(ip_prefix_match_query.item[2]))
				body += "<tr><td>IP prefix <code>[html_encode(device_fingerprint_short_hash(ip_prefix))]</code></td><td>[html_encode(ip_prefix_match_query.item[1])]</td><td>[html_encode(ip_prefix_match_query.item[2])]</td></tr>"
		for(var/browser in browsers)
			var/DBQuery/browser_match_query = dbcon.NewQuery("SELECT GROUP_CONCAT(DISTINCT ckey ORDER BY ckey SEPARATOR ', '), COUNT(DISTINCT ckey) FROM erro_device_fingerprint WHERE browser_hash = '[sql_sanitize_text(browser)]' AND ckey != '[sql_ckey]'")
			if(!browser_match_query.Execute())
				body += "<tr><td colspan='3'><b>Browser match query failed:</b> [html_encode(browser_match_query.ErrorMsg())]</td></tr>"
				continue
			if(browser_match_query.NextRow() && text2num(browser_match_query.item[2]))
				body += "<tr><td>browser <code>[html_encode(device_fingerprint_short_hash(browser))]</code></td><td>[html_encode(browser_match_query.item[1])]</td><td>[html_encode(browser_match_query.item[2])]</td></tr>"
		for(var/browser_token in browser_tokens)
			var/DBQuery/browser_token_match_query = dbcon.NewQuery("SELECT GROUP_CONCAT(DISTINCT ckey ORDER BY ckey SEPARATOR ', '), COUNT(DISTINCT ckey) FROM erro_device_fingerprint WHERE browser_token_hash = '[sql_sanitize_text(browser_token)]' AND ckey != '[sql_ckey]'")
			if(!browser_token_match_query.Execute())
				body += "<tr><td colspan='3'><b>Browser token match query failed:</b> [html_encode(browser_token_match_query.ErrorMsg())]</td></tr>"
				continue
			if(browser_token_match_query.NextRow() && text2num(browser_token_match_query.item[2]))
				body += "<tr><td>browser token <code>[html_encode(device_fingerprint_short_hash(browser_token))]</code></td><td>[html_encode(browser_token_match_query.item[1])]</td><td>[html_encode(browser_token_match_query.item[2])]</td></tr>"
		body += "</table>"

		var/DBQuery/ban_query = dbcon.NewQuery("SELECT DISTINCT b.ckey, b.bantype, b.reason, b.a_ckey, b.bantime FROM erro_ban b INNER JOIN erro_device_fingerprint f ON f.ckey = b.ckey WHERE ([selection]) AND [device_fingerprint_active_ban_clause()] ORDER BY b.bantime DESC LIMIT 50")
		body += "<h3>Active Bans On Related Fingerprints</h3><table border='1' cellspacing='0' cellpadding='4'>"
		body += "<tr><th>CKEY</th><th>Type</th><th>Reason</th><th>Admin</th><th>Time</th></tr>"
		if(!ban_query.Execute())
			body += "<tr><td colspan='5'><b>Ban query failed:</b> [html_encode(ban_query.ErrorMsg())]</td></tr>"
		else
			while(ban_query.NextRow())
				body += "<tr><td>[html_encode(ban_query.item[1])]</td><td>[html_encode(ban_query.item[2])]</td><td>[html_encode(ban_query.item[3])]</td><td>[html_encode(ban_query.item[4])]</td><td>[html_encode(ban_query.item[5])]</td></tr>"
		body += "</table>"

	body += "</body></html>"
	show_browser(src, body, "window=device_fingerprint_admin;size=1000x700")
