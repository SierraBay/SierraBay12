/// Checks if the given reagent is in bloodstream or metabolized
/mob/living/carbon/proc/has_reagent(reagent_type, amount = null)
	return (bloodstr?.has_reagent(reagent_type, amount) || metabolized?.has_reagent(reagent_type, amount))
