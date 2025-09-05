/mob/living/carbon/swap_hand()
	GLOB.hands_swapped_event.raise_event(src)
	hand = !hand
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)	//This being 1 means the left hand is in use
			hud_used.l_hand_hud_object.icon_state = "l_hand_active"
			hud_used.r_hand_hud_object.icon_state = "r_hand_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "l_hand_inactive"
			hud_used.r_hand_hud_object.icon_state = "r_hand_active"
	var/obj/item/I = get_active_hand()
	if(istype(I))
		I.on_active_hand(src)

	else if(in_throw_mode)//Если новая рука ПУСТА - зачем нам вообще оставлять бросок активным
		throw_mode_off()
