/obj/structure/heavy_vehicle_frame/proc/arms_install(obj/item/mech_component/manipulators/input_arm, mob/living/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("I dont know how work with mechs!"))
		return
	if (input_arm.side == LEFT && L_arm)
		USE_FEEDBACK_FAILURE("У \The [src] уже установлена левый манипулятор .")
		return TRUE
	if (input_arm.side == RIGHT && R_arm)
		USE_FEEDBACK_FAILURE("У \The [src] aуже установлен правый манипулятор.")
		return TRUE
	if (!install_component(input_arm, user))
		return TRUE
	if(input_arm.side == LEFT)
		L_arm = input_arm
	if(input_arm.side == RIGHT)
		R_arm = input_arm
	update_icon()
	return TRUE
