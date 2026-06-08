// CARDIAC_OVERHAUL overrides for human mob
#define PULSE_NUMBER_NONE 0
#define PULSE_NUMBER_SLOW 50
#define PULSE_NUMBER_NORM 75
#define PULSE_NUMBER_FAST 105
#define PULSE_NUMBER_2FAST 140
#define PULSE_NUMBER_THREADY PULSE_MAX_BPM

/mob/living/carbon/human/get_pulse_as_number()
	var/obj/item/organ/internal/heart/heart_organ = internal_organs_by_name[BP_HEART]

	if(!heart_organ)
		return PULSE_NUMBER_NONE

	// Use the heart's pre-calculated BPM from the cardiac rhythm system.
	// The heart updates bpm each tick via update_rhythm(), so we use it directly.
	if(heart_organ.bpm <= 0)
		return PULSE_NUMBER_NONE
	if(heart_organ.bpm >= PULSE_MAX_BPM)
		return PULSE_NUMBER_THREADY

	// Apply species blood volume modifier and slight randomization for realism.
	var/modified_bpm = heart_organ.bpm * (2 - species.blood_volume / SPECIES_BLOOD_DEFAULT)
	modified_bpm += modified_bpm * rand(-10, 10) / 100
	return clamp(round(modified_bpm), 0, PULSE_MAX_BPM)

#undef PULSE_NUMBER_NONE
#undef PULSE_NUMBER_SLOW
#undef PULSE_NUMBER_NORM
#undef PULSE_NUMBER_FAST
#undef PULSE_NUMBER_2FAST
#undef PULSE_NUMBER_THREADY

/mob/living/carbon/human/get_pulse(method)	//method 0 is for hands, 1 is for machines, more accurate
	var/obj/item/organ/internal/heart/heart_organ = internal_organs_by_name[BP_HEART]
	if(!heart_organ)
		// No heart, no pulse
		return "0"
	if(heart_organ.open && !method)
		// Heart is a open type (?) and cannot be checked unless it's a machine
		return "muddled and unclear; you can't seem to find a vein"

	var/bpm = get_pulse_as_number()
	if(bpm <= 0)
		return method ? "0" : "no pulse"
	if(bpm >= PULSE_MAX_BPM)
		return method ? ">[PULSE_MAX_BPM]" : "extremely weak and fast, patient's artery feels like a thread"

	return "[method ? bpm : bpm + rand(-10, 10)]"

/mob/living/carbon/human/resuscitate()
	. = ..()
	if(.)
		var/obj/item/organ/internal/heart/heart = internal_organs_by_name[BP_HEART]
		if(istype(heart))
			heart.infarct_progress = 0
