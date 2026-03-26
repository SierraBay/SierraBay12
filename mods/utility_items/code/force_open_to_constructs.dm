/obj/item/natural_weapon/juggernaut/use_before(atom/target,mob/user)
	if (istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
		if(A.locked)
			src/resolve_attackby(A, user)
			return
		A.visible_message(SPAN_DANGER("\The [user] forces \the [src] between \the [A], causing the metal to creak!"))
		playsound(A, 'sound/machines/airlock_creaking.ogg', 100, 1)
		if (do_after(user, 5 SECONDS, A, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) && !A.locked)
			A.welded = FALSE
			A.update_icon()
			playsound(A, 'sound/effects/meteorimpact.ogg', 100, 1)
			A.visible_message(SPAN_DANGER("\The [user] tears \the [A] open with \a [src]!"))
			addtimer(new Callback(A, /obj/machinery/door/airlock/.proc/open, TRUE), 0)
			A.open()
			A.set_broken(TRUE)

	if (istype(target, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/A = target
		playsound(A, 'sound/machines/airlock_creaking.ogg', 100, 1)
		if (do_after(user, 2 SECONDS, A, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
			A.visible_message(SPAN_DANGER("\The [user] pries \the [A] wide open effortlessly!"))
			A.open(TRUE)
	if (istype(target, /obj/machinery/door/blast))
		var/obj/machinery/door/blast/A = target
		if(!istype(user.get_inactive_hand(),/obj/item/melee/changeling/arm_blade))
			to_chat(user,SPAN_WARNING("We require an armblade in both arms to be able to exert enough force to pry a blast door open."))
			return
		A.visible_message(SPAN_DANGER("\The [user] forces both armblades between \the [A], prying with incredible strength!"))
		playsound(A, 'sound/machines/airlock_creaking.ogg', 100, 1)
		if (do_after(user, 20 SECONDS, A, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) )
			A.update_icon()
			playsound(A, 'sound/effects/meteorimpact.ogg', 100, 1)
			A.visible_message(SPAN_DANGER("\The [user] tears \the [A] wide open!"))
			A.force_open()
