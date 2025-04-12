/obj/structure/heavy_vehicle_frame/proc/doubled_legs_install(obj/item/mech_component/doubled_legs/input_double_legs, mob/living/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("I dont know how work with mechs!"))
		return
	if (R_leg || L_leg)
		USE_FEEDBACK_FAILURE("У \The [src] уже установлены ноги.")
		return TRUE
	if(!input_double_legs.R_stored_leg.motivator || !input_double_legs.L_stored_leg.motivator)
		USE_FEEDBACK_FAILURE("Какая-либо из конечностей не готова к установке.")
		return TRUE
	if (!install_component(input_double_legs, user))
		return TRUE
	R_leg =	input_double_legs.R_stored_leg
	L_leg = input_double_legs.L_stored_leg
	update_parts_images()
	update_icon()
	return TRUE
