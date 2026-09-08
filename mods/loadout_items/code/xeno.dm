// Alien clothing

// Skrell clothing

// Коммент от Колеса: если по какой-то причине у вас не отображается вещь в нужной вкладке лодаута, почекайте
// её в других вкладках. Если отображается не там, где нужно, поищите в коркоде определенные флаги сортировки.
// У меня например пришлось брать из коркода sort_category = "Xenowear"
/datum/gear/suit/skrell_robe
	display_name = "(Skrell) Skrellian robe"
	path = /obj/item/clothing/suit/skrell_robe
	sort_category = "Xenowear"
	cost = 1
	slot = slot_wear_suit

/datum/gear/uniform/skrell_clothes
	display_name = "(Skrell) Skrell clothes selection"
	path = /obj/item/clothing/under/
	sort_category = "Xenowear"

/datum/gear/uniform/skrell_clothes/New()
	..()
	var/skrell_clothes = list()
	skrell_clothes["Talum-Katish blue dress"] = /obj/item/clothing/under/uniform/skrell_talum_bluedress
	skrell_clothes["Talum-Katish green waist cloak"] = /obj/item/clothing/under/uniform/skrell_talum_greenwaistcloak
	skrell_clothes["Raskinta-Katish navy clothes"] = /obj/item/clothing/under/uniform/skrell_raskinta_navyclothes
	skrell_clothes["Malish-Katish blue office suit"] = /obj/item/clothing/under/uniform/skrell_malish_officesuit
	skrell_clothes["Talum-Katish white and red dress"] = /obj/item/clothing/under/uniform/skrell_talum_whitereddress
	skrell_clothes["Malish-Katish office suit with tie"] = /obj/item/clothing/under/uniform/skrell_malish_greentiedsuit
	skrell_clothes["Kanin-Katish sand-blue turtleneck"] = /obj/item/clothing/under/uniform/skrell_kanin_sandblueturtleneck
	skrell_clothes["Kanin-Katish orange-cyan uniform"] = /obj/item/clothing/under/uniform/skrell_kanin_orangecyanuniform
	skrell_clothes["Kanin-Katish yellow-black costume"] = /obj/item/clothing/under/uniform/skrell_kanin_yellowblackcostume
	skrell_clothes["Malish-Katish green office suit with suspenders"] = /obj/item/clothing/under/uniform/skrell_malish_greenofficesuit
	skrell_clothes["Raskinta-Katish red clothes"] = /obj/item/clothing/under/uniform/skrell_raskinta_redclothes
	skrell_clothes["Skrellian diving suit"] = /obj/item/clothing/under/uniform/skrell_skrellian_divingsuit
	gear_tweaks += new/datum/gear_tweak/path(skrell_clothes)



// Skrell outfits
/obj/item/clothing/suit/skrell_robe
	name = "Skrellian robe"
	desc = "Skrellian robe, worn by Qerr-Katish."
	icon = 'mods/loadout_items/icons/skrell/obj_skrell_robe.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/loadout_items/icons/skrell/onmob_skrell_robe.dmi')
	icon_state = "skrell_robe"


// Skrell outfits


/obj/item/clothing/under/uniform/skrell_talum_bluedress
	name = "Talum-Katish blue dress"
	desc = "Talum's blue dress, seems luminous, it's light and pleasant to the touch. The dress has a purple cape on the shoulders."
	icon = 'mods/loadout_items/icons/skrell/obj_under_skrell.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/skrell/onmob_under_skrell.dmi')
	icon_state = "talum_bluedress_s"
	item_state = "talum_bluedress_s"
	worn_state = "talum_bluedress"


/obj/item/clothing/under/uniform/skrell_talum_greenwaistcloak
	name = "Talum-Katish green waist cloak"
	desc = "Talum's white-green clothes with the translucent veil at the waist."
	icon = 'mods/loadout_items/icons/skrell/obj_under_skrell.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/skrell/onmob_under_skrell.dmi')
	icon_state = "talum_greenwaistcloak_s"
	item_state = "talum_greenwaistcloak_s"
	worn_state = "talum_greenwaistcloak"


/obj/item/clothing/under/uniform/skrell_raskinta_navyclothes
	name = "Raskinta-Katish navy clothes"
	desc = "Raskinta's navy clothes. Has no Qarr-Morr'Kon markings, and pretty flexible!"
	icon = 'mods/loadout_items/icons/skrell/obj_under_skrell.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/skrell/onmob_under_skrell.dmi')
	icon_state = "raskinta_navyclothes_s"
	item_state = "raskinta_navyclothes_s"
	worn_state = "raskinta_navyclothes"



/obj/item/clothing/under/uniform/skrell_malish_officesuit
	name = "Malish-Katish blue office suit"
	desc = "Malish's office suit, light top, dark bottom, and some glowing purple-teal jewelry."
	icon = 'mods/loadout_items/icons/skrell/obj_under_skrell.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/skrell/onmob_under_skrell.dmi')
	icon_state = "malish_officesuit_s"
	item_state = "malish_officesuit_s"
	worn_state = "malish_officesuit"


/obj/item/clothing/under/uniform/skrell_talum_whitereddress
	name = "Talum-Katish white and red dress"
	desc = "Talum's white-red dress. The sparkling red skirt is attached to one of the legs. It looks unusual."
	icon = 'mods/loadout_items/icons/skrell/obj_under_skrell.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/skrell/onmob_under_skrell.dmi')
	icon_state = "talum_whitereddress_s"
	item_state = "talum_whitereddress_s"
	worn_state = "talum_whitereddress"



/obj/item/clothing/under/uniform/skrell_malish_greentiedsuit
	name = "Malish-Katish office suit with tie"
	desc = "Malish's office suit, light top, green bottom, and a nice-looking green tie that barely touches the neck, made of soft material."
	icon = 'mods/loadout_items/icons/skrell/obj_under_skrell.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/skrell/onmob_under_skrell.dmi')
	icon_state = "malish_greentiedsuit_s"
	item_state = "malish_greentiedsuit_s"
	worn_state = "malish_greentiedsuit"


/obj/item/clothing/under/uniform/skrell_kanin_sandblueturtleneck
	name = "Kanin-Katish sand-blue turtleneck"
	desc = "Comfortable Kanin's clothing that has padded inserts and cleverly stitched fabric, allowing the wearer's skin to breathe."
	icon = 'mods/loadout_items/icons/skrell/obj_under_skrell.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/skrell/onmob_under_skrell.dmi')
	icon_state = "kanin_sandblueturtleneck_s"
	item_state = "kanin_sandblueturtleneck_s"
	worn_state = "kanin_sandblueturtleneck"

/obj/item/clothing/under/uniform/skrell_kanin_orangecyanuniform
	name = "Kanin-Katish orange-cyan uniform"
	desc = "Lightweight, breathable uniform designed for work in non-traumatic conditions, providing its owner with ease of movement."
	icon = 'mods/loadout_items/icons/skrell/obj_under_skrell.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/skrell/onmob_under_skrell.dmi')
	icon_state = "kanin_orangecyanuniform_s"
	item_state = "kanin_orangecyanuniform_s"
	worn_state = "kanin_orangecyanuniform"


/obj/item/clothing/under/uniform/skrell_kanin_yellowblackcostume
	name = "Kanin-Katish yellow-black costume"
	desc = "Kanin's black and yellow suit is of high quality, the contrast of colors makes a highly qualified employee stand out. White helmet is not included!"
	icon = 'mods/loadout_items/icons/skrell/obj_under_skrell.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/skrell/onmob_under_skrell.dmi')
	icon_state = "kanin_yellowblackcostume_s"
	item_state = "kanin_yellowblackcostume_s"
	worn_state = "kanin_yellowblackcostume"

/obj/item/clothing/under/uniform/skrell_malish_greenofficesuit
	name = "Malish-Katish green office suit with suspenders"
	desc = "Malish's office suit, light top, black bottom, and a fancy lime-green thin veil above the belt."
	icon = 'mods/loadout_items/icons/skrell/obj_under_skrell.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/skrell/onmob_under_skrell.dmi')
	icon_state = "malish_greenofficesuit_s"
	item_state = "malish_greenofficesuit_s"
	worn_state = "malish_greenofficesuit"


/obj/item/clothing/under/uniform/skrell_raskinta_redclothes
	name = "Raskinta-Katish red clothes"
	desc = "Raskinta's red clothes. Has no Qarr-Morr'Kon markings, and pretty flexible!"
	icon = 'mods/loadout_items/icons/skrell/obj_under_skrell.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/skrell/onmob_under_skrell.dmi')
	icon_state = "raskinta_redclothes_s"
	item_state = "raskinta_redclothes_s"
	worn_state = "raskinta_redclothes"


/obj/item/clothing/under/uniform/skrell_skrellian_divingsuit
	name = "Skrellian diving suit"
	desc = "A highly detailed Skrellian diving suit. Found mainly among the inhabitants of the planets of the Empire."
	icon = 'mods/loadout_items/icons/skrell/obj_under_skrell.dmi'
	item_icons = list(slot_w_uniform_str = 'mods/loadout_items/icons/skrell/onmob_under_skrell.dmi')
	icon_state = "skrellian_divingsuit_s"
	item_state = "skrellian_divingsuit_s"
	worn_state = "skrellian_divingsuit"
