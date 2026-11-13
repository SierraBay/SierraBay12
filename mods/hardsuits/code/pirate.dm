//Pirate rig
/obj/item/clothing/head/helmet/space/void/pirate
	name = "panoramic mauve voidsuit helmet"
	desc = "Mauve panoramic helmet used by various pirate factions across the frontier."
	icon = 'mods/hardsuits/icons/voidsuits/obj_head.dmi'
	icon_state = "pirate"
	item_state = "pirate"
	item_icons = list(slot_head_str = 'mods/hardsuits/icons/voidsuits/onmob_head.dmi')
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		laser = ARMOR_LASER_HANDGUNS,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
		)
	siemens_coefficient = 0.3
	species_restricted = list(SPECIES_HUMAN, SPECIES_IPC)
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/pirate
	icon = 'mods/hardsuits/icons/voidsuits/obj_suit.dmi'
	icon_state = "pirate"
	item_state = "pirate"
	item_icons = list(slot_wear_suit_str = 'mods/hardsuits/icons/voidsuits/onmob_suit.dmi')
	name = "clad-black voidsuit"
	desc = "A clad-black voidsuit used by various pirate factions across the frontier."
	item_state_slots = list(
		slot_l_hand_str = "syndie_voidsuit",
		slot_r_hand_str = "syndie_voidsuit",
	)
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		laser = ARMOR_LASER_HANDGUNS,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
		)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword,/obj/item/handcuffs)
	siemens_coefficient = 0.3
	species_restricted = list(SPECIES_HUMAN, SPECIES_IPC)

/obj/item/clothing/suit/space/void/pirate/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/pirate
	boots = /obj/item/clothing/shoes/magboots
	tank = /obj/item/tank/oxygen
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_INVALID_FOR_CHAMELEON
