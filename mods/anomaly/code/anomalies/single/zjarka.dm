/obj/anomaly/zjarka
	name = "Jet of flame"
	with_sound = TRUE
	sound_type = 'mods/anomaly/sounds/zjarka.ogg'
	idle_effect_type = "zjarka_idle"
	layer = ABOVE_HUMAN_LAYER
	light_after_activation = TRUE
	effect_type = LONG_ANOMALY_EFFECT
	effect_range = 1
	color_of_light = COLOR_WHITE
	effect_time = 5 SECONDS
	time_of_light = 5 SECONDS
	can_born_artifacts = TRUE
	//Урон который наносит открытое пламя телу в
	var/burn_damage = 10
	activation_effect_type = "zjarka_active"

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
	min_spawn_chance = 20
	max_spawn_chance = 40
	can_be_preloaded = FALSE
	being_preload_chance = 20

/obj/anomaly/zjarka/activate_anomaly()
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

/obj/anomaly/zjarka/get_effect_by_anomaly(target)
	if(isanomaly(target))
		return
	//Поджечь человека
	if(istype(target, /mob/living))
		var/mob/living/victim = target
		if(inmech_sec(victim))
			return
		if(victim.health == 0)
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
/obj/anomaly/zjarka/process_long_effect()
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

/obj/anomaly/zjarka/Crossed(atom/movable/O)
	if(currently_active)
		get_effect_by_anomaly(O)
	if(currently_charging_after_activation)
		return
	if(can_be_activated(O))
		activate_anomaly()
	return
