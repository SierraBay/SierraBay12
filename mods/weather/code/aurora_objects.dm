#define isaurora(A) istype(A, /obj/structure/aurora)

//Все обьекты что оживают при белой мгле
/obj/structure/aurora
	name = "Dead equipment"
	desc = "An ancient reminder of the past. It will never be able to leave the planet. Part of the planet, part of the ship."
	density =  TRUE
	anchored = TRUE
	icon = 'mods/weather/icons/aurora_objects.dmi'
	var/wake_up_icon_state
	var/waked_up = FALSE

/obj/structure/aurora/Initialize()
	.=..()
	LAZYADD(SSweather.aurora_sctructures, src)

//Обьект прошлого просыпается. Зажигаются фары/огни/монитор и прочее
/obj/structure/aurora/proc/wake_up(wake_up_time)
	set waitfor = FALSE
	if(waked_up)
		return
	sleep(rand(2,10)) //Для того чтоб техника не зажигалась одновременно
	waked_up = TRUE
	icon_state = "[icon_state]_wake_up"
	addtimer(new Callback(src, PROC_REF(go_sleep)), wake_up_time)

/obj/structure/aurora/proc/go_sleep()
	icon_state = initial(icon_state)
	waked_up = FALSE


//Обычное(Прост красивое)

/obj/structure/aurora/beaker_dropper
	icon_state = "beaker_dropper"

/obj/structure/aurora/old_comp
	icon_state = "old_comp"

/obj/structure/aurora/wall_comp
	icon_state = "wall_computer"
	density = FALSE

/obj/structure/aurora/wall_light
	icon_state = "light_tube"
	density =  FALSE

/obj/structure/aurora/wall_light/wake_up(wake_up_time)
	. = ..()
	set_light(4, 2,  COLOR_WHITE)

/obj/structure/aurora/wall_light/go_sleep()
	. = ..()
	set_light(0)

/obj/structure/aurora/nav_light
	icon_state = "nav_light"
	density =  FALSE



//ИНФОРМАТИВНОЕ

/obj/structure/aurora/informative
	var/stored_information
	var/list/possible_information = list()

/obj/structure/aurora/informative/Initialize()
	. = ..()
	if(LAZYLEN(possible_information))
		stored_information = pick(possible_information)

/obj/structure/aurora/informative/examine(mob/user)
	. = ..()
	if(waked_up && stored_information)
		to_chat(user, SPAN_NOTICE(stored_information))

/obj/structure/aurora/informative/old_computer
	icon_state = "old_comp_informative"
	possible_information = list()

/obj/structure/aurora/informative/wall_computer
	icon_state = "wall_computer_informative"
	density = FALSE

//Интерактивное
/obj/structure/aurora/cable
	icon_state = "damaged_cable"
	density =  FALSE

/obj/structure/aurora/cable/Crossed(mob/living/M)
	..()
	if(waked_up)
		M.electrocute_act(20, src, 1.0, ran_zone())

/obj/structure/aurora/cable_angle
	density =  FALSE
	icon_state = "cable_angle"


//Активные обьекты
/obj/structure/aurora/smes
	icon_state = "smes"
	var/electra_attack_cooldown
	var/last_electra_attack
	var/datum/beam = null

/obj/structure/aurora/smes/Initialize()
	. = ..()
	electra_attack_cooldown = rand(3 SECONDS, 20 SECONDS)

/obj/structure/aurora/smes/wake_up(wake_up_time)
	..()
	last_electra_attack = world.time
	START_PROCESSING(SSweather, src)

/obj/structure/aurora/smes/go_sleep()
	..()
	if(is_processing)
		STOP_PROCESSING(SSweather,src)

/obj/structure/aurora/smes/Process()
	..()
	if(world.time - last_electra_attack > electra_attack_cooldown)
		electra_attack()

//Смес бьёт
/obj/structure/aurora/smes/proc/electra_attack()
	set waitfor = FALSE
	last_electra_attack = world.time
	var/turf/picked_turf
	picked_turf = pick(RANGE_TURFS(src, 3))
	for(var/mob/living/picked_living in picked_turf)
		picked_living.electoanomaly_act(50, src)
	for(var/obj/structure/aurora/picked_aurora in picked_turf)
		picked_aurora.wake_up(5 SECONDS)
	beam = src.Beam(BeamTarget = picked_turf, icon_state = "electra_long",icon='mods/anomaly/icons/effects.dmi',time = 0.3 SECONDS)
	playsound(src, 'mods/anomaly/sounds/electra_blast.ogg', 100, FALSE  )
