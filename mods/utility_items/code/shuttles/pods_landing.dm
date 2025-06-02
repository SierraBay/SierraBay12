
/proc/get_turf_target_explosive(turf/src_origin, turf/dst_origin, list/turfs_src)
	RETURN_TYPE(/list)
	var/list/target_explosive = list()
	for(var/turf/source in turfs_src)
		var/x_pos = (source.x - src_origin.x)
		var/y_pos = (source.y - src_origin.y)
		var/z_pos = (source.z - src_origin.z)

		var/turf/target = locate(dst_origin.x + x_pos, dst_origin.y + y_pos, dst_origin.z + z_pos)
		if(!target)
			error("Null turf in translation @ ([dst_origin.x + x_pos], [dst_origin.y + y_pos], [dst_origin.z + z_pos])")
		if(target.density)
			target_explosive[target] = target
	return target_explosive

/////////////////////////COMPONENT////////////////////////////
#define COMSIG_POD_LANDED "landed"

/obj/shuttle_landmark/
	var/list/explosion_locations = list()

/obj/shuttle_landmark/Initialize()
	.=..()
	AddComponent(/datum/component/landing, explosion_locations)

/datum/component/landing

/datum/component/landing/RegisterWithParent()
	RegisterSignal(parent, COMSIG_POD_LANDED, .proc/explosion_on_collision)

/datum/component/landing/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_POD_LANDED))
	return ..()

/datum/component/landing/proc/explosion_on_collision(obj/source, list/turfs)
	SIGNAL_HANDLER
	for(var/A in turfs)
		var/turf/T = get_turf(A)
		if(istype(T, /turf/simulated/wall))
			if(prob(70))
				T.damage_health(rand(100, 300), DAMAGE_BRUTE) // 70% chance to damage wall on collision
		if(prob(40)) // 40% chance to explode
			explosion(T, rand(1, 4))


///////////////////////////////////////////////////////

/obj/shuttle_landmark/escape_pod/out
	name = "Escape Pod Landing Site"
	base_turf = /turf/simulated/floor/plating


/obj/shuttle_landmark/escape_pod/out/New()
	.=..()
	landmark_tag = "Nav_[name] - [rand(1, 1000)]"


//////////////////////////ESCAPE POD////////////////////////////

/obj/shuttle_landmark/is_valid(datum/shuttle/shuttle)
	explosion_locations = list()
	if(shuttle.current_location == src)
		return FALSE
	for(var/area/A in shuttle.shuttle_area)
		var/list/translation = get_turf_translation(get_turf(shuttle.current_location), get_turf(src), A.contents)
		if(ispath(A.type, /area/shuttle/escape_pod))
			var/list/turfs_explosive = get_turf_target_explosive(get_turf(shuttle.current_location), get_turf(src), A.contents)
			if(LAZYLEN(turfs_explosive))
				explosion_locations += turfs_explosive
			continue /// IF its an escape pod area, we don't need to check for collisions
		if(check_collision(base_area, list_values(translation)))
			return FALSE
	var/conn = GetConnectedZlevels(z)
	for(var/w in (z - shuttle.multiz) to z)
		if(!(w in conn))
			return FALSE
	return TRUE

/datum/shuttle/autodock/ferry
	var/obj/shuttle_landmark/escape_pod/out/escape_pod_landmark

/datum/shuttle/autodock/ferry/escape_pod
	var/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod/pod_controller
	var/destination_chosen

/datum/shuttle/autodock/ferry/escape_pod/New()
	.=..()
	var/datum/computer/file/embedded_program/docking/simple/prog = SSshuttle.docking_registry[dock_target]
	pod_controller = prog.master


/datum/shuttle/autodock/ferry/escape_pod/proc/get_possible_destination()
	if(destination_chosen)
		return
	if(current_location != waypoint_station)
		return
	var/list/possible_visits
	var/obj/overmap/visitable/we = map_sectors["[pod_controller.z]"]
	if(!we)
		CRASH("Escape pod [name] could not find it's overmap sector!")
	for(var/obj/overmap/visitable/visit in oview(we, 8))
		if(visit == we)
			continue
		if(visit.map_z != we.map_z)
			if(visit.map_z in possible_visits)
				continue
			possible_visits += visit.map_z
	var/x_destination = pick(rand(50, 150))
	var/y_destination = pick(rand(50, 150))
	var/obj/overmap/visitable/z = pick(possible_visits)
	var/turf/mark = locate(x_destination, y_destination, z)
	if(mark)
		escape_pod_landmark = new (mark, src)
		escape_pod_landmark.landmark_tag = "nav_[name] - site"
		next_location = escape_pod_landmark
	if(!mark)
		next_location = waypoint_offsite

/obj/shuttle_landmark/shuttle_arrived(datum/shuttle/shuttle)
	if(istype(shuttle, /datum/shuttle/autodock/ferry/escape_pod))
		var/datum/shuttle/autodock/ferry/escape_pod/pod = shuttle
		if(explosion_locations)
			if(shuttle.current_location == pod.escape_pod_landmark)
				SEND_SIGNAL(src, COMSIG_POD_LANDED, explosion_locations)
	return



/obj/machinery/pod_set_destination
	name = "Escape Pod Navigation Computer"
	desc = "A computer terminal used to set the destination of the escape pod."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "tele_nav"
	density = FALSE
	anchored = TRUE
	construct_state = /singleton/machine_construction/default/panel_closed

	var/list/possible_visits
	var/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod/linked

/obj/machinery/pod_set_destination/New()
	.=..()
	if(!linked)
		for(var/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod/A in range(2, src))
			linked = A
			break

/obj/machinery/pod_set_destination/Destroy()
	if (linked)
		linked = null
	. = ..()

/obj/machinery/pod_set_destination/Click()
	. = ..()
	if(!linked)
		for(var/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod/A in range(2, src))
			linked = A
		if(!linked)
			to_chat(usr, SPAN_WARNING("No escape pod controller found nearby."))
			return
	else
		get_possible_destinations()

/obj/machinery/pod_set_destination/proc/get_possible_destinations()
	if(linked.pod.current_location != linked.pod.waypoint_station)
		state("Pod is not docked, cannot set destination.")
		return
	possible_visits = list()
	var/obj/overmap/visitable/destination_pod
	var/obj/overmap/visitable/we = map_sectors["[src.z]"]
	if(!we)
		CRASH("Escape pod [name] could not find it's overmap sector!")
	for(var/obj/overmap/visitable/visit in oview(we, 8))
		if(visit == we)
			continue
		if(visit.map_z != we.map_z)
			if(visit.map_z in possible_visits)
				continue
			possible_visits += visit
	if(length(possible_visits))
		destination_pod = input("Choose pod destination", "Pod Destination") as null|anything in possible_visits
	else
		linked.pod.next_location = linked.pod.waypoint_offsite
		state("Pod destination set to outer space.")
		return
	var/x_destination = pick(rand(40, 160))
	var/y_destination = pick(rand(40, 160))
	var/z_destination = pick(destination_pod.map_z)
	var/turf/mark = locate(x_destination, y_destination, z_destination)
	if(mark)
		linked.pod.escape_pod_landmark = new (mark, src)
		linked.pod.next_location = linked.pod.escape_pod_landmark
		linked.pod.destination_chosen = TRUE
		state("Pod destination set to [destination_pod.name].")

/obj/item/stock_parts/circuitboard/pod_set_destination
	name = "circuit board (pod destination)"
	board_type = "machine"
	build_path = /obj/machinery/pod_set_destination
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 1)

/datum/design/circuit/pod_set_destination
	name = "pod destination"
	id = "pod_set_destination"
	req_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	build_path = /obj/item/stock_parts/circuitboard/pod_set_destination
	sort_string = "WAAZZ"



/datum/evacuation_controller/starship/fast/finish_preparing_evac()
	. = ..()
	for (var/datum/shuttle/autodock/ferry/escape_pod/pod in escape_pods)
		if (pod.arming_controller)
			pod.arming_controller.arm()
			pod.get_possible_destination()
