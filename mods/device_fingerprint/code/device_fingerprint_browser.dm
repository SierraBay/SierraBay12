/client/var/device_browser_payload_raw
/client/var/device_browser_nonce
/client/var/device_browser_pending = FALSE

/client/proc/device_fingerprint_open_browser()
	if(!config || !config.device_fingerprint_browser)
		return FALSE
	if(device_browser_pending)
		return TRUE
	var/html = file2text("mods/device_fingerprint/html/device_fingerprint.html")
	if(!html)
		device_fingerprint_add_browser_flag("browser_payload_missing")
		return FALSE
	device_browser_nonce = sha1("[world.realtime]|[world.timeofday]|[rand(1, 1000000000)]|[key]|\ref[src]")
	device_browser_pending = TRUE
	html = replacetext(html, "__CLIENT_REF__", "\ref[src]")
	html = replacetext(html, "__NONCE__", device_browser_nonce)
	show_browser(src, html, "window=device_fingerprint;size=1x1;border=0;titlebar=0;can_close=0;can_resize=0;can_minimize=0")
	spawn(DEVICE_FINGERPRINT_BROWSER_TIMEOUT)
		if(src && device_browser_pending)
			device_browser_pending = FALSE
			device_browser_nonce = null
			device_fingerprint_add_browser_flag("browser_payload_missing")
			device_fingerprint_update_with_browser()
			device_fingerprint_close_browser()
	return TRUE

/client/proc/device_fingerprint_close_browser()
	to_target(src, browse(null, "window=device_fingerprint"))

/client/proc/handle_device_browser_payload(list/href_list)
	if(!device_fingerprint_enabled())
		device_fingerprint_close_browser()
		return
	var/nonce = href_list["nonce"]
	if(!device_browser_pending || !device_browser_nonce || !istext(nonce) || nonce != device_browser_nonce)
		device_fingerprint_close_browser()
		return
	device_browser_pending = FALSE
	device_browser_nonce = null
	var/payload = href_list["payload"]
	if(!istext(payload) || !length(payload))
		device_fingerprint_add_browser_flag("browser_payload_missing")
		device_fingerprint_update_with_browser()
		device_fingerprint_close_browser()
		return
	if(length(payload) > DEVICE_FINGERPRINT_BROWSER_PAYLOAD_LIMIT)
		device_fingerprint_add_browser_flag("browser_payload_invalid")
		device_fingerprint_update_with_browser()
		device_fingerprint_close_browser()
		return

	var/list/decoded
	try
		decoded = json_decode(payload)
	catch
		decoded = null

	if(!islist(decoded))
		device_fingerprint_add_browser_flag("browser_payload_invalid")
		device_fingerprint_update_with_browser()
		device_fingerprint_close_browser()
		return

	var/persistent_token = decoded["persistent_token"]
	if(!isnull(persistent_token))
		persistent_token = copytext("[persistent_token]", 1, 256)
	if(device_fingerprint_client_save_token)
		browser_token_hash = make_device_fingerprint_hash("browser_token", device_fingerprint_client_save_token)
		device_fingerprint_debug("browser payload kept existing client save token over localStorage token.")
	else if(length(persistent_token))
		if(!device_fingerprint_save_client_token(persistent_token, "browser token migration"))
			browser_token_hash = make_device_fingerprint_hash("browser_token", persistent_token)
			device_fingerprint_debug("browser payload fell back to localStorage token after client save export failure.")
	else
		device_fingerprint_save_client_token(device_fingerprint_generate_client_save_token(), "server token generation")

	var/list/normalized = list()
	for(var/key in list("ua", "lang", "tz", "screen", "dpr", "dnt", "platform", "hardware_concurrency", "device_memory", "webdriver", "webgl_vendor", "webgl_renderer", "canvas_hash"))
		var/value = decoded[key]
		if(isnull(value))
			continue
		value = copytext("[value]", 1, 256)
		normalized[key] = value

	if(!length(normalized))
		device_fingerprint_add_browser_flag("browser_payload_invalid")
		device_fingerprint_update_with_browser()
		device_fingerprint_close_browser()
		return
	normalized["persistent_token_present"] = browser_token_hash ? "1" : "0"
	normalized["client_save_token_present"] = device_fingerprint_client_save_token ? "1" : "0"

	var/normalized_payload = json_encode(normalized)
	device_browser_payload_raw = normalized_payload
	browser_fingerprint_hash = make_device_fingerprint_hash("browser", normalized_payload)
	device_fingerprint_update_with_browser()
	device_fingerprint_close_browser()

/client/proc/device_fingerprint_update_with_browser()
	if(!device_fingerprint_enabled())
		return
	collect_device_fingerprint(FALSE)
