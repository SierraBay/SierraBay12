//Здесь я добавил переменную и проверку для того чтоб с некоторыми мобами
//НИКОГДА не свапались, в случае нужды.
/mob/living
	var/mob_never_swap = FALSE

/mob/living/can_swap_with(mob/living/tmob)
	if(tmob.mob_never_swap)
		return 0
	.=..()
