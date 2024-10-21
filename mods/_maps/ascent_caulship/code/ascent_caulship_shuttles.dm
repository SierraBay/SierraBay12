/obj/overmap/visitable/ship/landable/ascent
	name = "Caulship"
	scannable = TRUE
	shuttle = "Ascent Caulship"
	desc = "Wake signature indicates a small unarmed vessel of unknown design."
	moving_state = "ship_moving"
	max_speed = 1/(2 SECONDS)
	burn_delay = 1 SECONDS
	vessel_mass = 5000
	skill_needed = SKILL_BASIC
	vessel_size = SHIP_SIZE_SMALL
	fore_dir = NORTH
	hide_from_reports = TRUE
	initial_restricted_waypoints = list(
		"Caulship Landing Zone" = list("nav_ascent_caulship_start"),
		"NSV Sierra Docking Port" = list("nav_ascent_caulship_sierra")
	)

/obj/machinery/computer/shuttle_control/explore/ascent
	name = "shuttle control console"
	shuttle_tag = "Ascent Caulship"
	icon_state = "ascent"
	icon_keyboard = "ascent_key"
	icon_screen = "ascent_screen"
	req_access = list(access_ascent)

/obj/shuttle_landmark/ascent_caulship
	name = "Caulship Landing Zone"
	landmark_tag = "nav_ascent_caulship_start"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/obj/shuttle_landmark/ascent_caulship/sierra
	name = "NSV Sierra Docking Port"
	landmark_tag = "nav_ascent_caulship_sierra"
	docking_controller = "admin_shuttle_dock"

/datum/shuttle/autodock/overmap/ascent
	name = "Ascent Caulship"
	warmup_time = 5
	range = 2
	shuttle_area = /area/ship/ascent_caulship
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_BASIC
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/ascent
	current_location = "nav_ascent_caulship_start"
