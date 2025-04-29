/obj/overmap/visitable/sector/exoplanet
	var/weather_manager_type

/obj/overmap/visitable/sector/exoplanet/proc/deploy_weather()
	if(!weather_manager_type)
		return //Погоды то нет()
	var/turf/picked_turf
	picked_turf = pick(get_area_turfs(planetary_area))
	new weather_manager_type(picked_turf)
