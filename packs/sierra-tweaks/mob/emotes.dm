/mob/living/can_emote()
	. = ..() && emoteCooldownCheck()
