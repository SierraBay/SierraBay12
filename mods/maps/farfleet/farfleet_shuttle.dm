/datum/shuttle/autodock/overmap/snz
	name = "SNZ Speedboat"
	warmup_time = 5
	dock_target = "snz_shuttle"
	current_location = "nav_hangar_snz"
	range = 1
	shuttle_area = /area/ship/snz
	fuel_consumption = 7
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_BASIC
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/merc

/obj/machinery/computer/shuttle_control/explore/away_farfleet/snz
	name = "SNZ Shuttle control console"
	req_access = list(access_away_iccgn)
	shuttle_tag = "SNZ Speedboat"

/obj/effect/overmap/visitable/ship/landable/snz
	name = "SNZ Speedboat"
	desc = "SNZ-350 Speedboat. More lighter than it's predecessor, but more maneuverable."
	shuttle = "SNZ Speedboat"
	fore_dir = WEST
	color = "#ff7300"
	vessel_mass = 5000
	vessel_size = SHIP_SIZE_SMALL


/area/ship/snz
	name = "\improper ICCGN PC SNZ-350"
	icon_state = "yellow"
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED
	req_access = list(access_away_iccgn)

/obj/effect/shuttle_landmark/snz/start
	name = "SNZ Hangar"
	landmark_tag = "nav_hangar_snz"
	base_area = /area/ship/farfleet/command/snz_hangar
	base_turf = /turf/simulated/floor/reinforced

/obj/effect/shuttle_landmark/snz/altdock
	name = "Docking Port"
	landmark_tag = "nav_hangar_snzalt"

/obj/effect/shuttle_landmark/snz/dock
	name = "NSV Sierra Dock"
	landmark_tag = "nav_snz_dock"
	docking_controller = "nuke_shuttle_dock_airlock" // TODO Изменить на шаттл хейста из-за изменившегося местоположения выхода
