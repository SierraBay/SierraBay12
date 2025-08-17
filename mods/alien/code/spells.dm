/datum/client_color/xeno
	client_color = list(
	0.333,  0.333,  0.333,
	0.333,  0.333,  0.333,
	0.333,  0.333,  0.333
	)
	order = 100


/mob/proc/make_alien()

	if(isalien(src))
		var/mob/living/carbon/human/alien/H = src

		H.add_language(LANGUAGE_XENO)
		H.add_language(LANGUAGE_SPACER)
		H.add_language(LANGUAGE_HUMAN_EURO)
		H.abilities += new /datum/power/stalk_mode

		for(var/datum/power/P in H.abilities)
			if(P.isVerb)
				if(!(P in H.verbs))
					verbs.Add(P.verbpath)
			if(P.make_hud_button)
				if(!H.ability_master)
					H.ability_master = new /obj/screen/movable/ability_master(null, H)
				H.ability_master.add_verb_ability(
					object_given = H,
					verb_given = P.verbpath,
					name_given = P.name,
					ability_icon_given = P.ability_icon_state,
					arguments = list()
					)
		H.add_client_color(/datum/client_color/xeno)

/datum/power/stalk_mode
	name = "Stalk Mode"
	ability_icon_state = "fiend"
	verbpath = /mob/proc/stalk_mode

/mob/proc/stalk_mode()
	set category = "Alien"
	set name = "Stalk mode"
	set desc = "As long as you stalk, you will be almost invisible."

	if(isalien(src))
		var/mob/living/carbon/human/alien/H = src

		if(!H.cloaked)
			H.set_move_intent(default_walk_intent)
			H.cloaked = 1
			animate(src,alpha = 255, alpha = 5, time = 10)
		else
			H.cloaked = 0

		var/remain_cloaked = TRUE
		while(remain_cloaked) //This loop will keep going until the player uncloaks.
			sleep(1 SECOND) // Sleep at the start so that if something invalidates a cloak, it will drop immediately after the check and not in one second.

			if(MOVING_QUICKLY(H))
				remain_cloaked = 0
			if(!H.cloaked)
				remain_cloaked = 0
			if(H.stat)
				remain_cloaked = 0
			if(H.l_hand || H.r_hand)
				remain_cloaked = 0
			if(H.incapacitated(INCAPACITATION_DISABLED))
				remain_cloaked = 0

		H.invisibility = initial(invisibility)
		H.cloaked = 0
		animate(src,alpha = 10, alpha = 255, time = 10)
