/singleton/cyber_choose/organ
	avaible_hardpoints = list(
			BP_EYES,
			BP_HEART,
			BP_LUNGS,
			BP_LIVER,
			BP_KIDNEYS,
			BP_STOMACH
		)

/singleton/cyber_choose/organ/eyes
	augment_name = "Синтетические глаза"
	aug_description = "По сути пара высококачественных камер передающих картинку прямо в мозг."
	good_sides = list(
		"Возможен ремонт отвёрткой без хирургических вмешательств",
		"Возможна смена цвета глаз прямо на ходу")
	bad_sides = list("ЭМИ удар повреждает глаза.")
	avaible_hardpoints = list(BP_EYES)

/singleton/cyber_choose/organ/heart
	augment_name = "Синтетическое сердце"
	aug_description = "Мощный насос замещающий работу сердца."
	good_sides = list("Орган не страдает от любых внешних воздействия на себя кроме физических. Это сердце не остановится от боли, или передозировки.")
	neutral_sides = list("У вас не будет отображаться пульс в силу того что сердце качает кровь 24/7, а не пульсами.")
	bad_sides = list(
		"ЭМИ удар повреждает сердце.",
		"Второй ЭМИ удар уже имеет серьёзные последствия.")
	avaible_hardpoints = list(BP_HEART)

/singleton/cyber_choose/organ/lungs
	augment_name = "Синтетические лёгкие"
	aug_description = "Пара кибер лёгких"
	good_sides = list("Ваши лёгкие немного устойчивее к разрыву. Немного.")
	bad_sides = list("ЭМИ удар повреждает ваши лёгкие.")
	avaible_hardpoints = list(BP_LUNGS)

/singleton/cyber_choose/organ/liver
	augment_name = "Синтетическая печень"
	aug_description = "Синтетический аналог печени."
	good_sides = list("Звучит круто. Не может сгнить.")
	bad_sides = list("ЭМИ удар повреждает вашу печень.")
	avaible_hardpoints = list(BP_LIVER)

/singleton/cyber_choose/organ/kidneys
	augment_name = "Синтетические почки"
	aug_description = "Синтетические фильтры мочевины"
	good_sides = list("Бесполезны.")
	bad_sides = list("ЭМИ удар повреждает ваши почки.")
	avaible_hardpoints = list(BP_KIDNEYS)

/singleton/cyber_choose/organ/stomach
	augment_name = "Синтетический желудок"
	aug_description = "Синтетические аналог желудка"
	good_sides = list("Бесполезен.")
	bad_sides = list("ЭМИ удар повреждает ваш желудок")
	avaible_hardpoints = list(BP_STOMACH)
