/datum/reagent/bicaridine/affect_blood(mob/living/carbon/M, removed)
	// Metorapan doesn't work with bicaridine
	if(M.has_reagent(/datum/reagent/metorapan))
		return
	return ..()
