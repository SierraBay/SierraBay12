/mob/living/exosuit/proc/mech_customization(obj/item/tool, mob/user)
	var/obj/item/device/kit/mech/paint = tool
	for (var/obj/item/mech_component/component in list(head,body, L_arm, R_arm, L_leg, R_leg))
		component.decal = paint.current_decal
	if(paint.new_icon_file)
		icon = paint.new_icon_file
	update_icon()
	user.visible_message(
		SPAN_NOTICE("\The [user] opens \the [tool] and spends some quality time customising \the [src]."),
		SPAN_NOTICE("You open \the [tool] and spend some quality time customising \the [src].")
	)
	return TRUE
