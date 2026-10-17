// [SIERRA-ADD]
// Adapted from Shiptest, AGPL-3.0, revision 85eddb244aa6d18be44fdb236bea4a0ba01914a0:
// code/controllers/subsystem/mapping.dm (get_free_allocation through create_virtual_level)
// code/modules/mapping/space_management/space_level.dm (is_box_free)
// Only free allocations are needed. Sierra test datums replace the virtual-Z runtime types.
#define UNIT_TEST_ALLOC_JUMP 5 // Shiptest's DEFAULT_ALLOC_JUMP.
/datum/unit_test_map_allocator
	var/list/z_list = list()

/datum/unit_test_map_allocator/Destroy()
	for(var/datum/unit_test_map_level/level as anything in z_list)
		qdel(level)
	z_list = null
	return ..()

/// Searches for a free allocation for the passed size, creates new physical levels if nessecary.
/datum/unit_test_map_allocator/proc/get_free_allocation(size_x, size_y, allocation_jump = UNIT_TEST_ALLOC_JUMP)
	var/list/allocation_list
	var/list/levels_to_check = z_list.Copy()
	var/created_new_level = FALSE
	while(TRUE)
		for(var/datum/unit_test_map_level/iterated_level as anything in levels_to_check)
			allocation_list = find_allocation_in_level(iterated_level, size_x, size_y, allocation_jump)
			if(allocation_list)
				return allocation_list

		if(created_new_level)
			crash_with("MAPPING: We have failed to find allocation after creating a new level just for it, something went terribly wrong")
			return FALSE
		/// None of the levels could faciliate a new allocation, make a new one
		created_new_level = TRUE
		levels_to_check.Cut()
		levels_to_check += add_new_zlevel()

/// Finds a box allocation inside a Z level. Uses a methodical box boundary check method
/datum/unit_test_map_allocator/proc/find_allocation_in_level(datum/unit_test_map_level/level, size_x, size_y, allocation_jump)
	var/target_x = 1
	var/target_y = 1

	/// Sanity
	if(size_x > world.maxx || size_y > world.maxy)
		crash_with("Tried to find virtual level allocation that cannot possibly fit in a physical level.")
		return FALSE

	/// Methodical trial and error method
	while(TRUE)
		var/upper_target_x = target_x+size_x
		var/upper_target_y = target_y+size_y

		var/out_of_bounds = FALSE
		if((target_x < 1 || upper_target_x > world.maxx) || (target_y < 1 || upper_target_y > world.maxy))
			out_of_bounds = TRUE

		if(!out_of_bounds && level.is_box_free(target_x, target_y, upper_target_x, upper_target_y))
			return list(target_x, target_y, level.z_value) //hallelujah we found the unallocated spot

		if(upper_target_x > world.maxx) //If we can't increment x, then the search is over
			break

		var/increments_y = TRUE
		if(upper_target_y > world.maxy)
			target_y = 1
			increments_y = FALSE
		if(increments_y)
			target_y += allocation_jump
		else
			target_x += allocation_jump

/// Allocates and returns the bounds needed by Sierra's template loader.
/datum/unit_test_map_allocator/proc/create_virtual_level(width, height, allocation_jump = UNIT_TEST_ALLOC_JUMP)
	// Sierra adaptation: reject invalid sizes before allocating a physical level.
	if(width < 1 || height < 1 || width > world.maxx || height > world.maxy || allocation_jump < 1)
		return
	/// Because we add an implicit 1 for the coordinate calcuations.
	width--
	height--
	var/list/allocation_coords = get_free_allocation(width, height, allocation_jump)
	if(!allocation_coords)
		return
	var/datum/unit_test_map_level/level = z_list[length(z_list)]
	for(var/datum/unit_test_map_level/candidate as anything in z_list)
		if(candidate.z_value == allocation_coords[3])
			level = candidate
			break
	return new /datum/unit_test_map_region(level, allocation_coords[1], allocation_coords[2], allocation_coords[1] + width, allocation_coords[2] + height)

/datum/unit_test_map_allocator/proc/add_new_zlevel()
	INCREMENT_WORLD_Z_SIZE
	GLOB.using_map.sealed_levels |= world.maxz
	var/datum/unit_test_map_level/level = new(world.maxz)
	z_list += level
	return level

/datum/unit_test_map_level
	var/z_value
	var/list/virtual_levels = list()

/datum/unit_test_map_level/New(new_z)
	z_value = new_z

/datum/unit_test_map_level/Destroy()
	for(var/datum/unit_test_map_region/region as anything in virtual_levels.Copy())
		qdel(region)
	virtual_levels = null
	return ..()

/datum/unit_test_map_level/proc/is_box_free(low_x, low_y, high_x, high_y)
	for(var/datum/unit_test_map_region/vlevel as anything in virtual_levels)
		if(low_x <= vlevel.high_x && vlevel.low_x <= high_x && low_y <= vlevel.high_y && vlevel.low_y <= high_y)
			return FALSE
	return TRUE

/datum/unit_test_map_region
	var/low_x
	var/low_y
	var/high_x
	var/high_y
	var/datum/unit_test_map_level/parent_level

/datum/unit_test_map_region/New(datum/unit_test_map_level/level, lx, ly, hx, hy)
	parent_level = level
	low_x = lx
	low_y = ly
	high_x = hx
	high_y = hy
	level.virtual_levels += src

/datum/unit_test_map_region/Destroy()
	parent_level.virtual_levels -= src
	parent_level = null
	return ..()
#undef UNIT_TEST_ALLOC_JUMP
// [/SIERRA-ADD]
