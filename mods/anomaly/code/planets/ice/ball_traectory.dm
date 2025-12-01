//9 ТОЧЕК на опр расстоянии от центра
/proc/create_circle_turfs(turf/center, radius = 6)
	var/list/turfs = list()
	var/list/dirs = list(
		EAST,
		NORTHEAST,
		NORTH,
		NORTHWEST,
		WEST,
		SOUTHWEST,
		SOUTH,
		SOUTHEAST
	)
	for(var/dir in dirs)
		LAZYADD(turfs, get_ranged_target_turf(center, dir, radius))

	return turfs
