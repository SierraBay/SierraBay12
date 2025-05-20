/obj/item/clothing/head/helmet
	var/fov_angle = FOV_90_DEGREES


/obj/item/clothing/head/helmet/swat
	fov_angle = FOV_180_DEGREES


/obj/item/clothing/head/helmet/thunderdome
	fov_angle = FOV_270_DEGREES



/obj/item/clothing/head/helmet/Initialize()
	. = ..()
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
