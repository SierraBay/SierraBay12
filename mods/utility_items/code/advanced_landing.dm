/obj/machinery/computer/shuttle_control/Initialize(mapload, init_shuttle_tag)
	. = ..()
	if(shuttle_tag == init_shuttle_tag)
		sync_shuttle()

/obj/machinery/computer/shuttle_control/explore/handle_topic_href(datum/shuttle/autodock/overmap/shuttle, list/href_list)
	. = ..()
	if(href_list["advancedpick"])
		var/list/possible_d = shuttle.get_possible_waypoints()
		var/obj/overmap/visitable/D
		if(length(possible_d))
			D = input("Choose shuttle destination", "Shuttle Destination") as null|anything in possible_d
		else
			to_chat(usr,SPAN_WARNING("No valid landing sites in range."))
		possible_d = shuttle.get_possible_waypoints()
		if(CanInteract(usr, GLOB.default_state) && (D in possible_d))
			var/area/area_oko = get_area(src)
			var/obj/machinery/computer/shuttle_control/explore/console = locate(/obj/machinery/computer/shuttle_control/explore) in area_oko
			var/turf/origin = locate(console.x + x_offset, console.y + y_offset, console.z)
			landloc = locate(origin.x, origin.y, pick(D.map_z))
			oko_enter(landloc)
			shuttle_type = shuttle
		return TOPIC_REFRESH

/datum/shuttle/autodock/overmap/proc/get_possible_waypoints()
	var/list/waypoints = list()
	var/z_co = usr.z
	var/obj/overmap/visitable/we = map_sectors["[z_co]"]
	var/turf/T = get_turf(we)
	for(var/obj/overmap/visitable/candidate in T)
		if(candidate.map_z)
			waypoints += candidate
	return waypoints

/obj/machinery/computer/shuttle_control
	var/mob/observer/eye/landeye/oko
	var/datum/shuttle/autodock/overmap/shuttle_type
	/// Horizontal offset from the console of the origin tile when using it
	var/x_offset = 0
	/// Vertical offset from the console of the origin tile when using it
	var/y_offset = 0
	var/landloc
	var/skilled_enough = FALSE
	var/skill_req = SKILL_EXPERIENCED

/obj/machinery/computer/shuttle_control/proc/update_operator_skill()
	if (isobserver(usr))
		return
	if(!usr)
		return
	operator_skill = usr.get_skill_value(SKILL_PILOT)
	if (operator_skill >= skill_req && !(istype(usr, /mob/living/silicon/ai)))
		skilled_enough = TRUE
	else
		skilled_enough = FALSE

/obj/machinery/computer/shuttle_control/explore/get_ui_data(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	. = ..()
	update_operator_skill()

	. += list(
	"skilled_enough" = skilled_enough
	)

/mob/observer/eye/landeye
	see_in_dark = 7

	density = FALSE
	alpha = 127
	plane = OBSERVER_PLANE
	simulated = FALSE
	stat = CONSCIOUS
	invisibility = INVISIBILITY_EYE
	see_invisible = SEE_INVISIBLE_MINIMUM
	sight = SEE_TURFS
	ghost_image_flag = GHOST_IMAGE_NONE
	var/list/placement_images = list()
	var/obj/machinery/computer/shuttle_control/explore/console_link
	var/list/to_add = list()

/mob/living/carbon/human/update_dead_sight()
	. = ..()
	if(!eyeobj)
		cancel_landeye_view()
		return
	if(eyeobj.type == /mob/observer/eye/landeye)
		set_see_in_dark(8)
		set_see_invisible(SEE_INVISIBLE_MINIMUM)
		set_sight(BLIND|SEE_TURFS)

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


//______________________________________________________________
//Ради Модульности, дублируем сюда все что идет в awayshuttle и accessible_areas
/obj/machinery/computer/shuttle_control/explore/away_scg_patrol/reaper
/obj/machinery/computer/shuttle_control/explore/vox_lander
/obj/machinery/computer/shuttle_control/explore/skrellscoutshuttle
/obj/machinery/computer/shuttle_control/explore/away_farfleet/snz
/obj/machinery/computer/shuttle_control/explore/mule
/obj/machinery/computer/shuttle_control/explore/graysontug/hand_one
/obj/machinery/computer/shuttle_control/explore/pod_hand_one
/obj/machinery/computer/shuttle_control/explore/pod_hand_two
/obj/machinery/computer/shuttle_control/explore/graysontug/hand_two
/obj/machinery/computer/shuttle_control/explore/merc_shuttle/merc_drop_pod

/area/mine
	name = "Mine"

/area/bluespaceriver
	name = "\improper Arctic Planet Surface"

// ______________________________________________________________

/obj/machinery/computer/shuttle_control/explore/

	var/landmarkx_off
	var/landmarky_off
	//Лучше способа не придумал, поэтому если check_zone шаттла захватывает территории, больше чем надо, то пихаем консоль этого шаттла, в список
	var/list/awayshuttles = list(
	/obj/machinery/computer/shuttle_control/explore/away_scg_patrol/reaper,
	/obj/machinery/computer/shuttle_control/explore/vox_lander,
	/obj/machinery/computer/shuttle_control/explore/skrellscoutshuttle,
	/obj/machinery/computer/shuttle_control/explore/away_farfleet/snz,
	/obj/machinery/computer/shuttle_control/explore/mule,
	/obj/machinery/computer/shuttle_control/explore/graysontug/hand_one,
	/obj/machinery/computer/shuttle_control/explore/pod_hand_one,
	/obj/machinery/computer/shuttle_control/explore/pod_hand_two,
	/obj/machinery/computer/shuttle_control/explore/graysontug/hand_two,
	/obj/machinery/computer/shuttle_control/explore/merc_shuttle,
	/obj/machinery/computer/shuttle_control/explore/merc_shuttle/merc_drop_pod,
	)

	//Списки куда разрешена посадка
	var/list/accesible_areas = list(
	/area/mine,
	/area/space,
	/area/exoplanet,
	/area/bluespaceriver,
	)

	var/list/shadow_images = list()
	var/list/saved_landmarks= list()


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
	var/area/area_oko = get_area(src)
	var/turf/origin = locate(src.x + x_offset, src.y + y_offset, src.z)
	var/turf/turf
	var/obj/shuttle_landmark/shuttle_landmark
	if(src.type in awayshuttles)
		turf = get_subarea_turfs(area_oko.type)
	else
		turf = get_subarea_turfs(area_oko.parent_type)

	if(area_oko in SSshuttle.shuttle_areas)
		for(var/shuttle_name in SSshuttle.shuttles)
			var/datum/shuttle/shuttle_datum = SSshuttle.shuttles[shuttle_name]
			if(area_oko in shuttle_datum.shuttle_area)
				for(var/turf/simulated/T in turf)
					var/image/I = image('mods/utility_items/icons/alphacolors.dmi', origin, "red")
					var/x_off = T.x - origin.x
					var/y_off = T.y - origin.y
					I.loc = locate(origin.x + x_off, origin.y + y_off, origin.z) //we have to set this after creating the image because it might be null, and images created in nullspace are immutable.
					I.layer = TURF_LAYER
					oko.placement_images[I] = list(x_off, y_off)
				shuttle_landmark = shuttle_datum.current_location
	if(shuttle_landmark)
		landmarkx_off = shuttle_landmark.x - origin.x
		landmarky_off = shuttle_landmark.y - origin.y

/obj/machinery/computer/shuttle_control/explore/proc/check_zone()
	shadow_images = list()
	var/turf/eyeturf = get_turf(oko)
	var/list/image_cache = oko.placement_images
	var/landable = TRUE
	for(var/i in 1 to LAZYLEN(image_cache))
		var/image/I = image_cache[i]
		var/list/coords = image_cache[I]
		var/turf/T = locate(eyeturf.x + coords[1], eyeturf.y + coords[2], eyeturf.z)
		var/area/A = get_area(T)
		var/zone_good = FALSE
		I.loc = T
		shadow_images += I
		if(T && !(T.density))
			for(var/type in accesible_areas)
				if(A.type in typesof(type))
					zone_good = TRUE
			if(zone_good)
				I.icon_state = "blue"
			else
				I.icon_state = "red"
		else
			I.icon_state = "red"
			landable = FALSE
	if(landable)
		return landable

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
	src.Destroy()
	SetName(initial(name))

/obj/shuttle_landmark
	var/list/image_shadow

/obj/shuttle_landmark/ship/advancedlandmark/Initialize(mapload, obj/shuttle_landmark/ship/master, _name)
	landmark_tag = "_[shuttle_name] [rand(1,99999)]"
	. = ..()

/mob/living/proc/spawn_landmark()
	set name = "Landing Spot"
	set category = "Ships Control"
	var/obj/shuttle_landmark/ship/advancedlandmark/landmark
	var/area/temp = get_area(eyeobj.owner)
	if(temp in SSshuttle.shuttle_areas)
		for(var/shuttle_name in SSshuttle.shuttles)
			var/datum/shuttle/shuttle_datum = SSshuttle.shuttles[shuttle_name]
			if(temp in shuttle_datum.shuttle_area)
				for(var/obj/machinery/computer/shuttle_control/explore/c in temp)
					for(var/obj/shuttle_landmark/ship/advancedlandmark/l in c.saved_landmarks)
						var/area/landmarkarea = get_area(l)
						if(landmarkarea in shuttle_datum.shuttle_area)
							continue
						else
							c.saved_landmarks -= l
							qdel(l)
					if(c.check_zone())
						var/turf/eyeturf = get_turf(c.oko)
						var/turf/T = locate(eyeturf.x + c.landmarkx_off, eyeturf.y + c.landmarky_off , eyeturf.z)
						landmark = new (T, src)
						c.saved_landmarks += landmark
						c.shuttle_type.set_destination(landmark)
						c.shuttle_type.next_location.image_shadow = c.shadow_images

/turf
	var/prev_type

/turf/ChangeTurf(turf/N, tell_universe = TRUE, force_lighting_update = FALSE, keep_air = FALSE)
	.=..()
	var/old_prev_type = prev_type
	prev_type = old_prev_type


/datum/shuttle/autodock/process_launch()
	.=..()
	for(var/i in 1 to LAZYLEN(next_location.image_shadow))
		var/image/I = next_location.image_shadow[i]
		var/turf/T = locate(I.loc.x, I.loc.y, I.loc.z)
		I = image('mods/utility_items/icons/alphacolors.dmi', T, "dither50")
		T.AddOverlays(I)
