/obj/overmap/visitable/ship/tradership
	name = "Merchant Ship."
	desc = "Sensor array is detecting a small vessel."
	color = "#eff30e"
	icon_state = "ship"
	moving_state = "ship_moving"
	fore_dir = WEST
	vessel_size = SHIP_SIZE_SMALL
	burn_delay = 0.5 SECONDS
	hide_from_reports = TRUE
	skill_needed = SKILL_TRAINED
	vessel_mass = 3800
	max_speed = 1.4/(2 SECONDS)
	initial_restricted_waypoints = list(
		"Merchant" = list("nav_merchant_start")
	)

/obj/overmap/visitable/ship/tradership/New(nloc, max_x, max_y)
	name = "FTV [pick("Prosperous", "Nimble", "Feral", "Transparent", "Apelsinka")]"
	..()

/obj/machinery/computer/shuttle_control/explore/merchant
	name = "shuttle landing control console"
	shuttle_tag = "Merchant"

/obj/overmap/visitable/ship/landable/merchant
	name = "Merchant Shuttle."
	desc = "Sensor array is detecting a tiny vessel."
	shuttle = "Merchant"
	fore_dir = WEST
	dir = WEST
	color = "#f5d09f"
	vessel_mass = 750
	vessel_size = SHIP_SIZE_TINY

/obj/overmap/visitable/ship/landable/merchant/New(nloc, max_x, max_y)
	name = "FTV [pick("Milky Way", "Inquisitor", "Jew", "Kiggers", "Mandarinka")]"
	..()

/datum/map_template/ruin/away_site/tradership
	name = "Merchant Ship"
	id = "awaysite_merchant"
	description = "Medium movable vessel with merchants onboard (they do money)."
	prefix = "mods/_fd/_maps/trader_ship/maps/"
	suffixes = list("tradership.dmm")
	spawn_cost = 0.5
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/merchant)
	area_usage_test_exempted_root_areas = list(/area/tradership/shuttle)

/datum/shuttle/autodock/overmap/merchant
	name = "Merchant"
	move_time = 10
	shuttle_area = list(
		/area/tradership/shuttle
	)
	current_location = "nav_merchant_start"
	dock_target = "merchant_ship_dock"
	range = 1
	ceiling_type = /turf/simulated/floor/shuttle_ceiling
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS

/obj/submap_landmark/joinable_submap/merchant
	name = "Merchant Ship"
	archetype = /singleton/submap_archetype/merchant

/singleton/submap_archetype/merchant
	descriptor = "Merchant Ship"
	map = "Merchant Ship"
	crew_jobs = list(
		/datum/job/submap/merchant
	)

/obj/submap_landmark/spawnpoint/merchant
	name = "Ship Merchant"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/datum/job/submap/merchant
	title = "Ship Merchant"
	department = "Civilian"
	department_flag = CIV
	total_positions = 2
	spawn_positions = 2
	supervisors = "the invisible hand of the market"
	ideal_character_age = 30
	minimal_player_age = 0
	outfit_type = /singleton/hierarchy/outfit/job/torch/merchant
	allowed_branches = list(
		/datum/mil_branch/civilian,
		/datum/mil_branch/alien
	)
	allowed_ranks = list(
		/datum/mil_rank/civ/civ,
		/datum/mil_rank/alien
	)
	access = list(access_merchant)
	announced = FALSE
	min_skill = list(   SKILL_FINANCE = SKILL_TRAINED,
	                    SKILL_PILOT	  = SKILL_BASIC)

	max_skill = list(   SKILL_PILOT       = SKILL_MAX)
	skill_points = 24
