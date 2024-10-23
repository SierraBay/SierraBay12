GLOBAL_LIST_EMPTY(effected_by_weather)
GLOBAL_VAR_INIT(ambience_channel_weather, GLOB.sound_channels.RequestChannel("AMBIENCE_WEATHER"))

///Кто-то или что-то вошло в монитор-эффект
/obj/monitor_effect_triger/Crossed(O)
	react_at_enter_monitor(O)

/obj/monitor_effect_triger/Uncrossed(O)
	react_at_leave_monitor(O)

/obj/monitor_effect_triger/proc/add_monitor_effect(mob/living/input_mob)
	LAZYADD(input_mob,GLOB.effected_by_weather)

/obj/monitor_effect_triger/proc/remove_monitor_effect(mob/living/input_mob)
	LAZYREMOVE(input_mob,GLOB.effected_by_weather)

/obj/monitor_effect_triger/proc/react_at_enter_monitor(atom/movable/atom)
	if(!must_react_at_enter)
		return
	//Незачем накладывать эффект тому, кто уже с этим эффектом
	if(atom in GLOB.effected_by_weather)
		return
	if(isliving(atom))
		var/mob/living/detected_mob = atom
		//Если у моба есть клиент, значит есть на кого накладывать эффект на экран
		if(detected_mob.client)
			if(LAZYLEN(sound_type))
				var/sound = sound(pick(sound_type), repeat = TRUE, wait = 0, volume = 50, channel = GLOB.ambience_channel_weather)
				detected_mob.playsound_local(get_turf(detected_mob), sound)
			add_monitor_effect(detected_mob)
			//Если прошло достаточно времени с предыдущего пука в чат игроку - пукнем.
			if(detected_mob.last_monitor_message < world.time)
				to_chat(detected_mob, SPAN_BAD(pick(trigger_messages_list)))
				//Добавим время от КД
				detected_mob.last_monitor_message = detected_mob.last_monitor_message + trigger_message_cooldown

/obj/monitor_effect_triger/proc/react_at_leave_monitor(atom/movable/atom)
	if(!must_react_at_enter)
		return
	var/mob/detected_mob = atom
	if(!IsMonitorHere(get_turf(atom)))
		remove_monitor_effect(detected_mob)
		if(LAZYLEN(sound_type))
			sound_to(detected_mob, sound(null, channel = GLOB.ambience_channel_weather))

/proc/IsMonitorHere(turf/input_turf)
	if(locate(/obj/monitor_effect_triger) in input_turf)
		return TRUE
	else
		return FALSE
