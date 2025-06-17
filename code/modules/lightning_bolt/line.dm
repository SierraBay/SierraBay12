/**
 * a line drawn between two vectors
 */

/datum/line
	var/simple_vector/A
	var/simple_vector/B

/**
 * Constructs the line, assigns both vectors A and B
 *
 * - @param a first vector
 * - @param b second vector
 */
/datum/line/New(a, b)
	..()

	A = a
	B = b

/**
 * Draws a line of type with a color between two assigned vectors on z or client screen
 *
 * - @param root       root object for starting position, return appearance can be added as an overlay to this object
 * - @param s          basic segment to use when drawing
 * - @param thickness  thickness of the segment
 * @return an object or an image of given type transformed into a line between defined vectors
 */
/datum/line/proc/DrawOverlay(obj/root, obj/s, thickness = 1)
	var/simple_vector/tangent  = vectorSubtract(B, A)
	var/rotation        = Atan2(tangent.Y, tangent.X) - 90

	var/newWidth = tangent.Length()
	var/newX     = (newWidth - 1)/2

	var/matrix/m = turn(matrix(newWidth, 0, newX, 0, thickness, 0), rotation)

	m.Translate(A.X - (root.pixel_x + root.x * world.icon_size), A.Y - (root.pixel_y + root.y * world.icon_size))
	s.transform = m

	return s.appearance

/**
 * Draws a line of type with a color between two assigned vectors on z or client screen
 *
 * - @param z          the map z level to draw on, if z is client it will draw on client screen
 * - @param type       basic segment to use when drawing
 * - @param color      color of the segment
 * - @param thickness  thickness of the segment
 * @return an object or an image of given type transformed into a line between defined vectors
 */
/datum/line/proc/Draw(z = 1, type = /obj/lineSegment, color = "#fff", thickness = 1)
	var/simple_vector/tangent  = vectorSubtract(B, A)
	var/rotation        = Atan2(tangent.Y, tangent.X) - 90

	var/newWidth = tangent.Length()
	var/newX     = (newWidth - 1)/2

	var/matrix/m = turn(matrix(newWidth, 0, newX, 0, thickness, 0), rotation)

	var/obj/o = new type

	var/offsetX = A.X % world.icon_size
	var/offsetY = A.Y % world.icon_size

	var/x = (A.X - offsetX) / world.icon_size
	var/y = (A.Y - offsetY) / world.icon_size

	o.transform = m
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

	return o

/**
 * Returns a list of turfs the line passes through
 * returns null if no turfs are found
 *
 * - @param z         the map z level to search
 * - @param accurate  controlls the accurecy of this function, lower number means more accurate results however it reduces performance
 *                  1 being the minimum
 * @return a list of turfs the line passes on
 */
/datum/line/proc/GetTurfs(z, accurate = 16)
	return vectorGetTurfs(A, B, z, accurate)

/**
 * Rotates the line
 *
 * @param angle the angle to rotate thel line by
 */
/datum/line/proc/Rotate(angle)
	var/simple_vector/diff     = vectorSubtract(B, A)
	var/simple_vector/rotatedB = vectorRotate(diff, angle)

	B = vectorAdd(rotatedB, A)
