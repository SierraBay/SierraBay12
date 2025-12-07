
/singleton/cooking_recipe/hot_donkpocket
	appliance = COOKING_APPLIANCE_OVEN | COOKING_APPLIANCE_MICROWAVE | COOKING_APPLIANCE_GRILL
	required_reagents = list()
	required_items = list(
		/obj/item/reagent_containers/food/snacks/donkpocket
	)
	result_path = /obj/item/reagent_containers/food/snacks/donkpocket
	cooked_scent = /datum/extension/scent/food/dough

/singleton/cooking_recipe/popcorn
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_MICROWAVE
	required_reagents = list(
		/datum/reagent/sodiumchloride = 3
	)
	required_produce = list(
		"corn" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/popcorn
	cooked_scent = /datum/extension/scent/food/popcorn

/singleton/cooking_recipe/amanitajelly
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_MICROWAVE
	consumed_reagents = list(
		/datum/reagent/water = 10,
		/datum/reagent/toxin/amatoxin = 5
	)
	required_reagents = list(
		/datum/reagent/ethanol/vodka = 5,
	)
	result_path = /obj/item/reagent_containers/food/snacks/amanitajelly

/singleton/cooking_recipe/amanitajelly/CreateResult(obj/container as obj, ...)
		var/obj/item/reagent_containers/food/snacks/amanitajelly/jelly = ..()
		jelly.reagents.add_reagent(/datum/reagent/drugs/psilocybin, 5)
		return jelly

/singleton/cooking_recipe/boiledslimeextract
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_MICROWAVE
	consumed_reagents = list(
		/datum/reagent/water = 10
	)
	required_items = list(
		/obj/item/slime_extract
	)
	result_path = /obj/item/reagent_containers/food/snacks/boiledslimecore

/singleton/cooking_recipe/boiledspiderleg
	appliance = COOKING_APPLIANCE_POT | COOKING_APPLIANCE_MICROWAVE
	consumed_reagents = list(
		/datum/reagent/water = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/spider
	)
	result_path = /obj/item/reagent_containers/food/snacks/spider/cooked
	cooked_scent = /datum/extension/scent/food/meat

/singleton/cooking_recipe/red_sun_special
	appliance = COOKING_APPLIANCE_SKILLET
	required_items = list(
		/obj/item/reagent_containers/food/snacks/sausage,
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	result_path = /obj/item/reagent_containers/food/snacks/red_sun_special
	cooked_scent = /datum/extension/scent/food/meat
