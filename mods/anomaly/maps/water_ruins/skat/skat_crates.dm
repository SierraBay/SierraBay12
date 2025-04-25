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

/obj/landmark/titan_crate
	name = "Random titan crate"
	icon = 'mods/anomaly/icons/titan_crates.dmi'
	icon_state = "classic"
	var/list/possible_crates = list(
		/obj/structure/titan_largecrate = 1,
		/obj/structure/titan_largecrate/energizer = 2,
		/obj/structure/titan_largecrate/medical = 2,
		/obj/structure/titan_largecrate/materials = 5,
		/obj/structure/titan_largecrate/food = 6,
		/obj/structure/titan_largecrate/food/mre = 5,
		/obj/structure/titan_largecrate/energizer/toolz = 3
	)

/obj/landmark/titan_crate/Initialize()
	. = ..()
	var/spawn_type = pickweight(possible_crates)
	var/turf/my_turf = get_turf(src)
	new spawn_type(my_turf)
	qdel_self()

///Шеголадик
/obj/structure/titan_largecrate
	name = "Cargo crate"
	icon = 'mods/anomaly/icons/titan_crates.dmi'
	icon_state = "classic"
	var/open_case_sound = 'mods/anomaly/sounds/crates/wood_sound.ogg'
	///Если null то просто получаем доски
	var/destroyed_icon_state
	var/opened = FALSE
	var/see_throught_after_open = TRUE //Прозрачен после своего раскрытия
	opacity = TRUE
	density = TRUE
	var/list/spawn_contents = list(
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
		/obj/item/stack/material/wood/maple
	)

/obj/structure/titan_largecrate/Initialize()
	. = ..()
	for(var/item_path in spawn_contents)
		new item_path(src)

/obj/structure/titan_largecrate/use_tool(obj/item/tool, mob/living/user, list/click_params)
	. = ..()
	if(opened)
		return
	if(isCrowbar(tool))
		open_case()

/obj/structure/titan_largecrate/proc/open_case()
	opened = TRUE
	var/turf/my_turf = get_turf(src)
	for(var/atom/movable/item in src)
		item.forceMove(my_turf)
	if(open_case_sound)
		playsound(my_turf, open_case_sound, 100, 1)
	if(destroyed_icon_state)
		icon_state = destroyed_icon_state
	else
		qdel_self()
	if(see_throught_after_open)
		opacity = FALSE


/obj/structure/titan_largecrate/energizer
	icon_state = "power_closed"
	destroyed_icon_state = "power_open"
	open_case_sound = 'mods/anomaly/sounds/crates/metal_sound.ogg'
	spawn_contents = list(
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/infinite
	)

/obj/structure/titan_largecrate/energizer/toolz
	icon_state = "power_closed"
	destroyed_icon_state = "power_open"
	open_case_sound = 'mods/anomaly/sounds/crates/metal_sound.ogg'
	spawn_contents = list(
		/obj/item/crowbar,
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/wrench,
		/obj/item/wirecutters,
		/obj/item/wirecutters,
		/obj/item/swapper/power_drill,
		/obj/item/swapper/power_drill,
		/obj/item/weldingtool/electric,
		/obj/item/weldingtool/electric
	)

/obj/structure/titan_largecrate/medical
	icon_state = "medical_closed"
	destroyed_icon_state = "medical_open"
	open_case_sound = 'mods/anomaly/sounds/crates/metal_sound.ogg'
	spawn_contents = list(
		/obj/item/storage/firstaid/combat,
		/obj/item/storage/firstaid/sleekstab,
		/obj/item/bodybag/cryobag,
		/obj/item/bodybag/cryobag,
		/obj/item/storage/firstaid/surgery,
		/obj/item/defibrillator/compact/combat/loaded
	)

/obj/structure/titan_largecrate/materials
	icon_state = "closed_metal"
	destroyed_icon_state = "open_metal"
	open_case_sound = 'mods/anomaly/sounds/crates/metal_sound.ogg'
	see_throught_after_open = FALSE
	spawn_contents = list(
		/obj/item/stack/material/steel/fifty,
		/obj/item/stack/material/aluminium/fifty,
		/obj/item/stack/material/glass/fifty,
		/obj/item/stack/material/plastic/fifty,
		/obj/item/stack/material/marble/fifty,
		/obj/item/stack/material/plasteel/fifty,
		/obj/item/stack/material/titanium/fifty
	)

/obj/structure/titan_largecrate/food
	icon_state = "straped_closed"
	open_case_sound = 'mods/anomaly/sounds/crates/wood_sound.ogg'
	spawn_contents = list(
		/obj/item/reagent_containers/food/snacks/canned/beef,
		/obj/item/reagent_containers/food/snacks/canned/beef,
		/obj/item/reagent_containers/food/snacks/canned/tomato,
		/obj/item/reagent_containers/food/snacks/canned/tomato,
		/obj/item/reagent_containers/food/snacks/canned/spinach,
		/obj/item/reagent_containers/food/snacks/canned/spinach,
		/obj/item/reagent_containers/food/snacks/canned/beans,
		/obj/item/reagent_containers/food/snacks/canned/beans,
		/obj/item/stack/material/wood/maple
	)

/obj/structure/titan_largecrate/food/mre
	spawn_contents = list(
		/obj/item/storage/mre,
		/obj/item/storage/mre/menu2,
		/obj/item/storage/mre/menu3,
		/obj/item/storage/mre/menu4,
		/obj/item/storage/mre/menu5,
		/obj/item/storage/mre/menu6,
		/obj/item/storage/mre/menu7,
		/obj/item/storage/mre/menu8,
		/obj/item/storage/mre/menu9,
		/obj/item/storage/mre/menu10,
		/obj/item/stack/material/wood/maple)
