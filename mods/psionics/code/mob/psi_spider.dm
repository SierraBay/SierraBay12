/*
	Псионический паук — существо псионического плана.

	Невидим для всех, кроме активных псиоников.
	Атакует только тех, кто может его воспринимать (psi && !psi.suppressed).
	При укусе вызывает пси-шок: краткая дезориентация и потеря псионической выносливости.
*/

// =============================================================================
// AI holder — атакует исключительно активных псиоников
// =============================================================================

/datum/ai_holder/simple_animal/melee/psi_spider

/datum/ai_holder/simple_animal/melee/psi_spider/can_pursue(atom/movable/T)
	if(!isliving(T))
		return FALSE
	var/mob/living/L = T
	// Цель должна быть активным псиоником — иначе паук её «не замечает».
	if(!L.psi || L.psi.suppressed)
		return FALSE
	return ..()

// =============================================================================
// Паук
// =============================================================================

/mob/living/simple_animal/hostile/giant_spider/psi
	name = "Мерцающий Паук"
	desc = "Призрачный паук, существующий на грани реальности. Он не отбрасывает тени. Виден лишь тем, чей разум пробуждён."

	// Используем спрайт lurker'а — полупрозрачный, потусторонний вид.
	icon_state = "lurker"
	icon_living = "lurker"
	icon_dead = "lurker_dead"

	invisibility = INVISIBILITY_PSI_PLANE

	maxHealth = 55
	health = 55

	// Укус наносит пси-шок: сбивает концентрацию и тратит пси-выносливость.
	natural_weapon = /obj/item/natural_weapon/bite/spider/psi

	// Не отравляет обычным ядом — только псионический эффект (см. apply_melee_effects).
	poison_chance = 0

	movement_cooldown = 3
	base_attack_cooldown = 1 SECOND

	ai_holder = /datum/ai_holder/simple_animal/melee/psi_spider

	faction = "psi_spiders"

	// Паук существует на псионическом плане — не боится обычной атмосферы.
	min_gas = null
	max_gas = null
	minbodytemp = 0
	maxbodytemp = INFINITY


/obj/item/natural_weapon/bite/spider/psi
	name = "псионические жвалы"
	force = 12

/mob/living/simple_animal/hostile/giant_spider/psi/death(gibbed, deathmessage, show_dead_message)
	visible_message(SPAN_WARNING("\The [src] распадается на мерцающие осколки и растворяется в воздухе."))
	// Псионики, видевшие смерть паука, ощущают лёгкий резонанс.
	for(var/mob/living/observer in range(5, src))
		if(observer.psi && !observer.psi.suppressed)
			to_chat(observer, SPAN_WARNING("Ты чувствуешь, как что-то распадается поблизости — слабая волна ментального эха."))
	qdel(src)

// Не-псионики проходят сквозь паука — он для них бесплотен.
/mob/living/simple_animal/hostile/giant_spider/psi/CanPass(atom/movable/mover, turf/target, height=1.5, air_group=0)
	if(!air_group && height > 0 && isliving(mover))
		var/mob/living/L = mover
		if(!L.psi || L.psi.suppressed)
			return TRUE
	return ..()

// Блокируем взаимодействие для не-псиоников.
/mob/living/simple_animal/hostile/giant_spider/psi/attack_hand(mob/user)
	if(!can_perceive_psi_plane(user))
		return
	return ..()

// Псионический эффект укуса: напрямую сосут пси-стамину цели.
/mob/living/simple_animal/hostile/giant_spider/psi/apply_melee_effects(atom/A)
	if(!isliving(A))
		return
	var/mob/living/L = A
	if(!L.psi || L.psi.suppressed)
		return
	var/drain = rand(8, 15)
	L.psi.stamina = max(0, L.psi.stamina - drain)
	if(L.psi.ui)
		L.psi.ui.update_icon()
	to_chat(L, SPAN_DANGER("Укус [src] обжигает разум — твоя пси-концентрация рассеивается!"))
	// Краткое псионическое оглушение.
	if(prob(35))
		L.psi.stun = max(L.psi.stun, 3)
		to_chat(L, SPAN_WARNING("Ментальный разряд бьёт по твоему сознанию — силы на секунды ускользают!"))
