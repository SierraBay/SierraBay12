/mob/living/exosuit/apply_damage(damage = 0, damagetype = DAMAGE_BRUTE, def_zone, damage_flags = FLAGS_OFF, used_weapon, armor_pen, silent = FALSE)
	if(!damage)
		return 0

	if(!def_zone)
		if(damage_flags & DAMAGE_FLAG_DISPERSED)
			var/old_damage = damage
			var/tally
			silent = FALSE
			for(var/obj/item/part in list(head, body, L_arm, R_arm, L_leg, R_leg))
				tally += part.w_class
			for(var/obj/item/part in list(head, body, L_arm, R_arm, L_leg, R_leg))
				damage = old_damage * part.w_class/tally
				def_zone = BP_CHEST
				if(part == L_leg)
					def_zone = BP_L_LEG
				if(part == R_leg)
					def_zone = BP_R_LEG
				else if(part == L_arm)
					def_zone = BP_L_ARM
				else if(part == R_arm)
					def_zone = BP_R_ARM
				else if(part == head)
					def_zone = BP_HEAD

				. = .() || .
			return

		def_zone = ran_zone(def_zone)

	var/list/after_armor = modify_damage_by_armor(def_zone, damage, damagetype, damage_flags, src, armor_pen, TRUE)
	damage = after_armor[1]
	damagetype = after_armor[2]

	//В случае если атакованная часть меха ВЫБИТА(Т.е в ней выбиты все внутренние модули и 0 состояний)
	//то мы передаём урон в конечности меха
	var/obj/item/mech_component/target = zoneToComponent(def_zone)
	if(target.total_damage >= target.max_hp)
		if(target == head && !head.camera && !head.radio)
			body.take_brute_damage(damage)
			R_leg.take_brute_damage(damage)
			L_leg.take_brute_damage(damage)
			R_arm.take_brute_damage(damage)
			L_arm.take_brute_damage(damage)
		else if(target == body && !body.diagnostics )
			head.take_brute_damage(damage)
			R_leg.take_brute_damage(damage)
			L_leg.take_brute_damage(damage)
			R_arm.take_brute_damage(damage)
			L_arm.take_brute_damage(damage)
		else if(target == L_leg && !L_leg.motivator)
			body.take_brute_damage(damage)
			head.take_brute_damage(damage)
			R_leg.take_brute_damage(damage)
			R_arm.take_brute_damage(damage)
			L_arm.take_brute_damage(damage)
		else if(target == R_leg && !R_leg.motivator)
			body.take_brute_damage(damage)
			head.take_brute_damage(damage)
			L_leg.take_brute_damage(damage)
			R_arm.take_brute_damage(damage)
			L_arm.take_brute_damage(damage)
		else if(target == L_arm && !L_arm.motivator)
			body.take_brute_damage(damage)
			head.take_brute_damage(damage)
			L_leg.take_brute_damage(damage)
			R_leg.take_brute_damage(damage)
			R_arm.take_brute_damage(damage)
		else if(target == R_arm && !R_arm.motivator)
			body.take_brute_damage(damage)
			head.take_brute_damage(damage)
			R_leg.take_brute_damage(damage)
			L_leg.take_brute_damage(damage)
			L_arm.take_brute_damage(damage)
		updatehealth()


	if(!damage)
		return 0
	//Здесь мы реагируем на тип урона.
	switch(damagetype)
		if (DAMAGE_BRUTE)
		//Обшивка меха сопротивляется БРУТ урону
			var/brute_resist = ((material.brute_armor-7)) // Макс защита - 4 от брута, 5 от бёрна
			if(brute_resist > 5)
				brute_resist = 5
			damage = damage - brute_resist
			adjustBruteLoss(damage, target)
		if (DAMAGE_BURN)
		//Обшивка меха сопротивляется БЁРН урону
			var/burn_resist = ((material.burn_armor-7))
			if(burn_resist > 5)
				burn_resist = 5
			damage = damage - burn_resist
			adjustFireLoss(damage, target)
		if (DAMAGE_RADIATION)
			for(var/mob/living/pilot in pilots)
				pilot.apply_damage(damage, DAMAGE_RADIATION, def_zone, damage_flags, used_weapon)
	updatehealth()

	return 1
