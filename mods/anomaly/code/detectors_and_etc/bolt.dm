/obj/item/bolt
	name = "Bolt"
	desc = "A simple bolt, kindly twisted for you by engineers."
	icon = 'mods/anomaly/icons/bolts.dmi'
	icon_state = "bolt"
	w_class = ITEM_SIZE_TINY
	matter = list(MATERIAL_STEEL = 200)

/obj/item/bolt/Crossed(O)
	. = ..()
	if(ishuman(usr))
		for(var/obj/item/storage/bolt_bag/bag in usr)
			if(bag.autocollect)
				bag.can_be_inserted(src, usr, 0)


/obj/item/storage/bolt_bag
	name = "Bag with bolts"
	desc = "Sturdy bolt storage bag."
	icon = 'mods/anomaly/icons/bolts.dmi'
	icon_state = "bolt_bag"
	allow_quick_gather = TRUE
	allow_quick_empty  = TRUE
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = BASE_STORAGE_CAPACITY(2)
	var/autocollect = FALSE

/obj/item/storage/bolt_bag/examine(mob/user, distance, is_adjacent)
	. = ..()
	to_chat(user, SPAN_GOOD("Use RBM and use Toggle autocollect to toggle autocollect."))

/obj/item/storage/bolt_bag/verb/toggle_autocollect()
	set category = "Object"
	set name = "toggle autocollect"
	set src in usr

	autocollect = !autocollect
	if(autocollect)
		to_chat(usr, SPAN_NOTICE("Now you will automaticly collect bolts and beacons in this bag."))
	else
		to_chat(usr, SPAN_NOTICE("Now you will NOT automaticly collect bolts and beacons in this bag."))

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
