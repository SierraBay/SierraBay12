/mob/observer/ghost/scan_target()
	if(ishuman(following))
		var/mob/living/carbon/human/H = following
		var/dat = display_medical_data(H.get_raw_medical_data(), SKILL_MAX)

		dat += "<A href='byond://?src=\ref[usr];mach_close=scanconsole'>Close</A>"
		show_browser(usr, dat, "window=scanconsole;size=430x600")

	else if(issilicon(following))
		var/mob/living/silicon/robot/R = following
		var/BU = R.getFireLoss() > 50 	? 	"<b>[R.getFireLoss()]</b>" 		: R.getFireLoss()
		var/BR = R.getBruteLoss() > 50 	? 	"<b>[R.getBruteLoss()]</b>" 	: R.getBruteLoss()
		src.show_message(SPAN_NOTICE("Analyzing Results for [R]:\n\t Overall Status: [R.stat > 1 ? "fully disabled" : "[R.health - R.getHalLoss()]% functional"]"))
		src.show_message("\t Key: <font color='#ffa500'>Electronics</font>/<font color='red'>Brute</font>", 1)
		src.show_message("\t Damage Specifics: <font color='#ffa500'>[BU]</font> - <font color='red'>[BR]</font>")
		if(R.stat == DEAD)
			src.show_message(SPAN_NOTICE("Time of Failure: [time2text(worldtime2stationtime(R.timeofdeath))]"))
		var/list/damaged = R.get_damaged_components(1,1,1)
		src.show_message(SPAN_NOTICE("Localized Damage:"),1)
		if(length(damaged)>0)
			for(var/datum/robot_component/org in damaged)
				var/message = "\t [capitalize(org.name)]: "
				message += (org.installed == -1) ? SPAN_COLOR("red", "<b>DESTROYED</b> ") : ""
				message += (org.electronics_damage > 0) ? SPAN_COLOR("#ffa500", org.electronics_damage) : "0"
				message += (org.brute_damage > 0) ? SPAN_COLOR("red", org.brute_damage) : "0"
				message += org.toggled ? "Toggled ON" : SPAN_COLOR("red", "Toggled OFF")
				message += org.powered ? "Power ON" : SPAN_COLOR("red", "Power OFF")
				src.show_message(SPAN_NOTICE(message), VISIBLE_MESSAGE)
		else
			src.show_message(SPAN_NOTICE("\t Components are OK."),1)
			if(R.emagged && prob(5))
				src.show_message(SPAN_WARNING("\t ERROR: INTERNAL SYSTEMS COMPROMISED"),1)
				src.show_message(SPAN_NOTICE("Operating Temperature: [R.bodytemperature-T0C]&deg;C ([R.bodytemperature*1.8-459.67]&deg;F)"), 1)