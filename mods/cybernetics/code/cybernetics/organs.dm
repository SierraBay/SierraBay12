#define ASSISTED "assisted"
#define SYNTETHIC "syntethic"

/singleton/cyber_choose/organ
	avaible_hardpoints = list(
			BP_EYES,
			BP_HEART,
			BP_LUNGS,
			BP_LIVER,
			BP_KIDNEYS,
			BP_STOMACH
		)
	var/organ_type = SYNTETHIC

/singleton/cyber_choose/organ/eyes
	augment_name = "Синтетические глаза"
	aug_description = "По сути пара высококачественных камер передающих картинку прямо в мозг."
	good_sides = list(
		"Возможен ремонт отвёрткой без хирургических вмешательств",
		"Возможна смена цвета глаз прямо на ходу")
	bad_sides = list("ЭМИ удар повреждает глаза.")
	avaible_hardpoints = list(BP_EYES)

/singleton/cyber_choose/organ/eyes/assisted
	augment_name = "Органические глаза с интеграцией"
	aug_description = "Обычные глаза с интеграцией устройства для компенсации какой-либо болезни."
	good_sides = list()
	bad_sides = list("ЭМИ удар повреждает глаза.")
	organ_type = ASSISTED

/singleton/cyber_choose/organ/eyes/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_HEAD] == "Пусто")
		return TRUE

/singleton/cyber_choose/organ/eyes/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Данный орган нельзя установить в протез.")








/singleton/cyber_choose/organ/heart
	augment_name = "Синтетическое сердце"
	aug_description = "Мощный насос замещающий работу сердца."
	good_sides = list("Орган не страдает от любых внешних воздействия на себя кроме физических. Это сердце не остановится от боли, или передозировки.")
	neutral_sides = list("У вас не будет отображаться пульс в силу того что сердце качает кровь 24/7, а не пульсами.")
	bad_sides = list(
		"ЭМИ удар повреждает сердце.",
		"Второй ЭМИ удар уже имеет серьёзные последствия.")
	avaible_hardpoints = list(BP_HEART)

/singleton/cyber_choose/organ/heart/assisted
	augment_name = "Сердце с кардиоприбором"
	aug_description = "Обычное сердце с интеграцией устройства для компенсации какой-либо болезни."
	good_sides = list()
	neutral_sides = list()
	bad_sides = list("ЭМИ удар повреждает сердце.")
	organ_type = ASSISTED

/singleton/cyber_choose/organ/heart/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_CHEST] == "Пусто")
		return TRUE

/singleton/cyber_choose/organ/heart/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Данный орган нельзя установить в протез.")









/singleton/cyber_choose/organ/lungs
	augment_name = "Синтетические лёгкие"
	aug_description = "Обычное сердце с интеграцией устройства для компенсации какой-либо болезни."
	good_sides = list("Ваши лёгкие немного устойчивее к разрыву. Немного.")
	bad_sides = list("ЭМИ удар повреждает ваши лёгкие.")
	avaible_hardpoints = list(BP_LUNGS)

/singleton/cyber_choose/organ/lungs/assisted
	augment_name = "Лёгкие с поддерживающим устройством"
	aug_description = "Обычные лёгкие с интеграцией устройства для компенсации какой-либо болезни."
	good_sides = list()
	bad_sides = list("ЭМИ удар повреждает ваши лёгкие.")
	organ_type = ASSISTED

/singleton/cyber_choose/organ/lungs/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_CHEST] == "Пусто")
		return TRUE

/singleton/cyber_choose/organ/lungs/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Данный орган нельзя установить в протез.")










/singleton/cyber_choose/organ/liver
	augment_name = "Синтетическая печень"
	aug_description = "Синтетический аналог печени."
	good_sides = list("Звучит круто. Не может сгнить.")
	bad_sides = list("ЭМИ удар повреждает вашу печень.")
	avaible_hardpoints = list(BP_LIVER)

/singleton/cyber_choose/organ/liver/assisted
	augment_name = "Печень с поддерживающим устройством"
	aug_description = "Обычная печень с интеграцией устройства для компенсации какой-либо болезни."
	good_sides = list()
	bad_sides = list("ЭМИ удар повреждает вашу печень.")
	organ_type = ASSISTED


/singleton/cyber_choose/organ/liver/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_GROIN] == "Пусто")
		return TRUE

/singleton/cyber_choose/organ/liver/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Данный орган нельзя установить в протез.")






/singleton/cyber_choose/organ/kidneys
	augment_name = "Синтетические почки"
	aug_description = "Синтетические фильтры мочевины"
	good_sides = list("Бесполезны.")
	bad_sides = list("ЭМИ удар повреждает ваши почки.")
	avaible_hardpoints = list(BP_KIDNEYS)

/singleton/cyber_choose/organ/kidneys/assisted
	augment_name = "Почки с поддерживающим устройством"
	aug_description = "Обычные почки с интеграцией устройства для компенсации какой-либо болезни."
	good_sides = list()
	bad_sides = list("ЭМИ удар повреждает ваши почки.")
	organ_type = ASSISTED

/singleton/cyber_choose/organ/kidneys/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_GROIN] == "Пусто")
		return TRUE

/singleton/cyber_choose/organ/kidneys/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Данный орган нельзя установить в протез.")







/singleton/cyber_choose/organ/stomach
	augment_name = "Синтетический желудок"
	aug_description = "Синтетические аналог желудка"
	good_sides = list("Бесполезен.")
	bad_sides = list("ЭМИ удар повреждает ваш желудок")
	avaible_hardpoints = list(BP_STOMACH)

/singleton/cyber_choose/organ/stomach/assisted
	augment_name = "Желудок с поддерживающим устройством"
	aug_description = "Обычный желудок с интеграцией устройства для компенсации какой-либо болезни."
	good_sides = list()
	bad_sides = list("ЭМИ удар повреждает ваш желудок")
	organ_type = ASSISTED

/singleton/cyber_choose/organ/stomach/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_GROIN] == "Пусто")
		return TRUE

/singleton/cyber_choose/organ/stomach/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Данный орган нельзя установить в протез.")



#undef ASSISTED
#undef SYNTETHIC
