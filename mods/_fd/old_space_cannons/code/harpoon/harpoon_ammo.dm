#define CALIBER_SHIP_HARPOON "steel harpoon"

/obj/item/ammo_magazine/ammobox/harpoon_cannon
	name = "ammo box"
	desc = "Ammo box that contains 1.5 meters wide harpoon rods."
	icon_state = "ammocrate_autocannon1"
	caliber = CALIBER_SHIP_HARPOON
	max_ammo = 5
	ammo_type = /obj/item/ammo_casing/huge_caliber/harpoon_cannon

/obj/item/ammo_magazine/ammobox/harpoon_cannon/ex_act(severity)
	return

/obj/item/ammo_casing/huge_caliber/harpoon_cannon
	name = "giant rod casing"
	desc = "A harpoon gun charge casing."
	caliber = CALIBER_SHIP_HARPOON
	projectile_type = /obj/item/projectile/bullet/huge_caliber/harpoon_cannon

/obj/item/projectile/bullet/huge_caliber/harpoon_cannon
	name = "giant steel rod"
	icon_state = "rod"
	transform_scale = 4
	damage = 450
	armor_penetration = 50
	penetrating = 4
	penetration_modifier = 1.1
	shoot_range = 4 // how far will we go on the overmap = 1
	pew_spread = 8

	canhit_missiles = FALSE

	var/beam_icon = "n_beam_alt" // icons\effects\beam.dmi
	var/beam_icon_pull = "n_beam" // icons\effects\beam.dmi
	var/harpoon_wall_type = /turf/simulated/wall

/obj/item/projectile/bullet/huge_caliber/harpoon_cannon/process_thingies()
	if(origin && entered_overmap)
		if(overmap_projectile.z == 12)
			handle_overbeam(overmap_projectile)
		else
			handle_overbeam(overmap_projectile.loc)

/obj/item/projectile/bullet/huge_caliber/harpoon_cannon/proc/handle_overbeam(atom/target)
	set waitfor = FALSE
	if(get_dist(origin, target) > 5) return TRUE

	if(origin.z == 12) origin.Beam(target, beam_icon, time = 30, maxdistance = world.maxx)
	else origin.loc.Beam(target, beam_icon, time = 30, maxdistance = world.maxx)

/obj/item/projectile/bullet/huge_caliber/harpoon_cannon/enter_sector(z_level, target_fore_dir, obj/overmap/target)
	set waitfor = FALSE

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

	var/hit = FALSE
	for(var/turf/T in getline(start,get_edge_turf(start,heading)))
		ex_act(3)
		for(var/atom/A in T)
			if(!istype(A, /obj/item/projectile) && (!istype(A, /obj/effect) || istype(A, /obj/shield)))
				A.ex_act(1)
		if(T.density)
			explosion(T,9)
			new harpoon_wall_type(T)
			new harpoon_wall_type(get_step(T,heading))
			new harpoon_wall_type(get_step(T,turn(heading,180)))

			hit = TRUE
			log_and_message_admins("[name] попал в [target.name] на Z [z_level] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>MAP</a>)", location=T)

			break


	if(!hit)
		overmap_projectile.Destroy()
		return TRUE

	for(var/mob/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(!T || !(T.z in GetConnectedZlevels(start.z)))
			continue
		shake_camera(M, 15)
		if(!isdeaf(M))
			sound_to(M, sound('mods/_fd/old_space_cannons/sounds/harpoon_creak_thud.ogg', volume=50))

	var/sizes[0]
	sizes[origin] = origin.get_vessel_weight(target)
	sizes[target] = target.get_vessel_weight(origin)

	var/obj/overmap/visitable/puller = max(sizes[target], sizes[origin])
	var/obj/overmap/visitable/victim = min(sizes[target], sizes[origin])

	if(puller == INFINITY && victim == INFINITY)
		overmap_projectile.Destroy()
		return TRUE // immovable object VS unstoppable force momento, let's skip

	puller = get_key_by_value(sizes,puller)
	victim = get_key_by_value(sizes,victim)

	overmap_projectile.forceMove(target)
	beam_icon = beam_icon_pull // now we do the pull anim

	while(get_dist(victim, puller) > 0)
		if(get_dist(victim, puller) > 5) break
		sleep(20)
		victim.Move(get_step(victim,get_dir(victim,puller)))

		if(istype(victim, /obj/overmap/visitable/ship))
			var/obj/overmap/visitable/ship/vessel = victim
			vessel.adjust_speed(-vessel.speed[1] / 1.5, -vessel.speed[2] / 1.5)

	if(overmap_projectile)
		overmap_projectile.Destroy()

	return TRUE

/obj/overmap/proc/get_vessel_weight(obj/overmap/visitable/ship/compare_to)
	if(!istype(src,/obj/overmap/visitable/ship))
		return INFINITY // exoplanet/station = very chunky boi

	var/obj/overmap/visitable/ship/us = src
	if(istype(us,/obj/overmap/visitable/ship/landable) && us.z != 12)
		us = pick(us.locs) // If we are docked to something - use our mothership weight numbers instead

	if(istype(compare_to))
		if(us.vessel_size == compare_to.vessel_size)
			return us.vessel_mass // Let's compare vessel_masses instead of equal vessel_size's

	return us.vessel_size

/obj/item/projectile/bullet/huge_caliber/harpoon_cannon/enter_exoplanet(z_level, obj/overmap/target)
	enter_sector(z_level, NORTH, target)
	return TRUE
