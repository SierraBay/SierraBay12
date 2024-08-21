/* Unathi reagents reactions */
/singleton/reaction/paashe
	name = "Paashe Meish Sunn"
	result = /singleton/reagent/paashe
	required_reagents = list(/singleton/reagent/toxin/yeosvenom = 1, /singleton/reagent/ethanol = 1, /singleton/reagent/lithium = 1, /singleton/reagent/space_cleaner = 2)
	result_amount = 5

/singleton/reaction/arhishaap
	name = "Arhishaap"
	result = /singleton/reagent/arhishaap
	required_reagents = list(/singleton/reagent/toxin/yeosvenom = 1, /singleton/reagent/diethylamine = 2, /singleton/reagent/radium = 1)
	result_amount = 4

/singleton/reaction/oxycodonealt
	name = "Oxycodone Alt"
	result = /singleton/reagent/tramadol/oxycodone
	required_reagents = list(/singleton/reagent/ethanol = 1, /singleton/reagent/paashe = 1)
	catalysts = list(/singleton/reagent/toxin/phoron = 5)
	result_amount = 1
