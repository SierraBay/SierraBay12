/*
	COMBAT_EXTENDED — брызги хладагента и воды остужают горячую броню
	(`mods/combat_extended/code/laser_coolant.dm`).

	Всё, что брызгает на моба или вещь, — пульверизатор, огнетушитель, выплеснутая или брошенная
	ёмкость — касается их через `touch()`.
*/
/datum/reagents/touch(atom/target)
	. = ..()
	ce_spray_armor(target)
