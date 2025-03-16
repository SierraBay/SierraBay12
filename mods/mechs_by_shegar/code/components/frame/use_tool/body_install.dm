/obj/structure/heavy_vehicle_frame/proc/body_install(tool, mob/living/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("I dont know how work with mechs!"))
		return
	if (body)
		USE_FEEDBACK_FAILURE("У \The [src] уже установлено \a [body] тело.")
		return TRUE
	if (!install_component(tool, user))
		return TRUE
	body = tool
	update_parts_images()
	update_icon()
	return TRUE
