

/// Builds a list of z-level populations to allow for easier pauses on processing when nobody is around to care
SUBSYSTEM_DEF(presence)
	name = "Player Presence"
	priority = SS_PRIORITY_PRESENCE
	wait = 2 SECONDS
	var/static/list/levels = list()
	var/static/list/queue = list()
	var/static/list/build


/datum/controller/subsystem/presence/Recover()
	queue.Cut()
	build = null


// [SIERRA-EDIT] - Use numeric z-level array instead of stringified keys
/datum/controller/subsystem/presence/fire(resume, no_mc_tick)
	if (!resume)
		queue = GLOB.living_players.Copy()
		build = list()
		LIST_RESIZE(build, world.maxz)
	var/cut_until = 1
	var/build_len = length(build)
	for (var/mob/living/player as anything in queue)
		++cut_until
		if (QDELETED(player) || player.is_real_dead())
			continue
		var/pz = player.z || get_z(player)
		if (pz >= 1 && pz <= build_len)
			build[pz] = (build[pz] || 0) + 1
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			queue.Cut(1, cut_until)
			return
	levels = build
	queue.Cut()


#ifndef UNIT_TEST

/datum/controller/subsystem/presence/flags = SS_NO_INIT

/// 0, or the number of living players on level
/datum/controller/subsystem/presence/proc/population(level)
	var/list/L = levels
	if (level < 1 || level > length(L))
		return 0
	return L[level] || 0
// [/SIERRA-EDIT]

#else

/datum/controller/subsystem/presence/flags = SS_NO_INIT | SS_NO_FIRE

/datum/controller/subsystem/presence/proc/population(level)
	return 1

#endif
