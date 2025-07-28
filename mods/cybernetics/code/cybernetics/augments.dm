/singleton/cyber_choose/augment
	avaible_hardpoints = list(
		BP_HEAD,
		BP_CHEST,
		BP_GROIN,
		BP_R_ARM,
		BP_R_HAND,
		BP_L_ARM,
		BP_L_HAND,
		BP_R_LEG,
		BP_R_FOOT,
		BP_L_LEG,
		BP_L_FOOT
	)
	var/obj/item/organ/internal/augment/instal_aug_type

/singleton/cyber_choose/augment/internal_armor
	augment_name = "Подкожная броня"
	aug_description = "Подкожная броня умело установленная под кожу человека. Не способно оказать существенного влияния на заброневое воздействие."
	good_sides = list(
		"Модификатор физического урона 0.7. Слабоэффективно против тяжёлых калибров или атак.",
		"Может принять урон по органам вместо себя.")
	avaible_hardpoints = list(BP_CHEST)
	instal_aug_type = /obj/item/organ/internal/augment/armor


/singleton/cyber_choose/augment/internal_air
	augment_name = "Внутренний воздушный резерв"
	aug_description = "Является внутренним хранилищем кислорода, для активации - нажмите на кнопку подачи воздуха."
	good_sides = list("Сам автоматически заполняется воздухом при необходимости")
	avaible_hardpoints = list(BP_CHEST)
	instal_aug_type = /obj/item/organ/internal/augment/active/internal_air_system


//Худы

/singleton/cyber_choose/augment/hud
	augment_name = "Визор уборщика"
	aug_description = "Даёт зрение уборщика."
	good_sides = list("Визор уборщика, помечающий мусор и загрязнения")
	bad_sides = list("ЭМИ удар ослепит вас.")
	avaible_hardpoints = list(BP_HEAD)
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

//Инструментарий
/singleton/cyber_choose/augment/instrumental
	augment_name = "Раскладной набор инструментов для левой кисти"
	aug_description = "Раскладной набор инструментов в вашей левой кисти!"
	good_sides = list(
		"Позволяет вытащить из руки следущие инструменты: отвёртка, лом, кусачки, малая сварка, мультитул.")
	avaible_hardpoints = list(
		BP_R_HAND,
		BP_L_HAND)
	instal_aug_type = /obj/item/organ/internal/augment/active/polytool/engineer

/singleton/cyber_choose/augment/instrumental/left
	augment_name = "Раскладной набор инструментов для правой кисти"
	aug_description = "Раскладной набор инструментов в вашей правой кисти!"
	good_sides = list(
		"Позволяет вытащить из руки следущие инструменты: отвёртка, лом, кусачки, малая сварка, мультитул.")
	avaible_hardpoints = list(
		BP_R_HAND,
		BP_L_HAND)
	instal_aug_type = /obj/item/organ/internal/augment/active/polytool/engineer/right

/singleton/cyber_choose/augment/instrumental/surgical
	augment_name = "Раскладной набор хирургических инструментов"
	aug_description = "Раскладной набор хирургических инструментов в вашей руке!"
	good_sides = list("Позволяет вытащить из руки следущие инструменты: скальпель, пила, гемостат, ретрактор, фиксовейн.")
	instal_aug_type = /obj/item/organ/internal/augment/active/polytool/surgical



/singleton/cyber_choose/augment/muscles
	augment_name = "Эндоскелет"
	aug_description = "Эндоскелет встраиваемый в протез или плоть, усиливая ваши физические показатели"
	good_sides = list(
		"Уровень атлетики +1.",
		"Усиливает дистанцию прыжка.")
	neutral_sides = list("Для работы аугмента, требуется точно такой же и в другую ногу.")
	avaible_hardpoints = list(
		BP_R_LEG,
		BP_L_LEG)
	instal_aug_type = /obj/item/organ/internal/augment/boost/muscle

/singleton/cyber_choose/augment/cabluk
	augment_name = "Киберкаблук"
	aug_description = "Корона всех настоящих мужчин."
	good_sides = list("+1 см роста.")
	neutral_sides = list("Корона всех настоящих мужчин.")
	bad_sides = list("-100 к равновесию")
	avaible_hardpoints = list(
		BP_R_FOOT,
		BP_L_FOOT)
