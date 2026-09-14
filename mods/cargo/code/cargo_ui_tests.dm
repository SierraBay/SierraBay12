/datum/computer_file/program/supply/unit_test_catalog_range
	var/atom/test_trade_source

/datum/computer_file/program/supply/unit_test_catalog_range/GetTradeSource()
	return test_trade_source

/datum/unit_test/cargo_trade_ui_default_selection_test
	name = "CARGO: Trade UI defaults selected station and category"

/datum/unit_test/cargo_trade_ui_default_selection_test/start_test()
	var/datum/computer_file/program/supply/program = new
	var/datum/trading_station/unit_test_duplicate_pricing/station = new
	var/list/original_visible_stations = SSsupply.visible_trading_stations
	var/fail_reason = null

	station.AssembleInventory()
	SSsupply.visible_trading_stations = list(station)

	var/datum/trading_station/selected_station = program.EnsureSelectedStation()
	if(selected_station != station)
		fail_reason = "Trade UI did not select the only visible station by default."
	else if(program.chosen_category != "Alpha")
		fail_reason = "Trade UI chose [program.chosen_category] instead of the first station category."

	SSsupply.visible_trading_stations = original_visible_stations
	qdel(program)
	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade UI selects a default station and category.")
	return 1

/datum/unit_test/cargo_trade_ui_block_reason_test
	name = "CARGO: Trade UI block reasons resolve correctly"

/datum/unit_test/cargo_trade_ui_block_reason_test/start_test()
	var/datum/computer_file/program/supply/program = new
	var/datum/trading_station/unit_test_duplicate_pricing/station = new
	var/fail_reason = null

	station.whitelist_factions = list(FACTION_NANOTRASEN)
	if(program.GetStationTradeBlockReason(station, FACTION_INDEPENDENT) != "This station trades only with approved factions.")
		fail_reason = "Whitelist block reason did not match expected message."

	station.whitelist_factions = list()
	station.blacklist_factions = list(FACTION_INDEPENDENT)
	if(!fail_reason && program.GetStationTradeBlockReason(station, FACTION_INDEPENDENT) != "This station refuses trade with your faction.")
		fail_reason = "Blacklist block reason did not match expected message."

	station.blacklist_factions = list()
	if(!fail_reason && program.GetStationTradeBlockReason(station, FACTION_INDEPENDENT))
		fail_reason = "Trade UI reported a block reason when none should exist."

	qdel(program)
	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade UI block reasons resolve as expected.")
	return 1

/datum/unit_test/cargo_trade_ui_catalog_distance_test
	name = "CARGO: Trade catalog requires under-6 overmap distance"

/datum/unit_test/cargo_trade_ui_catalog_distance_test/start_test()
	var/datum/computer_file/program/supply/unit_test_catalog_range/program = new
	var/turf/source_turf = get_safe_turf()
	var/obj/overmap/visitable/current_sector = SSsupply.GetOvermapSectorFor(source_turf)
	var/fail_reason = null

	if(!istype(source_turf) || !istype(current_sector) || !current_sector.loc)
		qdel(program)
		skip("Overmap sector unavailable for trade catalog distance test.")
		return 1

	var/turf/near_turf = null
	var/turf/far_turf = null
	var/overmap_limit = GLOB.using_map.overmap_size
	if(current_sector.x + 6 <= overmap_limit)
		near_turf = locate(current_sector.x + 5, current_sector.y, current_sector.z)
		far_turf = locate(current_sector.x + 6, current_sector.y, current_sector.z)
	else if(current_sector.x - 6 >= 1)
		near_turf = locate(current_sector.x - 5, current_sector.y, current_sector.z)
		far_turf = locate(current_sector.x - 6, current_sector.y, current_sector.z)
	else if(current_sector.y + 6 <= overmap_limit)
		near_turf = locate(current_sector.x, current_sector.y + 5, current_sector.z)
		far_turf = locate(current_sector.x, current_sector.y + 6, current_sector.z)
	else if(current_sector.y - 6 >= 1)
		near_turf = locate(current_sector.x, current_sector.y - 5, current_sector.z)
		far_turf = locate(current_sector.x, current_sector.y - 6, current_sector.z)

	if(!istype(near_turf) || !istype(far_turf))
		qdel(program)
		fail("Failed to find valid overmap turfs for catalog distance test.")
		return 1

	var/datum/trading_station/unit_test_duplicate_pricing/station = new
	station.AssembleInventory()
	station.whitelist_factions = list()
	station.blacklist_factions = list()
	var/obj/item/pen/test_source = new(source_turf)
	program.test_trade_source = test_source

	station.overmap_location = near_turf
	if(program.GetStationTradeBlockReason(station))
		fail_reason = "A station within 5 overmap tiles should allow catalog browsing."
	else
		station.overmap_location = far_turf
		var/block_reason = program.GetStationTradeBlockReason(station)
		if(block_reason != "Move closer than 6 overmap tiles to browse this trade beacon's catalog.")
			fail_reason = "A station at 6 overmap tiles returned '[block_reason]' instead of the catalog distance block."

	qdel(station)
	qdel(test_source)
	qdel(program)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade catalog visibility is limited to under 6 overmap tiles.")
	return 1

/datum/unit_test/cargo_trade_ui_cart_serialization_test
	name = "CARGO: Trade UI serializes grouped cart data"

/datum/unit_test/cargo_trade_ui_cart_serialization_test/start_test()
	var/datum/computer_file/program/supply/program = new
	var/datum/trading_station/unit_test_duplicate_pricing/station = new
	var/fail_reason = null

	station.AssembleInventory()
	var/alpha_offer = station.inventory["Alpha"][1]
	var/beta_offer = station.inventory["Beta"][1]
	var/list/alpha_goods = list()
	var/list/beta_goods = list()
	alpha_goods[alpha_offer] = 2
	beta_goods[beta_offer] = 1
	program.shopping_list = list()
	program.shopping_list[station] = list(
		"Alpha" = alpha_goods,
		"Beta" = beta_goods
	)

	var/list/groups = program.SerializeShopListGroups(program.shopping_list, FACTION_INDEPENDENT)
	if(length(groups) != 1)
		fail_reason = "Grouped cart serialization produced [length(groups)] station groups instead of 1."
	else
		var/list/station_group = groups[1]
		var/list/categories = station_group["categories"]
		if(station_group["station_name"] != station.name)
			fail_reason = "Grouped cart serialization lost the station name."
		else if(length(categories) != 2)
			fail_reason = "Grouped cart serialization produced [length(categories)] categories instead of 2."
		else
			var/list/alpha_category = categories[1]
			var/list/alpha_items = alpha_category["items"]
			if(alpha_category["name"] != "Alpha")
				fail_reason = "First serialized category was [alpha_category["name"]] instead of Alpha."
			else if(length(alpha_items) != 1)
				fail_reason = "Serialized Alpha category produced [length(alpha_items)] items instead of 1."
			else
				var/list/alpha_item = alpha_items[1]
				if(alpha_item["name"] != "Alpha Pen")
					fail_reason = "Serialized Alpha item name was [alpha_item["name"]] instead of Alpha Pen."
				else if(alpha_item["price"] != 20)
					fail_reason = "Serialized Alpha item price was [alpha_item["price"]] instead of 20."

	qdel(program)
	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade UI serializes grouped cart data correctly.")
	return 1

/datum/unit_test/cargo_trade_ui_log_collection_test
	name = "CARGO: Trade UI selects the correct log collection"

/datum/unit_test/cargo_trade_ui_log_collection_test/start_test()
	var/datum/computer_file/program/supply/program = new
	var/fail_reason = null

	program.log_screen = "Shipping"
	if(program.GetLogCollection() != SSsupply.shipping_log)
		fail_reason = "Shipping log selection returned the wrong collection."

	program.log_screen = "Export"
	if(!fail_reason && program.GetLogCollection() != SSsupply.export_log)
		fail_reason = "Export log selection returned the wrong collection."

	program.log_screen = "Order"
	if(!fail_reason && program.GetLogCollection() != SSsupply.order_log)
		fail_reason = "Order log selection returned the wrong collection."

	program.log_screen = "Contract"
	if(!fail_reason && program.GetLogCollection() != SSsupply.contract_log)
		fail_reason = "Contract log selection returned the wrong collection."

	qdel(program)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade UI log collection selection works correctly.")
	return 1
