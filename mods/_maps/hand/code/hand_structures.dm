// HAND TODO BELOW

	///////////
	//CLOSETS//
	///////////

/obj/structure/closet/secure_closet/hand
	name = "trooper locker"
	closet_appearance = /singleton/closet_appearance/secure_closet/sol/two/dark
	req_access = list(access_away_cavalry_ops)

/obj/structure/closet/secure_closet/patrol/WillContain()
	return list(
		/obj/item/storage/belt/holster/security/tactical,
		/obj/item/melee/telebaton,
		/obj/item/clothing/glasses/hud/security/prot/aviators,
		/obj/item/clothing/glasses/tacgoggles,
		/obj/item/clothing/accessory/storage/black_vest,
		/obj/item/clothing/gloves/thick/combat,
		/obj/item/device/flashlight/maglight,
		/obj/item/storage/firstaid/sleekstab,
		/obj/item/clothing/mask/balaclava,
		/obj/item/gun/energy/gun,
		/obj/item/clothing/accessory/storage/holster/thigh,
		/obj/item/clothing/accessory/armor_plate/merc,
		/obj/item/clothing/head/helmet/tactical,
		/obj/item/storage/backpack/satchel/leather/black
	)


/obj/structure/closet/secure_closet/hand/med
	name = "fleet corpsman cabinet"
	closet_appearance = /singleton/closet_appearance/secure_closet/sol
	req_access = list(access_away_cavalry)

/obj/structure/closet/secure_closet/patrol/fleet/med/WillContain()
	return list(
		/obj/item/storage/firstaid/sleekstab,
		/obj/item/clothing/mask/gas,
		/obj/item/storage/belt/medical,
		/obj/item/clothing/head/beret/solgov/fleet/medical,
		/obj/item/storage/firstaid/adv,
		/obj/item/clothing/accessory/stethoscope,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/clothing/suit/storage/toggle/labcoat,
		/obj/item/clothing/gloves/latex/nitrile,
		/obj/item/clothing/under/rank/medical/scrubs/black,
		/obj/item/clothing/head/surgery/black,
		/obj/item/clothing/suit/storage/hazardvest/white,
		/obj/item/clothing/head/solgov/dress/fleet,
		/obj/item/clothing/under/solgov/utility/fleet/polopants/command,
		/obj/item/clothing/accessory/solgov/department/medical/fleet,
		/obj/item/clothing/suit/storage/solgov/service/fleet/officer
	)

/obj/structure/closet/secure_closet/hand/cpt
	name = "fleet commander cabinet"
	closet_appearance = /singleton/closet_appearance/secure_closet/sol
	req_access = list(access_away_cavalry, access_away_cavalry_commander)

/obj/structure/closet/secure_closet/patrol/fleet_com/WillContain()
	return list(
		/obj/item/melee/telebaton,
		/obj/item/gun/projectile/pistol/m22f,
		/obj/item/device/megaphone,
		//obj/item/clothing/accessory/armor/tag/solgov/com,
		/obj/item/clothing/mask/gas,
		/obj/item/storage/chewables/rollable/rollingkit,
		/obj/item/storage/fancy/smokable/cigar,
		/obj/item/flame/lighter/zippo/gunmetal,
		/obj/item/clothing/head/beret/solgov/fleet/command,
		/obj/item/clothing/under/solgov/utility/fleet/polopants/command,
		/obj/item/gun/projectile/revolver/medium,
		/obj/item/clothing/gloves/wristwatch/gold,
		/obj/item/clothing/head/solgov/dress/fleet,
		/obj/item/clothing/accessory/solgov/department/command/fleet,
		/obj/item/clothing/suit/storage/solgov/service/fleet/officer
	)


/obj/structure/closet/wardrobe/hand
	name = "PMC attire closet"
	closet_appearance = /singleton/closet_appearance/tactical


/obj/structure/closet/wardrobe/hand/saare
	name = "SAARE attire closet"
	closet_appearance = /singleton/closet_appearance/tactical

/obj/structure/closet/wardrobe/hand/saare/WillContain()
	return list(
	/obj/item/clothing/suit/armor/pcarrier/green/heavy_saare = 6,
	/obj/item/clothing/under/rank/security/saarecombat = 6,
	/obj/item/clothing/under/saare,
	/obj/item/clothing/head/beret/sec/corporate/saare = 6,
	/obj/item/clothing/accessory/helmet_cover/saare = 6,
	/obj/item/clothing/shoes/jackboots = 6,
	/obj/item/clothing/gloves/thick/combat = 6
	)

/obj/structure/closet/wardrobe/hand/pcrc
	name = "PCRC attire closet"
	closet_appearance = /singleton/closet_appearance/tactical

/obj/structure/closet/wardrobe/hand/pcrc/WillContain()
	return list(
	/obj/item/clothing/under/pcrc  = 5,
	/obj/item/clothing/under/pcrcsuit,
	/obj/item/clothing/head/beret/pcrc = 6,
	/obj/item/clothing/accessory/helmet_cover/pcrc = 6,
	/obj/item/clothing/accessory/armor_tag/pcrc = 6,
	/obj/item/clothing/shoes/jackboots = 6,
	/obj/item/clothing/gloves/thick/combat = 6
	)

/obj/structure/closet/wardrobe/hand/zpci
	name = "ZPCI attire closet"
	closet_appearance = /singleton/closet_appearance/tactical

/obj/structure/closet/wardrobe/hand/zpci/WillContain()
	return list(
	/obj/item/clothing/under/zpci_uniform  = 6,
	/obj/item/clothing/head/beret/sec/corporate/zpci = 6,
	/obj/item/clothing/accessory/armor_tag/zpci = 6,
	/obj/item/clothing/shoes/jackboots = 6,
	/obj/item/clothing/gloves/thick/combat = 6
	)
