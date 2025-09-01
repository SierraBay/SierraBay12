
/singleton/cooking_recipe/boiledspagetti
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN
	consumed_reagents = list(
		/datum/reagent/water = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/spagetti
	)
	result_path = /obj/item/reagent_containers/food/snacks/boiledspagetti
	cooked_scent = /datum/extension/scent/food/pasta

/singleton/cooking_recipe/pastatomato
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN
	consumed_reagents = list(
		/datum/reagent/water = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/spagetti
	)
	required_produce = list(
		"tomato" = 2
	)
	result_path = /obj/item/reagent_containers/food/snacks/pastatomato
	cooked_scent = /datum/extension/scent/food/pasta

/singleton/cooking_recipe/pastatomatoboiled
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_MICROWAVE
	required_items = list(
		/obj/item/reagent_containers/food/snacks/boiledspagetti
	)
	required_produce = list(
		"tomato" = 2
	)
	result_path = /obj/item/reagent_containers/food/snacks/pastatomato

/singleton/cooking_recipe/meatballspagetti
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN
	consumed_reagents = list(
		/datum/reagent/water = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/spagetti,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball
	)
	result_path = /obj/item/reagent_containers/food/snacks/meatballspagetti
	cooked_scent = /datum/extension/scent/food/pasta

/singleton/cooking_recipe/meatballspagettiboiled
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_MICROWAVE
	consumed_reagents = list(
		/datum/reagent/water = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/boiledspagetti,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball
	)
	result_path = /obj/item/reagent_containers/food/snacks/meatballspagetti
	cooked_scent = /datum/extension/scent/food/pasta

/singleton/cooking_recipe/meatballspagettiboiled
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN
	required_items = list(
		/obj/item/reagent_containers/food/snacks/boiledspagetti,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball
	)
	result_path = /obj/item/reagent_containers/food/snacks/meatballspagetti
	cooked_scent = /datum/extension/scent/food/pasta

/singleton/cooking_recipe/spesslaw
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN
	consumed_reagents = list(
		/datum/reagent/water = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/spagetti,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball
	)
	result_path = /obj/item/reagent_containers/food/snacks/spesslaw
	cooked_scent = /datum/extension/scent/food/pasta

/singleton/cooking_recipe/spesslawboiled
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_MICROWAVE
	required_items = list(
		/obj/item/reagent_containers/food/snacks/boiledspagetti,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball
	)
	result_path = /obj/item/reagent_containers/food/snacks/spesslaw
	cooked_scent = /datum/extension/scent/food/pasta

/singleton/cooking_recipe/nanopasta
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN
	consumed_reagents = list(
		/datum/reagent/water = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/spagetti,
		/obj/item/stack/nanopaste
	)
	result_path = /obj/item/reagent_containers/food/snacks/nanopasta
	cooked_scent = /datum/extension/scent/food/pasta

/singleton/cooking_recipe/nanopastaboiled
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_MICROWAVE
	required_items = list(
		/obj/item/reagent_containers/food/snacks/boiledspagetti,
		/obj/item/stack/nanopaste
	)
	result_path = /obj/item/reagent_containers/food/snacks/nanopasta
	cooked_scent = /datum/extension/scent/food/pasta
