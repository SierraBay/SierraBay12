/atom/movable/proc/update_water_filter(mask_icon_state)
	return

/obj/item/update_water_filter()
	if(!istitanwater(loc))
		desetup_water_filter()

/mob/living/update_water_filter(mask_icon_state)
	if(water_overlay)
		desetup_water_filter()
	setup_water_filter(mask_icon_state)

/mob/living/carbon/human/update_water_filter(mask_icon_state)
	if(water_overlay)
		desetup_water_filter()
	if(!lying)
		setup_water_filter(mask_icon_state)
