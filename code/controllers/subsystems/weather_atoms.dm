SUBSYSTEM_DEF(weather_atoms)
	name     = "Weather Atoms"
	wait     = 2 SECONDS
	priority = SS_PRIORITY_WEATHER
	flags    = SS_NO_INIT
	var/list/weather_atoms = list()
	var/list/processing_atoms

	// Predeclared vars for processing.
	var/atom/atom
	var/obj/abstract/weather_system/weather
	var/singleton/state/weather/weather_state

/datum/controller/subsystem/weather_atoms/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	..("A:[length(weather_atoms)]")

/datum/controller/subsystem/weather_atoms/fire(resumed = 0)
	// [SIERRA-EDIT] - Skip completely if no weather systems exist, and check z-level weather before expensive outside checks
	var/list/weather_by_z = SSweather.weather_by_z
	var/max_weather_z = length(weather_by_z)
	if(!resumed)
		if(!length(SSweather.weather_systems) || !length(weather_atoms))
			return
		processing_atoms = weather_atoms.Copy()

	atom          = null
	weather       = null
	weather_state = null

	var/i = 0
	var/proc_len = length(processing_atoms)
	while(i < proc_len)
		i++
		atom = processing_atoms[i]

		// Atom is null or doesn't exist, remove it from processing.
		if(QDELETED(atom))
			weather_atoms -= atom
			continue

		var/az = atom.z
		if(!az || az > max_weather_z)
			continue

		weather = weather_by_z[az]
		if(!weather)
			continue

		weather_state = weather.weather_system?.current_state
		if(!istype(weather_state))
			continue

		// Outside check runs only for atoms on z-levels that actually have active weather.
		var/turf/T = isturf(atom.loc) ? atom.loc : get_turf(atom)
		if(!istype(T) || !T.is_outside())
			continue

		// Process the atom and return early if needed.
		if(atom.process_weather(weather, weather_state) == PROCESS_KILL)
			weather_atoms -= atom
		if (MC_TICK_CHECK)
			processing_atoms.Cut(1, i+1)
			return

	processing_atoms.Cut()
	// [/SIERRA-EDIT]

/atom/proc/process_weather(obj/abstract/weather_system/weather, singleton/state/weather/weather_state)
	return PROCESS_KILL
