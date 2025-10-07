/**
 * a line made of line segments, used to create a growing animated line (useful for beams, bars etc)
 */
/datum/lineBeam
	var/simple_vector/start
	var/simple_vector/end
	var/fade
	var/speed
	var/matrix/endTransform
	var/newWidth
	var/rotation
	var/thickness

/**
 * Constructs the beam, from vector source to vector dest
 *
 * - @param source    source vector, where the bolt starts
 * - @param dest      destination vector, where the beam ends
 * - @param fade      assigns fade out rate, default of 25
 */
/datum/lineBeam/New(simple_vector/source, simple_vector/dest, speed = 20, fade = 25)
	..()

	src.fade  = fade
	src.speed = speed

	start = source
	end   = dest

/**
 * Draws a beam of type with a color between two assigned vectors on z or client screen
 *
 * - @param z         the map z level to draw on, if z is client it will draw on client screen
 * - @param type      basic segment to use when drawing
 * - @param color     color of the beam
 * - @param thickness thickness of the beam
 */
/datum/lineBeam/proc/Draw(z = 1, type = /obj/lineSegmentBeam, color = "#fff", thickness = 1)

	src.thickness = thickness

	var/simple_vector/tangent  = vectorSubtract(end, start)
	rotation        = Atan2(tangent.Y, tangent.X) - 90

	newWidth = tangent.Length()
	var/newX = (newWidth - 1)/2

	endTransform = turn(matrix(newWidth, 0, newX, 0, thickness, 0), rotation)

	var/obj/o = new type
	var/offsetX = start.X % world.icon_size
	var/offsetY = start.Y % world.icon_size
	var/x = (start.X - offsetX) / world.icon_size
	var/y = (start.Y - offsetY) / world.icon_size

	o.transform = turn(matrix(1, 0, 1, 0, thickness, 0), rotation)
	o.color      = color
	o.alpha      = 255

	if(isnum(z))
		o.loc = locate(x, y, z)
		o.pixel_x = offsetX
		o.pixel_y = offsetY

	else
		var/client/c = z
		o.screen_loc = "[x]:[offsetX],[y]:[offsetY]"
		c.screen    += o

	Effect(o)

	return o

/**
 * Applys animation to beam segment
 * this could be overriden by child types to allow different animations to beam
 * by default, a beam will fully grow then begin to fade out
 *
 * @param o   the object segment, each beam is made of several segments
 */
/datum/lineBeam/proc/Effect(obj/o)
	set waitfor = 0
	animate(o, transform = endTransform, time = speed, flags = ANIMATION_LINEAR_TRANSFORM )
	sleep(speed)
	animate(o, alpha = 0, time = 255 / fade, loop = 1)
	sleep(255 / fade)
	Dispose(o)

/**
 * Handles soft deletion of beam segments
 * by default after a beam faded it will be disposed
 *
 * @param o the object segment to dispose
 */
/datum/lineBeam/proc/Dispose(obj/o)
	o.loc = null

/**
 * Returns a list of turfs between the beam's starting vector to the beam's end vector
 * It can return null if no turfs are found.
 *
 * - @param  z         the map z level to search
 * - @param  accurate  controlls the accurecy of this function, lower number means more accurate results however it reduces performance
 *                   1 being the minimum
 * @return a list of turfs the beam passes on
 */
/datum/lineBeam/proc/GetTurfs(z, accurate = 16)
	return vectorGetTurfs(start, end, z, accurate)
