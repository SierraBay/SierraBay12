#ifndef PSI_IMPLANT_AUTOMATIC
#define PSI_IMPLANT_AUTOMATIC "Security Level Derived"
#endif
#ifndef PSI_IMPLANT_SHOCK
#define PSI_IMPLANT_SHOCK     "Issue Neural Shock"
#endif
#ifndef PSI_IMPLANT_WARN
#define PSI_IMPLANT_WARN      "Issue Reprimand"
#endif
#ifndef PSI_IMPLANT_LOG
#define PSI_IMPLANT_LOG       "Log Incident"
#endif
#ifndef PSI_IMPLANT_DISABLED
#define PSI_IMPLANT_DISABLED  "Disabled"
#endif

/obj/item/implant/psi_control
	name = "psi dampener implant"
	desc = "A safety implant for registered psi-operants."
	known = TRUE

	var/overload = 0
	var/max_overload = 100
	var/psi_mode = PSI_IMPLANT_DISABLED

/obj/item/implant/psi_control/get_data()
	. = {"
	<b>Технические данные:</b><BR>
	<b>Название:</b> Псионический подавитель переключатель Фонда Кухулин<BR>
	<b>Заметки:</b> Не защищен от ЭМИ и перегрева психонетикой<BR>
	<HR>
	<b>Детали:</b><BR>
	<b>Функция:</b> Имплант переключатель дистанционно управляется психонетическим стационарным монитором для переключения режима подавления психонетических способностей. Имеет четыре режима.<BR>
	<b>Дополнительно:</b> Автоматическое переключение в режим активного подавления при повышении уровня угрозы<BR>"}
	if(!malfunction)
		. += {"
		<HR><B>Режим работы:</B><BR>
		<a href='byond://?src=\ref[src];mode=1'>[psi_mode ? psi_mode : "NONE SET"]</A><BR>"}

/obj/item/implant/psi_control/islegal()
	return TRUE

/obj/item/implant/psi_control/Initialize()
	. = ..()
	SSpsi.psi_dampeners += src

/obj/item/implant/psi_control/Topic(href, href_list)
	..()
	if (href_list["mode"])
		var/mod = input("Установить режим подавления", "Режим подавления") as null|anything in list(PSI_IMPLANT_DISABLED, PSI_IMPLANT_LOG, PSI_IMPLANT_WARN, PSI_IMPLANT_SHOCK, PSI_IMPLANT_AUTOMATIC)
		if(mod)
			psi_mode = mod
		interact(usr)

/obj/item/implant/psi_control/Destroy()
	SSpsi.psi_dampeners -= src
	. = ..()

/obj/item/implant/psi_control/emp_act()
	..()
	update_functionality()

/obj/item/implant/psi_control/meltdown()
	. = ..()
	update_functionality()

/obj/item/implant/psi_control/disrupts_psionics()
	var/use_psi_mode = get_psi_mode()
	return (!malfunction && (use_psi_mode == PSI_IMPLANT_SHOCK || use_psi_mode == PSI_IMPLANT_WARN)) ? src : FALSE

/obj/item/implant/psi_control/removed()
	var/mob/living/M = imp_in
	if(disrupts_psionics() && istype(M) && M.psi)
		to_chat(M, SPAN_NOTICE("You feel the chilly shackles around your psionic faculties fade away."))
	. = ..()

/obj/item/implant/psi_control/proc/update_functionality(silent)
	var/mob/living/M = imp_in
	if(get_psi_mode() == PSI_IMPLANT_DISABLED || malfunction)
		if(implanted && !silent && istype(M) && M.psi)
			to_chat(M, SPAN_NOTICE("You feel the chilly shackles around your psionic faculties fade away."))
	else
		if(implanted && !silent && istype(M) && M.psi)
			to_chat(M, SPAN_NOTICE("Bands of hollow ice close themselves around your psionic faculties."))

/obj/item/implant/psi_control/meltdown()
	if(!malfunction)
		overload = 100
		if(imp_in)
			for(var/thing in SSpsi.psi_monitors)
				var/obj/machinery/psi_monitor/monitor = thing
				monitor.report_failure(src)
	. = ..()

/obj/item/implant/psi_control/proc/get_psi_mode()
	if(psi_mode == PSI_IMPLANT_AUTOMATIC)
		var/singleton/security_state/security_state = GET_SINGLETON(GLOB.using_map.security_state)
		return security_state.current_security_level.psionic_control_level
	return psi_mode

/obj/item/implant/psi_control/withstand_psi_stress(stress, atom/source)

	var/use_psi_mode = get_psi_mode()

	if(malfunction || use_psi_mode == PSI_IMPLANT_DISABLED)
		return stress

	. = 0

	if(stress > 0)

		// If we're disrupting psionic attempts at the moment, we might overload.
		if(disrupts_psionics())
			var/overload_amount = floor(stress/10)
			if(overload_amount > 0)
				overload += overload_amount
				if(overload >= 100)
					if(imp_in)
						to_chat(imp_in, SPAN_DANGER("Your psi dampener overloads violently!"))
					meltdown()
					update_functionality()
					return
				if(imp_in)
					if(overload >= 75 && overload < 100)
						to_chat(imp_in, SPAN_DANGER("Your psi dampener is searing hot!"))
					else if(overload >= 50 && overload < 75)
						to_chat(imp_in, SPAN_WARNING("Your psi dampener is uncomfortably hot..."))
					else if(overload >= 25 && overload < 50)
						to_chat(imp_in, SPAN_WARNING("You feel your psi dampener heating up..."))

		// If all we're doing is logging the incident then just pass back stress without changing it.
		if(source && source == imp_in && implanted)
			for(var/thing in SSpsi.psi_monitors)
				var/obj/machinery/psi_monitor/monitor = thing
				monitor.report_violation(src, stress)
			if(use_psi_mode == PSI_IMPLANT_LOG)
				return stress
			else if(use_psi_mode == PSI_IMPLANT_SHOCK)
				to_chat(imp_in, SPAN_DANGER("Your psi dampener punishes you with a violent neural shock!"))
				imp_in.flash_eyes()
				imp_in.Weaken(5)
				if(isliving(imp_in))
					var/mob/living/M = imp_in
					if(M.psi) M.psi.stunned(5)
			else if(use_psi_mode == PSI_IMPLANT_WARN)
				to_chat(imp_in, SPAN_WARNING("Your psi dampener primly informs you it has reported this violation."))
				//FD PSIONICS//
				//Probably fixing problem with no actual logs coming to computer, dunno why it even have to be on the top of this block//
				for(var/report in SSpsi.psi_monitors)
					var/obj/machinery/psi_monitor/monitor = report
					monitor.report_violation(src, stress)

#undef PSI_IMPLANT_AUTOMATIC
#undef PSI_IMPLANT_SHOCK
#undef PSI_IMPLANT_WARN
#undef PSI_IMPLANT_LOG
#undef PSI_IMPLANT_DISABLED
