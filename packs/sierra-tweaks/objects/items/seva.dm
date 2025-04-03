//Ceti
/obj/item/clothing/suit/space/void/ceti
	name = "CTI Voidsuit"
	desc = "A xenoarcheology voidsuit designed for CTI researchers, by CTI researchers. Tools not included."
	icon = 'mods/_maps/verne/icons/verne_void_obj.dmi'
	icon_state = "rig-ceti"
	item_icons = list(slot_wear_suit_str = 'mods/_maps/verne/icons/verne_void_onmob.dmi')
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SHIELDED
	)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/stack/flag,/obj/item/storage/excavation,/obj/item/pickaxe,/obj/item/device/scanner/health,/obj/item/device/measuring_tape,/obj/item/device/ano_scanner,/obj/item/device/depth_scanner,/obj/item/device/core_sampler,/obj/item/device/gps,/obj/item/pinpointer/radio,/obj/item/pickaxe/xeno,/obj/item/storage/bag/fossils)

/obj/item/clothing/suit/space/void/ceti/anomaly_protection = 0.4

/obj/item/clothing/suit/space/void/ceti/alt
	name = "CTI Hazard Environment Voidsuit"
	desc = "A specially made voidsuit designed for use by CTI affiliated researchers while in contact with exotic and potentially anomalous materials"
	icon_state = "SEVA_suit"
	item_state = "SEVA_suit"

/obj/item/clothing/suit/space/void/ceti/alt/anomaly_protection = 0.6

/obj/item/clothing/head/helmet/space/void/ceti
	name = "CTI voidsuit helmet"
	desc = "A specially made voidsuit helmet designed for use by CTI affiliated researchers."
	icon = 'mods/_maps/verne/icons/verne_void_obj.dmi'
	icon_state = "rig0-ceti"
	item_state = "helm-ceti"
	item_icons = list(slot_head_str = 'mods/_maps/verne/icons/verne_void_onmob.dmi')
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SHIELDED
	)
	light_overlay = "helmet_light"

/obj/item/clothing/head/helmet/space/void/ceti/anomaly_protection = 0.1

/obj/item/clothing/head/helmet/space/void/ceti/alt
	name = "CTI Hazard Environment voidsuit helmet"
	desc = "A specially made voidsuit helmet designed for use by CTI affiliated researchers while in contact with exotic and potentially anomalous materials."
	icon_state = "SEVA_helmet"
	item_state = "SEVA_helmet"

/obj/item/clothing/head/helmet/space/void/ceti/alt/anomaly_protection = 0.2

/obj/item/clothing/suit/space/void/ceti/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/ceti
	boots = /obj/item/clothing/shoes/magboots
