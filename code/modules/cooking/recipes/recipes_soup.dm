
/singleton/cooking_recipe/meatballsoup
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/water = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball
	)
	required_produce = list(
		"carrot" = 1,
		"potato" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/meatballsoup
	cooked_scent = /datum/extension/scent/food/meat

/singleton/cooking_recipe/onionsoup
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/water = 10
	)
	required_produce = list(
		"onion" = 2
	)
	result_path = /obj/item/reagent_containers/food/snacks/onionsoup
	cooked_scent = /datum/extension/scent/food/veg

/singleton/cooking_recipe/vegetablesoup
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/water = 10
	)
	required_produce = list(
		"carrot" = 1,
		"potato" = 1,
		"corn" = 1,
		"eggplant" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/vegetablesoup
	cooked_scent = /datum/extension/scent/food/veg

/singleton/cooking_recipe/nettlesoup
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/water = 10,
		/datum/reagent/nutriment/protein/egg = 3
	)
	required_produce = list(
		"nettle" = 1,
		"potato" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/nettlesoup
	cooked_scent = /datum/extension/scent/food/veg

/singleton/cooking_recipe/wishsoup
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/water = 10
	)
	result_path = /obj/item/reagent_containers/food/snacks/wishsoup

/singleton/cooking_recipe/hotchili
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_items = list(
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/cutlet
	)
	required_produce = list(
		"chili" = 1,
		"tomato" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/hotchili
	cooked_scent = /datum/extension/scent/food/spicy

/singleton/cooking_recipe/coldchili
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_items = list(
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/cutlet
	)
	required_produce = list(
		"icechili" = 1,
		"tomato" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/coldchili
	cooked_scent = /datum/extension/scent/food/spicy

/singleton/cooking_recipe/tomatosoup
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/water = 10
	)
	required_produce = list(
		"tomato" = 2
	)
	result_path = /obj/item/reagent_containers/food/snacks/tomatosoup
	cooked_scent = /datum/extension/scent/food/veg

/singleton/cooking_recipe/stew
	appliance = COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/water = 5
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/meat
	)
	required_produce = list(
		"potato" = 1,
		"tomato" = 1,
		"carrot" = 1,
		"eggplant" = 1,
		"mushroom" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/stew
	cooked_scent = /datum/extension/scent/food/stew

/singleton/cooking_recipe/milosoup
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/water = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu
	)
	result_path = /obj/item/reagent_containers/food/snacks/milosoup
	cooked_scent = /datum/extension/scent/food/tofu

/singleton/cooking_recipe/stewedsoymeat
	appliance = COOKING_APPLIANCE_POT
	required_items = list(
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/soydope
	)
	required_produce = list(
		"carrot" = 1,
		"tomato" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/stewedsoymeat
	cooked_scent = /datum/extension/scent/food/tofu

/singleton/cooking_recipe/bloodsoup
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/blood = 30
	)
	result_path = /obj/item/reagent_containers/food/snacks/bloodsoup
	cooked_scent = /datum/extension/scent/food/blood

/singleton/cooking_recipe/slimesoup
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/water = 10,
		/datum/reagent/slimejelly = 5
	)
	result_path = /obj/item/reagent_containers/food/snacks/slimesoup

/singleton/cooking_recipe/mysterysoup
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/water = 10,
		/datum/reagent/nutriment/protein/egg = 3
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/badrecipe,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	result_path = /obj/item/reagent_containers/food/snacks/mysterysoup
	cooked_scent = /datum/extension/scent/food/burning

/singleton/cooking_recipe/mushroomsoup
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/drink/milk = 10
	)
	required_produce = list(
		"mushroom" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/mushroomsoup
	cooked_scent = /datum/extension/scent/food/veg

/singleton/cooking_recipe/beetsoup
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/water = 10
	)
	required_produce = list(
		"whitebeet" = 1,
		"cabbage" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/beetsoup
	cooked_scent = /datum/extension/scent/food/veg

/singleton/cooking_recipe/clam_chowder
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/drink/milk/cream = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/shellfish/clam
	)
	required_produce = list(
		"potato" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/clam_chowder
	cooked_scent = /datum/extension/scent/food/seafood

/singleton/cooking_recipe/bisque
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	required_reagents = list(
		/datum/reagent/drink/milk/cream = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/shellfish/crab,
		/obj/item/reagent_containers/food/snacks/shellfish/crab
	)
	result_path = /obj/item/reagent_containers/food/snacks/bisque
	cooked_scent = /datum/extension/scent/food/seafood

/singleton/cooking_recipe/gumbo
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT
	consumed_reagents = list(
		/datum/reagent/water = 10
	)
	required_reagents = list(
		/datum/reagent/nutriment/rice = 5
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/sausage,
		/obj/item/reagent_containers/food/snacks/shellfish/shrimp,
		/obj/item/reagent_containers/food/snacks/shellfish/shrimp
	)
	required_produce = list(
		"chili" = 1,
		"onion" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/gumbo
	cooked_scent = /datum/extension/scent/food/seafood
