/obj/anomaly/zharka
	name = "Jet of flame"
	anomaly_tag = "Zharka"
	with_sound = TRUE
	sound_type = 'mods/anomaly/sounds/zharka.ogg'
	idle_effect_type = "zharka_idle"
	detection_icon_state = "hot_anomaly"
	layer = ABOVE_HUMAN_LAYER
	light_after_activation = TRUE
	effect_type = LONG_ANOMALY_EFFECT
	effect_range = 1
	color_of_light = COLOR_WHITE
	effect_time = 5 SECONDS
	time_of_light = 5 SECONDS
	can_born_artefacts = TRUE
	//Урон который наносит открытое пламя телу в
	var/burn_damage = 10
	activation_effect_type = "zharka_active"

	special_iniciators = list(
		/obj/item
	)

	special_iniciators_flags = list(
		"MUST_BE_METAL"
	)

	artefacts = list(
		/obj/item/artefact/zjar
	)
	//Рандомизация
	ranzomize_with_initialize = TRUE
	min_coldown_time = 8 SECONDS
	max_coldown_time = 20 SECONDS
	artefact_spawn_chance = 10
	can_be_preloaded = FALSE
	being_preload_chance = 20
	detection_skill_req = SKILL_BASIC


/obj/anomaly/zharka/activate_anomaly()
	last_activation_time = world.time
	var/list/victims = list()
	var/list/objs = list()
	var/turf/T = get_turf(src)
	currently_active = TRUE
	get_mobs_and_objs_in_view_fast(T, effect_range, victims, objs)
	for(var/mob/living/carbon/M in victims)
		get_effect_by_anomaly(M)
	for(var/obj/item/I in src.loc)
		if(!istype(I, /obj/item/artefact))
			anything_in_ashes(I)
	.=..()

/obj/anomaly/zharka/get_effect_by_anomaly(atom/movable/target)
	if(!isturf(target.loc))
		return
	if(isanomaly(target))
		return
	//Поджечь человека
	if(istype(target, /mob/living))
		SSanom.add_last_attack(target, "Жарка")
		var/mob/living/victim = target
		if(inmech_sec(victim))
			return
		if(victim.health == 0)
			SSanom.add_last_gibbed(target, "Жарка")
			anything_in_remains(victim)
			return
		victim.fire_stacks = max(2, victim.fire_stacks)
		victim.IgniteMob()
		victim.apply_damage(burn_damage, DAMAGE_BURN, used_weapon = src, armor_pen = 100)
	//Испепелить предмет
	else if(istype(target, /obj/item))
		if(!istype(target, /obj/item/artefact))
			anything_in_ashes(target)

///Жарим всех вокруг в течении действия аномалии
/obj/anomaly/zharka/process_long_effect()
	var/list/victims = list()
	var/list/objs = list()
	var/turf/T = get_turf(src)
	get_mobs_and_objs_in_view_fast(T, effect_range, victims, objs)
	for(var/atom/movable/atoms in victims)
		if(inmech_sec(atoms))
			continue
		get_effect_by_anomaly(atoms)
	for(var/atom/movable/atoms in objs)
		get_effect_by_anomaly(atoms)
	start_processing_long_effect()

/obj/anomaly/zharka/Crossed(atom/movable/O)
	if(currently_active)
		get_effect_by_anomaly(O)
	if(currently_charging_after_activation)
		return
	if(can_be_activated(O))
		activate_anomaly()
	return


/obj/anomaly/zharka/get_detection_icon()
	if(effect_range == 1 || effect_range == 0)
		return "zharka_detection"
	else if(effect_range == 2)
		return "zharka_first_detection"
	else if(effect_range > 2)
		return "zharka_second_detection"
