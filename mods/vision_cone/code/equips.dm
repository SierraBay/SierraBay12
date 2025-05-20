/obj/item/clothing/head/helmet
	var/fov_angle = FOV_90_DEGREES


/obj/item/clothing/head/helmet/swat
	fov_angle = FOV_180_DEGREES


/obj/item/clothing/head/helmet/thunderdome
	fov_angle = FOV_270_DEGREES



/obj/item/clothing/head/helmet/Initialize()
	..()
	AddComponent(/datum/component/helmets, fov_angle)

/mob/living/carbon/human/
	var/obj/item/clothing/head/last_equip_head

/mob/living/carbon/human/update_inv_head()
	..()
	if(head)
		if(istype(head, /obj/item/clothing/head/helmet))
			SEND_SIGNAL(head, COMSIG_ITEM_EQUIPPED, src)
			last_equip_head = head
	else
		if(last_equip_head)
			SEND_SIGNAL(last_equip_head, COMSIG_ITEM_DROPPED, src)



/mob/living/exosuit/Destroy()
	if(pilots)
		for(var/mob/living/thing in pilots)
			SEND_SIGNAL(head, COMSIG_CABINE_OPEN, thing)
			update_inv_head(thing)
	..()


/obj/item/mech_component/sensors
	var/fov_angle = FOV_90_DEGREES

/obj/item/mech_component/sensors/heavy
	fov_angle = FOV_180_DEGREES

/obj/item/mech_component/sensors/Initialize()
	.=..()
	AddComponent(/datum/component/mech_sensor, fov_angle)


/mob/living/exosuit/open_hatch()
	..()
	if(head)
		if(pilots)
			for(var/mob/living/thing in pilots)
				SEND_SIGNAL(head, COMSIG_CABINE_OPEN, thing)
				update_inv_head(thing)

/mob/living/exosuit/close_hatch()
	..()
	if(head)
		if(pilots)
			for(var/mob/living/thing in pilots)
				SEND_SIGNAL(head, COMSIG_CABINE_CLOSED, thing)
				update_inv_head(thing)

/obj/screen/exosuit/menu_button/hatch/switch_on()
	.=..()
	if(owner.head)
		if(owner.pilots)
			for(var/mob/living/thing in owner.pilots)
				SEND_SIGNAL(owner.head, COMSIG_CABINE_CLOSED, thing)
				owner.update_inv_head(thing)

/obj/screen/exosuit/menu_button/hatch/switch_off()
	.=..()
	if(owner.head)
		if(owner.pilots)
			for(var/mob/living/thing in owner.pilots)
				SEND_SIGNAL(owner.head, COMSIG_CABINE_OPEN, thing)
				owner.update_inv_head(thing)
