/mob/living/carbon/swap_hand()
	. = ..()
	if(in_throw_mode && !istype(get_active_hand(), /obj/item))//Если новая рука ПУСТА - зачем нам вообще оставлять бросок активным
		throw_mode_off()
	update_mouse_pointer()
