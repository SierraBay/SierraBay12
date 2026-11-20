/singleton/psi_disorder/custom
	id =          "custom"
	name =        "Своя"
	group =       null
	description = "Собственное пси-расстройство."
	delay_min =   30 SECONDS
	delay_max =   90 SECONDS

/singleton/psi_disorder/custom/get_name(list/state)
	return state["name"] || name

/singleton/psi_disorder/custom/get_description(list/state)
	return state["desc"] || description

/singleton/psi_disorder/custom/process(mob/living/owner, datum/psi_complexus/psi, list/state)
	var/mob/living/carbon/human/H
	if(!H)
		return
	// Периодически напоминает игроку о его расстройстве.
	if(prob(40) && length(state["desc"]))
		to_chat(H, SPAN_OCCULT("[state["name"]]: [state["desc"]]"))
	switch(state["group"])
		if("green")
			H.make_jittery(5)
		if("blue")
			H.make_jittery(15)
		if("red")
			H.make_jittery(25)
			if(prob(30))
				H.adjust_hallucination(rand(5, 12))
			if(prob(10))
				psi.trigger_instability(1)
