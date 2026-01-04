/datum/event/psi
	startWhen = 30
	endWhen = 120

/datum/event/psi/announce()
	priority_announcement.Announce( \
		"Обнаружена локальная абнормальность в соседних псионических континуумах. Всем членам экипажа, обладающим психонетикой \
		рекомендовано приостановить работу и обратится к врачу в случае проявления симптомов.", \
		"Автоматическое сообщение массива датчиков Фонда Кухулин" \
		)

/datum/event/psi/end()
	priority_announcement.Announce( \
		"Пси-абнормальность прекратилась и нормализовался исходный уровень. \
		Все, с чем вы по-прежнему не можете справиться, является вашей личной проблемой.", \
		"Автоматическое сообщение массива датчиков Фонда Кухулин" \
	)

/datum/event/psi/tick()
	for(var/thing in SSpsi.processing)
		apply_psi_effect(thing)

/datum/event/psi/proc/apply_psi_effect(datum/psi_complexus/psi)
	return
