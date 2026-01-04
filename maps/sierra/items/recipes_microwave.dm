/singleton/cooking_recipe/rye_bread
	appliance = COOKING_APPLIANCE_OVEN | COOKING_APPLIANCE_MICROWAVE
	required_reagents = list(/datum/reagent/blackpepper = 5
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/egg
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/ryebread

/singleton/cooking_recipe/pelmeni
	appliance = COOKING_APPLIANCE_MIX
	required_items = list(
		/obj/item/reagent_containers/food/snacks/doughslice,
		/obj/item/reagent_containers/food/snacks/doughslice,
		/obj/item/reagent_containers/food/snacks/rawmeatball
	)
	result_path = /obj/item/reagent_containers/food/snacks/dumpling

/singleton/cooking_recipe/pelmeniboiled
	appliance = COOKING_APPLIANCE_SAUCEPAN | COOKING_APPLIANCE_POT | COOKING_APPLIANCE_MICROWAVE
	required_reagents = list(/datum/reagent/water = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/dumpling,
		/obj/item/reagent_containers/food/snacks/dumpling,
		/obj/item/reagent_containers/food/snacks/dumpling,
		/obj/item/reagent_containers/food/snacks/dumpling,
		/obj/item/reagent_containers/food/snacks/dumpling
	)
	result_path = /obj/item/reagent_containers/food/snacks/boileddumplings
