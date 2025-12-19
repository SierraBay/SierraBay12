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
			addtimer(new Callback(movable, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, throw_power, throw_power), 0)
	if (--GLOB.running_explosions < 0)
		GLOB.running_explosions = 0

#undef EXPLOSION_MIN_POWER
#undef EXPLOSION_BUSY_TIMEOUT


/turf/proc/explosion_spread(power, direction, list/turfs)
	if (turfs[src] >= power)
		return
	turfs[src] = power
	var/spread_power = power - get_explosion_resistance()
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
	return ..()
