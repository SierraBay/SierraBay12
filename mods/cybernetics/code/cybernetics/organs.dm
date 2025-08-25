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
	aug_description = "Киберглаза. Полноценная замена органических глаз"
	good_sides = list(
		"Ремонтопригодны без хирургического вмешательства",
		"Возможность изменения цвета глаз в любой момент")
	bad_sides = list("Восприимчивость к ЭМИ")
	avaible_hardpoints = list(BP_EYES)

/singleton/cyber_choose/organ/eyes/assisted
	augment_name = "Глаза с устройством поддержки"
	aug_description = "Органические глаза с устройством поддержки функциональности"
	neutral_sides = list("Компенсирует врождённые болезни или травмы персонажа")
	bad_sides = list("Восприимчивость к ЭМИ")
	organ_type = ASSISTED

/singleton/cyber_choose/organ/eyes/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_HEAD] == "Пусто")
		return TRUE

/singleton/cyber_choose/organ/eyes/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Данный орган нельзя установить в протез")








/singleton/cyber_choose/organ/heart
	augment_name = "Синтетическое сердце"
	aug_description = "Устройство, заменяющее органическое сердце"
	good_sides = list(
		"Только физическое воздействие повреждает орган",
		"Болевой шок или передозировка химикатами не останавливает сердце")
	neutral_sides = list("Ввиду отсутствия сердечных сокращений, ваш пульс не отображается при сканировании")
	bad_sides = list(
		"Серьёзная восприимчивость к ЭМИ")
	avaible_hardpoints = list(BP_HEART)

/singleton/cyber_choose/organ/heart/assisted
	augment_name = "Сердце с кардиостимулятором"
	aug_description = "Органическое сердце с устройством поддержки функциональности"
	good_sides = list()
	neutral_sides = list("Компенсирует врождённые болезни или травмы персонажа")
	bad_sides = list("Восприимчивость к ЭМИ")
	organ_type = ASSISTED

/singleton/cyber_choose/organ/heart/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_CHEST] == "Пусто")
		return TRUE

/singleton/cyber_choose/organ/heart/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Данный орган нельзя установить в протез")









/singleton/cyber_choose/organ/lungs
	augment_name = "Синтетические лёгкие"
	aug_description = "Искусственные лёгкие, заменяющие органические"
	good_sides = list("Разрыв лёгких требует чуть большего на них воздействия")
	bad_sides = list("Восприимчивость к ЭМИ")
	avaible_hardpoints = list(BP_LUNGS)

/singleton/cyber_choose/organ/lungs/assisted
	augment_name = "Лёгкие с устройством поддержки"
	aug_description = "Органические лёгкие с устройством удаления углекислого газа"
	good_sides = list()
	neutral_sides = list("Компенсирует врождённые болезни или травмы персонажа")
	bad_sides = list("Восприимчивость к ЭМИ")
	organ_type = ASSISTED

/singleton/cyber_choose/organ/lungs/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_CHEST] == "Пусто")
		return TRUE

/singleton/cyber_choose/organ/lungs/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Данный орган нельзя установить в протез")










/singleton/cyber_choose/organ/liver
	augment_name = "Синтетическая печень"
	aug_description = "Синтетический фильтр токсинов, заменяющий органическую печень"
	good_sides = list("Орган невосприимчив к гниению при интоксикации организма")
	bad_sides = list("Восприимчивость к ЭМИ")
	avaible_hardpoints = list(BP_LIVER)

/singleton/cyber_choose/organ/liver/assisted
	augment_name = "Печень с поддерживающим устройством"
	aug_description = "Органическая печень с устройством фильтрации токсинов"
	good_sides = list()
	neutral_sides = list("Компенсирует врождённые болезни или травмы персонажа")
	bad_sides = list("Восприимчивость к ЭМИ")
	organ_type = ASSISTED


/singleton/cyber_choose/organ/liver/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_GROIN] == "Пусто")
		return TRUE

/singleton/cyber_choose/organ/liver/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Данный орган нельзя установить в протез")






/singleton/cyber_choose/organ/kidneys
	augment_name = "Синтетические почки"
	aug_description = "Синтетические фильтры мочевины"
	good_sides = list()
	neutral_sides = list("Выполняют функции органических почек без каких-либо улучшений")
	bad_sides = list("Восприимчивость к ЭМИ")
	avaible_hardpoints = list(BP_KIDNEYS)

/singleton/cyber_choose/organ/kidneys/assisted
	augment_name = "Почки с поддерживающим устройством"
	aug_description = "Органические почки с устройством компенсации нефрологических паталогий"
	good_sides = list()
	neutral_sides = list("Компенсирует врождённые болезни или травмы персонажа")
	bad_sides = list("Восприимчивость к ЭМИ")
	organ_type = ASSISTED

/singleton/cyber_choose/organ/kidneys/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_GROIN] == "Пусто")
		return TRUE

/singleton/cyber_choose/organ/kidneys/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Данный орган нельзя установить в протез")







/singleton/cyber_choose/organ/stomach
	augment_name = "Синтетический желудок"
	aug_description = "Синтетическая камера биопереработки"
	good_sides = list()
	neutral_sides = list("Выполняет функции органического желудка без каких-либо улучшений")
	bad_sides = list("Восприимчивость к ЭМИ")
	avaible_hardpoints = list(BP_STOMACH)

/singleton/cyber_choose/organ/stomach/assisted
	augment_name = "Желудок с поддерживающим устройством"
	aug_description = "Органический желудок с реконструированными стенками и гастростомой"
	good_sides = list()
	neutral_sides = list("Компенсирует врождённые болезни или травмы персонажа")
	bad_sides = list("Восприимчивость к ЭМИ")
	organ_type = ASSISTED

/singleton/cyber_choose/organ/stomach/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_GROIN] == "Пусто")
		return TRUE

/singleton/cyber_choose/organ/stomach/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Данный орган нельзя установить в протез")



#undef ASSISTED
#undef SYNTETHIC
