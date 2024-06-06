/mob/living/exosuit/proc/runOver(mob/living/target) //Нам нужно проверить весь турф на наличие обьектов, которые мы можем протоптать
	var/mob/living/pilot = pick(pilots)
	if(legs.bump_safety && pilot.a_intent != I_HURT) //Мы не хотим топтать и ноги могут не топтать?
		return //Не топчем
	src.visible_message(SPAN_DANGER("С силой топчет [target] на полу!"), blind_message = SPAN_DANGER("You hear the loud hissing of hydraulics!"))
	target.apply_effects(5, 5) //Чтоб ахуел
	var/damage = rand(5, 7)
	damage = damage * legs.bump_type
	target.apply_damage(2 * damage, DAMAGE_BRUTE, BP_HEAD)
	target.apply_damage(2 * damage, DAMAGE_BRUTE, BP_CHEST)
	target.apply_damage(0.5 * damage, DAMAGE_BRUTE, BP_L_LEG)
	target.apply_damage(0.5 * damage, DAMAGE_BRUTE, BP_R_LEG)
	target.apply_damage(0.5 * damage, DAMAGE_BRUTE, BP_L_ARM)
	target.apply_damage(0.5 * damage, DAMAGE_BRUTE, BP_R_ARM)

/mob/living/exosuit/Bump(mob/living/target)
	..()
	if(!istype(target, /mob/living))
		return
	if(Bumps != 1)
		Bumps = !Bumps
		return
	Bumps = !Bumps
	collision_attack(target)
	return

/mob/living/exosuit/proc/collision_attack(mob/living/target,bump_type) //Attack colissioned things
	if(world.time - last_collision < legs.collision_coldown)
		return
	var/additional_modificator = 0
	var/mob/living/pilot = pick(pilots)
	if(pilot.a_intent == I_HURT)
		additional_modificator = 2 * legs.bump_type
	last_collision = world.time
	if(legs.bump_safety && pilot.a_intent != I_HURT) //Мы не хотим таранить и ноги могут не таранить?
		return //Не тараним
	src.visible_message(SPAN_DANGER("[src] rams [target] out of the way!"), blind_message = SPAN_DANGER("You hear the loud hissing of hydraulics!"))
	var/list/parts = list(BP_HEAD, BP_CHEST, BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM)
	for(var/i = 0, i < rand(1,5), i++)
		var/def_zone = pick(parts)
		var/damage = rand(2,5) * legs.bump_type + additional_modificator
		target.apply_damage(damage, DAMAGE_BRUTE, def_zone)
