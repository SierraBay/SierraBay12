/datum/reagent/toxin/yeosvenom
	name = "Esh Hashaar Haashane"
	description = "A non-lethal toxin produced by Yeosa'Unathi"
	taste_description = "absolutely vile"
	color = "#91d895"
	target_organ = BP_LIVER
	strength = 1

/datum/reagent/toxin/yeosvenom/affect_blood(mob/living/carbon/M, removed)
	if(M.is_species(SPECIES_YEOSA))
		return // Yeosa are immune to their own venom

	if(prob(volume*10))
		M.set_confused(10)
	..()

//Medicine
/datum/reagent/paashe
	name = "Paashe Meish Sunn"
	description = "An effective natural painkiller, produced from Yeosa'Unathi innate venom. Has similar effect to a mixture of Tramadol and Synaptizine, but doesn't feature any significant side effects."
	taste_description = "way too much sweetness"
	reagent_state = LIQUID
	color = "#aea0c9"
	var/weakness_modifier = 30
	scannable = 1
	metabolism = 0.05
	ingest_met = 0.02
	flags = IGNORE_MOB_SIZE
	value = 3.1
	var/pain_power = 80 //magnitide of painkilling effect
	var/effective_dose = 0.5 //how many units it need to process to reach max power

/datum/reagent/paashe/affect_blood(mob/living/carbon/M, removed)
	var/effectiveness = 1
	if(M.chem_doses[type] < effective_dose) //some ease-in ease-out for the effect
		effectiveness = M.chem_doses[type]/effective_dose
	else if(volume < effective_dose)
		effectiveness = volume/effective_dose
	M.add_chemical_effect(CE_PAINKILLER, pain_power * effectiveness)
	if(M.chem_doses[type] > 0.5 * weakness_modifier)
		M.add_chemical_effect(CE_SLOWDOWN, 1)
		if(prob(1))
			M.slurring = max(M.slurring, 10)
	if(M.chem_doses[type] > 0.75 * weakness_modifier)
		M.add_chemical_effect(CE_SLOWDOWN, 1)
		if(prob(5))
			M.slurring = max(M.slurring, 20)
	if(M.chem_doses[type] > weakness_modifier)
		M.add_chemical_effect(CE_SLOWDOWN, 1)
		M.slurring = max(M.slurring, 30)
		if(prob(1))
			M.Weaken(2)
			M.drowsyness = max(M.drowsyness, 5)

	if (IS_METABOLICALLY_INERT(M))
		return
	M.drowsyness = max(M.drowsyness - 2, 0)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	holder.remove_reagent(/datum/reagent/drugs/mindbreaker, 2)
	M.adjust_hallucination(-5)
	M.add_chemical_effect(CE_MIND, 1)
	M.add_chemical_effect(CE_STIMULANT, 5)

/datum/reagent/arhishaap
	name = "Arhishaap"
	description = "An advanced Yeosa'Unathi anti-toxin, significantly more effective than synthetic alternatives."
	taste_description = "way too much sweetness"
	reagent_state = LIQUID
	color = "#49bc4b"
	scannable = 1
	flags = IGNORE_MOB_SIZE
	value = 2.1
	var/remove_generic = 1
	var/list/remove_toxins = list(
		/datum/reagent/toxin/zombiepowder
	)

/datum/reagent/arhishaap/affect_blood(mob/living/carbon/M, removed)
	M.radiation = max(M.radiation - 30 * removed, 0)

	if(remove_generic)
		M.drowsyness = max(0, M.drowsyness - 10 * removed)
		M.adjust_hallucination(-14 * removed)
		M.add_up_to_chemical_effect(CE_ANTITOX, 1)

	var/removing = (8 * removed)
	var/datum/reagents/ingested = M.get_ingested_reagents()
	for(var/datum/reagent/R in ingested.reagent_list)
		if((remove_generic && istype(R, /datum/reagent/toxin)) || (R.type in remove_toxins))
			ingested.remove_reagent(R.type, removing)
			return
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if((remove_generic && istype(R, /datum/reagent/toxin)) || (R.type in remove_toxins))
			M.reagents.remove_reagent(R.type, removing)
			return
