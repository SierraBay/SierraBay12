/datum/map_template/load(turf/T, centered=FALSE)
	if(centered)
		T = locate(T.x - round(width/2) , T.y - round(height/2) , T.z)
	if(!T)
		log_debug("[src] map template failed to load, could not locate a center turf.")
		return
	if(T.x+width > world.maxx)
		log_debug("[src] map template failed to load, map would extend past world X bound.")
		return
	if(T.y+height > world.maxy)
		log_debug("[src] map template failed to load, map would extend past world Y bound.")
		return

	var/list/atoms_to_initialise = list()
	var/shuttle_state = pre_init_shuttles()

	var/initialized_areas_by_type = list()
	for (var/mappath in mappaths)
		var/datum/map_load_metadata/M = GLOB.maploader.load_map(file(mappath), T.x, T.y, T.z, cropMap=TRUE, clear_contents=(template_flags & TEMPLATE_FLAG_CLEAR_CONTENTS), initialized_areas_by_type = initialized_areas_by_type)
		if (M)
			atoms_to_initialise += M.atoms_to_initialise
		else
			log_debug("Failed to load map file [mappath] for [src].")
			return FALSE

	//initialize things that are normally initialized after map load
	init_atoms(atoms_to_initialise)
	init_shuttles(shuttle_state)
	after_load(T.z)
	SSlighting.InitializeTurfs(atoms_to_initialise)	// Hopefully no turfs get placed on new coords by SSatoms.
	log_game("[name] loaded at at [T.x],[T.y],[T.z]")
	loaded++
	for(var/obj/weather/detected_weather in SSweather.weather_turf_in_world)
		detected_weather.update_by_map_templace()

	return TRUE
