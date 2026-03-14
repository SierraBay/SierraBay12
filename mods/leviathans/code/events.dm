/datum/event_meta/leviathan_spawn
	name = "Space Leviathan Spawn"
	event_type = /datum/event/leviathan_spawn
	severity = EVENT_LEVEL_MAJOR
	weight = 5

/datum/event/leviathan_spawn
	var/list/leviathan_types = list(
		/obj/overmap/event/leviathan/medusa,
		/obj/overmap/event/leviathan/dragon,
		/obj/overmap/event/leviathan/swarm
	)
	var/spawn_radius = 5 // Минимум в 5 квадратах от Сьерры
	announceWhen = 150

/datum/event/leviathan_spawn/setup()
	return


/datum/event/leviathan_spawn/announce()
	command_announcement.Announce("Бортовые сенсоры зафиксировали неопознанную сигнатуру в этом секторе. Командному персоналу рекомендуется идентифицировать сигнатуру и определить враждебность объекта, отозвать все исследовательские миссии во избежание потери корпоративной собственности и минимизировать убытки.", "Показания датчиков [station_name()]" , msg_sanitized = 1, zlevels = GLOB.using_map.station_levels)

/datum/event/leviathan_spawn/start()
	if(!length(leviathan_types))
		return
	var/lev_type = pick(leviathan_types)

	var/z_level = GLOB.using_map.overmap_z
	var/overmap_size = GLOB.using_map.overmap_size

	var/obj/overmap/visitable/ship/sierra = null
	var/best_mass = 0
	for(var/obj/overmap/visitable/ship/S in SSshuttle.ships)
		if(S.vessel_mass > best_mass)
			best_mass = S.vessel_mass
			sierra = S

	if(!sierra) return

	// Cпавн на минимальном расстоянии от Сьерры
	var/list/valid_turfs = list()
	for(var/turf/T in block(locate(2, 2, z_level), locate(overmap_size - 2, overmap_size - 2, z_level)))
		if(get_dist(T, sierra.loc) >= spawn_radius)
			valid_turfs += T

	if(!length(valid_turfs))
		return

	var/turf/spawn_turf = pick(valid_turfs)
	new lev_type(spawn_turf)
