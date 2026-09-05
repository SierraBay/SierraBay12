/mob/living/proc/combat_update_neck_grabs(force = FALSE)
	if(!combat_mode && !force)
		return
	for(var/obj/item/grab/G in src)
		if(G.assailant != src)
			continue
		if(!G.current_grab || G.current_grab.state_name != NORM_NECK)
			continue
		G.adjust_position()
