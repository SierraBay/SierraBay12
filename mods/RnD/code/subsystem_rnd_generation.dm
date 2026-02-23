SUBSYSTEM_DEF(rnd_generation)
	name = "RnD Generation Queue"
	flags = SS_BACKGROUND
	wait = 1

var/list/generation_queue = list()

/datum/controller/subsystem/rnd_generation/Initialize()
	. = ..()
	generation_queue = list()

	// Ensure mission asteroid areas are exempted from area usage tests at runtime
	if(GLOB.using_map)
		if(!istype(GLOB.using_map.area_usage_test_exempted_areas, "list"))
			GLOB.using_map.area_usage_test_exempted_areas = list()
		GLOB.using_map.area_usage_test_exempted_areas |= list(/area/rnd_mission_asteroid)

/datum/controller/subsystem/rnd_generation/proc/queue_asteroid_generation(obj/overmap/visitable/sector/rnd_mission_asteroid/sector)
	if(!sector)
		return
	generation_queue += sector

/datum/controller/subsystem/rnd_generation/fire()
	if(!length(generation_queue))
		return
	var/obj/overmap/visitable/sector/rnd_mission_asteroid/sector = generation_queue[1]
	if(sector && !sector.generation_in_progress)
		sector.generation_in_progress = TRUE
		// Schedule asteroid build with a short delay instead of spawn()
		addtimer(new Callback(sector, TYPE_PROC_REF(/obj/overmap/visitable/sector/rnd_mission_asteroid, build_asteroid)), 1, TIMER_STOPPABLE)
	generation_queue.Cut(1,2)





// ============================================================
// Mission Asteroid Sector - dynamically generated for missions
// ============================================================

/area/rnd_mission_asteroid
	name = "\improper Mission Asteroid"
	icon_state = "mining"
	ambience = list('sound/ambience/ambimine.ogg', 'sound/ambience/song_game.ogg')
	sound_env = ASTEROID
	base_turf = /turf/space
	turfs_airless = TRUE
	always_unpowered = TRUE
	area_flags = AREA_FLAG_EXTERNAL

/obj/overmap/visitable/sector/rnd_mission_asteroid
	name = "asteroid"
	desc = "A small asteroid detected by corporate sensor array. Mission-relevant signatures present."
	icon_state = "asteroid"
	sector_flags = OVERMAP_SECTOR_IN_SPACE | OVERMAP_SECTOR_KNOWN
	sensor_visibility = 50
	var/area/rnd_mission_asteroid/asteroid_area
	var/asteroid_size = 30
	var/list/_rnd_build_params

/obj/overmap/visitable/sector/rnd_mission_asteroid/New()
	if(!GLOB.using_map || !GLOB.using_map.use_overmap)
		return

	name = "RnD-[rand(100,999)], \a [name]"

	asteroid_area = new /area/rnd_mission_asteroid()
	asteroid_area.name = "Surface of [name]"

	INCREMENT_WORLD_Z_SIZE
	forceMove(locate(1, 1, world.maxz))
	..()

/obj/overmap/visitable/sector/rnd_mission_asteroid
	var/generation_in_progress = FALSE

/obj/overmap/visitable/sector/rnd_mission_asteroid/Initialize()
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	if(isnull(SSrnd_generation))
		build_asteroid()
	else
		SSrnd_generation.queue_asteroid_generation(src)


/obj/overmap/visitable/sector/rnd_mission_asteroid/proc/build_asteroid()
	if(!LAZYLEN(map_z))
		return

	var/zlevel = map_z[1]
	var/padding = TRANSITIONEDGE
	var/asteroid_area = src.asteroid_area
	var/a_size = min(asteroid_size, world.maxx - padding * 2 - 4, world.maxy - padding * 2 - 4)
	var/cx = round(world.maxx / 2)
	var/cy = round(world.maxy / 2)
	var/half = round(a_size / 2)
	var/ax1 = cx - half
	var/ay1 = cy - half
	var/ax2 = cx + half
	var/ay2 = cy + half

	// Schedule chunked asteroid generation via timer to avoid blocking
	// Store params on src so the chunk proc can access them
	src._rnd_build_params = list(zlevel, padding, asteroid_area, a_size, cx, cy, half, ax1, ay1, ax2, ay2)
	addtimer(new Callback(src, PROC_REF(build_asteroid_chunk)), 1, TIMER_STOPPABLE)


/obj/overmap/visitable/sector/rnd_mission_asteroid/proc/build_asteroid_chunk()
	var/list/p = src._rnd_build_params
	if(!p)
		return

	var/zlevel = p[1]
	var/padding = p[2]
	var/asteroid_area = p[3]
	//var/a_size = p[4]
	var/cx = p[5]
	var/cy = p[6]
	var/half = p[7]
	var/ax1 = p[8]
	var/ay1 = p[9]
	var/ax2 = p[10]
	var/ay2 = p[11]

	// 1. Fill the z-level with space first (in chunks)
	var/step = 50
	for(var/x = 1, x <= world.maxx, x += step)
		for(var/y = 1, y <= world.maxy, y += step)
			for(var/turf/T in block(locate(x, y, zlevel), locate(min(x+step-1, world.maxx), min(y+step-1, world.maxy), zlevel)))
				T.ChangeTurf(/turf/space)
		sleep(-1)

	// 2. Create transition-edge border
	var/list/edges = list()
	edges += block(locate(1, 1, zlevel), locate(padding, world.maxy, zlevel))
	edges |= block(locate(world.maxx - padding, 1, zlevel), locate(world.maxx, world.maxy, zlevel))
	edges |= block(locate(1, 1, zlevel), locate(world.maxx, padding, zlevel))
	edges |= block(locate(1, world.maxy - padding, zlevel), locate(world.maxx, world.maxy, zlevel))

	// 3. Fill asteroid area with mask turfs for the cave generator to process (in chunks)
	for(var/x = ax1, x <= ax2, x += step)
		for(var/y = ay1, y <= ay2, y += step)
			for(var/turf/T in block(locate(x, y, zlevel), locate(min(x+step-1, ax2), min(y+step-1, ay2), zlevel)))
				if(T in edges)
					continue
					var/dx = (T.x - cx) / (half + 0.5)
					var/dy = (T.y - cy) / (half + 0.5)
					if(dx*dx + dy*dy <= 1.0)
						T.ChangeTurf(/turf/unsimulated/mask)
						ChangeArea(T, asteroid_area)
		sleep(-1)

	// 4. Generate caves and ore using the standard cave system (delayed)
	new /datum/random_map/automata/cave_system(null, ax1, ay1, zlevel, ax2, ay2)
	new /datum/random_map/noise/ore(null, ax1, ay1, zlevel, ax2, ay2)
	// 5. Generate shuttle landing zone (final step)
	generate_landing(1)
	// 6. Place a random ruin from the specified list (synchronously)
	var/list/ruin_templates = list(
		/datum/map_template/ruin/exoplanet/hut,
		/datum/map_template/ruin/exoplanet/monolith,
		/datum/map_template/ruin/exoplanet/crashed_probe,
		/datum/map_template/ruin/exoplanet/droppod,
		/datum/map_template/ruin/exoplanet/radshrine
	)
	var/datum/map_template/ruin/exoplanet/ruin = pick(ruin_templates)
	// Pick a turf in the asteroid area
	var/turf/ruin_turf = null
	for(var/i = 0, i < 20 && !ruin_turf, i++)
		var/turf/T = locate(rand(ax1+5, ax2-5), rand(ay1+5, ay2-5), zlevel)
		if(T && istype(get_area(T), /area/rnd_mission_asteroid) && !T.density)
			ruin_turf = T
	if(ruin && ruin_turf)
		load_ruin(ruin_turf, ruin)

	// cleanup stored params
	del(src._rnd_build_params)

/obj/overmap/visitable/sector/rnd_mission_asteroid/proc/generate_landing(num = 1)
	if(!LAZYLEN(map_z))
		return
	var/zlevel = map_z[1]
	var/attempts = 30 * num
	var/cx = round(world.maxx / 2)
	var/cy = round(world.maxy / 2)
	var/half = round(min(asteroid_size, world.maxx - TRANSITIONEDGE * 2 - 4, world.maxy - TRANSITIONEDGE * 2 - 4) / 2)
	var/list/placed = list()

	while(num > 0 && attempts > 0)
		attempts--
		var/tx = rand(cx - half + LANDING_ZONE_RADIUS + 2, cx + half - LANDING_ZONE_RADIUS - 2)
		var/ty = rand(cy - half + LANDING_ZONE_RADIUS + 2, cy + half - LANDING_ZONE_RADIUS - 2)
		var/turf/T = locate(tx, ty, zlevel)
		if(!T || T.density || (T in placed))
			continue
		if(!istype(get_area(T), /area/rnd_mission_asteroid))
			continue
		// Check surrounding area is clear
		var/valid = TRUE
		for(var/turf/check in range(3, T))
			if(check.density)
				valid = FALSE
				break
		if(!valid)
			continue
		placed += T
		num--
		new /obj/shuttle_landmark/automatic/clearing(T)

/// Clean up the asteroid z-level and remove from overmap
/obj/overmap/visitable/sector/rnd_mission_asteroid/proc/cleanup_and_destroy()
	if(QDELETED(src))
		return
	// Unregister z-levels from global tracking
	for(var/zlevel in map_z)
		map_sectors -= "[zlevel]"
		GLOB.using_map.player_levels -= zlevel
		GLOB.using_map.sealed_levels -= zlevel

	// Clear all turfs to space to free rendering resources
	if(LAZYLEN(map_z))
		var/zlevel = map_z[1]
		for(var/turf/T in block(locate(1, 1, zlevel), locate(world.maxx, world.maxy, zlevel)))
			for(var/atom/movable/AM in T)
				if(ismob(AM))
					// Teleport living mobs to safety
					var/mob/M = AM
					var/turf/safe = get_base_turf_by_area(T)
					if(safe)
						M.forceMove(safe)
					continue
				qdel(AM)
			T.ChangeTurf(/turf/space)

	// Remove from overmap
	log_and_message_admins("RnD mission asteroid '[name]' cleaned up and removed from overmap.")
	qdel(src)
