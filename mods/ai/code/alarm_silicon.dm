/mob/living/silicon/proc/receive_alarm(datum/alarm_handler/alarm_handler, datum/alarm/alarm, was_raised)
	if(!next_alarm_notice || next_alarm_notice == 0)
		next_alarm_notice = world.time + 100

	var/list/alarms = queued_alarms[alarm_handler]
	if(was_raised)
		// Raised alarms are always set
		alarms[alarm] = 1
	else
		// Alarms that were raised but then cleared before the next notice are instead removed
		if(alarm in alarms)
			alarms -= alarm
		// And alarms that have only been cleared thus far are set as such
		else
			alarms[alarm] = -1

/mob/living/silicon/proc/process_queued_alarms()
	if(next_alarm_notice && (world.time > next_alarm_notice))
		next_alarm_notice = 0

		var/alarm_raised = 0
		///НЕ показывает тревогу если та не с наших Z уровней
		var/dont_show = TRUE
		for(var/datum/alarm_handler/AH in queued_alarms)
			var/list/alarms = queued_alarms[AH]
			var/reported = 0
			for(var/datum/alarm/A in alarms)
				if(alarms[A] == 1)
					alarm_raised = 1
					if(!reported)
						reported = 1
						var/datum/alarm_source/sources_of_alarm = A.sources[1]
						// sources_of_alarm.source
						if(AreConnectedZLevels(get_z(src), get_z(sources_of_alarm.source)))
							to_chat(src, "<span class='warning'>--- [AH.category] Detected ---</span>")
							dont_show = FALSE
							raised_alarm(A)

		for(var/datum/alarm_handler/AH in queued_alarms)
			var/list/alarms = queued_alarms[AH]
			var/reported = 0
			for(var/datum/alarm/A in alarms)
				if(alarms[A] == -1)
					if(!reported)
						reported = 1
						to_chat(src, "<span class='notice'>--- [AH.category] Cleared ---</span>")
					if(!dont_show)
						to_chat(src, "\The [A.alarm_name()].")

		if(alarm_raised && !dont_show)
			to_chat(src, "<A HREF=?src=\ref[src];showalerts=1>\[Show Alerts\]</A>")

		for(var/datum/alarm_handler/AH in queued_alarms)
			var/list/alarms = queued_alarms[AH]
			alarms.Cut()

/mob/living/silicon/ai/Life()
	.=..()
	process_queued_alarms()

/mob/living/silicon/robot/Life()
	.=..()
	process_queued_alarms()
