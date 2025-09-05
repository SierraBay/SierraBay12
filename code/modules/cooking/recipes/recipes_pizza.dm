
/singleton/cooking_recipe/pizzamargherita
	appliance = COOKING_APPLIANCE_OVEN
	required_items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	required_produce = list(
		"tomato" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/pizza/margherita
	cooked_scent = /datum/extension/scent/food/pizza

/singleton/cooking_recipe/meatpizza
	appliance = COOKING_APPLIANCE_OVEN
	required_items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	required_produce = list(
		"tomato" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza
	cooked_scent = /datum/extension/scent/food/pizza

/singleton/cooking_recipe/mushroompizza
	appliance = COOKING_APPLIANCE_OVEN
	required_items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	required_produce = list(
		"mushroom" = 5,
		"tomato" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/pizza/mushroompizza
	cooked_scent = /datum/extension/scent/food/pizza

/singleton/cooking_recipe/vegetablepizza
	appliance = COOKING_APPLIANCE_OVEN
	required_items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	required_produce = list(
		"eggplant" = 1,
		"carrot" = 1,
		"corn" = 1,
		"tomato" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza
	cooked_scent = /datum/extension/scent/food/pizza

/singleton/cooking_recipe/fruitpizza
	appliance = COOKING_APPLIANCE_OVEN
	required_items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	)
	required_reagents = list(
		/datum/reagent/drink/milk/cream = 10,
		/datum/reagent/sugar = 10
	)
	required_produce = list(
		"pineapple" = 1,
		"banana" = 1,
		"blueberries" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/pizza/fruitpizza
	cooked_scent = /datum/extension/scent/food/pizza
