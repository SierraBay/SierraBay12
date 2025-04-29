/mob/living/exosuit/proc/runOver(mob/living/target) //Нам нужно проверить весь турф на наличие обьектов, которые мы можем протоптать
	var/mob/living/pilot = pick(pilots)
	if(L_leg.bump_safety && R_leg.bump_safety && pilot.a_intent != I_HURT) //Мы не хотим топтать и ноги могут не топтать?
		return //Не топчем
	src.visible_message(SPAN_DANGER("forcefully tramples [target] on the floor!"), blind_message = SPAN_DANGER("You hear the loud hissing of hydraulics!"))
	target.apply_effects(5, 5) //Чтоб не вставал
	var/damage = rand(5, 10)
	damage = 2 * (damage * (total_weight / 1000)  + (L_leg.bump_type * 3) + (R_leg.bump_type * 3)) // 30 урона в лучшем случае по груди и голове
	target.apply_damage(0.1 * damage, DAMAGE_BRUTE, BP_HEAD)
	target.apply_damage(0.2 * damage, DAMAGE_BRUTE, BP_CHEST)
	target.apply_damage(0.2 * damage, DAMAGE_BRUTE, BP_GROIN)
	target.apply_damage(0.1 * damage, DAMAGE_BRUTE, BP_L_LEG)
	target.apply_damage(0.1 * damage, DAMAGE_BRUTE, BP_R_LEG)
	target.apply_damage(0.1 * damage, DAMAGE_BRUTE, BP_L_FOOT)
	target.apply_damage(0.1 * damage, DAMAGE_BRUTE, BP_R_FOOT)
	target.apply_damage(0.025 * damage, DAMAGE_BRUTE, BP_L_ARM)
	target.apply_damage(0.025 * damage, DAMAGE_BRUTE, BP_R_ARM)
	target.apply_damage(0.025 * damage, DAMAGE_BRUTE, BP_L_HAND)
	target.apply_damage(0.025 * damage, DAMAGE_BRUTE, BP_R_HAND)

/mob/living/exosuit/Bump(mob/living/target)
	..()
	//Что здесь происходит? Спрева мы проверяем что цель моб, подходящего размера
	if(!istype(target, /mob/living) || target.mob_size > MOB_LARGE || target.mob_size == MOB_LARGE)
		return
	//Здесь костыль, почему-то мех вызывает Bump() дважды.
	if(Bumps != 1)
		Bumps = !Bumps
		return
	Bumps = !Bumps
	collision_attack(target)
	return

/mob/living/exosuit/proc/collision_attack(mob/living/target,bump_type) //Attack colissioned things
	if(world.time - last_collision < (L_leg.collision_coldown + R_leg.collision_coldown))
		return
	var/additional_modificator = 0
	var/mob/living/pilot = pick(pilots)
	if(pilot.a_intent == I_HURT)
		additional_modificator = 1
	else
		additional_modificator = 0.5
	last_collision = world.time
	if(L_leg.bump_safety && R_leg.bump_safety && pilot.a_intent != I_HURT) //Мы не хотим таранить и ноги могут не таранить?
		return //Не тараним
	src.visible_message(SPAN_DANGER("[src] сталкивает [target] со своего пути!"), blind_message = SPAN_DANGER("You hear the loud hissing of hydraulics!"))
	var/damage = ( ( 0.00005 * total_weight * L_leg.bump_type * R_leg.bump_type * 1 MINUTE ) / current_speed) * additional_modificator
	current_speed = L_leg.min_speed + R_leg.min_speed
	//Да, можно сделать цикл, но А) Хуже читается Б) Вообще никак не поможет производительности
	target.apply_damage(0.1 * damage, DAMAGE_BRUTE, BP_HEAD)
	target.apply_damage(0.2 * damage, DAMAGE_BRUTE, BP_CHEST)
	target.apply_damage(0.2 * damage, DAMAGE_BRUTE, BP_GROIN)
	target.apply_damage(0.1 * damage, DAMAGE_BRUTE, BP_L_LEG)
	target.apply_damage(0.1 * damage, DAMAGE_BRUTE, BP_R_LEG)
	target.apply_damage(0.1 * damage, DAMAGE_BRUTE, BP_L_FOOT)
	target.apply_damage(0.1 * damage, DAMAGE_BRUTE, BP_R_FOOT)
	target.apply_damage(0.025 * damage, DAMAGE_BRUTE, BP_L_ARM)
	target.apply_damage(0.025 * damage, DAMAGE_BRUTE, BP_R_ARM)
	target.apply_damage(0.025 * damage, DAMAGE_BRUTE, BP_L_HAND)
	target.apply_damage(0.025 * damage, DAMAGE_BRUTE, BP_R_HAND)
