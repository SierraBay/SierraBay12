/datum/unit_test/cargo_crates_containment_test/start_test()
	skip("Legacy supply-pack test disabled by trade-network cargo rework.")
	return 1

/datum/unit_test/cargo_sufficient_cost_test/start_test()
	skip("Legacy supply-pack test disabled by trade-network cargo rework.")
	return 1

/datum/unit_test/zas_supply_shuttle_moved/start_test()
	skip("Supply shuttle test disabled by trade-network cargo rework.")
	return 1

/datum/unit_test/zas_supply_shuttle_moved
	async = 0

/datum/unit_test/zas_supply_shuttle_moved/check_result()
	return 1

/datum/unit_test/cargo_trade_factions_test
	name = "CARGO: Trade factions initialize"

/datum/unit_test/cargo_trade_factions_test/start_test()
	if(!istype(SSsupply.GetFaction(FACTION_NANOTRASEN), /datum/trade_faction))
		fail("NanoTrasen trade faction was not initialized.")
		return 1
	if(!istype(SSsupply.GetFaction(FACTION_INDEPENDENT), /datum/trade_faction))
		fail("Independent trade faction was not initialized.")
		return 1
	pass("Trade factions initialized.")
	return 1

/datum/unit_test/cargo_trade_station_init_test
	name = "CARGO: Trade stations initialize"

/datum/unit_test/cargo_trade_station_init_test/start_test()
	if(!length(SSsupply.all_trading_stations))
		fail("No trade stations were initialized.")
		return 1
	for(var/datum/trading_station/trading_station as anything in SSsupply.all_trading_stations)
		if(!trading_station.name || !length(trading_station.inventory))
			fail("[trading_station.type] did not initialize correctly.")
			return 1
	pass("Trade stations initialized with inventory.")
	return 1

/datum/unit_test/cargo_legacy_station_inventory_test
	name = "CARGO: Legacy stations import supply-pack contents"

/datum/unit_test/cargo_legacy_station_inventory_test/start_test()
	var/list/required_station_uids = list(
		"legacy_operations",
		"legacy_engineering",
		"legacy_atmospherics",
		"legacy_materials",
		"legacy_security",
		"legacy_medicine",
		"legacy_science",
		"legacy_service",
		"legacy_civilian",
		"legacy_munitions"
	)
	for(var/station_uid in required_station_uids)
		var/datum/trading_station/trading_station = SSsupply.GetStationByUid(station_uid)
		if(!istype(trading_station))
			fail("Legacy station [station_uid] was not initialized.")
			return 1
		if(!length(trading_station.inventory) && !length(trading_station.hidden_inventory))
			fail("Legacy station [station_uid] did not import any inventory.")
			return 1
	pass("Legacy stations imported supply-pack contents.")
	return 1

/datum/trading_station/unit_test_duplicate_pricing
	name = "Unit Test Trader"
	desc = "Trade station used for cargo unit tests."
	uid = "unit_test_duplicate_pricing"
	spawn_probability = 0
	spawn_cost = 0
	base_income = 0

/datum/trading_station/unit_test_duplicate_pricing/AssembleInventory()
	inventory = list(
		"Alpha" = list(/obj/item/pen = GOODS_DATA("Alpha Pen", null, 10)),
		"Beta" = list(/obj/item/pen = GOODS_DATA("Beta Pen", null, 20))
	)
	hidden_inventory = list()
	amounts_of_goods = list()
	unique_good_count = 0
	next_good_offer_id = 0
	NormalizeGoodsRecords()

/datum/unit_test/cargo_duplicate_offer_price_test
	name = "CARGO: Duplicate offers stay category-priced"

/datum/unit_test/cargo_duplicate_offer_price_test/start_test()
	var/datum/trading_station/unit_test_duplicate_pricing/station = new
	station.AssembleInventory()

	var/alpha_offer = station.inventory["Alpha"][1]
	var/beta_offer = station.inventory["Beta"][1]
	if(!alpha_offer || !beta_offer)
		fail("Failed to create duplicate-offer test inventory.")
		return 1

	var/alpha_price = SSsupply.GetBasicImportCost(alpha_offer, station, "Alpha")
	var/beta_price = SSsupply.GetBasicImportCost(beta_offer, station, "Beta")
	var/list/shop_list = list()
	var/list/categories = list(
		"Alpha" = list(),
		"Beta" = list()
	)
	shop_list[station] = categories
	var/list/alpha_goods = categories["Alpha"]
	var/list/beta_goods = categories["Beta"]
	alpha_goods[alpha_offer] = 1
	beta_goods[beta_offer] = 1
	var/total_price = SSsupply.CollectPriceForList(shop_list, FACTION_INDEPENDENT)

	if(alpha_price != 10)
		fail("Alpha offer price was [alpha_price] instead of 10.")
	else if(beta_price != 20)
		fail("Beta offer price was [beta_price] instead of 20.")
	else if(total_price != 30)
		fail("Duplicate offers were mispriced as [total_price] instead of 30.")
	else
		pass("Duplicate offers remain category-priced.")

	qdel(station)
	return 1

/datum/unit_test/cargo_buy_revalidates_stock_test
	name = "CARGO: Purchase revalidates stock"

/datum/unit_test/cargo_buy_revalidates_stock_test/start_test()
	var/datum/trading_station/unit_test_duplicate_pricing/station = new
	station.AssembleInventory()
	station.InitGoods()

	var/good_id = station.inventory["Alpha"][1]
	if(!good_id)
		fail("Failed to create stock-validation test inventory.")
		return 1

	station.SetGoodAmount("Alpha", good_id, 1)

	var/datum/money_account/account = new
	account.owner_name = "Unit Test"
	account.money = 1000

	var/obj/machinery/trade_beacon/receiving/beacon = new(get_safe_turf())
	var/list/shop_list = list()
	var/list/categories = list("Alpha" = list())
	shop_list[station] = categories
	var/list/alpha_goods = categories["Alpha"]
	alpha_goods[good_id] = 2

	if(SSsupply.Buy(beacon, account, shop_list, FALSE, null, FACTION_INDEPENDENT))
		fail("Purchase succeeded with stale stock.")
	else if(station.GetGoodAmount("Alpha", good_id) != 1)
		fail("Stock changed after a rejected stale-stock purchase.")
	else
		pass("Buy() rejects stale stock before delivery.")

	qdel(beacon)
	qdel(station)
	return 1

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

/datum/computer_file/program/supply/unit_test_catalog_range
	var/atom/test_trade_source

/datum/computer_file/program/supply/unit_test_catalog_range/GetTradeSource()
	return test_trade_source

/datum/unit_test/cargo_trade_ui_catalog_distance_test
	name = "CARGO: Trade catalog requires under-6 overmap distance"

/datum/unit_test/cargo_trade_ui_catalog_distance_test/start_test()
	var/datum/computer_file/program/supply/unit_test_catalog_range/program = new
	var/turf/source_turf = get_safe_turf()
	var/obj/overmap/visitable/current_sector = SSsupply.GetOvermapSectorFor(source_turf)
	var/fail_reason = null

	if(!istype(source_turf) || !istype(current_sector))
		qdel(program)
		skip("Overmap sector unavailable for trade catalog distance test.")
		return 1

	var/turf/near_turf = null
	var/turf/far_turf = null
	if(current_sector.x + 6 <= world.maxx)
		near_turf = locate(current_sector.x + 5, current_sector.y, current_sector.z)
		far_turf = locate(current_sector.x + 6, current_sector.y, current_sector.z)
	else if(current_sector.x - 6 >= 1)
		near_turf = locate(current_sector.x - 5, current_sector.y, current_sector.z)
		far_turf = locate(current_sector.x - 6, current_sector.y, current_sector.z)
	else if(current_sector.y + 6 <= world.maxy)
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

/datum/unit_test/cargo_trade_station_smart_placement_spacing_test
	name = "CARGO: Smart beacon placement avoids clustering"

/datum/unit_test/cargo_trade_station_smart_placement_spacing_test/start_test()
	var/list/original_all_stations = SSsupply.all_trading_stations
	var/fail_reason = null
	var/turf/source_turf = get_cargo_test_safe_turf()
	var/obj/overmap/visitable/current_sector = SSsupply.GetOvermapSectorFor(source_turf)
	if(!istype(source_turf) || !istype(current_sector))
		skip("Overmap sector unavailable for smart placement spacing test.")
		return 1

	var/turf/near_turf = locate(current_sector.x + 2, current_sector.y, current_sector.z)
	var/turf/far_turf = locate(current_sector.x + 8, current_sector.y, current_sector.z)
	if(!istype(near_turf, /turf/unsimulated/map) || !istype(far_turf, /turf/unsimulated/map))
		skip("Suitable overmap turfs unavailable for smart placement spacing test.")
		return 1

	var/datum/trading_station/unit_test_duplicate_pricing/anchor_station = new
	var/datum/trading_station/unit_test_duplicate_pricing/test_station = new
	anchor_station.overmap_location = near_turf
	test_station.min_overmap_station_spacing = 5
	test_station.preferred_distance_from_base = 8
	test_station.max_distance_from_base = 20
	SSsupply.all_trading_stations = list(anchor_station)

	var/near_score = test_station.ScoreOvermapSpawnLocation(near_turf)
	var/far_score = test_station.ScoreOvermapSpawnLocation(far_turf)

	if(near_score != 0)
		fail_reason = "Smart placement allowed a spawn [get_dist(near_turf, anchor_station.overmap_location)] tiles from another station."
	else if(far_score <= 0)
		fail_reason = "Smart placement rejected a valid open turf away from the existing station."

	SSsupply.all_trading_stations = original_all_stations
	qdel(anchor_station)
	qdel(test_station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Smart placement rejects clustered beacons and keeps open lanes available.")
	return 1

/datum/unit_test/cargo_trade_station_smart_placement_hazard_test
	name = "CARGO: Smart beacon placement avoids hazards"

/datum/unit_test/cargo_trade_station_smart_placement_hazard_test/start_test()
	var/turf/source_turf = get_cargo_test_safe_turf()
	var/obj/overmap/visitable/current_sector = SSsupply.GetOvermapSectorFor(source_turf)
	if(!istype(source_turf) || !istype(current_sector))
		skip("Overmap sector unavailable for smart placement hazard test.")
		return 1

	var/turf/hazard_turf = locate(current_sector.x + 4, current_sector.y, current_sector.z)
	var/turf/adjacent_turf = locate(current_sector.x + 5, current_sector.y, current_sector.z)
	if(!istype(hazard_turf, /turf/unsimulated/map) || !istype(adjacent_turf, /turf/unsimulated/map))
		skip("Suitable overmap turfs unavailable for smart placement hazard test.")
		return 1

	var/fail_reason = null
	var/datum/trading_station/unit_test_duplicate_pricing/test_station = new
	test_station.hazard_buffer = 1
	var/obj/overmap/event/dust/hazard = new(hazard_turf)

	if(test_station.CanUseOvermapSpawnLocation(hazard_turf))
		fail_reason = "Smart placement accepted a turf occupied by a hazard."
	else if(test_station.CanUseOvermapSpawnLocation(adjacent_turf))
		fail_reason = "Smart placement accepted a turf inside the hazard buffer."

	qdel(hazard)
	qdel(test_station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Smart placement filters direct and adjacent hazard tiles.")
	return 1

/datum/trading_station/unit_test_contract_source
	name = "Unit Test Source"
	desc = "Trade station used for contract unit tests."
	uid = "unit_test_contract_source"
	spawn_probability = 0
	spawn_cost = 0
	base_income = 0
	live_market_auto_events = FALSE

/datum/trading_station/unit_test_contract_source/AssembleInventory()
	inventory = list(
		"Alpha" = list(/obj/item/pen = GOODS_DATA("Contract Pen", null, 10)),
		"Tools" = list(/obj/item/crowbar = GOODS_DATA("Source Crowbar", null, 20))
	)
	hidden_inventory = list()
	amounts_of_goods = list()
	unique_good_count = 0
	next_good_offer_id = 0
	live_market_state = list()
	live_market_modifiers = list()
	NormalizeGoodsRecords()

/datum/trading_station/unit_test_contract_destination
	name = "Unit Test Destination"
	desc = "Destination station used for contract unit tests."
	uid = "unit_test_contract_destination"
	spawn_probability = 0
	spawn_cost = 0
	base_income = 0
	live_market_auto_events = FALSE

/datum/trading_station/unit_test_contract_destination/AssembleInventory()
	inventory = list(
		"Demand" = list(/obj/item/pen = GOODS_DATA("Demand Pen", null, 35)),
		"Beta" = list(/obj/item/paper = GOODS_DATA("Destination Paper", null, 5))
	)
	hidden_inventory = list()
	amounts_of_goods = list()
	unique_good_count = 0
	next_good_offer_id = 0
	live_market_state = list()
	live_market_modifiers = list()
	NormalizeGoodsRecords()

/datum/trading_station/unit_test_contract_no_market_source
	name = "Unit Test No-Market Source"
	desc = "Trade station used for contract no-market tests."
	uid = "unit_test_contract_no_market_source"
	spawn_probability = 0
	spawn_cost = 0
	base_income = 0
	live_market_auto_events = FALSE

/datum/trading_station/unit_test_contract_no_market_source/AssembleInventory()
	inventory = list(
		"Alpha" = list(/obj/item/pen = GOODS_DATA("Stable Pen", null, 10))
	)
	hidden_inventory = list()
	amounts_of_goods = list()
	unique_good_count = 0
	next_good_offer_id = 0
	live_market_state = list()
	live_market_modifiers = list()
	NormalizeGoodsRecords()

/datum/trading_station/unit_test_contract_no_market_destination
	name = "Unit Test No-Market Destination"
	desc = "Destination station used for contract no-market tests."
	uid = "unit_test_contract_no_market_destination"
	spawn_probability = 0
	spawn_cost = 0
	base_income = 0
	live_market_auto_events = FALSE

/datum/trading_station/unit_test_contract_no_market_destination/AssembleInventory()
	inventory = list(
		"Demand" = list(/obj/item/pen = GOODS_DATA("Stable Pen", null, 15))
	)
	hidden_inventory = list()
	amounts_of_goods = list()
	unique_good_count = 0
	next_good_offer_id = 0
	live_market_state = list()
	live_market_modifiers = list()
	NormalizeGoodsRecords()

/proc/get_cargo_test_safe_turf()
	for(var/obj/landmark/test/safe_turf/landmark in landmarks_list)
		return get_turf(landmark)
	return null

/proc/configure_cargo_contract_test_route(datum/trading_station/source_station, datum/trading_station/destination_station)
	var/turf/source_turf = get_cargo_test_safe_turf()
	var/obj/overmap/visitable/current_sector = SSsupply.GetOvermapSectorFor(source_turf)
	if(!istype(source_turf) || !istype(current_sector))
		return FALSE

	var/turf/source_market = null
	var/turf/destination_market = null
	if(current_sector.x + 3 <= world.maxx)
		source_market = locate(current_sector.x + 1, current_sector.y, current_sector.z)
		destination_market = locate(current_sector.x + 3, current_sector.y, current_sector.z)
	else if(current_sector.x - 3 >= 1)
		source_market = locate(current_sector.x - 1, current_sector.y, current_sector.z)
		destination_market = locate(current_sector.x - 3, current_sector.y, current_sector.z)
	else if(current_sector.y + 3 <= world.maxy)
		source_market = locate(current_sector.x, current_sector.y + 1, current_sector.z)
		destination_market = locate(current_sector.x, current_sector.y + 3, current_sector.z)
	else if(current_sector.y - 3 >= 1)
		source_market = locate(current_sector.x, current_sector.y - 1, current_sector.z)
		destination_market = locate(current_sector.x, current_sector.y - 3, current_sector.z)

	if(!istype(source_market) || !istype(destination_market))
		return FALSE

	source_station.overmap_object = current_sector
	source_station.overmap_location = source_market
	destination_station.overmap_location = destination_market
	source_station.trade_range = 5
	destination_station.trade_range = 5
	return TRUE

/proc/configure_cargo_market_contract_fixture(datum/trading_station/source_station, datum/trading_station/destination_station)
	if(!istype(source_station) || !istype(destination_station))
		return null

	var/source_shared_good = source_station.inventory["Alpha"][1]
	var/source_unmatched_good = source_station.inventory["Tools"][1]
	var/destination_shared_good = destination_station.inventory["Demand"][1]
	if(!source_shared_good || !source_unmatched_good || !destination_shared_good)
		return null

	source_station.SetGoodAmount("Alpha", source_shared_good, 20)
	source_station.EnsureLiveMarketCommodity("Alpha", source_shared_good, 15, 10)
	source_station.SetGoodAmount("Tools", source_unmatched_good, 20)
	source_station.EnsureLiveMarketCommodity("Tools", source_unmatched_good, 20, 10)
	destination_station.SetGoodAmount("Demand", destination_shared_good, 1)
	destination_station.EnsureLiveMarketCommodity("Demand", destination_shared_good, 35, 10)
	destination_station.AdjustLiveMarketDemand("Demand", destination_shared_good, 5)

	return list(
		"source_shared_good" = source_shared_good,
		"source_unmatched_good" = source_unmatched_good,
		"destination_shared_good" = destination_shared_good
	)

/proc/configure_cargo_caravan_contract_fixture(datum/trading_station/source_station, datum/trading_station/destination_station)
	if(!istype(source_station) || !istype(destination_station) || !istype(destination_station.overmap_location))
		return null

	var/datum/trading_station/caravan/caravan_station = new
	caravan_station.name = "Unit Test Caravan"
	caravan_station.desc = "A mobile caravan used for rendezvous contract tests."
	caravan_station.uid = "unit_test_trade_caravan"
	caravan_station.trade_range = 5
	caravan_station.overmap_location = destination_station.overmap_location

	var/obj/overmap/trade_beacon/caravan/caravan_object = new(destination_station.overmap_location)
	caravan_object.BindToStation(caravan_station)
	caravan_object.current_stop = source_station
	return caravan_station

/datum/unit_test/cargo_trade_contract_market_selection_test
	name = "CARGO: Trade contracts prefer market-valid shared commodities"

/datum/unit_test/cargo_trade_contract_market_selection_test/start_test()
	var/list/original_visible_stations = SSsupply.visible_trading_stations
	var/list/original_all_stations = SSsupply.all_trading_stations
	var/list/original_contracts = SSsupply.trade_contracts
	var/fail_reason = null

	var/datum/trading_station/unit_test_contract_source/source_station = new
	var/datum/trading_station/unit_test_contract_destination/destination_station = new
	source_station.AssembleInventory()
	source_station.InitGoods()
	destination_station.AssembleInventory()
	destination_station.InitGoods()
	if(!configure_cargo_contract_test_route(source_station, destination_station))
		qdel(source_station)
		qdel(destination_station)
		skip("Overmap sector unavailable for trade contract market-selection test.")
		return 1

	var/list/fixture = configure_cargo_market_contract_fixture(source_station, destination_station)
	var/source_shared_good = islist(fixture) ? fixture["source_shared_good"] : null
	var/source_unmatched_good = islist(fixture) ? fixture["source_unmatched_good"] : null

	SSsupply.visible_trading_stations = list(source_station, destination_station)
	SSsupply.all_trading_stations = list(source_station, destination_station)
	SSsupply.trade_contracts = list()

	var/datum/trade_contract/contract = SSsupply.CreateTradeContract(source_station)
	if(!istype(contract))
		fail_reason = "CreateTradeContract() did not return a market-valid contract."
	else
		var/list/content = length(contract.contents) ? contract.contents[1] : null
		if(!islist(content))
			fail_reason = "Generated contract did not contain a cargo line item."
		else if(content["good_id"] != source_shared_good)
			fail_reason = "Contract chose [content["good_id"]] instead of the shared market commodity [source_shared_good]."
		else if(content["good_id"] == source_unmatched_good)
			fail_reason = "Contract selected the unmatched source-only commodity."
		else if(contract.market_reason != "hybrid")
			fail_reason = "Contract market reason was [contract.market_reason] instead of hybrid."

	SSsupply.visible_trading_stations = original_visible_stations
	SSsupply.all_trading_stations = original_all_stations
	SSsupply.trade_contracts = original_contracts
	qdel(source_station)
	qdel(destination_station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade contracts choose shared live-market opportunities instead of random source goods.")
	return 1

/datum/unit_test/cargo_trade_contract_no_market_candidate_test
	name = "CARGO: Trade contracts require shortage or spread"

/datum/unit_test/cargo_trade_contract_no_market_candidate_test/start_test()
	var/list/original_visible_stations = SSsupply.visible_trading_stations
	var/list/original_all_stations = SSsupply.all_trading_stations
	var/list/original_contracts = SSsupply.trade_contracts

	var/datum/trading_station/unit_test_contract_no_market_source/source_station = new
	var/datum/trading_station/unit_test_contract_no_market_destination/destination_station = new
	source_station.AssembleInventory()
	source_station.InitGoods()
	destination_station.AssembleInventory()
	destination_station.InitGoods()
	if(!configure_cargo_contract_test_route(source_station, destination_station))
		qdel(source_station)
		qdel(destination_station)
		skip("Overmap sector unavailable for no-market trade contract test.")
		return 1

	var/source_good_id = source_station.inventory["Alpha"][1]
	var/destination_good_id = destination_station.inventory["Demand"][1]
	source_station.SetGoodAmount("Alpha", source_good_id, 10)
	source_station.EnsureLiveMarketCommodity("Alpha", source_good_id, 10, 10)
	destination_station.SetGoodAmount("Demand", destination_good_id, 10)
	destination_station.EnsureLiveMarketCommodity("Demand", destination_good_id, 15, 10)

	SSsupply.visible_trading_stations = list(source_station, destination_station)
	SSsupply.all_trading_stations = list(source_station, destination_station)
	SSsupply.trade_contracts = list()

	var/datum/trade_contract/contract = SSsupply.CreateTradeContract(source_station)

	SSsupply.visible_trading_stations = original_visible_stations
	SSsupply.all_trading_stations = original_all_stations
	SSsupply.trade_contracts = original_contracts
	qdel(source_station)
	qdel(destination_station)

	if(contract)
		fail("CreateTradeContract() created a contract without shortage, demand, or profitable spread.")
	else
		pass("Trade contracts are not created without a real market opportunity.")
	return 1

/datum/unit_test/cargo_trade_contract_accept_test
	name = "CARGO: Trade contracts spawn cargo crates"

/datum/unit_test/cargo_trade_contract_accept_test/start_test()
	var/list/original_visible_stations = SSsupply.visible_trading_stations
	var/list/original_all_stations = SSsupply.all_trading_stations
	var/list/original_contracts = SSsupply.trade_contracts
	var/fail_reason = null

	var/datum/trading_station/unit_test_contract_source/source_station = new
	var/datum/trading_station/unit_test_contract_destination/destination_station = new
	source_station.AssembleInventory()
	source_station.InitGoods()
	destination_station.AssembleInventory()
	destination_station.InitGoods()
	if(!configure_cargo_contract_test_route(source_station, destination_station))
		qdel(source_station)
		qdel(destination_station)
		skip("Overmap sector unavailable for trade contract accept test.")
		return 1
	var/list/fixture = configure_cargo_market_contract_fixture(source_station, destination_station)
	var/offer_id = islist(fixture) ? fixture["source_shared_good"] : null

	SSsupply.visible_trading_stations = list(source_station, destination_station)
	SSsupply.all_trading_stations = list(source_station, destination_station)
	SSsupply.trade_contracts = list()

	var/datum/trade_contract/contract = SSsupply.CreateTradeContract(source_station)
	var/starting_amount = source_station.GetGoodAmount("Alpha", offer_id)
	var/datum/money_account/account = new
	account.owner_name = "Unit Test"
	var/obj/machinery/trade_beacon/receiving/receiver = new(get_safe_turf())

	if(!istype(contract))
		fail_reason = "CreateTradeContract() did not return a contract."
	else if(!SSsupply.AcceptTradeContract(receiver, account, contract.id))
		fail_reason = "AcceptTradeContract() failed for a valid contract."
	else if(contract.status != "active")
		fail_reason = "Contract status did not update to active."
	else if(source_station.GetGoodAmount("Alpha", offer_id) >= starting_amount)
		fail_reason = "Accepting a contract did not reserve the source station stock."
	else
		var/obj/structure/closet/crate/trade_contract/crate = locate(/obj/structure/closet/crate/trade_contract) in range(2, receiver)
		if(!istype(crate))
			fail_reason = "Contract acceptance did not spawn a contract crate."
		else if(crate.contract_id != contract.id)
			fail_reason = "Spawned contract crate was not linked to the accepted contract."

	SSsupply.visible_trading_stations = original_visible_stations
	SSsupply.all_trading_stations = original_all_stations
	SSsupply.trade_contracts = original_contracts
	qdel(receiver)
	qdel(source_station)
	qdel(destination_station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade contracts spawn delivery cargo and reserve stock.")
	return 1

/datum/unit_test/cargo_trade_contract_delivery_test
	name = "CARGO: Trade contracts pay out on delivery"

/datum/unit_test/cargo_trade_contract_delivery_test/start_test()
	var/list/original_visible_stations = SSsupply.visible_trading_stations
	var/list/original_all_stations = SSsupply.all_trading_stations
	var/list/original_contracts = SSsupply.trade_contracts
	var/fail_reason = null

	var/datum/trading_station/unit_test_contract_source/source_station = new
	var/datum/trading_station/unit_test_contract_destination/destination_station = new
	source_station.AssembleInventory()
	source_station.InitGoods()
	destination_station.AssembleInventory()
	destination_station.InitGoods()
	if(!configure_cargo_contract_test_route(source_station, destination_station))
		qdel(source_station)
		qdel(destination_station)
		skip("Overmap sector unavailable for trade contract delivery test.")
		return 1
	var/list/fixture = configure_cargo_market_contract_fixture(source_station, destination_station)
	var/destination_good_id = islist(fixture) ? fixture["destination_shared_good"] : null

	SSsupply.visible_trading_stations = list(source_station, destination_station)
	SSsupply.all_trading_stations = list(source_station, destination_station)
	SSsupply.trade_contracts = list()

	var/datum/trade_contract/contract = SSsupply.CreateTradeContract(source_station)
	var/datum/money_account/account = new
	account.owner_name = "Unit Test"
	var/obj/machinery/trade_beacon/receiving/receiver = new(get_safe_turf())
	var/obj/machinery/trade_beacon/sending/sender = new(get_turf(receiver))
	var/starting_money = 500
	var/starting_destination_stock = destination_station.GetGoodAmount("Demand", destination_good_id)
	var/starting_destination_demand = destination_station.GetLiveMarketDemandScore("Demand", destination_good_id)
	account.money = starting_money

	if(!istype(contract))
		fail_reason = "CreateTradeContract() did not return a contract."
	else if(!SSsupply.AcceptTradeContract(receiver, account, contract.id))
		fail_reason = "AcceptTradeContract() failed for a valid contract."
	else
		var/obj/structure/closet/crate/trade_contract/crate = locate(/obj/structure/closet/crate/trade_contract) in range(2, receiver)
		if(!istype(crate))
			fail_reason = "Contract crate was not spawned for delivery test."
		else
			crate.forceMove(get_turf(sender))
			if(!SSsupply.DeliverTradeContract(sender, contract.id))
				fail_reason = "DeliverTradeContract() failed for a crate in sender range."
			else if(account.money <= starting_money)
				fail_reason = "Delivering the contract did not pay the linked account."
			else if(contract.status != "completed")
				fail_reason = "Contract status did not update to completed."
			else if(destination_station.GetGoodAmount("Demand", destination_good_id) <= starting_destination_stock)
				fail_reason = "Contract delivery did not replenish destination market stock."
			else if(destination_station.GetLiveMarketDemandScore("Demand", destination_good_id) >= starting_destination_demand)
				fail_reason = "Contract delivery did not cool destination market demand."

	SSsupply.visible_trading_stations = original_visible_stations
	SSsupply.all_trading_stations = original_all_stations
	SSsupply.trade_contracts = original_contracts
	qdel(receiver)
	qdel(sender)
	qdel(source_station)
	qdel(destination_station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade contract delivery pays out and completes.")
	return 1

/datum/unit_test/cargo_trade_contract_tamper_test
	name = "CARGO: Tampering fails trade contracts"

/datum/unit_test/cargo_trade_contract_tamper_test/start_test()
	var/list/original_visible_stations = SSsupply.visible_trading_stations
	var/list/original_all_stations = SSsupply.all_trading_stations
	var/list/original_contracts = SSsupply.trade_contracts
	var/fail_reason = null

	var/datum/trading_station/unit_test_contract_source/source_station = new
	var/datum/trading_station/unit_test_contract_destination/destination_station = new
	source_station.AssembleInventory()
	source_station.InitGoods()
	destination_station.AssembleInventory()
	destination_station.InitGoods()
	if(!configure_cargo_contract_test_route(source_station, destination_station))
		qdel(source_station)
		qdel(destination_station)
		skip("Overmap sector unavailable for trade contract tamper test.")
		return 1
	var/list/fixture = configure_cargo_market_contract_fixture(source_station, destination_station)
	var/destination_good_id = islist(fixture) ? fixture["destination_shared_good"] : null

	SSsupply.visible_trading_stations = list(source_station, destination_station)
	SSsupply.all_trading_stations = list(source_station, destination_station)
	SSsupply.trade_contracts = list()

	var/datum/trade_contract/contract = SSsupply.CreateTradeContract(source_station)
	var/datum/money_account/account = new
	account.owner_name = "Unit Test"
	account.money = 1000
	var/obj/machinery/trade_beacon/receiving/receiver = new(get_safe_turf())
	var/starting_destination_stock = destination_station.GetGoodAmount("Demand", destination_good_id)
	var/starting_destination_demand = destination_station.GetLiveMarketDemandScore("Demand", destination_good_id)

	if(!istype(contract))
		fail_reason = "CreateTradeContract() did not return a contract."
	else if(!SSsupply.AcceptTradeContract(receiver, account, contract.id))
		fail_reason = "AcceptTradeContract() failed for a valid contract."
	else
		var/obj/structure/closet/crate/trade_contract/crate = locate(/obj/structure/closet/crate/trade_contract) in range(2, receiver)
		if(!istype(crate))
			fail_reason = "Contract crate was not spawned for tamper test."
		else
			crate.toggle(null)
			if(contract.status != "failed")
				fail_reason = "Tampering did not mark the contract as failed."
			else if(account.money != max(0, 1000 - round(contract.base_value * 2)))
				fail_reason = "Tampering penalty was [account.money], expected [max(0, 1000 - round(contract.base_value * 2))]."
			else if(destination_station.GetGoodAmount("Demand", destination_good_id) != starting_destination_stock)
				fail_reason = "Failed contract changed destination market stock."
			else if(destination_station.GetLiveMarketDemandScore("Demand", destination_good_id) != starting_destination_demand)
				fail_reason = "Failed contract changed destination market demand."

	SSsupply.visible_trading_stations = original_visible_stations
	SSsupply.all_trading_stations = original_all_stations
	SSsupply.trade_contracts = original_contracts
	qdel(receiver)
	qdel(source_station)
	qdel(destination_station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Tampering fails contracts and applies penalties.")
	return 1

/datum/unit_test/cargo_trade_contract_reward_snapshot_test
	name = "CARGO: Trade contract reward uses creation snapshot"

/datum/unit_test/cargo_trade_contract_reward_snapshot_test/start_test()
	var/list/original_visible_stations = SSsupply.visible_trading_stations
	var/list/original_all_stations = SSsupply.all_trading_stations
	var/list/original_contracts = SSsupply.trade_contracts
	var/fail_reason = null

	var/datum/trading_station/unit_test_contract_source/source_station = new
	var/datum/trading_station/unit_test_contract_destination/destination_station = new
	source_station.AssembleInventory()
	source_station.InitGoods()
	destination_station.AssembleInventory()
	destination_station.InitGoods()
	if(!configure_cargo_contract_test_route(source_station, destination_station))
		qdel(source_station)
		qdel(destination_station)
		skip("Overmap sector unavailable for trade contract reward snapshot test.")
		return 1
	var/list/fixture = configure_cargo_market_contract_fixture(source_station, destination_station)
	var/destination_good_id = islist(fixture) ? fixture["destination_shared_good"] : null

	SSsupply.visible_trading_stations = list(source_station, destination_station)
	SSsupply.all_trading_stations = list(source_station, destination_station)
	SSsupply.trade_contracts = list()

	var/datum/trade_contract/contract = SSsupply.CreateTradeContract(source_station)
	var/snapshotted_reward = contract ? contract.reward : 0
	var/datum/money_account/account = new
	account.owner_name = "Unit Test"
	account.money = 250
	var/obj/machinery/trade_beacon/receiving/receiver = new(get_safe_turf())
	var/obj/machinery/trade_beacon/sending/sender = new(get_turf(receiver))

	if(!istype(contract))
		fail_reason = "CreateTradeContract() did not return a contract."
	else
		destination_station.SetGoodAmount("Demand", destination_good_id, 0)
		destination_station.AdjustLiveMarketDemand("Demand", destination_good_id, 5)
		if(!SSsupply.AcceptTradeContract(receiver, account, contract.id))
			fail_reason = "AcceptTradeContract() failed for reward snapshot test."
		else
			var/obj/structure/closet/crate/trade_contract/crate = locate(/obj/structure/closet/crate/trade_contract) in range(2, receiver)
			if(!istype(crate))
				fail_reason = "Contract crate was not spawned for reward snapshot test."
			else
				crate.forceMove(get_turf(sender))
				if(!SSsupply.DeliverTradeContract(sender, contract.id))
					fail_reason = "DeliverTradeContract() failed for reward snapshot test."
				else if(account.money != 250 + snapshotted_reward)
					fail_reason = "Delivery paid [account.money - 250] instead of snapshotted reward [snapshotted_reward]."
				else if(contract.reward != snapshotted_reward)
					fail_reason = "Contract reward changed from [snapshotted_reward] to [contract.reward] after market movement."

	SSsupply.visible_trading_stations = original_visible_stations
	SSsupply.all_trading_stations = original_all_stations
	SSsupply.trade_contracts = original_contracts
	qdel(receiver)
	qdel(sender)
	qdel(source_station)
	qdel(destination_station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade contracts keep their reward snapshot even if the market moves.")
	return 1

/datum/unit_test/cargo_caravan_rendezvous_contract_test
	name = "CARGO: Caravan rendezvous contracts transmit market intelligence"

/datum/unit_test/cargo_caravan_rendezvous_contract_test/start_test()
	var/list/original_visible_stations = SSsupply.visible_trading_stations
	var/list/original_all_stations = SSsupply.all_trading_stations
	var/list/original_contracts = SSsupply.trade_contracts
	var/fail_reason = null

	var/datum/trading_station/unit_test_contract_source/source_station = new
	var/datum/trading_station/unit_test_contract_destination/destination_station = new
	source_station.AssembleInventory()
	source_station.InitGoods()
	destination_station.AssembleInventory()
	destination_station.InitGoods()
	if(!configure_cargo_contract_test_route(source_station, destination_station))
		qdel(source_station)
		qdel(destination_station)
		skip("Overmap sector unavailable for caravan rendezvous contract test.")
		return 1

	var/datum/trading_station/caravan/caravan_station = configure_cargo_caravan_contract_fixture(source_station, destination_station)
	var/obj/overmap/trade_beacon/caravan/caravan_object = caravan_station ? caravan_station.overmap_object : null
	SSsupply.visible_trading_stations = list(source_station, caravan_station)
	SSsupply.all_trading_stations = list(source_station, caravan_station)
	SSsupply.trade_contracts = list()

	var/datum/trade_contract/caravan_rendezvous/contract = SSsupply.CreateCaravanRendezvousContract(caravan_station)
	var/datum/money_account/account = new
	account.owner_name = "Unit Test"
	account.money = 250
	var/starting_money = account.money
	var/obj/machinery/trade_beacon/receiving/receiver = new(get_safe_turf())
	var/obj/machinery/trade_beacon/sending/sender = new(get_turf(receiver))

	if(!istype(contract))
		fail_reason = "CreateCaravanRendezvousContract() did not return a caravan rendezvous contract."
	else if(contract.GetTypeLabel() != "Rendezvous Contract")
		fail_reason = "Caravan contract did not expose the rendezvous type label."
	else if(!SSsupply.AcceptTradeContract(receiver, account, contract.id))
		fail_reason = "AcceptTradeContract() failed for a valid caravan rendezvous contract."
	else if(contract.status != "active")
		fail_reason = "Caravan contract status did not update to active."
	else if(locate(/obj/structure/closet/crate/trade_contract) in range(2, receiver))
		fail_reason = "Caravan rendezvous contracts should not spawn a contract crate."
	else if(!SSsupply.DeliverTradeContract(sender, contract.id))
		fail_reason = "DeliverTradeContract() failed for a caravan rendezvous contract in beacon range."
	else if(contract.status != "completed")
		fail_reason = "Caravan rendezvous contract did not complete after transmission."
	else if(account.money <= starting_money)
		fail_reason = "Completing a caravan rendezvous contract did not pay the linked account."

	SSsupply.visible_trading_stations = original_visible_stations
	SSsupply.all_trading_stations = original_all_stations
	SSsupply.trade_contracts = original_contracts
	qdel(receiver)
	qdel(sender)
	qdel(caravan_object)
	qdel(caravan_station)
	qdel(source_station)
	qdel(destination_station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Caravan rendezvous contracts accept, transmit, and pay out without spawning cargo.")
	return 1

/datum/unit_test/cargo_caravan_rendezvous_departure_fail_test
	name = "CARGO: Caravan rendezvous contracts fail when the caravan departs"

/datum/unit_test/cargo_caravan_rendezvous_departure_fail_test/start_test()
	var/list/original_visible_stations = SSsupply.visible_trading_stations
	var/list/original_all_stations = SSsupply.all_trading_stations
	var/list/original_contracts = SSsupply.trade_contracts
	var/fail_reason = null

	var/datum/trading_station/unit_test_contract_source/source_station = new
	var/datum/trading_station/unit_test_contract_destination/destination_station = new
	source_station.AssembleInventory()
	source_station.InitGoods()
	destination_station.AssembleInventory()
	destination_station.InitGoods()
	if(!configure_cargo_contract_test_route(source_station, destination_station))
		qdel(source_station)
		qdel(destination_station)
		skip("Overmap sector unavailable for caravan departure fail test.")
		return 1

	var/datum/trading_station/caravan/caravan_station = configure_cargo_caravan_contract_fixture(source_station, destination_station)
	var/obj/overmap/trade_beacon/caravan/caravan_object = caravan_station ? caravan_station.overmap_object : null
	SSsupply.visible_trading_stations = list(source_station, caravan_station)
	SSsupply.all_trading_stations = list(source_station, caravan_station)
	SSsupply.trade_contracts = list()

	var/datum/trade_contract/caravan_rendezvous/contract = SSsupply.CreateCaravanRendezvousContract(caravan_station)
	var/datum/money_account/account = new
	account.owner_name = "Unit Test"
	var/obj/machinery/trade_beacon/receiving/receiver = new(get_safe_turf())

	if(!istype(contract))
		fail_reason = "CreateCaravanRendezvousContract() did not return a contract for departure fail test."
	else if(!SSsupply.AcceptTradeContract(receiver, account, contract.id))
		fail_reason = "AcceptTradeContract() failed before departure fail test could run."
	else
		qdel(caravan_object)
		SSsupply.RefreshCaravanContracts()
		if(contract.status != "failed")
			fail_reason = "Caravan contract did not fail after the caravan became unavailable."
		else if(contract.failure_reason != "Target caravan departed before data handoff.")
			fail_reason = "Caravan departure failure reason was '[contract.failure_reason]' instead of the expected data-handoff message."

	SSsupply.visible_trading_stations = original_visible_stations
	SSsupply.all_trading_stations = original_all_stations
	SSsupply.trade_contracts = original_contracts
	qdel(receiver)
	qdel(caravan_station)
	qdel(source_station)
	qdel(destination_station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Caravan rendezvous contracts fail immediately when the target caravan departs.")
	return 1
