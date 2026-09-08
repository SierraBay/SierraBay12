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
	name = "NDV Icarus"
	prefix = "mods/antagonists/maps/"
	suffixes = list("ert_ship.dmm")
	shuttles_to_initialise = list(/datum/shuttle/autodock/multi/antag/ert)

/obj/overmap/visitable/sector/ert_ship
	name = "NDV Icarus"
	desc = "An Orca-Class Escort Carrier, broadcasting NanoTrasen codes.\n<span class='bad'>Its weapons and shielding systems appears to be active.</span>"
	color = COLOR_NT_RED

/datum/shuttle/autodock/multi/antag/ert

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

/obj/shuttle_landmark/ert/start
	name = "NDV Icarus, Hangar Bay"
	landmark_tag = "nav_ert_start"

/obj/shuttle_landmark/ert/dock
	name = "Dock PRSD-3"
	landmark_tag = "nav_ert_dock"
	docking_controller = "rescue_shuttle_dock_airlock"

// Areas

/area/map_template/ert/ship
	name = "NDV Icarus"

/area/map_template/ert/ship/prepwing
	name = "NDV Icarus - ERT Preparation Wing"

/area/map_template/ert/ship/briefing
	name = "NDV Icarus - Briefing Room"

/area/map_template/ert/ship/armory
	name = "NDV Icarus - Armory"

/area/map_template/ert/ship/hangar
	name = "NDV Icarus - Hangar 5"

/area/map_template/ert/ship/officer
	name = "NDV Icarus - Commanding Officer"

// Shuttle

/area/map_template/ert/shuttle
	name = "NDV Interdictor"

/area/map_template/ert/shuttle/cockpit
	req_access = list(access_ert_responder)

/area/map_template/ert/shuttle/engines
	name = "NDV Interdictor - Engineering Compartment"

/area/map_template/ert/shuttle/medbay
	name = "NDV Interdictor - Medical Compartment"
	req_access = list(access_cent_medical)

/area/map_template/ert/shuttle/armory
	name = "NDV Interdictor - Armory"
	req_access = list(access_ert_responder)

/area/map_template/ert/shuttle/storage
	name = "NDV Interdictor - Storage"

/area/map_template/ert/shuttle/central
	name = "NDV Interdictor - Crew Compartment"

/area/map_template/ert/shuttle/airlock
	name = "NDV Interdictor - Aft Crew Compartment"
