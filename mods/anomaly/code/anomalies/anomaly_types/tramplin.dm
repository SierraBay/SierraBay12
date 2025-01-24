/obj/anomaly/tramplin
	name = "Refractions of light"
	anomaly_tag = "Tramp"
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
	artefacts = list(
		/obj/item/artefact/flyer = 1
	)
	//Рандомизация
	ranzomize_with_initialize = TRUE
	can_born_artefacts = FALSE
	min_coldown_time = 3 SECONDS
	max_coldown_time = 8 SECONDS
	being_preload_chance = 10
	chance_to_be_detected = 75
	detection_skill_req = SKILL_BASIC

/obj/anomaly/tramplin/Initialize()
	. = ..()
	range_of_throw = rand(2,5)

/obj/anomaly/tramplin/activate_anomaly()
	for(var/obj/item/target in src.loc)
		get_effect_by_anomaly(target)
	for(var/mob/living/targetbam in src.loc)
		get_effect_by_anomaly(targetbam)
	.=..()

/obj/anomaly/tramplin/get_effect_by_anomaly(target)
	if(ismech(target))
		return
	var/local_range_of_throw = range_of_throw
	if(istype(target, /mob/living))
		SSanom.add_last_attack(target, "Трамплин")
		var/list/result_effects = calculate_artefact_reaction(target, "Трамплин")
		if(result_effects)
			if(result_effects.Find("Не даёт кинуть"))
				return
			if(result_effects.Find("Усиливает дальность полёта"))
				local_range_of_throw = local_range_of_throw * 3

	if(ishuman(target))
		var/mob/living/carbon/human/victim = target
		if(!victim.incapacitated(INCAPACITATION_UNRESISTING) == TRUE) //Убедимся что наш чувак в сознании
			if(victim.skill_check(SKILL_HAULING, SKILL_EXPERIENCED))
				if(prob(10 * victim.get_skill_value(SKILL_HAULING)))
					victim.Weaken(1)
					to_chat(victim, SPAN_GOOD("Земля пропадает под ногами, но вы успеваете вцепиться в землю словно зубами."))
					return

	var/turf/own_turf = get_turf(src)
	var/turf/target_turf = own_turf
	if(!random_throw_dir)
		target_turf = get_ranged_target_turf(target, throw_dir, local_range_of_throw)
	var/atom/movable/victim = target
	if(isliving(victim))
		var/mob/victim_mob = victim
		victim_mob.Weaken(1)
	if(random_throw_dir)
		victim.throw_at_random(own_turf, local_range_of_throw, speed_of_throw )
	else
		victim.throw_at(target_turf, local_range_of_throw, speed_of_throw)

/obj/anomaly/tramplin/get_detection_icon()
	return "trampline_detection"
