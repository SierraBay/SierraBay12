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