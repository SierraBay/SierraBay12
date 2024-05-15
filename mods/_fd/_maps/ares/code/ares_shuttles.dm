/obj/overmap/visitable/ship/landable/ares
	name = "GMMV Ares"
	shuttle = "Ares"
	desc = "Sensor array is detecting a small mining vessel, property of Grayson Manufactories Ltd, broadcasting registration codes \"GMMV-3274-L-228\"."
	max_speed = 1/(2 SECONDS)
	burn_delay = 1 SECONDS
	vessel_mass = 5000
	skill_needed = SKILL_BASIC
	vessel_size = SHIP_SIZE_SMALL
	fore_dir = EAST
	dir = EAST
	color = "#6e0000"
	hide_from_reports = TRUE
	initial_restricted_waypoints = list(
		"Bluespace Residue" = list("nav_ares")
	)

/obj/machinery/computer/shuttle_control/explore/ares
	name = "vessel control console"
	req_access = list(access_ares)
	shuttle_tag = "Ares"

/obj/shuttle_landmark/ares
	name = "Ares Landing Zone"
	landmark_tag = "nav_ares"
	docking_controller = "ares_dock"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/datum/shuttle/autodock/overmap/ares
	name = "Ares"
	range = 1
	shuttle_area = list(/area/ship/ares/bridge, /area/ship/ares/interior, /area/ship/ares/kitchen, /area/ship/ares/bar, /area/ship/ares/mess_hall, /area/ship/ares/eng, /area/ship/ares/cargo, /area/ship/ares/mining, /area/ship/ares/janitor)
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_BASIC
	ceiling_type = /turf/simulated/floor/shuttle_ceiling
	current_location = "nav_ares"
