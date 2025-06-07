// Strike/Expert Team stuff.

/obj/item/clothing/head/helmet/foundation
	name = "\improper Strike Team helmet"
	desc = "A helmet with green stripe and radiotelescope emblem on it."
	icon_state = "helmet_pcrc"
	accessories = list(/obj/item/clothing/accessory/helmet_cover/foundation, /obj/item/clothing/accessory/glassesmod/psi)

/obj/item/clothing/suit/armor/pcarrier/troops/heavy/foundation
	accessories = list(/obj/item/clothing/accessory/armor_plate/medium,
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

/singleton/hierarchy/outfit/foundation
	name = "Cuchulain Foundation Agent"
	glasses =  /obj/item/clothing/glasses/sunglasses
	uniform =  /obj/item/clothing/under/suit_jacket/charcoal
	shoes =    /obj/item/clothing/shoes/black
	l_hand =   /obj/item/storage/briefcase/foundation
	l_ear =    /obj/item/device/radio/headset/foundation
	holster =  /obj/item/clothing/accessory/storage/holster/armpit
	id_slot =  slot_wear_id

/singleton/hierarchy/outfit/foundation/mtf
	name = "Cuchulain Foundation Operative"
	head = /obj/item/clothing/head/helmet/foundation
	mask = /obj/item/clothing/mask/gas
	glasses =  /obj/item/clothing/glasses/hud/security/prot/sunglasses
	uniform =  /obj/item/clothing/under/color/black/foundation
	suit = /obj/item/clothing/suit/armor/pcarrier/troops/heavy/foundation
	shoes =    /obj/item/clothing/shoes/jackboots
	l_hand =   null
	l_ear =    /obj/item/device/radio/headset/foundation
	l_pocket = /obj/item/device/radio
	r_hand = /obj/item/gun/projectile/automatic/sol_smg
	r_pocket = /obj/item/card/emag
	gloves = /obj/item/clothing/gloves/thick/swat
	holster =  /obj/item/clothing/accessory/storage/holster/thigh
	belt = /obj/item/storage/belt/holster/security/foundation
	back = /obj/item/storage/backpack
	id_slot =  slot_wear_id
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/storage/firstaid/sleekstab = 1
	)
	flags = OUTFIT_HAS_BACKPACK

/obj/item/storage/belt/holster/security/foundation/New()
	..()
	new /obj/item/gun/projectile/revolver/foundation(src)
	new /obj/item/ammo_magazine/speedloader/magnum/nullglass(src)
	new /obj/item/ammo_magazine/smg_sol(src)
	new /obj/item/ammo_magazine/smg_sol(src)
	new /obj/item/ammo_magazine/smg_sol(src)
	new /obj/item/grenade/chem_grenade/nullgas(src)
