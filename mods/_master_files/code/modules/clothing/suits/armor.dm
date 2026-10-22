/*
	COMBAT_EXTENDED — отражение лучей абляционным жилетом зависит от его покрытия и жара
	(`mods/combat_extended/code/laser_heat.dm`).

	Бросок Bay (`40 - урон / 3` процентов, вдвое меньше мимо груди и паха) не трогается: перед ним
	идёт свой бросок на долю, которую жилет сохраняет, и вместе они дают шанс Bay × доля. Целое
	покрытие холодного жилета отражает как Bay, выгоревшее или раскалённое добела — почти никак.
*/
/obj/item/clothing/suit/armor/laserproof/handle_shield(mob/user, damage, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	var/datum/extension/armor/armor = get_extension(src, /datum/extension/armor)
	if(ce_laser_heat_enabled && armor && !prob(100 * armor.ce_get_reflect_mult()))
		return 0
	return ..()
