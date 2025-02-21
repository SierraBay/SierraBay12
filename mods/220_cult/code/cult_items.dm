/obj/item/reagent_containers/glass/bucket/wood/cult/New()
	..()
	reagents.add_reagent(/datum/reagent/hell_water, 120)
	update_icon()


/obj/item/device/flashlight/flashdark/stone
	name = "hellstone shard"
	desc = "The stone is blacker than the night itself, it seems to dim all the light around."
	icon = 'mods/220_cult/icons/obj/hellstone.dmi'
	icon_state = "hellstone"
	item_state = "electronic"
	activation_sound = null

/obj/item/clothing/glasses/tacgoggles/cult
	name = "hell goggles"
	desc = "Its look equally funny and frightening."
	item_icons = list(slot_glasses_str = 'mods/220_cult/icons/mob/onmob/onmob_eyes.dmi')
	icon = 'mods/220_cult/icons/obj/clothing/obj_eyes.dmi'
	icon_state = "hg"
	item_state = "hg"
	off_state = "hg_off"
	darkness_view = 5

/obj/item/clothing/glasses/tacgoggles/cult/Initialize()
	. = ..()
	overlay = GLOB.global_hud.thermal
