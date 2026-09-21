/datum/trading_station/operations
	name_pool = list(
		"FTB \"Quartermaster\"" = "Free Trade Beacon \"Quartermaster\": tools, mining gear, office stock, and surplus cargo essentials.",
		"FTB \"Longhaul\"" = "Free Trade Beacon \"Longhaul\": practical freight and expedition logistics.",
		"FTB \"Crossroads\"" = "Free Trade Beacon \"Crossroads\": regional transit depot for supply exchange and freight dispatch.",
		"FTB \"Waypoint Nine\"" = "Free Trade Beacon \"Waypoint Nine\": automated waystation for mining crews and long-range haulers.",
		"FTB \"Cargo Core\"" = "Free Trade Beacon \"Cargo Core\": bulk crating facility handling standard supply manifests."
	)
	uid = "operations"
	icon_states = list("operations")
	unlock_favor = 3000
	faction = FACTION_INDEPENDENT
	spawn_always = TRUE
	markup = 1.2
	thematic_cores = list("Quartermaster", "Longhaul", "Crossroads", "Waypoint", "Cargo Core", "Freightline", "Manifest", "Tranship", "Dockside")
	role_summary = "freight handling, expedition logistics, and mining equipment"
	inventory = list(
		TRADE_CAT_EQUIPMENT = list(
			/obj/vehicle/train/cargo/engine = GOODS_DEFAULT,
			/obj/vehicle/train/cargo/trolley = GOODS_DEFAULT,
			/obj/item/stack/package_wrap = GOODS_DEFAULT,
			/obj/item/hand_labeler = GOODS_DEFAULT,
			/obj/item/device/destTagger = GOODS_DEFAULT
		),
		TRADE_CAT_CRATES = list(
			/obj/structure/closet/crate = GOODS_DEFAULT,
			/obj/structure/closet/crate/plastic = GOODS_DEFAULT,
			/obj/structure/closet/crate/large = GOODS_DEFAULT
		),
		TRADE_CAT_TOOLS = list(
			/obj/item/pickaxe = GOODS_DEFAULT,
			/obj/item/pickaxe/drill = GOODS_DEFAULT,
			/obj/item/storage/ore = GOODS_DEFAULT,
			/obj/item/device/scanner/mining = GOODS_DEFAULT
		)
	)
