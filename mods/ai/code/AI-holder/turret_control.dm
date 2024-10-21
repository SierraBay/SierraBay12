AIHOLDER_INITIALIZE(/obj/machinery/porta_turret)

/obj/machinery/porta_turret/Destroy()
	qdel(AiHolder)
	. = ..()

/obj/machinery/porta_turret/attack_ai(mob/living/silicon/ai/ai)
	if(!AiHolder)
		AIHOLDERINIT
	if(istype(ai) && !AiHolder?.MyAI) AiControl(ai)
	. = ..()

/obj/machinery/porta_turret/assume_AI_control(mob/living/silicon/ai/ai)
	. = ..()
	onAiHolderLife()

/obj/machinery/porta_turret/assess_and_assign(mob/living/L, list/targets, list/secondarytargets)
	if(!AiHolder.client)
		. = ..()

/obj/machinery/porta_turret/onAiHolderClickOn(atom/A, params)
	. = ..()
	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		if(raised)
			popDown()
		else
			popUp()
		sleep(1 SECOND)
		to_chat(AiHolder, "Your turret's cover now [raised ? "open" : "closed"]")

	else if(A != src)
		target(A)

	onAiHolderLife()

/obj/machinery/turretid/updateTurrets()
	var/datum/turret_checks/TC = new
	TC.enabled = enabled
	TC.lethal = lethal
	TC.check_synth = check_synth
	TC.check_access = check_access
	TC.check_records = check_records
	TC.check_arrest = check_arrest
	TC.check_weapons = check_weapons
	TC.check_anomalies = check_anomalies
	TC.attack_robots = attack_robots
	TC.hold_deployed = hold_deployed
	TC.ailock = ailock

	if(istype(control_area))
		for (var/obj/machinery/porta_turret/aTurret in control_area)
			aTurret.setState(TC)

	queue_icon_update()


/obj/machinery/porta_turret/setState(datum/turret_checks/TC)
	if(controllock)
		return
	src.enabled = TC.enabled
	src.lethal = TC.lethal
	src.iconholder = TC.lethal

	check_synth = TC.check_synth
	check_access = TC.check_access
	check_records = TC.check_records
	check_arrest = TC.check_arrest
	check_weapons = TC.check_weapons
	check_anomalies = TC.check_anomalies
	attack_robots = TC.attack_robots
	hold_deployed = TC.hold_deployed
	ailock = TC.ailock

	src.power_change()

/*
		Portable turret constructions
		Known as "turret frame"s
*/
