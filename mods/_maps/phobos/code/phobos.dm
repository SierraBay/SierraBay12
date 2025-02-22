/obj/overmap/visitable/ship/phobos
	name = "SCGF Patrol Craft"
	desc = "SCGF Cobra-class Patrol Craft. Belongs to Third Fleet Battle Group Alpha"
	color = "#81c6ff"
	vessel_mass = 5000
	max_speed = 1/(2 SECONDS)
	place_near_main = list(5, 5)
	initial_generic_waypoints = list(
		"nav_phobos_1",
		"nav_phobos_2",
		"nav_phobos_3",
		"nav_phobos_antag"
	)

	initial_restricted_waypoints = list(
		"Interseptor Shuttle" = list("nav_hangar_interseptor")
	)

#define PHOBOS_PREFIX pick("Theia","Kingfish","Sinai","Fallujah","Montjoie","Dallas","Castro","Quebec","Lee","Omaha","Gold","Utah","Juno","Sword")
/obj/overmap/visitable/ship/phobos/New()
	name = "SFV [PHOBOS_PREFIX], \a [name]"
	for(var/area/ship/patrol/A)
		A.name = "\improper [name] - [A.name]"
		GLOB.using_map.area_purity_test_exempt_areas += A.type
	..()
#undef PHOBOS_PREFIX

/datum/map_template/ruin/away_site/phobos
	name = "Third Fleet Patrol Craft (SFV)"
	id = "awaysite_phobos"
	description = "SolGov movable small ship with turned humans."
	prefix = "mods/_maps/phobos/maps/"
	suffixes = list("phobos.dmm")
	spawn_cost = 50 // We're testing this
	area_usage_test_exempted_root_areas = list(/area/phobos)
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/interseptor)
// We're deep in frontier. So no elite troops or terrans
	ban_ruins = list(
		/datum/map_template/ruin/away_site/farfleet,
		/datum/map_template/ruin/away_site/patrol
		)

/obj/shuttle_landmark/nav_phobos/nav1
	name = "Ship Navpoint #1"
	landmark_tag = "nav_phobos_1"

/obj/shuttle_landmark/nav_phobos/nav2
	name = "Ship Navpoint #2"
	landmark_tag = "nav_phobos_2"

/obj/shuttle_landmark/nav_phobos/nav3
	name = "Ship Navpoint #3"
	landmark_tag = "nav_phobos_3"

/obj/shuttle_landmark/nav_phobos/nav4
	name = "Ship Navpoint #4"
	landmark_tag = "nav_phobos_antag"

/datum/shuttle/autodock/overmap/interseptor
	name = "Interseptor Shuttle"
	warmup_time = 15
	dock_target = "interseptor"
	current_location = "nav_hangar_interseptor"
	range = 2
	fuel_consumption = 4
	shuttle_area = /area/ship/interseptor
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_BASIC
	ceiling_type = /turf/simulated/floor/shuttle_ceiling

/obj/machinery/computer/shuttle_control/explore/interseptor
	name = "Interseptor Shuttle control console"
	req_access = list(access_away_phobos)
	shuttle_tag = "Interseptor Shuttle"

/obj/overmap/visitable/ship/landable/interseptor
	name = "interseptor-S"
	desc = "A heavily modified military shuttle of particular design. More of the dropship now, scanner detects heavy alteration to the hull of the vessel and no designation"
	shuttle = "interseptor Shuttle"
	fore_dir = WEST
	color = "#81c6ff"
	vessel_mass = 2500
	vessel_size = SHIP_SIZE_TINY

/area/ship/interseptor
	name = "\improper interseptor"
	icon_state = "shuttlered"
	base_turf = /turf/simulated/floor
	requires_power = 1
	dynamic_lighting = 1
	req_access = list(access_away_phobos)
	area_flags = AREA_FLAG_RAD_SHIELDED

/obj/shuttle_landmark/interseptor/start
	name = "Dock"
	landmark_tag = "nav_hangar_interseptor"

/obj/shuttle_landmark/interseptor/altdock
	name = "Docking Port"
	landmark_tag = "nav_hangar_interseptoralt"
