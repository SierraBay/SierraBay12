/*
	COMBAT_EXTENDED — ожоги от раскалённой брони (`mods/combat_extended/code/laser_heat.dm`).

	Идут в тик Life вместе с огнём: так их, как и огонь, лаг только замедляет. `handle_fire()` зовётся
	каждый тик, горит ли человек или нет, а ожоги от брони от огня не зависят.
*/
/mob/living/carbon/human/handle_fire()
	. = ..()
	ce_burn_from_hot_armor()
