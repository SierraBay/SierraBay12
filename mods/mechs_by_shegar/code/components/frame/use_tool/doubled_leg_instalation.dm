/obj/structure/heavy_vehicle_frame/proc/doubled_legs_install(obj/item/mech_component/doubled_legs/input_double_legs, mob/living/user)
	if(!tags_check(input_double_legs, user))
		to_chat(user, "Эта часть не совместима с уже установленными.")
		return FALSE
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("Понятия не имею как обслуживать меха."))
		return
	if (R_leg || L_leg)
		USE_FEEDBACK_FAILURE("Ноги уже установлены.")
		return FALSE
	if(!input_double_legs.R_stored_leg.motivator || !input_double_legs.L_stored_leg.motivator)
		USE_FEEDBACK_FAILURE("Какая-либо из конечностей не готова к установке.")
		return FALSE
	if (!install_component(input_double_legs, user))
		return FALSE
	R_leg =	input_double_legs.R_stored_leg
	L_leg = input_double_legs.L_stored_leg
	update_parts_images()
	update_icon()
	return TRUE
