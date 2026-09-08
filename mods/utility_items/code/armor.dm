/obj/item/clothing/suit/armor
	allowed = list(/obj/item/gun/energy,/obj/item/device/radio,/obj/item/reagent_containers/spray/pepper, /obj/item/gun/projectile,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/handcuffs,/obj/item/gun/magnetic,/obj/item/clothing/head/helmet,/obj/item/device/flashlight, /obj/item/clothing/head/hardhat, /obj/item/device/flashlight/flare/glowstick)

/obj/item/clothing/suit/storage/hazardvest
		allowed = list (
		/obj/item/device/scanner/gas,
		/obj/item/device/flashlight,
		/obj/item/device/multitool,
		/obj/item/device/radio,
		/obj/item/device/t_scanner,
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/tank/oxygen_emergency,
		/obj/item/tank/oxygen_emergency_extended,
		/obj/item/tank/nitrogen_emergency,
		/obj/item/clothing/mask/gas,
		/obj/item/taperoll/engineering,
		/obj/item/clothing/head/deckcrew,
		/obj/item/clothing/head/hardhat,
		/obj/item/device/flashlight/flare/glowstick
	)

/* IAA_BADGE_ACCESS_FIX
AUTHOR = Guared1365
Fixes required access to imprint id data into iaa holobadge. */

/obj/item/clothing/accessory/badge/holo/investigator
	badge_access = "ACCESS_IAA"
