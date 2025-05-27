
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
	for(var/turf/T in turfs)
		if(prob(50)) // 50% chance to explode
			explosion(T, rand(8, 16))

///////////////////////////////////////////////////////
/area/shuttle/escape_pod
	name = "Escape Pod"

/obj/shuttle_landmark/escape_pod/out
	name = "Escape Pod Landing Site"


//////////////////////////ESCAPE POD////////////////////////////

/obj/shuttle_landmark/is_valid(datum/shuttle/shuttle)
	if(shuttle.current_location == src)
		return FALSE
	for(var/area/A in shuttle.shuttle_area)
		var/list/translation = get_turf_translation(get_turf(shuttle.current_location), get_turf(src), A.contents)
		if(ispath(A.type, /area/shuttle/escape_pod))
			for(var/target_turf in translation)
				var/turf/target = target_turf
				if(target.density)
					var/turf/locsforexplosion = target
					explosion_locations += locsforexplosion
			continue // escape pods are allowed to land anywhere
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
	move_time = 30 SECONDS
	var/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod/pod_controller

/datum/shuttle/autodock/ferry/escape_pod/New()
	.=..()
	var/datum/computer/file/embedded_program/docking/simple/prog = SSshuttle.docking_registry[dock_target]
	pod_controller = prog.master

/datum/shuttle/autodock/ferry/escape_pod/proc/get_possible_destination()
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

/obj/shuttle_landmark/shuttle_arrived(datum/shuttle/shuttle)
	if(istype(shuttle, /datum/shuttle/autodock/ferry/escape_pod))
		var/datum/shuttle/autodock/ferry/escape_pod/pod = shuttle
		if(explosion_locations)
			if(shuttle.current_location == pod.waypoint_offsite)
				SEND_SIGNAL(src, COMSIG_POD_LANDED, explosion_locations)
	return
