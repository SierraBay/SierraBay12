/mob/living/carbon/human/alien/proc/stalk_mode()
	set category = "Alien"
	set name = "Stalk mode"
	set desc = "As long as you stalk, you will be almost invisible."

	if(!src.cloaked)
		src.set_move_intent(default_walk_intent)
		src.cloaked = 1
	else
		src.cloaked = 0

		var/remain_cloaked = TRUE
		while(remain_cloaked)
			sleep(1 SECOND)
			if(MOVING_QUICKLY(src))
				remain_cloaked = 0
			if(!src.cloaked)
				remain_cloaked = 0
			if(src.stat)
				remain_cloaked = 0
			if(src.l_hand || src.r_hand)
				remain_cloaked = 0
			if(src.incapacitated(INCAPACITATION_DISABLED)) // Stunned lings also can't stay cloaked.
				remain_cloaked = 0

		src.invisibility = initial(invisibility)
