/mob/proc/electra_mob_effect()
	return

/mob/living/simple_animal/electra_mob_effect()
	SSanom.add_last_gibbed(src, "Электра")
	dust()

/mob/living/simple_animal/hostile/electra_wolf/electra_mob_effect()
	health = maxHealth
