/datum/trading_station/weapons_terra
	name_pool = list(
		"TTB \"Telum\"" = "Terran Trade Beacon \"Telum\": Surplus marine equipment sold to friends of humanity!",
		"TTB \"Aegis\"" = "Terran Trade Beacon \"Aegis\": Armored reserve supply depot authorizing defensive surplus.",
		"TTB \"Glaive\"" = "Terran Trade Beacon \"Glaive\": Confederate munitions outpost clearing decommissioned weaponry.",
		"TTB \"Ballista\"" = "Terran Trade Beacon \"Ballista\": Heavy-bore surplus supplier registered to Terran frontier patrol.",
		"TTB \"Centurion\"" = "Terran Trade Beacon \"Centurion\": Tactical ordnance cache certified for authorized independent buyers.",
		"TTB \"Castellan\"" = "Terran Trade Beacon \"Castellan\": Sol-border defense stockpile offering secondary armament sales."
	)
	uid = "weapons_terra"
	icon_states = list("weapons")
	unlock_favor = 15000
	faction = FACTION_INDIE_CONFED
	spawn_probability = 30
	markup = 1.2
	thematic_cores = list("Telum", "Aegis", "Glaive", "Ballista", "Centurion", "Castellan", "Bulwark", "Palisade", "Hoplon", "Redoubt", "Iron Gate", "Vanguard")
	role_summary = "defensive surplus, tactical weaponry, and munitions logistics"
	inventory = list(
		TRADE_CAT_WEAPONS = list(
			/obj/item/gun/projectile/pistol/magnum_pistol = CUSTOM_GOODS_NAME("magnum pistol")
		),
		TRADE_CAT_AMMO = list(
			/obj/item/ammo_magazine/pistol/double = CUSTOM_GOODS_NAME("service pistol magazine"),
			/obj/item/ammo_magazine/magnum = CUSTOM_GOODS_NAME("magnum pistol magazine")
		)
	)

/datum/trading_station/weapons_terra/GetNamingPrefixData()
	return list("short" = pick("TTB", "CTB", "PTB"), "full" = "Terran Trade Beacon")

