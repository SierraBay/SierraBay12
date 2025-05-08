/mob/living/say(message, datum/language/speaking = null, verb="says", alt_name="", whispering)
	.=..()
	SEND_SIGNAL(src, COMSIG_MOB_SAYED, message)
