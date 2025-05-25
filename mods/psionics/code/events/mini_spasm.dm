/datum/event/minispasm
	startWhen = 60
	endWhen = 90
	var/static/list/psi_operancy_messages = list(
		"Что-то ползет в твоем черепе!",
		"Что-то разъедает твои мысли!",
		"Ты ощущаешь как твой мозг промывается чем-то!",
		"Ты испытываешь неприятное ощущение, словно через глаз, кто-то дотрагивается к твоему мозгу!",
		"<b>СИГНАЛ СИГНАЛ СИГНАЛ СИГНАЛ СИГНАЛ СИГНАЛ</b>"
		)

/datum/event/minispasm/announce()
	priority_announcement.Announce( \
		"ПРИОРИТЕТНОЕ ОПОВЕЩЕНИЕ: Ф-[rand(50,80)] ОБНАРУЖЕНА ЛОКАЛЬНАЯ ПЕРЕДАЧА ПСИОНИЧЕСКОГО СИГНАЛА ([rand(70,100)]% СОВПАДЕНИЕ) \
		(ИСТОЧНИК СИГНАЛА ТРИАНГУЛИРОВАН — СОСЕДНИЙ МЕСТНЫЙ УЧАСТОК): Всем сотрудникам рекомендуется избегать \
		воздействия активного аудиопередающего оборудования, включая радиогарнитуры и переговорные устройства \
		на время трансляции сигнала.", \
		"Автоматическое сообщение массива датчиков Фонда Кухулин" \
		)

/datum/event/minispasm/start()
	var/list/victims = list()
	for(var/obj/item/device/radio/radio in GLOB.listening_objects)
		if(radio.on)
			for(var/mob/living/victim in range(radio.canhear_range, radio.loc))
				if(isnull(victims[victim]) && victim.stat == CONSCIOUS && !victim.ear_deaf)
					victims[victim] = radio
	for(var/thing in victims)
		var/mob/living/victim = thing
		var/obj/item/device/radio/source = victims[victim]
		do_spasm(victim, source)

/datum/event/minispasm/proc/do_spasm(mob/living/victim, obj/item/device/radio/source)
	set waitfor = 0

	if(iscarbon(victim) && !victim.isSynthetic())
		var/list/disabilities = list(NEARSIGHTED, EPILEPSY, NERVOUS)
		for(var/disability in disabilities)
			if(victim.disabilities & disability)
				disabilities -= disability
		if(length(disabilities))
			victim.disabilities |= pick(disabilities)

	if(victim.psi)
		to_chat(victim, SPAN_DANGER("Слишком знакомый визг исходит из [icon2html(source, victim)] \the [source]. Твой разум мутнеет!"))
		victim.psi.backblast(rand(5,15))
		victim.Paralyse(5)
		victim.make_jittery(100)
	else
		to_chat(victim, SPAN_DANGER("Неописуемый, пронзительный визг исходит из [icon2html(source, victim)] \the [source]. Тебя охватывают судороги!"))
		victim.seizure()
		var/new_latencies = rand(2,4)
		var/list/faculties = list(PSI_COERCION, PSI_REDACTION, PSI_ENERGISTICS, PSI_PSYCHOKINESIS)
		for(var/i = 1 to new_latencies)
			to_chat(victim, SPAN_DANGER(FONT_LARGE(pick(psi_operancy_messages))))
			victim.adjustBrainLoss(rand(10,20))
			victim.set_psi_rank(pick_n_take(faculties), 1)
			sleep(30)
		victim.psi.update()
	sleep(45)
	victim.psi.check_latency_trigger(100, "психонетический крик", redactive = TRUE)

/datum/event/minispasm/end()
	priority_announcement.Announce( \
		"ПРИОРИТЕТНОЕ ОПОВЕЩЕНИЕ: ТРАНСЛЯЦИЯ СИГНАЛА ПРЕКРАЩЕНА. Персоналу разрешено возобновить использование незащищенного радиопередающего оборудования. Хорошего дня.", \
		"Автоматическое сообщение массива датчиков Фонда Кухулин" \
		)
