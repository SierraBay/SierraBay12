/obj/item/ammo_casing/rifle/military/spent
	BB = null
	projectile_type = null
	icon_state = "riflecasing-spent"



/area/ship/lost_truck
	name = "Truck Interior"
	ambience = list('sound/ambience/ambigen3.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg','sound/ambience/ambigen6.ogg','sound/ambience/ambigen7.ogg','sound/ambience/ambigen8.ogg','sound/ambience/ambigen9.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg')
	icon_state = "amaint"

/area/ship/lost_truck/exterior
	name = "Truck Exterior"
	icon_state = "engineering_supply"
	turfs_airless = TRUE

// /obj/submap_landmark/joinable_submap/bearcat
// 	name = "FTV Bearcat"
// 	archetype = /singleton/submap_archetype/derelict/bearcat

// /singleton/submap_archetype/derelict/bearcat
// 	descriptor = "derelict cargo vessel"
// 	map = "Bearcat Wreck"
// 	crew_jobs = list(
// 		/datum/job/submap/bearcat_captain,
// 		/datum/job/submap/bearcat_crewman
// 	)

/obj/overmap/visitable/ship/lost_truck
	name = "freighter"
	color = "#ad7026"
	vessel_mass = 17000
	max_speed = 1/(4 SECONDS)
	burn_delay = 4 SECONDS

/obj/overmap/visitable/ship/lost_truck/New()
	name = "ITV [pick("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")]-[rand(10,99)]00"
	..()

/datum/map_template/ruin/away_site/bearcat_wreck
	name = "Bearcat Wreck"
	id = "awaysite_bearcat_wreck"
	description = "A wrecked freighter."
	prefix = "mods/chich_overmap_content/maps/"
	suffixes = list("lost_truck.dmm")
	// spawn_cost = 1
	// area_usage_test_exempted_root_areas = list(/area/ship)
	apc_test_exempt_areas = list(
		/area/ship/lost_truck/exterior = NO_SCRUBBER|NO_VENT
	)
	// spawn_weight = 0.67
