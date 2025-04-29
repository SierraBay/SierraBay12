/obj/overmap/radio/distress/panic_distress
	name = "panic distress"
	icon = 'packs/infinity/icons/obj/distress.dmi'
	icon_state = "distress"

/obj/overmap/radio/distress/panic_distress/get_scan_data(mob/user)
	return list("A unilateral, broadband data broadcast originating at \the [source] carrying only an emergency code sequence.")

/obj/overmap/radio/distress/panic_distress/set_origin(obj/overmap/origin)
	GLOB.moved_event.register(origin, src, TYPE_PROC_REF(/obj/overmap/radio, follow))
	GLOB.destroyed_event.register(origin, src, TYPE_PROC_REF(/datum, qdel_self))
	forceMove(origin.loc)
	source = origin
	pixel_x = 0
	pixel_y = 0

/obj/overmap/visitable/proc/distress(mob/user)

	log_and_message_admins(message ="Overmap panic button hit on z[z] ([name]) by '[user?.ckey || "Unknown"]'")

	var/distress_message = "Это автоматический сигнал бедствия от радиомаяка, соответствующего стандарту MIL-DTL-93352, передаваемого на частоте [PUB_FREQ*0.1]кГц.  \
	Этот маяк был запущен с  '[initial(name)]'. Местоположение передающего устройства: [get_distress_info()]. \
	Согласно Межпланетной конвенции о космической спасательной деятельности, лица, получившие это сообщение, должны попытаться предпринять попытку спасения, \
	или передать сообщение тем, кто может это сделать. Это сообщение повторится еще раз через 5 минут. Спасибо за вашу помощь."

	//sends to a single z-level of every /obj/overmap/visitable
	var/list/sent_to_z = list()
	for(var/zlevel in map_sectors)
		var/obj/overmap/visitable/O = map_sectors[zlevel]
		if(!isnull(O))
			var/should_send = TRUE
			var/list/overmap_z_list = O.map_z
			for(var/z_map in overmap_z_list)
				if(z_map in sent_to_z)
					should_send = FALSE
				else
					sent_to_z.Add(z_map)
			if(should_send && length(overmap_z_list))
				priority_announcement.Announce(distress_message, "Automated Distress Signal", new_sound = sound('packs/infinity/sound/AI/sos.ogg'), zlevels = overmap_z_list)

	//sends to a single random z-level (original)
	//priority_announcement.Announce(distress_message, "Automated Distress Signal", new_sound = sound('packs/infinity/sound/AI/sos.ogg'), zlevels = GLOB.using_map.player_levels)

	var/obj/overmap/radio/distress/panic_distress/emergency_signal = new /obj/overmap/radio/distress/panic_distress()

	emergency_signal.set_origin(src)

	addtimer(new Callback(src, PROC_REF(distress_update)), 5 MINUTES)
	return TRUE

/obj/overmap/visitable/proc/get_distress_info()
	return "\[X:[x], Y:[y]\]"

// Get heading in degrees (like a compass heading)
/obj/overmap/visitable/ship/proc/get_heading_degrees()
	return (Atan2(speed[2], speed[1]) + 360) % 360 // Yes ATAN2(y, x) is correct to get clockwise degrees

/obj/overmap/visitable/ship/get_distress_info()
	var/turf/T = get_turf(src) // Usually we're on the turf, but sometimes we might be landed or something.
	var/x_to_use = T?.x || "UNK"
	var/y_to_use = T?.y || "UNK"
	return "\[X:[x_to_use], Y:[y_to_use], VEL:[get_speed() * 1000], HDG:[get_heading_degrees()]\]"

/obj/overmap/visitable/proc/distress_update()
	var/message = "Это последнее сообщение с маяка бедствия, запущенного '[initial(name)]'. Местоположение передающего устройства: [get_distress_info()]. \
	Пожалуйста, окажите помощь в соответствии с вашими обязательствами по Межпланетной конвенции о космической спасательной деятельности, или передайте это сообщение той стороне, которая может это сделать."

	//sends to a single z-level of every /obj/overmap/visitable
	var/list/sent_to_z = list()
	for(var/zlevel in map_sectors)
		var/obj/overmap/visitable/O = map_sectors[zlevel]
		if(!isnull(O))
			var/should_send = TRUE
			var/list/overmap_z_list = O.map_z
			for(var/z_map in overmap_z_list)
				if(z_map in sent_to_z)
					should_send = FALSE
				else
					sent_to_z.Add(z_map)
			if(should_send && length(overmap_z_list))
				priority_announcement.Announce(message, "Automated Distress Signal", new_sound = sound('packs/infinity/sound/AI/sos.ogg'), zlevels = overmap_z_list)

	//sends to a single random z-level (original)
	//priority_announcement.Announce(message, "Automated Distress Signal", new_sound = sound('packs/infinity/sound/AI/sos.ogg'), zlevels = GLOB.using_map.player_levels)