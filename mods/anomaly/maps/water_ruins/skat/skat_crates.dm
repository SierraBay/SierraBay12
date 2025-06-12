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
	icon_state = "weak_crate"
	var/list/possible_crates = list()

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
	var/list/spawn_contents = list()

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

/obj/structure/titan_largecrate/shegolad
	icon_state = "straped_closed"
	open_case_sound = 'mods/anomaly/sounds/crates/wood_sound.ogg'
	spawn_contents = list(
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

/obj/structure/titan_largecrate/energizer
	icon_state = "power_closed"
	destroyed_icon_state = "power_open"
	open_case_sound = 'mods/anomaly/sounds/crates/metal_sound.ogg'
	spawn_contents = list(
		/obj/item/cell/standard,
		/obj/item/cell/standard,
		/obj/item/cell/standard,
		/obj/item/cell/standard,
		/obj/item/cell/standard,
		/obj/item/cell/high,
		/obj/item/cell/high,
		/obj/item/cell/high,
		/obj/item/cell/high,
		/obj/item/cell/high
	)


/obj/structure/titan_largecrate/energizer/rich
	spawn_contents = list(
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper,
		/obj/item/cell/hyper
	)

/obj/structure/titan_largecrate/energizer/mega_rich
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
		/obj/item/weldingtool,
		/obj/item/weldingtool
	)

/obj/structure/titan_largecrate/energizer/toolz/rich
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
		/obj/item/weldingtool/electric,
		/obj/item/rcd,
		/obj/item/rcd,
		/obj/item/rcd_ammo,
		/obj/item/rcd_ammo
	)

/obj/structure/titan_largecrate/medical
	icon_state = "medical_closed"
	destroyed_icon_state = "medical_open"
	open_case_sound = 'mods/anomaly/sounds/crates/metal_sound.ogg'

/obj/structure/titan_largecrate/medical/bags
	spawn_contents = list(
		/obj/item/bodybag/rescue,
		/obj/item/bodybag/rescue,
		/obj/item/bodybag/rescue,
		/obj/item/bodybag/rescue,
		/obj/item/bodybag/rescue
	)

/obj/structure/titan_largecrate/medical/spays
	spawn_contents = list(
		/obj/item/stack/medical/ointment,
		/obj/item/stack/medical/ointment,
		/obj/item/stack/medical/ointment,
		/obj/item/stack/medical/ointment,
		/obj/item/stack/medical/ointment,
		/obj/item/stack/medical/ointment,
		/obj/item/stack/medical/ointment,
		/obj/item/stack/medical/ointment,
		/obj/item/stack/medical/ointment,
		/obj/item/stack/medical/ointment
	)

/obj/structure/titan_largecrate/medical/bandages
	spawn_contents = list(
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/bruise_pack
	)

/obj/structure/titan_largecrate/medical/rich
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

/obj/structure/titan_largecrate/materials/wood
	spawn_contents = list(
		/obj/item/stack/material/wood/fifty,
		/obj/item/stack/material/wood/fifty,
		/obj/item/stack/material/wood/fifty,
		/obj/item/stack/material/wood/fifty
	)

/obj/structure/titan_largecrate/materials/rich
	spawn_contents = list(
		/obj/item/stack/material/silver/ten,
		/obj/item/stack/material/gold/ten,
		/obj/item/stack/material/diamond/ten,
		/obj/item/stack/material/phoron/ten
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

//Ящики для 2-го этажа, тобишь слабые
/obj/landmark/titan_crate/weak_crate
	icon_state = "weak_crate"
	possible_crates = list(
		/obj/structure/titan_largecrate/shegolad = 1,
		/obj/structure/titan_largecrate/energizer = 1,
		/obj/structure/titan_largecrate/medical/bags = 1,
		/obj/structure/titan_largecrate/medical/spays = 1,
		/obj/structure/titan_largecrate/medical/bandages = 1,
		/obj/structure/titan_largecrate/materials = 1,
		/obj/structure/titan_largecrate/materials/wood = 1,
		/obj/structure/titan_largecrate/food = 1,
		/obj/structure/titan_largecrate/food/mre = 1,
		/obj/structure/titan_largecrate/energizer/toolz = 1
	)

/obj/landmark/titan_crate/rare_crate
	icon_state = "rare_crate"
	possible_crates = list(
		/obj/structure/titan_largecrate/energizer/rich = 1,
		/obj/structure/titan_largecrate/energizer/mega_rich = 1,
		/obj/structure/titan_largecrate/materials/rich = 1,
		/obj/structure/titan_largecrate/energizer/toolz/rich = 1
	)
