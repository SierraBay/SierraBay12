/datum/reagent/ethanol/affect_blood(mob/living/carbon/M, removed)
	if(halluci)
		M.set_forced_hallucination_theme("psychedelic", 20 SECONDS)
	if(druggy >= 20)
		M.set_forced_hallucination_theme("psychedelic", 15 SECONDS)
	. = ..()

/datum/reagent/drink/nuka_cola/affect_ingest(mob/living/carbon/M, removed)
	M.set_forced_hallucination_theme("machinery", 20 SECONDS)
	. = ..()

/datum/reagent/paracetamol/process_overdose(mob/living/carbon/M)
	M.set_forced_hallucination_theme("body", 10 SECONDS)
	. = ..()

/datum/reagent/opiate/affect_metabolites(mob/living/carbon/affected, dose)
	if(istype(affected))
		var/hallucination_chance = 0
		if(dose >= overdose)
			hallucination_chance += dose / 3

		var/boozed = affected.chem_effects[CE_ALCOHOL]
		if(boozed)
			hallucination_chance *= 1.2
		if(affected.is_fast())
			hallucination_chance *= 1.5

		hallucination_chance = min(hallucination_chance, 100)
		if(hallucination_chance >= 10)
			affected.set_forced_hallucination_theme(pick("body", "aftermath"), 20 SECONDS)
	. = ..()

/datum/reagent/opiate/process_overdose(mob/living/carbon/M)
	if(istype(M))
		M.set_forced_hallucination_theme("body", 25 SECONDS)
	. = ..()

/datum/reagent/deletrathol/process_overdose(mob/living/carbon/M)
	M.set_forced_hallucination_theme("body", 15 SECONDS)
	. = ..()

/datum/reagent/methylphenidate/affect_metabolites(mob/living/carbon/affected, dose)
	if(dose >= overdose)
		affected.set_forced_hallucination_theme("machinery", 20 SECONDS)

	if (IS_METABOLICALLY_INERT(affected))
		return
	if (data && dose <= 1)
		data = 0
		to_chat(affected, SPAN_WARNING("You feel unfocused..."))
	if (!data || world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
		data = world.time
		to_chat(affected, SPAN_NOTICE("Your mind feels focused and undivided."))
		affected.add_chemical_effect(CE_MIND, -1)
	if (dose >= overdose && prob(dose))
		affected.hallucination(60,120)

/datum/reagent/antidexafen/process_overdose(mob/living/carbon/M)
	M.set_forced_hallucination_theme(pick("body", "psychedelic"), 15 SECONDS)
	. = ..()

/datum/reagent/drugs/hextro/affect_blood(mob/living/carbon/M, removed)
	if(!IS_METABOLICALLY_INERT(M))
		M.set_forced_hallucination_theme("psychedelic", 25 SECONDS)
	. = ..()

/datum/reagent/drugs/serotrotium/affect_blood(mob/living/carbon/M, removed)
	if(!IS_METABOLICALLY_INERT(M))
		M.set_forced_hallucination_theme("social", 15 SECONDS)
	. = ..()

/datum/reagent/drugs/cryptobiolin/affect_blood(mob/living/carbon/M, removed)
	if(!IS_METABOLICALLY_INERT(M))
		M.set_forced_hallucination_theme(prob(60) ? "psychedelic" : "machinery", 20 SECONDS)
	. = ..()

/datum/reagent/drugs/mindbreaker/affect_metabolites(mob/living/carbon/M, removed)
	if(!IS_METABOLICALLY_INERT(M))
		M.set_forced_hallucination_theme(pick("predator", "aftermath", "body"), 35 SECONDS)
	. = ..()

/datum/reagent/drugs/psilocybin/affect_metabolites(mob/living/carbon/M, dose)
	if(!IS_METABOLICALLY_INERT(M))
		M.set_forced_hallucination_theme("psychedelic", 30 SECONDS)
	. = ..()

/datum/reagent/drugs/three_eye/affect_blood(mob/living/carbon/M, removed)
	M.set_forced_hallucination_theme("cosmic", 40 SECONDS)
	M.set_forced_hallucination_theme("body", 20 SECONDS)
	. = ..()
