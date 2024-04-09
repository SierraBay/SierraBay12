/obj/overmap/visitable/ship/landable/providence
	name = "IPV Providence"
	shuttle = "Providence"
	desc = "Sensor array is detecting a small cargo vessel, broadcasting registration codes \"IPV-3466-L-112\"."
	max_speed = 1/(2 SECONDS)
	burn_delay = 1 SECONDS
	vessel_mass = 9000
	skill_needed = SKILL_TRAINED
	vessel_size = SHIP_SIZE_SMALL
	fore_dir = NORTH
	dir = NORTH
	hide_from_reports = TRUE
	initial_restricted_waypoints = list(
		"Bluespace Residue" = list("nav_providence")
	)

/obj/machinery/computer/shuttle_control/explore/providence
	name = "vessel control console"
	shuttle_tag = "Providence"

/obj/shuttle_landmark/providence
	name = "Providence Landing Zone"
	landmark_tag = "nav_providence"
	docking_controller = "providence_dock"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/datum/shuttle/autodock/overmap/providence
	name = "Providence"
	warmup_time = 3
	range = 1
	shuttle_area = list(/area/ship/providence/corridor,/area/ship/providence/living,/area/ship/providence/engineering,/area/ship/providence/engine_one,/area/ship/providence/engine_two,/area/ship/providence/outer)
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_BASIC
	ceiling_type = /turf/simulated/floor/shuttle_ceiling
	current_location = "nav_providence"
