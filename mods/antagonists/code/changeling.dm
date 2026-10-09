/datum/antagonist/changeling
	landmark_id = "changelingstart"
	flags = ANTAG_OVERRIDE_JOB | ANTAG_OVERRIDE_MOB | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	no_prior_faction = TRUE
	base_to_load = /datum/map_template/ruin/antag_spawn/changeling
	welcome_text = "You awaken in a hidden nest away from the Sierra. Use the salvage shuttle, tug, or landing pod to reach the ship, take a crew identity, and grow the brood. Use say \"%LANGUAGE_PREFIX%g message\" to communicate with your fellow changelings. Remember: you get all of their absorbed DNA if you absorb them."


/datum/antagonist/changeling/prepare_changeling_body(datum/mind/player, preserve_appearance)
	var/mob/living/carbon/human/H = player.current
	if (istype(H) && H.client?.prefs && !preserve_appearance)
		H.client.prefs.copy_to(H)
	..()


/datum/antagonist/changeling/equip(mob/living/carbon/human/player)
	if (!..())
		return 0
	if (!player.w_uniform)
		player.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(player), slot_w_uniform)
	if (!player.shoes)
		player.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(player), slot_shoes)
	return 1


/obj/landmark/changelingstart
	name = "changelingstart"
	icon_state = "x3"


/datum/map_template/ruin/antag_spawn/changeling
	name = "Changeling Nest"
	prefix = "mods/antagonists/maps/"
	suffixes = list("changeling_nest.dmm")
	shuttles_to_initialise = list(
		/datum/shuttle/autodock/overmap/changeling_crab,
		/datum/shuttle/autodock/overmap/changeling_pod,
		/datum/shuttle/autodock/overmap/changeling_tug
	)
	apc_test_exempt_areas = list(
		/area/map_template/changeling_nest = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/map_template/changeling_nest/crab/net = NO_SCRUBBER|NO_VENT|NO_APC
	)


/obj/overmap/visitable/sector/changeling_nest
	name = "Tiny Asteroid"
	desc = "Sensor array detects a small, insignificant asteroid. The core appears to be reflecting scans."
	place_near_main = list(2, 4)
	icon_state = "meteor4"
	hide_from_reports = TRUE
	sensor_visibility = 10
	scannable = FALSE
	sector_flags = OVERMAP_SECTOR_UNTARGETABLE | OVERMAP_SECTOR_IN_SPACE
	initial_generic_waypoints = list(
		"nav_changeling_crab",
		"nav_changeling_pod",
		"nav_changeling_tug"
	)
	initial_restricted_waypoints = list(
		"ISV Crab" = list("nav_changeling_crab"),
		"EE S-class 18-24" = list("nav_changeling_pod"),
		"Hyena GM Tug" = list("nav_changeling_tug")
	)


/obj/overmap/visitable/ship/sierra/New()
	. = ..()
	LAZYADD(initial_generic_waypoints, "nav_changeling_deck1")
	LAZYADD(initial_generic_waypoints, "nav_changeling_deck2")
	LAZYADD(initial_generic_waypoints, "nav_changeling_deck3")
	LAZYADD(initial_generic_waypoints, "nav_changeling_deck4")


/datum/shuttle/autodock/multi/antag/changeling
	name = "Unregistered Shuttle"
	defer_initialisation = TRUE
	warmup_time = 0
	shuttle_area = /area/map_template/changeling_nest/shuttle
	current_location = "nav_changeling_start"
	landmark_transition = "nav_changeling_transition"
	announcer = "Proximity Sensor Array"
	home_waypoint = "nav_changeling_start"
	arrival_message = "Attention, unidentified small craft detected entering vessel proximity."
	departure_message = "Attention, unidentified small craft detected leaving vessel proximity."
	destination_tags = list(
		"nav_changeling_deck1",
		"nav_changeling_deck2",
		"nav_changeling_deck3",
		"nav_changeling_deck4",
		"nav_changeling_start",
		"nav_away_6",
		"nav_derelict_5",
		"nav_cluster_6",
		"nav_lost_supply_base_antag",
		"nav_marooned_antag",
		"nav_smugglers_antag",
		"nav_magshield_antag",
		"nav_casino_antag",
		"nav_yacht_antag",
		"nav_slavers_base_antag",
		"nav_mining_antag"
	)


/obj/shuttle_landmark/changeling/start
	name = "Unregistered Outpost"
	landmark_tag = "nav_changeling_start"


/obj/shuttle_landmark/changeling/internim
	name = "In transit"
	landmark_tag = "nav_changeling_transition"


/obj/shuttle_landmark/changeling/deck1
	name = "West of Fourth Deck"
	landmark_tag = "nav_changeling_deck1"


/obj/shuttle_landmark/changeling/deck2
	name = "East of Third Deck"
	landmark_tag = "nav_changeling_deck2"


/obj/shuttle_landmark/changeling/deck3
	name = "Northeast of Second Deck"
	landmark_tag = "nav_changeling_deck3"


/obj/shuttle_landmark/changeling/deck4
	name = "South of First Deck"
	landmark_tag = "nav_changeling_deck4"


/obj/machinery/computer/shuttle_control/multi/changeling
	name = "shuttle control console"
	shuttle_tag = "Unregistered Shuttle"


/area/map_template/changeling_nest
	name = "Unregistered Outpost"
	icon_state = "green"
	requires_power = 0
	dynamic_lighting = TRUE
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED | AREA_FLAG_IS_NOT_PERSISTENT


/area/map_template/changeling_nest/shuttle
	name = "Unregistered Shuttle"
	icon_state = "shuttlered"
	base_turf = /turf/space
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED | AREA_FLAG_IS_NOT_PERSISTENT


/area/map_template/changeling_nest/crab
	name = "ISV Crab"
	icon_state = "shuttlegrn"
	requires_power = TRUE
	dynamic_lighting = TRUE
	base_turf = /turf/space
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED | AREA_FLAG_IS_NOT_PERSISTENT

/area/map_template/changeling_nest/crab/cockpit
	name = "ISV Crab - Cockpit"

/area/map_template/changeling_nest/crab/cargo
	name = "ISV Crab - Cargo"

/area/map_template/changeling_nest/crab/net
	name = "ISV Crab - Salvage Net"
	requires_power = FALSE
	turfs_airless = TRUE
	has_gravity = FALSE

/area/map_template/changeling_nest/crab/airlock
	name = "ISV Crab - Airlock"

/area/map_template/changeling_nest/crab/lounge
	name = "ISV Crab - Lounge"

/area/map_template/changeling_nest/crab/maintenance
	name = "ISV Crab - Maintenance"

/area/map_template/changeling_nest/pod
	name = "EE S-class 18-24"
	icon_state = "shuttlered"
	requires_power = TRUE
	dynamic_lighting = TRUE
	base_turf = /turf/space
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED | AREA_FLAG_IS_NOT_PERSISTENT

/area/map_template/changeling_nest/tug
	name = "GM Tug"
	icon_state = "shuttlered"
	requires_power = TRUE
	dynamic_lighting = TRUE
	base_turf = /turf/space
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED | AREA_FLAG_IS_NOT_PERSISTENT


/datum/shuttle/autodock/overmap/changeling_crab
	name = "ISV Crab"
	move_time = 45
	shuttle_area = list(
		/area/map_template/changeling_nest/crab/cockpit,
		/area/map_template/changeling_nest/crab/maintenance,
		/area/map_template/changeling_nest/crab/airlock,
		/area/map_template/changeling_nest/crab/lounge,
		/area/map_template/changeling_nest/crab/cargo,
		/area/map_template/changeling_nest/crab/net
	)
	dock_target = "crab_dock"
	current_location = "nav_changeling_crab"
	landmark_transition = "nav_changeling_crab_transit"
	range = 2
	fuel_consumption = 3
	logging_home_tag = "nav_changeling_crab"
	ceiling_type = /turf/simulated/floor/shuttle_ceiling
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/datum/shuttle/autodock/overmap/changeling_pod
	name = "EE S-class 18-24"
	warmup_time = 5
	current_location = "nav_changeling_pod"
	landmark_transition = "nav_changeling_pod_transit"
	range = 2
	shuttle_area = list(/area/map_template/changeling_nest/pod)
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_BASIC
	ceiling_type = /turf/simulated/floor/shuttle_ceiling

/datum/shuttle/autodock/overmap/changeling_tug
	name = "Hyena GM Tug"
	dock_target = "handtugtwo_shuttle"
	current_location = "nav_changeling_tug"
	landmark_transition = "nav_changeling_tug_transit"
	range = 2
	shuttle_area = /area/map_template/changeling_nest/tug
	fuel_consumption = 4
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_MIN
	ceiling_type = /turf/simulated/floor/shuttle_ceiling


/obj/machinery/computer/shuttle_control/explore/changeling_crab
	name = "crab control console"
	shuttle_tag = "ISV Crab"

/obj/machinery/computer/shuttle_control/explore/changeling_pod
	name = "pod control console"
	shuttle_tag = "EE S-class 18-24"

/obj/machinery/computer/shuttle_control/explore/changeling_tug
	name = "tug control console"
	shuttle_tag = "Hyena GM Tug"


/obj/overmap/visitable/ship/landable/changeling_crab
	name = "ISV Crab"
	desc = "A Firex SX5-B salvage shuttle, broadcasting the callsign \"Crab\"."
	shuttle = "ISV Crab"
	max_speed = 1/(5 SECONDS)
	burn_delay = 2 SECONDS
	vessel_mass = 4000
	fore_dir = WEST
	skill_needed = SKILL_BASIC
	vessel_size = SHIP_SIZE_SMALL

/obj/overmap/visitable/ship/landable/changeling_pod
	shuttle = "EE S-class 18-24"
	name = "EE S-class 18-24"
	desc = "Einstein Engines S-class pod. Universal takeoff and landing module."
	max_speed = 1/(2 SECONDS)
	burn_delay = 1 SECONDS
	fore_dir = NORTH
	vessel_mass = 500
	vessel_size = SHIP_SIZE_TINY

/obj/overmap/visitable/ship/landable/changeling_tug
	name = "GM Tug"
	desc = "Grayson Manufactories Tug. Space truckin commonly seen across Frontier."
	shuttle = "Hyena GM Tug"
	fore_dir = NORTH
	vessel_mass = 2500
	vessel_size = SHIP_SIZE_TINY


/obj/shuttle_landmark/changeling/crab
	name = "Uncharted Salvage Dock"
	landmark_tag = "nav_changeling_crab"
	docking_controller = "crab_dock"
	base_turf = /turf/space
	base_area = /area/space

/obj/shuttle_landmark/changeling/crab_transit
	name = "In transit"
	landmark_tag = "nav_changeling_crab_transit"
	base_turf = /turf/space
	base_area = /area/space

/obj/shuttle_landmark/changeling/pod
	name = "Uncharted Pod Dock"
	landmark_tag = "nav_changeling_pod"
	base_turf = /turf/space
	base_area = /area/space

/obj/shuttle_landmark/changeling/pod_transit
	name = "In transit"
	landmark_tag = "nav_changeling_pod_transit"
	base_turf = /turf/space
	base_area = /area/space

/obj/shuttle_landmark/changeling/tug
	name = "Uncharted Tug Dock"
	landmark_tag = "nav_changeling_tug"
	docking_controller = "handtugtwo_port_dock"
	base_turf = /turf/space
	base_area = /area/space

/obj/shuttle_landmark/changeling/tug_transit
	name = "In transit"
	landmark_tag = "nav_changeling_tug_transit"
	base_turf = /turf/space
	base_area = /area/space
