/mob/living/carbon/human/electra_mob_effect()
	if(health == 0)
		SSanom.add_last_gibbed(src, "Электра")
		dust()
		return

	if(lying) //Если цель лежит нам не нужно просчитывать путь до земли. Просто делаем удар в любую конечность
		electoanomaly_damage(50, null)
	else
		var/list/organs = list_organs_to_earth()
		var/damage = 50/LAZYLEN(organs)
		for(var/picked_organ in organs)
			electoanomaly_damage(damage, null, picked_organ)
