
/singleton/cooking_recipe/boiledrice
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_MICROWAVE
	consumed_reagents = list(
		/datum/reagent/water = 10
	)
	required_reagents = list(
		/datum/reagent/nutriment/rice = 10
	)
	result_path = /obj/item/reagent_containers/food/snacks/boiledrice
	cooked_scent = /datum/extension/scent/food/rice

/singleton/cooking_recipe/chazuke
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_MICROWAVE
	consumed_reagents = list(
		/datum/reagent/water = 10
	)
	required_reagents = list(
		/datum/reagent/nutriment/rice/chazuke = 10
	)
	result_path = /obj/item/reagent_containers/food/snacks/boiledrice/chazuke
	cooked_scent = /datum/extension/scent/food/rice

/singleton/cooking_recipe/katsucurry
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN
	consumed_reagents = list(
		/datum/reagent/nutriment/flour = 5
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/meat/chicken,
		/obj/item/reagent_containers/food/snacks/boiledrice
	)
	required_produce = list(
		"apple" = 1,
		"carrot" = 1,
		"potato" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/katsucurry
	cooked_scent = /datum/extension/scent/food/rice

/singleton/cooking_recipe/ricepudding
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_MICROWAVE
	required_reagents = list(
		/datum/reagent/drink/milk = 5,
		/datum/reagent/nutriment/rice = 10
	)
	result_path = /obj/item/reagent_containers/food/snacks/ricepudding
	cooked_scent = /datum/extension/scent/food/rice
