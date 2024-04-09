/obj/item/projectile/bullet/huge_caliber/proc/after_move()
	shoot_range--
	if(shoot_range==0)
		return FALSE
	return TRUE

/obj/item/projectile/bullet/huge_caliber/proc/process_thingies()
	return // in case we need projectile to do something when overmap_projectile.Process() occurs

/obj/item/projectile/bullet/huge_caliber/proc/check_enter()
	if(!overmap_projectile || !origin)
		return

	if(!istype(overmap_projectile.loc, /turf))
		return

	if(overmapdir != 0 && get_dist(overmap_projectile,origin) <= 0)
		return // ignore anything right under us if flying direction is not 0

	var/list/candidates = list()

	//Next we see if there are any targets around. Logically they are between us and the sector if one exists.

	if(!length(candidates) && canhit_ships)
		for(var/obj/overmap/visitable/ship/S in overmap_projectile.loc)
			if(S == origin)
				continue //Why are you shooting yourself?
			candidates += S

	if(!length(candidates) && canhit_missiles)
		for(var/obj/overmap/missile/M in overmap_projectile.loc)
			candidates += M

	if(!length(candidates) && canhit_sectors)
		for(var/obj/overmap/visitable/sector/O in overmap_projectile.loc)
			if(O == origin)
				continue //Why are you shooting yourself?
			if(O.sector_flags & OVERMAP_SECTOR_UNTARGETABLE || istype(O,/obj/overmap/visitable/sector/exoplanet))
				continue
			candidates += O

//		for(var/obj/overmap/trading/T in overmap_projectile.loc) TODO: OVERMAP_TRADERS
//			candidates += T

	if(!length(candidates) && destroy_event_flags)
		for(var/obj/overmap/event/E in overmap_projectile.loc)
			candidates += E

	if(!length(candidates) && canhit_planets)
		for(var/obj/overmap/visitable/sector/exoplanet/P in overmap_projectile.loc)
			if(P == origin)
				continue
			candidates += P

	if(!length(candidates))
		return TRUE

	var/obj/overmap/target = pick(candidates)

//	if(istype(target, /obj/overmap/trading)) TODO: OVERMAP_TRADERS
//		qdel(target)
//		overmap_projectile.Destroy()
//		return TRUE

	if(istype(target, /obj/overmap/event))
		var/obj/overmap/event/E = target
		if(E.weaknesses & destroy_event_flags)
			var/turf/T = E.loc
			qdel(E)
			overmap_projectile.Destroy()
			overmap_event_handler.update_hazards(T)
		return TRUE

	if(istype(target, /obj/overmap/missile))
		if(prob(100 - cal_accuracy / 2)) // �������� 50% ���� ������� �� �������
			target.Destroy()
			overmap_projectile.Destroy()
		return TRUE

	var/obj/overmap/visitable/finaltarget = target
	var/z_level = pick(finaltarget.map_z)

	if(istype(finaltarget,/obj/overmap/visitable/sector/exoplanet))
		enter_exoplanet(z_level, finaltarget)
	else
		var/fore_dir = SOUTH
		if(istype(finaltarget, /obj/overmap/visitable/ship))
			var/obj/overmap/visitable/ship/target_ship = finaltarget
			fore_dir = target_ship.fore_dir
		enter_sector(z_level, fore_dir, finaltarget)

/obj/item/projectile/bullet/huge_caliber/proc/enter_sector(z_level, target_fore_dir, obj/overmap/target)
	var/heading = overmap_projectile.walk_direction

	if(!heading)
		heading = pick(GLOB.cardinal)

	var/actual_spread = pew_spread / 2

	var/obj/overmap/visitable/ship/target_ship = target
	if(istype(target_ship, /obj/overmap/visitable/ship))
		actual_spread = (target_ship.get_helm_skill()+1) / 2 * (pew_spread/2)

		if(target_ship.is_still() || target_ship.get_speed() <= SHIP_SPEED_SLOW)
			actual_spread = pew_spread / 2

	var/start_x = floor(world.maxx / 2) + round( rand(-actual_spread, actual_spread) )
	var/start_y = floor(world.maxy / 2) + round( rand(-actual_spread, actual_spread) )

	//Normalize killing people :D
	if(heading in GLOB.cornerdirs)
		if(heading == NORTHEAST)
			heading = pick(NORTH, EAST)
		if(heading == NORTHWEST)
			heading = pick(NORTH, WEST)
		if(heading == SOUTHEAST)
			heading = pick(SOUTH, EAST)
		if(heading == SOUTHWEST)
			heading = pick(SOUTH, WEST)

	if(target.dir in GLOB.cornerdirs)
		if(target.dir == NORTHEAST)
			target.dir = pick(NORTH, EAST)
		if(target.dir == NORTHWEST)
			target.dir = pick(NORTH, WEST)
		if(target.dir == SOUTHEAST)
			target.dir = pick(SOUTH, EAST)
		if(target.dir == SOUTHWEST)
			target.dir = pick(SOUTH, WEST)

	if(heading == target.dir)
		if(target_fore_dir == NORTH)
			start_y = TRANSITIONEDGE + 2
			heading = NORTH
		else if(target_fore_dir == SOUTH)
			start_y = world.maxy - TRANSITIONEDGE - 2
			heading = SOUTH
		else if(target_fore_dir == WEST)
			start_x = world.maxx - TRANSITIONEDGE - 2
			heading = WEST
		else
			start_x = TRANSITIONEDGE + 2
			heading = EAST

	else if(heading == GLOB.reverse_dir[target.dir])
		if(target_fore_dir == NORTH)
			start_y = world.maxy - TRANSITIONEDGE - 2
			heading = SOUTH
		else if(target_fore_dir == SOUTH)
			start_y = TRANSITIONEDGE + 2
			heading = NORTH
		else if(target_fore_dir == WEST)
			start_x = TRANSITIONEDGE + 2
			heading = EAST
		else
			start_x = world.maxx - TRANSITIONEDGE - 2
			heading = WEST

	else if(heading == GLOB.cw_dir[target.dir])
		if(target_fore_dir == NORTH)
			start_x = TRANSITIONEDGE + 2
			heading = EAST
		else if(target_fore_dir == SOUTH)
			start_x = world.maxx - TRANSITIONEDGE - 2
			heading = WEST
		else if(target_fore_dir == WEST)
			start_y = TRANSITIONEDGE + 2
			heading = NORTH
		else
			start_y = world.maxy - TRANSITIONEDGE - 2
			heading = SOUTH

	else if(heading == GLOB.ccw_dir[target.dir])
		if(target_fore_dir == NORTH)
			start_x = world.maxx - TRANSITIONEDGE - 2
			heading = WEST
		else if(target_fore_dir == SOUTH)
			start_x = TRANSITIONEDGE + 2
			heading = EAST
		else if(target_fore_dir == WEST)
			start_y = world.maxy - TRANSITIONEDGE - 2
			heading = SOUTH
		else
			start_y = TRANSITIONEDGE + 2
			heading = NORTH

	var/turf/start = locate(start_x, start_y, z_level)

	log_and_message_admins("[name] ����� � [target.name] �� Z [z_level] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>MAP</a>)", location=start)

	entered_overmap = FALSE
	forceMove(start)

	overmap_projectile.actual_projectile = null
	overmap_projectile.Destroy()
	overmap_projectile = null

	original = start
	current = start
	starting = start
	launch(get_step(start,heading), pick(BP_ALL_LIMBS))

/obj/item/projectile/bullet/huge_caliber/proc/enter_exoplanet(z_level, obj/overmap/target)

	var/turf/start = locate(rand(8,world.maxx-8),rand(8,world.maxy-8), z_level)

	for(var/mob/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(!T || !(T.z == z_level))
			continue
		if(!isdeaf(M))
			if(enter_sound)
				sound_to(M, sound(enter_sound, volume=10))
			if(prob(33))
				if(prob(33))
					to_chat(M, SPAN_DANGER("The sky overhead roars as bullets slice through exoplanet's atmosphere from orbit! This isn't good..."))
				else
					to_chat(M, SPAN_DANGER("The sky overhead roars as bullets slice through exoplanet's atmosphere from orbit!"))

	log_and_message_admins("[name] ����� � {[start.x];[start.y]} �� [target] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>MAP</a>)", location=start)

	entered_overmap = FALSE
	forceMove(start)

	overmap_projectile.actual_projectile = null
	overmap_projectile.Destroy()
	overmap_projectile = null

	original = start
	current = start
	starting = start
	launch(get_step(start,pick(GLOB.cardinal)), pick(BP_ALL_LIMBS))
	Bump(start)
