/singleton/cyber_choose/augment/internal_armor
	augment_name = "Подкожная броня"
	aug_description = "Подкожная броня, дополнительно снижающая урон от атак"
	good_sides = list(
		"Модификатор физического урона 0.7",
		"Имеет шанс компенсировать урон по органам")
	neutral_sides = list("Малоэффективна против крупнокалиберного оружия")
	avaible_hardpoints = list(BP_CHEST)
	instal_aug_type = /obj/item/organ/internal/augment/armor
	price = 8


/singleton/cyber_choose/augment/internal_air
	augment_name = "Внутренний воздушный мешок"
	aug_description = "Внутреннее хранилище кислорода, используемая в экстренных случаях"
	good_sides = list("Автоматически заполняется в нормальной кислородной среде")
	neutral_sides = list("Активация происходит путём нажатия на кнопку активации кислородного баллона")
	avaible_hardpoints = list(BP_CHEST)
	instal_aug_type = /obj/item/organ/internal/augment/active/internal_air_system
	price = 6

/singleton/cyber_choose/augment/internal_air/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_CHEST] != "Пусто")
		return FALSE
	return TRUE

/singleton/cyber_choose/augment/internal_air/get_reason_for_avaibility(datum/preferences/input_pref)
	return "Данный аугмент можно установить только в органическую часть тела."

/singleton/cyber_choose/augment/emergency_battery
	augment_name = "Резервная батарея"
	aug_description = "Резервный элемент питания внутренних аугментов"
	good_sides = list("Имплант поддерживает ММИ или искусственное сердце в случае отказа основных систем")
	neutral_sides = list("Игромеханически не оказывает влияния на функциональность систем и является гиммиком")
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
	augment_name = "Селекционер лейкоцитов"
	aug_description = "Аугмент, стимулирующий иммунную систему."
	good_sides = list("Усиливает выработку лейкоцитов в организме и помогает эффективней бороться с болезнями и сепсисом")
	bad_sides = list("Восприимчивость к ЭМИ. При повреждении аугмента уровень иммунитета серьёзно падает")
	avaible_hardpoints = list(BP_CHEST)
	instal_aug_type = /obj/item/organ/internal/augment/active/leukocyte_breeder
	loadout_price = 4


/singleton/cyber_choose/augment/leukocyte_breeder/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_CHEST] != "Пусто")
		return FALSE
	return TRUE

/singleton/cyber_choose/augment/leukocyte_breeder/get_reason_for_avaibility(datum/preferences/input_pref)
	return "Данный аугмент можно установить только в органическую часть тела."

/singleton/cyber_choose/augment/skeletal_bracing
	augment_name = "Усиленный скелет"
	aug_description = "Дополнительное усиление скелета титаном для компенсации его хрупкости"
	good_sides = list("Поддерживает секелет при нормальной или высокой гравитации")
	neutral_sides = list("Игромеханически не оказывает влияния на прочность костей и шанс перелома")
	bad_sides = list()
	avaible_hardpoints = list(BP_CHEST)
	instal_aug_type = /obj/item/organ/internal/augment/skeletal_bracing

/singleton/cyber_choose/augment/ultraviolet_shielding
	augment_name = "УФ-экранирование"
	aug_description = "Интегрированная в эпидермис защита от ультрафиолетового излучения"
	good_sides = list("Защищает от последствий длительного пребывания под прямыми УФ-лучами")
	neutral_sides = list("Игромеханически не защищает от сильных солнечных вспышек")
	bad_sides = list()
	avaible_hardpoints = list(BP_CHEST)
	instal_aug_type = /obj/item/organ/internal/augment/ultraviolet_shielding
