/obj/structure/heavy_vehicle_frame/proc/body_install(tool, mob/living/user)
	if (body)
		USE_FEEDBACK_FAILURE("У \The [src] уже установлено \a [body] тело.")
		return TRUE
	if (!install_component(tool, user))
		return TRUE
	body = tool
	update_icon()
	return TRUE
