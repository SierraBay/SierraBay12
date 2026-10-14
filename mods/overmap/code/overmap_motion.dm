/// One completed movement interval, in map cells and world deciseconds.
/datum/overmap_motion
	var/list/start_point
	var/list/end_point
	var/start_time
	var/end_time

/datum/overmap_motion/Destroy()
	start_point = null
	end_point = null
	return ..()

/datum/overmap_motion/proc/begin(obj/overmap/object, timestamp)
	start_point = object.get_map_position()
	end_point = start_point.Copy()
	start_time = timestamp
	end_time = timestamp

/datum/overmap_motion/proc/finish(obj/overmap/object, timestamp)
	end_point = object.get_map_position()
	end_time = timestamp
	if (object.wraparound && !object.delete_on_edge && start_point[3] == end_point[3] && object.z == GLOB.using_map.overmap_z)
		var/period = GLOB.using_map.overmap_size - 2
		for (var/axis in 1 to 2)
			var/delta = end_point[axis] - start_point[axis]
			if (delta > period / 2)
				end_point[axis] -= period
			else if (delta < -period / 2)
				end_point[axis] += period

/datum/overmap_motion/proc/point_at(timestamp)
	var/fraction = end_time > start_time ? clamp((timestamp - start_time) / (end_time - start_time), 0, 1) : 1
	return list(Interpolate(start_point[1], end_point[1], fraction), Interpolate(start_point[2], end_point[2], fraction), end_point[3])

/// Only simultaneous portions of two paths can collide.
/datum/overmap_motion/proc/contact_time(datum/overmap_motion/other, radius, period, not_before = 0)
	if (start_point[3] != end_point[3] || other.start_point[3] != end_point[3] || other.end_point[3] != end_point[3])
		return null
	var/from_time = max(start_time, other.start_time, not_before)
	var/to_time = min(end_time, other.end_time)
	if (from_time > to_time)
		return null
	var/list/own_start = point_at(from_time)
	var/list/own_end = point_at(to_time)
	var/list/other_start = other.point_at(from_time)
	var/list/other_end = other.point_at(to_time)
	var/list/relative_start = list(own_start[1] - other_start[1], own_start[2] - other_start[2])
	var/list/relative_end = list(own_end[1] - other_end[1], own_end[2] - other_end[2])
	var/fraction = contact_fraction(relative_start, relative_end, radius, period)
	return isnull(fraction) ? null : Interpolate(from_time, to_time, fraction)

/datum/overmap_motion/proc/static_contact_time(list/point, radius, period, not_before)
	var/datum/overmap_motion/stationary = new
	stationary.start_point = point
	stationary.end_point = point
	stationary.start_time = start_time
	stationary.end_time = end_time
	. = contact_time(stationary, radius, period, not_before)
	qdel(stationary)

/// Reject stale history after a teleport or a local/overmap transition.
/datum/overmap_motion/proc/matches_position(obj/overmap/object, period)
	var/list/current = object.get_map_position()
	if (current[3] != end_point[3])
		return FALSE
	for (var/axis in 1 to 2)
		var/delta = abs(current[axis] - end_point[axis])
		if (delta > 0.0001 && (!period || abs(delta - period) > 0.0001))
			return FALSE
	return TRUE

/datum/overmap_motion/proc/contact_fraction(list/from_point, list/to_point, radius, period)
	var/list/images = period ? list(0, -period, period) : list(0)
	var/best
	for (var/image_x in images)
		for (var/image_y in images)
			var/fraction = segment_contact(from_point[1] + image_x, from_point[2] + image_y, to_point[1] - from_point[1], to_point[2] - from_point[2], radius)
			if (!isnull(fraction) && (isnull(best) || fraction < best))
				best = fraction
	return best

/// First entry of a relative line segment into a circle; tangency counts as contact.
/datum/overmap_motion/proc/segment_contact(delta_x, delta_y, travel_x, travel_y, radius)
	var/c = delta_x ** 2 + delta_y ** 2 - radius ** 2
	if (c <= 0)
		return 0
	var/a = travel_x ** 2 + travel_y ** 2
	if (!a)
		return null
	var/b = 2 * (delta_x * travel_x + delta_y * travel_y)
	var/discriminant = b ** 2 - 4 * a * c
	if (discriminant < 0)
		return null
	var/fraction = (-b - sqrt(discriminant)) / (2 * a)
	return fraction >= 0 && fraction <= 1 ? fraction : null
