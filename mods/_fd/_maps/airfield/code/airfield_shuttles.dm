// STAR #1

/obj/overmap/visitable/ship/landable/airfield/star1
	name = "PM-55-L Star #1"
	shuttle = "PM-55-L Star #1"
	desc = "An small Sol fighter, designed for double-piloting, broadcasting SCGSV codes and the callsign \"Hitman #1\"."
	fore_dir = NORTH
	color = "#0751f3"
	icon_state = "sfv-star"
	moving_state = "sfv-star_moving"
	skill_needed = SKILL_TRAINED
	free_landing = FALSE
	vessel_mass = 3500
	vessel_size = SHIP_SIZE_SMALL
	max_speed = 0.5/(3 SECONDS)
	burn_delay = 0.5 SECONDS
	hide_from_reports = TRUE

/obj/machinery/computer/shuttle_control/explore/airfield/star1
	name = "landing control console"
	shuttle_tag = "PM-55-L Star #1"

/datum/shuttle/autodock/overmap/airfield1
	name = "PM-55-L Star #1"
	move_time = 20
	shuttle_area = list(/area/ship/airfield/star1)
	current_location = "nav_airfield_star_1"
	landmark_transition = "nav_transit_star_1"
	dock_target = "star_1_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/merc
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/area/ship/airfield/star1
	name = "\improper PM-55-L Star #1"

/obj/shuttle_landmark/airfield/star1
	name = "Star #1 Position"
	landmark_tag = "nav_airfield_star_1"
	docking_controller = "star_1_shuttle_dock_airlock"
	base_area = /area/ship/airfield/outdoors

/obj/shuttle_landmark/transit/airfield/star1
	name = "In transit"
	landmark_tag = "nav_transit_star_1"

// STAR #2

/obj/overmap/visitable/ship/landable/airfield/star2
	name = "PM-55-L Star #2"
	shuttle = "PM-55-L Star #2"
	desc = "An small Sol fighter, designed for double-piloting, broadcasting SCGSV codes and the callsign \"Hitman #2\"."
	fore_dir = NORTH
	color = "#0751f3"
	icon_state = "sfv-star"
	moving_state = "sfv-star_moving"
	skill_needed = SKILL_TRAINED
	vessel_mass = 3500
	vessel_size = SHIP_SIZE_SMALL
	free_landing = FALSE
	max_speed = 0.5/(3 SECONDS)
	burn_delay = 0.5 SECONDS
	hide_from_reports = TRUE

/obj/machinery/computer/shuttle_control/explore/airfield/star2
	name = "landing control console"
	shuttle_tag = "PM-55-L Star #2"

/datum/shuttle/autodock/overmap/airfield2
	name = "PM-55-L Star #2"
	move_time = 20
	shuttle_area = list(/area/ship/airfield/star2)
	current_location = "nav_airfield_star_2"
	landmark_transition = "nav_transit_star_2"
	dock_target = "star_2_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/merc
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/area/ship/airfield/star2
	name = "\improper PM-55-L Star #2"

/obj/shuttle_landmark/airfield/star2
	name = "Star #2 Position"
	landmark_tag = "nav_airfield_star_2"
	docking_controller = "star_2_shuttle_dock_airlock"
	base_area = /area/ship/airfield/outdoors

/obj/shuttle_landmark/transit/airfield/star2
	name = "In transit"
	landmark_tag = "nav_transit_star_2"

// STAR #3

/obj/overmap/visitable/ship/landable/airfield/star3
	name = "PM-55-L Star #3"
	shuttle = "PM-55-L Star #3"
	desc = "An small Sol fighter, designed for double-piloting, broadcasting SCGSV codes and the callsign \"Hitman #3\"."
	fore_dir = NORTH
	color = "#0751f3"
	icon_state = "sfv-star"
	moving_state = "sfv-star_moving"
	skill_needed = SKILL_TRAINED
	vessel_mass = 3500
	vessel_size = SHIP_SIZE_SMALL
	free_landing = FALSE
	max_speed = 0.5/(3 SECONDS)
	burn_delay = 0.5 SECONDS
	hide_from_reports = TRUE

/obj/machinery/computer/shuttle_control/explore/airfield/star3
	name = "landing control console"
	shuttle_tag = "PM-55-L Star #3"

/datum/shuttle/autodock/overmap/airfield3
	name = "PM-55-L Star #3"
	move_time = 20
	shuttle_area = list(/area/ship/airfield/star3)
	current_location = "nav_airfield_star_3"
	landmark_transition = "nav_transit_star_3"
	dock_target = "star_3_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/merc
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/area/ship/airfield/star3
	name = "\improper PM-55-L Star #3"

/obj/shuttle_landmark/airfield/star3
	name = "Star #3 Position"
	landmark_tag = "nav_airfield_star_3"
	docking_controller = "star_3_shuttle_dock_airlock"
	base_area = /area/ship/airfield/outdoors

/obj/shuttle_landmark/transit/airfield/star3
	name = "In transit"
	landmark_tag = "nav_transit_star_3"

// STAR #4

/obj/overmap/visitable/ship/landable/airfield/star4
	name = "PM-55-L Star #4"
	shuttle = "PM-55-L Star #4"
	desc = "An small Sol fighter, designed for double-piloting, broadcasting SCGSV codes and the callsign \"Hitman #4\"."
	fore_dir = NORTH
	color = "#0751f3"
	icon_state = "sfv-star"
	moving_state = "sfv-star_moving"
	skill_needed = SKILL_TRAINED
	vessel_mass = 3500
	vessel_size = SHIP_SIZE_SMALL
	free_landing = FALSE
	max_speed = 0.5/(3 SECONDS)
	burn_delay = 0.5 SECONDS
	hide_from_reports = TRUE

/obj/machinery/computer/shuttle_control/explore/airfield/star4
	name = "landing control console"
	shuttle_tag = "PM-55-L Star #4"

/datum/shuttle/autodock/overmap/airfield4
	name = "PM-55-L Star #4"
	move_time = 20
	shuttle_area = list(/area/ship/airfield/star4)
	current_location = "nav_airfield_star_4"
	landmark_transition = "nav_transit_star_4"
	dock_target = "star_4_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/merc
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/area/ship/airfield/star4
	name = "\improper PM-55-L Star #4"

/obj/shuttle_landmark/airfield/star4
	name = "Star #4 Position"
	landmark_tag = "nav_airfield_star_4"
	docking_controller = "star_4_shuttle_dock_airlock"
	base_area = /area/ship/airfield/outdoors

/obj/shuttle_landmark/transit/airfield/star4
	name = "In transit"
	landmark_tag = "nav_transit_star_4"

// BULL #1

/obj/overmap/visitable/ship/landable/airfield/bull1
	name = "PM-08 Bull #1"
	shuttle = "PM-08 Bull #1"
	desc = "Sol light-weighted interceptor, designed to take down enemy rockets and heavy armored ships, broadcasting SCGSV codes and the callsign \"Diplomat #1\"."
	fore_dir = NORTH
	color = "#0751f3"
	icon_state = "sfv-bull"
	moving_state = "sfv-bull_moving"
	skill_needed = SKILL_BASIC
	vessel_mass = 4500
	vessel_size = SHIP_SIZE_SMALL
	free_landing = FALSE
	max_speed = 1/(2 SECONDS) //same stats as charon
	burn_delay = 2 SECONDS
	hide_from_reports = TRUE

/obj/machinery/computer/shuttle_control/explore/airfield/bull1
	name = "landing control console"
	shuttle_tag = "PM-08 Bull #1"

/datum/shuttle/autodock/overmap/airfield5
	name = "PM-08 Bull #1"
	move_time = 20
	shuttle_area = list(/area/ship/airfield/bull1)
	current_location = "nav_airfield_bull_1"
	landmark_transition = "nav_transit_bull_1"
	dock_target = "bull_1_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/merc
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/area/ship/airfield/bull1
	name = "\improper PM-08 Bull #1"

/obj/shuttle_landmark/airfield/bull1
	name = "Bull #1 Position"
	landmark_tag = "nav_airfield_bull_1"
	docking_controller = "bull_1_shuttle_dock_airlock"
	base_area = /area/ship/airfield/outdoors

/obj/shuttle_landmark/transit/airfield/bull1
	name = "In transit"
	landmark_tag = "nav_transit_bull_1"

// BULL #2

/obj/overmap/visitable/ship/landable/airfield/bull2
	name = "PM-08 Bull #2"
	shuttle = "PM-08 Bull #2"
	desc = "Sol light-weighted interceptor, designed to take down enemy rockets and heavy armored ships, broadcasting SCGSV codes and the callsign \"Diplomat #2\"."
	fore_dir = NORTH
	color = "#0751f3"
	icon_state = "sfv-bull"
	moving_state = "sfv-bull_moving"
	skill_needed = SKILL_BASIC
	vessel_mass = 4500
	vessel_size = SHIP_SIZE_SMALL
	free_landing = FALSE
	max_speed = 1/(2 SECONDS) //same stats as charon
	burn_delay = 2 SECONDS
	hide_from_reports = TRUE

/obj/machinery/computer/shuttle_control/explore/airfield/bull2
	name = "landing control console"
	shuttle_tag = "PM-08 Bull #2"

/datum/shuttle/autodock/overmap/airfield6
	name = "PM-08 Bull #2"
	move_time = 20
	shuttle_area = list(/area/ship/airfield/bull2)
	current_location = "nav_airfield_bull_2"
	landmark_transition = "nav_transit_bull_2"
	dock_target = "bull_2_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/merc
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/area/ship/airfield/bull2
	name = "\improper PM-08 Bull #2"

/obj/shuttle_landmark/airfield/bull2
	name = "Bull #2 Position"
	landmark_tag = "nav_airfield_bull_2"
	docking_controller = "bull_2_shuttle_dock_airlock"
	base_area = /area/ship/airfield/outdoors

/obj/shuttle_landmark/transit/airfield/bull2
	name = "In transit"
	landmark_tag = "nav_transit_bull_2"

// NIGHTBAT #1

/obj/overmap/visitable/ship/landable/airfield/nightbat1
	name = "PM-15 Nightbat #1"
	shuttle = "PM-15 Nightbat #1"
	desc = "An small Sol EW-Craft, designed for disrupting work of enemy systems, broadcasting SCGSV codes and the callsign \"Mosquito #1\"."
	fore_dir = NORTH
	color = "#0751f3"
	skill_needed = SKILL_TRAINED
	vessel_mass = 3500
	vessel_size = SHIP_SIZE_SMALL
	free_landing = FALSE
	max_speed = 0.4/(2 SECONDS)
	burn_delay = 0.3 SECONDS
	hide_from_reports = TRUE

/obj/machinery/computer/shuttle_control/explore/airfield/nightbat1
	name = "landing control console"
	shuttle_tag = "PM-15 Nightbat #1"

/datum/shuttle/autodock/overmap/airfield7
	name = "PM-15 Nightbat #1"
	move_time = 20
	shuttle_area = list(/area/ship/airfield/nightbat1)
	current_location = "nav_airfield_nightbat_1"
	landmark_transition = "nav_transit_nightbat_1"
	dock_target = "nightbat_1_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/merc
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/area/ship/airfield/nightbat1
	name = "\improper PM-15 Nightbat #1"

/obj/shuttle_landmark/airfield/nightbat1
	name = "Nightbat #1 Position"
	landmark_tag = "nav_airfield_nightbat_1"
	docking_controller = "nightbat_1_shuttle_dock_airlock"
	base_area = /area/ship/airfield/outdoors

/obj/shuttle_landmark/transit/airfield/nightbat1
	name = "In transit"
	landmark_tag = "nav_transit_nightbat_1"

// NIGHTBAT #2

/obj/overmap/visitable/ship/landable/airfield/nightbat2
	name = "PM-15 Nightbat #2"
	shuttle = "PM-15 Nightbat #2"
	desc = "An small Sol EW-Craft, designed for disrupting work of enemy systems, broadcasting SCGSV codes and the callsign \"Mosquito #2\"."
	fore_dir = NORTH
	color = "#0751f3"
	skill_needed = SKILL_TRAINED
	vessel_mass = 3500
	vessel_size = SHIP_SIZE_SMALL
	free_landing = FALSE
	max_speed = 0.4/(2 SECONDS)
	burn_delay = 0.3 SECONDS
	hide_from_reports = TRUE

/obj/machinery/computer/shuttle_control/explore/airfield/nightbat2
	name = "landing control console"
	shuttle_tag = "PM-15 Nightbat #2"

/datum/shuttle/autodock/overmap/airfield8
	name = "PM-15 Nightbat #2"
	move_time = 20
	shuttle_area = list(/area/ship/airfield/nightbat2)
	current_location = "nav_airfield_nightbat_2"
	landmark_transition = "nav_transit_nightbat_2"
	dock_target = "nightbat_2_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/merc
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/area/ship/airfield/nightbat2
	name = "\improper PM-15 Nightbat #2"

/obj/shuttle_landmark/airfield/nightbat2
	name = "Nightbat #2 Position"
	landmark_tag = "nav_airfield_nightbat_2"
	docking_controller = "nightbat_2_shuttle_dock_airlock"
	base_area = /area/ship/airfield/outdoors

/obj/shuttle_landmark/transit/airfield/nightbat2
	name = "In transit"
	landmark_tag = "nav_transit_nightbat_2"

// SPEAR #1

/obj/overmap/visitable/ship/landable/airfield/spear1
	name = "PM-57 Spear #1"
	shuttle = "PM-57 Spear #1"
	desc = "An small Sol fighter, designed for close-space combat and armed with massive boarding harpoon, broadcasting SCGSV codes and the callsign \"Wasp #1\"."
	fore_dir = NORTH
	color = "#0751f3"
	icon_state = "sfv-spear"
	moving_state = "sfv-spear_moving"
	skill_needed = SKILL_BASIC
	vessel_mass = 3500
	vessel_size = SHIP_SIZE_SMALL
	free_landing = FALSE
	max_speed = 0.4/(4 SECONDS)
	burn_delay = 0.5 SECONDS
	hide_from_reports = TRUE

/obj/machinery/computer/shuttle_control/explore/airfield/spear1
	name = "landing control console"
	shuttle_tag = "PM-57 Spear #1"

/datum/shuttle/autodock/overmap/airfield9
	name = "PM-57 Spear #1"
	move_time = 20
	shuttle_area = list(/area/ship/airfield/spear1)
	current_location = "nav_airfield_spear_1"
	landmark_transition = "nav_transit_spear_1"
	dock_target = "spear_1_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/merc
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/area/ship/airfield/spear1
	name = "\improper PM-57 Spear #1"

/obj/shuttle_landmark/airfield/spear1
	name = "Spear #1 Position"
	landmark_tag = "nav_airfield_spear_1"
	docking_controller = "spear_1_shuttle_dock_airlock"
	base_area = /area/ship/airfield/outdoors

/obj/shuttle_landmark/transit/airfield/spear1
	name = "In transit"
	landmark_tag = "nav_transit_spear_1"

// SPEAR #2

/obj/overmap/visitable/ship/landable/airfield/spear2
	name = "PM-57 Spear #2"
	shuttle = "PM-57 Spear #2"
	desc = "An small Sol fighter, designed for close-space combat and armed with massive boarding harpoon, broadcasting SCGSV codes and the callsign \"Wasp #2\"."
	fore_dir = NORTH
	color = "#0751f3"
	icon_state = "sfv-spear"
	moving_state = "sfv-spear_moving"
	skill_needed = SKILL_BASIC
	vessel_mass = 3500
	vessel_size = SHIP_SIZE_SMALL
	free_landing = FALSE
	max_speed = 0.4/(4 SECONDS)
	burn_delay = 0.5 SECONDS
	hide_from_reports = TRUE

/obj/machinery/computer/shuttle_control/explore/airfield/spear2
	name = "landing control console"
	shuttle_tag = "PM-57 Spear #2"

/datum/shuttle/autodock/overmap/airfield10
	name = "PM-57 Spear #2"
	move_time = 20
	shuttle_area = list(/area/ship/airfield/spear2)
	current_location = "nav_airfield_spear_2"
	landmark_transition = "nav_transit_spear_2"
	dock_target = "spear_2_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/merc
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/area/ship/airfield/spear2
	name = "\improper PM-57 Spear #2"

/obj/shuttle_landmark/airfield/spear2
	name = "Spear #2 Position"
	landmark_tag = "nav_airfield_spear_2"
	docking_controller = "spear_2_shuttle_dock_airlock"
	base_area = /area/ship/airfield/outdoors

/obj/shuttle_landmark/transit/airfield/spear2
	name = "In transit"
	landmark_tag = "nav_transit_spear_2"

// SCARAB

/obj/overmap/visitable/ship/landable/airfield/scarab
	name = "PM-100 Scarab"
	shuttle = "PM-100 Scarab"
	desc = "An small Sol fighter, designed for close-space combat and armed with massive boarding harpoon, broadcasting SCGSV codes and the callsign \"Monarch\"."
	fore_dir = NORTH
	color = "#0751f3"
	skill_needed = SKILL_BASIC
	vessel_mass = 4000
	vessel_size = SHIP_SIZE_SMALL
	free_landing = FALSE
	max_speed = 1/(4 SECONDS)
	burn_delay = 0.3 SECONDS
	hide_from_reports = TRUE

/obj/machinery/computer/shuttle_control/explore/airfield/scarab
	name = "landing control console"
	shuttle_tag = "PM-100 Scarab"

/datum/shuttle/autodock/overmap/airfield11
	name = "PM-100 Scarab"
	move_time = 20
	shuttle_area = list(/area/ship/airfield/scarab)
	current_location = "nav_airfield_scarab"
	landmark_transition = "nav_transit_scarab"
	dock_target = "scarab_shuttle_dock_airlock"
	range = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/merc
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/area/ship/airfield/scarab
	name = "\improper PM-100 Scarab"

/obj/shuttle_landmark/airfield/scarab
	name = "Scarab Hangar"
	landmark_tag = "nav_airfield_scarab"
	docking_controller = "scarab_shuttle_dock_airlock"
	base_area = /area/ship/airfield/scarab_hangar

/obj/shuttle_landmark/transit/airfield/scarab
	name = "In transit"
	landmark_tag = "nav_transit_scarab"
