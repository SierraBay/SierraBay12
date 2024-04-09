/datum/reagent/toxin/bromide/affect_touch(mob/living/carbon/M, alien, removed)
	if(!(alien in ALL_ASCENT_SPECIES - SPECIES_NABBER))
		. = ..()

/datum/reagent/toxin/bromide/affect_blood(mob/living/carbon/M, alien, removed)
	if(!(alien in ALL_ASCENT_SPECIES - SPECIES_NABBER))
		M.add_chemical_effect(CE_OXYGENATED, 1)
	else
		..()

/datum/reagent/toxin/bromide/affect_ingest(mob/living/carbon/M, alien, removed)
	if(!(alien in ALL_ASCENT_SPECIES - SPECIES_NABBER))
		. = ..()

/datum/reagent/toxin/methyl_bromide/affect_touch(mob/living/carbon/M, alien, removed)
	. = (!(alien in ALL_ASCENT_SPECIES) && ..())

/datum/reagent/toxin/methyl_bromide/affect_ingest(mob/living/carbon/M, alien, removed)
	. = (!(alien in ALL_ASCENT_SPECIES) && ..())
