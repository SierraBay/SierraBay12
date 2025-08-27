/mob/living/exosuit/proc/deinstall_power_cell(obj/item/tool, mob/user)
	if (!maintenance_protocols)
		USE_FEEDBACK_FAILURE("Сперва включите протокол обслуживания.")
		return
	if (!body || !body.cell)
		USE_FEEDBACK_FAILURE("Батарея отсутствует.")
		return
	user.visible_message(SPAN_NOTICE("\The [user] starts removing \the [src]'s power cell with \a [tool]."),)
	if (!user.do_skilled((tool.toolspeed * 2) SECONDS, SKILL_DEVICES, src) || !user.use_sanity_check(src, tool))
		return
	if (!maintenance_protocols)
		USE_FEEDBACK_FAILURE("Сперва включите протокол обслуживания.")
		return
	if (!body || !body.cell)
		USE_FEEDBACK_FAILURE("Батарея отсутствует.")
		return
	user.put_in_hands(body.cell)
	turn_off_mech()
	body.cell = null
	user.visible_message(SPAN_NOTICE("\The [user] removes \the [src]'s power cell with \a [tool]."),)
