/datum/trading_station/engineering
	name_pool = list(
		"FTB \"Arc Weld\"" = "Free Trade Beacon \"Arc Weld\": engineering machinery, floor stock, and field repairs.",
		"FTB \"Gridline\"" = "Free Trade Beacon \"Gridline\": power and construction stock for hard jobs.",
		"FTB \"Dyno Relay\"" = "Free Trade Beacon \"Dyno Relay\": substation equipment, electrical components, and heavy wiring.",
		"FTB \"Conduit Point\"" = "Free Trade Beacon \"Conduit Point\": industrial pipeline fittings and machinery surplus.",
		"FTB \"Scaffold\"" = "Free Trade Beacon \"Scaffold\": modular structural frames, floor plating, and maintenance supplies."
	)
	uid = "engineering"
	icon_states = list("engineering")
	unlock_favor = 5000
	faction = FACTION_INDEPENDENT
	spawn_always = TRUE
	markup = 1.2
	thematic_cores = list("Arc Weld", "Gridline", "Dyno Relay", "Conduit Point", "Scaffold", "Transformer", "Riveter", "Circuit", "Gantry")
	role_summary = "power grid machinery, structural materials, and technical field repair goods"
	inventory = list(
		TRADE_CAT_TOOLS = list(
			/obj/item/screwdriver = GOODS_DEFAULT,
			/obj/item/wrench = GOODS_DEFAULT,
			/obj/item/crowbar = GOODS_DEFAULT,
			/obj/item/wirecutters = GOODS_DEFAULT,
			/obj/item/weldingtool = GOODS_DEFAULT,
			/obj/item/device/multitool = GOODS_DEFAULT,
			/obj/item/device/geiger = GOODS_DEFAULT,
			/obj/item/device/t_scanner = GOODS_DEFAULT
		),
		TRADE_CAT_POWER = list(
			/obj/item/stack/cable_coil = GOODS_DEFAULT,
			/obj/item/light/tube = GOODS_DEFAULT,
			/obj/item/light/bulb = GOODS_DEFAULT,
			/obj/item/frame/apc = GOODS_DEFAULT,
			/obj/item/airlock_electronics = GOODS_DEFAULT,
			/obj/item/cell = GOODS_DEFAULT,
			/obj/item/cell/high = GOODS_DEFAULT,
			/obj/item/cell/super = GOODS_DEFAULT
		),
		TRADE_CAT_EQUIPMENT = list(
			/obj/item/storage/toolbox/mechanical = GOODS_DEFAULT,
			/obj/item/storage/toolbox/electrical = GOODS_DEFAULT,
			/obj/item/storage/toolbox/emergency = GOODS_DEFAULT,
			/obj/structure/closet/crate/solar = GOODS_DEFAULT,
			/obj/structure/closet/crate/solar_assembly = GOODS_DEFAULT,
			/obj/structure/closet/crate/rcd = GOODS_DEFAULT,
			/obj/item/rcd = GOODS_DEFAULT,
			/obj/item/rcd_ammo = GOODS_DEFAULT,
			/obj/machinery/power/supermatter = CUSTOM_GOODS_PRICE(6750)
		)
	)
	hidden_inventory = list(
		TRADE_CAT_TOOLS = list(
			/obj/item/gun/energy/plasmacutter = GOODS_DEFAULT
		),
		TRADE_CAT_COMPONENTS = list(
			/obj/item/stock_parts/matter_bin/super = GOODS_DEFAULT,
			/obj/item/stock_parts/manipulator/pico = GOODS_DEFAULT,
			/obj/item/stock_parts/capacitor/super = GOODS_DEFAULT
		),
		TRADE_CAT_POWER = list(
			/obj/item/cell/hyper = GOODS_DEFAULT
		)
	)
