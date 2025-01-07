/obj/anomaly
	///Шанс, что аномалию найдут детектором при условии что у пользователя максимальный навык науки
	var/chance_to_be_detected = 100
	//Спрайт обнаруженной аномалии. Смотри прок get_detection_icon(). Этот спрайт - стандартный для любых аномок.
	var/detection_icon_state = "any_anomaly"
	///Уровень навыка в науке, требуемый, чтоб персонаж смог понять тип аномалии
	var/detection_skill_req = SKILL_TRAINED


/obj/item/clothing/gloves/anomaly_detector
	name = "anomaly detection device"
	desc = "A complex technological device designed taking into account all possible dangers of anomalies."
	icon = 'mods/anomaly/icons/detector.dmi'
	icon_state = "detector_idle"
	var/destroyed = FALSE // Детектор убит из-за ЭМИ и уже никогда не проснётся.
	//Базовое название детектора используемое в коде смена иконок.
	var/detector_basic_name = "detector"
	action_button_name = "Scan anomalies"
	var/last_peek_time = 0
	var/peek_delay = 1 SECONDS
	var/show_anomalies_delay = 10 SECONDS
	var/in_tesla_range = FALSE
	var/in_scanning = FALSE
	var/last_scan_time = 0
	var/result_tesla = FALSE
	//Круги обнаружения
	var/start_garanted_detection_radius = 3 //Гарантированный радиус обнаружения присутствия аномалии
	var/garanted_detection_per_skill = 2
	var/start_chance_detection_radius = 4
	var/chance_detection_per_skill = 4
	//Некоторые детекторы могут вовсе не замечать некоторые аномалии. Укажите их теги, если потребутеся (Переменная anomaly_tag)
	var/list/blacklisted_amomalies = list()

/obj/item/clothing/gloves/anomaly_detector/emp_act(severity)
	SHOULD_CALL_PARENT(FALSE)
	if(!destroyed)
		destroyed = TRUE
		STOP_PROCESSING(SSanom, src)
		SSanom.processing_ammount--

/obj/item/clothing/gloves/anomaly_detector/proc/switch_toggle()
	if(destroyed)
		to_chat(usr, SPAN_NOTICE("Устройство не реагирует на нажатие кнопки. Похоже, оно уже не включится."))
		return
	if(!is_processing)
		to_chat(usr, SPAN_NOTICE("Вы включили детектор"))
		START_PROCESSING(SSanom, src)
		SSanom.processing_ammount++
	else
		to_chat(usr, SPAN_NOTICE("Вы выключили детектор"))
		STOP_PROCESSING(SSanom, src)
		SSanom.processing_ammount--


/obj/item/clothing/gloves/anomaly_detector/attack_self(mob/living/user)
	. = ..()
	if(!is_processing)
		to_chat(usr, SPAN_BAD("Сперва включите устройство."))
		return
	try_found_anomalies(user)

/obj/item/clothing/gloves/anomaly_detector/CtrlClick(mob/user)
	. = ..()
	switch_toggle()
	return TRUE

/obj/item/clothing/gloves/anomaly_detector/Process()
	..()
	check_electrostatic()
	update_icon()

/obj/item/clothing/gloves/anomaly_detector/on_update_icon()
	.=..()
	if(!in_tesla_range && !in_scanning)
		icon_state = "[detector_basic_name]_idle"
	else if(in_tesla_range && !in_scanning)
		icon_state = "[detector_basic_name]_idle_and_peak"
	else if(!in_tesla_range && in_scanning)
		icon_state = "[detector_basic_name]_scanning"
	else if(in_tesla_range && in_scanning)
		icon_state = "[detector_basic_name]_scanning_and_peak"


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
	to_chat(user, SPAN_GOOD("Жмите ЛКМ когда включен, для сканирования, или жмите на кнопку слева сверху."))
	to_chat(user, SPAN_GOOD("Жмите Контрол + ЛКМ чтоб включить/выключить устройство."))

///Пользователь проводит поиск при помощи сканера
/obj/item/clothing/gloves/anomaly_detector/proc/try_found_anomalies(mob/living/user)
	if((user.r_hand != src && user.l_hand !=src) && (wearer && wearer.gloves != src) )
		to_chat(user, SPAN_BAD("Не дотягиваюсь до детектора."))
		return
	if(!user.skill_check(SKILL_SCIENCE, SKILL_BASIC))
		to_chat(user, SPAN_BAD("Понятия не имею как им пользоваться."))
		return
	//Мы проверили, есть ли у пользователя базовый навык НАУКИ.
	// Снижаем 1.2 секунды сканирования за каждый пункт науки у персонажа
	var/user_science_lvl = user.get_skill_value(SKILL_SCIENCE)
	var/time_to_scan = (10 - (1 * user_science_lvl)) SECONDS
	in_scanning = TRUE
	update_icon()
	usr.update_action_buttons()
	if (do_after(user, time_to_scan, src, DO_DEFAULT | DO_USER_UNIQUE_ACT) && user)
		in_scanning = FALSE
		update_icon()
		usr.update_action_buttons()
		//Время прошло, пользователь простоял нужное нам время.
		//1.Расчитаем гарантированный круг обнаружения
		//2.Расчитаем шансовый круг обнаружения
		var/garant_radius = calculate_garanted_radius(user)
		var/chance_radius = calculate_chance_radius(user)
		var/scan_radius
		if(chance_radius > garant_radius)
			scan_radius = chance_radius
		else
			scan_radius = garant_radius
		var/list/victims = list()
		var/list/objs = list()
		var/turf/T = get_turf(src)
		get_mobs_and_objs_in_view_fast(T, scan_radius, victims, objs)
		//Собрали все обьекты рядом
		//Список разрешённых для показа игроку аномалий
		var/list/allowed_anomalies = list()
		allowed_anomalies = calculate_allowed_anomalies(objs, garant_radius, user_science_lvl)
		show_anomalies(user, 15 SECONDS, allowed_anomalies)
		if(LAZYLEN(allowed_anomalies))
			flick("detector_detected_anomalies", src)
			usr.update_action_buttons()
	else
		in_scanning = FALSE
		update_icon()
		usr.update_action_buttons()

/obj/item/clothing/gloves/anomaly_detector/proc/calculate_allowed_anomalies(list/input_anomalies_list, garant_radius, user_science_lvl)
	var/list/result_anomalies_list = list()
	for(var/obj/anomaly/choosed_anomaly in input_anomalies_list)
		//Если аномалия в блэклисте детектора - игнорируем аномалию
		if(choosed_anomaly.anomaly_tag in blacklisted_amomalies)
			continue
		//Если в зоне гарант круга
		if(get_dist(src, choosed_anomaly) <= garant_radius)
			LAZYADD(result_anomalies_list, choosed_anomaly) //Добавляем саму аномалию
		//Если у неё есть вспомогательные части - добавляем её вспомогательные части
			if(choosed_anomaly.multitile)
				for(var/obj/anomaly/choosed_part in choosed_anomaly.list_of_parts)
					LAZYADD(result_anomalies_list, choosed_part)
		//Если в зоне шансового круга
		else
			if(!choosed_anomaly.is_helper) //Вспомогательные части аномалий нас не интересуют
				var/chance_to_find = (user_science_lvl * 20) - (100 - choosed_anomaly.chance_to_be_detected)
				if(prob(chance_to_find))
					LAZYADD(result_anomalies_list, choosed_anomaly) //Добавляем саму аномалию
					//Если у неё есть вспомогательные части - добавляем её вспомогательные части
					if(choosed_anomaly.multitile)
						for(var/obj/anomaly/choosed_part in choosed_anomaly.list_of_parts)
							LAZYADD(result_anomalies_list, choosed_part)
	return result_anomalies_list

/obj/item/clothing/gloves/anomaly_detector/proc/calculate_garanted_radius(mob/living/user)
	var/skill_num = user.get_skill_value(SKILL_SCIENCE) - 1
	return start_garanted_detection_radius + (garanted_detection_per_skill * skill_num)

/obj/item/clothing/gloves/anomaly_detector/proc/calculate_chance_radius(mob/living/user)
	var/skill_num = user.get_skill_value(SKILL_SCIENCE) - 1
	return start_chance_detection_radius + (chance_detection_per_skill * skill_num)

///Показывает игроку аномалии, которые он обнаружил детектером
/proc/show_anomalies(mob/living/viewer, flick_time, allowed_anomalies)
	if(!ismob(viewer) || !viewer.client)
		return
	var/user_science_lvl = viewer.get_skill_value(SKILL_SCIENCE)
	var/list/list_of_showed_anomalies = list()
	for(var/obj/anomaly/in_turf_atom in allowed_anomalies)
		var/turf/T = get_turf(in_turf_atom)
		var/image/I
		if(user_science_lvl >= in_turf_atom.detection_skill_req)
			I = image(icon = 'mods/anomaly/icons/detection_icon.dmi',loc = T, icon_state = in_turf_atom.get_detection_icon())
		else
			I = image(icon = 'mods/anomaly/icons/detection_icon.dmi',loc = T, icon_state = "any_anomaly")
		I.layer = EFFECTS_ABOVE_LIGHTING_PLANE
		list_of_showed_anomalies += I

	if(length(list_of_showed_anomalies))
		flick_overlay(list_of_showed_anomalies, list(viewer.client), flick_time)


/obj/item/paper/sierra/exploration
	name = "new dangers"
	info = "<tt><center><b><large>NSV Sierra</large></b></center><center>Новые опасности</center><li><b>Одна из последних экспедиций вернулась с новой информацией, и ранениями. Согласно последнему отчёту, экспедиционный отряд наткнулся на некую аномальную активность на одной из планет. Научно исследовательский отдел выделил вашему отряду дополнительное снаряжение в виде маячков, коллекторов аномальных образований, детектора аномальной активности и раздатчика флагов. Советуем проявлять огромную осторожность при работе на планетах. Удачи.</b><hr></tt><br><i>This paper has been stamped by the Research&Development department.</i>"
	icon = 'maps/sierra/icons/obj/uniques.dmi'
	icon_state = "paper_words"

/datum/design/item/bluespace/detector
	name = "anomaly detector"
	desc = "Experiment anomaly detector, which can detect anomalies."
	id = "anomaly_detector"
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 4, TECH_BLUESPACE = 4, TECH_POWER = 4)
	build_path = /obj/item/clothing/gloves/anomaly_detector
	materials = list(MATERIAL_ALUMINIUM = 4000, MATERIAL_STEEL = 4000, MATERIAL_PLASTIC = 4000)
	sort_string = "VAWAB"
