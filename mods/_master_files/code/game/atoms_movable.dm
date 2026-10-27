// TRADE: explicit export tags replace Eris spawn-tag dependencies.
/atom/movable
	var/list/trade_export_tags = list()

/obj/item/trash
	trade_export_tags = list(TRADE_TAG_JUNK)

/obj/item/device/tankassemblyproxy
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/ore/iron
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/structure/closet/secure_closet/personal/trade
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)
