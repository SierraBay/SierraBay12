// NOTE: Maps generated with this datum as the base are not DIRECTLY compatible with maps generated from
// the automata, building or maze datums, as the noise generator uses 0-255 instead of WALL_CHAR/FLOOR_CHAR.
// TODO: Consider writing a conversion proc for noise-to-regular maps.
/datum/random_map/noise
	descriptor = "distribution map"
	var/cell_range = 255            // These values are used to seed ore values rather than to determine a turf type.
	var/cell_smooth_amt = 5
	var/random_variance_chance = 25 // % chance of applying random_element.
	var/random_element = 0.5        // Determines the variance when smoothing out cell values.
	var/cell_base                   // Set in New()
	var/initial_cell_range          // Set in New()
	var/smoothing_iterations = 0
	var/smooth_single_tiles			// Single turfs of different value are not allowed

/datum/random_map/noise/New()
	initial_cell_range = cell_range/5
	cell_base = cell_range/2
	..()

/datum/random_map/noise/set_map_size()
	// [SIERRA-ADD] - Padding is needed for calculation, not turf placement.
	apply_width = limit_x
	apply_height = limit_y
	// [/SIERRA-ADD]
	// Make sure the grid is a square with limits that are
	// (n^2)+1, otherwise diamond-square won't work.
	if(!IsPowerOfTwo((limit_x-1)))
		limit_x = Ceilp(limit_x, 2) + 1
	if(!IsPowerOfTwo((limit_y-1)))
		limit_y = Ceilp(limit_y, 2) + 1
	// Sides must be identical lengths.
	if(limit_x > limit_y)
		limit_y = limit_x
	else if(limit_y > limit_x)
		limit_x = limit_y
	..()

// Diamond-square algorithm.
/datum/random_map/noise/seed_map()
	// Instantiate the grid.
	for(var/x = 1, x <= limit_x, x++)
		for(var/y = 1, y <= limit_y, y++)
			map[TRANSLATE_COORD(x,y)] = 0

	// Now dump in the actual random data.
	map[TRANSLATE_COORD(1,1)]             = cell_base+rand(initial_cell_range)
	map[TRANSLATE_COORD(1,limit_y)]       = cell_base+rand(initial_cell_range)
	map[TRANSLATE_COORD(limit_x,limit_y)] = cell_base+rand(initial_cell_range)
	map[TRANSLATE_COORD(limit_x,1)]       = cell_base+rand(initial_cell_range)

/datum/random_map/noise/generate_map()
	// Begin recursion.
	subdivide(1,1,1,(limit_y-1))

/datum/random_map/noise/get_map_char(value)
	var/val = min(9,max(0,round((value/cell_range)*10)))
	if(isnull(val)) val = 0
	return "[val]"

/datum/random_map/noise/proc/noise2value(value)
	return min(9,max(0,round((value/cell_range)*10)))

/datum/random_map/noise/proc/subdivide(iteration,x,y,input_size)

	var/isize = input_size
	var/hsize = round(input_size/2)

	/*
	(x,y+isize)----(x+hsize,y+isize)----(x+size,y+isize)
	  |                 |                  |
	  |                 |                  |
	  |                 |                  |
	(x,y+hsize)----(x+hsize,y+hsize)----(x+isize,y)
	  |                 |                  |
	  |                 |                  |
	  |                 |                  |
	(x,y)----------(x+hsize,y)----------(x+isize,y)
	*/
	// Central edge values become average of corners.
	map[TRANSLATE_COORD(x+hsize,y+isize)] = round((\
		map[TRANSLATE_COORD(x,y+isize)] +          \
		map[TRANSLATE_COORD(x+isize,y+isize)] \
		)/2)

	map[TRANSLATE_COORD(x+hsize,y)] = round((  \
		map[TRANSLATE_COORD(x,y)] +            \
		map[TRANSLATE_COORD(x+isize,y)]   \
		)/2)

	map[get_map_cell(x,y+hsize)] = round((  \
		map[TRANSLATE_COORD(x,y+isize)] + \
		map[TRANSLATE_COORD(x,y)]              \
		)/2)

	map[TRANSLATE_COORD(x+isize,y+hsize)] = round((  \
		map[TRANSLATE_COORD(x+isize,y+isize)] + \
		map[TRANSLATE_COORD(x+isize,y)]        \
		)/2)

	// Centre value becomes the average of all other values + possible random variance.
	var/current_cell = TRANSLATE_COORD(x+hsize,y+hsize)
	map[current_cell] = round(( \
		map[TRANSLATE_COORD(x+hsize,y+isize)] + \
		map[TRANSLATE_COORD(x+hsize,y)] + \
		map[TRANSLATE_COORD(x,y+hsize)] + \
		map[TRANSLATE_COORD(x+isize,y)] \
		)/4)

	if(prob(random_variance_chance))
		map[current_cell] *= (rand(1,2)==1 ? (1.0-random_element) : (1.0+random_element))
		map[current_cell] = max(0,min(cell_range,map[current_cell]))

 	// Recurse until size is too small to subdivide.
	if(isize>3)
		if(!priority_process)
			CHECK_TICK
		iteration++
		subdivide(iteration, x,       y,       hsize)
		subdivide(iteration, x+hsize, y,       hsize)
		subdivide(iteration, x,       y+hsize, hsize)
		subdivide(iteration, x+hsize, y+hsize, hsize)

/datum/random_map/noise/cleanup()
	var/is_not_border_left
	var/is_not_border_right
	for(var/i = 1 to smoothing_iterations)
		var/list/next_map[limit_x*limit_y]
		for(var/x = 1 to limit_x)
			for(var/y = 1 to limit_y)
				var/current_cell = TRANSLATE_COORD(x,y)
				var/val_count = 1
				var/total = map[current_cell]

				is_not_border_left = (x != 1)
				is_not_border_right = (x != limit_x)

				// Center row. Center value's already been done above.
				if (is_not_border_left)
					total += map[TRANSLATE_COORD(x - 1, y)]
					++val_count
				if (is_not_border_right)
					total += map[TRANSLATE_COORD(x + 1, y)]
					++val_count

				if (y != 1) // top row
					total += map[TRANSLATE_COORD(x, y - 1)]
					++val_count
					if (is_not_border_left)
						total += map[TRANSLATE_COORD(x - 1, y - 1)]
						++val_count
					if (is_not_border_right)
						total += map[TRANSLATE_COORD(x + 1, y - 1)]
						++val_count

				if (y != limit_y) // bottom row
					total += map[TRANSLATE_COORD(x, y + 1)]
					++val_count
					if (is_not_border_left)
						total += map[TRANSLATE_COORD(x - 1, y + 1)]
						++val_count
					if (is_not_border_right)
						total += map[TRANSLATE_COORD(x + 1, y + 1)]
						++val_count

				total = round(total/val_count)

				// [SIERRA-EDIT] - Read the previous pass and retain the smoothed result.
				next_map[current_cell] = clamp(total, map[current_cell] - cell_smooth_amt, map[current_cell] + cell_smooth_amt)
				next_map[current_cell] = clamp(next_map[current_cell], 0, cell_range)
				// [/SIERRA-EDIT]
		map = next_map

	if(smooth_single_tiles)
		// [SIERRA-EDIT] - Only the existence of an equal neighbor matters.
		for(var/x in 1 to limit_x - 1)
			for(var/y in 1 to limit_y - 1)
				var/mapcell = get_map_cell(x,y)
				var/list/neighbors = get_neighbors(x, y)
				var/has_matching_neighbor = FALSE
				var/current_value = noise2value(map[mapcell])
				for(var/cell in neighbors)
					if(noise2value(map[cell]) == current_value)
						has_matching_neighbor = TRUE
						break
				if(!has_matching_neighbor && length(neighbors))
					map[mapcell] = map[pick(neighbors)]
		// [/SIERRA-EDIT]

/datum/random_map/noise/proc/get_neighbors(x, y, include_diagonals)
	. = list()
	if(!include_diagonals)
		var/static/list/ortho_offsets = list(list(-1, 0), list(1, 0), list(0, 1), list(0,-1))
		for(var/list/offset in ortho_offsets)
			// [SIERRA-ADD] - Flat indices alone allow wrapping into another row.
			if(x + offset[1] < 1 || x + offset[1] > limit_x || y + offset[2] < 1 || y + offset[2] > limit_y)
				continue
			// [/SIERRA-ADD]
			var/tmp_cell = get_map_cell(x+offset[1],y+offset[2])
			if(tmp_cell)
				. += tmp_cell
	else
		for(var/dx in -1 to 1)
			for(var/dy in -1 to 1)
				// [SIERRA-ADD]
				if(x + dx < 1 || x + dx > limit_x || y + dy < 1 || y + dy > limit_y)
					continue
				// [/SIERRA-ADD]
				var/tmp_cell = get_map_cell(x+dx,y+dy)
				if(tmp_cell)
					. += tmp_cell
		. -= get_map_cell(x,y)
