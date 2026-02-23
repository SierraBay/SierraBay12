#define CARGO_ORDER_SCIENCE 1
#define CARGO_ORDER_INDUSTRIAL 2
#define CARGO_ORDER_MEDICAL 3

#define CARGO_ORDER_STATE_AVAILABLE 1
#define CARGO_ORDER_STATE_IN_PROGRESS 2
#define CARGO_ORDER_STATE_COMPLETED 3
#define CARGO_ORDER_STATE_CANCELLED 4

/datum/cargo_order
	var/order_id
	var/order_type = CARGO_ORDER_SCIENCE
	var/state = CARGO_ORDER_STATE_AVAILABLE
	var/title = "Unknown Order"
	var/description = "No description"
	var/reward = 1500
	var/department_account = "Science"
	var/creation_time
	var/completion_deadline
	var/required_item_type
	var/required_item_amount = 0
	var/required_item_name
	var/required_reagent_type
	var/required_reagent_amount = 0
	var/required_reagent_name
	var/assigned_to

/datum/cargo_order/New()
	..()
	order_id = "[order_type]-[world.time]-[rand(1, 99999)]"
	creation_time = world.time

/datum/cargo_order/proc/get_brief()
	return "[title] — [reward] ₸"

/datum/cargo_order/proc/get_type_name()
	switch(order_type)
		if(CARGO_ORDER_SCIENCE)
			return "Научный заказ"
		if(CARGO_ORDER_INDUSTRIAL)
			return "Промышленный заказ"
		if(CARGO_ORDER_MEDICAL)
			return "Медицинский заказ"
	return "Неизвестный"

/datum/cargo_order/proc/get_state_name()
	switch(state)
		if(CARGO_ORDER_STATE_AVAILABLE)
			return "Доступно"
		if(CARGO_ORDER_STATE_IN_PROGRESS)
			return "В процессе"
		if(CARGO_ORDER_STATE_COMPLETED)
			return "Завершено"
		if(CARGO_ORDER_STATE_CANCELLED)
			return "Отменено"
	return "Неизвестно"

/datum/cargo_order/science/sample
	order_type = CARGO_ORDER_SCIENCE

/datum/cargo_order/science/sample/New()
	..()
	department_account = "Science"
	var/list/options = list(
		list("type" = /obj/item/disk/tech_disk, "name" = "технические диски", "min" = 1, "max" = 2),
		list("type" = /obj/item/disk/design_disk, "name" = "диски дизайнов", "min" = 1, "max" = 2),
		list("type" = /obj/item/disk/secret_project, "name" = "секретные диски", "min" = 1, "max" = 1)
	)
	var/list/choice = pick(options)
	var/amount = rand(choice["min"], choice["max"])
	required_item_type = choice["type"]
	required_item_amount = amount
	required_item_name = choice["name"]
	title = "Носители данных: [required_item_name]"
	description = "Требуется [required_item_amount] ед. [required_item_name]."

/datum/cargo_order/industrial/weapon
	order_type = CARGO_ORDER_INDUSTRIAL

/datum/cargo_order/industrial/weapon/New()
	..()
	department_account = "Engineering"
	var/list/options = list(
		list("type" = /obj/item/gun/energy/laser, "name" = "лазерные пистолеты", "min" = 2, "max" = 4),
		list("type" = /obj/item/gun/energy/taser, "name" = "тазеры", "min" = 3, "max" = 5),
		list("type" = /obj/item/gun/projectile/pistol, "name" = "пистолеты", "min" = 2, "max" = 4),
		list("type" = /obj/item/gun/projectile/shotgun, "name" = "дробовики", "min" = 1, "max" = 2),
		list("type" = /obj/item/gun/projectile/automatic, "name" = "автоматическое оружие", "min" = 1, "max" = 2)
	)
	var/list/choice = pick(options)
	var/amount = rand(choice["min"], choice["max"])
	required_item_type = choice["type"]
	required_item_amount = amount
	required_item_name = choice["name"]
	title = "Поставка: [required_item_name]"
	description = "Необходимо [required_item_amount] ед. типа \"[required_item_name]\"."

/datum/cargo_order/industrial/parts
	order_type = CARGO_ORDER_INDUSTRIAL

/datum/cargo_order/industrial/parts/New()
	..()
	department_account = "Engineering"
	var/list/options = list(
		list("type" = /obj/item/stock_parts/capacitor, "name" = "конденсаторы", "min" = 4, "max" = 8),
		list("type" = /obj/item/stock_parts/manipulator, "name" = "манипуляторы", "min" = 4, "max" = 8),
		list("type" = /obj/item/stock_parts/micro_laser, "name" = "микролазеры", "min" = 4, "max" = 8),
		list("type" = /obj/item/stock_parts/matter_bin, "name" = "матер-бины", "min" = 3, "max" = 6),
		list("type" = /obj/item/stock_parts/scanning_module, "name" = "скан-модули", "min" = 3, "max" = 6)
	)
	var/list/choice = pick(options)
	var/amount = rand(choice["min"], choice["max"])
	required_item_type = choice["type"]
	required_item_amount = amount
	required_item_name = choice["name"]
	title = "Комплектующие: [required_item_name]"
	description = "Требуется [required_item_amount] ед. компонентов типа \"[required_item_name]\"."

/datum/cargo_order/medical/chemistry
	order_type = CARGO_ORDER_MEDICAL

/datum/cargo_order/medical/chemistry/New()
	..()
	department_account = "Medical"
	var/list/options = list(
		list("type" = /datum/reagent/dexalinp, "name" = "дексалин плюс", "min" = 15, "max" = 30),
		list("type" = /datum/reagent/bicaridine, "name" = "бикаридин", "min" = 15, "max" = 30),
		list("type" = /datum/reagent/kelotane, "name" = "келотан", "min" = 15, "max" = 30),
		list("type" = /datum/reagent/inaprovaline, "name" = "инапровалин", "min" = 15, "max" = 30),
		list("type" = /datum/reagent/dylovene, "name" = "диловен", "min" = 15, "max" = 30)
	)
	var/list/choice = pick(options)
	var/amount = rand(choice["min"], choice["max"])
	required_reagent_type = choice["type"]
	required_reagent_amount = amount
	required_reagent_name = choice["name"]
	title = "Реагент: [required_reagent_name]"
	description = "Требуется [required_reagent_amount] ед. реагента \"[required_reagent_name]\"."

/datum/cargo_order/medical/antitoxin
	order_type = CARGO_ORDER_MEDICAL

/datum/cargo_order/medical/antitoxin/New()
	..()
	department_account = "Medical"
	var/list/options = list(
		list("type" = /datum/reagent/dylovene, "name" = "диловен", "min" = 10, "max" = 20),
		list("type" = /datum/reagent/spaceacillin, "name" = "спейсациллин", "min" = 10, "max" = 20),
		list("type" = /datum/reagent/inaprovaline, "name" = "инапровалин", "min" = 10, "max" = 20)
	)
	var/list/choice = pick(options)
	var/amount = rand(choice["min"], choice["max"])
	required_reagent_type = choice["type"]
	required_reagent_amount = amount
	required_reagent_name = choice["name"]
	title = "Детоксикация: [required_reagent_name]"
	description = "Требуется [required_reagent_amount] ед. \"[required_reagent_name]\"."
