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

/mob/living/exosuit/apply_effect(effect = 0, effecttype = EFFECT_STUN, blocked = 0)
	if(!effect || (blocked >= 100))
		return 0
	if(LAZYLEN(pilots) && (!hatch_closed || !prob(body.pilot_coverage)))
		if(effect > 0 && effecttype == DAMAGE_RADIATION)
			effect = max((1-(get_armors_by_zone(null, DAMAGE_RADIATION)/100))*effect/(blocked+1),0)
		var/mob/living/pilot = pick(pilots)
		return pilot.apply_effect(effect, effecttype, blocked)
	if (!(effecttype in list(EFFECT_PAIN, EFFECT_STUTTER, EFFECT_EYE_BLUR, EFFECT_DROWSY, EFFECT_STUN, EFFECT_WEAKEN)))
		. = ..()

/mob/living/exosuit/resolve_item_attack(obj/item/I, mob/living/user, def_zone)
	if(!I.force)
		user.visible_message(SPAN_NOTICE("\The [user] bonks \the [src] harmlessly with \the [I]."))
		return

	switch(def_zone)
		if(BP_HEAD , BP_CHEST, BP_MOUTH, BP_EYES)
			if(LAZYLEN(pilots) && (!hatch_closed || !prob(body.pilot_coverage)))
				var/mob/living/pilot = pick(pilots)
				var/zone = pilot.resolve_item_attack(I, user, def_zone)
				if(zone)
					var/datum/attack_result/AR = new()
					AR.hit_zone = zone
					AR.attackee = pilot
					return AR

	return def_zone //Careful with effects, mechs shouldn't be stunned

/mob/living/exosuit/hitby(atom/movable/AM, datum/thrownthing/TT)
	if (!hatch_closed && (LAZYLEN(pilots) < length(body.pilot_positions)))
		var/mob/living/M = AM
		if (istype(M))
			var/chance = 50 //Throwing someone at an empty exosuit MAY put them in the seat
			var/message = "\The [AM] lands in \the [src]'s cockpit with a crash. Get in the damn exosuit!"
			if (TT.thrower == TT.thrownthing)
				//This is someone jumping
				chance = M.skill_check_multiple(list(SKILL_MECH = HAS_PERK, SKILL_HAULING = SKILL_TRAINED)) ? 100 : chance
				message = "\The [AM] gets in \the [src]'s cockpit in one fluid motion."
			if (prob(chance))
				if (enter(AM, silent = TRUE, check_incap = FALSE, instant = TRUE))
					visible_message(SPAN_NOTICE("[message]"))
					return

	if (LAZYLEN(pilots) && (!hatch_closed || !prob(body.pilot_coverage)))
		var/mob/living/pilot = pick(pilots)
		return pilot.hitby(AM, TT)
	. = ..()

/mob/living/exosuit/bullet_act(obj/item/projectile/P, def_zone, used_weapon)
	if (status_flags & GODMODE)
		return PROJECTILE_FORCE_MISS
	//[SIERRA-ADD] - Mechs-by-Shegar
	//Проверяем, с какого направления прилетает атака!
	var/local_dir = get_dir(src, get_turf(P)) // <- Узнаём направление от меха до пули
	if(local_dir == turn(dir, -90) || local_dir == turn(dir, -135) || local_dir == turn(dir, 180) || local_dir == turn(dir, 90) || local_dir == turn(dir, 135))
	// U U U
	// U M U  ↓ (Mech dir, look on SOUTH)
	// D D D
	// M - mech, U - unload passengers if was hit from this side, D - defense passengers(Dont unload) if was hit from this side
		if(passengers_ammount > 0)
			forced_leave_passenger(null,MECH_DROP_ALL_PASSENGER,"attack")
	if(local_dir == turn(dir,-135) || local_dir == turn(dir,135) || local_dir == turn(dir,180))
		P.damage = P.damage * 1.3
	//[SIERRA-ADD]
	switch(def_zone)
		if(BP_HEAD , BP_CHEST, BP_MOUTH, BP_EYES)
			if(LAZYLEN(pilots) && (!hatch_closed || !prob(body.pilot_coverage)))
				//[SIERRA-EDIT] - Mechs-by-Shegar
				//Если мех открыт и снаряд прилетает в спину меха, урон уйдёт в меха
				/*
				var/mob/living/pilot = pick(pilots)
				return pilot.bullet_act(P, def_zone, used_weapon)
				*/
				if(local_dir != turn(dir,-135) || local_dir != turn(dir,135) || local_dir != turn(dir,180))
					var/mob/living/pilot = pick(pilots)
					return pilot.bullet_act(P, def_zone, used_weapon)
				//[SIERRA-EDIT]
	..()

/mob/living/exosuit/get_armors_by_zone(def_zone, damage_type, damage_flags)
	. = ..()
	if(body && body.m_armour)
		var/body_armor = get_extension(body.m_armour, /datum/extension/armor)
		if(body_armor)
			. += body_armor

/mob/living/exosuit/updatehealth()
	//[SIERRA-EDIT] - Mechs-by-Shegar - Тарков система здоровья меха
	//maxHealth = body ? body.mech_health : 0
	maxHealth = (body.mech_health + material.integrity) + head.max_damage + arms.max_damage + legs.max_damage
	//[SIERRA-EDIT]
	health = maxHealth-(getFireLoss()+getBruteLoss())

/mob/living/exosuit/adjustFireLoss(amount, obj/item/mech_component/MC = pick(list(arms, legs, body, head)))
	if(MC)
		MC.take_burn_damage(amount)
		MC.update_health()

/mob/living/exosuit/adjustBruteLoss(amount, obj/item/mech_component/MC = pick(list(arms, legs, body, head)))
	if(MC)
		MC.take_brute_damage(amount)
		MC.update_health()

/mob/living/exosuit/proc/zoneToComponent(zone)
	switch(zone)
		if(BP_EYES , BP_HEAD)
			return head
		if(BP_L_ARM , BP_R_ARM)
			return arms
		if(BP_L_LEG , BP_R_LEG)
			return legs
		else
			return body

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

	//[SIERRA-ADD] - Mechs-by-Shegar - Перенаправление урона
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

	//[SIERRA-ADD]
	if(!damage)
		return 0

	//Only 3 types of damage concern mechs and vehicles
	switch(damagetype)
		if (DAMAGE_BRUTE)
		//[SIERRA-ADD] - Mechs-by-Shegar - сопротивление материала бёрн урону
			var/brute_resist = ((material.brute_armor-7)) // Макс защита - 4 от брута, 5 от бёрна
			if(brute_resist > 5)
				brute_resist = 5
			damage = damage - brute_resist
		//[SIERRA-ADD]
			adjustBruteLoss(damage, target)
		if (DAMAGE_BURN)
		//[SIERRA-ADD] - Mechs-by-Shegar - Сопротивление материала бёрн урону
			var/burn_resist = ((material.burn_armor-7))
			if(burn_resist > 5)
				burn_resist = 5
			damage = damage - burn_resist
		//[SIERRA-ADD]
			adjustFireLoss(damage, target)
		if (DAMAGE_RADIATION)
			for(var/mob/living/pilot in pilots)
				pilot.apply_damage(damage, DAMAGE_RADIATION, def_zone, damage_flags, used_weapon)

	if ((damagetype == DAMAGE_BRUTE || damagetype == DAMAGE_BURN) && prob(25+(damage*2)))
		sparks.set_up(3,0,src)
		sparks.start()
	updatehealth()

	return 1

/mob/living/exosuit/rad_act(severity)
	return FALSE // Pilots already query rads, modify this for radiation alerts and such

/mob/living/exosuit/get_rads()
	. = ..()
	if(!hatch_closed || (body.pilot_coverage < 100)) //Open, environment is the source
		return .
	var/list/after_armor = modify_damage_by_armor(null, ., DAMAGE_RADIATION, DAMAGE_FLAG_DISPERSED, src, 0, TRUE)
	return after_armor[1]

/mob/living/exosuit/getFireLoss()
	var/total = 0
	for(var/obj/item/mech_component/MC in list(arms, legs, body, head))
		if(MC)
			total += MC.burn_damage
	return total

/mob/living/exosuit/getBruteLoss()
	var/total = 0
	for(var/obj/item/mech_component/MC in list(arms, legs, body, head))
		if(MC)
			total += MC.brute_damage
	return total

/mob/living/exosuit/emp_act(severity)
	if (status_flags & GODMODE)
		return
	//[SIERRA-ADD] - Mechs-by-Shegar - Эми удар по щиту
	for(var/obj/aura/mechshield/thing in auras)
		if(thing.active)
			thing.emp_attack(severity)
			return
	//[SIERRA-ADD]
	var/ratio = get_blocked_ratio(null, DAMAGE_BURN, null, (3-severity) * 20) // HEAVY = 40; LIGHT = 20

	if(ratio >= 0.5)
		for(var/mob/living/m in pilots)
			to_chat(m, SPAN_NOTICE("Your Faraday shielding absorbed the pulse!"))
		return
	else if(ratio > 0)
		for(var/mob/living/m in pilots)
			to_chat(m, SPAN_NOTICE("Your Faraday shielding mitigated the pulse!"))

	emp_damage += round((12 - (severity*3))*( 1 - ratio))
	for(var/obj/item/thing in list(arms,legs,head,body))
		thing.emp_act(severity)
	if(!hatch_closed || !prob(body.pilot_coverage))
		for(var/thing in pilots)
			var/mob/pilot = thing
			pilot.emp_act(severity)
	..()

/mob/living/exosuit/get_bullet_impact_effect_type(def_zone)
	return BULLET_IMPACT_METAL
