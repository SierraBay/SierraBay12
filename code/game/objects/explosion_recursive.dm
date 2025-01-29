<<<<<<< ours
/*
var/global/list/explosion_turfs = list()

var/global/explosion_in_progress = 0


/proc/explosion_rec(turf/epicenter, power, shaped)
	var/loopbreak = 0
	while(explosion_in_progress)
		if(loopbreak >= 15) return
		sleep(10)
		loopbreak++

	if(power <= 0) return
	epicenter = get_turf(epicenter)
//[SIERRA-ADD] - MODPACK_RND
	if(!epicenter) return
	for(var/obj/item/device/beacon/explosion_watcher/W in explosion_watcher_list)
		if(get_dist(W, epicenter) < 10)
			W.react_explosion(epicenter, power)
//[/SIERRA-ADD] - MODPACK_RND

	explosion_in_progress = 1
	explosion_turfs = list()

	explosion_turfs[epicenter] = power

	//This steap handles the gathering of turfs which will be ex_act() -ed in the next step. It also ensures each turf gets the maximum possible amount of power dealt to it.
	for(var/direction in GLOB.cardinal)
		var/turf/T = get_step(epicenter, direction)
		var/adj_power = power - epicenter.get_explosion_resistance()
		if(shaped)
=======
#define EXPLOSION_MIN_POWER 0.05
#define EXPLOSION_BUSY_TIMEOUT 10

/// The number of /proc/explosion_rec currently in progress
GLOBAL_VAR_AS(running_explosions, 0)

/proc/explosion_rec(turf/epicenter, power, shaped, force)
	if (power <= 0)
		return
	var/busy_timeout = EXPLOSION_BUSY_TIMEOUT
	epicenter = get_turf(epicenter)
	if (!epicenter)
		return
	var/x = epicenter.x
	var/y = epicenter.y
	var/z = epicenter.z
	while (GLOB.running_explosions > 0)
		if (force)
			break
		if (--busy_timeout < 1)
			log_debug("explosion at [epicenter] timed out waiting to run")
			return
		sleep(0.5 SECONDS)
	if (busy_timeout < EXPLOSION_BUSY_TIMEOUT)
		epicenter = get_turf(epicenter)
		if (!epicenter)
			return
	var/power_self = power - epicenter.get_explosion_resistance()
	if (power_self < EXPLOSION_MIN_POWER)
		return
	++GLOB.running_explosions
	var/list/turfs = list()
	turfs[epicenter] = power
	for (var/direction in GLOB.cardinal)
		var/turf/sibling = get_step(epicenter, direction)
		if (!sibling)
			continue
		var/power_sibling = power_self
		if (shaped)
>>>>>>> theirs
			if (shaped == direction)
				power_sibling *= 3
			else if (shaped == reverse_direction(direction))
				power_sibling *= 0.10
			else
				power_sibling *= 0.45
		if (power_sibling < EXPLOSION_MIN_POWER)
			continue
		sibling.explosion_spread(power_sibling, direction, turfs)
	for (var/turf/turf as anything in turfs)
		if (!turf)
			continue
		var/severity = turfs[turf]
		if (severity <= 0)
			continue
		severity /= max(3, power / 3)
		severity = clamp(severity, 1, 3)
		severity = 4 - severity
		severity = floor(severity)
<<<<<<< ours

		var/x = T.x
		var/y = T.y
		var/z = T.z
		T.ex_act(severity)
		if(!T)
			T = locate(x,y,z)

		var/throw_target = get_edge_target_turf(T, get_dir(epicenter,T))
		for(var/atom_movable in T.contents)
			var/atom/movable/AM = atom_movable
			if(AM && AM.simulated && !T.protects_atom(AM))
				AM.ex_act(severity)
				if(!QDELETED(AM) && !AM.anchored)
					addtimer(new Callback(AM, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, 9/severity, 9/severity), 0)

	explosion_turfs.Cut()
	explosion_in_progress = 0


//Code-wise, a safe value for power is something up to ~25 or ~30.. This does quite a bit of damage to the station.
//direction is the direction that the spread took to come to this tile. So it is pointing in the main blast direction - meaning where this tile should spread most of it's force.
/turf/proc/explosion_spread(power, direction)

	if(explosion_turfs[src] >= power)
		return //The turf already sustained and spread a power greated than what we are dealing with. No point spreading again.
	explosion_turfs[src] = power
/*
	sleep(2)
	var/obj/debugging/M = locate() in src
	if (!M)
		M = new(src, power, direction)
	M.maptext = "[power] vs [src.get_explosion_resistance()]"
	if(power > 10)
		M.color = "#cccc00"
	if(power > 20)
		M.color = "#ffcc00"
*/
	var/spread_power = power - src.get_explosion_resistance() //This is the amount of power that will be spread to the tile in the direction of the blast
=======
		x = turf.x
		y = turf.y
		z = turf.z
		turf.ex_act(severity)
		if (!turf)
			turf = locate(x, y, z)
		var/throw_target = get_edge_target_turf(turf, get_dir(epicenter, turf))
		var/throw_power = 9 / severity
		for (var/atom/movable/movable in turf)
			if (!movable?.simulated || turf.protects_atom(movable))
				continue
			movable.ex_act(severity)
			if (QDELETED(movable) || movable.anchored)
				continue
			addtimer(new Callback(movable, /atom/movable/.proc/throw_at, throw_target, throw_power, throw_power), 0)
	if (--GLOB.running_explosions < 0)
		GLOB.running_explosions = 0

#undef EXPLOSION_MIN_POWER
#undef EXPLOSION_BUSY_TIMEOUT


/turf/proc/explosion_spread(power, direction, list/turfs)
	if (turfs[src] >= power)
		return
	turfs[src] = power
	var/spread_power = power - get_explosion_resistance()
>>>>>>> theirs
	if (spread_power <= 0)
		return
	var/spread_dir = direction
	get_step(src, spread_dir)?.explosion_spread(spread_power, spread_dir, turfs)
	spread_dir = turn(direction, 90)
	get_step(src, spread_dir)?.explosion_spread(spread_power, spread_dir, turfs)
	spread_dir = turn(direction, -90)
	get_step(src, spread_dir)?.explosion_spread(spread_power, spread_dir, turfs)


/turf/unsimulated/explosion_spread()
	return


/// Float. The atom's explosion resistance value. Used to calculate how much of an explosion is 'absorbed' and not passed on to tiles on the other side of the atom's turf. See `/proc/explosion_rec()`.
/atom/var/explosion_resistance = 0


/// Retrieves the atom's explosion resistance. Generally, this is `explosion_resistance` for simulated atoms.
/atom/proc/get_explosion_resistance()
	if (simulated)
		return explosion_resistance


/turf/get_explosion_resistance()
	. = ..()
	for (var/obj/O in src)
		. += O.get_explosion_resistance()


/turf/space/explosion_resistance = 3


/turf/simulated/floor/get_explosion_resistance()
	. = ..()
	if (is_below_sound_pressure(src))
		. *= 3


/turf/simulated/wall/get_explosion_resistance()
	return 5 // Standardized health results in explosion_resistance being used to reduce overall damage taken, instead of changing explosion severity. 5 was the original default, so 5 is always returned here.


/turf/simulated/floor/explosion_resistance = 1


/turf/simulated/open/explosion_resistance = 1


/turf/simulated/open/get_explosion_resistance()
	. = ..()
	if (is_below_sound_pressure(src))
		. *= 3


/turf/simulated/mineral/explosion_resistance = 2


/turf/simulated/shuttle/wall/explosion_resistance = 10


/turf/simulated/wall/explosion_resistance = 10


/obj/machinery/door/get_explosion_resistance()
	if (!density)
		return 0
<<<<<<< ours
	else
		return ..()
*/
=======
	return ..()
>>>>>>> theirs
