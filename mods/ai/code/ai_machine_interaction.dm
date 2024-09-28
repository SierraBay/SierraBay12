/*
///АПЦ ИНТЕРАКТ
/obj/machinery/power/apc/CanUseTopic(mob/user, datum/topic_state/state)
	if(user.lying)
		to_chat(user, SPAN_WARNING("You must stand to use [src]!"))
		return STATUS_CLOSE
	if(istype(user, /mob/living/silicon))
		var/permit = 0 // Malfunction variable. If AI hacks APC it can control it even without AI control wire.
		var/mob/living/silicon/ai/AI = user
		var/mob/living/silicon/robot/robot = user
		if(hacker && !hacker.hacked_apcs_hidden)
			if(hacker == AI)
				permit = 1
			else if(istype(robot) && robot.connected_ai && robot.connected_ai == hacker) // Cyborgs can use APCs hacked by their AI
				permit = 1

		if(aidisabled && !permit)
			return STATUS_CLOSE
	. = ..()
	if(isAI(user))
		. = 2
	if(user.restrained())
		to_chat(user, SPAN_WARNING("You must have free hands to use [src]."))
		. = min(., STATUS_UPDATE)
*/


///ИНТЕРАКТ С ШЛЮЗОМ
/obj/machinery/door/airlock/CanUseTopic(mob/user)
	if (operating == DOOR_OPERATING_BROKEN) //emagged
		to_chat(user, SPAN_WARNING("Unable to interface: Internal error."))
		return STATUS_CLOSE
	if(issilicon(user) && !src.canAIControl())
		if(ai_control_disabled != 2)
			if(src.canAIHack(user))
				src.start_hack(user)
		if(ai_control_disabled == 2)
			return ..()
		else
			if (src.isAllPowerLoss()) //don't really like how this gets checked a second time, but not sure how else to do it.
				to_chat(user, "<span class='warning'>Unable to interface: Connection timed out.</span>")
			else
				to_chat(user, "<span class='warning'>Unable to interface: Connection refused.</span>")
		return STATUS_CLOSE

	return ..()

/*
/obj/machinery/CanUseTopic(mob/user)
	if(MACHINE_IS_BROKEN(src))
		return STATUS_CLOSE

	if(!interact_offline && (!is_powered()))
		return STATUS_CLOSE

	if(user.direct_machine_interface(src))
		var/mob/living/silicon/silicon = user
		if (silicon_restriction && ismachinerestricted(silicon))
			if (silicon_restriction == STATUS_CLOSE)
				to_chat(user, SPAN_WARNING("Remote AI systems detected. Firewall protections forbid remote AI access."))
			return silicon_restriction

	if(isAI(user))
		return STATUS_UPDATE

	if(GET_FLAGS(stat, MACHINE_STAT_NOSCREEN))
		return STATUS_CLOSE

	if(GET_FLAGS(stat, MACHINE_STAT_NOINPUT))
		return min(..(), STATUS_UPDATE)
	return ..()
*/
/obj/machinery/door/airlock/proc/CanAIUseTopic(mob/user)
	if (operating == DOOR_OPERATING_BROKEN) //emagged
		to_chat(user, SPAN_WARNING("Unable to interface: Internal error."))
		return FALSE
	if(issilicon(user) && !src.canAIControl())
		//[SIERRA-ADD] - AI-UPDATE
		if(ai_control_disabled != 2)
			if(src.canAIHack(user))
				src.start_hack(user)
		if(ai_control_disabled == 2)
			return TRUE
		//[SIERRA-ADD]
		return FALSE
	return TRUE
