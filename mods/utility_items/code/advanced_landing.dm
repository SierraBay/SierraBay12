/obj/machinery/computer/shuttle_control/explore/handle_topic_href(datum/shuttle/autodock/overmap/shuttle, list/href_list)
	. = ..()
	if(href_list["advancedpick"])
		var/list/possible_d = shuttle.get_possible_waypoints()
		var/D
		if(length(possible_d))
			D = input("Choose shuttle destination", "Shuttle Destination") as null|anything in possible_d
		else
			to_chat(usr,SPAN_WARNING("No valid landing sites in range."))
		possible_d = shuttle.get_possible_waypoints()
		if(CanInteract(usr, GLOB.default_state) && (D in possible_d))
			landloc = get_turf(possible_d[D])
			oko_enter(landloc)
			shuttle_type = shuttle
		return TOPIC_REFRESH

/datum/shuttle/autodock/overmap/proc/get_possible_waypoints()
	var/list/wp = list()
	for (var/obj/overmap/visitable/S in range(get_turf(waypoint_sector(current_location)), range))
		wp += S
		return S


/obj/machinery/computer/shuttle_control
	var/mob/observer/eye/landeye/oko
	var/datum/shuttle/autodock/overmap/shuttle_type
	/// Horizontal offset from the console of the origin tile when using it
	var/x_offset = 0
	/// Vertical offset from the console of the origin tile when using it
	var/y_offset = 0
	var/landloc

/mob/observer/eye/landeye
	see_in_dark = 7

	density = FALSE
	alpha = 127
	plane = OBSERVER_PLANE
	invisibility = INVISIBILITY_EYE
	see_invisible = SEE_INVISIBLE_MINIMUM
	sight = SEE_TURFS
	simulated = TRUE
	stat = CONSCIOUS
	status_flags = GODMODE
	ghost_image_flag = GHOST_IMAGE_NONE
	var/list/placement_images = list()
	var/obj/machinery/computer/shuttle_control/explore/console_link
	var/list/to_add = list()

/mob/living/carbon/human/
	var/list/obscured_turfs = list()

/mob/living/carbon/human/update_dead_sight()
	. = ..()
	/*
	var/area = seen_turfs_in_range(src.eyeobj, world.view)
	var/image/O = image('icons/effects/cameravis.dmi', null, "black")*/
	if(eyeobj.type == /mob/observer/eye/landeye)
		set_sight(BLIND|SEE_TURFS)
		set_see_in_dark(8)
		set_see_invisible(SEE_INVISIBLE_MINIMUM)
		/*for(var/turf/simulated/t in area)
			if(t in obscured_turfs)
				return
			if(!(t in list(/area/space)))
				O.loc = t.loc
				O.layer = TURF_LAYER
				obscured_turfs[O] = t
		client.images += obscured_turfs*/

/mob/observer/eye/landeye/proc/acquire_visible_turfs(list/visible)
	for(var/turf/t in seen_turfs_in_range(src, world.view))
		if(t in typesof(/area/space))
			visible[t] = t
	return visible

/mob/observer/eye/landeye/possess(mob/user)
	if(owner && owner != user)
		return
	if(owner && owner.eyeobj != src)
		return
	owner = user
	owner.eyeobj = src
	SetName("[owner.name] ([name_sufix])") // Update its name
	if(owner.client)
		owner.verbs |= /mob/living/proc/spawn_landmark
		owner.verbs |= /mob/living/proc/extra_view
		owner.verbs |= /mob/living/proc/cancel_landeye_view
		owner.client.eye = src
/mob/observer/eye/landeye/setLoc(T)
	if(!owner)
		return FALSE

	T = get_turf(T)
	if(!T || T == loc)
		return FALSE

	forceMove(T)

	if(owner.client)
		owner.client.eye = src
	if(owner_follows_eye)
		owner.forceMove(loc)
	return TRUE

/mob/living/proc/extra_view()
	set name = "Change View"
	set desc = "Change View"
	set category = "Ships Control"
	var/mob/user = src
	var/extra_view = 4
	switch(alert("Set view scale", "Set view scale", "Normal", "Big"))
		if("Normal")
			return usr.client.view = usr.get_preference_value(/datum/client_preference/client_view)
		if("Big")
			return user.client.view = world.view + extra_view


/obj/machinery/computer/shuttle_control/explore/proc/oko_enter()
	oko = new /mob/observer/eye/landeye
	oko.name_sufix = "Landing Eye"
	oko.possess(usr)
	addtimer(new Callback(src, PROC_REF(oko_force_move)), 2 SECONDS)
	oko.console_link = src
	create_zone()
	oko.to_add = oko.placement_images
	usr.client.images = oko.to_add

/obj/machinery/computer/shuttle_control/explore/proc/oko_force_move()
	oko.forceMove(landloc)

/obj/machinery/computer/shuttle_control/explore/proc/create_zone()
	var/area/area_oko = get_area(oko.owner)
	var/obj/shuttle_landmark/shuttle_landmark = locate(/obj/shuttle_landmark) in area_oko
	var/turf/origin = locate(shuttle_landmark.x + x_offset, shuttle_landmark.y + y_offset, shuttle_landmark.z)
	var/turf/turf = get_subarea_turfs(area_oko.parent_type)

	for(var/area in list(/area/shuttle, /area/exploration_shuttle, /area/guppy_hangar, /area/crucian_hangar))
		if(ispath(area_oko.type, area))
			for(var/turf/simulated/T in turf)
				var/image/I = image('icons/effects/alphacolors.dmi', origin, "red")
				var/x_off = T.x - origin.x
				var/y_off = T.y - origin.y
				I.loc = locate(origin.x + x_off, origin.y + y_off, origin.z) //we have to set this after creating the image because it might be null, and images created in nullspace are immutable.
				I.layer = TURF_LAYER
				oko.placement_images[I] = list(x_off, y_off)

/obj/machinery/computer/shuttle_control/explore/proc/check_zone()
	var/turf/eyeturf = get_turf(oko)
	var/list/image_cache = oko.placement_images
	for(var/i in 1 to LAZYLEN(image_cache))
		var/image/I = image_cache[i]
		var/list/coords = image_cache[I]
		var/turf/T = locate(eyeturf.x + coords[1], eyeturf.y + coords[2], eyeturf.z)
		I.loc = T
		if(T.density)
			I.icon_state = "red"
		else
			I.icon_state = "blue"

/mob/cancel_camera()
	. = ..()
	if(!eyeobj)
		return
	if(eyeobj.type == /mob/observer/eye/landeye)
		eyeobj.release(src)
	usr.client.view = usr.get_preference_value(/datum/client_preference/client_view)

/mob/living/proc/cancel_landeye_view()
	set name = "Cancel View"
	set desc = "Cancel View"
	set category = "Ships Control"
	cancel_camera()

/mob/observer/eye/landeye/release(mob/user)
	if(owner != user || !user)
		return
	if(owner.eyeobj != src)
		return
	usr.client.images -= placement_images
	QDEL_NULL_LIST(placement_images)
	owner.eyeobj = null
	owner.verbs -= /mob/living/proc/spawn_landmark
	owner.verbs -= /mob/living/proc/extra_view
	owner.verbs -= /mob/living/proc/cancel_landeye_view
	owner = null
	SetName(initial(name))



/obj/shuttle_landmark/ship/advancedlandmark/Initialize(mapload, obj/shuttle_landmark/ship/master, _name)
	landmark_tag = "_[shuttle_name] [rand(1,99999)]"
	. = ..()

/mob/living/proc/spawn_landmark()
	set name = "Landing Spot"
	set category = "Ships Control"

	var/T = get_turf(src.eyeobj)
	var/areaalloved = get_area(src.eyeobj)
	var/obj/shuttle_landmark/ship/advancedlandmark/landmark
	if(landmark)
		qdel(landmark)
	if(isspace(areaalloved))
		landmark = new (T, src)
	else
		to_chat(usr, "Cannot land at this location.")
		return

	var/area/temp = get_area(eyeobj.owner)
	for(var/area in list(/area/shuttle, /area/exploration_shuttle, /area/guppy_hangar, /area/crucian_hangar))
		if(ispath(temp.type, area))
			for(var/obj/machinery/computer/shuttle_control/explore/c in temp)
				c.shuttle_type.set_destination(landmark)
				c.check_zone()
