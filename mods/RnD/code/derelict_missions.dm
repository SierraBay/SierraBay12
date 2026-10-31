/// Away-site load tracking (used by ghost invasion). Corporate derelict contracts removed.

var/global/list/loaded_away_site_ids = list()

/datum/map_template/ruin/away_site
	var/loaded_z = 0

/datum/map_template/ruin/away_site/load_new_z(no_changeturf = TRUE)
	var/capture_z = world.maxz + 1
	. = ..()
	if (. && id)
		loaded_z = capture_z


/// Place an object on a random open floor of an away Z (optional area filter). Not mission-related.
/proc/spawn_on_away_site(type_path, z_level, area_type = null)
	if (!type_path || z_level < 1)
		return null
	var/list/valid_turfs = list()
	for (var/turf/simulated/floor/T in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		if (T.density || (locate(/obj/structure) in T))
			continue
		if (area_type)
			var/area/A = get_area(T)
			if (!istype(A, area_type))
				continue
		valid_turfs += T
	if (!length(valid_turfs))
		return null
	return new type_path(pick(valid_turfs))
