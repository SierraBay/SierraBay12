/obj/overmap/projectile
	name = "projectile"
	icon_state = "projectile_danger"
	scannable = FALSE

	var/obj/item/projectile/bullet/huge_caliber/actual_projectile = null

	var/walk_direction = NORTH
	var/walk_delay = 4
	var/walk_timer = 0

/obj/overmap/projectile/Initialize(maploading, sx, sy)
	. = ..()
	x = sx
	y = sy
	z = GLOB.using_map.overmap_z
	START_PROCESSING(SSobj, src)

/obj/overmap/projectile/Destroy()
	if(actual_projectile)
		if(!(actual_projectile.atom_flags & ATOM_FLAG_INITIALIZED))
			actual_projectile.Initialize()
		if(!QDELETED(actual_projectile))
			QDEL_NULL(actual_projectile)
	actual_projectile = null

	. = ..()

/obj/overmap/projectile/Bump(atom/A)
//	if(istype(A,/turf/unsimulated/map/edge))
//		// Destroy() in the missile will qdel this object as well
//		qdel(actual_projectile)
	..()

/obj/overmap/projectile/proc/set_projectile(obj/item/projectile/bullet/huge_caliber/projectile, cal_accuracy)
	actual_projectile = projectile
	actual_projectile.forceMove(src)

	var/shoot_direction = projectile.overmapdir
	if(prob(100 - cal_accuracy))
		shoot_direction = turn(shoot_direction,pick(45,-45))

	walk_direction = shoot_direction
	dir = shoot_direction

	pixel_x = projectile.origin.pixel_x + rand(-3,3)
	pixel_y = projectile.origin.pixel_y + rand(-3,3)

	// calculate initial x and y difference
	var/dx = get_step(src,shoot_direction).x - src.x
	var/dy = get_step(src,shoot_direction).y - src.y

	transform = turn(transform, -(Atan2(dx,dy) + 90) ) //no idea why 90 needs to be added, but it works

/obj/overmap/projectile/Process()
	actual_projectile.process_thingies()
	if(!actual_projectile || z != 12)
		return

	if(walk_timer >= walk_delay)
		actual_projectile.check_enter()
		if(actual_projectile.shoot_range == 0 || actual_projectile.overmapdir == 0) // we stay no longer if projectile shot on direction 0 (under us)
			Destroy()
			return
		Move(get_step(src,walk_direction))
		if(!actual_projectile.after_move())
			icon_state = "projectile"
		walk_timer = -1
		spawn(4) actual_projectile.check_enter()
	walk_timer++
