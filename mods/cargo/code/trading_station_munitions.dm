/datum/trading_station/munitions
	name_pool = list(
		"TTB \"Palisade\"" = "Terran Trade Beacon \"Palisade\": heavy ordnance, munitions, and battlefield support cargo.",
		"TTB \"Armory VII\"" = "Terran Trade Beacon \"Armory VII\": military-spec ballistic ammunition and tactical warhead reserves.",
		"TTB \"Siege Works\"" = "Terran Trade Beacon \"Siege Works\": defensive artillery ammunition and high-yield munitions crates.",
		"TTB \"High Caliber\"" = "Terran Trade Beacon \"High Caliber\": combat ordnance, heavy cartridge magazines, and weapon caches."
	)
	uid = "munitions"
	icon_states = list("munitions")
	unlock_favor = 9000
	faction = FACTION_INDIE_CONFED
	spawn_always = TRUE
	markup = 1.35
	inventory = list(
		TRADE_CAT_WEAPONS = list(
			/obj/item/gun/projectile/pistol = GOODS_DEFAULT,
			/obj/item/gun/projectile/pistol/sec = GOODS_DEFAULT,
			/obj/item/gun/projectile/pistol/sec/lethal = GOODS_DEFAULT,
			/obj/item/gun/projectile/pistol/magnum_pistol = GOODS_DEFAULT,
			/obj/item/gun/projectile/shotgun/pump = GOODS_DEFAULT,
			/obj/item/gun/projectile/shotgun/pump/combat = GOODS_DEFAULT,
			/obj/item/gun/projectile/shotgun/doublebarrel = GOODS_DEFAULT,
			/obj/item/gun/projectile/automatic/bullpup_rifle = GOODS_DEFAULT,
			/obj/item/gun/projectile/automatic/assault_rifle = GOODS_DEFAULT,
			/obj/item/gun/projectile/automatic/machine_pistol = GOODS_DEFAULT
		),
		TRADE_CAT_AMMO = list(
			/obj/item/ammobox/pistol = GOODS_DEFAULT,
			/obj/item/ammobox/pistol/small = GOODS_DEFAULT,
			/obj/item/ammobox/pistol/rubber = GOODS_DEFAULT,
			/obj/item/ammobox/magnum = GOODS_DEFAULT,
			/obj/item/ammobox/shotgun = GOODS_DEFAULT,
			/obj/item/ammobox/shotgun/slug = GOODS_DEFAULT,
			/obj/item/ammobox/shotgun/beanbag = GOODS_DEFAULT,
			/obj/item/ammobox/shotgun/flechette = GOODS_DEFAULT,
			/obj/item/ammobox/rifle = GOODS_DEFAULT,
			/obj/item/ammobox/rifle/military = GOODS_DEFAULT,
			/obj/item/ammobox/rifle/military/light = GOODS_DEFAULT,
			/obj/item/ammo_magazine/pistol = GOODS_DEFAULT,
			/obj/item/ammo_magazine/pistol/double = GOODS_DEFAULT,
			/obj/item/ammo_magazine/magnum = GOODS_DEFAULT,
			/obj/item/ammo_magazine/mil_rifle/heavy = GOODS_DEFAULT,
			/obj/item/ammo_magazine/mil_rifle/light = GOODS_DEFAULT,
			/obj/item/ammo_magazine/smg_top = GOODS_DEFAULT,
			/obj/item/storage/belt/holster = GOODS_DEFAULT,
			/obj/item/storage/belt/holster/security = GOODS_DEFAULT
		)
	)
