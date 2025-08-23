/mob/living/carbon/human
	var/list/health_controllers = list()

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
		if(world.time >= attack_end_time || owner.chem_effects[CE_OXYGENATED])
			attack_active = FALSE
			to_chat(owner, SPAN_NOTICE("Дышать становится легче..."))
			livedata_window_time = world.time + rand(15 MINUTES, 30 MINUTES)

	if(!attack_active && world.time >= next_random_attack_time)
		StartAttack("Что-то давит в горле. Дышать тяжело...")
		next_random_attack_time = world.time + rand(60 MINUTES, 80 MINUTES)

	if(livedata_check_active && world.time >= livedata_next_poll_time)
		var/pulse_bpm = owner.get_pulse_as_number()
		if(pulse_bpm >= 100 && pulse_bpm != 150)
			var/chance = (pulse_bpm >= 140) ? 80 : 30
			if(prob(chance))
				StartAttack("Дыхание выходит из-под контроля. Не хватает воздуха...")
				livedata_check_active = FALSE
				livedata_window_time = world.time + rand(15 MINUTES, 30 MINUTES)
		if(owner.stamina < stamina_trigger_threshold)
			if(prob(60))
				StartAttack("Не хватает воздуха. Тяжело дышать...")
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
		livedata_check_active ? livedata_next_poll_time : livedata_window_time
	))
	addtimer(new Callback(src, .proc/ProcessAsthma), max(1, next_wake - world.time))

/datum/asthma_controller/proc/StartAttack(reason)
	if(attack_active || !owner || owner.stat == DEAD) return
	attack_active = TRUE
	attack_end_time = world.time + rand(1 MINUTE, 3 MINUTES)
	attack_next_tick_time = world.time
	to_chat(owner, SPAN_DANGER("[reason]"))
	livedata_check_active = FALSE

// МИГРЕНИ
/datum/headache_controller
	var/mob/living/carbon/human/owner
	var/pain_active = FALSE
	var/next_pain = 0
	var/pain_end_time = 0
	var/running = FALSE
	var/residual_end_time = 0
	var/residual_active = FALSE

/datum/headache_controller/New(mob/living/carbon/human/H)
	..()
	owner = H
	next_pain = world.time + rand(20 MINUTES, 60 MINUTES)

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
		pain_end_time = world.time + rand(30 SECONDS, 60 SECONDS)
		to_chat(owner, SPAN_WARNING("Резкая боль пронзает голову!"))

	if(pain_active)
		owner.apply_damage(rand(5, 10), DAMAGE_PAIN, BP_HEAD)
		if(world.time >= pain_end_time)
			pain_active = FALSE
			residual_active = TRUE
			residual_end_time = world.time + rand(3 MINUTES, 6 MINUTES)
			next_pain = world.time + rand(20 MINUTES, 60 MINUTES)

	if(residual_active)
		owner.apply_damage(rand(2, 4), DAMAGE_PAIN, BP_HEAD)
		if(world.time >= residual_end_time)
			residual_active = FALSE

	var/next_wake = max(1, min(
		pain_active ? pain_end_time : next_pain,
		residual_active ? residual_end_time : next_pain
	))
	addtimer(new Callback(src, .proc/ProcessHeadache), max(1, next_wake - world.time, 15))


// ГАЛЛЮЦИНАЦИИ
/datum/hallucinations_controller
	var/mob/living/carbon/human/owner
	var/next_hallucination = 0
	var/running = FALSE

/datum/hallucinations_controller/New(mob/living/carbon/human/H)
	..()
	owner = H
	next_hallucination = world.time + rand(30 MINUTES, 60 MINUTES)

/datum/hallucinations_controller/proc/Start()
	if(running || !owner) return
	running = TRUE
	ProcessHallucinations()

/datum/hallucinations_controller/proc/Stop()
	running = FALSE

/datum/hallucinations_controller/proc/ProcessHallucinations()
	if(!running || !owner || owner.stat == DEAD) return

	if(world.time >= next_hallucination)
		owner.hallucination(rand(50, 500), rand(50, 500))
		next_hallucination = world.time + rand(30 MINUTES, 60 MINUTES)

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
		next_seizure = world.time + rand(20 MINUTES, 60 MINUTES)

	var/next_wake = max(1, next_seizure - world.time)
	addtimer(new Callback(src, .proc/ProcessSeizures), next_wake)
