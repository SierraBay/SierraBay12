/*
	COMBAT_EXTENDED — оружие, которое парирует, но от этого не изнашивается (`code/weapon_parry.dm`).
	Как устроена папка `code/items/` — README, раздел «Числа предметов».
*/

// Энергия, голограммы и псионика — поле, а не вещество.
/obj/item/melee/energy
	ce_armor_nonphysical = TRUE

/obj/item/holo
	ce_armor_nonphysical = TRUE

/obj/item/psychic_power
	ce_armor_nonphysical = TRUE

/obj/item/cryokinesis
	ce_armor_nonphysical = TRUE

// Клинки, когти и молот генокрада — часть его тела.
/obj/item/melee/changeling
	ce_parry_unbreakable = TRUE

// Стопка — много вещей сразу: сломать её целиком от одного удара нельзя.
/obj/item/stack
	ce_parry_unbreakable = TRUE
