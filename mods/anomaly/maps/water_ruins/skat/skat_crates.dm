/obj/item/reagent_containers/food/snacks/candy/shegolad
	icon = 'mods/anomaly/icons/shegolad.dmi'
	name = "Shegolad"
	desc = "Tasty chocolate bar by new brand!"
	icon_state = "shegolad"
	trash = /obj/item/trash/shegolad

/obj/item/trash/shegolad
	icon = 'mods/anomaly/icons/shegolad.dmi'
	icon_state = "shegolad_empty"

/obj/structure/closet/crate/titan_shegolad


/obj/structure/closet/crate/titan_shegolad/WillContain()
	return list(
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad,
		/obj/item/reagent_containers/food/snacks/candy/shegolad
	)

/obj/structure/closet/crate/titan_shegolad/energizer

/obj/structure/closet/crate/titan_shegolad/energizer/WillContain()
	return list(
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/infinite,
		/obj/item/cell/infinite
	)

/obj/landmark/random_titan_crate
	var/list/possible_crates = list(
		/obj/structure/closet/crate/titan_shegolad = 1,
		/obj/structure/closet/crate/titan_shegolad/energizer = 5
	)

/obj/landmark/random_titan_crate/Initialize()
	. = ..()
	var/result_crate = pickweight(possible_crates)
	var/obj/structure/closet/crate = new result_crate(get_turf(src))
	crate.LateInitialize()
	qdel(src)
