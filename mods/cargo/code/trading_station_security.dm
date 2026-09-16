/datum/trading_station/security
	name_pool = list(
		"TTB \"Bulwark\"" = "Terran Trade Beacon \"Bulwark\": armor, security tools, and authorized weapons stock.",
		"TTB \"Hoplon\"" = "Terran Trade Beacon \"Hoplon\": heavy personal protection gear and defensive riot control surplus.",
		"TTB \"Redoubt\"" = "Terran Trade Beacon \"Redoubt\": fortified outpost offering defensive armaments and tactical equipment.",
		"TTB \"Iron Sentry\"" = "Terran Trade Beacon \"Iron Sentry\": planetary defense auxiliary cache providing authorized security stock."
	)
	uid = "security"
	icon_states = list("weapons")
	unlock_favor = 7500
	faction = FACTION_INDIE_CONFED
	spawn_always = TRUE
	markup = 1.3
	inventory = list(
		TRADE_CAT_ARMOR = list(
			/obj/item/clothing/suit/armor/vest = GOODS_DEFAULT,
			/obj/item/clothing/head/helmet = GOODS_DEFAULT,
			/obj/item/clothing/suit/armor/pcarrier/light = GOODS_DEFAULT,
			/obj/item/clothing/accessory/arm_guards/blue = GOODS_DEFAULT
		),
		TRADE_CAT_SECURITY = list(
			/obj/item/melee/baton/loaded = GOODS_DEFAULT,
			/obj/item/gun/energy/taser = GOODS_DEFAULT,
			/obj/item/gun/energy/stunrevolver = GOODS_DEFAULT,
			/obj/item/handcuffs = GOODS_DEFAULT,
			/obj/item/reagent_containers/spray/pepper = GOODS_DEFAULT,
			/obj/item/device/flash = GOODS_DEFAULT,
			/obj/machinery/barrier = GOODS_DEFAULT,
			/obj/item/storage/briefcase/crimekit = GOODS_DEFAULT,
			/obj/item/forensics/sample_kit = GOODS_DEFAULT,
			/obj/item/forensics/sample_kit/powder = GOODS_DEFAULT,
			/obj/item/storage/box/evidence = GOODS_DEFAULT,
			/obj/item/taperoll/police = GOODS_DEFAULT
		)
	)
	hidden_inventory = list(
		TRADE_CAT_ARMOR = list(
			/obj/item/clothing/suit/armor/swat = GOODS_DEFAULT,
			/obj/item/clothing/head/helmet/swat = GOODS_DEFAULT,
			/obj/item/clothing/suit/armor/riot = GOODS_DEFAULT,
			/obj/item/clothing/head/helmet/riot = GOODS_DEFAULT
		),
		TRADE_CAT_SECURITY = list(
			/obj/item/grenade/flashbang = GOODS_DEFAULT,
			/obj/item/shield/riot = GOODS_DEFAULT
		)
	)
