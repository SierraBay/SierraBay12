/* Unathi reagents reactions */
/datum/chemical_reaction/paashe
	name = "Paashe Meish Sunn"
	result = /datum/reagent/paashe
	required_reagents = list(/datum/reagent/toxin/yeosvenom = 1, /datum/reagent/ethanol = 1, /datum/reagent/lithium = 1, /datum/reagent/space_cleaner = 2)
	result_amount = 5

/datum/chemical_reaction/arhishaap
	name = "Arhishaap"
	result = /datum/reagent/arhishaap
	required_reagents = list(/datum/reagent/toxin/yeosvenom = 1, /datum/reagent/diethylamine = 2, /datum/reagent/radium = 1)
	result_amount = 4

/datum/chemical_reaction/oxycodonealt
	name = "Oxycodone Alt"
	result = /datum/reagent/tramadol/oxycodone
	required_reagents = list(/datum/reagent/ethanol = 1, /datum/reagent/paashe = 1)
	catalysts = list(/datum/reagent/toxin/phoron = 5)
	result_amount = 1
