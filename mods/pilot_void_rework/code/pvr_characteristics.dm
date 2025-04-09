
//Делаю воидсьют Пилота ЭК более имбовым
/obj/item/clothing/head/helmet/space/void/pilot
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT,
		bomb = ARMOR_BOMB_MINOR,
		energy = ARMOR_ENERGY_MINOR
		)
	light_overlay = "helmet_light_alt"
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	min_pressure_protection = 0
	max_pressure_protection = VOIDSUIT_MAX_PRESSURE
	siemens_coefficient = 0.9
	species_restricted = list("exclude", SPECIES_NABBER, SPECIES_DIONA)
	flash_protection = FLASH_PROTECTION_MAJOR
	tint = TINT_NONE

/obj/item/clothing/suit/space/void/pilot
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT,
		bomb = ARMOR_BOMB_MINOR,
		energy = ARMOR_ENERGY_MINOR
		)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/rcd,/obj/item/rpd)

/obj/item/clothing/suit/space/void/pilot
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(
		/obj/item/device/flashlight,
		/obj/item/tank/oxygen_emergency,
		/obj/item/tank/oxygen_emergency_extended,
		/obj/item/tank/nitrogen_emergency,
		/obj/item/device/suit_cooling_unit
	)
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT,
		bomb = ARMOR_BOMB_MINOR,
		energy = ARMOR_ENERGY_MINOR
		)
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	min_pressure_protection = 0
	max_pressure_protection = VOIDSUIT_MAX_PRESSURE
	siemens_coefficient = 0.9
	randpixel = 0
