/datum/map_template/ruin/random_room
	name = "Random Room Framework" // The SSmapping random_room_template list is ordered by the name
	prefix = "maps/random_rooms/"
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/centerspawner = FALSE
	var/template_width = 0
	var/template_height = 0
	var/weight = 10 //weight(chance) a room has to appear
	var/stock = 1 //how many times this room can appear in a round
	var/room_type = "maintenance"