/mob/living/carbon/human
	var/list/health_controllers = list()
	var/trait_eye_protection = FALSE
	var/trait_ear_protection = FALSE

/mob/living/carbon/human/eyecheck()
	var/base = ..()
	if(src.trait_eye_protection)
		return max(base, 2)
	return base

/mob/living/carbon/human/get_sound_volume_multiplier()
	var/base = ..()
	if(src.trait_ear_protection)
		return 0.0
	return base


/mob/living/carbon/human/proc/add_asthma()
	var/datum/asthma_controller/H = new /datum/asthma_controller(src)
	health_controllers += H
	H.Start()

/mob/living/carbon/human/proc/add_headache()
	var/datum/headache_controller/H = new /datum/headache_controller(src)
	health_controllers += H
	H.Start()

/mob/living/carbon/human/proc/add_hallucinations()
	var/datum/hallucinations_controller/H = new /datum/hallucinations_controller(src)
	health_controllers += H
	H.Start()

/mob/living/carbon/human/proc/add_seizures()
	var/datum/seizures_controller/H = new /datum/seizures_controller(src)
	health_controllers += H
	H.Start()

/mob/living/carbon/human/proc/add_blindness()
	var/datum/blindness_controller/H = new /datum/blindness_controller(src)
	health_controllers += H
	H.Start()

/mob/living/carbon/human/proc/add_deafness()
	var/datum/deafness_controller/H = new /datum/deafness_controller(src)
	health_controllers += H
	H.Start()

/mob/living/carbon/human/proc/add_muteness()
	var/datum/muteness_controller/H = new /datum/muteness_controller(src)
	health_controllers += H
	H.Start()

// АСТМА
/datum/asthma_controller
	var/mob/living/carbon/human/owner
	var/attack_active = FALSE
	var/attack_end_time = 0
	var/attack_next_tick_time = 0
	var/next_random_attack_time = 0
	var/livedata_check_active = FALSE
	var/livedata_window_time = 0
	var/livedata_next_poll_time = 0
	var/stamina_trigger_threshold = 0
	var/running = FALSE
	var/oxygenated_check_time = 0
	var/list/asthma_pulse_phrases = list(
		"Сердце колотится, дыхание с трудом удерживается...",
		"Воздуха не хватает, сердце вот-вот выпрыгнет из груди!",
		"Сердце быстро бьётся, дыхание выходит из-под контроля!",
		"Я не могу выровнять дыхание, начинаю задыхаться!"
	)
	var/list/asthma_stamina_phrases = list(
		"Воздуха не хватает, не могу отдышаться...",
		"Я так устал, мне не хватает воздуха...",
		"Тяжело вдохнуть, усталость берёт своё...",
		"Слабость давит на грудь, дыхание учащается..."
	)
	var/list/asthma_random_phrases = list(
		"Что-то давит в горле. Дышать тяжело...",
		"Горло перехватило - мне тяжело выдохнуть!",
		"Кажется, воздуха не хватает...",
		"Сложно выдохнуть, грудь стягивает."
	)
	var/list/asthma_timer_end_phrases = list(
		"Дышать становится легче...",
		"Приступ постепенно проходит...",
		"Кажется, приступ проходит...",
		"Лёгкие начинают справляться. Дыхание выравнивается..."
	)
	var/list/asthma_oxygen_end_phrases = list(
		"Лёгкие насыщаются кислородом, дыхание выравнивается.",
		"Лекарство помогает, воздух идёт легко.",
		"Приходит облегчение, дышать вновь просто...",
		"Ощущаю лекарство, лёгкие расслабляются."
	)
/datum/asthma_controller/New(mob/living/carbon/human/H)
	..()
	owner = H
	next_random_attack_time = world.time + rand(60 MINUTES, 80 MINUTES)
	livedata_window_time = world.time + rand(15 MINUTES, 30 MINUTES)

/datum/asthma_controller/proc/Start()
	if(running || !owner) return
	running = TRUE
	ProcessAsthma()

/datum/asthma_controller/proc/Stop()
	running = FALSE

/datum/asthma_controller/proc/ProcessAsthma()
	if(!running || !owner || owner.stat == DEAD) return

	if(attack_active && world.time >= attack_next_tick_time)
		owner.adjustOxyLoss(rand(5, 8))
		if(prob(50))
			owner.emote("gasp")
		attack_next_tick_time = world.time + 2 SECONDS
		if(world.time >= attack_end_time)
			attack_active = FALSE
			to_chat(owner, SPAN_NOTICE(pick(asthma_timer_end_phrases)))
			livedata_window_time = world.time + rand(15 MINUTES, 30 MINUTES)
	if(attack_active)
		if(owner.chem_effects[CE_OXYGENATED])
			if(!oxygenated_check_time)
				oxygenated_check_time = world.time + 5 SECONDS
		else
			oxygenated_check_time = 0

		if(oxygenated_check_time && world.time >= oxygenated_check_time)
			if(owner.chem_effects[CE_OXYGENATED])
				attack_active = FALSE
				to_chat(owner, SPAN_NOTICE(pick(asthma_oxygen_end_phrases)))
				livedata_window_time = world.time + rand(15 MINUTES, 30 MINUTES)
			oxygenated_check_time = 0

	if(!attack_active && world.time >= next_random_attack_time)
		StartAttack()
		to_chat(owner, SPAN_DANGER(pick(asthma_random_phrases)))
		next_random_attack_time = world.time + rand(40 MINUTES, 80 MINUTES)

	if(livedata_check_active && world.time >= livedata_next_poll_time)
		var/pulse_bpm = owner.get_pulse_as_number()
		if(pulse_bpm >= 100 && pulse_bpm != 150)
			var/chance = (pulse_bpm >= 140) ? 80 : 30
			if(prob(chance))
				StartAttack()
				to_chat(owner, SPAN_DANGER(pick(asthma_pulse_phrases)))
				livedata_check_active = FALSE
				livedata_window_time = world.time + rand(15 MINUTES, 30 MINUTES)
		if(owner.stamina < stamina_trigger_threshold)
			if(prob(60))
				StartAttack()
				to_chat(owner, SPAN_DANGER(pick(asthma_stamina_phrases)))
				livedata_check_active = FALSE
				livedata_window_time = world.time + rand(15 MINUTES, 30 MINUTES)
			else
				livedata_next_poll_time = world.time + 3 SECONDS
		else
			livedata_next_poll_time = world.time + 3 SECONDS

	if(!livedata_check_active && world.time >= livedata_window_time)
		livedata_check_active = TRUE
		stamina_trigger_threshold = rand(20, 50)
		livedata_next_poll_time = world.time + 3 SECONDS

	var/next_wake = max(1, min(
		attack_active ? attack_next_tick_time : next_random_attack_time,
		livedata_check_active ? livedata_next_poll_time : livedata_window_time,
		oxygenated_check_time ? oxygenated_check_time : INFINITY
	))
	addtimer(new Callback(src, .proc/ProcessAsthma), max(1, next_wake - world.time))

/datum/asthma_controller/proc/StartAttack()
	if(attack_active || !owner || owner.stat == DEAD) return
	attack_active = TRUE
	attack_end_time = world.time + rand(1 MINUTE, 3 MINUTES)
	attack_next_tick_time = world.time
	livedata_check_active = FALSE
	oxygenated_check_time = 0

// МИГРЕНИ
/datum/headache_controller
	var/mob/living/carbon/human/owner
	var/pain_active = FALSE
	var/residual_active = FALSE
	var/running = FALSE
	var/pain_end_time = 0
	var/residual_end_time = 0
	var/next_pain = 0
	var/list/headache_start_phrases = list(
		"Резкая боль пронзает голову!",
		"В висках пульсирует. Голова начинает болеть...",
		"Давление в голове растёт.",
		"Висок тянет и пульсирует, появляется сильная боль."
	)

/datum/headache_controller/New(mob/living/carbon/human/H)
	..()
	owner = H
	next_pain = world.time + rand(15 MINUTES, 30 MINUTES)

/datum/headache_controller/proc/Start()
	if(running || !owner) return
	running = TRUE
	ProcessHeadache()

/datum/headache_controller/proc/Stop()
	running = FALSE

/datum/headache_controller/proc/ProcessHeadache()
	if(!running || !owner || owner.stat == DEAD) return

	if(!pain_active && world.time >= next_pain)
		pain_active = TRUE
		pain_end_time = world.time + rand(10 SECONDS, 20 SECONDS)
		to_chat(owner, SPAN_WARNING(pick(headache_start_phrases)))

	if(pain_active)
		owner.apply_damage(rand(10, 15), DAMAGE_PAIN, BP_HEAD)
		if(world.time >= pain_end_time)
			pain_active = FALSE
			residual_active = TRUE
			residual_end_time = world.time + rand(3 MINUTES, 6 MINUTES)
			next_pain = world.time + rand(20 MINUTES, 60 MINUTES)

	if(residual_active)
		owner.apply_damage(rand(2, 3), DAMAGE_PAIN, BP_HEAD)
		if(world.time >= residual_end_time)
			residual_active = FALSE

	var/next_delay
	if(pain_active || residual_active)
		next_delay = 50
	else
		next_delay = max(1, next_pain - world.time)

	addtimer(new Callback(src, .proc/ProcessHeadache), next_delay)


// ГАЛЛЮЦИНАЦИИ
/datum/hallucinations_controller
	var/mob/living/carbon/human/owner
	var/next_hallucination = 0
	var/running = FALSE

/datum/hallucinations_controller/New(mob/living/carbon/human/H)
	..()
	owner = H
	next_hallucination = world.time + rand(15 MINUTES, 30 MINUTES)

/datum/hallucinations_controller/proc/Start()
	if(running || !owner) return
	running = TRUE
	ProcessHallucinations()

/datum/hallucinations_controller/proc/Stop()
	running = FALSE

/datum/hallucinations_controller/proc/ProcessHallucinations()
	if(!running || !owner || owner.stat == DEAD) return

	if(world.time >= next_hallucination)
		owner.hallucination(rand(200, 500), pick(20, 30, 40, 50))
		next_hallucination = world.time + rand(20 MINUTES, 40 MINUTES)

	var/next_wake = max(1, next_hallucination - world.time)
	addtimer(new Callback(src, .proc/ProcessHallucinations), next_wake)


// ПРИПАДКИ
/datum/seizures_controller
	var/mob/living/carbon/human/owner
	var/next_seizure = 0
	var/running = FALSE

/datum/seizures_controller/New(mob/living/carbon/human/H)
	..()
	owner = H
	next_seizure = world.time + rand(15 MINUTES, 30 MINUTES)

/datum/seizures_controller/proc/Start()
	if(running || !owner) return
	running = TRUE
	ProcessSeizures()

/datum/seizures_controller/proc/Stop()
	running = FALSE

/datum/seizures_controller/proc/ProcessSeizures()
	if(!running || !owner || owner.stat == DEAD) return

	if(world.time >= next_seizure)
		owner.seizure()
		next_seizure = world.time + rand(20 MINUTES, 40 MINUTES)

	var/next_wake = max(1, next_seizure - world.time)
	addtimer(new Callback(src, .proc/ProcessSeizures), next_wake)

//ГЛУХОТА
/datum/deafness_controller
	var/mob/living/carbon/human/owner
	var/running = FALSE

/datum/deafness_controller/New(mob/living/carbon/human/H)
	..()
	owner = H

/datum/deafness_controller/proc/Start()
	if(running || !owner || owner.stat == DEAD)
		return
	running = TRUE
	owner.ear_deaf = INFINITY
	owner.trait_ear_protection = TRUE
	Enforce()

/datum/deafness_controller/proc/Stop()
	running = FALSE
	owner.ear_deaf = 0

/datum/deafness_controller/proc/Enforce()
	if(!running || !owner || owner.stat == DEAD)
		return
	if(owner.ear_deaf != INFINITY)
		owner.ear_deaf = INFINITY
	owner.set_sdisability(DEAFENED)
	addtimer(new Callback(src, .proc/Enforce), 20)

//НЕМOТА
/datum/muteness_controller
	var/mob/living/carbon/human/owner
	var/running = FALSE

/datum/muteness_controller/New(mob/living/carbon/human/H)
	..()
	owner = H

/datum/muteness_controller/proc/Start()
	if(running || !owner || owner.stat == DEAD)
		return
	running = TRUE
	owner.silent = INFINITY
	Enforce()

/datum/muteness_controller/proc/Stop()
	running = FALSE
	owner.silent = 0

/datum/muteness_controller/proc/Enforce()
	if(!running || !owner || owner.stat == DEAD)
		return
	if(owner.silent != INFINITY)
		owner.silent = INFINITY
	addtimer(new Callback(src, .proc/Enforce), 20)

//СЛЕПОТА
/datum/blindness_controller
	var/mob/living/carbon/human/owner
	var/running = FALSE

/datum/blindness_controller/New(mob/living/carbon/human/H)
	..()
	owner = H

/datum/blindness_controller/proc/Start()
	if(running || !owner || owner.stat == DEAD)
		return
	running = TRUE
	owner.eye_blind = INFINITY
	owner.trait_eye_protection = TRUE
	owner.monochromevision()
	Enforce()

/datum/blindness_controller/proc/Stop()
	running = FALSE
	owner.eye_blind = 0

/datum/blindness_controller/proc/Enforce()
	if(!running || !owner || owner.stat == DEAD)
		return
	if(owner.eye_blind != INFINITY)
		owner.eye_blind = INFINITY
	owner.set_sdisability(BLINDED)
	addtimer(new Callback(src, .proc/Enforce), 20)
