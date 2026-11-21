/singleton/psi_disorder/dissocial
	id =          "dissocial"
	name =        "Диссоциальное пси-растройство личности"
	group =       "red"
	description = "Эпизоды диссоциального расстройства личности (социопатия, психопатия) на фоне приобретённых способностей. Псионик игнорирует общественные нормы морали и установленные государством законы, считая себя выше этого. Данное состояние может как проявляться активно, так и протекать менее заметно, в зависимости от способностей псионика."
	delay_min =   5 MINUTES
	delay_max =   15 MINUTES

/singleton/psi_disorder/dissocial/on_power_used(mob/living/owner, datum/psi_complexus/psi, singleton/psionic_power/power, list/state)
	// Агрессивные способности отдают частью сил обратно.
	if(power.use_intent == I_HURT || power.use_intent == I_DISARM)
		psi.stamina = min(psi.max_stamina, psi.stamina + 5)
		psi.ui?.update_icon()
		if(prob(30))
			to_chat(owner, SPAN_STYLE(
				"letter-spacing: 6px; word-spacing: 6px; color: #990000; font-weight: 700; text-decoration: none; font-style: normal; font-variant: normal; text-transform: none;",
				"Приятно."))

/singleton/psi_disorder/dissocial/process(mob/living/owner, datum/psi_complexus/psi, list/state)
	to_chat(owner, SPAN_STYLE(
				"letter-spacing: 6px; word-spacing: 6px; color: #990000; font-weight: 700; text-decoration: none; font-style: normal; font-variant: normal; text-transform: none;",
				pick("Эти люди ничего не значат.",
					"Ты всемогущ",
					"Окрась всё в красный",
					"Они бессильны против тебя",
					"Нет пути назад",
					"Они все идиоты",
					"Всё достало",
					"Я ни разу не люблю этот мир",
					"Человеческие ублюдки",
					"Я только и мечтаю чтобы сдохнуть поскорее",
					"Сегодня я отомщу за всё",
					"Ни одна мразь не убежит",
					"Я отправлю в могилу стольких, сколько смогу",
					"Время умирать",
					"Время убивать",
					"Пора устроить небольшой, геноцид",
					"Пусть кровь льется ручьем.")))
