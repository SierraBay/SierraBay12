/datum/build_mode/anomalies
	name = "Anomaly spawner and editor"
	icon_state = "buildmode10"
	var/anomaly_type
	var/choosed_cooldown_time
	var/choosed_effect_time
	var/choosed_need_preload
	var/choosed_effect_range
	var/choosed_effect_type




	var/list/possible_anomalies = list(
		/obj/anomaly/zharka = "Жарка - аномалия накладывающая BURN урон и поджигающая всех в зоне поражения. Взводится от болта и мобов.",
		/obj/anomaly/zharka/short_effect = "Жарка - аномалия накладывающая BURN урон и поджигающая всех в зоне поражения. Взводится от болта и мобов.",
		/obj/anomaly/zharka/long_effect = "Жарка - аномалия накладывающая BURN урон и поджигающая всех в зоне поражения. Взводится от болта и мобов.",
		/obj/anomaly/electra/three_and_three = "Электра - аномалия наносящая электроудар (50 урона + стан) всех в зоне поражения. Реагирует на мобов, металлические предметы. Подтип ТЕСЛА бьёт дальше чем чувствует, параметр предзарядка заставит её сперва зарядить, и лишь потом ударить. НЕ СОВЕТУЮ СОВМЕЩАТЬ ТЕСЛУ И ПРЕДЗАРЯДКУ.",
		/obj/anomaly/electra/three_and_three/tesla = "Электра - аномалия наносящая электроудар (50 урона + стан) всех в зоне поражения. Реагирует на мобов, металлические предметы. Подтип ТЕСЛА бьёт дальше чем чувствует, параметр предзарядка заставит её сперва зарядить, и лишь потом ударить. НЕ СОВЕТУЮ СОВМЕЩАТЬ ТЕСЛУ И ПРЕДЗАРЯДКУ.",
		/obj/anomaly/electra/three_and_three/tesla_second = "Электра - аномалия наносящая электроудар (50 урона + стан) всех в зоне поражения. Реагирует на мобов, металлические предметы. Подтип ТЕСЛА бьёт дальше чем чувствует, параметр предзарядка заставит её сперва зарядить, и лишь потом ударить. НЕ СОВЕТУЮ СОВМЕЩАТЬ ТЕСЛУ И ПРЕДЗАРЯДКУ.",
		/obj/anomaly/vspishka = "Вспышка - аномалия накладывающее ослепление и стан на всех людей в зоне поражения. Обнаруживается лишь детектором, реагирует на мобов.",
		/obj/anomaly/rvach/three_and_three = "Рвач - аномалия всасывающая в себе все предметы и существ в случае активации. Обнаруживается детектором, предметами и мобами. Из аномалии можно выбраться, если пытаться вылезать после 5 секунд активации (Если ориентироваться по звуку, то прям перед звуком удара). Люди лишаются конечностей (Руки/ноги), мобов гибает, вещи удаляет. Админский параметр мощности способен гибать, вместо отрывания конечностей.",
		/obj/anomaly/heater/multisize = "Холодильник - аномалия охлаждающая все существа находящиеся на турфе ядра и вспомогательных частей. Обнаруживается лишь детектором, никакие скафандры не защищают от её влияния. Взводятся лишь мобом.",
		/obj/anomaly/tramplin = "Трамплин - аномалия швыряющая вещи и мобов находящиеся на её турфе. Не может сдвинуть меха."
	)
	var/help_text = {"\
********* Build Mode: Areas ********
Left Click        - Place anomaly
Right Click       - Delete anomaly
Middle click      - Choose anomaly
Shift + Left Click- Information about choosed anomaly
Cntrl + Left Click - Configurate anomaly
************************************\
"}



/datum/build_mode/anomalies/Destroy()
	UnselectAnomaly()
	Unselected()
	. = ..()


/datum/build_mode/anomalies/Help()
	to_chat(user, SPAN_NOTICE(help_text))


/datum/build_mode/anomalies/OnClick(atom/A, list/parameters)
	//Удаление аномалии
	if (parameters["right"])
		if(istype(A, /obj/anomaly))
			var/obj/anomaly/target = A
			target.delete_anomaly()
		else
			to_chat(user, SPAN_BAD("This is not anomaly"))
		return
	//Тонкая настройка именно этой аномалии
	else if(parameters["ctrl"])
		if(istype(A, /obj/anomaly))
			configurate_clicked_anomaly(A)
		else
			configurate_choosed_anomaly()
		return
	//Выбираем какую аномалию хотим заспавнить
	else if(parameters["middle"])
		Configurate()
		return
	else if(parameters["shift"])
		to_chat(user, SPAN_NOTICE("[possible_anomalies[anomaly_type]]"))
		return
	//Аномалия не выбрана
	if(!anomaly_type)
		to_chat(user, SPAN_BAD("Anomaly not choosed"))
		return
	var/location = get_turf(A)
	var/obj/anomaly/spawned_anomaly = new anomaly_type (location)
	if(choosed_cooldown_time)
		spawned_anomaly.cooldown_time = choosed_cooldown_time
	if(choosed_effect_time)
		spawned_anomaly.effect_time = choosed_effect_time
	if(choosed_need_preload)
		spawned_anomaly.need_preload = choosed_need_preload
	if(choosed_effect_range)
		spawned_anomaly.effect_range = choosed_effect_range
	if(choosed_effect_type)
		spawned_anomaly.effect_type = choosed_effect_type


/datum/build_mode/anomalies/Configurate()
	var/choosed_anomaly_type = input(usr, "Choose anomaly for spawn","Configurate") as null|anything in possible_anomalies
	anomaly_type = choosed_anomaly_type

/datum/build_mode/anomalies/proc/SelectAnomaly(obj/anomaly/A)
	if(!A || A == anomaly_type)
		return
	UnselectAnomaly()
	anomaly_type = A
	GLOB.destroyed_event.register(anomaly_type, src, PROC_REF(UnselectAnomaly))

/datum/build_mode/anomalies/proc/configurate_clicked_anomaly(obj/anomaly/input_anomaly)
	var/list/options = list("Время отката", "Время действия", "Предзарядка", "Радиус воздействия","Моментальное/Продолжительное воздействие")
	var/choosed_configuration = input(usr, "Выберите параметр для настройки","Configurate") as null|anything in options
	if(choosed_configuration == "Время отката")
		input_anomaly.cooldown_time = input("Каково будет время отката?") as num|null
	else if(choosed_configuration == "Время действия")
		input_anomaly.effect_time = input("Как долго аномалия будет воздействовать(Работает, если аномалия типа воздействия ПРОДОЛЖИТЕЛЬНОЕ.)") as num|null
	else if(choosed_configuration == "Предзарядка")
		input_anomaly.need_preload = input("Аномалии потребуется предзарядка перед воздействием?") as num|null
	else if(choosed_configuration == "Радиус воздействия")
		input_anomaly.effect_range = input("Радиус воздействия аномалии(целое число)?") as num|null
		calculate_effected_turfs_from_moving_anomaly(input_anomaly)
	else if(choosed_configuration == "Моментальное/Продолжительное воздействие")
		var/list/variations = list("Моментальное", "Продолжительное")
		var/choose = input("Время воздействия аномалии?") as null|anything in variations
		if(choose == "Моментальное")
			input_anomaly.effect_type = 2
		else if(choose == "Продолжительное")
			input_anomaly.effect_type =  1


/datum/build_mode/anomalies/proc/configurate_choosed_anomaly()

	var/list/options = list("Время отката", "Время действия", "Предзарядка", "Радиус воздействия","Моментальное/Продолжительное воздействие", "Очистить все настройки", "Вывести текущие настройки")
	var/choosed_configuration = input(usr, "Выберите параметр для настройки","Configurate") as null|anything in options
	if(choosed_configuration == "Время отката")
		choosed_cooldown_time = input("Каково будет время отката?") as num|null
	else if(choosed_configuration == "Время действия")
		choosed_effect_time = input("Как долго аномалия будет воздействовать(Работает, если аномалия типа воздействия ПРОДОЛЖИТЕЛЬНОЕ.)") as num|null
	else if(choosed_configuration == "Предзарядка")
		choosed_need_preload = input("Аномалии потребуется предзарядка перед воздействием?") as num|null
	else if(choosed_configuration == "Радиус воздействия")
		choosed_effect_range = input("Радиус воздействия аномалии(целое число)?") as num|null
	else if(choosed_configuration == "Моментальное/Продолжительное воздействие")
		var/list/variations = list("Моментальное", "Продолжительное")
		var/choose = input("Время воздействия аномалии?") as null|anything in variations
		if(choose == "Моментальное")
			choosed_effect_type = 2
		else if(choose == "Продолжительное")
			choosed_effect_type =  1
	else if(choosed_configuration == "Очистить все настройки")
		choosed_cooldown_time = null
		choosed_effect_time = null
		choosed_need_preload = null
		choosed_effect_range = null
		choosed_effect_type	 = null

	else if(choosed_configuration == "Вывести текущие настройки")
		to_chat(user, SPAN_NOTICE("[choosed_cooldown_time]"))
		to_chat(user, SPAN_NOTICE("[choosed_effect_time]"))
		to_chat(user, SPAN_NOTICE("[choosed_need_preload]"))
		to_chat(user, SPAN_NOTICE("[choosed_effect_range]"))
		to_chat(user, SPAN_NOTICE("[choosed_effect_type]"))



/datum/build_mode/anomalies/proc/UnselectAnomaly()
	if(!anomaly_type)
		return
	GLOB.destroyed_event.unregister(anomaly_type, src, PROC_REF(UnselectAnomaly))
	anomaly_type = null

/*
WIP
// ANOMALY CONTROL MODULE
/datum/admins/proc/anomaly_control()
	set category = "Fun"
	set desc = "Control anomalies in world"
	set name = "Anomaly control"

	if(!check_rights(R_SPAWN) && !check_rights(R_DEBUG) && !check_rights(R_ADMIN))
		return
	var/datum/nano_module/anom_control/anom = new /datum/nano_module/anom_control(usr)
	anom.ui_interact(usr)

/datum/nano_module/anom_control
	var/template = "anom_control.tmpl"
	var/current_tab = "anomalies" // текущая активная вкладка
	var/list/selected_z_levels = list() // выбранные Z-уровни
	var/list/all_z_levels = list() // все доступные Z-уровни

/datum/nano_module/anom_control/New()
	..()
	// Инициализируем список всех Z-уровней
	for(var/i in 1 to world.maxz)
		all_z_levels += i

/datum/nano_module/anom_control/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.modlist_state)
	var/list/data = list()

	// Данные для выбора Z-уровней
	data["z_levels"] = list()
	for(var/z in all_z_levels)
		data["z_levels"] += list(list(
			"z" = z,
			"selected" = (z in selected_z_levels),
			"name" = get_z_level_name(z)
		))

	// Данные для вкладок
	data["current_tab"] = current_tab

	// Данные для конкретных вкладок
	switch(current_tab)
		if("anomalies")
			data["anomalies_data"] = get_anomalies_data()
		if("artifacts")
			data["artifacts_data"] = get_artifacts_data()
		if("narrator")
			data["narrator_data"] = get_narrator_data()
		if("other")
			data["other_data"] = get_other_data()
		if("wip")
			data["wip_data"] = get_wip_data()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-anom_control.tmpl", "Повелитель зоны", 800, 600, state = state)
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/anom_control/proc/get_anomalies_data()
	var/list/data = list()
	// Здесь собираем данные об аномалиях на выбранных Z-уровнях
	// Пример:
	data["anomalies"] = list()
	for(var/obj/anomaly/anom in SSanom.all_anomalies_cores)
		if(anom.z in selected_z_levels)
			data["anomalies"] += list(list(
				"name" = anom.name,
				"location" = "[anom.x], [anom.y], [anom.z]",
				"ref" = "\ref[anom]"
			))
	return data

/datum/nano_module/anom_control/proc/get_artifacts_data()
	var/list/data = list()
	// Данные об артефактах
	return data

/datum/nano_module/anom_control/proc/get_narrator_data()
	var/list/data = list()
	// Данные для рассказчика
	return data

/datum/nano_module/anom_control/proc/get_other_data()
	var/list/data = list()
	// Другие данные
	return data

/datum/nano_module/anom_control/proc/get_wip_data()
	var/list/data = list()
	// WIP данные
	return data

/datum/nano_module/anom_control/Topic(href, href_list)
	if(..())
		return 1

	// Обработка выбора Z-уровней
	if(href_list["toggle_z"])
		var/z = text2num(href_list["toggle_z"])
		if(z in selected_z_levels)
			selected_z_levels -= z
		else
			selected_z_levels += z
		return 1

	// Обработка переключения вкладок
	if(href_list["switch_tab"])
		current_tab = href_list["switch_tab"]
		return 1

	// Обработка действий с аномалиями
	if(href_list["anomaly_action"])
		var/obj/anomaly/anom = locate(href_list["anomaly_action"])
		var/action = href_list["action"]
		if(!istype(anom))
			return 1

		switch(action)
			if("delete")
				qdel(anom)
			if("move")
				qdel(anom) // Логика перемещения аномалии
			if("modify") // Логика модификации аномалии
				qdel(anom)
		return TRUE

	// Обновляем UI после изменений
	SSnano.update_uis(src)

/datum/nano_module/anom_control/proc/get_z_level_name(z)
	// Возвращаем читаемое имя для Z-уровня
	switch(z)
		if(1)
			return "Station"
		if(2)
			return "Asteroid"
		if(3)
			return "Space"
		else
			return "Level [z]"
*/
