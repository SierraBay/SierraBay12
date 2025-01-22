/obj/anomaly/electra
	name = "Lightning strikes"
	anomaly_tag = "Electra"
	with_sound = TRUE
	sound_type = 'mods/anomaly/sounds/electra_blast.ogg'
	activation_effect_type = "electra_activation"
	idle_effect_type = "electra_idle"
	detection_icon_state = "electra_anomaly"
	layer = ABOVE_HUMAN_LAYER
	light_after_activation = TRUE
	color_of_light = COLOR_WHITE
	time_of_light = 1.5 SECONDS
	can_born_artefacts = TRUE
	special_iniciators = list(
		/obj/item
	)
	special_iniciators_flags = list(
		"MUST_BE_METAL"
	)
	artefacts = list(
		/obj/item/artefact/pruzhina = 80,
		/obj/item/artefact/svetlyak = 20
	)
	var/play_sound_second_time = FALSE //Костыль, чтоб тесла при ударе по целям вдаль тоже играла звук удара
	static_sound_type = 'mods/anomaly/sounds/electra_idle.ogg'
	var/datum/beam = null
	///Электра является подтипом ТЕСЛА
	var/subtype_tesla = FALSE
	//Сколько раз взвели электру, юзается в activation_anomaly()
	var/activated_ammount = 0
	preload_sound_type = 'mods/anomaly/sounds/electra_preload.ogg'
	preload_effect_type = "electra_preload"
	//Рандомизация
	ranzomize_with_initialize = TRUE
	min_coldown_time = 5 SECONDS
	max_coldown_time = 15 SECONDS
	min_preload_time = 4
	max_preload_time = 8
	artefact_spawn_chance = 25
	can_be_preloaded = TRUE
	being_preload_chance = 30
	detectable_effect_range = TRUE
	detection_skill_req = SKILL_EXPERIENCED

/obj/anomaly/electra/activate_anomaly(activate_friends = TRUE)
	if(need_preload)
		start_preload()
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
	//Если электра является подтипом теслы, она должна взвести все другие теслы рядом
	if(subtype_tesla && activate_friends)
		activate_tesla_around()
	.=..()

/obj/anomaly/electra/proc/activate_tesla_around()
	var/list/anomalies_list = list()
	get_anomalies_in_view_fast(get_turf(src), 5, anomalies_list)
	for(var/obj/anomaly/electra/picked_electra in anomalies_list)
		if(picked_electra.isready() && picked_electra.subtype_tesla)
			picked_electra.last_activation_time = world.time
			picked_electra.activate_anomaly(FALSE)

/obj/anomaly/electra/get_effect_by_anomaly(atom/movable/target)
	set waitfor = FALSE
	set background = TRUE
	electroanomaly_act(target, src)


///Функция обрабатывающее влияние электроаномалии на цель
/proc/electroanomaly_act(atom/movable/target, obj/anomaly/electra/input_electra, called_by_tesla = FALSE)
	set waitfor = FALSE
	set background = TRUE
	//Понадобится нам, если обьект по какой-либо причине будет удалён из-за удара, дабы "лучу" было куда идти
	var/target_turf = get_turf(target)
	if(!isturf(target.loc))
		return
	if(isanomaly(target))
		return

	var/create_line = FALSE //Если цель подходит под критерии удара, мы рисуем молнию
	if(input_electra && !called_by_tesla)
		if(get_dist(input_electra, target) > 1.5)
			if(!isliving(target) && !isitem(target) && !istype(target, /obj/structure/mech_wreckage) && !isaurora(target))
				return
			input_electra.play_sound_second_time = TRUE
			tesla_act_start(target, 2 SECONDS, input_electra)
			return
	if(istype(target, /mob/living)) //Жертвой удара является моб или его наследник(ребёнок)
		create_line = TRUE
		if(istype(target, /mob/living/carbon/human/adherent))
			electra_adherant_effect(target)

		else if(ishuman(target))
			electra_human_effect(target)
			stun_and_jittery_by_electra(target)

		else if(istype(target, /mob/living/silicon/robot )) //Если целью является борг, мы так же наносим ему электроудар
			electra_borg_effect(target)

		else if(istype(target, /mob/living/exosuit)) //Если целью является мех, мы наносим ему ЭМИ удар
			electra_mech_effect(target)

		else if(istype(target, /mob/living)) //Если целью является симплмоб, мы его гибаем
			electra_mob_effect(target)

	else if(isaurora(target))
		var/obj/structure/aurora/aurora = target
		aurora.wake_up(rand(5 SECONDS, 10 SECONDS))
		create_line = TRUE

	else if(istype(target, /obj/structure/mech_wreckage ))
		qdel(target)

	//Если целью является предмет, мы его испепеляем
	else if(istype(target, /obj/item/cell/pruzhina))
		var/obj/item/cell/pruzhina/victim = target
		victim.charge = victim.maxcharge
		create_line = TRUE

	else if(isitem(target))
		if(!istype(target, /obj/item/artefact))
			create_line = TRUE
			anything_in_ashes(target)

	if(input_electra)
		//Этот код и создаст саму молнию от центра аномалии до жертвы
		if(create_line)
			draw_electra_lighting(get_turf(input_electra), target_turf)


///Функция отрисует молнию от турфа А к турфу Б
/proc/draw_electra_lighting(turf/A, turf/B)
	var/obj/electra_holder/spawned_electra_holder = new /obj/electra_holder (A)
	spawned_electra_holder.beam = spawned_electra_holder.Beam(BeamTarget = B, icon_state = "electra_long",icon='mods/anomaly/icons/effects.dmi',time = 0.3 SECONDS)

/obj/electra_holder
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	var/datum/beam

//Задача функции - сделать "замедленный" удар по цели.
//Сперва мы обозначаем КУДА мы ударим, после какого-то времени производим удар
/obj/electrostatic
	icon = 'icons/effects/effects.dmi'
	icon_state = "blue_electricity_constant"
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE

/proc/tesla_act_start(target, attack_delay, obj/anomaly/electra/input_electra)
	var/target_turf = get_turf(target)
	var/obj/spawnerd_electra_particles = new /obj/electrostatic (target_turf)
	addtimer(new Callback(GLOBAL_PROC, GLOBAL_PROC_REF(tesla_act_end), target_turf, input_electra, spawnerd_electra_particles), attack_delay)

/proc/tesla_act_end(target_turf, obj/anomaly/electra/input_electra, spawnerd_electra_particles)
	qdel(spawnerd_electra_particles)
	draw_electra_lighting(get_turf(input_electra), target_turf)
	for(var/atom/detected_atom in target_turf)
		electroanomaly_act(detected_atom, input_electra, TRUE)
	input_electra.play_sound_second_time()

/obj/anomaly/electra/proc/play_sound_second_time()
	if(play_sound_second_time)
		play_sound_second_time = FALSE
		play_anomaly_sound()

///Отдельная функция для просчёта влияния электры
/mob/living/proc/electoanomaly_damage(shock_damage, obj/source, def_zone = null)
	if(status_flags & GODMODE)	//godmode
		return 0

	apply_damage(shock_damage, DAMAGE_BURN, def_zone, used_weapon="Electrocution")
	return shock_damage


///Выводит в чат о электроударе
/mob/living/proc/inform_about_electroanomaly_act(source)
	src.visible_message(
		SPAN_WARNING("[src] was electrocuted[source ? " by the [source]" : ""]!"), \
		SPAN_DANGER("You feel a powerful shock course through your body!"), \
		SPAN_WARNING("You hear a heavy electrical crack.") \
		)

/obj/anomaly/electra/get_detection_icon()
	if(effect_range == 1)
		return "electra_detection"
	else if(effect_range == 2)
		return "tesla_first_detection"
	else if(effect_range > 2)
		return "tesla_second_detection"
