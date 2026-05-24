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

/singleton/hierarchy/outfit/vr/surgeon
	name = "VR - Surgeon"
	uniform = /obj/item/clothing/under/rank/medical/scrubs/blue
	head = /obj/item/clothing/head/surgery/blue
	glasses = /obj/item/clothing/glasses/hud/health/goggle/prescription
	mask = /obj/item/clothing/mask/surgical
	suit = /obj/item/clothing/suit/surgicalapron
	gloves = /obj/item/clothing/gloves/latex/nitrile
	shoes = /obj/item/clothing/shoes/blue

/datum/controller/subsystem/virtual_reality
	var/list/vr_spawn_categories = list()
	var/list/vr_spawn_categories_by_zone = list()
	var/list/vr_spawn_cooldown = list()

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


	// Items
	vr_spawn_categories["Gun"] = typesof(/obj/item/gun)

	vr_spawn_categories["Ammo"] = typesof(/obj/item/ammo_magazine)
	vr_spawn_categories["Ammo"] += typesof(/obj/item/ammobox)
	vr_spawn_categories["Ammo"] += typesof(/obj/item/ammo_casing)

	vr_spawn_categories["Melee weapon"] = typesof(/obj/item/melee)
	vr_spawn_categories["Melee weapon"] -= typesof(/obj/item/melee/changeling)
	vr_spawn_categories["Melee weapon"] += typesof(/obj/item/material/sword)
	vr_spawn_categories["Melee weapon"] += typesof(/obj/item/material/twohanded)

	vr_spawn_categories["Medical supplies"] = list(
		/obj/item/stack/material/steel/fifty,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/ivbag/nanoblood,
		/obj/item/reagent_containers/food/snacks/candy/donor,
		/obj/item/reagent_containers/spray/cleaner,
		/obj/item/reagent_containers/spray/sterilizine,
		/obj/item/reagent_containers/glass/bottle/adminordrazine
	)

	vr_spawn_categories["Food"] = typesof(/obj/item/reagent_containers/food/snacks)

	vr_spawn_categories["Drinks"] = typesof(/obj/item/reagent_containers/food/drinks)

	vr_spawn_categories["Utensil"] = typesof(/obj/item/material/utensil)

	vr_spawn_categories_by_zone["Thunderdome"] = list("Gun", "Ammo", "Melee weapon")
	vr_spawn_categories_by_zone["Summer Cafe"] = list("Food", "Drinks", "Utensil")
	vr_spawn_categories_by_zone["Infirmary"] = list("Medical supplies")

/datum/controller/subsystem/virtual_reality/after_mob_creation(mob/living/L, zone)
	. = ..()
	var/area/zone_area = GLOB.active_vr_areas[zone]
	var/zone_name = ""

	if(zone_area)
		zone_name = SSvirtual_reality.zone_current_area[zone_area.name]

	if(zone == "Thunderdome" || zone_name && vr_spawn_categories_by_zone[zone_name])
		L.verbs += /mob/living/proc/select_vr_equipment
		L.verbs += /mob/living/proc/spawn_vr_item

/datum/controller/subsystem/virtual_reality/proc/vr_spawn_menu(mob/user, list/paths, item_type)
	var/objectjs = null
	objectjs = jointext(paths, ";")
	var/vr_object_html = ""
	vr_object_html = file2text('mods/vr/html/vr_create_object.html')
	vr_object_html = replacetext(vr_object_html, "null /* object types */", "\"[objectjs]\"")
	vr_object_html = replacetext(vr_object_html, "/* ref category */", "[item_type]")

	show_browser(user, replacetext(vr_object_html, "/* ref src */", "\ref[src]"), "window=vr_create_object;size=425x530")

/datum/controller/subsystem/virtual_reality/Topic(href, href_list)
	if(href_list["vr_object_list"])
		if(!virtual_mobs_to_occupants[usr])
			alert("Not a VR mob")
			return
		if(vr_spawn_cooldown[usr] && vr_spawn_cooldown[usr] > world.time )
			to_chat(usr, SPAN_WARNING("Wait a few seconds before spawning a new item."))
			return

		var/category = href_list["category"]
		var/area/user_area = get_area(usr)
		var/zone_name = ""

		if(user_area)
			zone_name = SSvirtual_reality.zone_current_area[user_area.name]

		if(istype(user_area, /area/tdome))
			zone_name = "Thunderdome"

		if(!vr_spawn_categories[category] || !vr_spawn_categories_by_zone[zone_name] || !(category in vr_spawn_categories_by_zone[zone_name]))
			alert("There is no such category.")
			return

		var/dirty_paths
		if (istext(href_list["vr_object_list"]))
			dirty_paths = list(href_list["vr_object_list"])
		else if (istype(href_list["vr_object_list"], /list))
			dirty_paths = href_list["vr_object_list"]

		var/paths = list()

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if (!prevent_spawn_reason(path))
				if(!(path in vr_spawn_categories[category]))
					alert("There is no such item.")
					return
				paths += path

		if(!paths)
			alert("The path list you sent is empty")
			return
		if(length(paths) > 1)
			alert("Select fewer object types, (max 1)")
			return

		var/number = 1

		var/atom/target = get_turf(usr)

		if(target)
			for (var/path in paths)
				for (var/i = 0; i < number; i++)
					if(path in typesof(/turf))
						var/turf/O = target
						O.ChangeTurf(path)
					else
						new path(target)

		vr_spawn_cooldown[usr] = world.time + 5 SECONDS
		return


/mob/living/proc/select_vr_equipment()
	set name = "Select VR Equipment"
	set desc = "Pick a provided set of equipment."
	set category = "VR"
	set src = usr

	var/mob/living/carbon/human/H = src

	if(!H)
		return

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
	) // default

	var/area/user_area = get_area(usr)
	var/zone_name = ""

	if(user_area)
		zone_name = SSvirtual_reality.zone_current_area[user_area.name]

	if(zone_name)
		switch(zone_name)
			if("Infirmary")
				available_outfits = list(
					"Surgeon" = /singleton/hierarchy/outfit/vr/surgeon,
					"Paramedic" = /singleton/hierarchy/outfit/job/sierra/crew/medical/paramedic
				)
			if("Summer Cafe")
				available_outfits = list()

	if(!LAZYLEN(available_outfits))
		to_chat(usr, SPAN_WARNING("No equipment to spawn."))
		return

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

	var/available_categories = list("Gun", "Ammo", "Melee weapon") // default

	var/area/user_area = get_area(usr)
	var/zone_name = ""

	if(user_area)
		zone_name = SSvirtual_reality.zone_current_area[user_area.name]

	if(zone_name)
		if(SSvirtual_reality.vr_spawn_categories_by_zone[zone_name])
			available_categories = SSvirtual_reality.vr_spawn_categories_by_zone[zone_name]

	if(!LAZYLEN(available_categories))
		to_chat(usr, SPAN_WARNING("No items to spawn."))
		return

	item_type = input("What to spawn", "Select spawn type") as null|anything in available_categories

	if(item_type)
		var/list/available_obj = list()

		available_obj = SSvirtual_reality.vr_spawn_categories[item_type]

		if(!LAZYLEN(available_obj))
			to_chat(usr, SPAN_WARNING("No items to spawn."))
			return

		SSvirtual_reality.vr_spawn_menu(usr, available_obj, item_type)