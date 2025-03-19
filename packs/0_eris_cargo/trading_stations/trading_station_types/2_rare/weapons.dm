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
			),
		TRADE_CAT_AMMO = list(
			/obj/item/ammo_magazine/pistol/double = CUSTOM_GOODS_NAME("service pistol magazine"),
			/obj/item/ammo_magazine/magnum = CUSTOM_GOODS_NAME("magnum pistol magazine"),
			),
		)

/*		GLIST_TODO: WEAPONS
	hidden_inventory = list(
		TRADE_CAT_WEAPONS = list(
			/obj/item/gun/projectile/automatic/t18 = CUSTOM_GOODS_NAME("T18 rifle"),
			/obj/item/gun/projectile/automatic/t12 = CUSTOM_GOODS_NAME("T12 rifle"),
			),
		TRADE_CAT_AMMO = list(
			/obj/item/ammo_magazine/t18 = CUSTOM_GOODS_NAME("T18 rifle magazine"),
			/obj/item/ammo_magazine/t12 = CUSTOM_GOODS_NAME("T12 rifle magazine"),
			),
		)
*/
