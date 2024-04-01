/obj/item/clothing/head/helmet/space/void/medic
	desc = "An atmos resistant helmet for space and planet exploration."
	name = "medic voidsuit helmet"
	icon_state = "rig0_pilot"
	item_state = "pilot_helm"
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
		)
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/medic
	desc = "An atmos resistant voidsuit for space and planet exploration."
	icon_state = "rig-pilot"
	name = "medic voidsuit"
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
		)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/rcd,/obj/item/rpd)

/obj/item/clothing/head/helmet/space/void/engineer
	desc = "An atmos resistant helmet for space and planet exploration."
	name = "engineer voidsuit helmet"
	icon_state = "rig0_pilot"
	item_state = "pilot_helm"
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
		)
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/engineer
	desc = "An atmos resistant voidsuit for space and planet exploration."
	icon_state = "rig-pilot"
	name = "engineer voidsuit"
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
		)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/rcd,/obj/item/rpd)
