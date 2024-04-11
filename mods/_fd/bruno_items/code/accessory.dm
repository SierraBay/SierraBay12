/obj/item/clothing/accessory/suspenders/beltchain
	name = "steel chain"
	desc = "Steel chain with a carabiner, designed to be worn on a belt."
	icon = 'mods/bruno_items/icons/onmob_accessories.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/bruno_items/icons/onmob_accessories.dmi')
	icon_state = "belt_chain"
	item_state = "belt_chain"

/obj/item/clothing/accessory/scarf/coolscarf
	name = "large scarf"
	desc = "A massive scarf made of durable fabric. Has several fastenings for attaching to outer clothing or voidsuits."
	icon = 'mods/bruno_items/icons/onmob_accessories.dmi'
	accessory_icons = list(
		slot_w_uniform_str = 'mods/bruno_items/icons/onmob_accessories.dmi',
		slot_wear_suit_str = 'mods/bruno_items/icons/onmob_accessories.dmi')
	item_icons = list(
		slot_wear_mask_str = 'mods/bruno_items/icons/onmob_mask.dmi')
	icon_state = "coolscarf"
	item_state = "coolscarf"
	slot = ACCESSORY_SLOT_INSIGNIA
	slot_flags = SLOT_MASK | SLOT_TIE

/obj/item/clothing/accessory/scarf/shemagh
	name = "Shemagh"
	desc = "A thick bandana designed to be worn around the neck. Has several fastenings for attaching to outer clothing or voidsuits."
	icon = 'mods/bruno_items/icons/onmob_accessories.dmi'
	accessory_icons = list(
		slot_w_uniform_str = 'mods/bruno_items/icons/onmob_accessories.dmi',
		slot_wear_suit_str = 'mods/bruno_items/icons/onmob_accessories.dmi')
	item_icons = list(
		slot_wear_mask_str = 'mods/bruno_items/icons/onmob_mask.dmi')
	icon_state = "shemagh"
	item_state = "shemagh"
	slot = ACCESSORY_SLOT_INSIGNIA
	slot_flags = SLOT_MASK | SLOT_TIE

/obj/item/clothing/accessory/scarf/shemagh/get_mob_overlay(mob/user_mob, slot)
    . = ..()

    if(istype(loc, /obj/item/clothing/suit/space/void/exploration))
        return overlay_image(accessory_icons[slot], "shemagh_fat", color, RESET_COLOR)

/obj/item/clothing/accessory/scarf/shouldercape
	name = "shoulder cape"
	desc = "A shoulder cape, often used to show the rank or specialization of the wearer. Has several fastenings for attaching to outer clothing or voidsuits."
	icon = 'mods/bruno_items/icons/onmob_accessories.dmi'
	accessory_icons = list(
		slot_w_uniform_str = 'mods/bruno_items/icons/onmob_accessories.dmi',
		slot_wear_suit_str = 'mods/bruno_items/icons/onmob_accessories.dmi')
	item_icons = list(
		slot_wear_mask_str = 'mods/bruno_items/icons/onmob_mask.dmi')
	icon_state = "shoulder_cape"
	item_state = "shoulder_cape"
	slot = ACCESSORY_SLOT_INSIGNIA
	slot_flags = SLOT_MASK | SLOT_TIE

/obj/item/clothing/accessory/scarf/shouldercape/get_mob_overlay(mob/user_mob, slot)
	. = ..()

	if(istype(loc, /obj/item/clothing/suit/space/void/exploration) || istype(loc, /obj/item/clothing/suit/space/void/atmos/alt/sol/expo) )
		return overlay_image(accessory_icons[slot], "shoulder_cape_fat", color, RESET_COLOR)
