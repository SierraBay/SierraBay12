/obj/item/bolt
	name = "Болт"
	desc = "Простенький болт, любезно скрученный для вас инженерами."
	icon = 'mods/anomaly/icons/bolts.dmi'
	icon_state = "bolt"
	w_class = ITEM_SIZE_TINY
	matter = list(MATERIAL_STEEL = 200)

/obj/item/storage/bolt_bag
	name = "Мешок с болтами"
	desc = "Крепкий мешок для хранения болтов."
	icon = 'mods/anomaly/icons/bolts.dmi'
	icon_state = "bolt_bag"
	w_class = ITEM_SIZE_TINY
	max_w_class = ITEM_SIZE_TINY
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
