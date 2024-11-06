//Рвач просто порвёт конечности
#define RVACH_DAMAGE_EFFECT 2
//Рвач гибнет, админская штука
#define RVACH_DESTROY_EFFECT 3

/obj/anomaly/rvach
	name = "Refractions of light"
	with_sound = TRUE
	sound_type = 'mods/anomaly/sounds/rvach_activation.ogg'
	idle_effect_type = "rvach_idle"
	activation_effect_type = "rvach_activation"
	can_born_artifacts = TRUE
	///Сколько длится первая фаза рвача(всасывание)
	effect_time = 4 SECONDS
	effect_type = LONG_ANOMALY_EFFECT
	effect_power = RVACH_DAMAGE_EFFECT
	cooldown_time = 15 SECONDS
	iniciators = list(
		/mob/living,
		/obj/item
	)
	artefacts = list(
		/obj/item/artefact/gravi = 1
	)
	artefact_spawn_chance = 20

//Аномалия выполняет своё финальное воздействие на все обьекты что оказались в её центре
/obj/anomaly/rvach/proc/get_end_effect_by_anomaly(target)
///Рвач отрывает конечности, гибает обычные вещи с пола
	//Если рвач мощный
	if(effect_power == RVACH_DESTROY_EFFECT)
		if(istype(target, /mob/living))
			var/mob/living/victim = target
			victim.gib()
			playsound(src, 'mods/anomaly/sounds/rvach_gibbed.ogg', 100, FALSE  )

	//Если рвач обычный
	else if(effect_power == RVACH_DAMAGE_EFFECT)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/victim = target
			if(!victim.incapacitated(INCAPACITATION_UNRESISTING) == TRUE) //Убедимся что наш чувак в сознании
				//Персонаж может вырваться из аномали, деж если он аутист
				if(victim.skill_check(SKILL_HAULING, SKILL_MASTER))
					if(prob(7 * victim.get_skill_value(SKILL_HAULING)))
						victim.Weaken(10)
						to_chat(victim, SPAN_WARNING("То-ли от страха, то-ли от огромной физической подготовки, вы выныриваете из аномалии."))
						return

			//Создаём список органов, которые мы МОЖЕМ оторвать
			var/list/list_of_organs_types = list(
				/obj/item/organ/external/arm,
				/obj/item/organ/external/arm/right,
				/obj/item/organ/external/leg,
				/obj/item/organ/external/leg/right
			)
			var/obj/item/organ/external/to_destroy = pick(list_of_organs_types)
			for(var/obj/item/organ/external/E in victim.organs)
				if(E.type == to_destroy)
					E.take_external_damage(500)
					playsound(src, 'mods/anomaly/sounds/rvach_gibbed.ogg', 100, FALSE  )
		else if(istype(target, /mob/living))
			var/mob/living/victim = target
			victim.gib()
			playsound(src, 'mods/anomaly/sounds/rvach_gibbed.ogg', 100, FALSE  )
		else if(istype(target, /obj/item))
			qdel(target)
		else if(istype(target, /obj/structure/mech_wreckage))
			qdel(target)

//Рвач всасывает всех в свой центр
/obj/anomaly/rvach/process_long_effect()
	rvach_pull_around(src, effect_range, STAGE_THREE)
	start_processing_long_effect()


/obj/anomaly/rvach/stop_processing_long_effect()
	addtimer(new Callback(src, PROC_REF(rvach_gib)), 2 SECONDS)


/obj/anomaly/rvach/proc/rvach_gib()
	for(var/atom/movable/target in src.loc)
		get_end_effect_by_anomaly(target)
	//Рвач раскидает всех из себя
	throw_everyone_from_rvach()
	//Выполняем стандартные действия функции stop_processing_long_effect()
	stop_long_visual_effect()
	currently_active = FALSE
	start_recharge()

//Рвач раскидывает всё что попадает в зону рвача из себя
/obj/anomaly/rvach/proc/throw_everyone_from_rvach()
	//Если рвач мультитайтловый
	for(var/atom/movable/victim in src.loc)
		if(!ismob(victim) && !isitem(victim) )
			continue
		if(!victim.anchored)
			victim.throw_at_random(get_turf(src), effect_range+1, 5)
	if(multitile)
		for(var/obj/anomaly/part/parts in list_of_parts)
			var/throw_dir = get_dir(src, parts)
			var/target_turf = get_edge_target_turf(parts, throw_dir)
			for(var/atom/movable/victim in parts.loc)
				if(!ismob(victim) && !isitem(victim) )
					continue
				if(!victim.anchored)
					victim.throw_at(target_turf, effect_range, 5)


/proc/rvach_pull_around(atom/target, pull_range = 255, pull_power = STAGE_FIVE)
	for(var/atom/A in range(pull_range, target))
		if(ismech(A))
			continue
		A.rvach_anomaly_pull(get_turf(target), pull_power)


/atom/proc/rvach_anomaly_pull(turf/target, current_size)
	return

/obj/item/rvach_anomaly_pull(turf/target, current_size)
	step_towards(src, target)

/mob/living/rvach_anomaly_pull(turf/target, current_size)
	step_towards(src, target)
	Weaken(5)

/mob/living/carbon/human/rvach_anomaly_pull(turf/target, current_size)
	if(target != src.loc)
		adjust_stamina(-30)
		to_chat(src, SPAN_BAD("Не могу, рано, меня с силой тащит обратно, тяжёло!"))
		if(stamina < 30)
			Paralyse(1)
			to_chat(src, SPAN_BAD("Нет сил!"))
	step_towards(src, target)
	Weaken(1)

/obj/anomaly/rvach/Crossed(atom/movable/O)
	if(currently_active)
		return
	if(currently_charging_after_activation)
		return
	if(can_be_activated(O))
		activate_anomaly()
	return
