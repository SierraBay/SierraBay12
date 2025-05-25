
/mob/living/carbon/virus_immunity()
	if(reagents)
		var/antibiotic_boost = reagents.get_reagent_amount(/datum/reagent/spaceacillin) / (REAGENTS_OVERDOSE/2)
		return max(immunity/100 * (1+antibiotic_boost), antibiotic_boost)
