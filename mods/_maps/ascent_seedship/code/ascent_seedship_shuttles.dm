// Submap shuttles.
// Trichopterax - Shuttle One, Port Side
// Lepidopterax - Shuttle Two, Starboard Side

/// Trichopterax

/obj/overmap/visitable/ship/landable/ascent_tricho
	shuttle = "Trichopterax"
	name = "Trichopterax"
	desc = "Signature indicates a small shuttle of unknown design."
	color = COLOR_PURPLE
	max_speed = 1/(2 SECONDS)
	burn_delay = 1 SECONDS
	vessel_mass = 5000
	fore_dir = SOUTH
	skill_needed = SKILL_BASIC
	vessel_size = SHIP_SIZE_SMALL

/obj/machinery/computer/shuttle_control/explore/ascent_tricho
	name = "shuttle control console"
	shuttle_tag = "Trichopterax"
	icon_state = "ascent"
	icon_keyboard = "ascent_key"
	icon_screen = "ascent_screen"
	req_access = list(access_ascent)

/obj/shuttle_landmark/ascent_tricho/start
	name = "Trichopterax Docked"
	landmark_tag = "nav_ascent_tricho_start"
	docking_controller = "ascent_inf_port_dock"

/datum/shuttle/autodock/overmap/ascent_tricho
	name = "Trichopterax"
	warmup_time = 5
	current_location = "nav_ascent_tricho_start"
	range = 2
	dock_target = "ascent_inf_port_shuttle_dock"
	shuttle_area = list(/area/ship/ascent_inf/shuttle_port)
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_BASIC
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/ascent

/// Lepidopterax

/obj/overmap/visitable/ship/landable/ascent_lepido
	shuttle = "Lepidopterax"
	name = "Lepidopterax"
	desc = "Signature indicates a small shuttle of unknown design."
	color = COLOR_PURPLE
	max_speed = 1/(2 SECONDS)
	burn_delay = 1 SECONDS
	vessel_mass = 5000
	fore_dir = NORTH
	skill_needed = SKILL_BASIC
	vessel_size = SHIP_SIZE_SMALL

/obj/machinery/computer/shuttle_control/explore/ascent_lepido
	name = "shuttle control console"
	shuttle_tag = "Lepidopterax"
	icon_state = "ascent"
	icon_keyboard = "ascent_key"
	icon_screen = "ascent_screen"
	req_access = list(access_ascent)

/obj/shuttle_landmark/ascent_lepido/start
	name = "Lepidopterax Docked"
	landmark_tag = "nav_ascent_lepido_start"
	docking_controller = "ascent_inf_starboard_dock"

/datum/shuttle/autodock/overmap/ascent_lepido
	name = "Lepidopterax"
	warmup_time = 5
	current_location = "nav_ascent_lepido_start"
	range = 2
	dock_target = "ascent_inf_starboard"
	shuttle_area = (/area/ship/ascent_inf/shuttle_starboard)
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_BASIC
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/ascent

/// Other Landmarks

/obj/shuttle_landmark/ascent_tricho/sierra
	name = "Dock PRSD-3"
	landmark_tag = "nav_ascent_tricho_sierra"
	docking_controller = "rescue_shuttle_dock_airlock"

/obj/shuttle_landmark/ascent_lepido/sierra
	name = "Dock STBD-1"
	landmark_tag = "nav_ascent_lepido_sierra"
	docking_controller = "merchant_shuttle_station"
