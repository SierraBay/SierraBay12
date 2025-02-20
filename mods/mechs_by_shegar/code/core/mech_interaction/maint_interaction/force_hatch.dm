/mob/living/exosuit/proc/force_open_hatch(obj/item/tool, mob/user)
	if (!body)
		USE_FEEDBACK_FAILURE("\The [src] has no cockpit to force.")
		return FALSE
	if(hatch_locked)
		USE_FEEDBACK_FAILURE("\The [src]'s cockpit locked by cockpit security bolts. You need saw or welder.")
		return FALSE
	if(!hatch_closed)
		USE_FEEDBACK_FAILURE("\The [src]'s cockpit open, crowbar force isn't required.")
		return FALSE
	visible_message(SPAN_NOTICE("\The [user] starts forcing the \the [src]'s emergency [body.hatch_descriptor] release using \the [tool]."))
	if(!do_after(user, 5 SECONDS, src, DO_DEFAULT | DO_PUBLIC_PROGRESS))
		return
	playsound(src, 'sound/machines/bolts_up.ogg', 25, TRUE)
	hatch_closed = FALSE
	update_icon()
	return TRUE
