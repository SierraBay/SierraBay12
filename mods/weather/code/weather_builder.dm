/datum/build_mode/weather
	name = "Weather"
	icon_state = "buildmode10"
	var/current_placement_mode = "С контроллерами"
	var/current_weather_type

	var/list/possible_weather_managers = list(
		/datum/weather_manager/snow = "Снежная погода с выбросом",
		/datum/weather_manager/snow/no_blowout = "Снежная погода без выброса",
		/datum/weather_manager/titan_rain = "Проливной дождь",
		/datum/weather_manager/titan_rain/no_cunami = "Проливной дождь без последующего цунами и влияния на туфры воды"
	)

	var/help_text = {"\
********* Build Mode: Areas ********
Left Click        - Разместить контроллер погоды в этой зоне
Right Click       - Удалить погоду или зону в зависимости от типа взаимодействия
Middle click      - Переключить режим работы с контроллерами/отдельной погодой
Shift + Left Click - Информация о зоне
************************************\
"}

/datum/build_mode/weather/Destroy()
	Unselected()
	. = ..()

/datum/build_mode/weather/Help()
	to_chat(user, SPAN_NOTICE(help_text))

/datum/build_mode/weather/OnClick(atom/A, list/parameters)
	if (parameters[MOUSE_2])
		delete_smthg_on_turf(A)
		return
	else if(parameters[MOUSE_3] && parameters[MOUSE_CTRL])
		switch_placement_mode()
		return
	else if(parameters[MOUSE_3])
		switch_spawning_atom()
		return
	else
		place_smthg(A)

/datum/build_mode/weather/proc/delete_smthg_on_turf(atom/input_atom)
	if(current_placement_mode == "С контроллерами")
		var/area/detected_area = get_area(input_atom)
		if(!detected_area.connected_weather_manager)
			to_chat(usr, SPAN_DANGER("Здесь нет контроллера погоды"))
			return
		var/confirmation = alert("Вы ТООООЧНООО хотите удалить контроллер в зоне [detected_area]?", "Бэм", "Да", "Не")
		if(confirmation == "Не")
			return
		detected_area.connected_weather_manager.Destroy()
	else if(current_placement_mode == "С погодой")
		for(var/obj/weather/detected_weather in get_turf(input_atom))
			detected_weather.Destroy()

/datum/build_mode/weather/proc/switch_placement_mode()
	var/new_mode = input(usr, "Будем взаимодействовать с контроллерами, или с отдельным квадратом погоды?", "Бэм", null) as null|anything in list("С контроллерами", "С погодой")
	if(new_mode)
		current_placement_mode = new_mode
		if(current_placement_mode == "С контроллерами")
			to_chat(usr, SPAN_DANGER("Теперь вы работаете с контроллером определённой зоны"))
		else if(current_placement_mode == "С погодой")
			to_chat(usr, SPAN_DANGER("Теперь вы работаете с отдельными кубами погоды"))

/datum/build_mode/weather/proc/switch_spawning_atom()
	var/new_weather_type = input(usr, "Выбирайте, какую погоду размещать", "Бэм", null) as null|anything in possible_weather_managers
	if(new_weather_type)
		current_weather_type = new_weather_type
		to_chat(usr, "Выбрана погода [current_weather_type].")

/datum/build_mode/weather/proc/place_smthg(atom/input_atom)
	if(!current_weather_type)
		to_chat(usr, "Контроллер погоды не выбран.")
		return
	if(current_placement_mode == "С контроллерами")
		var/area/input_area = get_area(input_atom)
		if(input_area.connected_weather_manager)
			to_chat(user, SPAN_DANGER("Здесь уже есть контроллер погоды."))
			return
		else
			input_area.deploy_new_weather_manager(current_weather_type, deploy_weather = TRUE)
			to_chat(user, SPAN_NOTICE("Контроллер погоды успешно размещен в зоне [input_area]. Погода расставлена автоматически."))

	else if(current_placement_mode == "С погодой")
		if(!current_weather_type)
			to_chat(usr, "Погоды нет.")
			return
		var/turf/input_turf = get_turf(input_atom)
		var/area/input_area = get_area(input_atom)
		if(!input_area.connected_weather_manager)
			input_area.deploy_new_weather_manager(current_weather_type)
		var/obj/weather/spawned_weather = new input_area.connected_weather_manager.weather_turf_type(input_turf)
		input_area.connected_weather_manager.connect_weather_to_manager(spawned_weather)
		to_chat(usr, SPAN_NOTICE("Погода [spawned_weather] успешно размещена на [input_turf]."))
