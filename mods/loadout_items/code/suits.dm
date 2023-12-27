/obj/item/clothing/suit/storage/drive_jacket
	name = "drive jacket"
	desc = "Stylish jacket for a real hero. Just like me."
	icon = 'maps/sierra/icons/obj/clothing/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi')
	icon_state = "drive_jacket"
	item_state = "drive_jacket"

/obj/item/clothing/suit/storage/toggle/the_jacket
	name = "the jacket"
	desc = "Old fashioned jacket. For lonely ride across southern city. Or for working on hotline may be?"
	icon = 'maps/sierra/icons/obj/clothing/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi')
	icon_state = "the_jacket"
//	icon_open = "the_jacket_open"
//	icon_closed = "the_jacket"

/obj/item/clothing/suit/storage/leon_jacket
	name = "patterned leather jacket"
	desc = "A black leather jacket wit some bizarre patterns."
	icon = 'maps/sierra/icons/obj/clothing/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi')
	icon_state = "leon_jacket"
	item_state = "leon_jacket"

/obj/item/clothing/suit/storage/brand_jacket
	name = "blue brand jacket"
	desc = "What a fiery coloration."
	icon = 'maps/sierra/icons/obj/clothing/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi')
	icon_state = "brand_jacket"
	item_state = "brand_jacket"

/obj/item/clothing/suit/storage/brand_orange_jacket
	name = "orange brand jacket"
	desc = "What a fiery coloration."
	icon = 'maps/sierra/icons/obj/clothing/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi')
	icon_state = "brand_orange_jacket"
	item_state = "brand_orange_jacket"

/obj/item/clothing/suit/storage/brand_rjacket
	name = "red brand jacket"
	desc = "What a fiery coloration."
	icon = 'maps/sierra/icons/obj/clothing/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi')
	icon_state = "brand_rjacket"
	item_state = "brand_rjacket"

/obj/item/clothing/suit/storage/hooded/faln_jacket
	name = "faln jacket"
	desc = "A very special piece of sports apparel, this jacket is warm, completely water and wind proof, and provides the air circulation through the membrane in its inner shell."
	icon = 'maps/sierra/icons/obj/clothing/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi')
	icon_state = "papaleroy_faln_jacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	action_button_name = "Toggle Hood"
	hoodtype = /obj/item/clothing/head/faln_jacket_hood

/obj/item/clothing/head/faln_jacket_hood
	name = "faln jacket hood"
	desc = "A hood attached to a faln jacket hood."
	icon = 'maps/sierra/icons/obj/clothing/obj_suit.dmi'
	item_icons = list(slot_head_str = 'maps/sierra/icons/mob/onmob/onmob_suit.dmi')
	icon_state = "papaleroy_faln_jacket_hood"
	body_parts_covered = HEAD
	flags_inv = HIDEEARS | BLOCKHAIR
