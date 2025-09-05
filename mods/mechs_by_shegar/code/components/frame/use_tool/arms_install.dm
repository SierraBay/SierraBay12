/obj/structure/heavy_vehicle_frame/proc/arms_install(obj/item/mech_component/manipulators/input_arm, mob/living/user)
	if(!tags_check(input_arm, user))
		to_chat(user, "Эта часть не совместима с уже установленными.")
		return FALSE
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("Понятия не имею как обслуживать меха."))
		return
	if (input_arm.side == LEFT && L_arm)
		USE_FEEDBACK_FAILURE("Левая рука уже установлена.")
		return TRUE
	if (input_arm.side == RIGHT && R_arm)
		USE_FEEDBACK_FAILURE("Правая рука уже установлена.")
		return TRUE
	if (!install_component(input_arm, user))
		return TRUE
	if(input_arm.side == LEFT)
		L_arm = input_arm
	if(input_arm.side == RIGHT)
		R_arm = input_arm
	update_icon()
	return TRUE
