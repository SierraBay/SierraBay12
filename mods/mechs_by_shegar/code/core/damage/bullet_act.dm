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
			external_leaving_passenger(mode = MECH_DROP_ALL_PASSENGERS)
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
