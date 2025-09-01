/obj/item/clothing/head/helmet
	var/fov_angle = FOV_90_DEGREES

/obj/item/clothing/head/helmet/Initialize()
	.=..()
	if(body_parts_covered == HEAD)
		fov_angle = FOV_90_DEGREES
	else if(body_parts_covered == (HEAD | FACE))
		fov_angle = FOV_180_DEGREES
	else if(body_parts_covered == (HEAD | FACE | EYES))
		fov_angle = FOV_180_DEGREES
	else
		fov_angle = FOV_90_DEGREES
	AddComponent(/datum/component/helmets, fov_angle)

/mob/living/carbon/human/
	var/obj/item/clothing/head/last_equip_head

/mob/living/carbon/human/update_inv_head()
	..()
	if(client)
		if(head)
			if(istype(head, /obj/item/clothing/head/helmet))
				SEND_SIGNAL(head, COMSIG_ITEM_EQUIPPED, src)
				last_equip_head = head
		else if(client.eye != client.mob)
			return
		else
			if(last_equip_head)
				SEND_SIGNAL(last_equip_head, COMSIG_ITEM_DROPPED, src)




//////////////////////////MECH COMPONENT//////////////////////////

/obj/item/mech_component/sensors
	var/fov_angle = FOV_90_DEGREES


/obj/item/mech_component/sensors/light
	fov_angle = FOV_90_DEGREES

/obj/item/mech_component/sensors/combat
	fov_angle = FOV_180_DEGREES

/obj/item/mech_component/sensors/heavy
	fov_angle = FOV_270_DEGREES

/obj/item/mech_component/sensors/Initialize()
	.=..()
	AddComponent(/datum/component/mech_sensor, fov_angle)

/mob/living/exosuit/Destroy()
	if(pilots)
		for(var/mob/living/carbon/human/thing in pilots)
			SEND_SIGNAL(head, COMSIG_CABINE_OPEN, thing)
			thing.update_inv_head()
	..()

/mob/living/exosuit/remove_pilot()
	if(pilots)
		for(var/mob/living/carbon/human/thing in pilots)
			SEND_SIGNAL(head, COMSIG_CABINE_OPEN, thing)
			thing.update_inv_head()
	..()
