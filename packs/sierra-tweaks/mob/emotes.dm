/mob/living/can_emote(var/emote_type)
	. = ..() && emoteCooldownCheck()
