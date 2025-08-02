/singleton/cyber_choose/augment/hud
	augment_name = "Визор уборщика"
	aug_description = "Даёт зрение уборщика."
	good_sides = list("Визор уборщика, помечающий мусор и загрязнения")
	bad_sides = list("ЭМИ удар ослепит вас.")
	avaible_hardpoints = list(BP_HEAD)
	instal_aug_type = /obj/item/organ/internal/augment/active/hud/janitor
	loadout_price = 4

/singleton/cyber_choose/augment/hud/self_health
	augment_name = "Внутренний анализатор здоровья"
	aug_description = "Устройство самоанализа медицинского состояния."
	good_sides = list("Позволяет проводить анализ состояния здоровья собственного тела.")
	bad_sides = list()
	instal_aug_type = /obj/item/organ/internal/augment/active/iatric_monitor
	loadout_price = 6

/singleton/cyber_choose/augment/hud/self_health/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_HEAD] != "Пусто" || input_pref.limb_list[BP_CHEST] != "Пусто" || input_pref.limb_list[BP_GROIN] != "Пусто")
		return FALSE
	return TRUE

/singleton/cyber_choose/augment/hud/self_health/get_reason_for_avaibility(datum/preferences/input_pref)
	return "Данный аугмент не подходит для киборгов. (Голова, грудь и брюхо должны быть мясными)"

/singleton/cyber_choose/augment/hud
	augment_name = "Визор уборщика"
	aug_description = "Даёт зрение уборщика."
	good_sides = list("Визор уборщика, помечающий мусор и загрязнения")
	bad_sides = list("ЭМИ удар ослепит вас.")
	instal_aug_type = /obj/item/organ/internal/augment/active/hud/janitor

/singleton/cyber_choose/augment/hud/security
	augment_name = "СБ Визор"
	aug_description = "СБ визор, обладающий таким же функционалом как и обычные СБ очки."
	good_sides = list(
		"Помечает людей находящихся в розыске",
		"Позволяет просмотреть записи сотрудника при осмотре",
		"Обладает слабой защитой от вспышки")
	instal_aug_type = /obj/item/organ/internal/augment/active/hud/security

/singleton/cyber_choose/augment/hud/medical
	augment_name = "МЕД Визор"
	aug_description = "Медицинский визор"
	good_sides = list(
		"Показывает сердцебиение ",
		"Позволяет просмотреть записи сотрудника при осмотре")
	instal_aug_type = /obj/item/organ/internal/augment/active/hud/health

/singleton/cyber_choose/augment/hud/science
	augment_name = "Научный визор"
	aug_description = "Медицинский визор"
	good_sides = list(
		"Показывает компоненты в машинерии",
		"Показывает научные данные предметов",
		"Показывает, из чего сделан предмет")
	instal_aug_type = /obj/item/organ/internal/augment/active/hud/science

/singleton/cyber_choose/augment/hud/science
	augment_name = "Встроенный бинокль"
	aug_description = "А ты любопытный."
	good_sides = list("Позволяет смотреть на 2 экрана вдаль, как и с обычным биноклем.")
	bad_sides = list()
	instal_aug_type = /obj/item/organ/internal/augment/active/item/adaptive_binoculars
	loadout_price = 8

/singleton/cyber_choose/augment/hud/glare
	augment_name = "Встроенные сварочные очки"
	aug_description = "Встроенные сварочные очки"
	good_sides = list("Способны защищать от ослепления и света сварки")
	bad_sides = list()
	instal_aug_type = /obj/item/organ/internal/augment/active/item/glare_dampeners
	loadout_price = 4

/singleton/cyber_choose/augment/hud/lenses
	augment_name = "Встроенные линзы"
	aug_description = "Встроенные линзы для зрения"
	good_sides = list("Самые точные линзы для зрения во всём фронтире. Поможет при проблемах со зрением.")
	bad_sides = list()
	instal_aug_type = /obj/item/organ/internal/augment/active/item/corrective_lenses
	loadout_price = 4



//Минорный кал
/singleton/cyber_choose/augment/head_minor
	augment_name = "Информационный чип"
	aug_description = "Чип для хранения информации, позволяющий считывать эту информацию без прямого доступа к этому устройству."
	good_sides = list("Не имеет внутриигрового влияния")
	bad_sides = list()
	avaible_hardpoints = list(BP_HEAD)
	instal_aug_type = /obj/item/organ/internal/augment/data_chip

/singleton/cyber_choose/augment/head_minor/circadian
	augment_name = "Имплант управления циркадными циклами"
	aug_description = "Устройство, позволяющее точечно и по желанию пользователя настраивать циркадные ритмы организма."
	instal_aug_type = /obj/item/organ/internal/augment/circadian_conditioner

/singleton/cyber_choose/augment/head_minor/codex
	augment_name = "Кодекс-чип"
	aug_description = "Устройство, позволяющее в любую секунду обратится к кодексу - внутренняя база данных обо всём в мире."
	instal_aug_type = /obj/item/organ/internal/augment/codex_access

/singleton/cyber_choose/augment/head_minor/genetic
	augment_name = "Генетический бэк-ап"
	aug_description = "Чип, хранящий в себе ДНК носителя."
	instal_aug_type = /obj/item/organ/internal/augment/genetic_backup

/singleton/cyber_choose/augment/head_minor/neurostimulator
	augment_name = "Нейростимулятор"
	aug_description = "Устройство позволяющее влиять на нервную систему человека, помогая при болезнях или просто делая жизнь проще."
	instal_aug_type = /obj/item/organ/internal/augment/neurostimulator_implant

/singleton/cyber_choose/augment/head_minor/painassistant
	augment_name = "Блокиратор боли"
	aug_description = "Простое гражданское устройство сопротивлению боли, поможет при бытовых болях - мигренях или спазмах, но не поможет при серьёзных повреждениях тела."
	instal_aug_type = /obj/item/organ/internal/augment/pain_assistant
