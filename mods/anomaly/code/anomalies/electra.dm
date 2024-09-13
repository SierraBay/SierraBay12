/obj/anomaly/electra
	name = "Lightning strikes"
	with_sound = TRUE
	sound_type = 'mods/anomaly/sounds/electra_blast.ogg'
	activation_effect_type = "electra_activation"
	idle_effect_type = "electra_idle"
	layer = ABOVE_HUMAN_LAYER
	light_after_activation = TRUE
	color_of_light = COLOR_WHITE
	time_of_light = 1.5 SECONDS
	can_born_artifacts = TRUE
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
	have_static_sound = TRUE
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

/obj/anomaly/electra/activate_anomaly()
	last_activation_time = world.time//Без этой строчки некоторые электры входят в вечный цикл зарядки и удара, костыль? Возможно
	if(need_preload)
		start_preload()
	last_activation_time = world.time //Без этой строчки некоторые электры входят в вечный цикл зарядки и удара, костыль? Возможно
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
	if(subtype_tesla)
		var/list/victims_not_used = list()
		var/list/objs_second = list()
		get_mobs_and_objs_in_view_fast(T, effect_range * 6, victims_not_used, objs_second)
		for(var/obj/anomaly/electra/electra_anomalies in objs_second)
			if(electra_anomalies.isready() && electra_anomalies.subtype_tesla)
				unwait_activate_anomaly(electra_anomalies)
		for(var/obj/anomaly/part/anomaly_parts in objs_second)
			if(istype(anomaly_parts.core, /obj/anomaly/electra))
				var/obj/anomaly/electra/electra_anomalies = anomaly_parts.core
				if(electra_anomalies.isready() && electra_anomalies.subtype_tesla)
					unwait_activate_anomaly(electra_anomalies)
	.=..()

/obj/anomaly/electra/proc/unwait_activate_anomaly(obj/anomaly/electra/anomaly)
	set waitfor = FALSE
	last_activation_time = world.time
	anomaly.activate_anomaly()

/obj/anomaly/electra/get_effect_by_anomaly(atom/movable/target)
	//Понадобится нам, если обьект по какой-либо причине будет удалён из-за удара, дабы "лучу" было куда идти
	var/target_turf = get_turf(target)
	if(!isturf(target.loc))
		return
	if(isanomaly(target))
		return
	//Если цель подходит под критерии удара, мы рисуем молнию
	var/create_line = FALSE
	//Если целью является адхерант, мы лишь заряжаем его батарею
	if(istype(target, /mob/living/carbon/human/adherent))
		create_line = TRUE
		var/mob/living/carbon/human/adherent/adherent = target
		var/obj/item/cell/power_cell
		var/obj/item/organ/internal/cell/cell = locate() in adherent.internal_organs
		if(cell && cell.cell)
			power_cell = cell.cell
		if(power_cell)
			power_cell.charge = power_cell.maxcharge
			to_chat(target, SPAN_NOTICE("<b>Your [power_cell] has been charged to capacity.</b>"))

	//Цель удара - человек
	else if(istype(target, /mob/living/carbon/human))
		for(var/obj/item/artefact/zjar/defense_artefact in target)
			if(defense_artefact.current_integrity > 1)
				defense_artefact.current_integrity--
				to_chat(target, SPAN_GOOD("[defense_artefact] вспыхивает красной вспышкой"))
			else
				qdel(defense_artefact)
				to_chat(target, SPAN_BAD("[defense_artefact] вспыхивает ярчайшей красной вспышкой и пропадает."))
			to_chat(target, SPAN_GOOD("Вы чувствуете сильный, но приятный ЖАР в месте удара. Но не боль."))
			return
		var/mob/living/carbon/human/victim = target
		var/list/organs = victim.list_organs_to_earth()
		for(var/picked_organ in organs)
			victim.electoanomaly_act(50, src, picked_organ)
	//Если целью является борг, мы так же наносим ему электроудар
	else if(istype(target, /mob/living/silicon/robot ))
		create_line = TRUE
		var/mob/living/silicon/robot/borg = target
		borg.apply_damage(50, DAMAGE_BURN, def_zone = BP_CHEST)
		to_chat(borg, SPAN_DANGER("<b>Powerful electric shock detected!</b>"))

	//Если целью является мех, мы наносим электроудар и эми удар
	else if(istype(target, /mob/living/exosuit))
		create_line = TRUE
		var/mob/living/exosuit/mech = target
		mech.apply_damage(100, DAMAGE_BURN)
		mech.emp_act(1)
	else if(istype(target, /obj/structure/mech_wreckage ))
		qdel(target)
	//Если целью является моб, мы наносим электроудар
	else if(istype(target, /mob/living))
		create_line = TRUE
		var/mob/living/victim = target
		if(victim.health == 0)
			anything_in_remains(victim)
			return
		victim.electoanomaly_act(100, src)

	//Если целью является пепел - мы его удаляем, чтоб не засорять аномалию
	else if(istype(target, /obj/decal/cleanable/ash))
		qdel(target)

	//Если целью является предмет, мы его испепеляем
	else if(istype(target, /obj/item/cell/pruzhina))
		var/obj/item/cell/pruzhina/victim = target
		victim.charge = victim.maxcharge
		create_line = TRUE


	else if(istype(target, /obj/item))
		if(!istype(target, /obj/item/artefact))
			create_line = TRUE
			anything_in_ashes(target)

	//Этот код и создаст саму молнию от центра аномалии до жертвы
	if(create_line)
		beam = src.Beam(BeamTarget = target_turf, icon_state = "electra_long",icon='mods/anomaly/icons/effects.dmi',time = 0.3 SECONDS)






///Отдельная функция для просчёта влияния электры
/mob/living/proc/electoanomaly_act(shock_damage, obj/source, def_zone = null)
	if(status_flags & GODMODE)	//godmode
		return 0

	apply_damage(shock_damage, DAMAGE_BURN, def_zone, used_weapon="Electrocution")

	stun_effect_act(1,1, def_zone)

	src.visible_message(
		SPAN_WARNING("[src] was electrocuted[source ? " by the [source]" : ""]!"), \
		SPAN_DANGER("You feel a powerful shock course through your body!"), \
		SPAN_WARNING("You hear a heavy electrical crack.") \
		)

	Weaken(1)
	make_jittery(min(shock_damage*5, 200))
	return shock_damage

//Выдаёт список конечностей от введёной конечности до земли
/mob/living/carbon/human/proc/list_organs_to_earth(input_organ)
	var/list/result_damaged_zones = list()
	var/attack_zone
	if(!input_organ)
		attack_zone = get_exposed_defense_zone()
	else
		attack_zone = input_organ
	LAZYADD(result_damaged_zones, attack_zone)
	if(attack_zone == BP_HEAD || attack_zone == BP_R_ARM || attack_zone == BP_R_HAND || attack_zone == BP_L_ARM || attack_zone == BP_L_HAND)
		if(attack_zone == BP_R_HAND)
			LAZYADD(result_damaged_zones, BP_R_ARM)
		else if(attack_zone == BP_L_HAND)
			LAZYADD(result_damaged_zones, BP_L_ARM)
		LAZYADD(result_damaged_zones, BP_CHEST)
		LAZYADD(result_damaged_zones, BP_GROIN)
		var/attacked_leg = pick(BP_L_LEG, BP_R_LEG)
		LAZYADD(result_damaged_zones, attacked_leg)
		if(attacked_leg == BP_L_LEG)
			LAZYADD(result_damaged_zones, BP_L_FOOT)
		else if(attacked_leg == BP_R_LEG)
			LAZYADD(result_damaged_zones, BP_R_FOOT)

	else if(attack_zone == BP_CHEST)
		LAZYADD(result_damaged_zones, BP_GROIN)
		var/attacked_leg = pick(BP_L_LEG, BP_R_LEG)
		LAZYADD(result_damaged_zones, attacked_leg)
		if(attacked_leg == BP_L_LEG)
			LAZYADD(result_damaged_zones, BP_L_FOOT)
		else if(attacked_leg == BP_R_LEG)
			LAZYADD(result_damaged_zones, BP_R_FOOT)

	else if(attack_zone == BP_GROIN)
		var/attacked_leg = pick(BP_L_LEG, BP_R_LEG)
		LAZYADD(result_damaged_zones, attacked_leg)
		if(attacked_leg == BP_L_LEG)
			LAZYADD(result_damaged_zones, BP_L_FOOT)
		else if(attacked_leg == BP_R_LEG)
			LAZYADD(result_damaged_zones, BP_R_FOOT)
	else if(attack_zone == BP_L_LEG)
		LAZYADD(result_damaged_zones, BP_L_FOOT)
	else if(attack_zone == BP_R_LEG)
		LAZYADD(result_damaged_zones, BP_R_FOOT)
	return result_damaged_zones
