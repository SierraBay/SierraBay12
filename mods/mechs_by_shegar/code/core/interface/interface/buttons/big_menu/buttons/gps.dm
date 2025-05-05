/obj/screen/exosuit/menu_button/gps
	name = "Интегрированный ГПС"
	button_desc = "Открывает меню управления встроенного GPS."
	icon_state = "gps"

/obj/screen/exosuit/menu_button/gps/activated()
	owner.GPS.attack_self(usr)

/obj/item/device/gps/mech_gps
	var/mob/living/exosuit/mech_holder

/obj/item/device/gps/mech_gps/update_holder(force_clear = FALSE)

	if(mech_holder && (force_clear || loc != mech_holder))
		GLOB.moved_event.unregister(mech_holder, src)
		GLOB.dir_set_event.unregister(mech_holder, src)
		for(var/mob/living/pilot in mech_holder.pilots)
			pilot.client?.screen -= compass
			pilot = null

	if(!force_clear && istype(loc, /mob/living/exosuit))
		mech_holder = loc
		GLOB.moved_event.register(mech_holder, src, PROC_REF(update_compass))
		GLOB.dir_set_event.register(mech_holder, src, PROC_REF(update_compass))

	if(!force_clear && mech_holder && tracking)
		if(!is_in_processing_list)
			START_PROCESSING(SSobj, src)
			is_in_processing_list = TRUE
		for(var/mob/living/pilot in mech_holder.pilots)
			if(pilot.client)
				pilot.client.screen |= compass
	else
		STOP_PROCESSING(SSobj, src)
		is_in_processing_list = FALSE
		for(var/mob/living/pilot in mech_holder.pilots)
			if(pilot.client)
				pilot.client.screen -= compass
