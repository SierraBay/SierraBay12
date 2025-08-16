/datum/map_template/ruin/antag_spawn/mercenary
	name = "Mercenary Base"
	prefix = "mods/antagonists/maps/"
	suffixes = list("mercenary_base.dmm")
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/merc_shuttle)

/datum/map_template/ruin/antag_spawn/ninja
	name = "Operative Base"
	prefix = "mods/antagonists/maps/"
	suffixes = list("ninja_sierrabay.dmm")
	shuttles_to_initialise = list(/datum/shuttle/autodock/multi/antag/ninja)
	apc_test_exempt_areas = list(
		/area/map_template/ninja_dojo = NO_SCRUBBER|NO_VENT|NO_APC
	)

/datum/map_template/ruin/antag_spawn/ert
	prefix = "mods/antagonists/maps/"
	suffixes = list("ert_base.dmm")
	shuttles_to_initialise = list(/datum/shuttle/autodock/multi/antag/rescue)
	apc_test_exempt_areas = list(/area/map_template/rescue_base = NO_SCRUBBER|NO_VENT|NO_APC)

/obj/overmap/visitable/sector/ert_ship
	name = "NDV Icarus"
	desc = "An Orca-Class Escort Carrier, broadcasting NanoTrasen codes.\n<span class='bad'>Its weapons and shielding systems appears to be active.</span>"
	color = COLOR_NT_RED

/datum/shuttle/autodock/multi/antag/rescue
	name = "Rescue"
	warmup_time = 0
	defer_initialisation = TRUE
	shuttle_area = /area/map_template/rescue_base/start
	dock_target = "rescue_shuttle"
	current_location = "nav_ert_start"
	landmark_transition = "nav_ert_transition"
	home_waypoint = "nav_ert_start"
	announcer = "Proximity Sensor Array"
	arrival_message = "Attention, vessel detected entering vessel proximity."
	departure_message = "Attention, vessel detected leaving vessel proximity."

	destination_tags = list(
		"nav_ert_deck1",
		"nav_ert_deck2",
		"nav_ert_deck3",
		"nav_ert_deck4",
		"nav_ert_deck5",
		"nav_away_4",
		"nav_derelict_4",
		"nav_cluster_4",
		"nav_ert_dock",
		"nav_ert_start",
		"nav_lost_supply_base_antag",
		"nav_marooned_antag",
		"nav_smugglers_antag",
		"nav_magshield_antag",
		"nav_casino_antag",
		"nav_yacht_antag",
		"nav_slavers_base_antag",
		"nav_mining_antag"
		)

/obj/machinery/computer/shuttle_control/multi/rescue
	name = "rescue shuttle control console"
	req_access = list(access_cent_specops)
	shuttle_tag = "Rescue"

/obj/shuttle_landmark/ert/start
	name = "NDV Icarus, Hangar Bay"
	landmark_tag = "nav_ert_start"
	docking_controller = "rescue_base"

/obj/shuttle_landmark/ert/internim
	name = "In transit"
	landmark_tag = "nav_ert_transition"

/obj/shuttle_landmark/ert/dock
	name = "Docking Port"
	landmark_tag = "nav_ert_dock"
	docking_controller = "rescue_shuttle_dock_airlock"

// Areas
/area/map_template/rescue_base
	name = "\improper Response Team Base"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = 1
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED

/area/map_template/rescue_base/base
	name = "\improper Barracks"
	icon_state = "yellow"
	dynamic_lighting = 0

/area/map_template/rescue_base/start
	name = "\improper Response Team Base"
	icon_state = "shuttlered"
	base_turf = /turf/unsimulated/floor/techfloor
