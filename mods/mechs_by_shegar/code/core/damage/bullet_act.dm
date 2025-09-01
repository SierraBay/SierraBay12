/*
	// B B B
	// N M N  ↓ (Направление меха, смотрит на ЮГ)
	// F F F
	// M - Мех, F - Атака пришла в лицо, B - Атака пришла в спину N - Ничего(Без модификаторов)
*/
/mob/living/exosuit/bullet_act(obj/item/projectile/P, def_zone, used_weapon)

	if (status_flags & GODMODE)
		return PROJECTILE_FORCE_MISS

	var/obj/item/mech_component/target = zoneToComponent(def_zone)
	var/local_dir = get_dir(src, get_turf(P)) // <- Узнаём направление от меха до снаряда

	if(!istype(P, /obj/item/projectile/bullet/rpg_rocket))
		//Учитываем модификатор урона исходя из того с какой стороны в меха влетает снаряд.
		modify_projectile_damage(P, target, local_dir)
		if(target.installed_armor)
			if(!target.installed_armor.react_at_damage(P))
				return FALSE //Снаряд схаван бронёй

	P.damage_type = DAMAGE_BRUTE //Каким образом можно починить ПРОВОДАМИ прожжёную обшивку?
	//Проверяем, с какого направления прилетает атака!
	//Делаем эффект попадания по меху, ииискрыы
	deploy_mech_hit_effect()

	//В случае если атака приходит в голову/лицо/глаза/пузо - снаряд может напрямую ранить пилота при условии
	//что кабина меха открыта
	if(def_zone == BP_HEAD || def_zone == BP_CHEST || def_zone == BP_MOUTH || def_zone == BP_EYES)
		if(LAZYLEN(pilots) && (!hatch_closed || !prob(body.pilot_coverage)))
			if(local_dir != turn(dir,-135) || local_dir != turn(dir,135) || local_dir != turn(dir,180))
				var/mob/living/pilot = pick(pilots)
				return pilot.bullet_act(P, def_zone, used_weapon)
	..()


/mob/living/exosuit/proc/modify_projectile_damage(obj/item/projectile/P, obj/item/mech_component/mech_part, attack_dir)

	var/result_mod
	var/resul_add
	//Попадание с лица
	if(attack_dir == turn(dir, -45) || attack_dir == turn(dir, 0) || attack_dir == turn(dir, 45))
		result_mod = mech_part.front_modificator_damage
		resul_add = mech_part.front_additional_damage
	//Попадание с тыла
	else if(attack_dir == turn(dir, 180) || attack_dir == turn(dir, -135) || attack_dir == turn(dir, 135))
		//В случае если у нас есть пассажиры скинем их при атаке по спине.
		if(passengers_ammount > 0)
			external_leaving_passenger(mode = MECH_DROP_ALL_PASSENGERS)
		result_mod =  mech_part.back_modificator_damage
		resul_add = mech_part.back_additional_damage

	if(result_mod)
		P.damage *= result_mod
		P.mech_armor_damage *= result_mod
	if(resul_add)
		P.damage += resul_add
		P.mech_armor_damage += resul_add








//Визуал попадания
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
