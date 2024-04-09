GLOBAL_LIST_EMPTY(vehicle_interiors)
GLOBAL_LIST_EMPTY(templates_cache)

/datum/vehicle_interior
	var/id
	var/global/gid = 0

	//11 at max
	var/size_x = 0
	var/size_y = 0

	var/list/mob/living/carbon/human/occupants
	var/obj/effect/vehicle_entrance/entrance
	var/obj/vehicles/large/vehicle
	var/turf/middle_turf
	var/area/area

/datum/vehicle_interior/New(datum/map_template/interior_template, new_vehicle)
	if(!(interior_template in GLOB.templates_cache))
		GLOB.templates_cache[interior_template] = new interior_template

	interior_template = GLOB.templates_cache[interior_template]

	load_map(interior_template, new_vehicle)

/datum/vehicle_interior/proc/load_map(datum/map_template/interior_template, new_vehicle)
	set waitfor = FALSE
	var/list/interior_levels = GLOB.using_map.escape_levels // Transit levels
	LAZYLEN(interior_levels) || interior_levels.Add(7) // Sierra transit z is 7, not listed in escape_levels for some reason
	var/start = locate(TRANSITIONEDGE+1, TRANSITIONEDGE+1, min(interior_levels))
	var/finish = locate(world.maxx-TRANSITIONEDGE-1, world.maxy-TRANSITIONEDGE-1, max(interior_levels))
	for(var/turf/space/T in block(start, finish))
		var/valid = TRUE
		for(var/turf/check in interior_template.get_affected_turfs(T))
			if(!istype(check, /turf/space))
				valid = FALSE
				break
		if(valid)
			interior_template.load(T)
			middle_turf = locate(T.x + round(interior_template.width / 2), T.y + round(interior_template.height / 2), T.z)
			area = get_area(middle_turf)
			break
	if(!area)
		CRASH("Failed to load interior")

	id = gid++

	for(var/obj/effect/vehicle_entrance/E in area)
		entrance = E
		entrance.id = id
		break

	for(var/obj/structure/vehicledoor/E in area)
		E.id = id
		E.interior = src

	vehicle = new_vehicle
	if(!vehicle)
		return

	GLOB.vehicle_interiors += src

/obj/effect/vehicle_entrance
	var/id

/obj/vehicles/large
	var/datum/vehicle_interior/interior = null
	var/size_x = 0
	var/size_y = 0
	var/datum/map_template/interior_template = /datum/map_template

/obj/vehicles/large/get_all_positions()
	return ..() + list(VP_INTERIOR)

/obj/vehicles/large/Initialize()
	. = ..()
	interior = new(interior_template, src)

/obj/vehicles/large/proc/move_to_interior(atom/movable/user, puller)
	if(user == puller)
		visible_message(SPAN_NOTICE("[user] enters the interior of [src]."))
	else
		visible_message(SPAN_NOTICE("[puller] puts [user] into interior of \the [src]."))
	to_chat(user, SPAN_NOTICE("You are now in the interior of [src]."))
	playsound(src, null, 150, 1, 5)

	if(!interior?.entrance)
		to_chat(user, SPAN_OCCULT("or not."))
		return

	user.forceMove(get_turf(interior.entrance))
	occupants[user] = VP_INTERIOR

	return TRUE

/obj/vehicles/large/proc/move_object_to_interior(obj/object, puller)
	if(isturf(object) || object.anchored || !interior?.entrance)
		to_chat(puller, SPAN_NOTICE("You can't pull [object]"))
		return FALSE

	visible_message(SPAN_NOTICE("[puller] puts [object] into interior of \the [src]."))
	object.forceMove(get_turf(interior.entrance))

	return TRUE


/obj/vehicles/large/enter_as_position(user, position, mob/puller)
	if(position == VP_INTERIOR)
		if(!ismob(user))
			return move_object_to_interior(user, puller)
		return move_to_interior(user, puller)
	return ..()

/obj/structure/vehiclewall
	name = "vehicle wall"
	icon = 'mods/_fd/multitile_vehicles/icons/walls.dmi'
	icon_state = "noborder"

	layer = ABOVE_HUMAN_LAYER

	density = TRUE
	opacity = TRUE
	fragile = FALSE
	anchored = TRUE

/obj/structure/vehicledoor
	name = "vehicle door"
	icon = 'mods/_fd/multitile_vehicles/icons/walls.dmi'
	icon_state = "ambulancedoor"

	layer = ABOVE_HUMAN_LAYER

	density = TRUE
	opacity = TRUE
	anchored = TRUE

	var/id
	var/datum/vehicle_interior/interior = null

	atmos_canpass = CANPASS_DENSITY

// ;(
/obj/structure/vehicledoor/Move()
	return

/obj/structure/vehicledoor/forceMove(atom/dest)
	return

/obj/structure/vehicledoor/attack_hand(mob/user)
	if(interior.vehicle.loc == null)
		to_chat(user, "\The [src] is locked.")
		return
	interior.vehicle.exit_vehicle(user)

/obj/structure/vehicledoor/MouseDrop_T(mob/target, mob/user)
	. = ..()
	if(ismob(target))
		interior.vehicle.exit_vehicle(target, ignore_incap_check = TRUE, puller = user)
	else
		target.forceMove(interior.vehicle.pick_valid_exit_loc())

/obj/structure/vehicledoor/airlock
	icon = 'icons/obj/doors/station/door.dmi'
	icon_state = "preview"

/area/interior
	name = "interior"
	dynamic_lighting = 1
	requires_power = 0

/area/interiors_spawn
	name = "interiors spawn"
