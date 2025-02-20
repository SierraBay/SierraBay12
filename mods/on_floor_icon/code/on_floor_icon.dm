//Учим предметы менять спрайт на турфе
/obj/item
	var/on_turf_icon

/obj/item/Initialize()
	.=..()
	update_onturf_icon_status()

/obj/item/dropped(mob/user)
	. = ..()
	update_onturf_icon_status()

///Тоже самое что и pickup, но loc изменился
/obj/item/proc/pickuped(user)
	update_onturf_icon_status()

/obj/item/on_enter_storage(obj/item/storage/S)
	. = ..()
	update_onturf_icon_status()

/obj/item/on_exit_storage(obj/item/storage/S)
	. = ..()
	update_onturf_icon_status()

/obj/item/proc/update_onturf_icon_status()
	if(on_turf_icon)
		if(isturf(loc))
			icon = on_turf_icon
		else
			icon = initial(icon)

/obj/item/attack_hand(mob/user as mob)
	.=..()
	pickuped(user) //Всё что добавилось - это вот эта одна строка
