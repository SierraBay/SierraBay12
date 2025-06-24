
/singleton/cooking_recipe/tossedsalad
	required_produce = list(
		"lettuce" = 2,
		"tomato" = 1,
		"carrot" = 1,
		"apple" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/tossedsalad

/singleton/cooking_recipe/aesirsalad
	required_items = list(
		/obj/item/reagent_containers/food/snacks/tossedsalad
	)
	required_produce = list(
		"goldapple" = 1,
		"ambrosiadeus" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/aesirsalad

/singleton/cooking_recipe/validsalad
	required_items = list(
		/obj/item/reagent_containers/food/snacks/meatball
	)
	required_produce = list(
		"potato" = 1,
		"ambrosia" = 3
	)
	result_path = /obj/item/reagent_containers/food/snacks/validsalad

/singleton/cooking_recipe/validsalad/CreateResult(obj/container as obj, ...)
	var/obj/item/reagent_containers/food/snacks/validsalad/salad = ..()
	salad.reagents.del_reagent(/datum/reagent/toxin)
	return salad
