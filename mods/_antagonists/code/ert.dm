/datum/map_template/ruin/antag_spawn/ert
	name = "ERT Base"
	prefix = "mods/_antagonists/maps/"
	suffixes = list("ert_base.dmm")
	shuttles_to_initialise = list(/datum/shuttle/autodock/multi/antag/rescue)
	apc_test_exempt_areas = list(
		/area/map_template/rescue_base = NO_SCRUBBER|NO_VENT|NO_APC
	)


/datum/shuttle/autodock/multi/antag/rescue
	name = "Rescue"
	warmup_time = 0
	defer_initialisation = TRUE
	destination_tags = list(
		"nav_ert_dock",
		"nav_ert_start"
		)
	shuttle_area = /area/map_template/rescue_base/start
	dock_target = "rescue_shuttle"
	current_location = "nav_ert_start"
	landmark_transition = "nav_ert_transition"
	home_waypoint = "nav_ert_start"
	announcer = "Proximity Sensor Array"
	arrival_message = "Attention, vessel detected entering vessel proximity."
	departure_message = "Attention, vessel detected leaving vessel proximity."

/obj/shuttle_landmark/ert/start
	name = "Response Team Base"
	landmark_tag = "nav_ert_start"
	docking_controller = "rescue_base"

/obj/shuttle_landmark/ert/internim
	name = "In transit"
	landmark_tag = "nav_ert_transition"

/obj/shuttle_landmark/ert/dock
	name = "Docking Port"
	landmark_tag = "nav_ert_dock"
	docking_controller = "rescue_shuttle_dock_airlock"

/datum/shuttle/autodock/ferry/armorysecond
	name = "Second class equipment armory"
	shuttle_area = /area/map_template/rescue_base/turbolift/armorysecond
	warmup_time = 3
	waypoint_station = "nav_armorysecond_lift_top"
	waypoint_offsite = "nav_armorysecond_lift_bottom"
	sound_takeoff = 'sound/effects/lift_heavy_start.ogg'
	sound_landing = 'sound/effects/lift_heavy_stop.ogg'
	ceiling_type = null
	knockdown = 0

/datum/shuttle/autodock/ferry/armoryheavy
	name = "Restricted Equipment"
	shuttle_area = /area/map_template/rescue_base/turbolift/armoryheavy
	warmup_time = 3
	waypoint_station = "nav_armoryheavy_lift_top"
	waypoint_offsite = "nav_armoryheavy_lift_bottom"
	sound_takeoff = 'sound/effects/lift_heavy_start.ogg'
	sound_landing = 'sound/effects/lift_heavy_stop.ogg'
	ceiling_type = null
	knockdown = 0

/obj/shuttle_landmark/lift/armorysecond_top
	name = "Offbase Lift Location"
	landmark_tag = "nav_armorysecond_lift_top"
	base_area = /area/map_template/rescue_base/base
	base_turf = /turf/simulated/floor/plating

/obj/shuttle_landmark/lift/armorysecond_bottom
	name = "Armory on main ERT level"
	landmark_tag = "nav_armorysecond_lift_bottom"
	flags = SLANDMARK_FLAG_AUTOSET
	base_area = /area/map_template/rescue_base/base
	base_turf = /turf/simulated/floor/plating

/obj/shuttle_landmark/lift/armoryheavy_top
	name = "Offbase Lift Location"
	landmark_tag = "nav_armoryheavy_lift_top"
	base_area = /area/map_template/rescue_base/base
	base_turf = /turf/simulated/floor/plating

/obj/shuttle_landmark/lift/armoryheavy_bottom
	name = "Armory on main ERT level"
	landmark_tag = "nav_armoryheavy_lift_bottom"
	flags = SLANDMARK_FLAG_AUTOSET
	base_area = /area/map_template/rescue_base/base
	base_turf = /turf/simulated/floor/plating

/obj/machinery/computer/shuttle_control/lift/armorysecond
	name = "Second class equipment armory lift controls"
	shuttle_tag = "Second class equipment armory"
	ui_template = "shuttle_control_console_lift.tmpl"
	icon_state = "tiny"
	icon_keyboard = "tiny_keyboard"
	icon_screen = "lift"
	density = FALSE

/obj/machinery/computer/shuttle_control/lift/armoryheavy
	name = "Restricted Equipment controls"
	shuttle_tag = "Restricted Equipment"
	ui_template = "shuttle_control_console_lift.tmpl"
	icon_state = "tiny"
	icon_keyboard = "tiny_keyboard"
	icon_screen = "lift"
	density = FALSE

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
	base_turf = /turf/unsimulated/floor/rescue_base

/area/map_template/rescue_base/turbolift/armorysecond
	name = "ERT - Armory lift"
	icon_state = "shuttle3"
	base_turf = /turf/simulated/floor/plating

/area/map_template/rescue_base/turbolift/armoryheavy
	name = "ERT - Armory lift"
	icon_state = "shuttle3"
	base_turf = /turf/simulated/floor/plating
	lighting_tone = AREA_LIGHTING_COOL

//Objects

/obj/item/device/radio/headset/ert
	name = "emergency response team radio headset"
	desc = "The headset of the boss's boss."
	icon_state = "com_headset"
	item_state = "headset"
	ks1type = /obj/item/device/encryptionkey/ert

/obj/item/device/radio/headset/ert/Initialize()
	. = ..()
	set_frequency(ERT_FREQ)

/obj/item/stock_parts/circuitboard/telecomms/allinone/ert
	build_path = /obj/machinery/telecomms/allinone/ert

/obj/machinery/telecomms/allinone/ert
	listening_freqs = list(ERT_FREQ)
	channel_color = COMMS_COLOR_CENTCOMM
	channel_name = "Response Team"
	circuitboard = /obj/item/stock_parts/circuitboard/telecomms/allinone/ert
