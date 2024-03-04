/obj/machinery/computer/ship/ship_weapon/proc/fire(mob/user)
	if(!link_parts())
		return FALSE //no disperser, no service
	if(!front.powered() || !middle.powered() || !back.powered())
		return FALSE //no power, no boom boom
	if(get_ammo() < ammo_per_shot || !get_ammo_type())
		return FALSE

	var/turf/start = front
	var/direction = front.dir

	if(prefire_sound)
		playsound(start, prefire_sound, 250, 0)

	var/list/relevant_z = GetConnectedZlevels(start.z)
	if(far_prefire_sound)
		for(var/mob/M in GLOB.player_list)
			var/turf/T = get_turf(M)
			if(!T || !(T.z in relevant_z))
				continue
			if(!isdeaf(M))
				sound_to(M, sound(far_prefire_sound, volume=10))

	sleep(fire_delay)

	if(!front || !get_charge()) //Meanwhile front might have exploded
		return FALSE

	for(var/mob/M in GLOB.player_list)
		var/turf/T = get_turf(M)
		if(!T || !(T.z in relevant_z))
			continue
		shake_camera(M, shake_camera_force)
		if(!isdeaf(M))
			sound_to(M, sound(far_fire_sound, volume=10))

	playsound(start, fire_sound, 250, 1)
	handle_muzzle(start, direction)

	var/ammo_type = get_ammo_type()
	var/obj/item/projectile/bullet/huge_caliber/pew = new ammo_type(front.loc)
	pew.starting = front.loc
	pew.overmapdir = overmapdir
	pew.enter_sound = far_fire_sound
	pew.cal_accuracy = cal_accuracy()
	pew.launch(get_step(front.loc, front.dir), pick(BP_ALL_LIMBS))

	remove_ammo()

	return TRUE

/obj/machinery/computer/ship/ship_weapon/proc/handle_muzzle(turf/start, direction = 1)
	set waitfor = FALSE
	if(!muzzle_flash || !start)
		return
	var/obj/projectile/P = new muzzle_flash(get_step(get_turf(start), direction))
	P.dir = direction
	P.color = muzzle_color
	QDEL_IN(P,2)

/proc/get_edge_turf(turf/start, direction)
	switch(direction)
		if(NORTH)
			return locate(start.x,world.maxy,start.z)
		if(SOUTH)
			return locate(start.x,1,start.z)
		if(WEST)
			return locate(1,start.y,start.z)
		if(EAST)
			return locate(world.maxx,start.y,start.z)
