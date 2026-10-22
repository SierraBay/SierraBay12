/*
	COMBAT_EXTENDED — уколы в броню (`mods/combat_extended/code/injections.dm`). Шприц объявляет цели
	укол перед кор процедурой: её `can_inject()` проверит броню зоны и движение цели по числам шприца.
	Удар на намерении вреда `can_inject()` не зовёт — его срывает правка кор `syringestab()`.
*/

/obj/item/reagent_containers/syringe/drawReagents(atom/target, mob/user)
	ce_announce_injection(target)
	. = ..()
	ce_retract_injection(target)


/obj/item/reagent_containers/syringe/injectMob(mob/living/carbon/target, mob/living/carbon/user, atom/trackTarget)
	ce_announce_injection(target)
	. = ..()
	ce_retract_injection(target)
