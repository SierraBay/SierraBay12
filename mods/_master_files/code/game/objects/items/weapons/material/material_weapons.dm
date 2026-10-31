/*
	COMBAT_EXTENDED — износ материального оружия при парировании считает мод
	(`mods/combat_extended/code/weapon_parry.dm`), а не бросок Bay на 1 HP против материального оружия.
*/

/obj/item/material/on_parry(damage_source)
	if(ce_parry_enabled)
		return
	return ..()
