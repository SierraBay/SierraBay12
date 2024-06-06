/datum/microwave_recipe/rye_bread
	required_reagents = list(/datum/reagent/blackpepper = 5
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/egg
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/ryebread

/datum/microwave_recipe/pelmeni
	required_items = list(
		/obj/item/reagent_containers/food/snacks/doughslice,
		/obj/item/reagent_containers/food/snacks/doughslice,
		/obj/item/reagent_containers/food/snacks/rawmeatball
	)
	result_path = /obj/item/reagent_containers/food/snacks/dumpling

/datum/microwave_recipe/pelmeniboiled
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
