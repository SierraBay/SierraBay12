/datum/planet_storyteller/classic

/obj/deploy_storyteller_here
	var/storyteller_path = /datum/planet_storyteller
	var/datum/planet_storyteller/storyteller

/obj/deploy_storyteller_here/New(loc, ...)
	.=..()
	storyteller = new storyteller_path(null, get_area(src))

/obj/deploy_storyteller_here/debug_activity

/obj/deploy_storyteller_here/debug_activity/New(loc, ...)
	. = ..()
	storyteller.next_possible_action = 1
	storyteller.current_scam_points = 1000
	storyteller.check_action()
