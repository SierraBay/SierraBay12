/obj/item/reagent_containers/food/snacks/sliceable/ryebread
	name = "rye bread"
	icon_state = "Some plain old Earthen bread. Made of a rye."
	desc = "Some plain old Earthen rye bread."
	icon = 'maps/sierra/icons/obj/snacks.dmi'
	icon_state = "bread-rye"
	slice_path = /obj/item/reagent_containers/food/snacks/slice/ryebread
	slices_num = 6
	center_of_mass = "x=16;y=9"
	nutriment_desc = list("rye" = 10)
	nutriment_amt = 10
	bitesize = 2
	trash = null

/obj/item/reagent_containers/food/snacks/slice/ryebread
	name = "rye bread slice"
	desc = "A slice of home. A rye home."
	icon = 'maps/sierra/icons/obj/snacks.dmi'
	icon_state = "bread-rye-slice"
	bitesize = 2
	center_of_mass = "x=16;y=4"
	whole_path = /obj/item/reagent_containers/food/snacks/sliceable/ryebread
	trash = null

/obj/item/reagent_containers/food/snacks/slice/ryebread
	filled = TRUE

/obj/item/reagent_containers/food/snacks/dumpling
	name = "\improper meat dumplings"
	desc = "Raw meat appetizer, native to Terra."
	icon = 'maps/sierra/icons/obj/snacks.dmi'
	icon_state = "pelmeni"
	filling_color = "#ffffff"
	center_of_mass = "x=16;y=16"
	bitesize = 2

/obj/item/reagent_containers/food/snacks/dumpling/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/nutriment/protein, 5)

/obj/item/reagent_containers/food/snacks/boileddumplings
	name = "\improper boiled dumplings"
	desc = "A dish consisting of boiled pieces of meat wrapped in dough. Delicious!"
	icon = 'maps/sierra/icons/obj/snacks.dmi'
	icon_state = "pelmeni_boiled"
	filling_color = "#ffffff"
	center_of_mass = "x=16;y=16"
	bitesize = 2

/obj/item/reagent_containers/food/snacks/dumpling/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/nutriment/protein, 30)
