/mob/proc/face_atom(atom/A)
	if(!A || !x || !y || !A.x || !A.y) return
	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy) return

	var/direction
	if(abs(dx) < abs(dy))
		if(dy > 0)	direction = NORTH
		else		direction = SOUTH
	else
		if(dx > 0)	direction = EAST
		else		direction = WEST
	if(direction != dir)
		facedir(direction, TRUE)
