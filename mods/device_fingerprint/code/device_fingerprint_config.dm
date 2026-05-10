#define DEVICE_FINGERPRINT_SCHEMA "v2"
#define DEVICE_FINGERPRINT_BROWSER_PAYLOAD_LIMIT 4096
#define DEVICE_FINGERPRINT_BROWSER_TIMEOUT 150

/datum/configuration
	var/static/device_fingerprint_secret = ""
	var/static/device_fingerprint_browser = TRUE
	var/static/device_fingerprint_raw_storage = FALSE
	var/static/device_fingerprint_retention_days = 180
	var/static/device_fingerprint_alert_threshold = 25

/datum/configuration/load_config()
	. = ..()
	var/list/file = read_config("config/config.txt")
	for(var/name in file)
		var/value = file[name]
		if(islist(value))
			value = value[length(value)]
		switch(name)
			if("device_fingerprint_secret")
				device_fingerprint_secret = value
			if("device_fingerprint_browser")
				device_fingerprint_browser = text2num(value) != 0
			if("device_fingerprint_raw_storage")
				device_fingerprint_raw_storage = text2num(value) != 0
			if("device_fingerprint_retention_days")
				device_fingerprint_retention_days = max(0, text2num(value))
			if("device_fingerprint_alert_threshold")
				device_fingerprint_alert_threshold = max(0, text2num(value))
