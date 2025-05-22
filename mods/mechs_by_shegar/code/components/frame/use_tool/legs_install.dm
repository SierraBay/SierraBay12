/obj/structure/heavy_vehicle_frame/proc/legs_install(obj/item/mech_component/propulsion/input_leg, mob/living/user)
	if(!tags_check(input_leg, user))
		to_chat(user, "Эта часть не совместима с уже установленными.")
		return FALSE
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("Понятия не имею как обслуживать меха."))
		return
	if (input_leg.side == LEFT && L_leg)
		USE_FEEDBACK_FAILURE("Левая нога уже установлена.")
		return TRUE
	if (input_leg.side == RIGHT && R_leg)
		USE_FEEDBACK_FAILURE("Правая нога уже установлена.")
		return TRUE
	if (!install_component(input_leg, user))
		return TRUE
	if(input_leg.side == LEFT)
		L_leg = input_leg
	if(input_leg.side == RIGHT)
		R_leg = input_leg
	update_icon()
	return TRUE
