/singleton/psi_disorder/sleep_stretch
	id =          "sleep_stretch"
	name =        "Растяжение сонного цикла"
	group =       "blue"
	description = "Сны становятся всё длиннее. Купируется метилфенидатом."
	delay_min =   30 SECONDS
	delay_max =   60 SECONDS

/singleton/psi_disorder/sleep_stretch/process(mob/living/owner, datum/psi_complexus/psi, list/state)
	var/mob/living/carbon/human/H
	if(!H)
		return
	if(H.reagents)
		for(var/datum/reagent/R in H.reagents.reagent_list)
			if(istype(R, /datum/reagent/methylphenidate))
				return
	if(H.sleeping && prob(25))
		H.AdjustSleeping(H.sleeping + rand(1, 10))
		return
