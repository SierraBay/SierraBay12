GLOBAL_LIST_EMPTY(effected_by_weather)
GLOBAL_VAR_INIT(ambience_channel_weather, GLOB.sound_channels.RequestChannel("AMBIENCE_WEATHER"))
#define isweatherhere(A) locate(/obj/weather) in A
/obj/weather
	var/play_monitor_effect = TRUE
	var/play_sound = TRUE
	var/area/start_area //Зона, в которой и создавалась погода. Используется для проверок при спавне карты.
	var/area/last_check_area
	//Виброс
	var/list/blowout_messages = list()
	var/blowout_icon_state
	var/blowout_status = FALSE

///Кто-то или что-то вошло в погоду
/obj/weather/Crossed(O)
	react_at_enter_monitor(O)

/obj/weather/Uncrossed(O)
	react_at_leave_monitor(O)

/obj/weather/Initialize()
	.=..()
	LAZYADD(SSweather.weather_turf_in_world, src)
	start_area = get_area(src)

/obj/weather/proc/update(mob/living/input_mob)
	if(input_mob)
		if(input_mob.client)
			update_visual(input_mob)
			update_sound(input_mob)
	else
		for(var/mob/living/somebody in get_turf(src))
			if(somebody.client)
				update_visual(somebody)
				update_sound(somebody)

/obj/weather/proc/update_sound(mob/living/input_mob)
	if(play_sound)
		var/sound = sound(pick(sound_type), repeat = TRUE, wait = 0, volume = 50, channel = GLOB.ambience_channel_weather)
		input_mob.playsound_local(get_turf(input_mob), sound)
	else
		sound_to(input_mob, sound(null, channel = GLOB.ambience_channel_weather))

/obj/weather/proc/update_visual(mob/living/input_mob)
	if(play_monitor_effect)
		add_monitor_effect(input_mob)
	else
		remove_monitor_effect(input_mob)

/obj/weather/proc/message_about_blowout()
	if(LAZYLEN(blowout_messages))
		for(var/mob/living/somebody in get_turf(src))
			to_chat(somebody, pick(blowout_messages))

/obj/weather/proc/add_monitor_effect(mob/living/input_mob)
	LAZYADD(input_mob,GLOB.effected_by_weather)

/obj/weather/proc/remove_monitor_effect(mob/living/input_mob)
	LAZYREMOVE(input_mob,GLOB.effected_by_weather)

/obj/weather/proc/react_at_enter_monitor(atom/movable/atom)
	if(!must_react_at_enter)
		return
	if(blowout_status)
		react_at_enter_in_blowout(atom)
		return
	//Незачем накладывать эффект тому, кто уже с этим эффектом
	if(atom in GLOB.effected_by_weather)
		return
	if(isliving(atom))
		var/mob/living/detected_mob = atom
		//Если у моба есть клиент, значит есть на кого накладывать эффект на экран
		if(detected_mob.client)
			update_sound(detected_mob)
			update_visual(detected_mob)
			LAZYADD(GLOB.effected_by_weather, atom)

/obj/weather/proc/react_at_leave_monitor(atom/movable/atom)
	if(!must_react_at_enter)
		return
	if(blowout_status)
		react_at_leave_from_blowout(atom)
		return
	var/mob/detected_mob = atom
	if(!isweatherhere(get_turf(atom)))
		if(atom in GLOB.effected_by_weather)
			LAZYREMOVE(GLOB.effected_by_weather, atom)
			remove_monitor_effect(detected_mob)
			if(LAZYLEN(sound_type))
				sound_to(detected_mob, sound(null, channel = GLOB.ambience_channel_weather))


/obj/weather/proc/react_at_enter_in_blowout(atom/movable/atom)
	return

/obj/weather/proc/react_at_leave_from_blowout(atom/movable/atom)
	return

/obj/weather/proc/blowout_check_turf()
	return

/obj/weather/proc/update_by_map_templace() //Функция проверяет что
	if(get_area(get_turf(src)) != start_area)
		delete_weather()
		return
	last_check_area = get_area(get_turf(src))


/obj/weather/proc/delete_weather()
	LAZYREMOVE(SSweather.weather_turf_in_world, src)
	qdel(src)
