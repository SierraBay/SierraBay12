//У тесл отключена рандомизация параметров и предзарядка дабы они не входили в цикл, активируя друг друга
/obj/anomaly/electra/three_and_three/tesla
	admin_name = "Электроаномалия(Тесла +1)"
	can_be_preloaded = FALSE
	ranzomize_with_initialize = FALSE

/obj/anomaly/electra/three_and_three/tesla/Initialize()
	if(multitile)
		effect_range = 2
	subtype_tesla = TRUE
	.=..()

/obj/anomaly/electra/three_and_three/tesla_second
	admin_name = "Электроаномалия(Тесла +2)"
	can_be_preloaded = FALSE
	ranzomize_with_initialize = FALSE

/obj/anomaly/electra/three_and_three/tesla_second/Initialize()
	if(multitile)
		effect_range = 3
	subtype_tesla = TRUE
	.=..()


/obj/anomaly/tramplin/random
	admin_name = "Трамплин (Рандомный)"
	random_throw_dir = TRUE

/obj/anomaly/thamplin/random/always_powerfull_walking
	can_walking = TRUE
	walking_activity = 20
	walk_time = 2 SECONDS
	chance_spawn_walking = 100

/obj/anomaly/zharka/walking
	admin_name = "Жарка (Бродячая)"
	chance_spawn_walking = 100

/obj/anomaly/zharka/short_effect
	effect_range = 0

/obj/anomaly/zharka/long_effect
	effect_range = 2

/obj/anomaly/electra/three_and_three/preload
	admin_name = "Электра (Предзарядочная)"
	need_preload = TRUE

/obj/anomaly/tramplin/powerfull
	admin_name = "Трамплин (Усиленный)"
	random_throw_dir = FALSE
	ranzomize_with_initialize = FALSE
	range_of_throw = 10
	speed_of_throw = 10
