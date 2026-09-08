/*
	Псионический бродяга — существо псионического плана.

	Невидим для всех, кроме активных псиоников.
	Атакует только тех, кто может его воспринимать (psi && !psi.suppressed).
	При нападении присасывается и вызывает пси-отдачу, если стамина цели на нуле.
*/

// =============================================================================
// AI holder — атакует исключительно активных псиоников
// =============================================================================

/datum/ai_holder/hostile/melee/vagrant/psi

/datum/ai_holder/hostile/melee/vagrant/psi/can_pursue(atom/movable/T)
	if(!isliving(T))
		return FALSE
	var/mob/living/L = T
	// Цель должна быть активным псиоником — иначе бродяга её «не замечает».
	if(!L.psi || L.psi.suppressed)
		return FALSE
	return ..()


// =============================================================================
// Бродяга
// =============================================================================

/mob/living/simple_animal/hostile/vagrant/psi
	desc = "Strange creature, resonating with psionic power. Run."

	maxbodytemp = INFINITY

	invisibility = INVISIBILITY_PSI_PLANE
	var/stamina_per_tick = 3

	ai_holder = /datum/ai_holder/hostile/melee/vagrant/psi

	faction = "psi_breach"


/mob/living/simple_animal/hostile/vagrant/psi/death(gibbed, deathmessage, show_dead_message)
	visible_message(SPAN_WARNING("\The [src] распадается на мерцающие осколки и растворяется в воздухе."))
	// Псионики, видевшие смерть бродяги, ощущают лёгкий резонанс.
	for(var/mob/living/observer in range(5, src))
		if(observer.psi && !observer.psi.suppressed)
			to_chat(observer, SPAN_WARNING("Ты чувствуешь, как что-то распадается поблизости — слабая волна ментального эха."))
	qdel(src)

// Не-псионики проходят сквозь бродягу — он для них бесплотен.
/mob/living/simple_animal/hostile/vagrant/psi/CanPass(atom/movable/mover, turf/target, height=1.5, air_group=0)
	if(!air_group && height > 0 && isliving(mover))
		var/mob/living/L = mover
		if(!L.psi || L.psi.suppressed)
			return TRUE
	return ..()

// Блокируем взаимодействие для не-псиоников.
/mob/living/simple_animal/hostile/vagrant/psi/attack_hand(mob/user)
	if(!can_perceive_psi_plane(user))
		return
	return ..()

/datum/ai_holder/hostile/melee/vagrant/psi/engage_target()
	if(!ishuman(target))
		return FALSE
	var/mob/living/L = target
	// Цель должна быть активным псиоником — иначе бродяга её «не замечает».
	if(!L.psi || L.psi.suppressed)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/vagrant/psi/Life()
	. = ..()
	if(!.)
		return FALSE
	if(gripping)
		invisibility = null
		if(!(get_turf(src) == get_turf(gripping)))
			gripping = null
			invisibility = INVISIBILITY_PSI_PLANE

		else if(gripping.psi)
			var/stamina_volume = gripping.psi.stamina
			if(stamina_volume > 5)
				gripping.psi.spend_power(stamina_per_tick)
				health = min(health + health_per_tick, maxHealth)
				if(prob(15))
					to_chat(gripping, SPAN_DANGER("Вы чувствуете, как ваши псионические силы высасывают!"))
			else
				gripping.psi.backblast(rand(5,10))
				gripping = null
				invisibility = INVISIBILITY_PSI_PLANE

		if(turns_per_move != initial(turns_per_move))
			turns_per_move = initial(turns_per_move)

	if(stance == STANCE_IDLE && !cloaked)
		cloaked = 1
		update_icon()
	if(health == maxHealth)
		new/mob/living/simple_animal/hostile/vagrant(src.loc)
		new/mob/living/simple_animal/hostile/vagrant(src.loc)
		gib()
		return
