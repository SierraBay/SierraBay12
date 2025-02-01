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

// Shuttle locations. Due to override we lose them if load with Sierra map
/datum/shuttle/autodock/multi/antag/rescue
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

// Areas

/area/map_template/rescue_base/start
	base_turf = /turf/unsimulated/floor/techfloor
