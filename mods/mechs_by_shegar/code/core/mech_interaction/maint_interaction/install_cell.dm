/mob/living/exosuit/proc/instal_power_cell(obj/item/tool, mob/user)
	if (!maintenance_protocols)
		USE_FEEDBACK_FAILURE("\The [src]'s maintenance protocols must be enabled to install \the [tool].")
		return TRUE
	if (body?.cell)
		USE_FEEDBACK_FAILURE("\The [src] already has \a [body.cell] installed.")
		return TRUE
	if (!user.unEquip(tool, body))
		FEEDBACK_UNEQUIP_FAILURE(user, tool)
		return TRUE
	body.cell = tool
	playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("\The [user] installs \a [tool] into \the [src]."),
		SPAN_NOTICE("You install \the [tool] into \the [src].")
	)
	return TRUE
