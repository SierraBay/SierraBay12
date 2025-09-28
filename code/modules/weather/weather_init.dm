INITIALIZE_IMMEDIATE(/obj/abstract/weather_system)
/obj/abstract/weather_system/Initialize(ml, target_z, initial_weather, list/banned)
	SSweather.register_weather_system(src)

	. = ..()

	set_invisibility(INVISIBILITY_NONE)

	if(prob(20)) // arbitrary chance to already have some degree of wind when the weather system starts
		wind_direction = pick(GLOB.alldirs)
		wind_strength = rand(1,5)

	banned_weather_conditions = banned

	//For planets, we have some data that could be relevant for the future, so let's keep track of planet if any
	var/obj/overmap/visitable/sector/exoplanet/E = map_sectors["[target_z]"]
	if (istype(E))
		planet = E
		water_colour = E.water_color

	// Bookkeeping/rightclick guards.
	verbs.Cut()
	forceMove(null)
	lightning_overlay = new
	vis_contents_additions = list(src, lightning_overlay)

	// Initialize our state machine.
	weather_system = add_state_machine(src, /datum/state_machine/weather)
	weather_system.set_state(initial_weather || /singleton/state/weather/calm)

	// Track our affected z-levels.
	affecting_zs = GetConnectedZlevels(target_z)

	// If we're post-init, init immediately.
	if(SSweather.initialized)
		addtimer(new Callback(src, PROC_REF(init_weather)), 0)

// Start the weather effects from the highest point; they will propagate downwards during update.
/obj/abstract/weather_system/proc/init_weather()
	// Track all z-levels.
	for(var/highest_z in affecting_zs)
		var/turfcount = 0
		if(HasAbove(highest_z))
			continue
		// Update turf weather.
		for(var/turf/T as anything in block(locate(1, 1, highest_z), locate(world.maxx, world.maxy, highest_z)))
			T.update_weather(src)
			turfcount++
			CHECK_TICK
		log_debug("Initialized weather for [turfcount] turf\s from z[highest_z].")
