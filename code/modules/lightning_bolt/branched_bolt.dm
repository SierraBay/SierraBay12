/**
 * A lightning bolt drawn between two vectors with 3 to 6 branched lightning bolts
 */

/datum/BranchedBolt
	var/list/datum/bolts
	var/simple_vector/end

	var/fade

/**
 * Constructs the branched bolt, from vector source to vector dest
 *
 * - @param source source vector, where the bolt starts
 * - @param dest   destination vector, where the bold ends
 * - @param fade   assigns fade out rate, default of 50
 */
/datum/BranchedBolt/New(simple_vector/start, simple_vector/end, fade = 50, targets=null)
	..()

	src.end  = end
	src.fade = fade

	Create(start, end, targets)

/**
 * Draws a branched lightning bolt of type with a color between two assigned vectors on z or client screen
 *
 * - @param z         the map z level to draw on, if z is client it will draw on client screen
 * - @param type      basic segment to use when drawing
 * - @param color     color of the branched bolt
 * - @param thickness thickness of the branched bolt
 * - @param split     if set to 1 will create an obj for each segment, if not it will only create one object with segments as overlays
 */
/datum/BranchedBolt/proc/Draw(z, type = /obj/lineSegment, color = "#fff", thickness = 1, split = 0)
	for(var/datum/bolt/b in bolts)
		b.fade = fade
		b.Draw(z, type, color, thickness, split)

/**
 * Initializes the branched lightning bolts list
 * the first bolt in the list will be the main bolt between the two given vectors with the addition of 3 to 6 branched bolts
 *
 * - @param source source vector, where the bolt starts
 * - @param dest   destination vector, where the bolt ends
 */
/datum/BranchedBolt/proc/Create(simple_vector/start, simple_vector/end, targets = null)
	var/datum/bolt/mainbolt = new (start, end)

	bolts = list(mainbolt)

	var/branches
	var/datum/boltTargets = FALSE

	if(!targets)
		branches = rand(3, 6)
	else if(isnum(targets))
		branches = targets
	else
		branches    = length(targets)
		boltTargets = TRUE

	var/list/positions = list()

	var/growth = 0.5 / branches
	var/p = 0
	for(var/i in 1 to branches)
		var/r = prand(growth / 3, growth * 3)
		p += r
		positions += p

		if(p >= 0.50) break

	var/simple_vector/diff = vectorSubtract(end, start)

	for(var/i in 1 to length(positions))
		// bolt.GetPoint() gets the position of the lightning bolt at specified fraction (0 = start of bolt, 1 = end)
		var/simple_vector/boltStart = mainbolt.GetPoint(positions[i])

		var/simple_vector/boltEnd
		if(boltTargets)
			var/atom/target = targets[i]
			boltEnd = new (target.x * world.icon_size, target.y * world.icon_size)
		else
			// rotate 30 degrees. Alternate between rotating left and right.
			var/simple_vector/v = vectorRotate(vectorMultiply(diff, 1 - positions[i]), pick(30,-30))
			boltEnd = vectorAdd(boltStart, v)

		var/datum/bolt/bolt = new (boltStart, boltEnd)
		bolt.fade     = fade
		bolts        += bolt

/**
 * Returns a list of turfs between the bolt's starting vector to the bolt's end vector without including branched bolts
 * because this only checks first and last vectors it returns a form of line between both vectors and can be inaccurate if bolt segments stray too far
 * It can return null if no turfs are found.
 *
 * - @param z         the map z level to search
 * - @param accurate  controlls the accurecy of this function, lower number means more accurate results however it reduces performance
 *                  1 being the minimum, it should be noted even at 1 this will not be too accurate, use GetAllTurfs() for a more accurate result
 * @return a partial list of turfs the main bolt passes on
 */
/datum/BranchedBolt/proc/GetTurfs(z, accurate = 16)
	var/datum/bolt/b = bolts[1]
	var/datum/line/l = b.segments[1]

	return vectorGetTurfs(l.A, end, z, accurate)

/**
 * Returns a list of turfs between the bolt's starting vector to the bolt's end vector checking all segments including all branched bolts
 * It can return null if no turfs are found.
 *
 * - @param z         the map z level to search
 * - @param accurate  controlls the accurecy of this function, lower number means more accurate results however it reduces performance
 *                  1 being the minimum
 * @return a list of turfs the bolts pass on
 */
/datum/BranchedBolt/proc/GetAllTurfs(z, accurate = 16)
	var/list/locs = list()

	for(var/datum/bolt/b in bolts)
		locs = locs|b.GetAllTurfs(z, accurate)

	return length(locs) ? locs : null
