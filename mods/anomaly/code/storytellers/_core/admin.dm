/datum/admins/proc/listen_anomaly_storytellers()
	set category = "Fun"
	set desc = "Start listen debug message from storyteller"
	set name = "Switch storyteller debug listening"

	if(!check_rights(R_DEBUG))
		return
	if(usr.ckey in SSanom.debug_storyteller_listeners)
		to_chat(usr, SPAN_NOTICE("Более вы не слышите дебаг сообщений рассказчика"))
		LAZYREMOVE(SSanom.debug_storyteller_listeners, usr.ckey)
	else
		to_chat(usr, SPAN_NOTICE("Вы начали прослушивать дебаг сообщения рассказчика"))
		LAZYADD(SSanom.debug_storyteller_listeners, usr.ckey)
