/obj/submap_landmark/joinable_submap/airfield
	name = "Rubicon 3 Airfield"
	archetype = /singleton/submap_archetype/derelict/airfield

/singleton/submap_archetype/derelict/airfield
	descriptor = "Rubicon 3 Airfield"
	map = "Rubicon 3 Airfield"
	crew_jobs = list(
		/datum/job/submap/airfield/command/instructor,
		/datum/job/submap/airfield/command/assistant,
		/datum/job/submap/airfield/engineer,
		/datum/job/submap/airfield/cadet,
	)

/obj/overmap/visitable/ship/airfield
	name = "Rubicon 3 Airfield"
	desc = "Sensor array detects a large planet, named Rubicon 3, with big amount of various infrastructure on it."
	vessel_mass = 100000
	free_landing = FALSE
	icon_state = "globe"
	color = "#6db8b8"
	fore_dir = NORTH
	initial_restricted_waypoints = list(
			"PM-55-L Star #1" = list("nav_airfield_star_1", "nav_airfield_1"),
			"PM-55-L Star #2" = list("nav_airfield_star_2", "nav_airfield_2"),
			"PM-55-L Star #3" = list("nav_airfield_star_3", "nav_airfield_3"),
			"PM-55-L Star #4" = list("nav_airfield_star_4", "nav_airfield_4"),
			"PM-08 Bull #1" = list("nav_airfield_bull_1", "nav_airfield_5"),
			"PM-08 Bull #2" = list("nav_airfield_bull_2", "nav_airfield_6"),
			"PM-15 Nightbat #1" = list("nav_airfield_nightbat_1", "nav_airfield_7"),
			"PM-15 Nightbat #2" = list("nav_airfield_nightbat_2", "nav_airfield_8"),
			"PM-57 Spear #1" = list("nav_airfield_spear_1", "nav_airfield_9"),
			"PM-57 Spear #2" = list("nav_airfield_spear_2", "nav_airfield_10"),
			"PM-100 Scarab" = list("nav_airfield_scarab", "nav_airfield_11")
	)
	initial_generic_waypoints = list(
		"nav_airfield_1",
		"nav_airfield_2",
		"nav_airfield_3",
		"nav_airfield_4",
		"nav_airfield_5",
		"nav_airfield_6",
		"nav_airfield_7",
		"nav_airfield_8",
		"nav_airfield_9",
		"nav_airfield_10",
		"nav_airfield_11",
	)

/datum/map_template/ruin/away_site/airfield
	name = "Rubicon 3 Airfield"
	id = "awaysite_airfield"
	description = "Free Trade Union salvage ship"
	prefix = "mods/_fd/_maps/airfield/maps/"
	suffixes = list("airfield-1.dmm", "airfield-2.dmm")
	spawn_cost = INFINITY
	player_cost = 6
	area_usage_test_exempted_root_areas = list(/area/ship/airfield)
	shuttles_to_initialise = list(
		/datum/shuttle/autodock/overmap/airfield1,
		/datum/shuttle/autodock/overmap/airfield2,
		/datum/shuttle/autodock/overmap/airfield3,
		/datum/shuttle/autodock/overmap/airfield4,
		/datum/shuttle/autodock/overmap/airfield5,
		/datum/shuttle/autodock/overmap/airfield6,
		/datum/shuttle/autodock/overmap/airfield7,
		/datum/shuttle/autodock/overmap/airfield8,
		/datum/shuttle/autodock/overmap/airfield9,
		/datum/shuttle/autodock/overmap/airfield10,
		/datum/shuttle/autodock/overmap/airfield11,
		/datum/shuttle/autodock/ferry/airfield1,
		/datum/shuttle/autodock/ferry/airfield2
	)
	apc_test_exempt_areas = list(
		/area/ship/airfield/outdoors = NO_SCRUBBER|NO_VENT|NO_APC
	)


//elevator

/obj/machinery/computer/shuttle_control/lift/airfield1
	name = "ODT 1 controls"
	shuttle_tag = "ODT 1 lift"
	ui_template = "shuttle_control_console_lift.tmpl"
	icon_state = "tiny"
	icon_keyboard = "tiny_keyboard"
	icon_screen = "lift"
	density = FALSE

/datum/shuttle/autodock/ferry/airfield1
	name = "ODT 1 lift"
	shuttle_area = /area/ship/airfield/lift1
	warmup_time = 3
	waypoint_station = "nav_airfield_adt1_lift_top"
	waypoint_offsite = "nav_airfield_adt1_lift_bottom"
	sound_takeoff = 'sound/effects/lift_heavy_start.ogg'
	sound_landing = 'sound/effects/lift_heavy_stop.ogg'
	ceiling_type = null
	knockdown = 0
	defer_initialisation = TRUE

/obj/shuttle_landmark/lift/airfield/top1
	name = "Top Deck"
	landmark_tag = "nav_airfield_adt1_lift_top"
	base_area = /area/ship/airfield/adt1/upper
	base_turf = /turf/simulated/open

/obj/shuttle_landmark/lift/airfield/bottom1
	name = "Lower Deck"
	landmark_tag = "nav_airfield_adt1_lift_bottom"
	flags = SLANDMARK_FLAG_AUTOSET
	base_area = /area/ship/airfield/adt1
	base_turf = /turf/simulated/floor/plating



/obj/machinery/computer/shuttle_control/lift/airfield2
	name = "ODT 2 controls"
	shuttle_tag = "ODT 2 lift"
	ui_template = "shuttle_control_console_lift.tmpl"
	icon_state = "tiny"
	icon_keyboard = "tiny_keyboard"
	icon_screen = "lift"
	density = FALSE

/datum/shuttle/autodock/ferry/airfield2
	name = "ODT 2 lift"
	shuttle_area = /area/ship/airfield/lift2
	warmup_time = 3
	waypoint_station = "nav_airfield_adt2_lift_top"
	waypoint_offsite = "nav_airfield_adt2_lift_bottom"
	sound_takeoff = 'sound/effects/lift_heavy_start.ogg'
	sound_landing = 'sound/effects/lift_heavy_stop.ogg'
	ceiling_type = null
	knockdown = 0
	defer_initialisation = TRUE

/obj/shuttle_landmark/lift/airfield/top2
	name = "Top Deck"
	landmark_tag = "nav_airfield_adt2_lift_top"
	base_area = /area/ship/airfield/adt2/upper
	base_turf = /turf/simulated/open

/obj/shuttle_landmark/lift/airfield/bottom2
	name = "Lower Deck"
	landmark_tag = "nav_airfield_adt2_lift_bottom"
	flags = SLANDMARK_FLAG_AUTOSET
	base_area = /area/ship/airfield/adt2
	base_turf = /turf/simulated/floor/plating
