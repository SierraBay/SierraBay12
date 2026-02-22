// Данный мини-мод вводит дополнительные рецепты для блюд из духовки, в которых batter и cakebatter заменены на соевые аналоги.
// TODO: Может вызывать дублирование информации в Кодексе, хотя всё остальное работает корректно.
// Автор: Guared1365

// Blueberry pancakes
/singleton/cooking_recipe/pancakesblu/soy
	appliance = COOKING_APPLIANCE_SKILLET
	required_reagents = list(
		/datum/reagent/nutriment/batter/soy = 20
	)
	required_produce = list(
		"blueberries" = 2
	)
	result_path = /obj/item/reagent_containers/food/snacks/pancakesblu
	cooked_scent = /datum/extension/scent/food/pancakes

// Pancakes
/singleton/cooking_recipe/pancakes/soy
	appliance = COOKING_APPLIANCE_SKILLET
	required_reagents = list(
		/datum/reagent/nutriment/batter/soy = 20
	)
	result_path = /obj/item/reagent_containers/food/snacks/pancakes
	cooked_scent = /datum/extension/scent/food/pancakes

// Waffles
/singleton/cooking_recipe/waffles/soy
	appliance = COOKING_APPLIANCE_SKILLET
	required_reagents = list(
		/datum/reagent/nutriment/batter/cakebatter/soy = 20
	)

	result_path = /obj/item/reagent_containers/food/snacks/waffles
	cooked_scent = /datum/extension/scent/food/waffles

// Muffins
/singleton/cooking_recipe/muffin/soy
	appliance = COOKING_APPLIANCE_OVEN | COOKING_APPLIANCE_MICROWAVE
	required_reagents = list(
		/datum/reagent/nutriment/batter/cakebatter/soy = 10
	)
	result_path = /obj/item/reagent_containers/food/snacks/muffin
	cooked_scent = /datum/extension/scent/food/cake

// Cookies
/singleton/cooking_recipe/cookie/soy
	appliance = COOKING_APPLIANCE_OVEN
	required_reagents = list(
		/datum/reagent/nutriment/batter/cakebatter/soy = 5,
		/datum/reagent/nutriment/coco = 5
	)
	result_path = /obj/item/reagent_containers/food/snacks/cookie
	cooked_scent = /datum/extension/scent/food/cookie

// Roffle waffles
/singleton/cooking_recipe/rofflewaffles/soy
	appliance = COOKING_APPLIANCE_OVEN
	required_reagents = list(
		/datum/reagent/drugs/psilocybin = 5,
		/datum/reagent/nutriment/batter/cakebatter/soy = 20
	)
	result_path = /obj/item/reagent_containers/food/snacks/rofflewaffles
	cooked_scent = /datum/extension/scent/food/waffles

// Plump helmet biscuits
/singleton/cooking_recipe/plumphelmetbiscuit/soy
	appliance = COOKING_APPLIANCE_OVEN
	required_reagents = list(
		/datum/reagent/nutriment/batter/soy = 10
	)
	required_produce = list(
		"plumphelmet" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/plumphelmetbiscuit
	cooked_scent = /datum/extension/scent/food/cookie

// Plain Cakes
/singleton/cooking_recipe/cake/soy
	appliance = COOKING_APPLIANCE_OVEN
	required_reagents = list(
		/datum/reagent/nutriment/batter/cakebatter/soy = 60
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/plaincake
	cooked_scent = /datum/extension/scent/food/cake

// Ntella cheesecakes
/singleton/cooking_recipe/cake/ntella_cheesecake/soy
	required_reagents = list(
		/datum/reagent/nutriment/choconutspread = 15,
		/datum/reagent/nutriment/batter/cakebatter/soy = 60
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cookie,
		/obj/item/reagent_containers/food/snacks/cookie,
		/obj/item/reagent_containers/food/snacks/cookie
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/ntella_cheesecake

// Birthday cakes
/singleton/cooking_recipe/cake/birthday/soy
	required_reagents = list(
		/datum/reagent/nutriment/batter/cakebatter/soy = 60,
		/datum/reagent/nutriment/sprinkles = 10
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/birthdaycake

// Figgy puddings
/singleton/cooking_recipe/figgypudding/soy
	appliance = COOKING_APPLIANCE_OVEN
	required_reagents = list(
		/datum/reagent/nutriment/batter/cakebatter/soy = 20,
		/datum/reagent/ethanol/lunabrandy = 5
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/no_raisin
	)
	required_produce = list(
		"apple" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/figgypudding
	cooked_scent = /datum/extension/scent/food/cake

// Cuban carp
/singleton/cooking_recipe/cubancarp/soy
	appliance = COOKING_APPLIANCE_FRYER
	required_reagents = list(
		/datum/reagent/nutriment/batter/soy = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/fish
	)
	required_produce = list(
		"chili" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/cubancarp
	cooked_scent = /datum/extension/scent/food/fish

// Fish fingers
/singleton/cooking_recipe/fishfingers/soy
	appliance = COOKING_APPLIANCE_FRYER
	required_reagents = list(
		/datum/reagent/nutriment/batter/soy = 10
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/fish
	)
	result_path = /obj/item/reagent_containers/food/snacks/fishfingers
	cooked_scent = /datum/extension/scent/food/fish

// Onion rings
/singleton/cooking_recipe/onionrings/soy
	appliance = COOKING_APPLIANCE_FRYER | COOKING_APPLIANCE_OVEN
	required_reagents = list(
		/datum/reagent/nutriment/batter/soy = 10
	)
	required_produce = list(
		"onion" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/onionrings
	cooked_scent = /datum/extension/scent/food/grease

// Shrimp in batter (Shrimp_tempura)
/singleton/cooking_recipe/shrimp_tempura/soy
	appliance = COOKING_APPLIANCE_FRYER
	required_reagents = list(
		/datum/reagent/nutriment/batter/soy = 5
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/shellfish/shrimp
	)
	result_path = /obj/item/reagent_containers/food/snacks/shrimp_tempura
	cooked_scent = /datum/extension/scent/food/grease
