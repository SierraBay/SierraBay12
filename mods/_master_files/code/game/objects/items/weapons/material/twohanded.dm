/obj/item/material/twohanded/update_force()
	..()
	if(wielded)
		force = force_wielded

/obj/item/material/twohanded/update_twohanding()
	if(!istype(src, /obj/item/material/twohanded/offhand) && wielded)
		var/mob/living/M = loc
		if(!istype(M) || (M.l_hand != src && M.r_hand != src) || !M.can_wield_item(src))
			unwield(M, TRUE)
	return ..()
