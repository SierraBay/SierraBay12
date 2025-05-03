/obj/structure/heavy_vehicle_frame/proc/legs_install(obj/item/mech_component/propulsion/input_leg, mob/living/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("I dont know how work with mechs!"))
		return
	if (input_leg.side == LEFT && L_leg)
		USE_FEEDBACK_FAILURE("У \The [src] уже установлена левая нога.")
		return TRUE
	if (input_leg.side == RIGHT && R_leg)
		USE_FEEDBACK_FAILURE("У \The [src] уже установлена правая нога.")
		return TRUE
	if (!install_component(input_leg, user))
		return TRUE
	if(input_leg.side == LEFT)
		L_leg = input_leg
	if(input_leg.side == RIGHT)
		R_leg = input_leg
	update_icon()
	return TRUE
