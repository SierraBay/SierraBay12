/*
	COMBAT_EXTENDED — внешние бронеэлементы мехов: типы из
	`mods/mechs_by_shegar/code/components/external_armor/_external_armour.dm`.
	Как устроена папка `code/items/` — README, раздел «Числа предметов». Механика —
	`code/mech_plates.dm`.
*/

/obj/item/mech_external_armor/laserproof
	// Абляционное покрытие, как у абляционного жилета: забирает долю жара каждого луча, пока не
	// выгорит, а жара бронеэлемент вмещает больше остальных.
	ce_armor_material = /singleton/ce_armor_material/ablative
