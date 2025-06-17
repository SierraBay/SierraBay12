/obj/item/haircomb/brush
	name = "hairbrush"
	desc = "A surprisingly decent hairbrush with a false wood handle and semi-soft bristles."
	w_class = ITEM_SIZE_SMALL
	slot_flags = null
	icon_state = "brush"
	item_state = "brush"
	var/brushing = FALSE

/obj/item/haircomb/brush/attack_self(mob/living/carbon/human/user)
	if(!user.incapacitated())
		var/datum/sprite_accessory/hair/hair_style = GLOB.hair_styles_list[user.head_hair_style]
		if(hair_style.flags & VERY_SHORT)
			user.visible_message(SPAN_NOTICE("[user] just sort of runs \the [src] over their scalp."))
		else
			user.visible_message(SPAN_NOTICE("[user] meticulously brushes their hair with \the [src]."))

/obj/item/haircomb/brush/use_after(atom/A, mob/living/user as mob)
	if(brushing)
		return
	brushing = TRUE
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		var/cover = "hair"
		switch(H.get_species())
			if(SPECIES_VOX)          cover = "quills"
			if(SPECIES_RESOMI)       cover = "feathers"
			if(SPECIES_TAJARA)       cover = "fur"
			if(SPECIES_UNATHI)       cover = "scale"
			if(SPECIES_SKRELL)       cover = "skin"
			if(SPECIES_IPC)          cover = "body"
			if(SPECIES_DIONA)        cover = "foliage"

		if(do_after(user, 10, H))
			if(user.a_intent == I_HURT && cover != "skin" && cover != "body")
				user.visible_message(SPAN_WARNING("[user] brushes [H]'s <b>against</b> [cover] with \the [src]!"))
			else
				user.visible_message(SPAN_WARNING("<span class='notice'>[user] brushes [H]'s [cover] with \the [src].</span>"))

	brushing = FALSE
