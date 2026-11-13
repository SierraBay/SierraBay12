/obj/item/ammobox
	var/caliber

/obj/item/ammobox/rifle
	caliber = CALIBER_RIFLE

/obj/item/ammobox/rifle/military
	caliber = CALIBER_RIFLE_MILITARY

/obj/item/ammobox/can_insert_casing(obj/item/ammo_casing/ammo_casing, mob/user, casing_spent = FALSE)
	var/round_caliber
	if(ispath(ammo_casing, /obj/item/ammo_casing))
		round_caliber = initial(ammo_casing.caliber)
	else if(istype(ammo_casing))
		round_caliber = ammo_casing.caliber
	if(caliber && round_caliber != caliber)
		if(user)
			USE_FEEDBACK_FAILURE("\The [src] only holds [caliber] ammunition.")
		return FALSE
	return ..()
