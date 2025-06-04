/obj/effect/smoke/hookah
	name = "smoke"
	icon_state = "smoke"
	icon = 'mods/utility_items/icons/smoke_hookah.dmi'
	opacity = 0
	anchored = FALSE
	mouse_opacity = 0
	amount = 4.0
	time_to_live = 40
	pixel_x = 0
	pixel_y = 0

/datum/effect/smoke_spread/hookah
	smoke_type = /obj/effect/smoke/hookah

/singleton/hierarchy/supply_pack/galley/hookah
	name = "Bar - Hookah"
	contains = list(
		/obj/item/hookah,
		/obj/item/storage/box/large/coal = 2
	)
	cost = 20
	containername = "Hookah crate"
