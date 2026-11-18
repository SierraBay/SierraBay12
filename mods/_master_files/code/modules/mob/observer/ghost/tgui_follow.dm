/mob/observer/ghost/follow()
	set category = "Ghost"
	set name = "Follow"
	if(next_follow > world.time)
		return
	next_follow = world.time + 1 SECOND
	GLOB.orbit_menu.show(src)
