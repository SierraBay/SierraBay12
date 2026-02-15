/mob/living/carbon/handle_viruses()
	if(status_flags & GODMODE) //godmode
		return FALSE
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
				if(LAZYLEN(B.virus2))
					for (var/ID in B.virus2)
						var/datum/disease2/disease/V = B.virus2[ID]
						infect_virus2(src,V)

			else if(istype(O,/obj/decal/cleanable/mucus))
				var/obj/decal/cleanable/mucus/M = O
				if(isnull(M.virus2))
					M.virus2 = list()
				if(LAZYLEN(M.virus2))
					for (var/ID in M.virus2)
						var/datum/disease2/disease/V = M.virus2[ID]
						infect_virus2(src,V)

	if(LAZYLEN(virus2))
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
			if(LAZYLEN(common_antibodies))
				V.dead = 1
	if(immunity > 0.2 * immunity_norm)
		if(immunity < immunity_norm)
			immunity = min(immunity + 0.25, immunity_norm)
		else if(immunity > 132)
			immunity = max(immunity - 0.15, immunity_norm)
	if(life_tick % 5 && immunity < 15 && chem_effects[CE_ANTIVIRAL] < VIRUS_COMMON && !LAZYLEN(virus2))
		var/infection_prob = 5 - immunity
		var/turf/simulated/T = get_turf(src)
		if(istype(T,/turf/space))
			return
		if(istype(T))
			infection_prob += T.dirt

		if(prob(infection_prob))
			if(T.dirt >= 50)
				infect_mob_random_greater(src)
			else
				infect_mob_random_lesser(src)
