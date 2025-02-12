/mob/living/exosuit/ex_act(severity)
	if (status_flags & GODMODE)
		return
	var/b_loss = 0
	var/f_loss = 0
	switch (severity)
		if (EX_ACT_DEVASTATING)
			b_loss = 200
			f_loss = 200
		if (EX_ACT_HEAVY)
			b_loss = 90
			f_loss = 90
		if(EX_ACT_LIGHT)
			b_loss = 45

	// spread damage overall
	apply_damage(b_loss, DAMAGE_BRUTE, null, DAMAGE_FLAG_EXPLODE | DAMAGE_FLAG_DISPERSED, used_weapon = "Explosive blast")
	apply_damage(f_loss, DAMAGE_BURN, null, DAMAGE_FLAG_EXPLODE | DAMAGE_FLAG_DISPERSED, used_weapon = "Explosive blast")
