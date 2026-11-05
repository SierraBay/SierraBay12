/datum/reagent/metorapan
	name = "Metorapan"
	description = "Metorapan is an advanced medication used to treat physical trauma, working almost twice as fast as bicaridine, but coming with dangerous side effects if combined with its predecessor and requiring strict dosages."
	taste_description = "metallic bitterness"
	taste_mult = 3
	reagent_state = LIQUID
	color = "#ff4840"
	overdose = REAGENTS_OVERDOSE / 2
	scannable = 1
	flags = IGNORE_MOB_SIZE
	value = 6.8

/datum/reagent/metorapan/affect_blood(mob/living/carbon/M, removed)
	if(M.has_reagent(/datum/reagent/bicaridine))
		if (volume < overdose)
			process_overdose(M)
		return
	if (volume >= overdose)
		return
	if (!IS_METABOLICALLY_INERT(M))
		M.heal_organ_damage(10 * removed, 0)

/datum/reagent/metorapan/process_overdose(mob/living/carbon/M)
	..()
	if (!ishuman(M))
		return
	M.add_chemical_effect(CE_BLOCKAGE, (15 + M.metabolized.get_reagent_amount(type) - overdose)/100)
	if (prob(70))
		M.take_organ_damage(4 * metabolism, 0, ORGAN_DAMAGE_FLESH_ONLY)
	if(M.has_reagent(/datum/reagent/bicaridine))
		return
	var/mob/living/carbon/human/H = M
	for (var/obj/item/organ/external/E in H.organs)
		if (E.status & ORGAN_TENDON_CUT && prob(2))
			E.status &= ~ORGAN_TENDON_CUT


/datum/reagent/cortolin
	name = "Cortolin"
	description = "Cortolin is an advanced organ-regenerative medication used in treating cardiac damage."
	reagent_state = LIQUID
	color = "#008000"
	metabolism = REM
	overdose = REAGENTS_OVERDOSE / 3
	scannable = 1
	flags = IGNORE_MOB_SIZE
	value = 6

/datum/reagent/cortolin/affect_blood(mob/living/carbon/M, removed)
	if (!ishuman(M))
		return
	var/mob/living/carbon/human/H = M

	var/obj/item/organ/internal/heart/heart = H.internal_organs_by_name[BP_HEART]
	if (heart && !BP_IS_ROBOTIC(heart))
		heart.damage = max(heart.damage - 2 * removed, 0)
	H.mod_confused(1)
