/obj/structure/heavy_vehicle_frame/proc/material_install(obj/item/stack/material/stack, mob/living/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("Понятия не имею как обслуживать меха."))
		return
	if (is_reinforced)
		USE_FEEDBACK_FAILURE("Обшивка уже установлена.")
		return TRUE
	if (stack.reinf_material) // Current code doesn't account for reinforced materials
		USE_FEEDBACK_FAILURE("этот Материал не подходит.")
		return TRUE
	if (!stack.can_use(10))
		USE_FEEDBACK_STACK_NOT_ENOUGH(stack, 10, "to reinforce \the [src].")
		return TRUE
	playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts reinforcing \the [src] with \a [stack]."),
		SPAN_NOTICE("You start reinforcing \the [src] with \the [stack].")
		)
	if (!user.do_skilled(3 SECONDS, SKILL_DEVICES, src) || !user.use_sanity_check(src, stack))
		return TRUE
	if (is_reinforced)
		USE_FEEDBACK_FAILURE("Обшивка уже установлена.")
		return TRUE
	if (!stack.use(10))
		USE_FEEDBACK_STACK_NOT_ENOUGH(stack, 10, "to reinforce \the [src].")
		return TRUE
	playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
	material = stack.material
	is_reinforced = FRAME_REINFORCED
	update_icon()
	user.visible_message(
		SPAN_NOTICE("\The [user] reinforces \the [src] with \a [stack]."),
		SPAN_NOTICE("You reinforce \the [src] with \the [stack].")
		)
	return TRUE
