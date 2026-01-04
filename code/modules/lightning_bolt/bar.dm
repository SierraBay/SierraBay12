/**
 * adjustable bar
 */

/datum/lineBeam/bar
	var/percent
	var/obj/lastCreated

/**
 * Draws a adjustable bar of type with a color between two assigned vectors on z or client screen
 *
 * - @param z          the map z level to draw on, if z is client it will draw on client screen
 * - @param type       basic segment to use when drawing
 * - @param color      color of the segment
 * - @param thickness  thickness of the segment
 */
/datum/lineBeam/bar/Draw(z, type = /obj/lineSegmentBeam, color = "#fff", thickness = 1)

	lastCreated = ..()

	lastCreated.transform = endTransform

	Effect()

/**
 * Adjusts the bar to a percent
 *
 * @param percent percent of bar filled
 */
/datum/lineBeam/bar/proc/Adjust(percent)
	set waitfor = 0

	var/newX = (newWidth*(percent / 100) - 1)/2
	lastCreated.transform = turn(matrix(newWidth * (percent / 100), 0, newX, 0, thickness, 0), rotation)
