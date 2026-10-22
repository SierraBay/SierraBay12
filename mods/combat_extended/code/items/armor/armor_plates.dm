/*
	COMBAT_EXTENDED — пластины плитоноски: типы из `code/modules/clothing/under/accessories/armor_plate.dm`.
	Как устроена папка `code/items/` — README, раздел «Числа предметов».

	Базовый тип — это и есть light-вставка, так что его материал наследуют все пластины. Кевлар только
	у light, medium и обычного скрытого жилета, поэтому остальным материал задан явно.

	light и medium — не пластины, а баллистические пакеты: мягкие вставки из кевлара. Отсюда их
	названия и описания; у остальных пластин они свои.

	Скрытых жилетов два. Обычный — мягкий кевлар с числами light-вставки: его со временем получат
	охрана и главы. Тактический — жёсткий, с числами medium-вставки: он для антагонистов. Под курткой
	не видно оба (`concealed_accessories.dm`).
*/

/obj/item/clothing/accessory/armor_plate
	name = "light ballistic insert"
	desc = "A flexible ballistic insert of soft kevlar weave. Attaches to a plate carrier."
	// Мягкий кевлар: тонкое плетение.
	ce_armor_material = /singleton/ce_armor_material/kevlar/soft

/obj/item/clothing/accessory/armor_plate/medium
	name = "medium ballistic insert"
	desc = "A thick ballistic insert of densely layered kevlar, providing good protection against pistols. Attaches to a plate carrier."
	// Кевлар: плотный многослойный пакет.
	ce_armor_material = /singleton/ce_armor_material/kevlar

/obj/item/clothing/accessory/armor_plate/tactical
	// Керамика.
	ce_armor_material = /singleton/ce_armor_material/ceramic

/obj/item/clothing/accessory/armor_plate/merc
	// Материал по умолчанию, не кевлар от light-вставки.
	ce_armor_material = /singleton/ce_armor_material

/obj/item/clothing/accessory/armor_plate/sneaky
	// Мягкий кевлар, как у light-вставки: пули держит как она, нож и удар — как одежда.
	ce_armor_material = /singleton/ce_armor_material/kevlar/soft

/obj/item/clothing/accessory/armor_plate/sneaky/tactical
	desc = "An armor vest made of layered smart polymers that lock rigid on impact. Can attach to your slacks and office shirt."
	// Материал по умолчанию, не кевлар обычного жилета: жёсткая броня.
	ce_armor_material = /singleton/ce_armor_material
