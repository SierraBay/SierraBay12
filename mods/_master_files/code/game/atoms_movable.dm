// TRADE: explicit export tags replace Eris spawn-tag dependencies.
/atom/movable
	var/list/trade_export_tags = list()

/obj/item/trash
	trade_export_tags = list(TRADE_TAG_JUNK)

/obj/item/device/tankassemblyproxy
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/ore/iron
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/ore/glass
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/ore/slag
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/structure/closet/secure_closet/personal/trade
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/machinery/power/supermatter
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/structure/AIcore
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/aicard
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/aiModule
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/machinery/r_n_d
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/machinery/telecomms
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/machinery/gravity_generator
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/machinery/atm
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/machinery/computer
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/machinery/botany
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/machinery/vending
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/machinery/chemical_dispenser
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/machinery/fabricator
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/blueprints
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/cell/infinite
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/stock_parts/computer/battery_module/lambda
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/organ
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/prosthetic_kit
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/spacecash
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/card/id
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/reagent_containers
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/clothing/under
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/clothing/shoes
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/clothing/gloves/latex
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/clothing/mask/surgical
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)

/obj/item/stack/tile
	trade_export_tags = list(TRADE_TAG_NONEXPORTABLE)
