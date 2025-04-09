/obj/item/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical_storage.dmi'
	icon_state = "bottle-default"
	item_state = "atoxinbottle"
	randpixel = 7
	center_of_mass = "x=15;y=10"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;25;30;60"
	w_class = ITEM_SIZE_SMALL
	obj_flags = 0
	volume = 60
	matter = list(MATERIAL_GLASS = 500)
	/// The reagant the bottle will start with. If not set, the bottle spawns empty.
	var/preset_reagent
	/// Amount to add to the bottle, with the maximum amount being the bottle's `volume`. If not set, defaults to the bottle's total volume. Only used if `preset_reagent` is set.
	var/preset_amount

/obj/item/reagent_containers/glass/bottle/on_reagent_change()
	update_icon()


/obj/item/reagent_containers/glass/bottle/pickup(mob/user)
	..()
	update_icon()


/obj/item/reagent_containers/glass/bottle/dropped(mob/user)
	..()
	update_icon()


/obj/item/reagent_containers/glass/bottle/attack_hand()
	..()
	update_icon()


/obj/item/reagent_containers/glass/bottle/New()
	..()
	if (preset_reagent)
		icon_state = "bottle-4"
	else if (icon_state == "bottle-default")
		icon_state = "bottle-[rand(1,4)]"
	if (!preset_reagent)
		return
	if (!preset_amount)
		preset_amount = volume
	else
		preset_amount = min(preset_amount, volume)
	reagents.add_reagent(preset_reagent, preset_amount)
	update_icon()

/obj/item/reagent_containers/glass/bottle/on_update_icon()
	ClearOverlays()
	if (reagents.total_volume && (icon_state == "bottle-1" || icon_state == "bottle-2" || icon_state == "bottle-3" || icon_state == "bottle-4"))
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")
		var/percent = round((reagents.total_volume / volume) * 100)
		switch (percent)
			if (0 to 9)
				filling.icon_state = "[icon_state]--10"
			if (10 to 24)
				filling.icon_state = "[icon_state]-10"
			if (25 to 49)
				filling.icon_state = "[icon_state]-25"
			if (50 to 74)
				filling.icon_state = "[icon_state]-50"
			if (75 to 79)
				filling.icon_state = "[icon_state]-75"
			if (80 to 90)
				filling.icon_state = "[icon_state]-80"
			if (91 to INFINITY)
				filling.icon_state = "[icon_state]-100"
		filling.color = reagents.get_color()
		AddOverlays(filling)
	if (!is_open_container())
		var/image/lid = image(icon, src, "lid_bottle")
		AddOverlays(lid)

/obj/item/reagent_containers/glass/bottle/dye
	name = "dye bottle"
	desc = "A little bottle used to hold dye or food coloring, with a narrow bottleneck for handling small amounts."
	icon = 'icons/obj/chemical_storage.dmi'
	icon_state = "bottle-1"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = "1;2;5;10;15;25;30;60"
	var/datum/reagent/starting_reagent = /datum/reagent/dye
	var/starting_vol = 60


/obj/item/reagent_containers/glass/bottle/dye/Initialize()
	. = ..()
	reagents.add_reagent(starting_reagent, starting_vol)
	update_icon()


/obj/item/reagent_containers/glass/bottle/dye/polychromic
	name = "polychromic dye bottle"
	desc = "A little bottle used to hold dye or food coloring, with a narrow bottleneck for handling small amounts. \
			Outfitted with a tiny mechanism that can change the color of its contained dye, opening up infinite possibilities."


/obj/item/reagent_containers/glass/bottle/dye/polychromic/attack_self(mob/living/user)
	var/datum/reagent/heldDye = reagents.get_reagent(starting_reagent)
	if (!heldDye)
		to_chat(user, SPAN_WARNING("\The [src] isn't holding any dye!"))
		return
	var/new_color = input(user, "Choose the dye's new color.", "[name]") as color|null
	if (!new_color || !Adjacent(user))
		return
	to_chat(user, SPAN_NOTICE("The dye in \the [src] swirls and takes on a new color."))
	heldDye.color = new_color
	update_icon()


/obj/item/reagent_containers/glass/bottle/dye/polychromic/strong
	starting_reagent = /datum/reagent/dye/strong
	starting_vol = 15
