/* FOUNDATION ARMOR AND FLUFF
 * ========
 */

/obj/item/clothing/head/helmet/foundation
	name = "\improper Strike Team helmet"
	desc = "A helmet with green stripe and radiotelescope emblem on it."
	icon_state = "helmet_pcrc"
	accessories = list(/obj/item/clothing/accessory/helmet_cover/foundation, /obj/item/clothing/accessory/glassesmod/psi)
	armor = list(
		melee = ARMOR_MELEE_MAJOR,
		bullet = ARMOR_BALLISTIC_RIFLE,
		laser = ARMOR_LASER_HANDGUNS,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED
		)
	siemens_coefficient = 0.6


/obj/item/clothing/suit/armor/pcarrier/troops/heavy/foundation
	accessories = list(/obj/item/clothing/accessory/armor_plate/tactical,
						/obj/item/clothing/accessory/arm_guards,
						/obj/item/clothing/accessory/leg_guards,
						/obj/item/clothing/accessory/storage/pouches,
						/obj/item/clothing/accessory/armor_tag/foundation
	)


/obj/item/clothing/accessory/helmet_cover/foundation
	name = "\improper Foundation helmet cover"
	desc = "A fabric cover for armored helmets. This one has Cuchulain Foundation's colors."
	icon_state = "helmcover_foundation"
	icon_override = 'mods/psionics/icons/foundation/foundation_onmob.dmi'
	icon = 'mods/psionics/icons/foundation/foundation_obj.dmi'
	accessory_icons = list(
		slot_tie_str = 'mods/psionics/icons/foundation/foundation_onmob.dmi',
		slot_head_str = 'mods/psionics/icons/foundation/foundation_onmob.dmi'
	)

/obj/item/clothing/accessory/armor_tag/foundation
	name = "\improper Foundation tag"
	desc = "An armor tag with the radiotelescope emblem on it."
	icon_state = "foundationtag"
	icon_override = 'mods/psionics/icons/foundation/foundation_onmob.dmi'
	icon = 'mods/psionics/icons/foundation/foundation_obj.dmi'
	accessory_icons = list(
		slot_tie_str = 'mods/psionics/icons/foundation/foundation_onmob.dmi',
		slot_wear_suit_str = 'mods/psionics/icons/foundation/foundation_onmob.dmi'
	)

/obj/item/clothing/accessory/armband/foundation
	name = "Foundation armband"
	icon = 'mods/psionics/icons/foundation/foundation_obj.dmi'
	accessory_icons = list(slot_w_uniform_str = 'mods/psionics/icons/foundation/foundation_onmob.dmi', slot_wear_suit_str = 'mods/psionics/icons/foundation/foundation_onmob.dmi')
	icon_state = "foundationband"

/obj/item/clothing/under/color/black/foundation
	name = "Foundation layered undersuit"
	desc = "A thick, layered black undersuit lined with power cables filled with psi-disrupting materials."
	accessories = list(/obj/item/clothing/accessory/armband/foundation)

/obj/item/clothing/under/color/black/foundation/disrupts_psionics()
	return src

/obj/item/clothing/mask/gas/foundation
	name = "tactical mask"
	desc = "A close-fitting tactical mask whith green visor, that can be connected to an air supply."
	icon = 'mods/psionics/icons/foundation/foundation_obj.dmi'
	icon_state = "foundation_gas_mask"
	item_state = "foundation_gas_mask"
	item_icons = list(slot_wear_mask_str = 'mods/psionics/icons/foundation/foundation_onmob.dmi')
	siemens_coefficient = 0.7
	armor = list(
		melee = ARMOR_MELEE_SMALL,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_MINOR,
		bio = ARMOR_BIO_STRONG
		)

/obj/item/card/id/centcom/foundation
	name = "\improper Cuchulain Foundation PID ID"
	registered_name = "Physical Impact Department"
	assignment = "Strike Team Witchsword"
	color = COLOR_OFF_WHITE
	detail_color = COLOR_PAKISTAN_GREEN
	extra_details = list("onegoldstripe")

/obj/item/card/id/centcom/foundation/New()
	..()
	access |= get_all_station_access()

/* FOUNDATION OUTFITS
 * ========
 */

/singleton/hierarchy/outfit/foundation
	name = "Cuchulain Foundation Agent"
	glasses =  /obj/item/clothing/glasses/sunglasses
	uniform =  /obj/item/clothing/under/suit_jacket/charcoal
	suit =     /obj/item/clothing/suit/storage/toggle/suit/black
	shoes =    /obj/item/clothing/shoes/dress
	l_hand =   /obj/item/storage/briefcase/foundation
	l_ear =    /obj/item/device/radio/headset/foundation
	holster =  /obj/item/clothing/accessory/storage/holster/armpit
	l_pocket = /obj/item/device/flash/advanced
	id_slot =  slot_wear_id

/singleton/hierarchy/outfit/foundation/mtf
	name = "Cuchulain Foundation Operative"
	head = /obj/item/clothing/head/helmet/foundation
	mask = /obj/item/clothing/mask/gas/foundation
	glasses =  /obj/item/clothing/glasses/hud/security/prot/sunglasses
	uniform =  /obj/item/clothing/under/color/black/foundation
	suit = /obj/item/clothing/suit/armor/pcarrier/troops/heavy/foundation
	shoes =    /obj/item/clothing/shoes/jackboots
	l_hand =   null
	l_ear =    /obj/item/device/radio/headset/ert
	r_hand = /obj/item/gun/projectile/automatic/sol_smg
	r_pocket = /obj/item/device/radio
	gloves = /obj/item/clothing/gloves/thick/swat
	holster = /obj/item/clothing/accessory/storage/holster/thigh
	belt = /obj/item/storage/belt/holster/security/foundation
	back = /obj/item/storage/backpack
	id_slot = slot_wear_id
	id_types = list(/obj/item/card/id/centcom/foundation)
	backpack_contents = list(
		/obj/item/storage/firstaid/sleekstab = 1,
		/obj/item/handcuffs = 2,
		/obj/item/plastique = 1,
		/obj/item/silencer/medium = 1
	)
	flags = OUTFIT_RESET_EQUIPMENT

/obj/item/storage/belt/holster/security/foundation/New()
	..()
	new /obj/item/gun/projectile/revolver/foundation(src)
	new /obj/item/ammo_magazine/speedloader/magnum/nullglass(src)
	new /obj/item/ammo_magazine/smg_sol(src)
	new /obj/item/ammo_magazine/smg_sol(src)
	new /obj/item/ammo_magazine/smg_sol(src)
	new /obj/item/grenade/chem_grenade/nullgas(src)

// Simplemobs outfits

/singleton/hierarchy/outfit/foundation/hostile
	name = "Cuchulain Foundation - Hostile"
	head = /obj/item/clothing/head/helmet/foundation
	mask = /obj/item/clothing/mask/gas/foundation
	glasses = /obj/item/clothing/glasses/sunglasses
	uniform =  /obj/item/clothing/under/color/black/foundation
	suit = /obj/item/clothing/suit/armor/pcarrier/troops/heavy/foundation
	shoes =    /obj/item/clothing/shoes/jackboots
	l_hand =   null
	l_ear =    null
	r_hand =   null
	l_pocket = null
	r_pocket = null
	gloves = /obj/item/clothing/gloves/thick/swat
	holster =  null
	belt =     null

/singleton/hierarchy/outfit/foundation/hostile/pilot
	name = "Cuchulain Foundation - Hostile Pilot"
	mask = /obj/item/clothing/mask/gas/foundation
	glasses =  null
	uniform =  /obj/item/clothing/under/color/black/foundation
	back = /obj/item/rig/zero
	gloves =   null
	suit =     null
	head =     null
	l_hand =   null
	l_ear =    null
	r_hand =   null
	l_pocket = /obj/item/tank/oxygen_emergency_extended
	r_pocket = /obj/item/device/multitool
	holster =  null
	belt = /obj/item/storage/belt/utility/full

/singleton/hierarchy/outfit/foundation/hostile/voidsuit
	name = "Cuchulain Foundation - Hostile Voidsuit"
	mask = /obj/item/clothing/mask/gas/foundation
	glasses =  null
	uniform =  /obj/item/clothing/under/color/black/foundation
	back = /obj/item/tank/jetpack/carbondioxide
	gloves = /obj/item/clothing/gloves/thick/swat
	suit = /obj/item/clothing/suit/space/void/foundation
	head = /obj/item/clothing/head/helmet/space/void/foundation
	l_hand =   null
	l_ear =    null
	r_hand =   null
	l_pocket = /obj/item/tank/oxygen_emergency_extended
	r_pocket = null
	holster =  null
	belt =     null
