/mob/living/exosuit/proc/start_dismantle_mech(obj/item/tool, mob/user)
	if(!user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		to_chat(user, SPAN_BAD("Понятия не имею как обслуживать меха."))
		return
	user.visible_message(SPAN_NOTICE("\The [user] starts removing \the [src]'s securing bolts with \a [tool]."),)
	if (!user.do_skilled((tool.toolspeed * 6) SECONDS, SKILL_DEVICES, src) || !user.use_sanity_check(src, tool))
		return
	if (!maintenance_protocols)
		USE_FEEDBACK_FAILURE("\The [src]'s maintenance protocols must be enabled to access the securing bolts.")
		return
	user.visible_message(SPAN_NOTICE("\The [user] removes \the [src]'s securing bolts with \a [tool], dismantling it."),)
	dismantle()
	return
