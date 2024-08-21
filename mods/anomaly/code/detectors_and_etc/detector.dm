//Детектор Сарасповой получил дополнительную функцию - проверять, находится ли детектор в зоне поражения аномалии.
#define SCAN_ANOMALIES 1
#define SCAN_ARTEFACTS_AND_RADIATION 2

/turf
	var/in_anomaly_effect_range = FALSE

/obj/anomaly
	///Шанс, что аномалию найдут детектором при условии что у пользователя максимальный навык науки
	var/chance_to_be_detected = 100

/obj/item/device/ano_scanner
	var/current_mode = SCAN_ARTEFACTS_AND_RADIATION
	var/last_peek_time = 0
	var/peek_delay = 0.2 SECONDS
	var/show_anomalies_delay = 10 SECONDS
	var/last_anomaly_search = 0


///Альт клик по детектору
/obj/item/device/ano_scanner/AltClick(mob/living/user)
	changemode(user)

///Смена режима работы детектора
/obj/item/device/ano_scanner/proc/changemode(mob/living/user)
	if(current_mode == SCAN_ARTEFACTS_AND_RADIATION)
		current_mode = SCAN_ANOMALIES
		START_PROCESSING(SSobj, src)
		to_chat(user, SPAN_NOTICE("Current mode: Scan anomalies"))
	else if(current_mode == SCAN_ANOMALIES)
		current_mode = SCAN_ARTEFACTS_AND_RADIATION
		STOP_PROCESSING(SSobj, src)
		to_chat(user, SPAN_NOTICE("Current mode: Scan artifacts and radiation"))
	playsound(loc, 'sound/weapons/guns/selector.ogg', 40)

/obj/item/device/ano_scanner/interact(mob/living/user)
	if(current_mode == SCAN_ANOMALIES)
		scan_anomalies(user) //Пищит если мы в зоне поражения
		try_found_anomalies(user)
		return
	.=..()


/obj/item/device/ano_scanner/proc/scan_anomalies()
	if(world.time - last_scan_time >= peek_delay )
		last_peek_time = world.time
	var/turf/cur_turf = get_turf(src)
	//Проверяем, турф на котором мы находимся находится в зоне поражения?
	if(cur_turf.in_anomaly_effect_range)
		playsound(loc, 'mods/anomaly/sounds/detector_peek.ogg', 40)

/obj/item/device/ano_scanner/Process()
	if(current_mode != SCAN_ANOMALIES)
		return
	scan_anomalies()

/obj/item/device/ano_scanner/examine(mob/user, distance, is_adjacent)
	. = ..()
	to_chat(user, SPAN_GOOD("Use alt+LBM to switch scan mode."))

///Пользователь проводит поиск при помощи сканера
/obj/item/device/ano_scanner/proc/try_found_anomalies(mob/living/user)
	if((world.time - last_anomaly_search) < show_anomalies_delay )
		to_chat(user, SPAN_BAD("Device is stil cooling."))
		return
	last_anomaly_search = world.time
	if(!user.skill_check(SKILL_SCIENCE, SKILL_BASIC))
		to_chat(user, SPAN_BAD("I dont know how use this function of this device."))
		return
	//Мы проверили, есть ли у пользователя базовый навык НАУКИ.
	// Снижаем 1.2 секунды сканирования за каждый пункт науки у персонажа
	var/user_science_lvl = user.get_skill_value(SKILL_SCIENCE)
	var/time_to_scan = (10 - (1.2 * user_science_lvl)) SECONDS
	var/scan_radius = (4 + user_science_lvl) //макс радиус - 9 "квадратов"
	if (do_after(user, time_to_scan, src, DO_DEFAULT | DO_USER_UNIQUE_ACT) && user)
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
		var/flick_time = (1 + (user_science_lvl * 2))SECONDS
		last_anomaly_search = world.time
		show_anomalies(user, flick_time, allowed_anomalies)


/obj/item/paper/sierra/exploration
	name = "new dangers"
	info = "<tt><center><b><large>NSV Sierra</large></b></center><center>Новые опасности</center><li><b>Одна из последних экспедиций вернулась с новой информацией, и ранениями. Согласно последнему отчёту, экспедиционный отряд наткнулся на некую аномальную активность на одной из планет. Научно исследовательский отдел выделил вашему корпусу дополнительное снаряжение и модифицировал сканеры Сарасповой, добавив им АЛЬТЕРНАТИВНЫЙ режим. Советуем проявлять огромную осторожность при работе на планетах. Удачи.</b><hr></tt><br><i>This paper has been stamped by the Research&Development department.</i>"
	icon = 'maps/sierra/icons/obj/uniques.dmi'
	icon_state = "paper_words"


/proc/show_anomalies(mob/viewer, flick_time, allowed_anomalies)
	if(!ismob(viewer) || !viewer.client)
		return
	var/list/t_ray_images = list()
	for(var/obj/anomaly/in_turf_atom in allowed_anomalies)
		var/turf/T = get_turf(in_turf_atom)
		var/image/I = image(icon = 'mods/anomaly/icons/effects.dmi',loc = T,icon_state = "none")
		var/mutable_appearance/MA = new(in_turf_atom)
		MA.alpha = 255
		MA.dir = in_turf_atom.dir
		MA.plane = FLOAT_PLANE
		I.layer = HUD_ABOVE_ITEM_LAYER
		I.appearance = MA
		t_ray_images += I

	for(var/image/choosed_image in t_ray_images)
		choosed_image.icon_state = "none"
	if(length(t_ray_images))
		flick_overlay(t_ray_images, list(viewer.client), flick_time)
