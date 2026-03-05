/datum/shuttle/autodock/ferry/farfleet_lift
	name = "Gunboat Cargo Lift"
	defer_initialisation = TRUE
	shuttle_area = /area/turbolift/farfleet_lift
	warmup_time = 3
	waypoint_station = "nav_farfleet_lift_top"
	waypoint_offsite = "nav_farfleet_lift_bottom"
	sound_takeoff = 'sound/effects/lift_heavy_start.ogg'
	sound_landing = 'sound/effects/lift_heavy_stop.ogg'
	ceiling_type = null
	knockdown = 0

/area/turbolift/farfleet_lift
	name = "Gunboat Cargo Lift"
	icon_state = "shuttle3"
	base_turf = /turf/simulated/open
	req_access = list(access_away_iccgn)

/obj/shuttle_landmark/lift/farfleet_top
	name = "Deck 1 - Hangar Deck"
	landmark_tag = "nav_farfleet_lift_top"
	base_area = /area/ship/farfleet/crew/hallway/upper
	base_turf = /turf/simulated/open

/obj/shuttle_landmark/lift/farfleet_bottom
	name = "Deck 2 - Operating Deck"
	landmark_tag = "nav_farfleet_lift_bottom"
	flags = SLANDMARK_FLAG_AUTOSET
	base_area = /area/ship/farfleet/crew/hallway/lower
	base_turf = /turf/simulated/floor/plating

/obj/machinery/computer/shuttle_control/lift/farfleet
	name = "farfleet lift controls"
	shuttle_tag = "Gunboat Cargo Lift"
	ui_template = "shuttle_control_console_lift.tmpl"
	icon_state = "tiny"
	icon_keyboard = "tiny_keyboard"
	icon_screen = "lift"
	density = FALSE
