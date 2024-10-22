/obj/anomaly/vspishka
	name = "Brightest flash"
	with_sound = TRUE
	sound_type = 'mods/anomaly/sounds/vspishka_activated.ogg'
	idle_effect_type = "vspishka_idle"
	layer = ABOVE_HUMAN_LAYER
	light_after_activation = TRUE
	color_of_light = COLOR_WHITE
	time_of_light = 1.5 SECONDS
	range_of_light = 6
	power_of_light = 10
	effect_range = 5
	can_born_artefacts = FALSE
	var/datum/beam = null
	var/create_line = FALSE
	preload_sound_type = 'mods/anomaly/sounds/vspishka_preload.ogg'
	//Рандомизация
	ranzomize_with_initialize = TRUE
	min_coldown_time = 30 SECONDS
	max_coldown_time = 75 SECONDS
	min_preload_time = 6
	max_preload_time = 12
	can_be_preloaded = TRUE
	being_preload_chance = 80
	chance_to_be_detected = 75

/obj/anomaly/vspishka/activate_anomaly()
	last_activation_time = world.time
	if(need_preload)
		start_preload()
	var/list/victims = list()
	var/list/objs = list()
	var/turf/T = get_turf(src)
	get_mobs_and_objs_in_view_fast(T, effect_range, victims, objs)
	for(var/atom/movable/atoms in victims)
		get_effect_by_anomaly(atoms)
	for(var/atom/movable/atoms in objs)
		get_effect_by_anomaly(atoms)
	.=..()

/obj/anomaly/vspishka/get_effect_by_anomaly(target)
	create_line = FALSE
	//Ослепим моба
	if(istype(target, /mob/living))
		SSanom.add_last_attack(target, "Вспышка")
		var/list/result_effects = calculate_artefact_reaction(target, "Вспышка")
		if(result_effects)
			if(result_effects.Find("Защищает от ослепления"))
				return
		var/mob/living/victim = target
		victim.flash_eyes(FLASH_PROTECTION_MAJOR)
		victim.Stun(5)
		victim.mod_confused(10)
		create_line = TRUE
	if(istype(target, /obj/machinery/camera))
		var/obj/machinery/victim = target
		victim.emp_act(1)
		create_line = TRUE
	if(create_line)
		beam = src.Beam(BeamTarget = get_turf(target), icon_state = "vspishka_beam",icon='mods/anomaly/icons/effects.dmi',time = 0.3 SECONDS)
