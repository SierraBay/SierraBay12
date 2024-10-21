/obj/item/bolt
	name = "Bolt"
	desc = "A simple bolt, kindly twisted for you by engineers."
	icon = 'mods/anomaly/icons/bolts.dmi'
	icon_state = "bolt"
	w_class = ITEM_SIZE_TINY
	matter = list(MATERIAL_STEEL = 200)


/obj/item/storage/bolt_bag
	name = "Bag with bolts"
	desc = "Sturdy bolt storage bag."
	icon = 'mods/anomaly/icons/bolts.dmi'
	icon_state = "bolt_bag"
	allow_quick_gather = TRUE
	allow_quick_empty  = TRUE
	w_class = ITEM_SIZE_TINY
	max_w_class = ITEM_SIZE_LARGE
	max_storage_space = DEFAULT_BOX_STORAGE


/obj/item/storage/bolt_bag/full_of_bolts
	startswith = list(
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt,
		/obj/item/bolt
	)


//Ниже будут изменяться matter у разных предметов, чтоб те имели в составе железо и подобное
/obj/item/ammo_casing
	matter = list(MATERIAL_STEEL = 10) //Мало, чтоб не абузили

/obj/item/tank
	matter = list(MATERIAL_STEEL = 100)
