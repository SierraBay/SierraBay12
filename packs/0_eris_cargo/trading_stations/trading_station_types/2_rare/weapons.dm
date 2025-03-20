/datum/trading_station/weapons_terra
	name_pool = list(
		"HTTB \"Telum\"" = "HelTek Trade Beacon \"Telum\": Quality weapons right from Terra!",
		)
	uid = "weapons_terra"
	unlock_favor = 15000
	faction = FACTION_INDIE_CONFED
	spawn_probability = 30
	markup = 1.2
	inventory = list(
		TRADE_CAT_WEAPONS = list(
			/obj/item/gun/projectile/pistol/bobcat = CUSTOM_GOODS_NAME("bobcat service pistol"),
			/obj/item/gun/projectile/pistol/optimus = CUSTOM_GOODS_NAME("optimus service pistol"),
			/obj/item/gun/projectile/pistol/magnum_pistol = CUSTOM_GOODS_NAME("magnum pistol"),
			/obj/item/gun/energy/laser/bonfire = CUSTOM_GOODS_NAME("Bonfire laser carbine"),
			/obj/item/gun/energy/ionrifle/small/stupor = CUSTOM_GOODS_NAME("Stupor ion pistol"),
			/obj/item/gun/projectile/automatic/merc_smg = CUSTOM_GOODS_NAME("C-20r submachine gun"),
			/obj/item/gun/projectile/shotgun/pump/exploration = CUSTOM_GOODS_NAME("Xynergy XP-3 ballistic launcher"),
			),
		TRADE_CAT_AMMO = list(
			/obj/item/ammo_magazine/pistol/double = CUSTOM_GOODS_NAME("service pistol magazine"),
			/obj/item/ammo_magazine/magnum = CUSTOM_GOODS_NAME("magnum pistol magazine"),
			/obj/item/ammo_magazine/smg = CUSTOM_GOODS_NAME("submachine gun magazine"),
			/obj/item/ammo_magazine/shotholder/net = CUSTOM_GOODS_NAME("Ballistic launcher net shells"),
			),
		)
	hidden_inventory = list(
		TRADE_CAT_WEAPONS = list(
			/obj/item/gun/projectile/automatic/assault_rifle/heltek = CUSTOM_GOODS_NAME("LA-700 assault rifle"),
			/obj/item/gun/projectile/sniper/panther = CUSTOM_GOODS_NAME("SD-Panther marksman rifle"),
			),
		TRADE_CAT_AMMO = list(
			/obj/item/ammo_magazine/rifle = CUSTOM_GOODS_NAME("5mmR assault rifle magazine"),
			),
		)
