/obj/aura/regenerating/human/mod_tribe
	regen_message = "<span class='warning'>You feel a soothing sensation as your ORGAN mends...</span>"

	var/can_toggle = FALSE

/obj/aura/regenerating/human/mod_tribe/can_toggle()
	return can_toggle

/obj/aura/regenerating/human/mod_tribe/aura_check_life()
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return AURA_FALSE
	if (H.nutrition < 50)
		return AURA_FALSE
	var/obj/machinery/optable/optable = locate() in get_turf(H)
	if (optable?.suppressing && H.sleeping)
		return AURA_FALSE

	..()

/obj/aura/regenerating/human/mod_tribe/can_regenerate_organs()
	return organ_mult

/obj/aura/regenerating/human/mod_tribe/external_regeneration_effect(obj/item/organ/external/O, mob/living/carbon/human/H)
	to_chat(H, SPAN_DANGER("With a shower of fresh blood, a new [O.name] forms."))
	H.visible_message(SPAN_DANGER("With a shower of fresh blood, a length of biomass shoots from [H]'s [O.amputation_point], forming a new [O.name]!"))
	H.adjust_nutrition(-external_nutrition_mult)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in H.vessel.reagent_list
	blood_splatter(H,B,1)
	O.set_dna(H.dna)