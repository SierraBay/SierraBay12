/datum/shuttle/autodock/overmap/snz
	name = "SNZ Baydarka"
	warmup_time = 10
	move_time = 30
	dock_target = "snz_shuttle"
	current_location = "nav_hangar_snz"
	range = 1
	shuttle_area = /area/ship/snz
	landmark_transition = "nav_transit_snz"
	fuel_consumption = 4
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_MIN
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/merc

/obj/machinery/computer/shuttle_control/explore/away_farfleet/snz
	name = "SNZ Shuttle control console"
	req_access = list(access_away_iccgn)
	shuttle_tag = "SNZ Baydarka"

/obj/overmap/visitable/ship/landable/snz
	name = "SNZ Baydarka"
	desc = "SNZ-350 Baydarka. Multipurpose shuttle, used for personnel and light vehicle delivery. This one definetly belongs to ICCG."
	shuttle = "SNZ Baydarka"
	fore_dir = WEST
	color = "#ff7300"
	vessel_mass = 1280
	vessel_size = SHIP_SIZE_TINY


/area/ship/snz
	name = "\improper ICCGN PC SNZ-350"
	icon_state = "shuttlered"
	requires_power = 1
	dynamic_lighting = 1
	area_flags = AREA_FLAG_RAD_SHIELDED
	req_access = list(access_away_iccgn)

/obj/shuttle_landmark/snz/start
	name = "SNZ Hangar"
	landmark_tag = "nav_hangar_snz"
	base_area = /area/ship/farfleet/command/snz_hangar
	base_turf = /turf/simulated/floor/plating

/obj/shuttle_landmark/snz/altdock
	name = "Docking Port"
	landmark_tag = "nav_hangar_snzalt"

/obj/shuttle_landmark/snz/dock
	name = "Dock PRSD-3"
	landmark_tag = "nav_snz_dock"
	docking_controller = "rescue_shuttle_dock_airlock"

/obj/shuttle_landmark/snz/transit
	name = "In transit"
	landmark_tag = "nav_transit_snz"
