/*
	COMBAT_EXTENDED — броня на тело: типы из `code/modules/clothing/suits/armor.dm`.
	Как устроена папка `code/items/` — README, раздел «Числа предметов».
*/

/obj/item/clothing/suit/armor/makeshift
	// Сталь: «A pair of sheets held together by rods and wires», крафтится из стальных листов.
	ce_armor_material = /singleton/ce_armor_material/steel
	// Голые листы без подбоя: сдавшая сталь колется в носителя.
	ce_armor_shards = TRUE

/obj/item/clothing/suit/storage/vest/tactical
	ce_armor_material = /singleton/ce_armor_material/ceramic

/obj/item/clothing/suit/armor/laserproof
	// Абляционный жилет: покрытие выгорает вместо брони и отражает лучи, пока цело.
	ce_armor_material = /singleton/ce_armor_material/ablative
