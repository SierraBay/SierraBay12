/obj/item/spacecash
	icon = 'mods/utility_items/icons/money.dmi'
	on_turf_icon = 'mods/on_floor_icon/icons/money.dmi'

/obj/item/spacecash/bundle/
	icon = 'mods/utility_items/icons/money.dmi'

/obj/item/spacecash/bundle/update_onturf_icon_status()
	if(on_turf_icon)
		if(isturf(loc))
			icon = on_turf_icon
			on_update_icon(TRUE)
		else
			icon = initial(icon)
			on_update_icon(FALSE)

/obj/item/spacecash/bundle/on_update_icon(onturf = FALSE)
	ClearOverlays()
	var/list/images = src.getMoneyImages()
	var/icon_type = 'mods/utility_items/icons/money.dmi'
	if(onturf)
		icon_type = 'mods/on_floor_icon/icons/money.dmi'
	for(var/A in images)
		var/image/banknote = image(icon_type, A)
		banknote.SetTransform(
			rotation = pick(-45, -27.5, 0, 0, 0, 0, 0, 0, 0, 27.5, 45),
			offset_x = rand(-6, 6),
			offset_y = rand(-4, 8)
		)
		AddOverlays(banknote)

	src.desc = "They are worth [worth] [GLOB.using_map.local_currency_name]."
	if(worth in denominations)
		src.SetName("[worth] [GLOB.using_map.local_currency_name]")
	else
		src.SetName("pile of [worth] [GLOB.using_map.local_currency_name]")
