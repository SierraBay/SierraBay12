/singleton/hierarchy/supply_pack/security
	name = "Security"
	access = access_security
	cost = 15

/singleton/hierarchy/supply_pack/security/nanoarmor
	name = "Armor - NanoTrasen"
	contains = list(/obj/item/clothing/suit/armor/pcarrier/medium/nt = 2,
					/obj/item/clothing/head/helmet/nt/guard =2)
	cost = 25
	containertype = /obj/structure/closet/crate/secure
	containername = "NanoTrasen armor crate"

/singleton/hierarchy/supply_pack/security/lightnanoarmor
	name = "Armor - NanoTrasen light"
	contains = list(/obj/item/clothing/suit/armor/pcarrier/light/nt = 2,
					/obj/item/clothing/head/helmet/nt/guard =2)
	cost = 15
	containertype = /obj/structure/closet/crate/secure
	containername = "NanoTrasen light armor crate"

/singleton/hierarchy/supply_pack/security/armory
	name = "Weapons - NT Mk58 sidearms"
	containertype = /obj/structure/closet/crate/secure/weapon
	contains = list(/obj/item/gun/projectile/pistol/sec = 4)
	cost = 60
	containername = "ballistic sidearms crate"

/singleton/hierarchy/supply_pack/security/armory/laser
	name = "Weapons - G40E laser carbines"
	contains = list(/obj/item/gun/energy/laser/secure = 4)
	cost = 60
	containername = "laser carbines crate"

/singleton/hierarchy/supply_pack/security/armory/laser/shady
	name = "Weapons - G40E laser carbines (For disposal)"
	contains = list(/obj/item/gun/energy/laser = 4)
	cost = 80
	contraband = 1
	security_level = null

/singleton/hierarchy/supply_pack/security/armory/advancedlaser
	name = "Weapons - Advanced Laser Weapons"
	contains = list(/obj/item/gun/energy/xray = 2,
					/obj/item/gun/energy/xray/pistol = 2,
					/obj/item/shield/energy = 2)
	cost = 100
	containername = "Advanced Laser Weapons crate"
	security_level = SUPPLY_SECURITY_HIGH

/*2 OP for us

/singleton/hierarchy/supply_pack/security/armory/sniperlaser
	name = "Weapons - Energy marksman"
	contains = list(/obj/item/gun/energy/sniperrifle = 2)
	cost = 120
	containername = "\improper Energy marksman crate"
	security_level = SUPPLY_SECURITY_HIGH

/singleton/hierarchy/supply_pack/security/armory/bullpup
	name = "Weapons - Ballistic rifles"
	contains = list(/obj/item/gun/projectile/automatic/bullpup_rifle = 2)
	cost = 150 //Because 5.56 is OP as fuck right now.
	containername = "\improper Bullpup automatic rifle crate"
	security_level = SUPPLY_SECURITY_HIGH

*/

/singleton/hierarchy/supply_pack/security/armory/c20a
	name = "Weapons - C20A carabines"
	contains = list(/obj/item/gun/projectile/automatic/sec_smg/c20a/empty = 2)
	cost = 40
	containertype = /obj/structure/closet/crate/secure/weapon
	containername = "\improper Ballistic PDW crate"
	security_level = SUPPLY_SECURITY_ELEVATED

/singleton/hierarchy/supply_pack/ammunition/p7_mag_carbine
	name = "Magazines - 7mm C20A carbine, 8x"
	contains = list(
		/obj/item/ammo_magazine/smg_nt/empty = 8
	)
	cost = 10
	containername = "C20A carbine magazines"

/singleton/hierarchy/supply_pack/ammunition/p7_ap
	name = "Ammunition - 7mm pistol, armor piercing, 200x"
	contains = list(
		/obj/item/ammobox/pistol/small_ap = 2
	)
	cost = 40
	containername = "7mm pistol ap rounds (WARNING: LIVE AMMUNITION)"
	access = access_hos
	security_level = SUPPLY_SECURITY_HIGH

/singleton/hierarchy/supply_pack/security/armory/pdw
	name = "Weapons - NT41 SMGs"
	contains = list(/obj/item/gun/projectile/automatic/nt41/empty  = 2)
	cost = 120
	containername = "\improper Ballistic PDW crate"
	security_level = SUPPLY_SECURITY_HIGH

/singleton/hierarchy/supply_pack/ammunition/p28_mag
	name = "Magazines - 5.7x28mm NT41, 8x"
	contains = list(
		/obj/item/ammo_magazine/n10mm/empty = 8
	)
	cost = 10
	containername = "NT41 SMG magazines"

/singleton/hierarchy/supply_pack/ammunition/p28_lethal
	name = "Ammunition - 5.7x28mm smg lethal, 100x"
	contains = list(
		/obj/item/ammobox/nt41 = 1
	)
	cost = 20
	containername = "5.7x28mm smg lethal rounds (WARNING: LIVE AMMUNITION)"
	access = access_hos
	security_level = SUPPLY_SECURITY_HIGH

/singleton/hierarchy/supply_pack/ammunition/sg12_manstopper_shell
	name = "Ammunition - 12g shotgun, manstopper shells, 32x"
	contains = list(
		/obj/item/ammobox/shotgun/manstopper = 1
	)
	cost = 20
	containername = "12g shotgun manstopper shells (WARNING: LIVE AMMUNITION)"
	access = access_hos
	security_level = SUPPLY_SECURITY_ELEVATED

/singleton/hierarchy/supply_pack/ammunition/sg12_dragon_shell
	name = "Ammunition - 12g shotgun, dragon's breath shells, 32x"
	contains = list(
		/obj/item/ammobox/shotgun/dragon = 1
	)
	cost = 20
	contraband = 1
	containername = "12g shotgun dragon's breath shells (WARNING: LIVE AMMUNITION)"
	access = access_hos
	security_level = null

/singleton/hierarchy/supply_pack/security/holster
	name = "Misc - Holster crate"
	contains = list(/obj/item/clothing/accessory/storage/holster/hip = 4)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Holster crate"

/singleton/hierarchy/supply_pack/security/securityextragear
	name = "Misc - Security equipment"
	contains = list(/obj/item/storage/belt/holster/security = 2,
					/obj/item/device/radio/headset/headset_sec = 2,
					/obj/item/clothing/glasses/eyepatch/hud/security = 2,
					/obj/item/taperoll/police = 2,
					/obj/item/device/hailer = 2,
					/obj/item/clothing/gloves/thick = 2,
					/obj/item/device/holowarrant = 2,
					/obj/item/device/flashlight/maglight = 2)
	cost = 60
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Security equipment crate"


/singleton/hierarchy/supply_pack/security/practicelasers
	name = "Misc - Practice Laser Carbines"
	contains = list(/obj/item/gun/energy/laser/practice = 4)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Practice laser carbine crate"

/*
 * OVERRIDES
 * =========
 */

/singleton/hierarchy/supply_pack/security/tacticalarmor
	name = "Armor - Tactical"
	contains = list(/obj/item/clothing/under/tactical,
					/obj/item/clothing/suit/armor/pcarrier/tan/tactical,
					/obj/item/clothing/head/helmet/tactical,
					/obj/item/clothing/mask/balaclava/tactical,
					/obj/item/clothing/accessory/glassesmod/nvg,
					/obj/item/storage/belt/holster/security/tactical,
					/obj/item/clothing/shoes/tactical,
					/obj/item/clothing/gloves/tactical)
	cost = 45
	containertype = /obj/structure/closet/crate/secure
	containername = "tactical armor crate"
	access = access_armory
	security_level = SUPPLY_SECURITY_ELEVATED
