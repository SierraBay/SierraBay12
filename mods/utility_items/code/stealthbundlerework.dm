/datum/uplink_item/item/mercenary/stealthy
	path = /obj/structure/closet/crate/stealthy

/obj/structure/closet/crate/stealthy
	name = "Disguise crate"

/obj/structure/closet/crate/stealthy/New()
	..()
	new /obj/item/storage/backpack/chameleon/sydie_kit(src)
	new /obj/item/clothing/accessory/armor_plate/sneaky/tactical(src)
	new /obj/item/device/chameleon(src)
	new /obj/item/storage/box/syndie_kit/silenced(src)
	new /obj/item/storage/lunchbox/caltrops(src)
	new /obj/item/card/emag(src)
	new /obj/item/device/uplink_service/fake_crew_announcement(src)
