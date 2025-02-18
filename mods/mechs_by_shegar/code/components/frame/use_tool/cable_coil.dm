/obj/structure/heavy_vehicle_frame/proc/cable_coil_interaction(obj/item/stack/cable_coil/cable, mob/living/user)
	if (is_wired)
		USE_FEEDBACK_FAILURE("У \The [src] уже установлена проводка.")
		return TRUE
	if (!cable.can_use(10))
		USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 10, "to wire \the [src].")
		return TRUE
	playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("\The [user] начал устанавливать проводку в \the [src]."),
		SPAN_NOTICE("Вы начали устанавливать проводку в \the [src].")
	)
	if (!user.do_skilled(3 SECONDS, SKILL_ELECTRICAL, src) || !user.use_sanity_check(src, cable))
		return TRUE
	if (is_wired)
		USE_FEEDBACK_FAILURE("У \The [src] уже установлена проводка.")
		return TRUE
	if (!cable.use(10))
		USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 10, "to wire \the [src].")
		return TRUE
	playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
	is_wired = FRAME_WIRED
	update_icon()
	user.visible_message(
		SPAN_NOTICE("\The [user] установил проводку в \the [src]."),
		SPAN_NOTICE("Проводка успешно установлена в  \the [src].")
	)
	return TRUE
