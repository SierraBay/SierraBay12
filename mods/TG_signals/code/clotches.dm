/mob/living/carbon/human/equip_to_slot(obj/item/I, slot)
	. = ..()
	SEND_SIGNAL(src, COMSIG_MOB_EQUIPED_SMTHG, src)
