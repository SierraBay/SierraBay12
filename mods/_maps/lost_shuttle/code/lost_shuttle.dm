/datum/map_template/ruin/exoplanet/lost_shuttle/scg
	name = "Lost shuttle"
	id = "lost_shuttle"
	description = "Lost corporate shuttle."
	suffixes = list("lost_shuttle/lost_shuttle.dmm")
	spawn_cost = 100
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/lost_shuttle/scg)
	apc_test_exempt_areas = list(/area/map_template/lost_shuttle/scg/crash = NO_SCRUBBER|NO_VENT|NO_APC)
	ruin_tags = RUIN_HUMAN|RUIN_WRECK
	template_flags = TEMPLATE_FLAG_CLEAR_CONTENTS | TEMPLATE_FLAG_NO_RUINS

	skip_main_unit_tests = "Ruin has shuttle landmark."

/area/map_template/lost_shuttle/scg
	name = "\improper SCG EV Sunset"
	icon_state = "shuttlegrn"
	requires_power = 1
	dynamic_lighting = 1
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED

/area/map_template/lost_shuttle/scg/crash
	name = "\improper Crash zone"
	icon_state = "shuttle2"
	area_flags = AREA_FLAG_EXTERNAL

/area/map_template/lost_shuttle/scg/cockpit
	name = "Shuttle - Sunset - Cockpit"

/area/map_template/lost_shuttle/scg/power
	name = "Shuttle - Sunset - Maintenance Chamber"

/area/map_template/lost_shuttle/scg/medical
	name = "Shuttle - Sunset - Medical Chamber"

/area/map_template/lost_shuttle/scg/equipment
	name = "Shuttle - Sunset - Equipment Chamber"

/area/map_template/lost_shuttle/scg/coridor
	name = "Shuttle - Sunset - Coridor"

/datum/shuttle/autodock/overmap/lost_shuttle/scg
	name = "SCG EV Sunset"
	dock_target = "scgevsunset_shuttle"
	current_location = "nav_scgevsunset_start"
	range = 1
	shuttle_area = /area/map_template/lost_shuttle/scg
	fuel_consumption = 4
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_MIN
	ceiling_type = /turf/simulated/floor/shuttle_ceiling

/obj/machinery/computer/shuttle_control/explore/lost_shuttle/scg
	name = "SCG EV Sunset Shuttle control console"
	shuttle_tag = "SCG EV Sunset"

/obj/overmap/visitable/ship/landable/lost_shuttle/scg
	name = "SCG EV Sunset"
	desc = "Sol Central Goverment Exploration Vessel Sunset."
	shuttle = "SCG EV Sunset"
	fore_dir = NORTH
	color = "#e6f7ff"
	vessel_mass = 3000
	vessel_size = SHIP_SIZE_TINY

/obj/shuttle_landmark/lost_shuttle/scg/start
	name = "Shuttle Zone"
	landmark_tag = "nav_scgevsunset_start"
	base_area = /area/map_template/lost_shuttle/scg/crash
	base_turf = /turf/simulated/floor/exoplanet/barren
	movable_flags = MOVABLE_FLAG_EFFECTMOVE
