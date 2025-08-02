/singleton/cyber_choose/augment/internal_armor
	augment_name = "Подкожная броня"
	aug_description = "Подкожная броня умело установленная под кожу человека. Не способно оказать существенного влияния на заброневое воздействие."
	good_sides = list(
		"Модификатор физического урона 0.7. Слабоэффективно против тяжёлых калибров или атак.",
		"Может принять урон по органам вместо себя.")
	avaible_hardpoints = list(BP_CHEST)
	instal_aug_type = /obj/item/organ/internal/augment/armor
	price = 8


/singleton/cyber_choose/augment/internal_air
	augment_name = "Внутренний воздушный резерв"
	aug_description = "Является внутренним хранилищем кислорода, для активации - нажмите на кнопку подачи воздуха."
	good_sides = list("Сам автоматически заполняется воздухом при необходимости")
	avaible_hardpoints = list(BP_CHEST)
	instal_aug_type = /obj/item/organ/internal/augment/active/internal_air_system
	price = 6

/singleton/cyber_choose/augment/internal_air/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_CHEST] != "Пусто")
		return FALSE
	return TRUE

/singleton/cyber_choose/augment/internal_air/get_reason_for_avaibility(datum/preferences/input_pref)
	return "Данный аугмент можно установить только в плоть."

/singleton/cyber_choose/augment/emergency_battery
	augment_name = "Резервный запас питания"
	aug_description = "Запасное питание, если основное отказало."
	good_sides = list("Запаса энергии не хватит для обеспечения работы всего тела, но хватит для обеспечения работы внутренних вычислительных систем.")
	bad_sides = list()
	avaible_hardpoints = list(BP_CHEST)
	instal_aug_type = /obj/item/organ/internal/augment/emergency_battery
	price = 0

/singleton/cyber_choose/augment/emergency_battery/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_CHEST] == "Пусто")
		return FALSE
	return TRUE

/singleton/cyber_choose/augment/emergency_battery/get_reason_for_avaibility(datum/preferences/input_pref)
	return "Данный аугмент можно установить только в протез."


/singleton/cyber_choose/augment/leukocyte_breeder
	augment_name = "Хранилище лейкоцитов"
	aug_description = "Помогает иммунитету в трудную минуту."
	good_sides = list("Усиливает и восстанавливает ваш иммунитет в трудную минуту.")
	bad_sides = list("Ваше тело становится зависимым от данного устройства, в случае его отключения или уничтожения ЭМИ ударом, ваше тело сильно потеряет в иммунитете.")
	avaible_hardpoints = list(BP_CHEST)
	instal_aug_type = /obj/item/organ/internal/augment/active/leukocyte_breeder
	loadout_price = 4


/singleton/cyber_choose/augment/leukocyte_breeder/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_CHEST] != "Пусто")
		return FALSE
	return TRUE

/singleton/cyber_choose/augment/leukocyte_breeder/get_reason_for_avaibility(datum/preferences/input_pref)
	return "Данный аугмент можно установить только в плоть."

/singleton/cyber_choose/augment/skeletal_bracing
	augment_name = "Укрепление скелета"
	aug_description = "Титановые укрепления скелета, увеличивающие вашу грузоподьёмность и помогающие в случае болезни костей."
	good_sides = list("Не имеет внутриигрового влияния.")
	bad_sides = list()
	avaible_hardpoints = list(BP_CHEST)
	instal_aug_type = /obj/item/organ/internal/augment/skeletal_bracing

/singleton/cyber_choose/augment/ultraviolet_shielding
	augment_name = "Кожная защита от ультрафиолета"
	aug_description = "Ваш эпидермис был заменён на материал, устойчивый к радиации и ультрофиолету. К сожалению, не спасёт от полноценной солнечной вспышки."
	good_sides = list("Не имеет внутриигрового влияния.")
	bad_sides = list()
	avaible_hardpoints = list(BP_CHEST)
	instal_aug_type = /obj/item/organ/internal/augment/ultraviolet_shielding
