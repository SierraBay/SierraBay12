/atom/movable
	///Оверлей для воды с планеты Титан. BOOL
	var/water_overlay = FALSE

//СНЯТИЕ ФИЛЬТРОВ ВОДЫ//

/atom/movable/proc/desetup_water_filter()
	return

/obj/item/desetup_water_filter()
	//animate(src, pixel_y = 0, time = 5, easing = SINE_EASING | EASE_IN)
	filters = null

/mob/living/desetup_water_filter()
	filters = null
	update_icons()

/mob/living/carbon/human/desetup_water_filter()
	for(var/i in overlays_standing)
		if(!i)
			continue
		if(islist(i))
			for(var/i_list in i)
				i_list:filters = null
		else
			i:filters = null
	update_icons()
