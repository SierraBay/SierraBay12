/datum/shuttle/autodock/overmap/petrov
	name = "Petrov"
	dock_target = "petrov_shuttle"
	current_location = "nav_petrov_start"
	landmark_transition = "nav_transit_scavshuttle"
	logging_home_tag = "nav_petrov_start"
	sound_takeoff = 'sound/effects/rocket.ogg'
	sound_landing = 'sound/effects/rocket_backwards.ogg'
	range = 1
	fuel_consumption = 6
	warmup_time = 10
	ceiling_type = /turf/simulated/floor/shuttle_ceiling
	shuttle_area = list(/area/shuttle/petrov/airlock,
	/area/shuttle/petrov/cockpit,
	/area/shuttle/petrov/ship,
	/area/shuttle/petrov/test_room,
	/area/shuttle/petrov/cell1,
	/area/shuttle/petrov/cell2,
	/area/shuttle/petrov/cell3,
	/area/shuttle/petrov/gas,
	/area/shuttle/petrov/equipment,
	/area/shuttle/petrov/eva,
	/area/shuttle/petrov/security,
	/area/shuttle/petrov/scan
	)


/obj/machinery/computer/shuttle_control/explore/petrov
	name = "Petrov control console"
	shuttle_tag = "Petrov"

/obj/overmap/visitable/ship/landable/petrov
	name = "Petrov"
	shuttle = "Petrov"
	desc = "A small, unmarked vessel."
	fore_dir = WEST
	vessel_size = SHIP_SIZE_SMALL
	vessel_mass = 9000

/obj/shuttle_landmark/sierra/petrov/start
	name = "First Deck"
	landmark_tag = "nav_petrov_start"
	docking_controller = "petrov_shuttle_dock_airlock"

/obj/machinery/computer/shuttle_control/explore/petrov
	skill_req = SKILL_BASIC
