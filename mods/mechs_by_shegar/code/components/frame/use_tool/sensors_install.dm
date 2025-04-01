/obj/structure/heavy_vehicle_frame/proc/sensors_install(tool, mob/living/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("I dont know how work with mechs!"))
		return
	if (head)
		USE_FEEDBACK_FAILURE("\The [src] already has \a [head] installed.")
		return TRUE
	if (!install_component(tool, user))
		return TRUE
	head = tool
	update_parts_images()
	update_icon()
	return TRUE
