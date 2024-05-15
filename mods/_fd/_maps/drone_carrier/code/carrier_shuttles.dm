// GUP #1

/obj/overmap/visitable/ship/landable/carrier/gup1
	name = "FTU-SV GUP #1"
	shuttle = "FTU-SV GUP #1"
	desc = "An SSE-U20 long range shuttle, broadcasting FTUSV codes and the callsign \"FTU-SV GUP #1\"."
	fore_dir = NORTH
	max_speed = 1/(2 SECONDS) //same stats as charon
	burn_delay = 1 SECONDS
	vessel_mass = 5000
	skill_needed = SKILL_BASIC
	free_landing = FALSE

/obj/machinery/computer/shuttle_control/explore/carrier/gup1
	name = "landing control console"
	shuttle_tag = "FTU-SV GUP #1"

/datum/shuttle/autodock/overmap/carrier1
	name = "FTU-SV GUP #1"
	move_time = 20
	shuttle_area = list(/area/ship/carrier/deck2/gup1)
	current_location = "nav_hangar_carrier_1"
	landmark_transition = "nav_transit_carrier_1"
	dock_target = "carrier_1_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/heist
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/obj/shuttle_landmark/carrier/gup1
	name = "GUP #1 Hangar"
	landmark_tag = "nav_hangar_carrier_1"
	docking_controller = "carrier_1_shuttle_dock_airlock"
	base_area = /area/ship/carrier/deck2/living1

/obj/shuttle_landmark/transit/carrier/gup1
	name = "In transit"
	landmark_tag = "nav_transit_carrier_1"

// GUP #2

/obj/overmap/visitable/ship/landable/carrier/gup2
	name = "FTU-SV GUP #2"
	shuttle = "FTU-SV GUP #2"
	desc = "An SSE-U20 long range shuttle, broadcasting FTUSV codes and the callsign \"FTU-SV GUP #2\"."
	fore_dir = NORTH
	max_speed = 1/(2 SECONDS) //same stats as charon
	burn_delay = 1 SECONDS
	vessel_mass = 5000
	skill_needed = SKILL_BASIC
	free_landing = FALSE

/obj/machinery/computer/shuttle_control/explore/carrier/gup2
	name = "landing control console"
	shuttle_tag = "FTU-SV GUP #2"

/datum/shuttle/autodock/overmap/carrier2
	name = "FTU-SV GUP #2"
	move_time = 20
	shuttle_area = list(/area/ship/carrier/deck2/gup2)
	current_location = "nav_hangar_carrier_2"
	landmark_transition = "nav_transit_carrier_2"
	dock_target = "carrier_2_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/heist
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/obj/shuttle_landmark/carrier/gup2
	name = "GUP #2 Hangar"
	landmark_tag = "nav_hangar_carrier_2"
	docking_controller = "carrier_2_shuttle_dock_airlock"
	base_area = /area/ship/carrier/deck2/living2

/obj/shuttle_landmark/transit/carrier/gup2
	name = "In transit"
	landmark_tag = "nav_transit_carrier_2"

// GUP #3

/obj/overmap/visitable/ship/landable/carrier/gup3
	name = "FTU-SV GUP #3"
	shuttle = "FTU-SV GUP #3"
	desc = "An SSE-U20 long range shuttle, broadcasting FTUSV codes and the callsign \"FTU-SV GUP #3\"."
	fore_dir = NORTH
	max_speed = 1/(2 SECONDS) //same stats as charon
	burn_delay = 1 SECONDS
	vessel_mass = 5000
	skill_needed = SKILL_BASIC
	free_landing = FALSE

/obj/machinery/computer/shuttle_control/explore/carrier/gup3
	name = "landing control console"
	shuttle_tag = "FTU-SV GUP #3"

/datum/shuttle/autodock/overmap/carrier3
	name = "FTU-SV GUP #3"
	move_time = 20
	shuttle_area = list(/area/ship/carrier/deck2/gup3)
	current_location = "nav_hangar_carrier_3"
	landmark_transition = "nav_transit_carrier_3"
	dock_target = "carrier_3_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/heist
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/obj/shuttle_landmark/carrier/gup3
	name = "GUP #3 Hangar"
	landmark_tag = "nav_hangar_carrier_3"
	docking_controller = "carrier_3_shuttle_dock_airlock"
	base_area = /area/ship/carrier/deck2/living3

/obj/shuttle_landmark/transit/carrier/gup3
	name = "In transit"
	landmark_tag = "nav_transit_carrier_3"

// GUP #4

/obj/overmap/visitable/ship/landable/carrier/gup4
	name = "FTU-SV GUP #4"
	shuttle = "FTU-SV GUP #4"
	desc = "An SSE-U20 long range shuttle, broadcasting FTUSV codes and the callsign \"FTU-SV GUP #4\"."
	fore_dir = NORTH
	max_speed = 1/(2 SECONDS) //same stats as charon
	burn_delay = 1 SECONDS
	vessel_mass = 5000
	skill_needed = SKILL_BASIC
	free_landing = FALSE

/obj/machinery/computer/shuttle_control/explore/carrier/gup4
	name = "landing control console"
	shuttle_tag = "FTU-SV GUP #4"

/datum/shuttle/autodock/overmap/carrier4
	name = "FTU-SV GUP #4"
	move_time = 20
	shuttle_area = list(/area/ship/carrier/deck2/gup4)
	current_location = "nav_hangar_carrier_4"
	landmark_transition = "nav_transit_carrier_4"
	dock_target = "carrier_4_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/heist
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/obj/shuttle_landmark/carrier/gup4
	name = "GUP #4 Hangar"
	landmark_tag = "nav_hangar_carrier_4"
	docking_controller = "carrier_4_shuttle_dock_airlock"
	base_area = /area/ship/carrier/deck2/living4

/obj/shuttle_landmark/transit/carrier/gup4
	name = "In transit"
	landmark_tag = "nav_transit_carrier_4"

// GUP #5

/obj/overmap/visitable/ship/landable/carrier/gup5
	name = "FTU-SV GUP #5"
	shuttle = "FTU-SV GUP #5"
	desc = "An SSE-U20 long range shuttle, broadcasting FTUSV codes and the callsign \"FTU-SV GUP #5\"."
	fore_dir = NORTH
	max_speed = 1/(2 SECONDS) //same stats as charon
	burn_delay = 1 SECONDS
	vessel_mass = 5000
	skill_needed = SKILL_BASIC
	free_landing = FALSE

/obj/machinery/computer/shuttle_control/explore/carrier/gup5
	name = "landing control console"
	shuttle_tag = "FTU-SV GUP #5"

/datum/shuttle/autodock/overmap/carrier5
	name = "FTU-SV GUP #5"
	move_time = 20
	shuttle_area = list(/area/ship/carrier/deck2/gup5)
	current_location = "nav_hangar_carrier_5"
	landmark_transition = "nav_transit_carrier_5"
	dock_target = "carrier_5_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/heist
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/obj/shuttle_landmark/carrier/gup5
	name = "GUP #5 Hangar"
	landmark_tag = "nav_hangar_carrier_5"
	docking_controller = "carrier_5_shuttle_dock_airlock"
	base_area = /area/ship/carrier/deck2/living5

/obj/shuttle_landmark/transit/carrier/gup5
	name = "In transit"
	landmark_tag = "nav_transit_carrier_5"

// GUP #6

/obj/overmap/visitable/ship/landable/carrier/gup6
	name = "FTU-SV GUP #6"
	shuttle = "FTU-SV GUP #6"
	desc = "An SSE-U20 long range shuttle, broadcasting FTUSV codes and the callsign \"FTU-SV GUP #6\"."
	fore_dir = NORTH
	max_speed = 1/(2 SECONDS) //same stats as charon
	burn_delay = 1 SECONDS
	vessel_mass = 5000
	skill_needed = SKILL_BASIC
	free_landing = FALSE

/obj/machinery/computer/shuttle_control/explore/carrier/gup6
	name = "landing control console"
	shuttle_tag = "FTU-SV GUP #6"

/datum/shuttle/autodock/overmap/carrier6
	name = "FTU-SV GUP #6"
	move_time = 20
	shuttle_area = list(/area/ship/carrier/deck2/gup6)
	current_location = "nav_hangar_carrier_6"
	landmark_transition = "nav_transit_carrier_6"
	dock_target = "carrier_6_shuttle_dock_airlock"
	range = 1
	fuel_consumption = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/heist
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/obj/shuttle_landmark/carrier/gup6
	name = "GUP #6 Hangar"
	landmark_tag = "nav_hangar_carrier_6"
	docking_controller = "carrier_6_shuttle_dock_airlock"
	base_area = /area/ship/carrier/deck2/living6

/obj/shuttle_landmark/transit/carrier/gup6
	name = "In transit"
	landmark_tag = "nav_transit_carrier_6"
