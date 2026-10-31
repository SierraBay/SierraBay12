/*
	COMBAT_EXTENDED — хладагент и вода на броню человека (`mods/combat_extended/code/laser_coolant.dm`).

	Ёмкость на человеке — кормёжка, на намерении вреда — всплеск. Пока на человеке горячая броня, а
	прицел не во рту, хладагент или воду вместо этого льют на самую горячую броню — свою или чужую.
*/
/obj/item/reagent_containers/glass/use_before(mob/M, mob/user)
	var/mob/living/carbon/human/wearer = M
	if(istype(wearer) && user.a_intent != I_HURT && user.zone_sel?.selecting != BP_MOUTH && wearer.ce_try_pour_coolant(src, user))
		return TRUE
	return ..()
