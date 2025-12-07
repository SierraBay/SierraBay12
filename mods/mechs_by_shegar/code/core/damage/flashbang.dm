//Здесь расположены минорные изменения и фиксы относящиеся к мехам, но места для которыз в других местах не нашлось.
/obj/item/grenade/flashbang/bang(turf/T , mob/living/carbon/M)
	if(istype(M.loc,/mob/living/exosuit))
		var/mob/living/exosuit/mech = M.loc
		if(mech.power == MECH_POWER_ON && mech.hatch_closed && mech.body.pilot_coverage == 100)
			return
	.=..()
