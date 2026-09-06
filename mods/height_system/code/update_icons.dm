/mob/living/carbon/human/proc/human_update_offset(image/I, head = TRUE)
	if(mob_size == MOB_LARGE)
		return I // Don't apply height changes to large mobs
	if(!I)
		return I
	if(head)
		switch(src.height)
			if(HUMANHEIGHT_SHORTEST)
				I.pixel_y = -2
			if(HUMANHEIGHT_SHORT)
				I.pixel_y = -1
			if(HUMANHEIGHT_MEDIUM)
				I.pixel_y = 0
			if(HUMANHEIGHT_TALL)
				I.pixel_y = 1
			if(HUMANHEIGHT_TALLEST)
				I.pixel_y = 2
	else
		I.pixel_y = 0
	return I

/mob/living/carbon/human/proc/update_height(image/I)
	if(mob_size == MOB_LARGE)
		return I // Don't apply height changes to large mobs
	if(!I)
		return I

	// Static masks - Cut1 = torso, Cut2 = legs, Cut3 = lengthen torso, Cut4 = lengthen legs
	var/static/icon/cut_torso_mask = icon('icons/effects/cut.dmi', "Cut1")
	var/static/icon/cut_legs_mask = icon('icons/effects/cut.dmi', "Cut2")
	var/static/icon/lenghten_torso_mask = icon('icons/effects/cut.dmi', "Cut3")
	var/static/icon/lenghten_legs_mask = icon('icons/effects/cut.dmi', "Cut4")

	// Remove old filters
	I.remove_filter(list("Cut_Torso", "Cut_Legs", "Lenghten_Torso", "Lenghten_Legs"))

	// Apply displacement filters based on height
	switch(src.height)
		if(HUMANHEIGHT_SHORTEST)
			I.add_filter("Cut_Torso", 1, list("type" = "displace", "icon" = cut_torso_mask, "x" = 0, "y" = 0, "size" = 1))
			I.add_filter("Cut_Legs", 2, list("type" = "displace", "icon" = cut_legs_mask, "x" = 0, "y" = 0, "size" = 1))
		if(HUMANHEIGHT_SHORT)
			I.add_filter("Cut_Legs", 1, list("type" = "displace", "icon" = cut_legs_mask, "x" = 0, "y" = 0, "size" = 1))
		if(HUMANHEIGHT_TALL)
			I.add_filter("Lenghten_Legs", 1, list("type" = "displace", "icon" = lenghten_legs_mask, "x" = 0, "y" = 0, "size" = 1))
		if(HUMANHEIGHT_TALLEST)
			I.add_filter("Lenghten_Torso", 1, list("type" = "displace", "icon" = lenghten_torso_mask, "x" = 0, "y" = 0, "size" = 1))
			I.add_filter("Lenghten_Legs", 2, list("type" = "displace", "icon" = lenghten_legs_mask, "x" = 0, "y" = 0, "size" = 1))

	return I

/obj/item/clothing/accessory/get_mob_overlay(mob/user_mob, slot)
	var/image/ret = ..()
	if(istype(ret, /image) && ishuman(user_mob) && istype(loc, /obj/item/clothing))
		var/mob/living/carbon/human/H = user_mob
		if(!(body_location & HEAD))
			H.update_height(ret)
		H.human_update_offset(ret, FALSE) // sub-overlay:
	return ret
