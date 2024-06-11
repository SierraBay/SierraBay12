/obj/random/colony_flag
  name = "Colony flag"

/obj/random/colony_armor
	name = "random colony armor"

/obj/random/colony_helmet
	name  = "random colony helmet"

/obj/random/colony_smg
	name = "random colony smg"

/obj/random/colony_rifle
	name = "random colony rifle"

/obj/structure/sign/colony
	name = "Independent colony"
	icon = 'mods/colony_fractions/icons/colony.dmi'
	icon_state = "colony"

/obj/random/colony_paper
	name = "Colony instructions paper"

/obj/random/colony2_paper
	name = "Colony instructions paper"

/obj/submap_landmark/spawnpoint/ship_leader_spawn
	name = "Ship Leader"

/obj/submap_landmark/spawnpoint/colonist_leader_spawn
	name = "Colonist Leader"

//Actual weapons, armor, etc. Colonial versions becauses reasons.

/obj/item/gun/projectile/automatic/colony_mbr
	name = "MBR"
	desc = "A shabby bullpup carbine. Despite its size, it looks a little uncomfortable, but it is robust. HelTek MBR is a standart equipment of ICCG Space-assault Forces, designed in a bullpup layout. Possesses autofire and is perfect for the ship's crew."
	icon = 'mods/_maps/farfleet/icons/obj/mbr_bullpup.dmi'
	icon_state = "mbr_bullpup"
	item_state = "mbr_bullpup"
	item_icons = list(
		slot_r_hand_str = 'mods/_maps/farfleet/icons/mob/righthand.dmi',
		slot_l_hand_str = 'mods/_maps/farfleet/icons/mob/lefthand.dmi',
		)
	wielded_item_state = "mbr_bullpup-wielded"
	force = 10
	caliber = CALIBER_RIFLE
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ESOTERIC = 5)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/rifle
	allowed_magazines = /obj/item/ammo_magazine/rifle
	bulk = GUN_BULK_RIFLE + 1
	mag_insert_sound = 'sound/weapons/guns/interaction/ltrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/ltrifle_magout.ogg'

	firemodes = list(
		list(mode_name="semi auto",      burst=1,    fire_delay=null, one_hand_penalty=8,  burst_accuracy=null,                dispersion=null),
		list(mode_name="2-round bursts", burst=2,    fire_delay=null, one_hand_penalty=9,  burst_accuracy=list(0,-1,-1),       dispersion=list(0.0, 0.6, 1.0)),
		list(mode_name="full auto",      burst=1,    fire_delay=1.7,    burst_delay=1.3,     one_hand_penalty=7,  burst_accuracy=list(0,-1,-1), dispersion=list(1.3, 1.5, 1.7, 1.9, 2.2), autofire_enabled=1)
		)

/obj/item/gun/projectile/automatic/colony_mbr/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "mbr_bullpup"
	else
		icon_state = "mbr_bullpup-empty"

/obj/item/gun/projectile/automatic/assault_rifle/heltek_colony
	name = "LA-700"
	desc = "HelTek LA-700 is a standart equipment of ICCG Space-assault Forces. Looks very similiar to STS-35."
	icon = 'mods/_maps/farfleet/icons/obj/iccg_rifle.dmi'
	icon_state = "iccg_rifle"

/obj/item/gun/projectile/automatic/assault_rifle/heltek_colony/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "iccg_rifle"
		wielded_item_state = "arifle-wielded"
	else
		icon_state = "iccg_rifle-empty"
		wielded_item_state = "arifle-wielded-empty"

/obj/item/gun/projectile/automatic/mr735_colony
	name = "MR-735"
	desc = "A cheap rifle for close quarters combat, with an auto-firing mode available. HelTek MR-735 is a standard rifle for ICCG Space-assault Forces, designed without a stock for easier storage and combat in closed spaces. Perfect weapon for some ship's crew."
	icon = 'mods/_maps/farfleet/icons/obj/mr735.dmi'
	icon_state = "nostockrifle"
	item_state = "nostockrifle"
	item_icons = list(
		slot_r_hand_str = 'mods/_maps/farfleet/icons/mob/righthand.dmi',
		slot_l_hand_str = 'mods/_maps/farfleet/icons/mob/lefthand.dmi',
		)
	wielded_item_state = "nostockrifle_wielded"
	force = 10
	caliber = CALIBER_RIFLE
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ESOTERIC = 5)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/rifle
	allowed_magazines = /obj/item/ammo_magazine/rifle
	bulk = GUN_BULK_RIFLE
	mag_insert_sound = 'sound/weapons/guns/interaction/ltrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/ltrifle_magout.ogg'

	//Assault rifle, burst fire degrades quicker than SMG, worse one-handing penalty, slightly increased move delay
	firemodes = list(
		list(mode_name="semi auto",      burst=1,    fire_delay=null, one_hand_penalty=8,  burst_accuracy=null,                dispersion=null),
		list(mode_name="2-round bursts", burst=2,    fire_delay=null, one_hand_penalty=9,  burst_accuracy=list(0,-1,-1),       dispersion=list(0.0, 0.6, 1.0)),
		list(mode_name="full auto",      burst=1,    fire_delay=1.7,    burst_delay=1.3,     one_hand_penalty=7,  burst_accuracy=list(0,-1,-1), dispersion=list(1.3, 1.5, 1.7, 1.9, 2.2), autofire_enabled=1)
		)

/obj/item/gun/projectile/automatic/mr735_colony/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "nostockrifle"
		wielded_item_state = "nostockrifle-wielded"
	else
		icon_state = "nostockrifle-empty"
		wielded_item_state = "nostockrifle-wielded-empty"

/obj/item/clothing/head/helmet/solgov_colony
	accessories = list(/obj/item/clothing/accessory/helmet_cover/blue/sol)
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_head_solgov_unathi.dmi'
		)

/obj/item/clothing/head/helmet/solgov_colony/security
	name = "security helmet"
	desc = "A helmet with 'POLICE' printed on the back in silver lettering."
	icon_state = "helmet_security"
	icon = 'maps/torch/icons/obj/obj_head_solgov.dmi'
	item_icons = list(slot_head_str = 'maps/torch/icons/mob/onmob_head_solgov.dmi')
	accessories = null

/obj/item/clothing/head/helmet/solgov_colony/command
	name = "command helmet"
	desc = "A helmet with 'SOL CENTRAL GOVERNMENT' printed on the back in gold lettering."
	icon_state = "helmet_command"
	icon = 'maps/torch/icons/obj/obj_head_solgov.dmi'
	item_icons = list(slot_head_str = 'maps/torch/icons/mob/onmob_head_solgov.dmi')
	accessories = null

/obj/item/clothing/head/helmet/solgov_colony/pilot
	name = "pilot's helmet"
	desc = "A pilot's helmet for operating the cockpit in style. For when you want to protect your noggin AND look stylish."
	icon_state = "pilotgov"
	accessories = null

/obj/item/clothing/head/helmet/solgov_colony/pilot/fleet
	name = "fleet pilot's helmet"
	desc = "A pilot's helmet for operating the cockpit in style. This one is worn by members of the SCG Fleet."
	icon = 'maps/torch/icons/obj/obj_head_solgov.dmi'
	icon_state = "pilotfleet"
	item_icons = list(slot_head_str = 'maps/torch/icons/mob/onmob_head_solgov.dmi')
	accessories = null

/obj/item/clothing/suit/armor/vest/solgov_colony
	name = "\improper Sol Central Government armored vest"
	desc = "A synthetic armor vest. This one is marked with the crest of the Sol Central Government."
	icon_state = "solvest"
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_suit_solgov_unathi.dmi'
	)

/obj/item/clothing/suit/storage/vest/solgov_colony
	name = "\improper Sol Central Government heavy armored vest"
	desc = "A synthetic armor vest with PEACEKEEPER printed in distinctive blue lettering on the chest. This one has added webbing and ballistic plates."
	icon_state = "solwebvest"
	icon = 'maps/torch/icons/obj/obj_suit_solgov.dmi'
	item_icons = list(slot_wear_suit_str = 'maps/torch/icons/mob/onmob_suit_solgov.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_suit_solgov_unathi.dmi'
	)

/obj/item/clothing/suit/storage/vest/solgov_colony/security
	name = "master at arms heavy armored vest"
	desc = "A synthetic armor vest with MASTER AT ARMS printed in silver lettering on the chest. This one has added webbing and ballistic plates."
	icon_state = "secwebvest"

/obj/item/clothing/suit/storage/vest/solgov_colony/command
	name = "command heavy armored vest"
	desc = "A synthetic armor vest with SOL CENTRAL GOVERNMENT printed in gold lettering on the chest. This one has added webbing and ballistic plates."
	icon_state = "comwebvest"

/obj/item/clothing/suit/armor/pcarrier/troops_colony
	accessories  = list(/obj/item/clothing/accessory/armor_plate/medium, /obj/item/clothing/accessory/storage/pouches)

/obj/item/clothing/suit/armor/pcarrier/troops_colony/heavy
	accessories  = list(/obj/item/clothing/accessory/armor_plate/medium, /obj/item/clothing/accessory/arm_guards, /obj/item/clothing/accessory/leg_guards, /obj/item/clothing/accessory/storage/pouches)

/obj/item/clothing/suit/armor/pcarrier/tactical_colony
	accessories  = list(/obj/item/clothing/accessory/armor_plate/tactical, /obj/item/clothing/accessory/arm_guards, /obj/item/clothing/accessory/leg_guards)
