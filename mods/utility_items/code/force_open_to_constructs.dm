/obj/item/natural_weapon/juggernaut/use_before(atom/target,mob/user,click_params) //пришлось прокидывать клик парамсы, ибо во время переобъявления одного из проков в стеке - кто-то забыл обьявить параметр, изначально пренадлежавший этому проку
	//типа заявил переменную-лист
	var/list/L = params2list(click_params)

	if(("shift" in L) && ("ctrl" in L))
		if (istype(target, /obj/machinery/door/airlock/highsecurity))
			var/obj/machinery/door/airlock/A = target
			if(A.arePowerSystemsOn())
				if(A.locked)
					to_chat(user,SPAN_WARNING("I'm trying to pry and push the [A] gates apart, but they're shut tight!"))
					return TRUE // возвращаем тру, что бы он не бил при отмене действия
				A.visible_message(SPAN_DANGER("\The [user] forces \the [src] between \the [A], causing the metal to creak!"))
				playsound(A, 'sound/machines/airlock_creaking.ogg', 100, 1)
				if (do_after(user, 20 SECONDS, A, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) && !A.locked)
					A.welded = FALSE
					A.update_icon()
					playsound(A, 'sound/effects/meteorimpact.ogg', 100, 1)
					A.visible_message(SPAN_DANGER("\The [click_params] tears \the [A] open with \a [src]!"))
					addtimer(new Callback(A, /obj/machinery/door/airlock/.proc/open, TRUE), 0)
					A.open()
					A.set_broken(TRUE)
					return TRUE // (для всех return TRUE) - отменяем удар после взаимодействия со шлюзом. т.к. есть проверка на клик
				else
					return TRUE // если нас прерывают - отменяем удар.
			else
				if(A.locked)
					return TRUE
				A.visible_message(SPAN_DANGER("\The [user] forces \the [src] between \the [A], causing the metal to creak!"))
				playsound(A, 'sound/machines/airlock_creaking.ogg', 100, 1)
				if (do_after(user, 0 SECONDS, A, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) && !A.locked)
					A.welded = FALSE
					A.update_icon()
					playsound(A, 'sound/effects/meteorimpact.ogg', 100, 1)
					A.visible_message(SPAN_DANGER("\The [user] tears \the [A] open with \a [src]!"))
					addtimer(new Callback(A, /obj/machinery/door/airlock/highsecurity.proc/open, TRUE), 0)
					A.open()
					A.set_broken(TRUE)
					return TRUE
				else
					return TRUE
		else if (istype(target, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/A = target
			if(A.arePowerSystemsOn())
				if(A.locked)
					A.visible_message(SPAN_DANGER("\The [user] forces \the [src] between \the [A], causing the metal to creak!"))
					playsound(A, 'sound/machines/airlock_creaking.ogg', 100, 1)
					if (do_after(user, 25 SECONDS, A, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
						A.locked = FALSE
						A.welded = FALSE
						A.update_icon()
						playsound(A, 'sound/effects/meteorimpact.ogg', 100, 1)
						A.visible_message(SPAN_DANGER("\The [user] tears \the [A] open with \a [src]!"))
						addtimer(new Callback(A, /obj/machinery/door/airlock/.proc/open, TRUE), 0)
						A.open()
						A.set_broken(TRUE)
						A.visible_message(SPAN_DANGER("\The [user] forces \the [src] between \the [A], causing the metal to creak!"))
						playsound(A, 'sound/machines/airlock_creaking.ogg', 100, 1)
						return TRUE
					else
						return TRUE //аналогично отменяем удар
				else
					playsound(A, 'sound/machines/airlock_creaking.ogg', 100, 1)
					if (do_after(user, 5 SECONDS, A, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) && A.arePowerSystemsOn())
						A.welded = FALSE
						A.update_icon()
						playsound(A, 'sound/effects/meteorimpact.ogg', 100, 1)
						A.visible_message(SPAN_DANGER("\The [user] tears \the [A] open with \a [src]!"))
						addtimer(new Callback(A, /obj/machinery/door/airlock/.proc/open, TRUE), 0)
						A.open()
						A.set_broken(TRUE)
						return TRUE
					else
						return TRUE
			else
				if(A.locked)
					return TRUE
				A.visible_message(SPAN_DANGER("\The [user] forces \the [src] between \the [A], causing the metal to creak!"))
				if (do_after(user, 0 SECONDS, A, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
					A.welded = FALSE
					A.update_icon()
					playsound(A, 'sound/effects/meteorimpact.ogg', 100, 1)
					playsound(A, 'sound/machines/airlock_creaking.ogg', 100, 1)
					A.visible_message(SPAN_DANGER("\The [user] tears \the [A] open with \a [src]!"))
					addtimer(new Callback(A, /obj/machinery/door/airlock/.proc/open, TRUE), 0)
					A.open()
					A.set_broken(TRUE)
					return TRUE
				else
					return TRUE
		else if (istype(target, /obj/machinery/door/firedoor))
			var/obj/machinery/door/firedoor/A = target
			if(!A.can_open()) // что-бы не кликалось по открытому шлюзу, когда он уже открыт
				return
			playsound(A, 'sound/machines/airlock_creaking.ogg', 100, 1)
			if(do_after(user, 2 SECONDS, A, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
				A.visible_message(SPAN_DANGER("\The [user] pries \the [A] wide open effortlessly!"))
				A.open(TRUE)
			else
				return TRUE
	return
