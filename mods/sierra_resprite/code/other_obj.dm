
/obj/machinery/jukebox/old
	icon = 'mods/sierra_resprite/icons/jukebox.dmi'
	icon_state = "jukebox2"

/obj/machinery/jukebox/custom_tape/old
	icon = 'mods/sierra_resprite/icons/jukebox.dmi'
	icon_state = "jukebox2"

/obj/item/boombox
	icon = 'mods/sierra_resprite/icons/boombox.dmi'
	icon_state = "off"

/obj/structure/undies_wardrobe
	name = "underwear vendor"
	icon = 'mods/sierra_resprite/icons/other.dmi'
	icon_state = "und_vend"

/obj/item/inflatable_duck
	icon_state = "inflatable"
	item_state = "inflatable"
	icon = 'mods/sierra_resprite/icons/other.dmi'
	slot_flags = SLOT_BELT

/obj/structure/flora/pottedplant
	icon = 'mods/sierra_resprite/icons/plants.dmi'

/obj/item/flora/pottedplantsmall
	icon = 'mods/sierra_resprite/icons/plants.dmi'



/obj/item/storage/box/donut
	icon = 'mods/sierra_resprite/icons/donutbox.dmi'
	icon_state = "donutbox"
	name = "donut box"
	contents_allowed = list(/obj/item/reagent_containers/food/snacks/donut)
	foldable = /obj/item/stack/material/cardboard

	startswith = list(/obj/item/reagent_containers/food/snacks/donut/normal = 6)

/obj/item/storage/box/donut/on_update_icon()
	ClearOverlays()
	var/i = 0
	for(var/obj/item/reagent_containers/food/snacks/donut/D in contents)
		var/image/I = image('mods/sierra_resprite/icons/donutbox.dmi', "[i][D.overlay_state]")
		if(D.overlay_state == "box-donut1")
			I.color = D.filling_color
		AddOverlays(I)
		i++

/obj/item/storage/box/donut/Initialize(loc, ...)
	. = ..()
	for(var/obj/item/reagent_containers/food/snacks/donut/D in contents)
		if(rand(1,6) == 1)
			D.reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 3)
	update_icon()


/obj/item/storage/box/donut/empty
	startswith = null

/obj/structure/bedsheetbin
	icon = 'mods/sierra_resprite/icons/other.dmi'
	icon_state = "linenbin-full"
