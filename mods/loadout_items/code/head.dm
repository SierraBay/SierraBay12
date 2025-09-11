// Unathi garnmaents

/obj/item/clothing/head/cap/sec
	name = "big security cap"
	desc = "A security cap. This one pretty big."
	icon = 'mods/loadout_items/icons/obj_head.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/loadout_items/icons/onmob_head.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'mods/loadout_items/icons/onmob_head.dmi'
	)
	icon_state = "unathi_seccap"
	item_state = "unathi_seccap"
	species_restricted = list(SPECIES_UNATHI)
	flags_inv = BLOCKHEADHAIR

/obj/item/clothing/head/cap/desert
	name = "Suncap"
	desc = "A big suncap designed for use in the desert. Unathi use it to withstand scorhing heat rays when \"Burning Mother\" at it's zenith, something that their heads cannot handle. This one features foldable flaps to keep back of the neck protected. It's too big to fit anyone, but unathi."
	icon = 'mods/loadout_items/icons/obj_head.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/loadout_items/icons/onmob_head.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'mods/loadout_items/icons/onmob_head.dmi'
	)
	icon_state = "unathi_suncap"
	item_state = "unathi_suncap"
	flags_inv = HIDEEARS|BLOCKHEADHAIR
	var/icon_state_up = "unathi_suncap_u"
	species_restricted  = list(SPECIES_UNATHI)
	body_parts_covered = HEAD

/obj/item/clothing/head/cap/desert/attack_self(mob/user as mob)
	if(icon_state == initial(icon_state))
		icon_state = icon_state_up
		item_state = icon_state_up
		to_chat(user, "You raise the ear flaps on the Suncap.")
	else
		icon_state = initial(icon_state)
		item_state = initial(icon_state)
		to_chat(user, "You lower the ear flaps on the Suncap.")

// Human headgarments

/obj/item/clothing/head/soft/colorable
	name = "Soft cap"
	desc = "A simple baseball soft cap without any special qualities"
	icon = 'mods/loadout_items/icons/obj_head.dmi'
	item_icons = list(
		slot_head_str = 'mods/loadout_items/icons/onmob_head.dmi'
	)
	icon_state = "cprescap"
	item_state = "cprescap"

/obj/item/clothing/head/soft/on_update_icon()
	. = ..()
	item_state = initial(item_state) + (flipped ? "_flipped" : "")

/obj/item/clothing/head/beret/kms
	name = "\improper KMS beret"
	desc = "A white beret denoting KMS employee."
	icon = 'mods/loadout_items/icons/obj_head.dmi'
	item_icons = list(
		slot_head_str = 'mods/loadout_items/icons/onmob_head.dmi'
	)
	icon_state = "kmsberet"
	item_state = "kmsberet"

/obj/item/clothing/head/bighat
	name = "brown wide hat"
	desc = "A brown hat with a wide brim and low crown. Yeehaw!"
	icon = 'mods/loadout_items/icons/obj_head.dmi'
	item_icons = list(
		slot_head_str = 'mods/loadout_items/icons/onmob_head.dmi'
	)

	icon_state = "cowboy_wide"
	item_state = "cowboy_wide"

/obj/item/clothing/head/bighat/kgbhat
	name = "black-red hat"
	desc = "A black hat with a wide brim and low crown with red additions"
	icon_state = "kgbhat"
	item_state = "kgbhat"

/obj/item/clothing/head/bighat/gunfighter
	name = "white stetson hat"
	desc = "A white hat with a slightly wide brim and high crown"
	icon_state = "gunfighter"
	item_state = "gunfighter"

/obj/item/clothing/head/bighat/lawdog
	name = "black stetson hat"
	desc = "A black hat with a slightly wide brim and high crown"
	icon_state = "lawdog"
	item_state = "lawdog"

/obj/item/clothing/head/bighat/black
	name = "black wide hat"
	desc = "A black hat with a wide brim and low crown."
	icon_state = "blackhat"
	item_state = "blackhat"
