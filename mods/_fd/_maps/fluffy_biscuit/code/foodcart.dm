// Map template data
/datum/map_template/ruin/away_site/foodcart
	name = "IPV Fluffy Biscuit"
	id = "awaysite_foodcart"
	description = "."
	prefix = "mods/_fd/_maps/fluffy_biscuit/maps/"
	suffixes = list("itv_fluffy_biscuit.dmm")
	spawn_cost = 2
	area_usage_test_exempted_root_areas = /area/ship/foodcart
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/foodcart)

/obj/overmap/visitable/sector/foodcart
	name = "Bluespace Residue"
	desc = "/ERROR/."
	icon_state = "event"
	hide_from_reports = TRUE
	sector_flags = OVERMAP_SECTOR_IN_SPACE | OVERMAP_SECTOR_UNTARGETABLE

/obj/submap_landmark/joinable_submap/foodcart
	name = "IPV Fluffy Biscuit"
	archetype = /singleton/submap_archetype/foodcart

/singleton/submap_archetype/foodcart
	descriptor = "IPV Fluffy Biscuit"
	map = "IPV Fluffy Biscuit"
	crew_jobs = list(/datum/job/submap/foodcart)

/datum/job/submap/foodcart
	title = "Foodcart Personnel"
	total_positions = 4
	supervisors = "nobody but yourself"
	info = "You are the crewman of your small flying restaurant. Pursue your goals, cook, trade with people; try to make everyone happy."
	whitelisted_species = list(SPECIES_HUMAN,SPECIES_IPC,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN,SPECIES_TRITONIAN,SPECIES_RESOMI)
	outfit_type = /singleton/hierarchy/outfit/job/foodcart
	loadout_allowed = TRUE
	min_skill = list(
		SKILL_EVA = SKILL_TRAINED,
		SKILL_COOKING = SKILL_TRAINED,
		SKILL_HAULING = SKILL_TRAINED,
		SKILL_PILOT = SKILL_BASIC
	)

/singleton/hierarchy/outfit/job/foodcart
	name = "Foodcart Personnel"
	uniform = /obj/item/clothing/under/lawyer/bluesuit
	l_ear = null
	l_pocket = /obj/item/device/flashlight/maglight
	shoes = /obj/item/clothing/shoes/black
	pda_type = /obj/item/modular_computer/pda

/obj/submap_landmark/spawnpoint/foodcart
	name = "Foodcart Personnel"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

//Ship code

/obj/overmap/visitable/ship/landable/foodcart
	name = "IPV Fluffy Biscuit"
	shuttle = "IPV Fluffy Biscuit"
	desc = "Sensor array is detecting a small private vessel, broadcasting registration codes \"IPV-2356-L-229\"."
	max_speed = 1/(2 SECONDS)
	burn_delay = 1 SECONDS
	vessel_mass = 7000
	skill_needed = SKILL_TRAINED
	vessel_size = SHIP_SIZE_SMALL
	fore_dir = NORTH
	dir = NORTH
	hide_from_reports = TRUE
	initial_restricted_waypoints = list(
		"Bluespace Residue" = list("nav_foodcart")
	)

/obj/machinery/computer/shuttle_control/explore/foodcart
	name = "vessel control console"
	shuttle_tag = "IPV Fluffy Biscuit"

/obj/shuttle_landmark/foodcart
	name = "Foodcart Landing Zone"
	landmark_tag = "nav_foodcart"
	docking_controller = "foodcart_dock"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/datum/shuttle/autodock/overmap/foodcart
	name = "IPV Fluffy Biscuit"
	warmup_time = 3
	range = 1
	shuttle_area = list(/area/ship/foodcart/bridge,/area/ship/foodcart/kitchen,/area/ship/foodcart/bedroom,/area/ship/foodcart/shower,/area/ship/foodcart/vip_hall,/area/ship/foodcart/main_hall,/area/ship/foodcart/engineering)
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_BASIC
	ceiling_type = /turf/simulated/floor/shuttle_ceiling
	current_location = "nav_foodcart"

//Areas

/area/ship/foodcart
	name = "\improper IPV Fluffy Biscuit"
	icon_state = "bridge"
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED

/area/ship/foodcart/bridge
	name = "\improper Fluffy Biscuit - Bridge"

/area/ship/foodcart/kitchen
	name = "\improper Fluffy Biscuit - Kitchen"

/area/ship/foodcart/bedroom
	name = "\improper Fluffy Biscuit - Bedroom"

/area/ship/foodcart/shower
	name = "\improper Fluffy Biscuit - Shower"

/area/ship/foodcart/vip_hall
	name = "\improper Fluffy Biscuit - VIP Room"

/area/ship/foodcart/main_hall
	name = "\improper Fluffy Biscuit - Main Hall"

/area/ship/foodcart/engineering
	name = "\improper Fluffy Biscuit - Engineering"
