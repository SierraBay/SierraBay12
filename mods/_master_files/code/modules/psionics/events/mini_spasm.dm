/datum/event/minispasm
	var/alarm_sound = 'packs/infinity/sound/misc/foundation_alarm.ogg'
	var/end_sound = 'packs/infinity/sound/misc/foundation_restore.ogg'

/datum/event/minispasm/announce()
	priority_announcement.Announce( \
		"ПРИОРИТЕТНОЕ ОПОВЕЩЕНИЕ: Ф-[rand(50,80)] ОБНАРУЖЕНА ЛОКАЛЬНАЯ ПЕРЕДАЧА ПСИОНИЧЕСКОГО СИГНАЛА ([rand(70,100)]% СОВПАДЕНИЕ) \
		(ИСТОЧНИК СИГНАЛА ТРИАНГУЛИРОВАН — СОСЕДНИЙ МЕСТНЫЙ УЧАСТОК): Всем сотрудникам рекомендуется избегать \
		воздействия активного аудиопередающего оборудования, включая радиогарнитуры и переговорные устройства \
		на время трансляции сигнала.", \
		"Автоматическое сообщение массива датчиков Фонда Кухулин" \
	)
	sound_to(world, sound(alarm_sound))

/datum/event/minispasm/start()
	var/list/victims = list()
	for(var/obj/item/device/radio/radio in GLOB.listening_objects)
		if(radio.on)
			for(var/mob/living/victim in view(radio.canhear_range, radio.loc))
				if(isnull(victims[victim]) && victim.stat == CONSCIOUS && !victim.ear_deaf)
					victims[victim] = radio
	for(var/thing in victims)
		var/mob/living/victim = thing
		var/obj/item/device/radio/source = victims[victim]
		do_spasm(victim, source)

/datum/event/minispasm/end()
	priority_announcement.Announce( \
		"ПРИОРИТЕТНОЕ ОПОВЕЩЕНИЕ: ТРАНСЛЯЦИЯ СИГНАЛА ПРЕКРАЩЕНА. Персоналу разрешено возобновить использование незащищенного радиопередающего оборудования. Хорошего дня.", \
		"Автоматическое сообщение массива датчиков Фонда Кухулин" )
	sound_to(world, sound(end_sound))

/datum/event/minispasm/do_spasm(mob/living/victim, obj/item/device/radio/source)
	set waitfor = 0

	if(iscarbon(victim) && !victim.isSynthetic())
		var/list/disabilities = list(NEARSIGHTED, EPILEPSY, NERVOUS)
		for(var/disability in disabilities)
			if(victim.disabilities & disability)
				disabilities -= disability
		if(length(disabilities))
			victim.disabilities |= pick(disabilities)

	if(victim.psi)
		to_chat(victim, SPAN_DANGER("A hauntingly familiar sound hisses from [icon2html(source, victim)] \the [source], and your vision flickers!"))
		victim.psi.backblast(rand(5,15))
		victim.Paralyse(5)
		victim.make_jittery(100)
	else
		to_chat(victim, SPAN_DANGER("An indescribable, brain-tearing sound hisses from [icon2html(source, victim)] \the [source], and you collapse in a seizure!"))
		victim.seizure()
		victim.adjustBrainLoss(rand(5,15))
	sleep(45)

	if(victim.psi)
		victim.psi.check_latency_trigger(100, "a psionic scream", redactive = TRUE)

	if(!victim.psi && prob(5))
		var/new_latencies = rand(1,4)
		var/list/faculties = list(PSI_COERCION, PSI_REDACTION, PSI_ENERGISTICS, PSI_PSYCHOKINESIS)
		for(var/i = 1 to new_latencies)
			to_chat(victim, SPAN_DANGER(FONT_LARGE(pick(psi_operancy_messages))))
			victim.adjustBrainLoss(rand(5,10))
			victim.set_psi_rank(pick_n_take(faculties), 1)
			sleep(30)
		if(victim.psi)
			victim.psi.update()
