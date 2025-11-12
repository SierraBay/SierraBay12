/atom/movable
	///Оверлей для воды с планеты Титан. BOOL
	var/water_overlay = FALSE

//СНЯТИЕ ФИЛЬТРОВ ВОДЫ//

/atom/movable/proc/desetup_water_filter()
	return

/obj/structure/desetup_water_filter()
	LAZYREMOVE(filters, filters["water_overlay"])

/obj/item/desetup_water_filter()
	//animate(src, pixel_y = 0, time = 5, easing = SINE_EASING | EASE_IN)
	LAZYREMOVE(filters, filters["water_overlay"])

/mob/living/desetup_water_filter()
	LAZYREMOVE(filters, filters["water_overlay"])
	update_icons()

/mob/living/carbon/human/desetup_water_filter()
	LAZYREMOVE(filters, filters["water_overlay"])
	update_icons()
