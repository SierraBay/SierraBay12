/obj/anomaly
	///Шанс, что аномалию найдут детектором при условии что у пользователя максимальный навык науки
	var/chance_to_be_detected = 100


/obj/item/clothing/gloves/anomaly_detector
	name = "anomaly detection device"
	desc = "A complex technological device designed taking into account all possible dangers of anomalies."
	icon = 'mods/anomaly/icons/detector.dmi'
	icon_state = "detector_idle"
	action_button_name = "Scan anomalies"
	var/last_peek_time = 0
	var/peek_delay = 1 SECONDS
	var/show_anomalies_delay = 10 SECONDS
	var/in_tesla_range = FALSE
	var/in_scanning = FALSE
	var/last_scan_time = 0
	var/result_tesla = FALSE
	var/global_scan_cooldown = 300 SECONDS
	var/last_global_scan = 0

/obj/item/clothing/gloves/anomaly_detector/Initialize()
	. = ..()
	START_PROCESSING(SSanom, src)
	SSanom.processing_ammount++


/obj/item/clothing/gloves/anomaly_detector/attack_self(mob/living/user)
	. = ..()
	try_found_anomalies(user)

/obj/item/clothing/gloves/anomaly_detector/AltClick()
	scan_z_level_for_anomalies(usr)
	return TRUE

/obj/item/clothing/gloves/anomaly_detector/Process()
	check_electrostatic()
	update_icon()

/obj/item/clothing/gloves/anomaly_detector/on_update_icon()
	.=..()
	if(!in_tesla_range && !in_scanning)
		icon_state = "detector_idle"
	else if(in_tesla_range && !in_scanning)
		icon_state = "detector_idle_and_peak"
	else if(!in_tesla_range && in_scanning)
		icon_state = "detector_scanning"
	else if(in_tesla_range && in_scanning)
		icon_state = "detector_scanning_and_peak"


/obj/item/clothing/gloves/anomaly_detector/verb/scan_anomalies()
	set category = "Object"
	set name = "Scan anomalies"
	set src in usr

	if(!usr.incapacitated())
		try_found_anomalies(usr)
		usr.update_action_buttons()

/obj/item/clothing/gloves/anomaly_detector/proc/check_electrostatic()
	if(world.time - last_peek_time < peek_delay )
		return
	last_peek_time = world.time
	var/turf/cur_turf = get_turf(src)
	//Проверяем, турф на котором мы находимся находится в зоне поражения?
	if(LAZYLEN(cur_turf.list_of_in_range_anomalies))
		playsound(loc, 'mods/anomaly/sounds/detector_peek.ogg', 40)
		result_tesla = TRUE
	else
		result_tesla = FALSE
	if(result_tesla != in_tesla_range)
		in_tesla_range = result_tesla
		update_icon()
		if(wearer)
			wearer.update_action_buttons()


/obj/item/clothing/gloves/anomaly_detector/examine(mob/user, distance, is_adjacent)
	. = ..()
	to_chat(user, SPAN_GOOD("Use LBM in anomaly scan mode for search anomalies, or use action button."))
	to_chat(user, SPAN_GOOD("Use Alt + LBM to use more powerfull mode."))

///Пользователь проводит поиск при помощи сканера
/obj/item/clothing/gloves/anomaly_detector/proc/try_found_anomalies(mob/living/user)
	if((user.r_hand != src && user.l_hand !=src) && (wearer && wearer.gloves != src) )
		to_chat(user, SPAN_BAD("You cant reach device."))
		return
	if(!user.skill_check(SKILL_SCIENCE, SKILL_BASIC))
		to_chat(user, SPAN_BAD("I dont know how use this function of this device."))
		return
	//Мы проверили, есть ли у пользователя базовый навык НАУКИ.
	// Снижаем 1.2 секунды сканирования за каждый пункт науки у персонажа
	var/user_science_lvl = user.get_skill_value(SKILL_SCIENCE)
	var/time_to_scan = (20 - (2 * user_science_lvl)) SECONDS
	var/scan_radius = (4 + user_science_lvl) //макс радиус - 9 "квадратов"
	in_scanning = TRUE
	update_icon()
	usr.update_action_buttons()
	if (do_after(user, time_to_scan, src, DO_DEFAULT | DO_USER_UNIQUE_ACT) && user)
		in_scanning = FALSE
		update_icon()
		usr.update_action_buttons()
		//Время прошло, пользователь простоял нужное нам время.
		var/list/victims = list()
		var/list/objs = list()
		var/turf/T = get_turf(src)
		get_mobs_and_objs_in_view_fast(T, scan_radius, victims, objs)
		//Собрали все обьекты рядом
		//Список разрешённых для показа игроку аномалий
		var/list/allowed_anomalies = list()
		for(var/obj/anomaly/choosed_anomaly in objs)
			var/chance_to_find = (user_science_lvl * 20) - (100 - choosed_anomaly.chance_to_be_detected)
			if(prob(chance_to_find))
				LAZYADD(allowed_anomalies, choosed_anomaly)
		show_anomalies(user, time_to_scan, allowed_anomalies)
		if(LAZYLEN(allowed_anomalies))
			flick("detector_detected_anomalies", src)
			usr.update_action_buttons()
	else
		in_scanning = FALSE
		update_icon()
		usr.update_action_buttons()


/obj/item/clothing/gloves/anomaly_detector/proc/scan_z_level_for_anomalies(mob/living/user)
	if(in_scanning)
		return
	if((world.time - last_global_scan) < global_scan_cooldown)
		to_chat(user, SPAN_BAD("Detector still isn't ready."))
		return
	last_global_scan = world.time
	var/user_science_lvl = user.get_skill_value(SKILL_SCIENCE)
	var/time_to_scan = (30 - (2 * user_science_lvl)) SECONDS
	in_scanning = TRUE
	update_icon()
	usr.update_action_buttons()
	if (do_after(user, time_to_scan, src, DO_DEFAULT | DO_USER_UNIQUE_ACT) && user)
		in_scanning = FALSE
		update_icon()
		usr.update_action_buttons()
		for(var/obj/anomaly/picked_anomaly in SSanom.all_anomalies_cores)
			if(picked_anomaly.z == get_z(src))
				to_chat(user, SPAN_BAD("Обнаружена аномальная активность."))
				return TRUE
		to_chat(user, SPAN_GOOD("Аномалий не обнаружено."))
		return FALSE

/proc/show_anomalies(mob/viewer, flick_time, allowed_anomalies)
	if(!ismob(viewer) || !viewer.client)
		return
	var/list/list_of_showed_anomalies = list()
	for(var/obj/anomaly/in_turf_atom in allowed_anomalies)
		var/turf/T = get_turf(in_turf_atom)
		//var/image/I = image(icon = 'mods/anomaly/icons/detection_icon.dmi',loc = T, icon_state = in_turf_atom.detection_icon_state)
		var/image/I = image(icon = 'mods/anomaly/icons/effects.dmi',loc = T, icon_state = "none")
		I.layer = EFFECTS_ABOVE_LIGHTING_PLANE
		list_of_showed_anomalies += I

	if(length(list_of_showed_anomalies))
		flick_overlay(list_of_showed_anomalies, list(viewer.client), flick_time)


/obj/item/paper/sierra/exploration
	name = "new dangers"
	info = "<tt><center><b><large>NSV Sierra</large></b></center><center>Новые опасности</center><li><b>Одна из последних экспедиций вернулась с новой информацией, и ранениями. Согласно последнему отчёту, экспедиционный отряд наткнулся на некую аномальную активность на одной из планет. Научно исследовательский отдел выделил вашему отряду дополнительное снаряжение в виде маячков, коллекторов аномальных образований, детектора аномальной активности и раздатчика флагов. Советуем проявлять огромную осторожность при работе на планетах. Удачи.</b><hr></tt><br><i>This paper has been stamped by the Research&Development department.</i>"
	icon = 'maps/sierra/icons/obj/uniques.dmi'
	icon_state = "paper_words"
