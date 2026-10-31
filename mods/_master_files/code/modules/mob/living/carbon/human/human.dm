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
	var/blood_volume_factor = species ? species.blood_volume : SPECIES_BLOOD_DEFAULT
	var/modified_bpm = heart_organ.bpm * clamp(2 - blood_volume_factor / SPECIES_BLOOD_DEFAULT, 0.5, 1.5)
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


/*
	COMBAT_EXTENDED — взрыв контузит, а не отключает (`mods/combat_extended/code/concussion.dm`).
	Кор версия бросает на лёгком и тяжёлом взрыве `Paralyse(10)`; паралич после `..()` возвращается
	к значению до взрыва, а вместо него — контузия, а незащищённого тяжёлый взрыв ещё и сбивает с
	ног. Сила и защита считаются до `..()`: по целой броне и по позе до того, как взрыв отбросит
	носителя.
*/
/mob/living/carbon/human/ex_act(severity)
	if(!ce_concussion_enabled || (status_flags & GODMODE))
		return ..()
	var/strength = ce_get_concussion_strength(severity)
	var/knockdown = ce_is_knocked_down_by_blast(severity)
	var/paralysis_before = paralysis
	. = ..()
	SetParalysis(paralysis_before)
	ce_concuss(strength, knockdown)


/*
	COMBAT_EXTENDED — уколы в броню (`mods/combat_extended/code/injections.dm`). Кор версия смотрит
	только на толстую ткань одежды. Если вещь объявила укол, после неё проверяются движение цели и
	броня зоны. Порт скафандра ведёт под броню, а свой отказ кор версия уже объяснила колющему, — в
	обоих случаях правило мода не действует. Без объявления — жало генокрада, дротик — всё как в Bay.
*/
/mob/living/carbon/human/can_inject(mob/user, target_zone, ignore_thick_clothing)
	var/obj/item/injector = ce_take_injector()
	. = ..()
	if(. != CAN_INJECT || !injector)
		return
	var/refusal = ce_get_injection_refusal(user, target_zone, injector)
	if(refusal)
		to_chat(user, SPAN_WARNING(refusal))
		return 0
