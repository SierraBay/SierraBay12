/obj/overmap/visitable/ship/landable/cubkitten
	name = "FTV Cubkitten"
	shuttle = "FTV Cubkitten"
	desc = "Sensor array detects a tiny vessel claiming to be the 'FTV Cubkitten'. It appears to be a standard civilian utility pod - however, rudimentary scans indicate that severe damage was sustained by the hull quite recently."
	fore_dir = NORTH
	skill_needed = SKILL_BASIC
	vessel_size = SHIP_SIZE_TINY
	max_speed = 1/(4 SECONDS)
	burn_delay = 2.5 SECONDS
	vessel_mass = 3500

/obj/machinery/computer/shuttle_control/explore/cubkitten
	name = "landing control console"
	shuttle_tag = "FTV Cubkitten"

/datum/shuttle/autodock/overmap/cubkitten
	name = "FTV Cubkitten"
	warmup_time = 5
	move_time = 35
	shuttle_area = list(/area/ship/scrap/shuttle/cubkitten)
	current_location = "nav_hangar_cubkitten"
	landmark_transition = "nav_transit_cubkitten"
	range = 1
	fuel_consumption = 3
	ceiling_type = /turf/simulated/floor/shuttle_ceiling
	flags = SHUTTLE_FLAGS_PROCESS
	defer_initialisation = TRUE

/obj/shuttle_landmark/cubkitten
	name = "FTV Cubkitten Dock"
	landmark_tag = "nav_hangar_cubkitten"

/obj/shuttle_landmark/transit/cubkitten
	name = "In transit"
	landmark_tag = "nav_transit_cubkitten"

/obj/shuttle_landmark/cubkitten/torch
	name = "SEV Torch FTV Cubkitten Dock"
	landmark_tag = "nav_hangar_cubkitten_torch"
