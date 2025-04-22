///Обьект заспавнит крабиков
/obj/mob_spawner
	invisibility = 100
	icon = 'mods/anomaly/icons/spawn_protocol_stuff.dmi'
	icon_state = "bluecrab"
	var/spawn_type = /mob/living/simple_animal/hostile/retaliate/giant_crab
	var/spawn_range = 2
	var/detection_range = 2
	var/mobs_ammout
	var/min_mobs_ammout = 2
	var/max_mobs_ammout = 5
	var/delete_after_spawn
	var/cooldown = 10 MINUTES
	var/whitelist_turf
	var/next_possible_spawn
	var/list/list_of_helpers = list()

/obj/mob_spawner/New(loc, ...)
	.=..()
	calculate_spawn_time()
	deploy_helper_parts()

/obj/mob_spawner/Destroy()
	.=..()
	for(var/obj/spawner_helper/helper in list_of_helpers)
		helper.Destroy()

/obj/mob_spawner/proc/calculate_spawn_ammout()
	var/result_spawn
	if(mobs_ammout)
		result_spawn = mobs_ammout
	else
		result_spawn = rand(min_mobs_ammout, max_mobs_ammout)
	if(!result_spawn)
		CRASH("Игра пытается заспавнить несуществующее количество мобиков в моб спавнере")
	return result_spawn

/obj/mob_spawner/proc/spawn_mobs(atom/movable/input_movable)
	if(!input_movable || (!ishuman(input_movable) && !ismech(input_movable)) || !is_ready())
		return
	var/turf/my_turf = get_turf(src)
	var/list/possible_turfs = RANGE_TURFS(my_turf, spawn_range)
	if(whitelist_turf)
		for(var/turf/T in possible_turfs)
			if(!istype(T, whitelist_turf))
				LAZYREMOVE(possible_turfs, T)
	var/spawn_ammout = calculate_spawn_ammout()
	while(LAZYLEN(possible_turfs) && spawn_ammout != 0)
		var/turf/spawn_turf = pick(possible_turfs)
		new spawn_type(get_turf(spawn_turf))
		LAZYREMOVE(possible_turfs, spawn_turf)
		spawn_ammout--

/obj/mob_spawner/proc/calculate_spawn_time()
	next_possible_spawn = world.time + cooldown

/obj/mob_spawner/proc/is_ready()
	if(world.time > next_possible_spawn)
		calculate_spawn_time()
		return TRUE
	return FALSE


/obj/mob_spawner/titan_crabs
	spawn_type = /mob/living/simple_animal/hostile/titan_crab
	whitelist_turf = /turf/simulated/floor/exoplanet/titan_water

/mob/living/simple_animal/hostile/titan_crab
	name = "giant blue crab"
	desc = "A gigantic crustacean with a blue shell. Its left claw is nearly twice the size of its right."
	icon_state = "bluecrab"
	icon_living = "bluecrab"
	icon_dead = "bluecrab_dead"
	mob_size = MOB_LARGE
	turns_per_move = 5
	response_help  = "pats"
	response_disarm = "gently nudges"
	response_harm   = "strikes"
	meat_type = /obj/item/reagent_containers/food/snacks/shellfish/crab
	meat_amount = 12
	can_escape = TRUE //snip snip
	break_stuff_probability = 15
	faction = "crabs"
	pry_time = 2 SECONDS
	health = 350
	maxHealth = 350
	natural_weapon = /obj/item/natural_weapon/pincers/giant
	natural_armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_PISTOL
		)
	bleed_colour = "#064b5c"
	see_in_dark = 10
	ai_holder = /datum/ai_holder/simple_animal/titan_crab

/datum/ai_holder/simple_animal/titan_crab
	hostile = TRUE
