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
	//Делаем эффект попадания по меху, ииискрыы
	deploy_mech_hit_effect()
	//Попадание с фронта
	if(local_dir == turn(dir, -45) || local_dir == turn(dir, 0) || local_dir == turn(dir, 45))
		P.damage = ( P.damage * target.front_modificator_damage ) + target.front_additional_damage
	//Попадание с тыла
	else if(local_dir == turn(dir, 180) || local_dir == turn(dir, -135) || local_dir == turn(dir, 135))
		//В случае если у нас есть пилоты скинем их при атаке по спине.
		if(passengers_ammount > 0)
			external_leaving_passenger(mode = MECH_DROP_ALL_PASSENGERS)
		P.damage = ( P.damage * target.back_modificator_damage ) + target.back_additional_damage

	//В случае если атака приходит в голову/лицо/глаза/пузо - снаряд может напрямую ранить пилота при условии
	//что кабина меха открыта
	if(def_zone == BP_HEAD || def_zone == BP_CHEST || def_zone == BP_MOUTH || def_zone == BP_EYES)
		if(LAZYLEN(pilots) && (!hatch_closed || !prob(body.pilot_coverage)))
			if(local_dir != turn(dir,-135) || local_dir != turn(dir,135) || local_dir != turn(dir,180))
				var/mob/living/pilot = pick(pilots)
				return pilot.bullet_act(P, def_zone, used_weapon)
	..()

/mob/living/exosuit/proc/deploy_mech_hit_effect()
	set waitfor = FALSE
	new /obj/particle_emitter/mech_hit (get_turf(src))


/particles/mech_hit
	name = "mech_hit_sparks"
	width = 500
	height = 500
	count = 3000
	spawning = 15
	lifespan = 0.4 SECONDS
	fade = 0.3 SECONDS
	position = generator("circle", -3, 3, NORMAL_RAND)
	velocity = generator("circle", -12, 12, NORMAL_RAND)
	friction = 0.25
	gradient = list(
		0.0, "#ffcc00", // Ярко-желтый
		0.2, "#ff6600", // Оранжевый
		0.5, "#ff3300", // Красно-оранжевый
		1.0, "#fffffFf"  // Белый (при затухании)
	)
	color_change = 0.3
	scale = generator("vector", list(0.1, 0.1), list(0.3, 0.3), NORMAL_RAND) // Разный размер частиц
	rotation = generator("num", -180, 180) // Вращение частиц
	grow = -0.05

/obj/particle_emitter/mech_hit
	plane = 3
	layer = FIRE_LAYER
	particle_type = "mech_hit_sparks"

/obj/particle_emitter/mech_hit/New(loc, ...)
	. = ..()
	//расположение партиклов немного изменяется для лучшего визуала
	pixel_x = pick(-12, -8, -4,  0, 4, 8, 12)
	pixel_y = pick(-12, -8, -4,  0, 4, 8, 12)
	particles.spawning = 6
	sleep(0.1 SECONDS)
	particles.spawning = 0
	sleep(0.4 SECONDS)
	qdel(src)
