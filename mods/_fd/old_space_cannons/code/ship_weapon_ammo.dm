#define TRANSITIONEDGE_BULLET 8
#define CALIBER_SHIP    "100mm"

/obj/item/ammo_magazine/ammobox
	name = "ammo box"
	desc = "An ordinary ammo box."
	icon = 'mods/_fd/old_space_cannons/icons/ammo.dmi'
	icon_state = "ammocrate_autocannon1"
	atom_flags =  ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_CLIMBABLE
	w_class = ITEM_SIZE_GARGANTUAN
	does_spin = FALSE
	density = TRUE
	randpixel = 0
	layer = 2.22

	max_ammo = 60
	ammo_type = /obj/item/ammo_casing/huge_caliber
	caliber = CALIBER_SHIP

	var/should_explode = TRUE

/obj/item/ammo_magazine/ammobox/ex_act(severity)
	if(should_explode && severity > 100)
		if(stored_ammo.len > max_ammo/3)
			should_explode = FALSE
			explosion(get_turf(src), 6, EX_ACT_DEVASTATING)
			if(src)
				qdel(src)
		else if(stored_ammo.len > 0)
			should_explode = FALSE
			explosion(get_turf(src), 3, EX_ACT_DEVASTATING)
			if(src)
				qdel(src)
	return

/obj/item/ammo_magazine/ammobox/attackby(obj/item/W as obj, mob/user as mob)
	if(isWrench(W))
		var/ammo_count = stored_ammo.len
		if(ammo_count > 0)
			to_chat(user, "You need [ammo_count] less [(ammo_count == 1)? "round" : "rounds"] left in the box to do that!")
			return
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/material/plasteel(get_turf(src))
		qdel(src)
		return
	..()

/obj/item/ammo_magazine/ammobox/pickup()
	return

///////////////////////////CASING///////////////////////////

/obj/item/ammo_casing/huge_caliber
	name = "round casing"
	desc = "A huge round casing."
	icon_state = "lcasing"
	spent_icon = "lcasing-spent"
	caliber = CALIBER_SHIP
	projectile_type = /obj/item/projectile/bullet/huge_caliber
	matter = list(MATERIAL_STEEL = 1250)

///////////////////////////BULLET///////////////////////////

/obj/item/projectile/bullet/huge_caliber
	name = "round"
	icon_state= "bolter"
	damage = 100
	damage_flags = DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP | DAMAGE_FLAG_EDGE
	armor_penetration = 10
	muzzle_type = null
	fire_sound = null
	distance_falloff = 0.1
	life_span = 250

	var/explosion_radius
	var/explosion_max_power = EX_ACT_DEVASTATING

	var/proximity_detonation = TRUE //should we explode near our target, and not inside of it?
	var/exploded = FALSE

	var/entered_overmap = FALSE
	var/overmapdir = NORTH

	var/transform_scale = 1

	var/cal_accuracy
	var/obj/overmap/projectile/overmap_projectile
	var/obj/overmap/origin

	var/shoot_range = 3 // how far will we go on the overmap

	// Насколько большой будет разброс в тайлах при попадании на овермап судна-цели.
	// Пример: при pew_spread = 50 снаряд будет спавниться с разбросом от -25 до 25 тайлов на нужном краю карты цели.
	// UPD: Теперь разброс умножается на уровень скилла пилота у корабля-цели.
	var/pew_spread = 10

	var/ground_to_space = TRUE //стрельба с планеты по космическим целям
	var/canhit_missiles = TRUE
	var/canhit_planets = TRUE
	var/canhit_sectors = TRUE
	var/canhit_ships = TRUE

	var/destroy_event_flags = null

	var/overmap_color = null
	var/enter_sound = null

/obj/item/projectile/bullet/huge_caliber/Initialize()
	. = ..()
	origin = map_sectors["[z]"]

/obj/item/projectile/bullet/huge_caliber/Move()
	. = ..()

	// for some reason, touch_map_edge doesn't always trigger like it should
	// this ensures that it does
	if(x < TRANSITIONEDGE_BULLET || x > world.maxx - TRANSITIONEDGE_BULLET || y < TRANSITIONEDGE_BULLET || y > world.maxy - TRANSITIONEDGE_BULLET)
		if(z != 0) //в нуллспейсе торпеда сразу решала что она на краю мапы
			touch_map_edge()

/obj/item/projectile/bullet/huge_caliber/setup_trajectory(turf/startloc, turf/targloc, x_offset = 0, y_offset = 0)
	..()
	SetTransform(scale = transform_scale, rotation = -(trajectory.angle + 90))

/obj/item/projectile/bullet/huge_caliber/Process()
	var/first_step = 1

	spawn while(src && src.loc)
		if(loc == overmap_projectile || entered_overmap)
			return
		if(life_span-- < 1)
			on_impact(src.loc) //for any final impact behaviours
			qdel(src)
			return
		if((!( current ) || loc == current))
			current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)
		if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
			qdel(src)
			return

		trajectory.increment()	// increment the current location
		location = trajectory.return_location(location)		// update the locally stored location data

		if(!location)
			qdel(src)	// if it's left the world... kill it
			return

		if (is_below_sound_pressure(get_turf(src)) && !vacuum_traversal) //Deletes projectiles that aren't supposed to bein vacuum if they leave pressurised areas
			qdel(src)
			return

		before_move()
		Move(location.return_turf())
		pixel_x = location.pixel_x
		pixel_y = location.pixel_y

		if(!bumped && !isturf(original))
			if(loc == get_turf(original))
				if(!(original in permutated))
					if(Bump(original))
						return

		if(first_step)
			muzzle_effect(effect_transform)
			first_step = 0
		else if(!bumped && life_span > 0)
			tracer_effect(effect_transform)
		if(!hitscan)
			sleep(step_delay)	//add delay between movement iterations if it's not a hitscan weapon

/obj/item/projectile/bullet/huge_caliber/touch_map_edge()
	if(istype(get_area(src), /area/exoplanet) && !ground_to_space)
		Destroy(src)
		return FALSE //Ты чё ебанутый, как твои пули без мини-двигателя собрались атмосферу покидать??

	if(loc == overmap_projectile || entered_overmap)
		return FALSE
	entered_overmap = TRUE

	var/obj/overmap/source = map_sectors["[z]"]

	if(!source)
		Destroy()

	overmap_projectile = new /obj/overmap/projectile(null, source.x, source.y)

	overmap_projectile.SetName("[source.name+"'s"] [name]")

	forceMove(overmap_projectile)
	overmap_projectile.set_projectile(src, cal_accuracy)
	overmap_projectile.color = overmap_color

/obj/item/projectile/bullet/huge_caliber/Destroy()
	if(!(atom_flags & ATOM_FLAG_INITIALIZED))
		Initialize()
	. = ..()

	if(!QDELETED(overmap_projectile))
		QDEL_NULL(overmap_projectile)
	overmap_projectile = null

/obj/item/projectile/bullet/huge_caliber/Bump(atom/A as mob|obj|turf|area, forced=0)
	if(entered_overmap)
		return

	if(!explosion_radius)
		..()
		return

	if(!exploded)
		exploded = TRUE
		if(proximity_detonation)
			var/backwards = turn(dir, 180)
			explosion(get_step(A, backwards), explosion_radius, explosion_max_power)
		else
			explosion(get_turf(A), explosion_radius, explosion_max_power)
		qdel(src)

///////////////////////////MUZZLE///////////////////////////

/obj/projectile/bullet/muzzle/ship_weapon
	icon = 'mods/_fd/old_space_cannons/icons/ammo.dmi'
	icon_state = "muzzle_bullet"
	anchored = TRUE

#undef TRANSITIONEDGE_BULLET
#undef CALIBER_SHIP
