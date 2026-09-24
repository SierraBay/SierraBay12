/datum/trading_station/science
	name_pool = list(
		"FTB \"Peer Review\"" = "Free Trade Beacon \"Peer Review\": research consumables, lab gear, and anomaly support stock.",
		"FTB \"Synapse\"" = "Free Trade Beacon \"Synapse\": advanced sensor probes, data storage media, and circuit fabrication feed.",
		"FTB \"Observatory Six\"" = "Free Trade Beacon \"Observatory Six\": astronomical surveying packages and high-energy physics supplies.",
		"FTB \"Collider\"" = "Free Trade Beacon \"Collider\": research grade apparatus, laser diodes, and laboratory test cartridges."
	)
	uid = "science"
	icon_states = list("science")
	unlock_favor = 6000
	faction = FACTION_INDEPENDENT
	spawn_always = TRUE
	markup = 1.2
	thematic_cores = list("Peer Review", "Synapse", "Observatory", "Collider", "Spectra", "Hypothesis", "Quark", "Prism", "Archimedes", "Cipher")
	role_summary = "scientific consumables, laboratory apparatus, and research provisions"
	inventory = list(
		TRADE_CAT_COMPONENTS = list(
			/obj/item/stock_parts/manipulator = GOODS_DEFAULT,
			/obj/item/stock_parts/manipulator/nano = GOODS_DEFAULT,
			/obj/item/stock_parts/micro_laser = GOODS_DEFAULT,
			/obj/item/stock_parts/micro_laser/high = GOODS_DEFAULT,
			/obj/item/stock_parts/capacitor = GOODS_DEFAULT,
			/obj/item/stock_parts/capacitor/adv = GOODS_DEFAULT,
			/obj/item/stock_parts/scanning_module = GOODS_DEFAULT,
			/obj/item/stock_parts/scanning_module/adv = GOODS_DEFAULT,
			/obj/item/stock_parts/matter_bin = GOODS_DEFAULT,
			/obj/item/stock_parts/matter_bin/adv = GOODS_DEFAULT,
			/obj/item/stock_parts/circuitboard = GOODS_DEFAULT
		),
		TRADE_CAT_RESEARCH = list(
			/obj/item/device/ano_scanner = GOODS_DEFAULT,
			/obj/item/device/scanner/gas = GOODS_DEFAULT,
			/obj/item/device/scanner/health = GOODS_DEFAULT,
			/obj/item/clothing/suit/bio_suit = GOODS_DEFAULT,
			/obj/item/clothing/head/bio_hood = GOODS_DEFAULT,
			/obj/item/clothing/suit/radiation = GOODS_DEFAULT,
			/obj/item/clothing/head/radiation = GOODS_DEFAULT
		),
		TRADE_CAT_EQUIPMENT = list(
			/obj/item/robot_parts/robot_suit = GOODS_DEFAULT,
			/obj/item/robot_parts/chest = GOODS_DEFAULT,
			/obj/item/robot_parts/head = GOODS_DEFAULT,
			/obj/item/robot_parts/l_arm = GOODS_DEFAULT,
			/obj/item/robot_parts/r_arm = GOODS_DEFAULT,
			/obj/item/robot_parts/l_leg = GOODS_DEFAULT,
			/obj/item/robot_parts/r_leg = GOODS_DEFAULT,
			/obj/item/device/mmi = GOODS_DEFAULT
		)
	)
