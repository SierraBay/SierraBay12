/proc/electra_mob_effect(mob/living/victim)
	SSanom.add_last_gibbed(victim, "Электра")
	victim.dust()
