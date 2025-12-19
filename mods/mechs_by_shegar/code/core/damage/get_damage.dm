/mob/living/exosuit/getBruteLoss()
	var/total_brute = 0
	for(var/obj/item/mech_component/component in list(head, body, R_arm, L_arm, R_leg, L_leg))
		total_brute += component.brute_damage
	return total_brute
