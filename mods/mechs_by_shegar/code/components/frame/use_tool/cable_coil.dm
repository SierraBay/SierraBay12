/obj/structure/heavy_vehicle_frame/proc/cable_coil_interaction(obj/item/stack/cable_coil/cable, mob/living/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("Понятия не имею как обслуживать меха."))
		return
	if (is_wired)
		USE_FEEDBACK_FAILURE("Проводка уже установлена.")
		return TRUE
	if (!cable.can_use(10))
		USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 10, "to wire \the [src].")
		return TRUE
	playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("\The [user] has started wiring \the [src]."),
		SPAN_NOTICE("You have started wiring \the [src].")
	)
	if (!user.do_skilled(3 SECONDS, SKILL_ELECTRICAL, src) || !user.use_sanity_check(src, cable))
		return TRUE
	if (is_wired)
		USE_FEEDBACK_FAILURE("\The [src] is already wired.")
		return TRUE
	if (!cable.use(10))
		USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 10, "to wire \the [src].")
		return TRUE
	playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
	is_wired = FRAME_WIRED
	update_icon()
	user.visible_message(
		SPAN_NOTICE("\The [user] has wired \the [src]."),
		SPAN_NOTICE("The wiring has been successfully installed in \the [src].")
	)
	return TRUE
