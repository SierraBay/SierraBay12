///Вызывается при изменении
/turf/simulated/floor/exoplanet/titan_water/proc/update_filters_for_contents()
	for(var/atom/movable/movable_atom in contents)
		movable_atom.update_water_filter(mask_icon_state)

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
