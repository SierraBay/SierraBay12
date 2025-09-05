/mob/living/exosuit/proc/destroy_mech_hatch_bolts(obj/item/tool, mob/user)
	if (!body)
		USE_FEEDBACK_FAILURE("\The [src] has no cockpit to force.")
		return FALSE
	if (!hatch_locked)
		USE_FEEDBACK_FAILURE("\The [src]'s cockpit isn't locked, you can't reach cockpit security bolts.")
		return FALSE
	var/delay = min(100 * user.skill_delay_mult(SKILL_DEVICES), 100 * user.skill_delay_mult(SKILL_EVA))
	visible_message(SPAN_NOTICE("\The [user] starts destroing the \the [src]'s [body.name] security bolts "))
	if(!do_after(user, delay, src, DO_DEFAULT | DO_PUBLIC_PROGRESS))
		return
	playsound(src, 'sound/machines/bolts_up.ogg', 25, TRUE)
	hatch_locked = FALSE
	body.hatch_bolts_status = BOLTS_DESTROYED
	update_icon()
	return TRUE
