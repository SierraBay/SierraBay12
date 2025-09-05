/obj/structure/heavy_vehicle_frame/proc/sensors_install(tool, mob/living/user)
	if(!tags_check(tool, user))
		to_chat(user, "Эта часть не совместима с уже установленными.")
		return FALSE
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("Понятия не имею как обслуживать меха."))
		return
	if (head)
		USE_FEEDBACK_FAILURE("Сенсоры уже установлены.")
		return TRUE
	if (!install_component(tool, user))
		return TRUE
	head = tool
	update_parts_images()
	update_icon()
	return TRUE
