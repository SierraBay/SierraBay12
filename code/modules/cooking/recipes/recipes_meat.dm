
/singleton/cooking_recipe/plainsteak
	appliance = COOKING_APPLIANCE_SKILLET | COOKING_APPLIANCE_MICROWAVE | COOKING_APPLIANCE_GRILL
	required_items = list(
		/obj/item/reagent_containers/food/snacks/meat
	)
	result_path = /obj/item/reagent_containers/food/snacks/plainsteak
	cooked_scent = /datum/extension/scent/food/meat

/singleton/cooking_recipe/seasonedsteak
	appliance = COOKING_APPLIANCE_SKILLET | COOKING_APPLIANCE_GRILL
	required_reagents = list(
		/datum/reagent/sodiumchloride = 1,
		/datum/reagent/blackpepper = 1
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/meat
	)
	result_path = /obj/item/reagent_containers/food/snacks/plainsteak
	cooked_scent = /datum/extension/scent/food/meat

/singleton/cooking_recipe/loadedsteak
	appliance = COOKING_APPLIANCE_SKILLET
	required_reagents = list(
		/datum/reagent/nutriment/garlicsauce = 5
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/meat
	)
	required_produce = list(
		"onion" = 1,
		"mushroom" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/loadedsteak
	cooked_scent = /datum/extension/scent/food/meat

/singleton/cooking_recipe/syntisteak
	appliance = COOKING_APPLIANCE_SKILLET | COOKING_APPLIANCE_GRILL
	required_items = list(
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh
	)
	result_path = /obj/item/reagent_containers/food/snacks/plainsteak/synthetic
	cooked_scent = /datum/extension/scent/food/meat

/singleton/cooking_recipe/seasonedsyntisteak
	appliance = COOKING_APPLIANCE_SKILLET | COOKING_APPLIANCE_GRILL
	required_reagents = list(
		/datum/reagent/sodiumchloride = 1,
		/datum/reagent/blackpepper = 1
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh
	)
	result_path = /obj/item/reagent_containers/food/snacks/plainsteak/synthetic
	cooked_scent = /datum/extension/scent/food/meat

/singleton/cooking_recipe/sausage
	appliance = COOKING_APPLIANCE_SKILLET | COOKING_APPLIANCE_MICROWAVE | COOKING_APPLIANCE_GRILL
	required_items = list(
		/obj/item/reagent_containers/food/snacks/rawmeatball,
		/obj/item/reagent_containers/food/snacks/rawcutlet
	)
	result_path = /obj/item/reagent_containers/food/snacks/sausage
	cooked_scent = /datum/extension/scent/food/meat

/singleton/cooking_recipe/fatsausage
	appliance = COOKING_APPLIANCE_SKILLET | COOKING_APPLIANCE_MICROWAVE | COOKING_APPLIANCE_GRILL
	required_reagents = list(
		/datum/reagent/blackpepper = 2
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/rawmeatball,
		/obj/item/reagent_containers/food/snacks/rawcutlet
	)
	result_path = /obj/item/reagent_containers/food/snacks/fatsausage
	cooked_scent = /datum/extension/scent/food/meat

/singleton/cooking_recipe/taco
	appliance = COOKING_APPLIANCE_MIX | COOKING_APPLIANCE_SKILLET
	required_items = list(
		/obj/item/reagent_containers/food/snacks/doughslice,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	result_path = /obj/item/reagent_containers/food/snacks/taco
	cooked_scent = /datum/extension/scent/food/meat

/singleton/cooking_recipe/meatball
	appliance = COOKING_APPLIANCE_SKILLET | COOKING_APPLIANCE_FRYER | COOKING_APPLIANCE_OVEN | COOKING_APPLIANCE_MICROWAVE | COOKING_APPLIANCE_GRILL
	required_items = list(
		/obj/item/reagent_containers/food/snacks/rawmeatball
	)
	result_path = /obj/item/reagent_containers/food/snacks/meatball
	cooked_scent = /datum/extension/scent/food/meat

/singleton/cooking_recipe/cutlet
	appliance = COOKING_APPLIANCE_SKILLET | COOKING_APPLIANCE_FRYER | COOKING_APPLIANCE_OVEN | COOKING_APPLIANCE_MICROWAVE | COOKING_APPLIANCE_GRILL
	required_items = list(
		/obj/item/reagent_containers/food/snacks/rawcutlet
	)
	result_path = /obj/item/reagent_containers/food/snacks/cutlet
	cooked_scent = /datum/extension/scent/food/meat

/singleton/cooking_recipe/bacon
	appliance = COOKING_APPLIANCE_SKILLET | COOKING_APPLIANCE_FRYER | COOKING_APPLIANCE_OVEN | COOKING_APPLIANCE_MICROWAVE | COOKING_APPLIANCE_GRILL
	required_items = list(
		/obj/item/reagent_containers/food/snacks/rawbacon
	)
	result_path = /obj/item/reagent_containers/food/snacks/bacon
	cooked_scent = /datum/extension/scent/food/bacon

/singleton/cooking_recipe/bugmeat_cutlet
	appliance = COOKING_APPLIANCE_SKILLET | COOKING_APPLIANCE_FRYER | COOKING_APPLIANCE_OVEN | COOKING_APPLIANCE_MICROWAVE | COOKING_APPLIANCE_GRILL
	required_items = list(
		/obj/item/reagent_containers/food/snacks/rawcutlet/bugmeat
	)
	result_path = /obj/item/reagent_containers/food/snacks/cutlet/bugmeat
	cooked_scent = /datum/extension/scent/food/meat


/singleton/cooking_recipe/bugmeat_bacon
	appliance = COOKING_APPLIANCE_SKILLET | COOKING_APPLIANCE_FRYER | COOKING_APPLIANCE_OVEN | COOKING_APPLIANCE_MICROWAVE | COOKING_APPLIANCE_GRILL
	required_items = list(
		/obj/item/reagent_containers/food/snacks/rawbacon/bugmeat
	)
	result_path = /obj/item/reagent_containers/food/snacks/bacon/bugmeat
	cooked_scent = /datum/extension/scent/food/bacon
