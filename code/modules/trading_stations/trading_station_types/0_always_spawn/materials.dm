/datum/trading_station/materials
	name_pool = list(
		"FTB \"Jacarta\"" = "Free Trade Beacon \"Jacarta\": Selling every kind of materials you will ever need!",
		"FTB \"Steel Deck\"" = "Free Trade Beacon \"Steel Deck\": Best materials around this sector of space!",
		)
	uid = "materials"
	unlock_favor = 2500
	faction = FACTION_INDEPENDENT
	spawn_always = TRUE
	markup = 1.5
	inventory = list(
		TRADE_CAT_MATERIALS = list(
			/obj/item/stack/material/steel/ten = CUSTOM_GOODS_NAME("steel (x10)"),
			/obj/item/stack/material/glass/ten = CUSTOM_GOODS_NAME("glass (x10)"),
			/obj/item/stack/material/plastic/ten = CUSTOM_GOODS_NAME("plastic (x10)"),
			/obj/item/stack/material/aluminium/ten = CUSTOM_GOODS_NAME("aluminium (x10)"),
			/obj/item/stack/material/titanium/ten = CUSTOM_GOODS_NAME("titanium (x10)"),
			/obj/item/stack/material/phoron/ten = CUSTOM_GOODS_NAME("phoron (x10)"),
			/obj/item/stack/material/uranium/ten = CUSTOM_GOODS_NAME("uranium (x10)"),
			/obj/item/stack/material/tritium/ten = CUSTOM_GOODS_NAME("tritium (x10)"),
			/obj/item/stack/material/silver/ten = CUSTOM_GOODS_NAME("silver (x10)"),
			/obj/item/stack/material/gold/ten = CUSTOM_GOODS_NAME("gold (x10)"),
			/obj/item/stack/material/wood/ten = CUSTOM_GOODS_NAME("wood (x10)"),
			),
		)
	hidden_inventory = list(
		TRADE_CAT_MATERIALS = list(
			/obj/item/stack/material/diamond/ten = CUSTOM_GOODS_NAME("diamond (x10)"),
			/obj/item/stack/material/plasteel/ten = CUSTOM_GOODS_NAME("plasteel (x10)"),
			/obj/item/stack/material/deuterium/ten = CUSTOM_GOODS_NAME("deuterium (x10)"),
			/obj/item/stack/material/osmium/ten = CUSTOM_GOODS_NAME("osmium (x10)"),
			),
		)
