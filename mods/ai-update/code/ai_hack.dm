/obj/machinery/door/airlock
	var/hackProof = FALSE
	var/aiHacking = FALSE


/obj/machinery/door/airlock/proc/canAIHack()
	return ((src.ai_control_disabled == TRUE) && (!hackProof) && (!src.isAllPowerLoss()));

/obj/machinery/door/airlock/proc/hack(mob/user as mob)
	if(!src.aiHacking)
		src.aiHacking = TRUE
		spawn(20)
			//TODO: Make this take a minute
			to_chat(user, "Airlock AI control has been blocked. Beginning fault-detection.")
			sleep(50)
			if(src.canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				src.aiHacking = FALSE
				return
			else if(!src.canAIHack(user))
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				src.aiHacking = FALSE
				return
			to_chat(user, "Fault confirmed: airlock control wire disabled or cut.")
			sleep(20)
			to_chat(user, "Attempting to hack into airlock. This may take some time.")
			sleep(200)
			if(src.canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				src.aiHacking = FALSE
				return
			else if(!src.canAIHack(user))
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				src.aiHacking = FALSE
				return
			to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
			sleep(170)
			if(src.canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				src.aiHacking = FALSE
				return
			else if(!src.canAIHack(user))
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				src.aiHacking = FALSE
				return
			to_chat(user, "Transfer complete. Forcing airlock to execute program.")
			sleep(50)
			//disable blocked control
			src.ai_control_disabled = 2
			to_chat(user, "Receiving control information from airlock.")
			sleep(10)
			//bring up airlock dialog
			src.aiHacking = FALSE
			if (user)
				src.attack_ai(user)
