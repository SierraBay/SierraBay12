/obj/machinery/door/airlock/mech_clamp_interaction(mob/living/user, obj/item/mech_equipment/clamp/mech_clamp)
	visible_message(SPAN_DANGER("\The [mech_clamp.owner] begins prying on \the [src]!"))
	if(do_after(mech_clamp.owner, 5 SECONDS, src, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
		welded = FALSE
		if(locked)
			lock_cut_state = BOLTS_CUT
		locked = FALSE
		update_icon()
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
		playsound(src, 'sound/machines/airlock_creaking.ogg', 100, 1)
		visible_message(SPAN_DANGER("\The [mech_clamp.owner] tears \the [src] open!"))
		set_broken(TRUE)
		open(TRUE)

/obj/machinery/door/airlock/external
