/obj/machinery/door/airlock
	var/hackProof = FALSE
	var/aiHacking = FALSE


/obj/machinery/door/airlock/proc/canAIHack(mob/user = null)
	if(user && (!issilicon(user) || user.stat == DEAD || !user.client))
		return FALSE
	return ((src.ai_control_disabled == TRUE) && (!hackProof) && (!src.isAllPowerLoss()));

/obj/machinery/door/airlock/proc/start_hack(mob/user)
	if(!src.aiHacking)
		src.aiHacking = TRUE
		to_chat(user, "Airlock AI control has been blocked, airlock control wire disabled or cut. Attempting to hack into airlock. This may take some time.")
		addtimer(new Callback(src, PROC_REF(result_hack), user), 40 SECONDS)

/obj/machinery/door/airlock/proc/result_hack(mob/user)
	if(QDELETED(src))
		return
	if(!user || !issilicon(user) || user.stat == DEAD || !user.client)
		aiHacking = FALSE
		return
	if(src.canAIControl())
		to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
		src.aiHacking = FALSE
		return
	if(!canAIHack(user))
		to_chat(user, "We've lost our connection! Unable to hack airlock.")
		aiHacking = FALSE
		return


	//Взлом успешен, работаем.
	to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
	src.ai_control_disabled = 2
	to_chat(user, "Receiving control information from airlock. Forcing airlock to execute program.")
	//bring up airlock dialog
	src.aiHacking = FALSE
	if(user && issilicon(user) && user.client && user.stat != DEAD)
		src.attack_ai(user)

#define MALF_APC_HACK_SILENT "Silent Intrusion"
#define MALF_APC_HACK_STANDARD "Standard Hack"
#define MALF_APC_HACK_BRUTEFORCE "Brute-force Override"

/obj/machinery/power/apc
	var/malf_silent_hack = FALSE // If set, a malf AI hacked the APC without obvious APC visual feedback.

/proc/get_apc_hack_modes()
	return list(MALF_APC_HACK_SILENT, MALF_APC_HACK_STANDARD, MALF_APC_HACK_BRUTEFORCE)

/proc/get_apc_hack_price(hack_mode)
	switch(hack_mode)
		if(MALF_APC_HACK_SILENT)
			return 15
		if(MALF_APC_HACK_BRUTEFORCE)
			return 10
	return 10

/proc/get_apc_hack_stage_delays(hack_mode)
	switch(hack_mode)
		if(MALF_APC_HACK_SILENT)
			return list(400, 300, 100)
		if(MALF_APC_HACK_BRUTEFORCE)
			return list(150, 100, 50)
	return list(300, 200, 100)

/proc/get_apc_hack_description(hack_mode)
	switch(hack_mode)
		if(MALF_APC_HACK_SILENT)
			return "15 CPU - Slow, careful intrusion with no obvious APC feedback."
		if(MALF_APC_HACK_BRUTEFORCE)
			return "10 CPU - Fast override that causes obvious APC feedback nearby."
	return "10 CPU - Standard override with current timing and cost."

/proc/is_silent_apc_hack_mode(hack_mode)
	return hack_mode == MALF_APC_HACK_SILENT

/proc/validate_basic_apc_hack(mob/living/silicon/ai/user, obj/machinery/power/apc/A, show_message = TRUE)
	if(!user || !istype(user) || QDELETED(user))
		return FALSE
	if(QDELETED(A) || !istype(A))
		if(show_message)
			to_chat(user, "This is not an APC!")
		return FALSE
	if(A.hacker && A.hacker == user)
		if(show_message)
			to_chat(user, "You already control this APC!")
		return FALSE
	if(A.aidisabled)
		if(show_message)
			to_chat(user, SPAN_NOTICE("Unable to connect to APC. Please verify wire connection and try again."))
		return FALSE
	if(!can_malf_hack_apc(user, A))
		if(show_message)
			to_chat(user, SPAN_NOTICE("Unable to connect to APC. Target is outside your accessible network."))
		return FALSE
	return TRUE

/proc/show_basic_apc_hack_feedback(obj/machinery/power/apc/A, hack_mode, stage)
	if(QDELETED(A) || !istype(A) || hack_mode != MALF_APC_HACK_BRUTEFORCE)
		return
	switch(stage)
		if(1)
			A.visible_message(SPAN_WARNING("\The [A] flashes a rapid sequence of warning lights."))
		if(2)
			A.visible_message(SPAN_WARNING("\The [A] emits a harsh error tone as its interface flickers."))
			playsound(A.loc, 'sound/effects/sparks4.ogg', 50, 1)
		if(3)
			A.visible_message(SPAN_WARNING("\The [A] buzzes loudly and briefly showers sparks."))
			var/datum/effect/spark_spread/sparks = new
			sparks.set_up(3, 1, A)
			sparks.start()

/datum/game_mode/malfunction/verb/basic_encryption_hack(obj/machinery/power/apc/A as obj in get_unhacked_apcs(src))
	set category = "Software"
	set name = "Basic Encryption Hack"
	set desc = "10-15 CPU - Basic encryption hack that allows you to overtake APCs"
	var/mob/living/silicon/ai/user = usr

	if(!A)
		A = input(user, "Select APC to hack", "Basic Encryption Hack") as null|obj in get_unhacked_apcs(user)
		if(!A)
			return

	if(!validate_basic_apc_hack(user, A))
		return

	var/list/hack_modes = get_apc_hack_modes()
	var/hack_mode = input(user, "Select APC hack mode", "Basic Encryption Hack") as null|anything in hack_modes
	if(!hack_mode)
		return

	if(!validate_basic_apc_hack(user, A))
		return

	var/price = get_apc_hack_price(hack_mode)
	if(alert(user, "[get_apc_hack_description(hack_mode)] Hack \the [A] using [hack_mode]?", "Basic Encryption Hack", "Yes", "No") != "Yes")
		to_chat(user, "Hack Aborted")
		return

	if(!validate_basic_apc_hack(user, A))
		return

	if(!ability_prechecks(user, price, TRUE))
		return

	if(!ability_prechecks(user, 0, TRUE))
		to_chat(user, SPAN_NOTICE("Hack cancelled. Your system can no longer sustain the selected hack mode."))
		return

	if(!ability_pay(user, price))
		return

	if(!ability_prechecks(user, 0, TRUE))
		to_chat(user, SPAN_NOTICE("Hack cancelled. Your system can no longer sustain the selected hack mode."))
		return

	log_ability_use(user, "basic encryption hack ([hack_mode])", A, 0)	// Does not notify admins, but it's still logged for reference.
	var/list/stage_delays = get_apc_hack_stage_delays(hack_mode)
	to_chat(user, "Beginning APC system override using [hack_mode]...")
	show_basic_apc_hack_feedback(A, hack_mode, 1)
	sleep(stage_delays[1])
	if(QDELETED(user) || user.stat == DEAD)
		return
	if(!validate_basic_apc_hack(user, A, FALSE))
		to_chat(user, SPAN_NOTICE("Hack failed. Connection to APC has been lost. Please verify wire connection and try again."))
		return
	to_chat(user, "APC hack completed. Uploading modified operation software..")
	show_basic_apc_hack_feedback(A, hack_mode, 2)
	sleep(stage_delays[2])
	if(QDELETED(user) || user.stat == DEAD)
		return
	if(!validate_basic_apc_hack(user, A, FALSE))
		to_chat(user, SPAN_NOTICE("Hack failed. Connection to APC has been lost. Please verify wire connection and try again."))
		return
	to_chat(user, "Restarting APC to apply changes..")
	show_basic_apc_hack_feedback(A, hack_mode, 3)
	sleep(stage_delays[3])
	if(QDELETED(user) || user.stat == DEAD)
		return
	if(QDELETED(A) || !istype(A))
		to_chat(user, SPAN_NOTICE("Hack failed. Unable to locate APC. Please verify the APC still exists."))
		return
	if(!validate_basic_apc_hack(user, A, FALSE))
		to_chat(user, SPAN_NOTICE("Hack failed. Connection to APC has been lost. Please verify wire connection and try again."))
		return
	A.ai_hack(user, is_silent_apc_hack_mode(hack_mode))
	if(A.hacker == user)
		to_chat(user, "Hack successful. You now have full control over \the [A].")
	else
		to_chat(user, SPAN_NOTICE("Hack failed. Connection to APC has been lost. Please verify wire connection and try again."))

/obj/machinery/power/apc/proc/malf_hack_is_visible()
	return hacker && !hacker.hacked_apcs_hidden && !malf_silent_hack

/obj/machinery/power/apc/proc/can_detect_silent_malf_hack(mob/user)
	if(!malf_silent_hack || !user || !user.mind)
		return FALSE
	if(!(user.mind.assigned_role in SSjobs.titles_by_department(ENG)))
		return FALSE
	if(!user.skill_check(SKILL_COMPUTER, SKILL_AVERAGE))
		return FALSE
	return TRUE

/obj/machinery/power/apc/proc/malf_examine(mob/user)
	if(can_detect_silent_malf_hack(user))
		to_chat(user, SPAN_NOTICE("Its control firmware shows subtle irregularities consistent with a concealed intrusion."))

// Malfunction: Transfers APC under AI's control
/obj/machinery/power/apc/proc/ai_hack(mob/living/silicon/ai/A = null, silent = FALSE)
	if(!A || !A.hacked_apcs || hacker || aidisabled || A.is_dead())
		return FALSE
	src.hacker = A
	malf_silent_hack = silent
	A.hacked_apcs += src
	if(!silent)
		locked = TRUE
		update_icon()
	return TRUE
