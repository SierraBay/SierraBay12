/obj/item/clothing/head/helmet/nt/blueshift
	name = "research division security helmet"
	desc = "A helmet with 'RESEARCH DIVISION SECURITY' printed on the back in red lettering."
	icon = 'mods/loadout_items/icons/obj_head.dmi'
	item_icons = list(slot_head_str = 'mods/loadout_items/icons/onmob_head.dmi')
	icon_state = "blueshift_helm"

/obj/item/clothing/suit/armor/vest/blueshift
	name = "research division armored vest"
	desc = "A synthetic armor vest. This one is marked with a hazard markings and 'RESEARCH DIVISION SECURITY' tag."
	icon = 'mods/loadout_items/icons/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/loadout_items/icons/onmob_suit.dmi')
	icon_state = "blueshift_armor"

/*
Armor Patches, covers, ect
*/

/obj/item/clothing/accessory/helmet_cover/black
	name = "black cover"
	desc = "A fabric cover for armored helmets. This one is flat black."
	icon_override = 'mods/loadout_items/icons/obj_accessory.dmi'
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	icon_state = "black_cover"
	accessory_icons = list(slot_tie_str = 'mods/loadout_items/icons/onmob_accessory.dmi', slot_head_str = 'mods/loadout_items/icons/onmob_accessory.dmi')

/obj/item/clothing/accessory/helmet_cover/scp_cover
	name = "SCP cover"
	desc = "A fabric cover for armored helmets. This one has SCP's colors."
	icon_override = 'mods/loadout_items/icons/obj_accessory.dmi'
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	icon_state = "scp_cover"
	accessory_icons = list(slot_tie_str = 'mods/loadout_items/icons/onmob_accessory.dmi', slot_head_str = 'mods/loadout_items/icons/onmob_accessory.dmi')

/obj/item/clothing/accessory/armor_tag/scp
	name = "SCP tag"
	desc = "An armor tag with the words SECURITY CORPORATE PERSONAL printed in red lettering on it."
	icon_override = 'mods/loadout_items/icons/onmob_accessory.dmi'
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	icon_state = "scp_tag"
	accessory_icons = list(slot_tie_str = 'mods/loadout_items/icons/onmob_accessory.dmi', slot_wear_suit_str = 'mods/loadout_items/icons/onmob_accessory.dmi')

/obj/item/clothing/accessory/armor_tag/zpci
	name = "\improper ZPCI tag"
	icon = 'mods/loadout_items/icons/obj_accessory.dmi'
	accessory_icons = list(slot_tie_str = 'mods/loadout_items/icons/onmob_accessory.dmi', slot_wear_suit_str = 'mods/loadout_items/icons/onmob_accessory.dmi')
	desc = "An armor tag with the words ZONE PROTECTION CONTROL INCORPORATED printed in blue lettering on it."
	icon_state = "zpci_tag"
	sprite_sheets = list(
		SPECIES_UNATHI = 'mods/loadout_items/icons/unathi/onmob_accessory_unathi.dmi'
		)

/obj/item/clothing/suit/armor/pcarrier/kms
	name = "EMT plate carrier"
	desc = "A lightweight white-red plate carrier vest. Denotes Komatsu Medical Servies employed EMT"
	icon = 'mods/loadout_items/icons/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/loadout_items/icons/onmob_suit.dmi')
	icon_state = "kms_pcarrier"
	item_state = "kms_pcarrier"
	valid_accessory_slots = list(ACCESSORY_SLOT_INSIGNIA, ACCESSORY_SLOT_ARMOR_CHEST, ACCESSORY_SLOT_ARMOR_ARMS, ACCESSORY_SLOT_ARMOR_LEGS, ACCESSORY_SLOT_ARMOR_STORAGE, ACCESSORY_SLOT_ARMOR_MISC)
	restricted_accessory_slots = list(ACCESSORY_SLOT_ARMOR_CHEST, ACCESSORY_SLOT_ARMOR_ARMS, ACCESSORY_SLOT_ARMOR_LEGS, ACCESSORY_SLOT_ARMOR_STORAGE)
	blood_overlay_type = "armorblood"
	flags_inv = 0
