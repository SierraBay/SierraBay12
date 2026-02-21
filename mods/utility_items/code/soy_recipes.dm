// Данный мини-мод вводит дополнительные рецепты для блюд из духовки, в которых batter и cakebatter заменены на соевые аналоги.
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
	result_path = /obj/item/reagent_containers/food/snacks/pancakesblu/soy
	cooked_scent = /datum/extension/scent/food/pancakes

/obj/item/reagent_containers/food/snacks/pancakesblu/soy
	name = "soy blueberry pancakes"
	desc = "Pancakes with blueberries, delicious. These were made from soy batter."
	icon_state = "pancakes_berry"
	trash = /obj/item/trash/plate
	center_of_mass = "x=15;y=11"
	bitesize = 2

// Pancakes
/singleton/cooking_recipe/pancakes/soy
	appliance = COOKING_APPLIANCE_SKILLET
	required_reagents = list(
		/datum/reagent/nutriment/batter/soy = 20
	)
	result_path = /obj/item/reagent_containers/food/snacks/pancakes/soy
	cooked_scent = /datum/extension/scent/food/pancakes

/obj/item/reagent_containers/food/snacks/pancakes/soy
	name = "soy pancakes"
	desc = "Pancakes without blueberries, still delicious. These were made from soy batter."
	icon_state = "pancakes"
	trash = /obj/item/trash/plate
	center_of_mass = "x=15;y=11"
	bitesize = 2

// Waffles
/singleton/cooking_recipe/waffles/soy
	appliance = COOKING_APPLIANCE_SKILLET
	required_reagents = list(
		/datum/reagent/nutriment/batter/cakebatter/soy = 20
	)

	result_path = /obj/item/reagent_containers/food/snacks/waffles/soy
	cooked_scent = /datum/extension/scent/food/waffles

/obj/item/reagent_containers/food/snacks/waffles/soy
	name = "soy waffles"
	desc = "Mmm, waffles. These were made from soy cake batter."
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	filling_color = "#e6deb5"
	center_of_mass = "x=15;y=11"
	bitesize = 2

// Muffins
/singleton/cooking_recipe/muffin/soy
	appliance = COOKING_APPLIANCE_OVEN | COOKING_APPLIANCE_MICROWAVE
	required_reagents = list(
		/datum/reagent/nutriment/batter/cakebatter/soy = 10
	)
	result_path = /obj/item/reagent_containers/food/snacks/muffin/soy
	cooked_scent = /datum/extension/scent/food/cake

/obj/item/reagent_containers/food/snacks/muffin/soy
	name = "soy muffin"
	desc = "A delicious and spongy little cake. This one was made from soy cake batter."
	icon_state = "muffin"
	filling_color = "#e0cf9b"
	center_of_mass = "x=17;y=4"
	bitesize = 2

// Cookies
/singleton/cooking_recipe/cookie/soy
	appliance = COOKING_APPLIANCE_OVEN
	required_reagents = list(
		/datum/reagent/nutriment/batter/cakebatter/soy = 5,
		/datum/reagent/nutriment/coco = 5
	)
	result_path = /obj/item/reagent_containers/food/snacks/cookie/soy
	cooked_scent = /datum/extension/scent/food/cookie

/obj/item/reagent_containers/food/snacks/cookie/soy
	name = "soy cookie"
	desc = "COOKIE!!! Oops, it seems that this one was made from soy cake batter."
	icon_state = "cookie"
	filling_color = "#dbc94f"
	center_of_mass = "x=17;y=18"
	w_class = ITEM_SIZE_TINY
	volume = 20
	bitesize = 1

// Roffle waffles
/singleton/cooking_recipe/rofflewaffles
	appliance = COOKING_APPLIANCE_OVEN
	required_reagents = list(
		/datum/reagent/drugs/psilocybin = 5,
		/datum/reagent/nutriment/batter/cakebatter/soy = 20
	)
	result_path = /obj/item/reagent_containers/food/snacks/rofflewaffles/soy
	cooked_scent = /datum/extension/scent/food/waffles

/obj/item/reagent_containers/food/snacks/rofflewaffles/soy
	name = "soy roffle waffles"
	desc = "Waffles from Roffle. Co. Wait... These were made from soy batter."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	filling_color = "#ff00f7"
	center_of_mass = "x=15;y=11"
	bitesize = 4

// Plump helmet biscuits
/singleton/cooking_recipe/plumphelmetbiscuit/soy
	appliance = COOKING_APPLIANCE_OVEN
	required_reagents = list(
		/datum/reagent/nutriment/batter/soy = 10
	)
	required_produce = list(
		"plumphelmet" = 1
	)
	result_path = /obj/item/reagent_containers/food/snacks/plumphelmetbiscuit/soy
	cooked_scent = /datum/extension/scent/food/cookie

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit/soy
	name = "soy plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour. Oops, this one was made from soy batter."
	icon_state = "phelmbiscuit"
	filling_color = "#cfb4c4"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("mushroom" = 5)
	nutriment_amt = 5
	bitesize = 2

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit/soy/Initialize()
	.=..()
	if(prob(10))
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
		reagents.add_reagent(/datum/reagent/nutriment, 3)
		reagents.add_reagent(/datum/reagent/tricordrazine, 5)

// Plain Cakes
/singleton/cooking_recipe/cake
	appliance = COOKING_APPLIANCE_OVEN
	required_reagents = list(
		/datum/reagent/nutriment/batter/cakebatter/soy = 60
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/plaincake/soy
	cooked_scent = /datum/extension/scent/food/cake

/obj/item/reagent_containers/food/snacks/sliceable/plaincake/soy
	name = "soy vanilla cake"
	desc = "A plain cake, not a lie. This one was made from soy cake batter."
	icon_state = "plaincake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/plaincake/soy
	slices_num = 5
	filling_color = "#f7edd5"
	center_of_mass = "x=16;y=10"

/obj/item/reagent_containers/food/snacks/slice/plaincake/soy
	name = "soy vanilla cake slice"
	desc = "Just a slice of cake, it is enough for everyone. This one was made from soy cake batter."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#f7edd5"
	bitesize = 2
	center_of_mass = "x=16;y=14"
	whole_path = /obj/item/reagent_containers/food/snacks/sliceable/plaincake/soy

/obj/item/reagent_containers/food/snacks/slice/plaincake/soy/filled
	filled = TRUE

// Ntella cheesecakes
/singleton/cooking_recipe/cake/ntella_cheesecake/soy
	required_reagents = list(
		/datum/reagent/nutriment/choconutspread = 15,
		/datum/reagent/nutriment/batter/cakebatter/soy = 60
	)
	required_items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cookie/soy,
		/obj/item/reagent_containers/food/snacks/cookie/soy,
		/obj/item/reagent_containers/food/snacks/cookie/soy
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/ntella_cheesecake/soy

/obj/item/reagent_containers/food/snacks/sliceable/ntella_cheesecake/soy
	name = "soy NTella cheesecake"
	desc = "An elaborate layered cheesecake made with chocolate hazelnut spread. You gain calories just by looking at it for too long. This one was made from soy cake batter."
	icon_state = "NTellacheesecake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/ntella_cheesecake
	slices_num = 5
	filling_color = "#331c03"
	center_of_mass = "x=16;y=10"
	bitesize = 2

/obj/item/reagent_containers/food/snacks/slice/ntella_cheesecake
	name = "soy NTella cheesecake slice"
	desc = "A slice of cake marrying the chocolate taste of NTella with the creamy smoothness of cheesecake, all on a cookie crumble base. This one was made from soy cake batter."
	icon_state = "NTellacheesecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#331c03"
	bitesize = 2
	center_of_mass = "x=16;y=14"
	whole_path = /obj/item/reagent_containers/food/snacks/sliceable/ntella_cheesecake

/obj/item/reagent_containers/food/snacks/slice/ntella_cheesecake/soy/filled
	filled = TRUE

// Birthday cakes
/singleton/cooking_recipe/cake/birthday/soy
	required_reagents = list(
		/datum/reagent/nutriment/batter/cakebatter/soy = 60,
		/datum/reagent/nutriment/sprinkles = 10
	)
	result_path = /obj/item/reagent_containers/food/snacks/sliceable/birthdaycake/soy

/obj/item/reagent_containers/food/snacks/sliceable/birthdaycake/soy
	name = "soy birthday cake"
	desc = "Happy birthday! Oops! This one was made from soy cake batter."
	icon_state = "birthdaycake"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/birthdaycake/soy
	slices_num = 5
	filling_color = "#ffd6d6"
	center_of_mass = "x=16;y=10"
	bitesize = 3

/obj/item/reagent_containers/food/snacks/slice/birthdaycake/soy
	name = "soy birthday cake slice"
	desc = "A slice of your birthday. Oops! This one was made from soy cake batter."
	icon_state = "birthdaycakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#ffd6d6"
	bitesize = 2
	center_of_mass = "x=16;y=14"
	whole_path = /obj/item/reagent_containers/food/snacks/sliceable/birthdaycake/soy

/obj/item/reagent_containers/food/snacks/slice/birthdaycake/soy/filled
	filled = TRUE

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
	result_path = /obj/item/reagent_containers/food/snacks/figgypudding/soy
	cooked_scent = /datum/extension/scent/food/cake

/obj/item/reagent_containers/food/snacks/figgypudding/soy
	name = "soy figgy pudding"
	icon_state = "pudding"
	filling_color = "#4e3d3a"
	desc = "Now bring us some figgy pudding, now bring us some figgy pudding... wait a minute, there's not actually any figs in this. This one was made from soy cake batter."
	trash = /obj/item/trash/plate
	nutriment_amt = 10
	nutriment_desc = list("fruit cake" = 5, "raisins" = 5)
	bitesize = 3
