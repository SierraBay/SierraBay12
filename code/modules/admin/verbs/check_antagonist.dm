/datum/admins/proc/check_antagonists()
	if (GAME_STATE >= RUNLEVEL_GAME)
		var/dat = list()
		dat += "<html><head><title>Round Status</title></head><body><h1><B>Round Status</B></h1>"
		dat += "Current Game Mode: <B>[SSticker.mode.name]</B><BR>"
		dat += "Round Duration: <B>[roundduration2text()]</B><BR>"
		dat += "<B>Evacuation</B><BR>"
		if (evacuation_controller.is_idle())
			dat += "<a href='?src=\ref[src];call_shuttle=1'>Call Evacuation</a><br>"
		else
			var/timeleft = evacuation_controller.get_eta()
			if (evacuation_controller.waiting_to_leave())
				dat += "ETA: [(timeleft / 60) % 60]:[pad_left(num2text(timeleft % 60), 2, "0")]<BR>"
				dat += "<a href='?src=\ref[src];call_shuttle=2'>Send Back</a><br>"

		dat += "<a href='?src=\ref[src];delay_round_end=1'>[SSticker.delay_end ? "End Round Normally" : "Delay Round End"]</a><br>"
		dat += "<hr>"
		var/list/all_antag_types = GLOB.all_antag_types_
		for(var/antag_type in all_antag_types)
			var/datum/antagonist/A = all_antag_types[antag_type]
			dat += A.get_check_antag_output(src)
		dat += "</body></html>"
		show_browser(usr, jointext(dat,null), "window=roundstatus;size=400x500")
	else
		alert("The game hasn't started yet!")
