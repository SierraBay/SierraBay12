/*
	COMBAT_EXTENDED — уколы в броню (`mods/combat_extended/code/injections.dm`). Гипоспрей объявляет
	цели укол перед кор процедурой: её `can_inject()` проверит броню зоны и движение цели по числам
	гипоспрея. Сюда же приходят гипоспрей с ампулой и автоинъекторы.
*/

/obj/item/reagent_containers/hypospray/inject_mob(mob/living/M, mob/user)
	ce_announce_injection(M)
	. = ..()
	ce_retract_injection(M)
