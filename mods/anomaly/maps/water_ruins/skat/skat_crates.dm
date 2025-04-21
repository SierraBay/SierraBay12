/obj/item/reagent_containers/food/snacks/candy/shegolad
	icon = 'mods/anomaly/icons/shegolad.dmi'
	name = "Shegolad"
	desc = "Tasty chocolate bar by new brand!"
	icon_state = "shegolad"
	trash = /obj/item/trash/shegolad

/obj/item/trash/shegolad
	name = "Shegolad empty pack"
	icon = 'mods/anomaly/icons/shegolad.dmi'
	icon_state = "shegolad_empty"

/datum/titan_crate_contents/proc/return_contents()
	return

/datum/titan_crate_contents/shegolad/return_contents()
	return  list(
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

/datum/titan_crate_contents/energizer/return_contents()
	return  list(
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/infinite
	)

/obj/structure/largecrate/titan_crate
	icon = 'icons/obj/ore_boxes.dmi'
	icon_state = "orebox0"
	var/list/possible_contents = list(
		/datum/titan_crate_contents/shegolad = 1,
		/datum/titan_crate_contents/energizer = 5
	)

/obj/structure/largecrate/titan_crate/Initialize()
	. = ..()
	var/type = pickweight(possible_contents)
	var/datum/titan_crate_contents/result_datum_contents = new type(src)
	var/list/spawn_items_list = result_datum_contents.return_contents()
	for(var/item_path in spawn_items_list)
		new item_path(src)
