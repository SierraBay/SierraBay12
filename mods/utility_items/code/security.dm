/obj/item/clothing/suit/armor/hos/Initialize()
	. = ..()
	name = "armored coat"
	desc = "A greatcoat enhanced with a special alloy for some protection and style."
	icon = 'maps/sierra/icons/obj/clothing/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi')
	icon_state = "hos"
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi',
		SPECIES_TAJARA = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi',
		SPECIES_SKRELL = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi',
		SPECIES_VOX = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi',
		SPECIES_RESOMI = 'mods/resomi/icons/clothing/onmob_suit_resomi.dmi')
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(
		melee = ARMOR_MELEE_MAJOR,
		bullet = ARMOR_BALLISTIC_PISTOL,
		laser = ARMOR_LASER_HANDGUNS,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED
		)
	siemens_coefficient = 0.6
	flags_inv = null
