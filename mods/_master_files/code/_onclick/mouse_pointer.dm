/*
	COMBAT_EXTENDED — кольцо разброса (`mods/combat_extended/code/spread_ring.dm`) заводится,
	пересчитывается и убирается перед тем, как кор ставит курсор: кор зовёт `update_mouse_pointer()`,
	когда оружие взяли, бросили, сменили руку, щёлкнули предохранителем, поменяли настройку и вошли в
	моба, а мод — когда кольцо сменило радиус.
*/
/mob/living/carbon/update_mouse_pointer()
	ce_sync_spread_ring()
	..()


/*
	COMBAT_EXTENDED — курсор оружия апстрима с кольцом разброса вокруг, если кольцо есть
	(`mods/combat_extended/code/spread_ring.dm`). Нет курсора апстрима — кольцо с точкой посередине.
*/
/obj/item/gun/get_mouse_pointer(mob/user)
	return ce_get_spread_ring_pointer(user, ..())
