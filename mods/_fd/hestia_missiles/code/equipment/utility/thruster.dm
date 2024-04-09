// Very oversimplified engine/booster. It takes a target and instantly adjusts the speed of the projectile to move towards it
/obj/item/missile_equipment/thruster
	name = "missile booster"
	desc = "A simple but powerful and modular booster that can be fitted in most missiles. This one comes with an embedded targeting computer."
	icon_state = "target"

	cooldown = 5

	var/target
	var/fuel = 10 // how many times can the engine do work until its out of fuel
	var/max_fuel = 100
	var/speed = 0
	var/min_speed = 60 //bos
	var/maneuverability = 20 // turf spread on entering map

/obj/item/missile_equipment/thruster/do_overmap_work(obj/overmap/missile/P)
	if(!..() || isnull(target) || !fuel)
		return 0

	var/turf/T = get_turf(target)

	// The missile has arrived or it ran out of fuel. Stop it from moving further
	if(P.loc == T || !fuel)
		P.move_to(null)

	speed = min(min_speed, speed+1)
	fuel--
	P.move_to(T, min_speed, speed)
	return 1

/obj/item/missile_equipment/thruster/should_enter(obj/overmap/O)
	if(O == target)
		return TRUE
	return FALSE

/obj/item/missile_equipment/thruster/proc/is_target_valid(obj/overmap/visitable/O)
	return ((O.sector_flags & OVERMAP_SECTOR_IN_SPACE) && !(O.sector_flags & OVERMAP_SECTOR_UNTARGETABLE) && LAZYLEN(O.map_z))

/obj/item/missile_equipment/thruster/on_touch_map_edge(obj/overmap/missile/P)
	var/turf/turf_location = get_turf(src)
	var/obj/overmap/visitable/ship/ship = waypoint_sector(turf_location)
	target = ship.get_target(TARGET_SHIP)



// Anti-missile missile booster with more fuel and more thrust per unit of fuel
// Intended for use with the anti-missile equipment
/obj/item/missile_equipment/thruster/hunter
	name = "HUNTER warp booster"
	desc = "An advanced booster specifically designed to plot courses towards and catch up to rapidly moving objects such as other missiles."
	icon_state = "seeker"
	min_speed = 40 //bos

	fuel = 40

/obj/item/missile_equipment/thruster/hunter/is_target_valid(obj/overmap/O)
	return istype(O, /obj/overmap/missile)

/obj/item/missile_equipment/thruster/hunter/on_touch_map_edge(obj/overmap/missile/P)
	var/turf/turf_location = get_turf(src)
	var/obj/overmap/visitable/ship/ship = waypoint_sector(turf_location)
	target = ship.get_target(TARGET_MISSILE)


// Takes in coordinates and flies to said coordinates (although very slowly, so the range isn't great)
/obj/item/missile_equipment/thruster/point
	name = "pointman missile booster"
	desc = "A missile booster designed to travel to and rest at a given point. Steers away from structures."
	icon_state = "dumbfire"
	min_speed = 30 //FD

/obj/item/missile_equipment/thruster/point/on_touch_map_edge(obj/overmap/missile/P)
	var/turf/turf_location = get_turf(src)
	var/obj/overmap/visitable/ship/ship = waypoint_sector(turf_location)
	target = locate(ship.get_target(TARGET_POINT)[1], ship.get_target(TARGET_POINT)[2], GLOB.using_map.overmap_z)

/obj/item/missile_equipment/thruster/planet
	name = "planetary missile booster"
	desc = "The standard fare missile booster, but with planetary flight capabilities."
	icon_state = "planet"
	min_speed = 25 //bos

	var/turf/planetary_target

/obj/item/missile_equipment/thruster/planet/is_target_valid(obj/overmap/O)
	return istype(O, /obj/overmap/visitable/sector/exoplanet || /obj/overmap/visitable/sector/arcticplanet)

// Immediately move the missile to the target on arrival
/obj/item/missile_equipment/thruster/planet/on_enter_level(z_level)
	var/obj/structure/missile/M = loc
	if(!istype(M))
		return

	if(z_level == planetary_target.z)
		// Effectively apply a small random offset from the target
		var/turf/impact_turf = planetary_target
		for(var/turf/T in shuffle(trange(3, planetary_target)))
			if(!T.contains_dense_objects())
				impact_turf = T
				break

//		playsound(impact_turf, 'sound/effects/bomb_fall.ogg', 75, FALSE, falloff = 5)

//		sleep(rand(35,50))

		M.forceMove(impact_turf)
		M.detonate(impact_turf)

	return null

/obj/item/missile_equipment/thruster/planet/on_touch_map_edge(obj/overmap/missile/P) //TODO: THIS WILL FUCKING RUNTIME

	var/turf/turf_location = get_turf(src)
	var/obj/overmap/visitable/ship/ship = waypoint_sector(turf_location)

	var/target_x = ship.get_target(TARGET_PLANET)[2]
	var/target_y = ship.get_target(TARGET_PLANET)[3]
	target = ship.get_target(TARGET_PLANET)[1]

	var/obj/overmap/visitable/sector/exoplanet/planet = target
	var/turf/tgt = locate(target_x, target_y, planet.map_z[planet.map_z.len])
	planetary_target = tgt

	return
