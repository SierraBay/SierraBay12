#define SANITIZE_SPEED(speed) SIGN(speed) * clamp(abs(speed), 0, max_speed)
/obj/overmap
	name = "map object"
	icon = 'icons/obj/overmap.dmi'
	icon_state = "object"
	color = "#fffffe"

	var/scannable					// If set to TRUE will show up on ship sensors for detailed scans, and will ping when detected by scanners.

	var/unknown_id					// A unique identifier used when this entity is scanned. Assigned in Initialize().

	var/requires_contact = FALSE	// Whether or not the effect must be identified by ship sensors before being seen.
	var/instant_contact  = FALSE	// Do we instantly identify ourselves to any ship in sensors range?
	var/sensor_visibility = 20		// How much it increases identification process each scan.

	var/list/known_ships = list()	//List of ships known at roundstart - put types here.

	/// The list of scans that can be performed on this overmap effect. See /datum/sector_scan for more info.
	var/list/scans = list()
	///Used for generating unique keys for the associated list 'scans'
	var/next_id = 0

	// Basic movement is supported, but things like acceleration are handled in subtypes (ships)
	/// If true, this object will be scheduled for movement processing
	var/movable = FALSE
	/// Current speed of the object, as turfs/ticks
	var/list/speed = list(0, 0)
	/// Sub-tile position of the object, as a fraction of distance from center
	/// For example, 0.33 = 1/3 tile
	var/list/position = list(0, 0)
	/// Halts movement processing entirely (admin freezes and similar)
	var/halted = FALSE
	/// If true, the object is deleted on hitting the map edge. This takes precedence over wraparound
	var/delete_on_edge = FALSE
	/// Should the object wrap to the other side of the map when it hits the map edge?
	var/wraparound = TRUE
	/// The "speed of light" for this object. Any faster than 1 turf/SSobj tick will get janky.
	var/max_speed = 1 / (1 SECOND)
	/// Objects traveling slower than this are considered at rest
	var/min_speed = 1 / (5 MINUTES)

	/// Whether to randomize sub-tile start position
	var/randomize_start_pos = TRUE

	var/image/heading_overlay = null

//Overlay of how this object should look on other skyboxes
/obj/overmap/proc/get_skybox_representation()
	return

/obj/overmap/proc/get_scan_data(mob/user)
	var/temp_data = list()
	for(var/id in scans)
		var/datum/sector_scan/scan = scans[id]
		if (!scan.required_skill || user.skill_check(scan.required_skill, scan.required_skill_level))
			temp_data += scan.description
		else if (scan.low_skill_description)
			temp_data += scan.low_skill_description

	return temp_data

/obj/overmap/Initialize()
	. = ..()
	min_speed = round(min_speed, GLOB.overmap_move_resolution)
	max_speed = round(max_speed, GLOB.overmap_move_resolution)
	add_scan_data("base_scan", desc)

	if(!GLOB.using_map.use_overmap)
		return INITIALIZE_HINT_QDEL

	if(scannable)
		unknown_id = "[pick(GLOB.phonetic_alphabet)]-[random_id(/obj/overmap, 100, 999)]"

	if(requires_contact)
		invisibility = INVISIBILITY_OVERMAP // Effects that require identification have their images cast to the client via sensors.

	if(movable)
		START_PROCESSING(SSobj, src)
		heading_overlay = overlay_image(icon = icon, icon_state = "heading_indicator", flags = RESET_COLOR)
		heading_overlay.filters = filter(type="drop_shadow", color = color + "F0", size = 2, offset = 1,x = 0, y = 0)

	if (randomize_start_pos)
		position[1] = round((rand() - 0.5) / 2.5, GLOB.overmap_move_resolution)
		position[2] = round((rand() - 0.5) / 2.5, GLOB.overmap_move_resolution)
	update_icon()

/obj/overmap/Destroy()
	if(movable)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/overmap/Process()
	process_movement()

/obj/overmap/proc/make_movable()
	if (movable)
		return FALSE

	movable = TRUE
	if (isnull(heading_overlay))
		heading_overlay = overlay_image(icon = icon, icon_state = "heading_indicator", flags = RESET_COLOR)
		heading_overlay.filters = filter(type="drop_shadow", color = color + "F0", size = 2, offset = 1,x = 0, y = 0)

	START_PROCESSING(SSobj, src)

/obj/overmap/proc/make_stationary()
	if (!movable)
		return FALSE

	speed[1] = 0
	speed[2] = 0
	movable = FALSE
	STOP_PROCESSING(SSobj, src)

/obj/overmap/proc/adjust_speed(n_x, n_y)
	n_x = SANITIZE_SPEED(n_x)
	n_y = SANITIZE_SPEED(n_y)

	if(abs(speed[1] + n_x) < min_speed)
		speed[1] = 0
	else
		speed[1] = SANITIZE_SPEED((speed[1] + n_x)/(1 + speed[1]*n_x/(max_speed ** 2)))

	if(abs(speed[2] + n_y) < min_speed)
		speed[2] = 0
	else
		speed[2] = SANITIZE_SPEED((speed[2] + n_y)/(1 + speed[2]*n_y/(max_speed ** 2)))

	update_icon()

/obj/overmap/proc/get_speed()
	return round(sqrt(speed[1] ** 2 + speed[2] ** 2), GLOB.overmap_move_resolution)

/obj/overmap/proc/is_moving()
	return ((abs(speed[1]) >= min_speed) || (abs(speed[2]) >= min_speed))

/obj/overmap/proc/get_heading()
	var/res = 0
	if(abs(speed[1]) >= min_speed)
		if(speed[1] > 0)
			res |= EAST
		else
			res |= WEST
	if(abs(speed[2]) >= min_speed)
		if(speed[2] > 0)
			res |= NORTH
		else
			res |= SOUTH
	return res

/obj/overmap/proc/get_heading_angle()
	var/res = 0
	if (is_moving())
		res = (round(Atan2(speed[1], -speed[2])) + 450)%360
	return res

// [SIERRA-EDIT] - Integrate in half-cell units and visit every crossed turf.
#define OVERMAP_MOVEMENT_BOUNDARY_EPSILON 0.000001

/obj/overmap/proc/process_movement(elapsed = world.time - SSobj.last_fire, timestamp = world.time)
	if (halted || !is_moving() || elapsed <= 0)
		return 0

	dir = get_heading()
	while (elapsed > 0 && is_moving())
		var/step_time = get_movement_step(elapsed)
		elapsed = max(0, elapsed - step_time)
		if (!advance_map_position(step_time) || QDELETED(src))
			return elapsed

	if (is_moving())
		dir = get_heading()
	update_icon()
	return 0

/// Stop precisely at the next cell boundary, including simultaneous corner crossings.
/obj/overmap/proc/get_movement_step(elapsed)
	for (var/axis in 1 to 2)
		if (abs(speed[axis]) >= min_speed && speed[axis])
			elapsed = min(elapsed, max(0, (SIGN(speed[axis]) - position[axis]) / speed[axis]))
	return elapsed

/obj/overmap/proc/advance_map_position(elapsed)
	var/list/delta = list(0, 0)
	for (var/axis in 1 to 2)
		if (abs(speed[axis]) < min_speed || !speed[axis])
			continue

		position[axis] += speed[axis] * elapsed
		if (position[axis] * SIGN(speed[axis]) >= 1 - OVERMAP_MOVEMENT_BOUNDARY_EPSILON)
			delta[axis] = SIGN(speed[axis])
			position[axis] -= 2 * delta[axis]
	if (!delta[1] && !delta[2])
		return TRUE

	return move_map_cell(delta)

/obj/overmap/proc/move_map_cell(list/delta)
	var/turf/destination = locate(x + delta[1], y + delta[2], z)
	// Edge turfs are dense markers. Core movement already bypassed their Enter check when wrapping.
	if (istype(destination, /turf/unsimulated/map/edge))
		return move_map_edge(destination, delta)

	if (destination && Move(destination))
		return TRUE

	return stop_map_movement(delta)

/obj/overmap/proc/move_map_edge(turf/destination, list/delta)
	if (delete_on_edge)
		qdel(src)
		return FALSE

	if (wraparound)
		forceMove(destination)
		// Move() may have set dir to the last single-axis crossing of a diagonal path.
		dir = get_heading()
		handle_wraparound(x, y)
		return TRUE

	return stop_map_movement(delta)

/obj/overmap/proc/stop_map_movement(list/delta)
	for (var/axis in 1 to 2)
		position[axis] += 2 * delta[axis]
	speed = list(0, 0)
	update_icon()
	return FALSE
#undef OVERMAP_MOVEMENT_BOUNDARY_EPSILON
// [/SIERRA-EDIT]

/obj/overmap/proc/handle_wraparound(nx, ny)
	var/low_edge = 2
	var/high_edge = GLOB.using_map.overmap_size - 1

	if((dir & WEST) && (nx == 1))
		nx = high_edge
	else if((dir & EAST) && (nx == GLOB.using_map.overmap_size))
		nx = low_edge

	if((dir & SOUTH) && (ny == 1))
		ny = high_edge
	else if((dir & NORTH) && (ny == GLOB.using_map.overmap_size))
		ny = low_edge

	var/turf/T = locate(nx,ny,z)
	if(T)
		forceMove(T)

/obj/overmap/visitable/ship/proc/halt()
	halted = TRUE

/obj/overmap/visitable/ship/proc/unhalt()
	halted = FALSE

/obj/overmap/Crossed(obj/overmap/visitable/other)
	if(istype(other))
		for(var/obj/overmap/visitable/O in loc)
			SSskybox.rebuild_skyboxes(O.map_z)

/obj/overmap/Uncrossed(obj/overmap/visitable/other)
	if(istype(other))
		SSskybox.rebuild_skyboxes(other.map_z)
		for(var/obj/overmap/visitable/O in loc)
			SSskybox.rebuild_skyboxes(O.map_z)

/obj/overmap/on_update_icon()
	pixel_x = position[1] * (world.icon_size/2)
	pixel_y = position[2] * (world.icon_size/2)
	filters = filter(type="drop_shadow", color = color + "F0", size = 2, offset = 1,x = 0, y = 0)

	ClearOverlays()
	if (is_moving())
		AddOverlays(heading_overlay)

/**
 * Runs any relevant code needed for updating anything connected to known overmap effects, such as helms.
 */
/obj/overmap/proc/update_known_connections(notify = FALSE)
	return

/obj/overmap/proc/add_scan_data(id, description, low_skill_description, required_skill, required_skill_level)

	var/datum/sector_scan/new_scan = new()
	//If id isn't specified, generate unique-ish one
	if(!id)
		id = "scan_data_[next_id++]"

	if (scans[id])
		log_debug("Tried to add a scan with an id that already exists: [id]")
		return FALSE

	new_scan.id = id
	new_scan.description = description
	new_scan.low_skill_description = low_skill_description
	new_scan.required_skill = required_skill
	new_scan.required_skill_level = required_skill_level

	scans[id] = new_scan

	return TRUE

/obj/overmap/proc/remove_scan_data(id)
	if(!scans[id])
		return FALSE

	var/datum/scan = scans[id]
	scans -= id
	qdel(scan)

	return TRUE

/datum/sector_scan
	/// The id of the scan. Used for referencing the scan in the linked overmap effect's 'scans' list.
	var/id = "Sector Scan"
	/// The description of the scan. This is what will be shown to the player when they scan the sector.
	var/description = "A scan of the sector."
	/// The description of the scan if the player doesn't have the required skill to see the normal description.
	var/low_skill_description = "A scan of the sector. You can't make out much."
	/// The skill required to see the normal description.
	var/required_skill = SKILL_SCIENCE
	/// The level of the skill required to see the normal description.
	var/required_skill_level = SKILL_TRAINED

#undef SANITIZE_SPEED
