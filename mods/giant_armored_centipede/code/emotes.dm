/mob/living/carbon/human/nabber/verb/bug_flap()
	set name = "X - Взмах крыльями"
	set category = "Emote"
	emote("flap")

/singleton/emote/visible/flap/do_extra(atom/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.flash_nabber_wings()

/singleton/emote/visible/aflap/do_extra(atom/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.flash_nabber_wings()

/singleton/emote/audible/bug_buzz/do_extra(atom/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.flash_nabber_wings()
