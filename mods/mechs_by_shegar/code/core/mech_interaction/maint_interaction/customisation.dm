/mob/living/exosuit/proc/mech_customization(obj/item/tool, mob/user)
	var/obj/item/device/kit/mech/paint = tool
	var/obj/item/mech_component/choosed_part = show_radial_menu(user, src, parts_list_images, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if(!choosed_part || !paint)
		return
	choosed_part.decal = paint.current_decal
	update_icon()
	user.visible_message(
		SPAN_NOTICE("\The [user] opens \the [tool] and spends some quality time customising \the [src]."),
		SPAN_NOTICE("You open \the [tool] and spend some quality time customising \the [src].")
	)
	return TRUE
