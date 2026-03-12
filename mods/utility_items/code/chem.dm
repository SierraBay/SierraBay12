/datum/reagent/drugs/red_nightshade
	name = "Red Nightshade"
	description = "An illegal combat performance enhancer originating from the criminal syndicates of Mars. It floods the brain with violence and rage, driving the user into a feral berserk state."
	taste_description = "metallic bitterness"
	reagent_state = LIQUID
	color = "#af111c"
	metabolism = REM * 0.3
	overdose = 20
	value = 3
	should_admin_log = TRUE
	high_message_list = list(
		"You feel an overwhelming urge to fight.",
		"Pain recedes as a red haze fills your vision.",
		"Your heartbeat hammers in your ears as adrenaline surges.",
		"Everything around you looks like a target."
	)
	sober_message_list = list(
		"The rage ebbs, leaving you exhausted.",
		"Your whole body aches as the stimulant wears off."
	)

/datum/reagent/drugs/red_nightshade/affect_blood(mob/living/carbon/M, removed)
	if (IS_METABOLICALLY_INERT(M))
		return

	if(prob(10))
		M.adjustBrainLoss(rand(3, 6) * removed)
	M.make_jittery(5)

	M.add_chemical_effect(CE_PAINKILLER, 80)
	M.add_chemical_effect(CE_STIMULANT, 3)
	M.add_chemical_effect(CE_SPEEDBOOST, 1)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.add_client_color(/datum/client_color/berserk)

		if(H.bodytemperature < 151)
			var/fixed_fracture = FALSE
			for(var/obj/item/organ/external/E in H.bad_external_organs)
				if(E.status & ORGAN_BROKEN && E.damage < E.min_broken_damage)
					if(E.mend_fracture())
						fixed_fracture = TRUE
						to_chat(H, SPAN_WARNING("A terrible pressure builds in your [E.name] before something snaps back into place."))
						break

			if(fixed_fracture)
				H.remove_blood(rand(30, 60))
			else
				H.remove_blood(rand(15, 30))

	..()

/datum/reagent/drugs/red_nightshade/on_leaving_metabolism(mob/parent, metabolism_class)
	if(ismob(parent))
		var/mob/M = parent
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.remove_client_color(/datum/client_color/berserk)

/datum/reagent/drugs/red_nightshade/process_overdose(mob/living/carbon/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/heart/O = H.internal_organs_by_name[BP_HEART]
		if(O)
			O.take_internal_damage(1)
			if(prob(15))
				to_chat(H, SPAN_WARNING("Your heart throbs painfully against the strain of the drug."))

/datum/reagent/drugs/snowflake
	name = "Snowflake"
	description = "A recreational stimulant refined from frostoil, found in certain plants."
	taste_description = "cold metal"
	reagent_state = LIQUID
	color = "#b7f2ff"
	metabolism = REM * 0.25
	overdose = 15
	value = 2.2
	should_admin_log = TRUE
	high_message_list = list(
		"A pleasant chill runs through your body.",
		"You feel strangely euphoric.",
		"Your skin prickles as the cold sets in.",
		"You feel comfortably numb."
	)
	sober_message_list = list(
		"The pleasant chill fades, leaving you shivering.",
		"Your mood drops as the euphoria wears off."
	)

/datum/reagent/drugs/snowflake/affect_blood(mob/living/carbon/M, removed)
	if (IS_METABOLICALLY_INERT(M))
		return

	M.add_chemical_effect(CE_PAINKILLER, 60)

	M.bodytemperature = max(M.bodytemperature - 25 * TEMPERATURE_DAMAGE_COEFFICIENT, 0)

	if(prob(20))
		M.emote("shiver")
	M.add_chemical_effect(CE_MIND, -1)

	..()

/datum/reagent/drugs/snowflake/process_overdose(mob/living/carbon/M)
	..()
	if (IS_METABOLICALLY_INERT(M))
		return
	M.adjustBrainLoss(1)

/datum/reagent/drugs/krok_juice
	name = "Krok Juice"
	description = "An ancient krokodil, known for causing prosthetic malfunctions. It is illegal in most jurisdictions."
	taste_description = "citrus gasoline"
	reagent_state = LIQUID
	color = "#ff8b3d"
	metabolism = REM
	overdose = 15
	value = 2.6
	should_admin_log = TRUE
	high_message_list = list(
		"Warm pleasure crawls up your spine.",
		"You feel oddly invigorated.",
		"Your body feels comfortably numb.",
		"Your thoughts slip into a hazy calm."
	)
	sober_message_list = list(
		"The pleasant haze fades, leaving you irritable.",
		"Your muscles feel tense again."
	)

/datum/reagent/drugs/krok_juice/affect_blood(mob/living/carbon/M, removed)
	if (IS_METABOLICALLY_INERT(M))
		return

	var/has_prosthetic = FALSE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/obj/item/organ/external/E in H.organs)
			if(E && BP_IS_ROBOTIC(E))
				has_prosthetic = TRUE
				break

	if(!has_prosthetic)
		M.add_chemical_effect(CE_PAINKILLER, 80)
	else
		M.add_chemical_effect(CE_PAINKILLER, 40)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(prob(25))
				var/list/robotic_limbs = list()
				for(var/obj/item/organ/external/E in H.organs)
					if(E && BP_IS_ROBOTIC(E))
						robotic_limbs += E
				if(length(robotic_limbs))
					var/obj/item/organ/external/limb = pick(robotic_limbs)
					to_chat(H, SPAN_NOTICE("Your [limb.name] buzzes warmly as its servos briefly misalign."))
					if(prob(40))
						H.grasp_damage_disarm(limb)
					if(prob(25))
						H.stance_damage_prone(limb)

			if(prob(15))
				M.hallucination(30, 60)

	..()

/datum/reagent/opiate/heroin
	name = "Heroin"
	description = "An extremely potent but dangerous and addictive opiate refined from other opiates."
	taste_description = "bitter warmth"
	color = "#b9b9ff"
	metabolism = REM * 0.25
	overdose = 5
	value = 4.2
	should_admin_log = TRUE

/datum/reagent/opiate/heroin/affect_metabolites(mob/living/carbon/affected, dose)
	..()
	if (!istype(affected) || IS_METABOLICALLY_INERT(affected))
		return

	affected.add_chemical_effect(CE_PAINKILLER, 20 * dose)
	if(prob(10))
		to_chat(affected, SPAN_NOTICE("A soothing warmth spreads through your body."))

	if(dose >= 1.5)
		affected.eye_blurry = max(affected.eye_blurry, 5)
	if(dose >= 2.5 && prob(40))
		affected.set_confused(10)

	if(affected.chem_effects[CE_ALCOHOL])
		affected.druggy = max(affected.druggy, 6)
		affected.add_chemical_effect(CE_BREATHLOSS, 0.2)

/singleton/reaction/red_nightshade
	name = "Red Nightshade"
	result = /datum/reagent/drugs/red_nightshade
	required_reagents = list(
		/datum/reagent/toxin/stimm = 1,
		/datum/reagent/synaptizine = 1,
		/datum/reagent/toxin/phoron = 0.1
	)
	result_amount = 1

/singleton/reaction/snowflake
	name = "Snowflake"
	result = /datum/reagent/drugs/snowflake
	required_reagents = list(
		/datum/reagent/frostoil = 1,
		/datum/reagent/fuel = 1,
		/datum/reagent/sulfur = 1
	)
	result_amount = 3

/singleton/reaction/krok_juice
	name = "Krok Juice"
	result = /datum/reagent/drugs/krok_juice
	required_reagents = list(
		/datum/reagent/iron = 1,
		/datum/reagent/fuel = 1,
		/datum/reagent/drink/juice/orange = 4
	)
	result_amount = 4

/singleton/reaction/heroin_from_oxycodone
	name = "Heroin"
	result = /datum/reagent/opiate/heroin
	required_reagents = list(
		/datum/reagent/opiate/oxycodone = 2,
		/datum/reagent/acetone = 2
	)
	result_amount = 1

/singleton/reaction/heroin_from_tramadol
	name = "Heroin (crude)"
	result = /datum/reagent/opiate/heroin
	required_reagents = list(
		/datum/reagent/opiate/tramadol = 3,
		/datum/reagent/acetone = 2
	)
	result_amount = 1
