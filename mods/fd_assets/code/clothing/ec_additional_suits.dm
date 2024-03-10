//EC Specs suits
/obj/item/clothing/suit/space/void/medical/alt/sol/expo
	name = "exploration medical voidsuit"
	desc = "The bulky Exoplanet Exploration Unit is a standard voidsuit for Expeditionary Corps' medical specialists in field operations. It features extra padding and respectable radiation-resistant lining."
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
		)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/stack/flag,/obj/item/device/scanner/health,/obj/item/device/gps,/obj/item/pinpointer/radio,/obj/item/material/hatchet/machete,/obj/item/shovel)

/obj/item/clothing/head/helmet/space/void/medical/alt/sol/expo
	name = "exploration medical voidsuit helmet"
	desc = "The bulky Exoplanet Exploration Unit is a standard voidsuit for Expeditionary Corps' medical specialists in field operations. It features extra padding and respectable radiation-resistant lining."
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
		)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/stack/flag,/obj/item/device/scanner/health,/obj/item/device/gps,/obj/item/pinpointer/radio,/obj/item/material/hatchet/machete,/obj/item/shovel)


/obj/item/clothing/suit/space/void/atmos/alt/sol/expo
	name = "exploration engineering voidsuit"
	desc = "The bulky Exoplanet Exploration Unit is a standard voidsuit for Expeditionary Corps' engineering specialists in field operations. It features extra padding and respectable radiation-resistant lining."
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
		)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/stack/flag,/obj/item/device/scanner/health,/obj/item/device/gps,/obj/item/pinpointer/radio,/obj/item/material/hatchet/machete,/obj/item/shovel)

/obj/item/clothing/head/helmet/space/void/atmos/alt/sol/expo
	name = "exploration engineering voidsuit helmet"
	desc = "The bulky Exoplanet Exploration Unit is a standard voidsuit for Expeditionary Corps' engineering specialists in field operations. It features extra padding and respectable radiation-resistant lining."
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
		)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/stack/flag,/obj/item/device/scanner/health,/obj/item/device/gps,/obj/item/pinpointer/radio,/obj/item/material/hatchet/machete,/obj/item/shovel)

//EC Specs suits
/obj/machinery/suit_storage_unit/explorer/medic
	name = "Exploration Medic Voidsuit Storage Unit"
	suit = /obj/item/clothing/suit/space/void/medical/alt/sol/expo
	helmet = /obj/item/clothing/head/helmet/space/void/medical/alt/sol/expo
	boots = /obj/item/clothing/shoes/magboots
	tank = /obj/item/tank/oxygen
	mask = /obj/item/clothing/mask/breath
	req_access = list(access_explorer)
	islocked = 1

/obj/machinery/suit_storage_unit/explorer/engineer
	name = "Exploration Engineer Voidsuit Storage Unit"
	suit = /obj/item/clothing/suit/space/void/atmos/alt/sol/expo
	helmet = /obj/item/clothing/head/helmet/space/void/atmos/alt/sol/expo
	boots = /obj/item/clothing/shoes/magboots
	tank = /obj/item/tank/oxygen
	mask = /obj/item/clothing/mask/breath
	req_access = list(access_explorer)
	islocked = 1
