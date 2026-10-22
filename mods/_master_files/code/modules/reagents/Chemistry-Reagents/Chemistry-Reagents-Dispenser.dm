/*
	COMBAT_EXTENDED — кислота на коже человека встречает его одежду и броню по частям тела
	(`mods/combat_extended/code/acid_armor.dm`). Доза — сколько кислоты на коже на самом деле: Сьерра
	зовёт `affect_touch()` с полной скоростью усвоения, 50 единиц, сколько бы их ни было. Не люди —
	по правилам Бэй.
*/
/datum/reagent/acid/affect_touch(mob/living/carbon/M, removed)
	if(!ishuman(M))
		return ..()
	ce_burn_human(M, min(removed, volume))
