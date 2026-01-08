//УСТАНОВКА ФИЛЬТРОВ ВОДЫ//
/atom/proc/setup_water_filter(mask_icon_state)
	return

/obj/item/setup_water_filter(mask_icon_state)
	var/icon/mask_icon = icon('mods/anomaly/icons/water_mask_small.dmi', mask_icon_state)
	filters = filter(type="alpha", icon = mask_icon)
	//animate(src,transform = matrix().Translate(0, 10), time = 1 SECOND, easing = SINE_EASING)
	//animate(transform = matrix().Translate(0, -10), time = 1 SECOND, easing = SINE_EASING, loop = -1)

/obj/structure/setup_water_filter(mask_icon_state)
	var/icon/mask_icon = icon('mods/anomaly/icons/water_mask_small.dmi', mask_icon_state)
	filters = filter(type="alpha", icon = mask_icon, name = "water_overlay")

/mob/living/setup_water_filter(mask_icon_state)
	var/icon/mask_icon = icon('mods/anomaly/icons/water_mask_small.dmi', mask_icon_state)
	filters += filter(type = "alpha", icon = mask_icon, x = 0, name = "water_overlay")
	update_icons()

/mob/living/carbon/human/setup_water_filter(mask_icon_state)
	var/icon/mask_icon = icon('mods/anomaly/icons/water_mask_small.dmi', mask_icon_state)
	filters += filter(type = "alpha", icon = mask_icon, x = 0, name = "water_overlay")
	update_icons()

/mob/living/carbon/human/adherent/setup_water_filter(mask_icon_state)
	var/icon/mask_icon = icon('mods/anomaly/icons/water_mask_small.dmi', mask_icon_state)
	filters += filter(type = "alpha", icon = mask_icon, x = 0, name = "water_overlay")
	update_icons()

/mob/living/carbon/human/nabber/setup_water_filter(mask_icon_state)
	var/icon/mask_icon = icon('mods/anomaly/icons/water_mask_big.dmi', mask_icon_state)
	filters += filter(type = "alpha", icon = mask_icon, x = 0, name = "water_overlay")
	update_icons()
