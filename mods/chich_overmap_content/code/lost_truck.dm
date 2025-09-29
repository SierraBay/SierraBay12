/area/ship/lost_truck
	name = "Truck Interior"
	ambience = list('sound/ambience/ambigen3.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg','sound/ambience/ambigen6.ogg','sound/ambience/ambigen7.ogg','sound/ambience/ambigen8.ogg','sound/ambience/ambigen9.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg')
	icon_state = "amaint"

/area/ship/lost_truck/exterior
	name = "Truck Exterior"
	icon_state = "engineering_supply"
	turfs_airless = TRUE



/obj/overmap/visitable/ship/lost_truck
	name = "freighter"
	desc = "Sensors detect an undamaged vessel and a small cloud of debris on the starboard side, no signs of activity."
	color = "#ad7026"
	vessel_mass = 17000
	max_speed = 1/(4 SECONDS)
	burn_delay = 4 SECONDS
	initial_generic_waypoints = list(
		"nav_lost_truck_1",
		"nav_lost_truck_2",
		"nav_lost_truck_3",
		"nav_lost_truck_4",
	)

/obj/overmap/visitable/ship/lost_truck/New()
	name = "ITV [pick("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")]-[rand(10,99)]00"
	..()

/datum/map_template/ruin/away_site/lost_truck
	name = "Lost Truck"
	id = "awaysite_lost_truck"
	description = "A looted old freighter."
	prefix = "mods/chich_overmap_content/maps/"
	suffixes = list("lost_truck.dmm")
	spawn_cost = 1
	area_usage_test_exempted_root_areas = list(/area/ship)
	apc_test_exempt_areas = list(
		/area/ship/lost_truck/exterior = NO_SCRUBBER|NO_VENT
	)



/obj/shuttle_landmark/lost_truck/nav1
	name = "Freighter Fore Navpoint"
	landmark_tag = "nav_lost_truck_1"

/obj/shuttle_landmark/lost_truck/nav2
	name = "Freighter Aft Navpoint"
	landmark_tag = "nav_lost_truck_2"

/obj/shuttle_landmark/lost_truck/nav3
	name = "Freighter Port Navpoint"
	landmark_tag = "nav_lost_truck_3"

/obj/shuttle_landmark/lost_truck/nav4
	name = "Freighter Starboard Navpoint"
	landmark_tag = "nav_lost_truck_4"



/obj/item/ammo_casing/rifle/military/used/Initialize()
	. = ..()
	expend()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
