// HAND TODO BELOW

/datum/shuttle/autodock/overmap/graysontug/hand_one
	name = "GM Tug"
	dock_target = "graysontug_shuttle"
	current_location = "nav_graysontug_start"
	range = 1
	shuttle_area = /area/map_template/crashed_shuttle/graysontug
	fuel_consumption = 4
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_MIN
	ceiling_type = /turf/simulated/floor/shuttle_ceiling

/obj/machinery/computer/shuttle_control/explore/graysontug
	name = "GM Tug Shuttle control console"
	shuttle_tag = "GM Tug"

/obj/overmap/visitable/ship/landable/graysontug
	name = "GM Tug"
	desc = "Grayson Manufactories Tug. Space truckin commonly seen across Frontier."
	shuttle = "GM Tug"
	fore_dir = NORTH
	color = "#e6f7ff"
	vessel_mass = 2500
	vessel_size = SHIP_SIZE_TINY

/obj/shuttle_landmark/graysontug/start
	name = "Crash Zone"
	landmark_tag = "nav_graysontug_start"
	base_area = /area/map_template/crashed_shuttle/crash
	base_turf = /turf/simulated/floor/exoplanet/barren
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/area/ship/
	name = "\improper Reaper"
	icon_state = "shuttlered"
	base_turf = /turf/simulated/floor
	requires_power = 1
	dynamic_lighting = 1
	area_flags = AREA_FLAG_RAD_SHIELDED

/obj/shuttle_landmark/handtugone/start
	name = "Port Tug Dock"
	landmark_tag = "nav_handtugone_start"
	docking_controller = "handtugone_port_dock"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/obj/shuttle_landmark/handtugtwo/start
	name = "Starboard Tug Dock"
	landmark_tag = "nav_handtugtwo_start"
	docking_controller = "handtugtwo_port_dock"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE
