/obj/overmap/visitable/ship/playable_yacht
	name = "private yacht"
	desc = "Sensor array is detecting a small vessel with unknown lifeforms on board."
	color = "#ffc966"
	vessel_mass = 3000
	max_speed = 1/(2 SECONDS)
	initial_generic_waypoints = list(
		"nav_yacht_1",
		"nav_yacht_2",
		"nav_yacht_3",
		"nav_yacht_antag"
	)

/obj/overmap/visitable/ship/playable_yacht/New(nloc, max_x, max_y)
	name = "IPV [pick("Razorshark", "Aurora", "Lighting", "Pequod", "Anansi")], \a [name]"
	..()

/datum/map_template/ruin/away_site/playable_yacht
	name = "Playable Yacht"
	id = "awaysite_playable_yach"
	description = "Expensive recreational boat"
	prefix = "mods/playable_away_yacht/maps/"
	suffixes = list("yacht.dmm")
	spawn_cost = 0.5
	player_cost = 2
	spawn_weight = 0.67
	area_usage_test_exempted_root_areas = list(/area/playable_yacht)


/singleton/submap_archetype/yacht
	descriptor = "established yacht"
	crew_jobs = list(/datum/job/submap/yachtman)

/datum/job/submap/yachtman
	title = "Yachtman"
	info = "Ты, устав от богатой жизни, с друзьями путешествуешь по бескрайнему космосу, в поисках интересной жизни."
	total_positions = 2
	outfit_type = /singleton/hierarchy/outfit/job/yachtman
	economic_power = 5


/singleton/hierarchy/outfit/job/yachtman
	name = OUTFIT_JOB_NAME("Yachtman")
	id_types = null

/obj/submap_landmark/spawnpoint/yachtman_spawn
	name = "Yachtman"

/obj/submap_landmark/joinable_submap/yachtman
	name = "established yacht"
	archetype = /singleton/submap_archetype/yacht





/area/playable_yacht
	icon = 'mods/playable_away_yacht/icons/yacht_icons.dmi'

/area/playable_yacht/bridge
	name = "\improper Yacht Bridge"
	icon_state = "bridge"

/area/playable_yacht/living
	name = "\improper Yacht living room"
	icon_state = "living"

/area/playable_yacht/left_engine
	name = "\improper Yacht left engine"
	icon_state = "engine"

/area/playable_yacht/right_engine
	name = "\improper Yacht right engine"
	icon_state = "engine"

/area/playable_yacht/kitchen
	name = "\improper Yacht kitchen"
	icon = 'icons/turf/areas.dmi'
	icon_state = "kitchen"

/area/playable_yacht/sklad
	name = "\improper Yacht sklad"
	icon = 'icons/turf/areas.dmi'
	icon_state = "storage"


/area/playable_yacht/relax_zone
	name = "\improper Yacht relax zone"
	icon = 'icons/turf/areas.dmi'
	icon_state = "restrooms"

/area/playable_yacht/main_corridor
	name = "\improper Yacht corridor"
	icon = 'icons/turf/areas.dmi'
	icon_state = "crew_quarters"


/obj/shuttle_landmark/nav_playable_yacht/nav1
	name = "Playable Yacht Navpoint #1"
	landmark_tag = "nav_playable_yacht_1"

/obj/shuttle_landmark/nav_playable_yacht/nav2
	name = "Playable Yacht Navpoint #2"
	landmark_tag = "nav_playable_yacht_2"

/obj/shuttle_landmark/nav_playable_yacht/nav3
	name = "Playable Yacht Navpoint #3"
	landmark_tag = "nav_playable_yacht_3"

/obj/shuttle_landmark/nav_playable_yacht/nav4
	name = "Playable Yacht Navpoint #4"
	landmark_tag = "nav_playable_yacht_antag"



//Затычки, дабы не ругались юнит тесты.
/obj/paint/nt_white/playable_yacht

/obj/item/clothing/gloves/wristwatch/gold/yacht
	desc = "There is a huge expensive yacht in the background of the clock."

/obj/structure/bed/sofa/l/black/yacht

/obj/structure/bed/sofa/r/black/yacht

/obj/structure/bed/sofa/m/light/yacht
