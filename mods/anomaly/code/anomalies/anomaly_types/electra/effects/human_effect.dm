/proc/electra_human_effect(mob/living/carbon/human/victim)
	if(victim.health == 0)
		SSanom.add_last_gibbed(victim, "Электра")
		victim.dust()
		return

	if(victim.lying) //Если цель лежит нам не нужно просчитывать путь до земли. Просто делаем удар в любую конечность
		victim.electoanomaly_damage(50, null)
	else
		var/list/organs = victim.list_organs_to_earth()
		var/damage = 50/LAZYLEN(organs)
		for(var/picked_organ in organs)
			victim.electoanomaly_damage(damage, null, picked_organ)
