#include "psistation_areas.dm"

/obj/overmap/visitable/sector/psistation
	name = "Strange Station"
	desc = "Scanner shows Science Space Station with -DANGER- beacon. Damage to structural integrity of object detected, no active life indicators detected. Low profile energy indicators present. Minor dark matter glitch in square area.."
	icon_state = "object"

	initial_generic_waypoints = list(
		"nav_psistation_1",
		"nav_psistation_2",
		"nav_psistation_3",
		"nav_psistation_4",
		"nav_psistation_antag"
	)

/datum/map_template/ruin/away_site/psistation
	name = "Psistation"
	id = "awaysite_psistation"
	description = "It's a strange research station."
	prefix = "mods/_maps/psistation/"
	suffixes = list("psistation.dmm")
	spawn_cost = 1
	area_usage_test_exempted_root_areas = list(/area/psistation)

/obj/shuttle_landmark/nav_psistation/nav1
	name = "Navpoint #1"
	landmark_tag = "nav_psistation_1"

/obj/shuttle_landmark/nav_psistation/nav2
	name = "Navpoint #2"
	landmark_tag = "nav_psistation_2"

/obj/shuttle_landmark/nav_psistation/nav3
	name = "Navpoint #3"
	landmark_tag = "nav_psistation_3"

/obj/shuttle_landmark/nav_psistation/nav4
	name = "Navpoint #4"
	landmark_tag = "nav_psistation_4"

/obj/shuttle_landmark/nav_psistation/nav5
	name = "Navpoint #5"
	landmark_tag = "nav_psistation_antag"




///obj - /maps/away/psistation/psistation_sprites/psi_extractor

/obj/structure/psistation/strange_computer
	name = "Analyzer Computer"
	desc = "It looks like a strange piece of machinery that you probably haven't seen before. Why does it need a floppy disk slot?"
	icon = 'mods/_maps/psistation/psistation_sprites.dmi'
	icon_state = "psi_extractor"
	anchored = TRUE
	density = TRUE

/obj/structure/psistation/strange_server_c
	name = "Closed Server"
	desc = "A strange server that appears to be locked with a smart digital lock."
	icon = 'mods/_maps/psistation/psistation_sprites.dmi'
	icon_state = "closed_server"
	anchored = TRUE
	density = TRUE

/obj/structure/psistation/strange_server3
	name = "Server"
	desc = "A strange server with digital blocks inside, they make a small hum when working, the door won't close, a smart lock."
	icon = 'mods/_maps/psistation/psistation_sprites.dmi'
	icon_state = "server_open3"
	anchored = TRUE
	density = TRUE

/obj/structure/psistation/strange_server2
	name = "Server"
	desc = "A strange server, inside of which there are digital blocks, but one is missing, they make a small hum when working, the door does not close, a smart lock."
	icon = 'mods/_maps/psistation/psistation_sprites.dmi'
	icon_state = "server_open2"
	anchored = TRUE
	density = TRUE

/obj/structure/psistation/strange_server0
	name = "Server"
	desc = "A strange server, which is empty inside, you can see places for something, the door does not close, a smart lock."
	icon = 'mods/_maps/psistation/psistation_sprites.dmi'
	icon_state = "server_open0"
	anchored = TRUE
	density = TRUE

/obj/structure/psistation/technological_monolith_c
	name = "Closed technological monolith"
	desc = "Very strange and frightening machinery, it seems that locks are visible along the contour of the lid, they cannot be opened."
	icon = 'mods/_maps/psistation/psistation_sprites.dmi'
	icon_state = "strangecoffin_closed"
	anchored = TRUE
	density = TRUE

/obj/structure/psistation/technological_monolith
	name = "Technological monolith"
	desc = "Very strange and scary machinery, indicators actively blink, scan and emit a low squeak, the lid does not close."
	icon = 'mods/_maps/psistation/psistation_sprites.dmi'
	icon_state = "strangecoffin_open"
	anchored = TRUE
	density = TRUE

/obj/structure/psistation/technological_scanner
	name = "Technological Scanner"
	desc = "A very strange and big, huge scanner."
	icon = 'mods/_maps/psistation/psistation_sprites_96.dmi'
	icon_state = "mega_scan"
	anchored = TRUE

/obj/structure/psistation/technological_scanner_a
	name = "Technological Scanner"
	desc = "A very strange and big, huge scanner, it is active."
	icon = 'mods/_maps/psistation/psistation_sprites_96.dmi'
	icon_state = "mega_scan2"
	anchored = TRUE

///mob

/mob/living/simple_animal/hostile/hivebot/ranged_damage/fleet_robot/foundation
	faction = "foundation"
	icon = 'mods/_maps/psistation/psistation_sprites.dmi'
	icon_state = "secbotlaser"
	icon_dead = "secbotlaser"
	explosion_radius = 2
	explosion_max_power = EX_ACT_LIGHT


/mob/living/simple_animal/hostile/hivebot/ranged_damage/fleet_robot/foundation/stun
	icon_state = "secbotstun"
	icon_dead = "secbotstun"

	projectiletype = /obj/item/projectile/beam/stun/smalllaser
	projectilesound = 'sound/weapons/plasma_cutter.ogg'

/mob/living/simple_animal/hostile/hivebot/ranged_damage/fleet_robot/foundation/stun/shield
	icon_state = "secbotstunriot"
	icon_dead = "secbotstunriot"
	natural_armor = list(
		melee = ARMOR_MELEE_MAJOR,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		laser = ARMOR_LASER_MAJOR,
		energy = ARMOR_ENERGY_SMALL,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SHIELDED
		)

/mob/living/simple_animal/hostile/hivebot/ranged_damage/fleet_robot/foundation/claws
	icon_state = "secbotclaws"
	icon_dead = "secbotclaws"

	projectiletype = null
	natural_weapon = /obj/item/natural_weapon/claws
	ai_holder = /datum/ai_holder/simple_animal/hivebot

/obj/landmark/corpse/bloody/LateInitialize(mapload)
	var/new_species = pickweight(species)
	var/mob/living/carbon/human/corpse = new (loc, new_species)
	corpse.adjustOxyLoss(corpse.maxHealth)
	corpse.setBrainLoss(corpse.maxHealth)
	corpse.adjustBruteLoss(corpse.maxHealth)
	corpse.faction = MOB_FACTION_NEUTRAL
	var/obj/item/organ/internal/heart/heart = corpse.internal_organs_by_name[BP_HEART]
	if (heart)
		heart.pulse = PULSE_NONE
	randomize_appearance(corpse, new_species)
	equip_outfit(corpse)
	corpse.update_icon()
	qdel(src)

/obj/landmark/corpse/husk/LateInitialize(mapload)
	var/new_species = pickweight(species)
	var/mob/living/carbon/human/corpse = new (loc, new_species)
	corpse.adjustOxyLoss(corpse.maxHealth)
	corpse.setBrainLoss(corpse.maxHealth)
	corpse.adjustFireLoss(corpse.maxHealth)
	corpse.ChangeToHusk()
	corpse.faction = MOB_FACTION_NEUTRAL
	var/obj/item/organ/internal/heart/heart = corpse.internal_organs_by_name[BP_HEART]
	if (heart)
		heart.pulse = PULSE_NONE
	randomize_appearance(corpse, new_species)
	equip_outfit(corpse)
	corpse.update_icon()
	qdel(src)
