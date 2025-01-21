/datum/trading_station/engineering
	name_pool = list(
		"FTB \"Screws & Bolts\"" = "Free Trade Beacon \"Screws & Bolts\": Tools and equipment for all your engineering needs!",
		"FTB \"Spacer\"" = "Free Trade Beacon \"Spacer\": Cheap and powerful tools to build and rebuild!",
		)
	uid = "engineering"
	unlock_favor = 5000
	random_factions = list(
		FACTION_INDEPENDENT,
		FACTION_FREETRADE,
		)
	spawn_always = TRUE
	markup = 1.2
	inventory = list(
		TRADE_CAT_TOOLS = list(
			/obj/item/storage/toolbox/mechanical = GOODS_DEFAULT,
			/obj/item/storage/toolbox/electrical = GOODS_DEFAULT,
			),
		TRADE_CAT_CLOTHING = list(
			/obj/item/clothing/suit/radiation = GOODS_DEFAULT,
			/obj/item/clothing/head/radiation = GOODS_DEFAULT,
			),
		TRADE_CAT_EQUIPMENT = list(
			/obj/item/clothing/gloves/insulated = GOODS_DEFAULT,
			/obj/item/clothing/shoes/magboots = GOODS_DEFAULT,
			/obj/item/cell/standard = GOODS_DEFAULT,
			/obj/item/cell/high = GOODS_DEFAULT,
			/obj/item/solar_assembly = GOODS_DEFAULT,
			/obj/machinery/the_singularitygen = GOODS_DEFAULT,
			),
		TRADE_CAT_COMPONENTS = list(
			/obj/item/stock_parts/smes_coil/weak = GOODS_DEFAULT,
			/obj/item/stock_parts/smes_coil = GOODS_DEFAULT,
			/obj/item/stock_parts/smes_coil/super_capacity = GOODS_DEFAULT,
			/obj/item/stock_parts/smes_coil/super_io = GOODS_DEFAULT,
			/obj/item/stock_parts/circuitboard/solar_control = GOODS_DEFAULT,
			/obj/item/tracker_electronics = GOODS_DEFAULT,
			/obj/item/stock_parts/circuitboard/pacman = GOODS_DEFAULT,
			/obj/item/stock_parts/circuitboard/pacman/super = GOODS_DEFAULT,
			),
		)
	hidden_inventory = list(
		TRADE_CAT_TOOLS = list(
			/obj/item/storage/toolbox/syndicate = GOODS_DEFAULT,
			),
		)
