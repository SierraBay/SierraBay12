/obj/structure/heavy_vehicle_frame/proc/screwdriver_interaction(obj/item/screwdriver/tool, mob/living/user) //Сборка меха
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("Понятия не имею как обслуживать меха."))
		return
	if (!(head && body && L_arm && R_arm && L_leg && R_leg))
		USE_FEEDBACK_FAILURE("Не хватает деталей, сборка невозможна.")
		return TRUE
	// Check for wiring.
	if (is_wired < FRAME_WIRED_ADJUSTED)
		if (is_wired == FRAME_WIRED)
			USE_FEEDBACK_FAILURE("Провода нужно закрепить кусачками перед сборкой.")
		else
			USE_FEEDBACK_FAILURE("Проведите проводку перед окончательной сборкой.")
		return TRUE
	// Check for basing metal internal plating.
	if (is_reinforced < FRAME_REINFORCED_WELDED)
		if (is_reinforced == FRAME_REINFORCED)
			USE_FEEDBACK_FAILURE("Закрутите внутреннюю обшивку гаечным ключом перед сборкой")
		else if (is_reinforced == FRAME_REINFORCED_SECURE)
			USE_FEEDBACK_FAILURE("Приварите внутреннюю обшивку сваркой перед сборкой.")
		else
			USE_FEEDBACK_FAILURE("Перед сборкой требуется установить внутреннюю обшивку.")
		return TRUE
	playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("\The [user] starts finishing \the [src] with \a [tool]."),
		SPAN_NOTICE("You start finishing \the [src] with \the [tool].")
		)
	if (!user.do_skilled((tool.toolspeed * 5) SECONDS, SKILL_DEVICES, src) || !user.use_sanity_check(src, tool))
		return TRUE
	// Check for basic components.
	if (!(head && body && L_arm && R_arm && L_leg && R_leg))
		USE_FEEDBACK_FAILURE("Не хватает деталей, сборка невозможна.")
		return TRUE
	// Check for wiring.
	if (is_wired < FRAME_WIRED_ADJUSTED)
		if (is_wired == FRAME_WIRED)
			USE_FEEDBACK_FAILURE("\The [src]'s wiring needs to be adjusted before you can complete it.")
		else
			USE_FEEDBACK_FAILURE("\The [src] needs to be wired before you can complete it.")
		return TRUE
	// Check for basing metal internal plating.
	if (is_reinforced < FRAME_REINFORCED_WELDED)
		if (is_reinforced == FRAME_REINFORCED)
			USE_FEEDBACK_FAILURE("\The [src]'s internal reinforcement needs to be secured before you can complete it.")
		else if (is_reinforced == FRAME_REINFORCED_SECURE)
			USE_FEEDBACK_FAILURE("\The [src]'s internal reinforcement needs to be welded before you can complete it.")
		else
			USE_FEEDBACK_FAILURE("\The [src] needs internal reinforcement before you can complete it.")
		return TRUE
	var/mob/living/exosuit/exosuit = new(get_turf(src), src)
	transfer_fingerprints_to(exosuit)
	playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("\The [user] finishes constructing \the [exosuit] with \a [tool]."),
		SPAN_NOTICE("You finish constructing \the [exosuit] with \the [tool].")
		)
	head = null
	body = null
	R_arm = null
	L_arm = null
	R_leg = null
	L_leg = null
	qdel(src)
	return TRUE
