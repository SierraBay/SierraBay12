/// The name of the controller
/datum/controller
	var/name

	/// The atom used to hold information about the controller for client UI output
	var/obj/clickable_stat/__stat


	/// The next time we should do work updating __stat
	var/__stat_next = 0


/datum/controller/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	return QDEL_HINT_LETMELIVE


/datum/controller/proc/Initialize()
	return


/datum/controller/proc/Shutdown()
	return


/datum/controller/proc/Recover()
	return


/// when we enter dmm_suite.load_map
/datum/controller/proc/StartLoadingMap()
	return

/// when we exit dmm_suite.load_map
/datum/controller/proc/StopLoadingMap()
	return


/datum/controller/proc/UpdateStat(text)
	if (!__stat)
		__stat = new (null, src)
	if (istext(text))
		__stat.name = text
	stat(name, __stat)


/datum/controller/proc/PreventUpdateStat(time)
	if (!isnum(time))
		time = uptime()
	if (time < __stat_next)
		return TRUE
	__stat_next = time + 1 SECONDS
	return FALSE
