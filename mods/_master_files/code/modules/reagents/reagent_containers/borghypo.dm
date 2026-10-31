/*
	COMBAT_EXTENDED — уколы в броню (`mods/combat_extended/code/injections.dm`). Гипоспрей борга
	объявляет цели укол перед кор процедурой: её `can_inject()` проверит броню зоны и движение цели
	по числам гипоспрея.
*/

/obj/item/reagent_containers/borghypo/use_before(mob/living/M, mob/user)
	ce_announce_injection(M)
	. = ..()
	ce_retract_injection(M)
