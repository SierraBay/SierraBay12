/client/var/device_fingerprint_hash
/client/var/device_computerid_hash
/client/var/device_ip_prefix_hash
/client/var/browser_fingerprint_hash
/client/var/browser_token_hash
/client/var/device_risk_score = 0
/client/var/list/device_risk_flags = list()
/client/var/list/device_browser_risk_flags = list()
/client/var/device_fingerprint_secret_warned = FALSE
/client/var/device_fingerprint_client_save_token
/client/var/device_fingerprint_client_save_loaded = FALSE
/client/var/device_fingerprint_client_save_importing = FALSE

/client/New(TopicData)
	. = ..()
	if(src)
		spawn(10)
			if(src)
				collect_device_fingerprint(TRUE)

/client/Topic(href, href_list, hsrc)
	if(href_list["device_fp_browser"])
		if(usr?.client == src)
			handle_device_browser_payload(href_list)
		return

	if(href_list["device_fp_admin_ckey"])
		if(usr?.client != src || !user_acted(src))
			return
		if(check_rights(R_INVESTIGATE|R_DEBUG))
			var/target_ckey = ckey(href_list["device_fp_admin_ckey"])
			if(target_ckey)
				show_device_fingerprint_report(target_ckey)
		return
	if(href_list["device_fp_manual"])
		if(usr?.client != src || !user_acted(src))
			return
		if(check_rights(R_INVESTIGATE|R_DEBUG))
			check_device_fingerprint_ckey()
		return
	if(href_list["device_fp_overview"])
		if(usr?.client != src || !user_acted(src))
			return
		if(check_rights(R_INVESTIGATE|R_DEBUG))
			check_device_fingerprint_overview(href_list["min_risk"], text2num(href_list["shared_only"]), text2num(href_list["active_ban_only"]))
		return
	return ..()

/client/proc/device_fingerprint_add_flag(flag)
	if(!device_risk_flags)
		device_risk_flags = list()
	LAZYDISTINCTADD(device_risk_flags, flag)

/client/proc/device_fingerprint_add_browser_flag(flag)
	if(!device_browser_risk_flags)
		device_browser_risk_flags = list()
	LAZYDISTINCTADD(device_browser_risk_flags, flag)

/client/proc/collect_device_fingerprint(open_browser = TRUE)
	if(!sqlenabled)
		return
	if(!config || !config.device_fingerprint_secret)
		if(!device_fingerprint_secret_warned)
			device_fingerprint_secret_warned = TRUE
			log_debug("Device Fingerprint: DEVICE_FINGERPRINT_SECRET is not configured; fingerprint collection disabled.")
		return
	if(IsGuestKey(key))
		return
	if(!establish_db_connection() || !dbcon.IsConnected())
		return

	device_fingerprint_load_client_save()
	device_risk_flags = list()
	device_risk_score = 0

	var/ip_prefix = device_fingerprint_ip_prefix(address)
	device_computerid_hash = make_device_fingerprint_hash("cid", computer_id)
	device_ip_prefix_hash = make_device_fingerprint_hash("ip", ip_prefix)
	device_fingerprint_hash = make_device_fingerprint_hash("bundle", "[DEVICE_FINGERPRINT_SCHEMA]|cid=[computer_id]|ip=[ip_prefix]|byond=[byond_version].[byond_build]")

	if(open_browser && config.device_fingerprint_browser && !browser_token_hash)
		if(device_fingerprint_open_browser())
			return

	if(!device_fingerprint_client_save_token)
		device_fingerprint_save_client_token(device_fingerprint_generate_client_save_token(), "collect fallback generation")

	if(!computer_id)
		device_fingerprint_add_flag("blank_cid")
		device_risk_score += 15

	if(device_computerid_hash && device_fingerprint_related_count("computerid_hash", device_computerid_hash))
		device_fingerprint_add_flag("shared_cid_with_other_ckeys")
		device_risk_score += 20
	if(browser_token_hash && device_fingerprint_related_count("browser_token_hash", browser_token_hash))
		device_fingerprint_add_flag("shared_browser_token_with_other_ckeys")
		device_risk_score += 30
	if(browser_fingerprint_hash && device_fingerprint_related_count("browser_hash", browser_fingerprint_hash))
		device_fingerprint_add_flag("shared_browser_fingerprint_with_other_ckeys")
		device_risk_score += 10
	if(device_ip_prefix_hash && device_fingerprint_related_count("ip_prefix_hash", device_ip_prefix_hash))
		device_fingerprint_add_flag("shared_ip_with_other_ckeys")
	if(device_fingerprint_distinct_count("ckey", ckey, "ip_prefix_hash") > 3)
		device_fingerprint_add_flag("many_ip_prefixes_for_ckey")
		device_risk_score += 8
	if(device_computerid_hash && device_fingerprint_distinct_count("computerid_hash", device_computerid_hash, "ip_prefix_hash") > 3)
		device_fingerprint_add_flag("stable_cid_many_ip_prefixes")
		device_risk_score += 15
	if(device_computerid_hash && device_fingerprint_active_ban_matches("computerid_hash", device_computerid_hash))
		device_fingerprint_add_flag("matched_cid_with_active_ban_history")
		device_risk_score += 45
	if(browser_token_hash && device_fingerprint_active_ban_matches("browser_token_hash", browser_token_hash))
		device_fingerprint_add_flag("matched_browser_token_with_active_ban_history")
		device_risk_score += 55
	if(browser_fingerprint_hash && device_fingerprint_active_ban_matches("browser_hash", browser_fingerprint_hash))
		device_fingerprint_add_flag("matched_browser_fingerprint_with_active_ban_history")
		device_risk_score += 25
	if(device_fingerprint_connection_ban_matches())
		device_fingerprint_add_flag("matched_active_ban_by_connection_history")
		device_risk_score += 35

	device_fingerprint_upsert()
	device_fingerprint_alert_staff()

/client/proc/device_fingerprint_alert_staff()
	if(!length(device_risk_flags))
		return
	if(device_risk_score < config.device_fingerprint_alert_threshold)
		return
	var/list/report_flags = device_risk_flags.Copy()
	if(!length(report_flags))
		return
	message_staff(SPAN_WARNING("[key_name_admin(src)] has device fingerprint risk flags: [jointext(report_flags, ", ")]. Score: [device_risk_score]."))

/client/proc/device_fingerprint_debug(message)
	var/debug_key = key ? key : "<no key>"
	log_debug("Device Fingerprint: [debug_key] [message]")

/client/proc/device_fingerprint_generate_client_save_token()
	return sha1("[world.realtime]|[world.timeofday]|[rand(1, 1000000000)]|[key]|\ref[src]|[computer_id]|[address]")

/client/proc/device_fingerprint_load_client_save()
	if(device_fingerprint_client_save_loaded)
		return
	device_fingerprint_client_save_loaded = TRUE
	device_fingerprint_client_save_importing = TRUE
	var/client_file
	try
		client_file = Import()
	catch
		device_fingerprint_debug("client save import failed.")
		device_fingerprint_client_save_importing = FALSE
		return
	device_fingerprint_client_save_importing = FALSE

	if(!client_file)
		device_fingerprint_debug("client save import returned no file.")
		return

	var/savefile/F = new(client_file)
	var/schema
	var/token
	try
		F["device_fingerprint/schema"] >> schema
		F["device_fingerprint/token"] >> token
	catch
		device_fingerprint_debug("client save import could not read savefile data.")
		return
	if(schema != DEVICE_FINGERPRINT_SCHEMA || !istext(token) || !length(token))
		var/schema_debug = schema ? schema : "null"
		device_fingerprint_debug("client save import ignored invalid data; schema=[schema_debug].")
		return

	device_fingerprint_client_save_token = copytext(token, 1, 256)
	browser_token_hash = make_device_fingerprint_hash("browser_token", device_fingerprint_client_save_token)
	device_fingerprint_debug("client save import loaded token hash [copytext(browser_token_hash, 1, 13)]...")

/client/proc/device_fingerprint_save_client_token(token, reason = "update")
	if(!istext(token) || !length(token))
		return FALSE
	token = copytext(token, 1, 256)
	var/new_token_hash = make_device_fingerprint_hash("browser_token", token)

	var/savefile/F = new()
	F["device_fingerprint/schema"] << DEVICE_FINGERPRINT_SCHEMA
	F["device_fingerprint/token"] << token
	F["device_fingerprint/ckey"] << ckey
	F["device_fingerprint/updated_at"] << world.realtime
	try
		Export(F)
	catch
		device_fingerprint_debug("client save export failed during [reason].")
		return FALSE

	device_fingerprint_client_save_token = token
	browser_token_hash = new_token_hash
	device_fingerprint_debug("client save export succeeded during [reason]; token hash [copytext(new_token_hash, 1, 13)]...")
	return TRUE
