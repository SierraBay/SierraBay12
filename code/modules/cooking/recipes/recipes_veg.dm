
/singleton/cooking_recipe/mashedpotato
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_MICROWAVE
	required_reagents = list(
		/datum/reagent/drink/milk = 5,
		/datum/reagent/sodiumchloride = 1,
		/datum/reagent/blackpepper = 1
	)
	required_produce = list(
		"potato" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/mashedpotato
	cooked_scent = /datum/extension/scent/food/veg
