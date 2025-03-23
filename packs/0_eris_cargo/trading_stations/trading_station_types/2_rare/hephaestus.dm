/*
// Маяк Гефеста - оптовый маяк для торговца. Сиерра не может купить напрямую с него оружие, поэтому это стабильный (и дорогой) способ для торгаша навариться на СБ гэнге
// TODO: Протезы
*/
/datum/trading_station/hephaestus
	name_pool = list(
		"HITB \"Sonne Waffen\"" = "Hephaestus Industries \"Sonne Waffen\": Sol Finest.",
		)
	uid = "hephaestus"
	unlock_favor = 20000
	faction = FACTION_HEPHAESTUS
	whitelist_factions = list(FACTION_FREETRADE, FACTION_HEPHAESTUS)
	markup = 3
	inventory = list(
		TRADE_CAT_ARTILLERY = list(
			/obj/structure/ship_munition/disperser_charge/fire/military = GOODS_DEFAULT,
			/obj/structure/ship_munition/disperser_charge/emp/military = GOODS_DEFAULT,
			/obj/structure/ship_munition/disperser_charge/explosive/military = GOODS_DEFAULT,
			),
		TRADE_CAT_WEAPONS = list(
			/obj/item/gun/projectile/automatic/assault_rifle = CUSTOM_GOODS_NAME("STS-35 assault rifle"),
			/obj/item/gun/energy/laser = CUSTOM_GOODS_NAME("G40E laser carbine"),
			/obj/item/gun/projectile/automatic/machine_pistol = CUSTOM_GOODS_NAME("MP6 Vesper machine pistol"),
			/obj/item/gun/projectile/shotgun/pump/combat = CUSTOM_GOODS_NAME("KS-40 combat shotgun"),
			),
			TRADE_CAT_ARMOR = list(
			/obj/item/clothing/suit/armor/laserproof = GOODS_DEFAULT,
			/obj/item/clothing/head/helmet/ablative = GOODS_DEFAULT,
			/obj/item/clothing/suit/armor/bulletproof = GOODS_DEFAULT,
			/obj/item/clothing/head/helmet/ballistic = GOODS_DEFAULT,
			/obj/item/clothing/suit/armor/pcarrier/tan/tactical = GOODS_DEFAULT,
			/obj/item/clothing/head/helmet/tactical = GOODS_DEFAULT,
			),
		TRADE_CAT_AMMO = list(
			/obj/item/ammo_magazine/rifle = CUSTOM_GOODS_NAME("5mmR assault rifle magazine"),
			/obj/item/ammo_magazine/machine_pistol = CUSTOM_GOODS_NAME("machine pistol magazine"),
			),
		TRADE_CAT_MEDICAL = list(
			/obj/item/organ/internal/augment/active/hud/security = CUSTOM_GOODS_NAME("C-VSR HUD implant"),
			/obj/item/organ/internal/augment/boost/shooting = CUSTOM_GOODS_NAME("AIM-4 gunnery booster implant"),
			),
		TRADE_CAT_EXOSUIT = list(
			/obj/item/mech_equipment/mounted_system/flamethrower = CUSTOM_GOODS_NAME("Prometeus exosuit-mounted flamethrower"),
			/obj/item/mech_equipment/ballistic_shield = CUSTOM_GOODS_NAME("Bulwark exosuit-mounted ballistic shield"),
			/obj/item/mech_equipment/shields = CUSTOM_GOODS_NAME("Armature exosuit energy deflectors"),
			/obj/item/mech_equipment/mounted_system/taser/ballistic = CUSTOM_GOODS_NAME("Vulcan exosuit machinegun"),
			),
		)
	hidden_inventory = list(
		TRADE_CAT_WEAPONS = list(
			/obj/item/gun/energy/sniperrifle = CUSTOM_GOODS_NAME("DMR 9E marksman energy rifle"),
			/obj/item/gun/projectile/heavysniper = CUSTOM_GOODS_NAME("HI PTR-7 anti-material rifle"),
			),
		TRADE_CAT_AMMO = list(
			/obj/item/ammo_casing/shell = CUSTOM_GOODS_NAME("15mmR rifle shell"),
			/obj/item/ammo_casing/shell/apds = CUSTOM_GOODS_NAME("15mmR APDS rifle shell"),
			),
		TRADE_CAT_EXOSUIT = list(
			/obj/item/mech_equipment/mounted_system/taser/pulse = CUSTOM_GOODS_NAME("Pulsator exosuit pulse rifle"),
			/obj/item/mech_equipment/mounted_system/taser/ballistic/launcher = CUSTOM_GOODS_NAME("GRA-D exosuit missile launcher system"),
			),
		TRADE_CAT_RIG = list(
			/obj/item/rig/light/ninja/corpo = CUSTOM_GOODS_NAME("X-11 Lightweight hardsuit"), // expensive af
			),
		)
