/obj/structure/heavy_vehicle_frame/proc/body_install(tool, mob/living/user)
	if(!tags_check(tool, user))
		to_chat(user, "Эта часть не совместима с уже установленными.")
		return FALSE
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("Понятия не имею как обслуживать меха."))
		return
	if (body)
		USE_FEEDBACK_FAILURE("Тело уже установлено.")
		return TRUE
	if (!install_component(tool, user))
		return TRUE
	body = tool
	update_parts_images()
	update_icon()
	return TRUE
