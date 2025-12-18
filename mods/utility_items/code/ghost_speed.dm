/mob/observer/ghost
	glide_size = 6
	movement_handlers = list(/datum/movement_handler/mob/multiz_connected, /datum/movement_handler/delay = list(0.35), /datum/movement_handler/mob/incorporeal)

/datum/movement_handler/delay/ghost_delay
	delay = 0.35
	next_move

/datum/movement_handler/delay/New(host, delay)
	..()
	src.delay = max(0.35, delay)
