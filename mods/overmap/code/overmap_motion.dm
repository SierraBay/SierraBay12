#define OVERMAP_MOTION_POSITION_TOLERANCE 0.0001

/// One completed movement interval, in map cells and world deciseconds.
/datum/overmap_motion
	var/list/start_point
	var/list/end_point
	var/start_time
	var/end_time
	/// Knots retain curved missile flight until both objects have completed the interval.
	var/list/points = list()
	var/list/times = list()
	var/recording = FALSE

/datum/overmap_motion/Destroy()
	start_point = null
	end_point = null
	points = null
	times = null
	return ..()

/datum/overmap_motion/proc/begin(obj/overmap/object, timestamp)
	if (recording)
		return

	start_point = object.get_unwrapped_map_position()
	end_point = start_point.Copy()
	start_time = timestamp
	end_time = timestamp
	points = list(start_point)
	times = list(timestamp)

/datum/overmap_motion/proc/finish(obj/overmap/object, timestamp)
	end_point = object.get_unwrapped_map_position()
	end_time = timestamp
	points += list(end_point)
	times += timestamp

/datum/overmap_motion/proc/point_at(timestamp)
	if (!length(times))
		return interpolate_point(start_point, end_point, start_time, end_time, timestamp)

	var/index = time_index(timestamp)
	if (index <= 1)
		return start_point.Copy()

	if (index > length(times))
		return end_point.Copy()

	return interpolate_point(points[index - 1], points[index], times[index - 1], times[index], timestamp)

/// Binary search keeps long delayed intervals from repeatedly scanning every earlier knot.
/datum/overmap_motion/proc/time_index(timestamp, strictly_after = FALSE)
	var/low = 1
	var/high = length(times) + 1
	while (low < high)
		var/middle = floor((low + high) / 2)
		if (times[middle] < timestamp || (strictly_after && times[middle] == timestamp))
			low = middle + 1
		else
			high = middle
	return low

/datum/overmap_motion/proc/interpolate_point(list/from_point, list/to_point, from_time, to_time, timestamp)
	var/fraction = to_time > from_time ? clamp((timestamp - from_time) / (to_time - from_time), 0, 1) : 1
	return list(Interpolate(from_point[1], to_point[1], fraction), Interpolate(from_point[2], to_point[2], fraction), to_point[3])

/datum/overmap_motion/proc/next_time(timestamp, limit)
	var/index = time_index(timestamp, TRUE)
	return index <= length(times) ? min(times[index], limit) : limit

/// Only simultaneous portions of two paths can collide.
/datum/overmap_motion/proc/contact_time(datum/overmap_motion/other, radius, period, not_before = 0)
	if (start_point[3] != end_point[3] || other.start_point[3] != end_point[3] || other.end_point[3] != end_point[3])
		return null

	var/from_time = max(start_time, other.start_time, not_before)
	var/to_time = min(end_time, other.end_time)
	if (from_time > to_time)
		return null

	while (TRUE)
		var/segment_end = other.next_time(from_time, next_time(from_time, to_time))
		var/fraction = contact_during(other, radius, period, from_time, segment_end)
		if (!isnull(fraction))
			return Interpolate(from_time, segment_end, fraction)

		if (segment_end >= to_time)
			return null

		from_time = segment_end

/datum/overmap_motion/proc/contact_during(datum/overmap_motion/other, radius, period, from_time, to_time)
	var/list/own_start = point_at(from_time)
	var/list/own_end = point_at(to_time)
	var/list/other_start = other.point_at(from_time)
	var/list/other_end = other.point_at(to_time)
	var/list/relative_start = list(own_start[1] - other_start[1], own_start[2] - other_start[2])
	var/list/relative_end = list(own_end[1] - other_end[1], own_end[2] - other_end[2])
	return contact_fraction(relative_start, relative_end, radius, period)

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
	var/list/current = object.get_unwrapped_map_position()
	if (current[3] != end_point[3])
		return FALSE

	for (var/axis in 1 to 2)
		var/delta = abs(current[axis] - end_point[axis])
		if (delta > OVERMAP_MOTION_POSITION_TOLERANCE)
			return FALSE

	return TRUE

/datum/overmap_motion/proc/contact_fraction(list/from_point, list/to_point, radius, period)
	if (abs(to_point[2] - from_point[2]) > abs(to_point[1] - from_point[1]))
		return contact_fraction(list(from_point[2], from_point[1]), list(to_point[2], to_point[1]), radius, period)

	var/list/x_images = get_segment_images(from_point[1], to_point[1], radius, period)
	var/best
	for (var/image_x in x_images)
		var/fraction = contact_at_image(from_point, to_point, image_x, radius, period)
		if (!isnull(fraction) && (isnull(best) || fraction < best))
			best = fraction
	return best

/// Restrict Y images to the time spent in this X strip: linear cost for multi-wrap diagonals.
/datum/overmap_motion/proc/contact_at_image(list/from_point, list/to_point, image_x, radius, period)
	var/travel_x = to_point[1] - from_point[1]
	var/travel_y = to_point[2] - from_point[2]
	var/entry_fraction = travel_x ? clamp((image_x - radius - from_point[1]) / travel_x, 0, 1) : 0
	var/exit_fraction = travel_x ? clamp((image_x + radius - from_point[1]) / travel_x, 0, 1) : 1
	var/list/y_images = get_segment_images(
		from_point[2] + travel_y * entry_fraction,
		from_point[2] + travel_y * exit_fraction,
		radius,
		period,
	)
	var/best
	for (var/image_y in y_images)
		var/fraction = segment_contact(from_point[1] - image_x, from_point[2] - image_y, travel_x, travel_y, radius)
		if (!isnull(fraction) && (isnull(best) || fraction < best))
			best = fraction
	return best

/// Enumerate only periodic circles whose bounding box overlaps the actual segment.
/datum/overmap_motion/proc/get_segment_images(from_coordinate, to_coordinate, radius, period)
	if (!period)
		return list(0)

	var/list/images = list()
	var/first = ceil((min(from_coordinate, to_coordinate) - radius) / period)
	var/last = floor((max(from_coordinate, to_coordinate) + radius) / period)
	if (first > last)
		return images

	for (var/index in first to last)
		images += index * period
	return images

/// First entry of a relative line segment into a circle; tangency counts as contact.
/datum/overmap_motion/proc/segment_contact(delta_x, delta_y, travel_x, travel_y, radius)
	var/c = delta_x ** 2 + delta_y ** 2 - radius ** 2
	if (c <= 0)
		return 0

	var/a = travel_x ** 2 + travel_y ** 2
	if (!a)
		return null

	var/projection = -(delta_x * travel_x + delta_y * travel_y) / a
	var/perpendicular_squared = (delta_x * travel_y - delta_y * travel_x) ** 2 / a
	if (perpendicular_squared > radius ** 2)
		return null

	var/fraction = projection - sqrt((radius ** 2 - perpendicular_squared) / a)
	return fraction >= 0 && fraction <= 1 ? fraction : null

#undef OVERMAP_MOTION_POSITION_TOLERANCE
