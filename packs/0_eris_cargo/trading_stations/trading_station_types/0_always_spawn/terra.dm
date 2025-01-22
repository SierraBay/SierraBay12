/datum/trading_station/terra
	name_pool = list(
		"TTB \"Invictus\"" = "Terran Trade Beacon \"Invictus\": Marine Corps equipment, sold exclusively to TerraGov associates.",
		)
	uid = "terra"
	unlock_favor = 10000
	faction = FACTION_INDIE_CONFED
	whitelist_factions = list(FACTION_INDIE_CONFED)
	spawn_always = TRUE
	markup = 2.2
	inventory = list(
		TRADE_CAT_ARTILLERY = list(
			/obj/structure/ship_munition/disperser_charge/fire = GOODS_DEFAULT,
			/obj/structure/ship_munition/disperser_charge/emp = GOODS_DEFAULT,
			/obj/structure/ship_munition/disperser_charge/mining = GOODS_DEFAULT,
			/obj/structure/ship_munition/disperser_charge/explosive = GOODS_DEFAULT,
			/obj/structure/ship_munition/disperser_charge/explosive/high = GOODS_DEFAULT,
			),
		TRADE_CAT_WEAPONS = list(
			/obj/item/gun/projectile/heavysniper = GOODS_DEFAULT,
			/obj/item/gun/projectile/rocket_launcher = GOODS_DEFAULT,
			/obj/item/gun/magnetic/railgun = GOODS_DEFAULT,
			),
		TRADE_CAT_AMMO = list(
			/obj/item/ammo_casing/shell = GOODS_DEFAULT,
			/obj/item/ammo_casing/rocket = GOODS_DEFAULT,
			),
		)
	hidden_inventory = list(
		TRADE_CAT_WEAPONS = list(
			/obj/item/gun/magnetic/railgun/automatic = GOODS_DEFAULT,
			),
		TRADE_CAT_AMMO = list(
			/obj/item/ammo_casing/rocket/heavy = GOODS_DEFAULT,
			),
		)
