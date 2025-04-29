//Учим предметы менять спрайт на турфе
/obj/item
	var/on_turf_icon

/obj/item/Initialize()
	.=..()
	update_onturf_icon_status()

/obj/item/Move()
	.=..()
	update_onturf_icon_status()

/obj/item/forceMove()
	.=..()
	update_onturf_icon_status()

/obj/item/proc/update_onturf_icon_status()
	if(on_turf_icon)
		if(isturf(loc))
			icon = on_turf_icon
		else
			icon = initial(icon)

/obj/item/attack_hand(mob/user as mob)
	..()
	update_onturf_icon_status()
