// Wouldnt work with any other map, apart from sierra
/singleton/hierarchy/outfit/vr
	name = "VR"

/singleton/hierarchy/outfit/vr/pirate
	name = "VR - Pirate"

/singleton/hierarchy/outfit/vr/pirate/captain
	name = "VR - Pirate - Captain"
	uniform = /obj/item/clothing/under/pirate
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/eyepatch
	l_hand = /obj/item/melee/energy/sword/pirate
	head = /obj/item/clothing/head/helmet/pirate
	suit = /obj/item/clothing/suit/pirate
	flags = OUTFIT_RESET_EQUIPMENT

/singleton/hierarchy/outfit/vr/mercenary
	name = "VR - Terrorist - Mercenary"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	l_ear = /obj/item/device/radio/headset/syndicate/alt
	belt = /obj/item/storage/belt/holster/security/tactical
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/thick/swat

	id_slot = slot_wear_id
	id_types = list(/obj/item/card/id/syndicate)
	id_pda_assignment = "Mercenary"

	backpack_contents = list(/obj/item/clothing/mask/gas/syndicate = 1)

	flags = OUTFIT_HAS_BACKPACK|OUTFIT_RESET_EQUIPMENT

/singleton/hierarchy/outfit/vr/mercenary/armored
	name = "VR - Terrorist - Armored"
	suit = /obj/item/clothing/suit/armor/vest
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/helmet/swat
	shoes = /obj/item/clothing/shoes/swat

/singleton/hierarchy/outfit/vr/mercenary/voidsuit
	name = "VR - Terrorist - Voidsuit"
	suit = /obj/item/clothing/suit/space/void/merc
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/helmet/space/void/merc

/singleton/hierarchy/outfit/vr/mercenary/hardsuit
	name = "VR - Terrorist - Hardsuit"
	mask = /obj/item/clothing/mask/gas
	back = /obj/item/rig/merc
	backpack_contents = null

	flags = OUTFIT_RESET_EQUIPMENT

/singleton/hierarchy/outfit/vr/stealth
	name = "VR - Stealth suit"
	uniform = /obj/item/clothing/under/color/black
	shoes = null
	gloves = null
	back = /obj/item/rig/light/stealth

	flags = OUTFIT_RESET_EQUIPMENT

/singleton/hierarchy/outfit/vr/ert
	name = "VR - ERT"
	uniform = /obj/item/clothing/under/ert
	shoes = /obj/item/clothing/shoes/swat
	gloves = /obj/item/clothing/gloves/thick/swat
	l_ear = /obj/item/device/radio/headset/ert
	glasses = /obj/item/clothing/glasses/sunglasses
	back = /obj/item/storage/backpack/satchel

	id_slot = slot_wear_id
	id_types = list(/obj/item/card/id/centcom/station/ert)

/singleton/hierarchy/outfit/vr/ert/hardsuit
	name = "VR - ERT - Hardsuit"
	gloves = null
	shoes = null
	mask = /obj/item/clothing/mask/gas
	flags = OUTFIT_RESET_EQUIPMENT

/singleton/hierarchy/outfit/vr/ert/hardsuit/commander
	name = "VR - ERT - Commander"
	back = /obj/item/rig/ert

/singleton/hierarchy/outfit/vr/ert/hardsuit/medical
	name = "VR - ERT - Medical"
	back = /obj/item/rig/ert/medical

/singleton/hierarchy/outfit/vr/ert/hardsuit/engineer
	name = "VR - ERT - Engineer"
	back = /obj/item/rig/ert/engineer

/singleton/hierarchy/outfit/vr/ert/hardsuit/security
	name = "VR - ERT - Security"
	back = /obj/item/rig/ert/security

/singleton/hierarchy/outfit/vr/ert/hardsuit/janitor
	name = "VR - ERT - Janitor"
	back = /obj/item/rig/ert/janitor

/singleton/hierarchy/outfit/vr/icgn
	name = "VR - ICGN"
	uniform = /obj/item/clothing/under/iccgn/utility
	suit = /obj/item/clothing/suit/iccgn/utility
	id_types = list(/obj/item/card/id/awayiccgn/droptroops)
	belt = /obj/item/storage/belt/holster/security/tactical/farfleet
	gloves = /obj/item/clothing/gloves/thick/combat

/singleton/hierarchy/outfit/vr/icgn/voidsuit
	name = "VR - ICGN - Voidsuit"
	head = /obj/item/clothing/head/helmet/space/void/pioneer
	suit = /obj/item/clothing/suit/space/void/pioneer
	mask = /obj/item/clothing/mask/gas

/singleton/hierarchy/outfit/vr/icgn/hardsuit
	name = "VR - ICGN - Hardsuit"
	gloves = null
	shoes = null
	back = /obj/item/rig/pioneer
	mask = /obj/item/clothing/mask/gas

	flags = OUTFIT_RESET_EQUIPMENT


/datum/controller/subsystem/virtual_reality/Initialize(start_timeofday)
	. = ..()

	// special zones
	GLOB.active_vr_areas["Thunderdome"] = null
	GLOB.vr_spawns["Thunderdome Team 1"] = list()
	GLOB.vr_spawns["Thunderdome Team 2"] = list()
	GLOB.vr_spawns["Thunderdome Spectators"] = list()

	for(var/obj/landmark/L in locate(/area/tdome/tdome1))
		var/turf/T = get_turf(L)
		var/obj/effect/vr_spawn/V = new(T)
		GLOB.vr_spawns["Thunderdome Team 1"] += V

	for(var/obj/landmark/L in locate(/area/tdome/tdome2))
		var/turf/T = get_turf(L)
		var/obj/effect/vr_spawn/V = new(T)
		GLOB.vr_spawns["Thunderdome Team 2"] += V

	for(var/obj/landmark/L in locate(/area/tdome/tdomeobserve))
		var/turf/T = get_turf(L)
		var/obj/effect/vr_spawn/V = new(T)
		GLOB.vr_spawns["Thunderdome Spectators"] += V

/datum/controller/subsystem/virtual_reality/after_mob_creation(mob/living/L, zone)
	. = ..()
	if(zone == "Thunderdome")
		L.verbs += /mob/living/proc/select_vr_equipment
		L.verbs += /mob/living/proc/spawn_vr_item

/mob/living/proc/select_vr_equipment()
	set name = "Select Tournament Equipment"
	set desc = "Pick a provided set of equipment."
	set category = "VR"
	set src = usr

	var/list/available_outfits = list()


	available_outfits = list(
		"NT officer" = /singleton/hierarchy/outfit/nanotrasen/officer,
		"NT commander" = /singleton/hierarchy/outfit/nanotrasen/commander,
		"ERT" = /singleton/hierarchy/outfit/vr/ert,
		"ERT - medical" = /singleton/hierarchy/outfit/vr/ert/hardsuit/medical,
		"ERT - engineer" = /singleton/hierarchy/outfit/vr/ert/hardsuit/engineer,
		"ERT - security" = /singleton/hierarchy/outfit/vr/ert/hardsuit/security,
		"ERT - commander" = /singleton/hierarchy/outfit/vr/ert/hardsuit/commander,
		"ERT - janitor" = /singleton/hierarchy/outfit/vr/ert/hardsuit/janitor,
		"SCG Marine" = /singleton/hierarchy/outfit/scg/troops/standart,
		"SCG Marine Engineer" = /singleton/hierarchy/outfit/scg/troops/engineer,
		"SCG Marine Medic" = /singleton/hierarchy/outfit/scg/troops/medic,
		"SCG Marine Sergeant" = /singleton/hierarchy/outfit/scg/troops/sergeant,
		"ICGN Voidsuit" = /singleton/hierarchy/outfit/vr/icgn/voidsuit,
		"ICGN Hardsuit" = /singleton/hierarchy/outfit/vr/icgn/hardsuit,
		"Pirate" = /singleton/hierarchy/outfit/pirate/norm,
		"Pirate captain" = /singleton/hierarchy/outfit/vr/pirate/captain,
		"Terrorist" = /singleton/hierarchy/outfit/vr/mercenary,
		"Terrorist - Armored" = /singleton/hierarchy/outfit/vr/mercenary/armored,
		"Terrorist - Voidsuit" = /singleton/hierarchy/outfit/vr/mercenary/voidsuit,
		"Terrorist - Hardsuit" = /singleton/hierarchy/outfit/vr/mercenary/hardsuit,
		"Stealth Suit" = /singleton/hierarchy/outfit/vr/stealth,
		"Tournamet gear - red" = /singleton/hierarchy/outfit/tournament_gear/red,
		"Tournamet gear - green" = /singleton/hierarchy/outfit/tournament_gear/green,
		"Tournamet gear - chef" = /singleton/hierarchy/outfit/tournament_gear/chef,
		"Tournamet gear - janitor" = /singleton/hierarchy/outfit/tournament_gear/janitor,
	)

	var/outfit_name = input("Select outfit.", "Select equipment.") as null|anything in available_outfits

	var/singleton/hierarchy/outfit/outfit

	if(outfit_name)
		outfit = GET_SINGLETON(available_outfits[outfit_name])

	if(!outfit)
		return
	var/reset_equipment = (outfit.flags&OUTFIT_RESET_EQUIPMENT)
	if(!reset_equipment)
		reset_equipment = alert("Do you wish to delete all current equipment first?", "Delete Equipment?","Yes", "No") == "Yes"
	dressup_human(src, outfit, reset_equipment)

	var/list/held_items = src.GetAllHeld(/obj/item/storage/box)

	for(var/obj/item/storage/box/B in held_items)
		qdel(B)

	var/mob/living/occupant = SSvirtual_reality.virtual_mobs_to_occupants[src]
	var/list/real_access = list()
	if(occupant)
		var/obj/item/card/id/O = occupant.GetIdCard()

		if(O)
			real_access = O.access.Copy()

	for(var/obj/item/card/id/I in src)
		I.access = real_access

/mob/living/proc/spawn_vr_item()
	set name = "Spawn VR item"
	set desc = "Pick an item to spawn."
	set category = "VR"
	set src = usr

	var/item_type

	item_type = input("What to spawn", "Select spawn type") as null|anything in list("Gun", "Ammo", "Melee weapon")

	if(item_type == "Gun")
		var/list/available_gun = typesof(/obj/item/gun)
		var/path_gun = input("Select a gun.", "Select gun.") as null|anything in available_gun
		if(path_gun)
			new path_gun(get_turf(src))
	else if(item_type == "Ammo")
		var/list/available_ammo = list()
		available_ammo += typesof(/obj/item/ammo_magazine)
		available_ammo += typesof(/obj/item/ammobox)
		available_ammo += typesof(/obj/item/ammo_casing)

		var/path_ammo = input("Select ammo for spawn.", "Select ammo.") as null|anything in available_ammo
		if(path_ammo)
			new path_ammo(get_turf(src))
	else if(item_type == "Melee weapon")
		var/list/available_melee = typesof(/obj/item/melee)
		available_melee -= typesof(/obj/item/melee/changeling)
		available_melee += typesof(/obj/item/material/sword)
		available_melee += typesof(/obj/item/material/twohanded)
		var/path_melee = input("Select melee weapon.", "Select melee.") as null|anything in available_melee
		if(path_melee)
			new path_melee(get_turf(src))