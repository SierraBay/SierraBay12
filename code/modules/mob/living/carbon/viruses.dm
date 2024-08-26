/mob/living/carbon
	var/immunity 		= 100		//current immune system strength
//[SIERRA-ADD] VIRUSOLOGY
	var/immunity_norm 	= 100		//it will regenerate to this value

/mob/living/carbon/proc/handle_viruses()
	if(status_flags & GODMODE)	return 0	//godmode
	if(bodytemperature > 406)
		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			V.cure(src)

	if(life_tick % 3) //don't spam checks over all objects in view every tick.
		for(var/obj/decal/cleanable/O in view(1,src))
			if(istype(O,/obj/decal/cleanable/blood))
				var/obj/decal/cleanable/blood/B = O
				if(isnull(B.virus2))
					B.virus2 = list()
				if(B.virus2.len)
					for (var/ID in B.virus2)
						var/datum/disease2/disease/V = B.virus2[ID]
						infect_virus2(src,V)

			else if(istype(O,/obj/decal/cleanable/mucus))
				var/obj/decal/cleanable/mucus/M = O
				if(isnull(M.virus2))
					M.virus2 = list()
				if(M.virus2.len)
					for (var/ID in M.virus2)
						var/datum/disease2/disease/V = M.virus2[ID]
						infect_virus2(src,V)

	if(virus2.len)
		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			if(isnull(V)) // Trying to figure out a runtime error that keeps repeating
				CRASH("virus2 nulled before calling activate()")
			else
				V.process(src)
			// activate may have deleted the virus
			if(!V) continue

			// check if we're immune
			var/list/common_antibodies = V.antigen & src.antibodies
			if(common_antibodies.len)
				V.dead = 1
//[/SIERRA-ADD] VIRUSOLOGY
	if(immunity > 0.2 * immunity_norm && immunity < immunity_norm)
		immunity = min(immunity + 0.25, immunity_norm)
//[SIERRA-ADD] VIRUSOLOGY
	if(life_tick % 5 && immunity < 15 && chem_effects[CE_ANTIVIRAL] < VIRUS_COMMON && !virus2.len)
		var/infection_prob = 5 - immunity
		var/turf/simulated/T = loc
		if(istype(T))
			infection_prob += T.dirt
		if(T.dirt >= 50)
			if(prob(infection_prob))
				infect_mob_random_greater(src)
		else
			if(prob(infection_prob))
				infect_mob_random_lesser(src)
//[/SIERRA-ADD] VIRUSOLOGY

/mob/living/carbon/proc/virus_immunity()
	var/antibiotic_boost = reagents.get_reagent_amount(/datum/reagent/spaceacillin) / (REAGENTS_OVERDOSE/2)
	return max(immunity/100 * (1+antibiotic_boost), antibiotic_boost)

/mob/living/carbon/proc/immunity_weakness()
	return max(2-virus_immunity(), 0)
