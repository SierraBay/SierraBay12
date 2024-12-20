/*
*	// B B B
*	// U M U  ↓ (Направление меха, смотрит на ЮГ)
*	// F F F
*	// M - Мех, F - Атака пришла в лицо, B - Атака пришла в спину N - Ничего
*/
/mob/living/exosuit/bullet_act(obj/item/projectile/P, def_zone, used_weapon)

	if (status_flags & GODMODE)
		return PROJECTILE_FORCE_MISS
	var/obj/item/mech_component/target = zoneToComponent(def_zone)
	P.damage_type = DAMAGE_BRUTE //Каким образом можно починить ПРОВОДАМИ прожжёную обшивку?
	//Проверяем, с какого направления прилетает атака!
	var/local_dir = get_dir(src, get_turf(P)) // <- Узнаём направление от меха до снаряда

	//Попадание с фронта
	if(local_dir == turn(dir, -45) || local_dir == turn(dir, 0) || local_dir == turn(dir, 45))
		P.damage = ( P.damage * target.front_modificator_damage ) + target.front_additional_damage
	//Попадание с тыла
	else if(local_dir == turn(dir, 180) || local_dir == turn(dir, -135) || local_dir == turn(dir, 135))
		//В случае если у нас есть пилоты скинем их при атаке по спине.
		if(passengers_ammount > 0)
			forced_leave_passenger(null,MECH_DROP_ALL_PASSENGERS,"attack")
		P.damage = ( P.damage * target.back_modificator_damage ) + target.back_additional_damage
	switch(def_zone)
		//В случае если атака приходит в голову/лицо/глаза/пузо - снаряд может напрямую ранить пилота при условии
		//что кабина меха открыта
		if(BP_HEAD , BP_CHEST, BP_MOUTH, BP_EYES)
			if(LAZYLEN(pilots) && (!hatch_closed || !prob(body.pilot_coverage)))
				if(local_dir != turn(dir,-135) || local_dir != turn(dir,135) || local_dir != turn(dir,180))
					var/mob/living/pilot = pick(pilots)
					return pilot.bullet_act(P, def_zone, used_weapon)
	..()



/mob/living/exosuit/apply_damage(damage = 0, damagetype = DAMAGE_BRUTE, def_zone, damage_flags = EMPTY_BITFIELD, used_weapon, armor_pen, silent = FALSE)
	if(!damage)
		return 0

	if(!def_zone)
		if(damage_flags & DAMAGE_FLAG_DISPERSED)
			var/old_damage = damage
			var/tally
			silent = FALSE
			for(var/obj/item/part in list(arms, legs, body, head))
				tally += part.w_class
			for(var/obj/item/part in list(arms, legs, body, head))
				damage = old_damage * part.w_class/tally
				def_zone = BP_CHEST
				if(part == arms)
					def_zone = BP_L_ARM
				else if(part == legs)
					def_zone = BP_L_LEG
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
	if(target.total_damage >= target.max_damage)
		if(target == head && !head.camera && !head.radio)
			body.take_brute_damage(damage/3)
			arms.take_brute_damage(damage/3)
			legs.take_brute_damage(damage/3)
		else if(target == body && !body.m_armour && !body.diagnostics )
			head.take_brute_damage(damage/1.5)
			legs.take_brute_damage(damage/1.5)
			arms.take_brute_damage(damage/1.5)
		else if(target == arms && !arms.motivator)
			body.take_brute_damage(damage/3)
			head.take_brute_damage(damage/3)
			legs.take_brute_damage(damage/3)
		else if(target == legs && !legs.motivator)
			body.take_brute_damage(damage/2)
			head.take_brute_damage(damage/2)
			arms.take_brute_damage(damage/2)
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

	if ((damagetype == DAMAGE_BRUTE || damagetype == DAMAGE_BURN) && prob(25+(damage*2)))
		sparks.set_up(3,0,src)
		sparks.start()
	updatehealth()

	return 1

/mob/living/exosuit/emp_act(severity)
	SHOULD_CALL_PARENT(FALSE)
	if (status_flags & GODMODE)
		return
	//В случае если у меха есть ЭНЕРГОЩИТ - мы передадим ЭМИ по нему и перестанем идти дальше по коду
	for(var/obj/aura/mechshield/thing in auras)
		if(thing.active)
			thing.emp_attack(severity)
			return
	var/ratio = get_blocked_ratio(null, DAMAGE_BURN, null, (3-severity) * 20) // HEAVY = 40; LIGHT = 20
	//Добавит игроку на экран глитчей из-за ЭМИ.
	add_glitch_effects()
	//В зависимости от типа брони меха - выведем в чат сообщение
	if(ratio >= 0.5)
		for(var/mob/living/m in pilots)
			to_chat(m, SPAN_NOTICE("Your Faraday shielding absorbed the pulse!"))
	else if(ratio > 0)
		for(var/mob/living/m in pilots)
			to_chat(m, SPAN_NOTICE("Your Faraday shielding mitigated the pulse!"))
	//ЭМИ на меха работает лишь в том случае, если он запитан
	if(power == MECH_POWER_ON)
		setClickCooldown(10) //Орудия и модули на КД
		sub_speed(10) //Убьём скорость меха
		for(var/obj/item/mech_component/thing in list(arms,legs,head,body))
			thing.emp_heat(severity, ratio, src) //Греем конечности
			if(ratio < 0.5) //Без эми брони, получаем дамаг от эми
				thing.emp_act(severity)
	//Если кабина меха не закрыта - воздействуем и на пилота.
	if(!hatch_closed || !prob(body.pilot_coverage))
		for(var/thing in pilots)
			var/mob/pilot = thing
			pilot.emp_act(severity)
