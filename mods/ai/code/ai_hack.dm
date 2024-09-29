/obj/machinery/door/airlock
	var/hackProof = FALSE
	var/aiHacking = FALSE


/obj/machinery/door/airlock/proc/canAIHack()
	return ((src.ai_control_disabled == TRUE) && (!hackProof) && (!src.isAllPowerLoss()));

/obj/machinery/door/airlock/proc/start_hack(mob/user)
	if(!src.aiHacking)
		src.aiHacking = TRUE
		to_chat(user, "Airlock AI control has been blocked, airlock control wire disabled or cut. Attempting to hack into airlock. This may take some time.")
		addtimer(new Callback(src, PROC_REF(result_hack), user), 40 SECONDS)

/obj/machinery/door/airlock/proc/result_hack(mob/user)
	if(src.canAIControl())
		to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
		src.aiHacking = FALSE
		return
	else if(!src.canAIHack(user))
		to_chat(user, "We've lost our connection! Unable to hack airlock.")
		src.aiHacking = FALSE
		return


	//Взлом успешен, работаем.
	to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
	src.ai_control_disabled = 2
	to_chat(user, "Receiving control information from airlock. Forcing airlock to execute program.")
	//bring up airlock dialog
	src.aiHacking = FALSE
	if (user)
		src.attack_ai(user)
