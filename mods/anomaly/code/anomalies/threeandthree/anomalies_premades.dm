//У тесл отключена рандомизация параметров и предзарядка дабы они не входили в цикл, активируя друг друга
/obj/anomaly/electra/three_and_three/tesla
	can_be_preloaded = FALSE
	ranzomize_with_initialize = FALSE

/obj/anomaly/electra/three_and_three/tesla/Initialize()
	if(multitile)
		effect_range = 2
	subtype_tesla = TRUE
	.=..()

/obj/anomaly/electra/three_and_three/tesla_second
	can_be_preloaded = FALSE
	ranzomize_with_initialize = FALSE

/obj/anomaly/electra/three_and_three/tesla_second/Initialize()
	if(multitile)
		effect_range = 3
	subtype_tesla = TRUE
	.=..()


/obj/anomaly/thamplin/random
	random_throw_dir = TRUE

/obj/anomaly/zjarka/short_effect
	effect_range = 0

/obj/anomaly/zjarka/long_effect
	effect_range = 2

/obj/anomaly/electra/three_and_three/preload
	need_preload = TRUE
