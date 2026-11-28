/singleton/psi_disorder/sob
	id =          "sob"
	name =        "СОБ (нарушение терморегуляции)"
	group =       "blue"
	description = "Механизм поддержания комфортной температуры тела пациента нарушается, что вызывает перегрев, грозящий денатурацией белка, или замедление кровообращения и гипоксию на фоне общего переохлаждения тела."
	delay_min =   4 SECONDS
	delay_max =   8 SECONDS

	var/temperature_step = 20

/singleton/psi_disorder/sob/process(mob/living/owner, datum/psi_complexus/psi, list/state)
	var/mob/living/carbon/human/H
	if(!H)
		return
	if(world.time < state["episode_until"])
		if(state["mode"] == "hot")
			if(H.bodytemp + temperature_step < H.species.heat_level_1 - 1)
				H.bodytemperature += temperature_step
		else
			if(H.bodytemp - temperature_step > H.species.cold_level_1 + 1)
				H.bodytemperature -= temperature_step
		return
	else
		state["next"] = world.time + rand(30 MINUTES, 60 MINUTES)

	state["mode"] = pick("hot", "cold")
	state["episode_until"] = world.time + 5 MINUTES
