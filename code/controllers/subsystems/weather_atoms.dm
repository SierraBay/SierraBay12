SUBSYSTEM_DEF(weather_atoms)
	name     = "Weather Atoms"
	wait     = 2 SECONDS
	priority = SS_PRIORITY_WEATHER
	flags    = SS_NO_INIT
	var/list/weather_mobs = list()
	var/list/weather_cleanables = list()
	var/list/processing_mobs = list()
	var/list/processing_cleanables = list()
	var/current_step = 1
	var/next_mob_process = 0
	var/mob_wait = 5 SECONDS

	// Predeclared vars for processing.
	var/atom/atom
	var/obj/abstract/weather_system/weather
	var/singleton/state/weather/weather_state

#define SSWEATHER_ATOMS_MOBS 1
#define SSWEATHER_ATOMS_CLEANABLES 2

/datum/controller/subsystem/weather_atoms/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	..("M:[length(weather_mobs)] C:[length(weather_cleanables)]")

/datum/controller/subsystem/weather_atoms/fire(resumed = 0)
	if(!resumed)
		current_step = SSWEATHER_ATOMS_CLEANABLES
		if(world.time >= next_mob_process)
			processing_mobs = weather_mobs.Copy()
			next_mob_process = world.time + mob_wait
			current_step = SSWEATHER_ATOMS_MOBS
		else
			processing_mobs.Cut()
		processing_cleanables = weather_cleanables.Copy()

	if(current_step == SSWEATHER_ATOMS_MOBS)
		if(!process_weather_atoms(processing_mobs, weather_mobs))
			return
		current_step = SSWEATHER_ATOMS_CLEANABLES

	if(current_step == SSWEATHER_ATOMS_CLEANABLES)
		if(!process_weather_atoms(processing_cleanables, weather_cleanables, TRUE))
			return
		current_step = SSWEATHER_ATOMS_MOBS

/datum/controller/subsystem/weather_atoms/proc/process_weather_atoms(list/processing_atoms, list/source_atoms, liquid_only = FALSE)
	atom          = null
	weather       = null
	weather_state = null

	while(length(processing_atoms))
		atom = processing_atoms[length(processing_atoms)]
		LIST_DEC(processing_atoms)

		// Atom is null or doesn't exist, remove it from processing.
		if(QDELETED(atom))
			source_atoms -= atom
			if (MC_TICK_CHECK)
				return FALSE
			continue

		// Not outside, or not on a turf with a Z- weather is not relevant.
		if(!atom.z)
			if (MC_TICK_CHECK)
				return FALSE
			continue

		if(ismovable(atom))
			var/turf/atom_turf = get_turf(atom)
			if(!istype(atom_turf) || !atom_turf.is_outside())
				if (MC_TICK_CHECK)
					return FALSE
				continue
			weather = atom_turf.weather || LAZYACCESS(SSweather.weather_by_z, atom_turf.z)
		else
			if(!atom.is_outside())
				if (MC_TICK_CHECK)
					return FALSE
				continue
			weather = atom.get_affecting_weather()

		// If weather does not exist, we don't care.
		weather_state = weather?.weather_system?.current_state
		if(!istype(weather_state))
			if (MC_TICK_CHECK)
				return FALSE
			continue

		if(liquid_only && !weather_state.is_liquid)
			if (MC_TICK_CHECK)
				return FALSE
			continue

		// Process the atom and return early if needed.
		if(atom.process_weather(weather, weather_state) == PROCESS_KILL)
			source_atoms -= atom
		if (MC_TICK_CHECK)
			return FALSE

	processing_atoms.Cut()
	return TRUE

/datum/controller/subsystem/weather_atoms/proc/register_weather_mob(atom/movable/target)
	weather_mobs |= target

/datum/controller/subsystem/weather_atoms/proc/register_weather_cleanable(atom/target)
	weather_cleanables |= target

/datum/controller/subsystem/weather_atoms/proc/unregister_weather_atom(atom/target)
	weather_mobs -= target
	weather_cleanables -= target

#undef SSWEATHER_ATOMS_MOBS
#undef SSWEATHER_ATOMS_CLEANABLES

/atom/proc/process_weather(obj/abstract/weather_system/weather, singleton/state/weather/weather_state)
	return PROCESS_KILL
