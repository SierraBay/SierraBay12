/mob/observer/ghost/scan_target()
	if(ishuman(following))
		var/mob/living/carbon/human/H = following
		var/dat = display_medical_data(H.get_raw_medical_data(), SKILL_MAX)

		dat += text("<BR><A href='?src=\ref[];mach_close=scanconsole'>Close</A>", usr)
		show_browser(src, dat, "window=scanconsole;size=430x600")

	else if(issilicon(following))
		var/mob/living/silicon/robot/R = following
		var/BU = R.getFireLoss() > 50 	? 	"<b>[R.getFireLoss()]</b>" 		: R.getFireLoss()
		var/BR = R.getBruteLoss() > 50 	? 	"<b>[R.getBruteLoss()]</b>" 	: R.getBruteLoss()
		src.show_message("<span class='notice'>Analyzing Results for [R]:\n\t Overall Status: [R.stat > 1 ? "fully disabled" : "[R.health - R.getHalLoss()]% functional"]</span>")
		src.show_message("\t Key: <font color='#ffa500'>Electronics</font>/<font color='red'>Brute</font>", 1)
		src.show_message("\t Damage Specifics: <font color='#ffa500'>[BU]</font> - <font color='red'>[BR]</font>")
		if(R.stat == DEAD)
			src.show_message("<span class='notice'>Time of Failure: [worldtime2stationtime(R.timeofdeath)]</span>")
		var/list/damaged = R.get_damaged_components(1,1,1)
		src.show_message("<span class='notice'>Localized Damage:</span>",1)
		if(length(damaged)>0)
			for(var/datum/robot_component/org in damaged)
				src.show_message(text("<span class='notice'>\t []: [][] - [] - [] - []</span>",	\
				capitalize(org.name),					\
				(org.installed == -1)	?	"<font color='red'><b>DESTROYED</b></font> "							:"",\
				(org.electronics_damage > 0)	?	"<font color='#ffa500'>[org.electronics_damage]</font>"	:0,	\
				(org.brute_damage > 0)	?	"<font color='red'>[org.brute_damage]</font>"							:0,		\
				(org.toggled)	?	"Toggled ON"	:	"<font color='red'>Toggled OFF</font>",\
				(org.powered)	?	"Power ON"		:	"<font color='red'>Power OFF</font>"),1)
		else
			src.show_message("<span class='notice'>\t Components are OK.</span>",1)
		src.show_message("<span class='notice'>Operating Temperature: [R.bodytemperature-T0C]&deg;C ([R.bodytemperature*1.8-459.67]&deg;F)</span>", 1)
