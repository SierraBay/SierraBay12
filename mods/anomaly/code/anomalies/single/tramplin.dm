/obj/anomaly/thamplin
	name = "Refractions of light"
	with_sound = TRUE
	sound_type = 'mods/anomaly/sounds/tramplin.ogg'
	idle_effect_type = "trampline_idle"
	layer = ABOVE_HUMAN_LAYER
	effect_range = 0
	var/random_throw_dir = FALSE
	var/throw_dir = EAST
	var/range_of_throw = 5
	var/speed_of_throw = 5
	iniciators = list(
		/mob/living,
		/obj/item
	)
	//Рандомизация
	ranzomize_with_initialize = TRUE
	can_born_artifacts = FALSE
	min_coldown_time = 3 SECONDS
	max_coldown_time = 8 SECONDS
	can_be_preloaded = TRUE
	being_preload_chance = 10
	chance_to_be_detected = 75
	can_walking = TRUE
	chance_spawn_walking = 5
	walking_activity = 5


/obj/anomaly/thamplin/activate_anomaly()
	for(var/obj/item/target in src.loc)
		get_effect_by_anomaly(target)
	for(var/mob/living/targetbam in src.loc)
		get_effect_by_anomaly(targetbam)
	.=..()

/obj/anomaly/thamplin/get_effect_by_anomaly(target)
	if(ismech(target))
		return

	if(ishuman(target))
		var/mob/living/carbon/human/victim = target
		if(!victim.incapacitated(INCAPACITATION_UNRESISTING) == TRUE) //Убедимся что наш чувак в сознании
			if(victim.skill_check(SKILL_HAULING, SKILL_EXPERIENCED))
				if(prob(10 * victim.get_skill_value(SKILL_HAULING)))
					victim.Weaken(1)
					to_chat(victim, SPAN_WARNING("Земля пропадает под ногами, но вы успеваете вцепиться в землю словно зубами."))
					return

	var/turf/own_turf = get_turf(src)
	var/turf/target_turf = own_turf
	if(!random_throw_dir)
		//В силу того что в билде нет нормальной функции по киданию по направлению, сперва расчитаем цель, куда будем метать обьект
		for(var/i = 1, i < range_of_throw, i++)
			target_turf = get_edge_target_turf(target, throw_dir)
	var/atom/movable/victim = target
	if(random_throw_dir)
		victim.throw_at_random(own_turf, range_of_throw, speed_of_throw )
	else
		victim.throw_at(target_turf, range_of_throw, speed_of_throw)
