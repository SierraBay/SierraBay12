/datum/preferences/save_pref_record(record_key, list/data)
	var/path = get_path(client_ckey, record_key)
	var/text = json_encode(data)

	if(isnull(text))
		log_error("JSON encode failed for [path] | Ckey: [client_ckey] | Record: [record_key]")
		message_admins("JSON encode failed for [path] | Ckey: [client_ckey] | Record: [record_key]")
		return

	var/error = rustg_file_write(text, path)
	if (error)
		log_error("Preferences save failed: [error] | Path: [path] | Ckey: [client_ckey] | Record: [record_key] | Text length: [length(text)]")
		message_admins("Preferences save failed: [error] | Path: [path] | Ckey: [client_ckey] | Record: [record_key] | Text length: [length(text)]")
		return
