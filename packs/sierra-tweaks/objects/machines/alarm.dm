/obj/machinery/firealarm/interact(mob/user)
	user.set_machine(src)
	var/area/A = src.loc
	var/d1
	var/d2
	var/dat = list()
	var/singleton/security_state/security_state = GET_SINGLETON(GLOB.using_map.security_state)
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon))
		A = A.loc

		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>Reset - Lockdown</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>Alarm - Lockdown</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		dat += "<HTML><HEAD></HEAD><BODY><TT><B>Fire alarm</B> [d1]\n<HR>The current alert level is <b>[security_state.current_security_level.name]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? "[minute]:" : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n</TT></BODY></HTML>"
		var/datum/browser/popup = new(user, "fire_alarm", "Fire Alarm", 275, 195)
		popup.set_content(JOINTEXT(dat))
		popup.open()
		onclose(user, "firealarm")
	else
		A = A.loc
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("Reset - Lockdown"))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("Alarm - Lockdown"))
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		dat += "<HTML><HEAD></HEAD><BODY><TT><B>[stars("Fire alarm")]</B> [d1]\n<HR>The current security level is <b>[security_state.current_security_level.name]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? text("[]:", minute) : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n</TT></BODY></HTML>"
		var/datum/browser/popup = new(user, "fire_alarm", "Fire Alarm", 275, 195)
		popup.set_content(JOINTEXT(dat))
		popup.open()
		onclose(user, "firealarm")
	return
	
