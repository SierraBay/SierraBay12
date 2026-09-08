/datum/persistent/mod_last_online
	name = "mod_last_online"

/datum/persistent/mod_last_online/Initialize()
	return

/datum/persistent/mod_last_online/FinalizeTokens(list/tokens)
	if(fexists(filename))
		var/list/token_sets = json_decode(file2text(filename))
		return token_sets

/datum/persistent/mod_last_online/Shutdown()
	var/list/online = list()
	var/player_count = 0

	for(var/client/C in GLOB.clients)
		++player_count

	online["last_online"] = player_count

	var/error = rustg_file_write(json_encode(online), filename)
	if (error)
		crash_with(error)
