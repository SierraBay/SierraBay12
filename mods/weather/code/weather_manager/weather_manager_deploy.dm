//У нас может быть два сценария
//1. Погода спавнится планетой и сразу расставляет все свои единицы погоды
//2. Погода ставится билдер модом и ей НЕ надо сразу расставлять все свои единицы погоды
/obj/overmap/visitable/sector/exoplanet
	var/weather_manager_type

/area
	var/datum/weather_manager/connected_weather_manager

/area/proc/deploy_new_weather_manager(input_weather_manager_type, deploy_weather = FALSE)
	if(!input_weather_manager_type)
		return FALSE
	connected_weather_manager = new input_weather_manager_type(src)
	connected_weather_manager.my_area = src
	connected_weather_manager.my_z = get_z(pick(get_area_turfs(src))) //у зоны нет Z координаты или я даун
	if(deploy_weather)
		for(var/turf/T in contents)
			if(locate(/obj/landmark/no_weather_here, T)) //Здесь стоит запрет на размещение погоды от марки
				continue
			var/spawn_type = connected_weather_manager.weather_turf_type
			var/obj/weather/spawned_weather = new spawn_type(T)
			connected_weather_manager.connect_weather_to_manager(spawned_weather)


/datum/weather_manager/proc/connect_weather_to_manager(obj/weather/input_weather)
	LAZYADD(connected_weather_turfs, input_weather)
