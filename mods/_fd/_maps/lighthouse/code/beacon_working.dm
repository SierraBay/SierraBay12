/obj/overmap/visitable/ship/working_beacon
	name = "Space beacon"
	desc = "This is space lighthouse!"
	icon = 'mods/_fd/_maps/lighthouse/icons/space_beacon.dmi'
	icon_state = "beacon"
	instant_contact = TRUE

	initial_generic_waypoints = list(
		"nav_beacon1_1",
		"nav_beacon1_2",
		"nav_beacon1_3",
		"nav_beacon1_antag"
	)

/obj/submap_landmark/joinable_submap/working_beacon
	name = "Working beacon"
	archetype = /singleton/submap_archetype/working_beacon

/singleton/submap_archetype/working_beacon
	descriptor = "Working beacon"
	map = "Working beacon"
	crew_jobs = list(
		/datum/job/submap/working_beacon/overseer,
		/datum/job/submap/working_beacon/cyborg
	)

/datum/job/submap/working_beacon/overseer
	title = "Lighthouse overseer"
	total_positions = 1
	supervisors = "nobody but yourself"
	info = "You will probably go insane here"
	outfit_type = /singleton/hierarchy/outfit/beacon
	loadout_allowed = TRUE
	min_skill = list(
		SKILL_EVA = SKILL_TRAINED,
		SKILL_HAULING = SKILL_TRAINED,
		SKILL_DEVICES = SKILL_BASIC,
		SKILL_MEDICAL = SKILL_BASIC
	)

/singleton/hierarchy/outfit/beacon
	name = "Lighthouse overseer"

	uniform = /obj/item/clothing/under/frontier
	suit = /obj/item/clothing/suit/storage/hazardvest/blue
	back = /obj/item/storage/backpack/satchel/pocketbook/gray
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/dutyboots
	glasses = /obj/item/clothing/glasses/meson
	backpack_contents = list(/obj/item/device/flashlight/flare=2,/obj/item/device/radio/hailing=1)

/obj/submap_landmark/spawnpoint/working_beacon/overseer
	name = "Lighthouse overseer"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/datum/job/submap/working_beacon/cyborg
	title = "Helper Bot"
	total_positions = 1
	supervisors = "your laws and your overseer"
	minimal_player_age = 7
	account_allowed = 0
	economic_power = 0
	loadout_allowed = FALSE
	outfit_type = /singleton/hierarchy/outfit/job/silicon/cyborg
	hud_icon = "hudblank"
	skill_points = 0

/datum/job/submap/working_beacon/cyborg/handle_variant_join(mob/living/carbon/human/H, alt_title)
	return H && H.Robotize(SSrobots.get_mob_type_by_title(alt_title || title))

/datum/job/submap/working_beacon/cyborg/equip(mob/living/carbon/human/H)
	return !!H

/datum/job/submap/working_beacon/cyborg/New(datum/submap/_owner, abstract_job = FALSE)
	..()
	alt_titles = SSrobots.robot_alt_titles.Copy()
	alt_titles -= title // So the unit test doesn't flip out if a mob or mmi type is declared for our main title.

/obj/submap_landmark/spawnpoint/working_beacon/cyborg
	name = "Helper Bot"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/datum/map_template/ruin/away_site/working_beacon
	name = "Space beacon"
	id = "awaysite_working_beacon"
	description = "An working space lighthouse."
	prefix = "mods/_fd/_maps/lighthouse/maps/"
	suffixes = list("beaconV1-1.dmm", "beaconV1-2.dmm")
	spawn_cost = 1
	player_cost = 2
	area_usage_test_exempted_root_areas = list(/area/ship/working_beacon)

/obj/shuttle_landmark/nav_working_beacon/nav1
	name = "Lighthouse Navpoint #1"
	landmark_tag = "nav_beacon1_1"

/obj/shuttle_landmark/nav_working_beacon/nav2
	name = "Lighthouse Navpoint #2"
	landmark_tag = "nav_beacon1_base_2"

/obj/shuttle_landmark/nav_working_beacon/nav3
	name = "Lighthouse Navpoint #3"
	landmark_tag = "nav_beacon1_base_3"

/obj/shuttle_landmark/nav_working_beacon/navantag
	name = "Lighthouse Navpoint #4"
	landmark_tag = "nav_beacon1_antag"

/area/ship/working_beacon
	name = "\improper Working beacon"
	icon_state = "bridge"

/area/ship/working_beacon/upper_hall
	name = "\improper Working beacon upper hall"

/area/ship/working_beacon/reactor
	name = "\improper Working beacon reactor room"

/area/ship/working_beacon/bridge
	name = "\improper Working beacon commanding center"

/area/ship/working_beacon/lower_hall
	name = "\improper Working beacon lower hall"

/area/ship/working_beacon/storage
	name = "\improper Working beacon storage room"

/area/ship/working_beacon/cryo
	name = "\improper Working beacon cryo chamber"

/area/ship/working_beacon/atmos
	name = "\improper Working beacon atmos"

/area/ship/working_beacon/breakroom
	name = "\improper Working beacon recreation room"

/area/ship/working_beacon/bedroom
	name = "\improper Working beacon bedroom"

/area/ship/working_beacon/restroom
	name = "\improper Working beacon restroom"
