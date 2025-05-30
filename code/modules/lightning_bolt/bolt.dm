/**
 * A lightning bolt drawn between two vectors
 */
/datum/bolt
	var/list/segments
	var/fade
	var/obj/lastCreatedBolt

	/**
	 * Constructs the bolt, from vector source to vector dest
	 *
	 * - @param source source vector, where the bolt starts
	 * - @param dest   destination vector, where the bolt ends
	 * - @param fade   assigns fade out rate, default of 50
	 */
/datum/bolt/New(simple_vector/source, simple_vector/dest, fade = 50)
	..()

	segments    = createBolt(source, dest)
	src.fade    = fade

		/**
		 * Draws a bolt of type with a color between two assigned vectors on z or client screen
		 *
		 * - @param z         the map z level to draw on, if z is client it will draw on client screen
		 * - @param type      basic segment to use when drawing
		 * - @param color     color of the bolt
		 * - @param thickness thickness of the bolt
		 * - @param split     if set to 1 will create an obj for each segment, if not it will only create one object with segments as overlays
		 */
/datum/bolt/proc/Draw(z, type = /obj/lineSegment, color = "#fff", thickness = 1, split = 0)

	if(split)
		for(var/datum/line/segment in segments)
			var/obj/o = segment.Draw(z, type, color, thickness)
			Effect(o)
	else
		var/datum/line/l = segments[1]
		var/obj/o = new (l.A.Locate(z))

		lastCreatedBolt = o

		var/mutable_appearance/ma = new(o)

		ma.alpha = 255
		ma.color = color

		var/obj/s = new type ()

		for(var/datum/line/segment in segments)
			ma.AddOverlays(segment.DrawOverlay(o, s, thickness))

		o.appearance = ma

		Effect(o)

/**
 * Applys animation to lightning bolt segment
 * this could be overriden by child types to allow different animations to the lightning bolt
 * by default, a lightning bolt will fade out then be disposed
 *
 * @param o  the object segment, each lightning bolt is made of several segments
 */
/datum/bolt/proc/Effect(obj/o)
	set waitfor = 0
	animate(o, alpha = 0, time = 255 / fade, loop = 1)

	sleep(255 / fade)
	Dispose(o)

/**
 * Rotates last created bolt to a different angle
 *
 * @param angle the new angle of the bolt
 */
/datum/bolt/proc/Rotate(angle)

	var/datum/line/firstLine = segments[1]
	var/datum/line/lastLine  = segments[length(segments)]

	var/simple_vector/tangent  = vectorSubtract(lastLine.B, firstLine.A)
	var/rotation        = Atan2(tangent.Y, tangent.X) - 90

	angle -= rotation

	lastCreatedBolt.transform = turn(matrix(), angle)

/**
 * Handles soft deletion of lightning bolt segments
 * by default after a lightning bolt faded it will be disposed
 *
 * @param o  the object segment to dispose
 */
/datum/bolt/proc/Dispose(obj/o)
	lastCreatedBolt = null
	o.loc = null

/**
 * Returns a list of segments from vector source to vector dest
 *
 * - @param  source source vector, where the bolt starts
 * - @param  dest   destination vector, where the bolt ends
 * @return dest   a list of line segments forming a lightning bolt
 */
/datum/bolt/proc/createBolt(simple_vector/source, simple_vector/dest)
	var/list/results = list()

	var/simple_vector/tangent = vectorSubtract(dest, source)
	var/simple_vector/normal  = vectorNormalize(new /simple_vector/(tangent.Y, -tangent.X))

	var/length = tangent.Length()

	var/list/positions = list(0)

	var/growth = 1 / (length / 4)
	var/p = 0
	for(var/i in 1 to length / 8)
		var/r = prand(growth / 3, growth * 3)
		p += r
		positions += p

		if(p >= 1) break

	var/const/Sway       = 80
	var/const/Jaggedness = 1 / Sway

	var/simple_vector/prevPoint = source
	var/prevDisplacement  = 0
	for(var/i in 2 to length(positions))
		var/pos = positions[i]

		// used to prevent sharp angles by ensuring very close positions also have small perpendicular variation.
		var/scale = ((length) * Jaggedness) * (pos - positions[i - 1])

		// defines an envelope. Points near the middle of the bolt can be further from the central line.
		var/envelope = pos > 0.95 ? 20 * (1 - pos) : 1

		var/displacement = prand(-Sway, Sway)

		displacement -= (displacement - prevDisplacement) * (1 - scale)
		displacement *= envelope


		var/simple_vector/point = new (source.X + (tangent.X * pos) + (normal.X * displacement), source.Y + (tangent.Y * pos) + (normal.Y * displacement))
		point.RoundVector()

		var/datum/line/l = new(prevPoint, point)
		results   += l

		prevPoint        = point
		prevDisplacement = displacement

	var/datum/line/l = new(prevPoint, dest)
	results += l

	return results

/**
 * Returns a vector at a given fraction 0 to 1, 0 being the start of the bolt and 1 being the end
 *
 * @param  fraction 0 to 1, 0 being the start of the bolt and 1 being the end
 * @return a vector at fraction point of the bolt
 */
/datum/bolt/proc/GetPoint(fraction)
	var/index = round(fraction * length(segments))

	index = min(index, length(segments))
	index = max(index, 1)

	var/datum/line/l = segments[index]

	return l.A

/**
 * Returns a list of turfs between the bolt's starting vector to the bolt's end vector
 * because this only checks first and last vectors it returns a form of line between both vectors and can be inaccurate if bolt segments stray too far
 * It can return null if no turfs are found.
 *
 * - @param  z         the map z level to search
 * - @param  accurate  controlls the accurecy of this function, lower number means more accurate results however it reduces performance
 *                   1 being the minimum, it should be noted even at 1 this will not be too accurate, use GetAllTurfs() for a more accurate result
 * @return a partial list of turfs the bolt passes on
 */
/datum/bolt/proc/GetTurfs(z, accurate = 16)
	var/datum/line/start = segments[1]
	var/datum/line/end = segments[length(segments)]

	return vectorGetTurfs(start.A, end.B, z, accurate)

/**
 * Returns a list of turfs between the bolt's starting vector to the bolt's end vector checking all segments
 * It can return null if no turfs are found.
 *
 * - @param z         the map z level to search
 * - @param accurate  controlls the accurecy of this function, lower number means more accurate results however it reduces performance
 *                  1 being the minimum
 * @return a list of turfs the bolt passes on
 */
/datum/bolt/proc/GetAllTurfs(z, accurate = 16)
	var/list/locs = list()

	for(var/datum/line/segment in segments)
		locs = locs|segment.GetTurfs(z, accurate)

	return length(locs) ? locs : null
