/*
	COMBAT_EXTENDED. Аплинк: типы из `code/datums/uplink/stealth_and_camouflage_items.dm`.
	Как устроена папка `code/items/`: README, раздел "Числа предметов".

	Скрытые жилеты стали разными (README, "Скрытые жилеты и аксессуары под верхней одеждой"), а light-
	и medium-пластин, с которыми их сравнивал кор, больше нет.
*/

// Обычный жилет теперь снаряжение экипажа: он лежит в шкафчиках глав и охранников. Антагонистам
// остаётся тактический. Запись без имени аплинк не показывает (`/datum/uplink/New()`).
/datum/uplink_item/item/stealth_items/sneaky_armor
	name = null

/datum/uplink_item/item/stealth_items/tactical_sneaky_armor
	// Жёсткая броня с числами medium-вставки: держит holdout и 10-мм пистолет, но не магнум и винтовку.
	// Держит и стальные ножи, но не мечи (README, "Нульглас и стальное холодное оружие").
	desc = "A hard armor vest that can be worn under a jacket. Stops most pistol rounds and knives; magnums, rifles and swords go through."
