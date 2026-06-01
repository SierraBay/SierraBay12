#include "slavers_base_areas.dm"
#include "../mining/mining_areas.dm"

/obj/overmap/visitable/sector/slavers_base
	name = "large asteroid"
	desc = "Sensor array is reading an artificial structure inside the asteroid."
	icon_state = "object"


	initial_generic_waypoints = list(
		"nav_slavers_base_1",
		"nav_slavers_base_2",
		"nav_slavers_base_3",
		"nav_slavers_base_4",
		"nav_slavers_base_5",
		"nav_slavers_base_6",
		"nav_slavers_base_antag"
	)

/datum/map_template/ruin/away_site/slavers
	name = "Slavers' Base"
	id = "awaysite_slavers"
	description = "Asteroid with slavers base inside."
	suffixes = list("slavers/slavers_base.dmm")
	spawn_cost = 1
	generate_mining_by_z = 1
	area_usage_test_exempted_root_areas = list(/area/slavers_base)
	apc_test_exempt_areas = list(
		/area/slavers_base/hangar = NO_SCRUBBER
	)

/datum/map_template/ruin/away_site/slavers/after_load(z)
	..()
	var/obj/item/tactical_terminal/terminal = \
		spawn_derelict_mission_object(/obj/item/tactical_terminal, z, /area/slavers_base)
	// Spawn the access log containing the terminal's code
	if(terminal)
		var/obj/item/paper/log = spawn_derelict_mission_object(/obj/item/paper, z, /area/slavers_base)
		if(log)
			log.name = "Shellguard tactical operations log"
			log.info = "<b>Shellguard PRIVATE MILITARY — OPERATIONS TERMINAL</b><hr>" + \
				"Authorization code for field terminal access:<br><br>" + \
				"<b>ACCESS VERIFICATION CODE: [terminal.access_code]</b><br><br>" + \
				"This document is classified. Destruction required after use."
			log.update_icon()

/obj/shuttle_landmark/nav_slavers_base/nav1
	name = "Slavers Base Navpoint #1"
	landmark_tag = "nav_slavers_base_1"

/obj/shuttle_landmark/nav_slavers_base/nav2
	name = "Slavers Base Navpoint #2"
	landmark_tag = "nav_slavers_base_2"

/obj/shuttle_landmark/nav_slavers_base/nav3
	name = "Slavers Base Navpoint #3"
	landmark_tag = "nav_slavers_base_3"

/obj/shuttle_landmark/nav_slavers_base/nav4
	name = "Slavers Base Navpoint #4"
	landmark_tag = "nav_slavers_base_4"

/obj/shuttle_landmark/nav_slavers_base/nav5
	name = "Slavers Base Navpoint #5"
	landmark_tag = "nav_slavers_base_5"

/obj/shuttle_landmark/nav_slavers_base/nav6
	name = "Slavers Base Navpoint #6"
	landmark_tag = "nav_slavers_base_6"

/obj/shuttle_landmark/nav_slavers_base/nav7
	name = "Slavers Base Navpoint #7"
	landmark_tag = "nav_slavers_base_antag"

/singleton/hierarchy/outfit/corpse
	name = "Corpse Clothing"

/singleton/hierarchy/outfit/corpse/Initialize()
	..()
	hierarchy_type = type

/singleton/hierarchy/outfit/corpse/slavers_base
	name = "Basic slaver output"

/obj/landmark/corpse/slavers_base/slaver1
	name = "Slaver"
	corpse_outfits = list(/singleton/hierarchy/outfit/corpse/slavers_base/slaver1)

/singleton/hierarchy/outfit/corpse/slavers_base/slaver1
	name = "Dead Slaver 1"
	uniform = /obj/item/clothing/under/color/brown
	shoes = /obj/item/clothing/shoes/black
	glasses = /obj/item/clothing/glasses/sunglasses

/obj/landmark/corpse/slavers_base/slaver2
	name = "Slaver"
	corpse_outfits = list(/singleton/hierarchy/outfit/corpse/slavers_base/slaver2)

/singleton/hierarchy/outfit/corpse/slavers_base/slaver2
	name = "Dead Slaver 2"
	uniform = /obj/item/clothing/under/grayson
	shoes = /obj/item/clothing/shoes/blue

/obj/landmark/corpse/slavers_base/slaver3
	name = "Slaver"
	corpse_outfits = list(/singleton/hierarchy/outfit/corpse/slavers_base/slaver3)

/singleton/hierarchy/outfit/corpse/slavers_base/slaver3
	name = "Dead Slaver 3"
	uniform = /obj/item/clothing/under/pirate
	shoes = /obj/item/clothing/shoes/brown

/obj/landmark/corpse/slavers_base/slaver4
	name = "Slaver"
	corpse_outfits = list(/singleton/hierarchy/outfit/corpse/slavers_base/slaver4)

/singleton/hierarchy/outfit/corpse/slavers_base/slaver4
	name = "Dead Slaver 4"
	uniform = /obj/item/clothing/under/redcoat
	shoes = /obj/item/clothing/shoes/brown

/obj/landmark/corpse/slavers_base/slaver5
	name = "Slaver"
	corpse_outfits = list(/singleton/hierarchy/outfit/corpse/slavers_base/slaver5)

/singleton/hierarchy/outfit/corpse/slavers_base/slaver5
	name = "Dead Slaver 5"
	uniform = /obj/item/clothing/under/sterile
	shoes = /obj/item/clothing/shoes/orange
	mask = /obj/item/clothing/mask/surgical

/obj/landmark/corpse/slavers_base/slaver6
	name = "Slaver"
	corpse_outfits = list(/singleton/hierarchy/outfit/corpse/slavers_base/slaver6)

/singleton/hierarchy/outfit/corpse/slavers_base/slaver6
	name = "Dead Slaver 6"
	uniform = /obj/item/clothing/under/frontier
	shoes = /obj/item/clothing/shoes/orange

/obj/landmark/corpse/slavers_base/slave
	name = "Slave"
	corpse_outfits = list(/singleton/hierarchy/outfit/corpse/slavers_base/slave)

/singleton/hierarchy/outfit/corpse/slavers_base/slave
	name = "Dead Slave"
	uniform = /obj/item/clothing/under/color/orange
	shoes = /obj/item/clothing/shoes/tactical

// ============================================================
// Abolition Extremist NPC Spawner (carbon/human with AI)
// ============================================================

/obj/landmark/slavers_npc/extremist
	name = "abolition extremist spawner"
	var/npc_name = "abolition extremist"
	var/outfit_type = /singleton/hierarchy/outfit/corpse/abolitionist
	var/ai_type = /datum/ai_holder/human/abolition_extremist
	var/faction_name = "extremist abolitionists"
	var/list/weapons = list(/obj/item/gun/energy/laser)

/obj/landmark/slavers_npc/extremist/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/landmark/slavers_npc/extremist/LateInitialize()
	var/mob/living/carbon/human/H = new(loc)
	H.real_name = npc_name
	H.SetName(npc_name)
	H.faction = faction_name
	H.a_intent = I_HURT
	// Equip outfit
	if(outfit_type)
		var/singleton/hierarchy/outfit/O = outfit_by_type(outfit_type)
		O.equip(H, equip_adjustments = OUTFIT_ADJUSTMENT_SKIP_ID_PDA|OUTFIT_ADJUSTMENT_SKIP_BACKPACK|OUTFIT_ADJUSTMENT_SKIP_SURVIVAL_GEAR|OUTFIT_ADJUSTMENT_SKIP_POST_EQUIP)
	// Weapons in hands
	for(var/W in weapons)
		var/obj/item/I = new W(H)
		H.put_in_hands(I)
	// AI setup
	H.ai_holder = new ai_type(H)
	H.update_icon()
	qdel(src)

/datum/ai_holder/human/abolition_extremist
	hostile = TRUE
	wander = TRUE
	cooperative = TRUE

/obj/landmark/corpse/abolitionist
	name = "abolitionist"
	corpse_outfits = list(/singleton/hierarchy/outfit/corpse/abolitionist)

/singleton/hierarchy/outfit/corpse/abolitionist
	name = "Dead abolitionist"
	uniform = /obj/item/clothing/under/abol_uniform
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/helmet/merc

/obj/item/clothing/under/abol_uniform
	name = "abolitionist combat suit"
	desc = "Lightly armored suit worn by abolition extremists during raids. It has green patches on the right sleeve and the chest. There is big green \"A\" on the back."
	icon = 'maps/away/slavers/slavers_base_sprites.dmi'
	icon_state = "abol_suit"
	item_icons = list(slot_w_uniform_str = 'maps/away/slavers/slavers_base_sprites.dmi')
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_PISTOL,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_MINOR
		)
