/* TACTICAL_GEAR_RESPRITE
Black resprite of the "Armor - Tactical" cargo crate set. */

/obj/item/clothing/under/tactical
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_uniforms.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_uniforms.dmi',
		slot_w_uniform_str = 'mods/utility_items/icons/tactical_onmob.dmi'
		)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/species/vox/onmob_under_vox.dmi',
		SPECIES_NABBER = 'icons/mob/species/nabber/onmob_under_gas.dmi',
		SPECIES_UNATHI = 'mods/utility_items/icons/tactical_onmob_unathi.dmi'
		)

/obj/item/clothing/head/helmet/tactical
	desc = "A black helmet made from advanced ceramic. Comfortable and robust."
	icon = 'mods/utility_items/icons/tactical_obj.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_hats.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_hats.dmi',
		slot_head_str = 'mods/utility_items/icons/tactical_onmob.dmi'
		)
	icon_state = "tac_helmet"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/species/vox/onmob_head_vox.dmi',
		SPECIES_UNATHI = 'mods/utility_items/icons/tactical_onmob_unathi.dmi',
		SPECIES_NABBER = 'icons/mob/species/nabber/onmob_head_gas.dmi'
		)

// resomi modpack sets its own sheet on every hat and suit in Initialize()
/obj/item/clothing/head/helmet/tactical/Initialize()
	. = ..()
	LAZYSET(sprite_sheets, SPECIES_RESOMI, 'mods/utility_items/icons/tactical_onmob_resomi.dmi')

/obj/item/clothing/gloves/tactical
	desc = "These black tactical gloves are made from a durable synthetic, and have hardened knuckles."
	icon = 'mods/utility_items/icons/tactical_obj.dmi'
	item_icons = list(slot_gloves_str = 'mods/utility_items/icons/tactical_onmob.dmi')
	icon_state = "tac_gloves"
	item_state = "tac_gloves"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/species/vox/onmob_hands_vox.dmi',
		SPECIES_NABBER = 'icons/mob/species/nabber/onmob_hands_gas.dmi',
		SPECIES_UNATHI = 'mods/utility_items/icons/tactical_onmob_unathi.dmi'
		)

/obj/item/clothing/shoes/tactical
	desc = "Black boots with extra padding and armor."
	icon = 'mods/utility_items/icons/tactical_obj.dmi'
	item_icons = list(slot_shoes_str = 'mods/utility_items/icons/tactical_onmob.dmi')
	icon_state = "tac_boots"

/obj/item/clothing/suit/armor/pcarrier/tan/tactical
	desc = "A lightweight black plate carrier vest. It can be equipped with armor plates, but provides no protection of its own."
	icon = 'mods/utility_items/icons/tactical_obj.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/utility_items/icons/tactical_onmob.dmi')
	icon_state = "tac_carrier"
	sprite_sheets = list(
		SPECIES_UNATHI = 'mods/utility_items/icons/tactical_onmob_unathi.dmi'
		)
	accessories = list(/obj/item/clothing/accessory/armor_plate/tactical, /obj/item/clothing/accessory/storage/pouches/large/tactical)

/obj/item/clothing/suit/armor/pcarrier/tan/tactical/Initialize()
	. = ..()
	LAZYSET(sprite_sheets, SPECIES_RESOMI, 'mods/utility_items/icons/tactical_onmob_resomi.dmi')

/obj/item/clothing/accessory/storage/pouches/large/tactical
	desc = "A collection of black tactical pouches that can be attached to a plate carrier. Carries up to four items."
	icon = 'mods/utility_items/icons/tactical_obj.dmi'
	icon_override = 'mods/utility_items/icons/tactical_onmob.dmi'
	accessory_icons = list(
		slot_tie_str = 'mods/utility_items/icons/tactical_onmob.dmi',
		slot_wear_suit_str = 'mods/utility_items/icons/tactical_onmob.dmi'
		)
	icon_state = "tac_lpouches"
	sprite_sheets = list(
		SPECIES_UNATHI = 'mods/utility_items/icons/tactical_onmob_unathi.dmi'
		)

/obj/item/clothing/accessory/arm_guards/tactical
	name = "tactical arm guards"
	desc = "A pair of black arm pads reinforced with additional ablative coating. Attaches to a plate carrier."
	icon = 'mods/utility_items/icons/tactical_obj.dmi'
	icon_override = 'mods/utility_items/icons/tactical_onmob.dmi'
	accessory_icons = list(
		slot_tie_str = 'mods/utility_items/icons/tactical_onmob.dmi',
		slot_wear_suit_str = 'mods/utility_items/icons/tactical_onmob.dmi'
		)
	icon_state = "tac_armguards"
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		laser = ARMOR_LASER_HANDGUNS,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED
		)
	sprite_sheets = list(
		SPECIES_UNATHI = 'mods/utility_items/icons/tactical_onmob_unathi.dmi'
		)

/obj/item/clothing/accessory/leg_guards/tactical
	name = "tactical leg guards"
	desc = "A pair of armored leg pads reinforced with additional ablative coating. Attaches to a plate carrier."
	icon = 'mods/utility_items/icons/tactical_obj.dmi'
	icon_override = 'mods/utility_items/icons/tactical_onmob.dmi'
	accessory_icons = list(
		slot_tie_str = 'mods/utility_items/icons/tactical_onmob.dmi',
		slot_wear_suit_str = 'mods/utility_items/icons/tactical_onmob.dmi'
		)
	icon_state = "tac_legguards"
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		laser = ARMOR_LASER_HANDGUNS,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED
		)
	sprite_sheets = list(
		SPECIES_UNATHI = 'mods/utility_items/icons/tactical_onmob_unathi.dmi'
		)
