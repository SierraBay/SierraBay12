/obj/item/clothing/under/skirt/longskirt
	name = "Long skirt"
	desc = "A slimming, long jumpskirt."
	icon = 'mods/utility_items/icons/onmob_under.dmi'
	item_icons = list(
		slot_w_uniform_str = 'mods/utility_items/icons/onmob_under.dmi'
	)
	icon_state = "skirt_long"
	item_state = "skirt_long"
	worn_state = "skirt_long"

/obj/item/clothing/accessory/glassesmod/hud/medical/New()
	. = ..()
	desc = "An attachable medical HUD for ballistic goggles."
