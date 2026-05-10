/client/var/device_fingerprint_hash
/client/var/device_computerid_hash
/client/var/device_ip_prefix_hash
/client/var/browser_fingerprint_hash
/client/var/browser_token_hash
/client/var/device_risk_score = 0
/client/var/list/device_risk_flags = list()
/client/var/list/device_browser_risk_flags = list()
/client/var/device_fingerprint_secret_warned = FALSE

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
	device_fingerprint_add_flag(flag)

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

	device_risk_flags = list()
	device_risk_score = 0
	if(length(device_browser_risk_flags))
		for(var/browser_flag in device_browser_risk_flags)
			device_fingerprint_add_flag(browser_flag)

	var/ip_prefix = device_fingerprint_ip_prefix(address)
	device_computerid_hash = make_device_fingerprint_hash("cid", computer_id)
	device_ip_prefix_hash = make_device_fingerprint_hash("ip", ip_prefix)
	device_fingerprint_hash = make_device_fingerprint_hash("bundle", "[DEVICE_FINGERPRINT_SCHEMA]|cid=[computer_id]|ip=[ip_prefix]|byond=[byond_version].[byond_build]")

	if(open_browser && config.device_fingerprint_browser && !browser_fingerprint_hash)
		if(device_fingerprint_open_browser())
			return

	if(!computer_id)
		device_fingerprint_add_flag("blank_cid")
		device_risk_score += 15
	if(!browser_fingerprint_hash && config.device_fingerprint_browser)
		device_fingerprint_add_flag("browser_payload_missing")
	if("browser_payload_invalid" in device_risk_flags)
		device_risk_score += 5
	if("browser_payload_changed" in device_risk_flags)
		device_risk_score += 10
	if("possible_vm_environment" in device_risk_flags)
		device_risk_score += 15
	if("browser_software_renderer" in device_risk_flags)
		device_risk_score += 5
	if("browser_automation_hint" in device_risk_flags)
		device_risk_score += 10

	if(device_computerid_hash && device_fingerprint_related_count("computerid_hash", device_computerid_hash))
		device_fingerprint_add_flag("shared_cid_with_other_ckeys")
		device_risk_score += 20
	if(browser_fingerprint_hash && device_fingerprint_related_count("browser_hash", browser_fingerprint_hash))
		device_fingerprint_add_flag("shared_browser_with_other_ckeys")
	if(browser_token_hash && device_fingerprint_related_count("browser_token_hash", browser_token_hash))
		device_fingerprint_add_flag("shared_browser_token_with_other_ckeys")
		device_risk_score += 30
	if(device_ip_prefix_hash && device_fingerprint_related_count("ip_prefix_hash", device_ip_prefix_hash))
		device_fingerprint_add_flag("shared_ip_with_other_ckeys")
	if(device_fingerprint_distinct_count("ckey", ckey, "ip_prefix_hash") > 3)
		device_fingerprint_add_flag("many_ip_prefixes_for_ckey")
		device_risk_score += 8
	if(device_computerid_hash && device_fingerprint_distinct_count("computerid_hash", device_computerid_hash, "ip_prefix_hash") > 3)
		device_fingerprint_add_flag("stable_cid_many_ip_prefixes")
		device_risk_score += 15
	if(browser_fingerprint_hash && device_fingerprint_distinct_count("browser_hash", browser_fingerprint_hash, "ip_prefix_hash") > 3)
		device_fingerprint_add_flag("stable_browser_many_ip_prefixes")
	if(device_fingerprint_active_ban_matches())
		device_fingerprint_add_flag("matched_fingerprint_with_active_ban_history")
		device_risk_score += 45
	if(device_computerid_hash && device_fingerprint_active_ban_matches("computerid_hash", device_computerid_hash))
		device_fingerprint_add_flag("matched_cid_with_active_ban_history")
		device_risk_score += 45
	if(browser_fingerprint_hash && device_fingerprint_active_ban_matches("browser_hash", browser_fingerprint_hash))
		device_fingerprint_add_flag("matched_browser_with_active_ban_history")
		device_risk_score += 15
	if(browser_token_hash && device_fingerprint_active_ban_matches("browser_token_hash", browser_token_hash))
		device_fingerprint_add_flag("matched_browser_token_with_active_ban_history")
		device_risk_score += 55
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
	report_flags -= "browser_payload_missing"
	if(!length(report_flags))
		return
	message_staff(SPAN_WARNING("[key_name_admin(src)] has device fingerprint risk flags: [jointext(report_flags, ", ")]. Score: [device_risk_score]."))
