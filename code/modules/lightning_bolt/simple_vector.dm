/**
 * a simple 2D vector
 */
/simple_vector
	var/X
	var/Y

/**
 * Constructs the vector, assigns X and Y.
 *
 * - @param x the vector's x
 * - @param y the vector's y
 */
/simple_vector/New(x, y)
	..()

	X = x
	Y = y


/**
* Returns the length of the vector
* @return the length of the vector
*/
/simple_vector/proc/Length()
	return max(sqrt(X*X + Y*Y), 1)

/**
* Returns the start location turf of vector on z level
* @param  the z level
* @return the start location turf of vector on z level
*/
/simple_vector/proc/Locate(z)
	var/offsetX = X % world.icon_size
	var/offsetY = Y % world.icon_size

	var/x = (X - offsetX) / world.icon_size
	var/y = (Y - offsetY) / world.icon_size

	return locate(x, y, z)

/**
* Rounds the vectors coordinates
*/
/simple_vector/proc/RoundVector(r = 1)
	X = round(X, r)
	Y = round(Y, r)

/**
 * Returns true if vector
 *
 * @param v value to check
 * @return if value is vector or not
 */
/proc/isVector(v)
	return istype(v, /simple_vector)

/**
 * Returns a new vector equal to the sum of the two vectors
 *
 * - @param v1 first vector
 * - @param v2 second vector
 * @return new vector sum of the vectors added
 */
/proc/vectorAdd(simple_vector/v1, simple_vector/v2)
	return new /simple_vector (v1.X + v2.X, v1.Y + v2.Y)
/**
 * Returns a new vector equal to second vector subtracted from first
 *
 * - @param v1 first vector to subtract from
 * - @param v2 second vector
 * @return new vector sum of second vector subtracted from first
 */
/proc/vectorSubtract(simple_vector/v1, simple_vector/v2)
	return new/simple_vector(v1.X - v2.X, v1.Y - v2.Y)

/**
 * Return new vector from the result of multiplying the vector by a factor
 *
 * - @param v   vector to multiply
 * - @param num number to multiply by
 * @return new vector multiplied by number
	 */
/proc/vectorMultiply(simple_vector/v, num)
	return new/simple_vector(v.X * num, v.Y * num)

/**
 * Returns the distance between two vectors
 *
 * - @param v1 first vector
 * - @param v2 second vector
 * @return distance between the two vectors
 */
/proc/vectorDistance(simple_vector/v1, simple_vector/v2)
	return sqrt((v1.X - v2.X) ** 2 + (v1.Y - v2.Y) ** 2)

/**
 * Returns new normalized vector
 *
 * @param v vector to normalize
 * @return new normalized vector
 */
/proc/vectorNormalize(simple_vector/v)
	return new/simple_vector(v.X / v.Length(), v.Y / v.Length())

/**
 * Rotates a vector by an angle
 *
 * - @param v     the vector to rotate
 * - @param angle the angle to rotate by
 * @return new rotated vector
 */
/proc/vectorRotate(simple_vector/v, angle)
	return new/simple_vector(v.X * cos(angle) - v.Y * sin(angle), v.X * sin(angle) + v.Y * cos(angle))

/**
 * Returns a list of turfs between both vectors
 * returns null if no turfs are found
 *
 * - @param start     first vector
 * - @param end       second vector
 * - @param z         the z level on the map
 * - @param accurate  controlls the accurecy of this function, lower number means more accurate results however it reduces performance
 *                  1 being the minimum
 * @return a list of turfs between two vectors
 */
/proc/vectorGetTurfs(simple_vector/start, simple_vector/end, z, accurate = 16)
	var/list/locs
	var/distance    = vectorDistance(start, end)
	var/simple_vector/diff = vectorSubtract(end, start)

	for(var/i in 1 to distance step accurate)
		var/x = (start.X + diff.X * (i / distance)) / world.icon_size
		var/y = (start.Y + diff.Y * (i / distance)) / world.icon_size

		var/turf/t = locate(x, y, z)

		if(t)
			if(!locs)
				locs  = list(t)
			else if(!(t in locs))
				locs += t

	return locs
