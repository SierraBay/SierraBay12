/obj/structure/heavy_vehicle_frame/proc/sensors_install(tool, mob/living/user)
	if (head)
		USE_FEEDBACK_FAILURE("\The [src] already has \a [head] installed.")
		return TRUE
	if (!install_component(tool, user))
		return TRUE
	head = tool
	update_icon()
	return TRUE
