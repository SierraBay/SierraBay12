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

/datum/unit_test/cargo_legacy_good_names_test
	name = "CARGO: Legacy stations generate descriptive names for cartridges, seeds, and accessories"

/datum/unit_test/cargo_legacy_good_names_test/start_test()
	var/datum/trading_station/med_station = SSsupply.GetStationByUid("legacy_medicine")
	if(!istype(med_station))
		fail("Legacy medicine station was not initialized.")
		return 1

	for(var/cat_name in med_station.inventory)
		var/list/goods = med_station.inventory[cat_name]
		if(!islist(goods))
			continue
		for(var/good_id in goods)
			var/good_path = med_station.GetGoodPath(cat_name, good_id)
			if(ispath(good_path, /obj/item/reagent_containers/chem_disp_cartridge))
				var/good_name = med_station.GetGoodName(cat_name, good_id)
				if(good_name == "chemical dispenser cartridge")
					var/obj/item/reagent_containers/chem_disp_cartridge/cartridge = good_path
					if(initial(cartridge.spawn_reagent))
						fail("Cartridge with reagent [initial(cartridge.spawn_reagent)] has generic name '[good_name]'.")
						return 1

	var/datum/trading_station/service_station = SSsupply.GetStationByUid("legacy_service")
	if(!istype(service_station))
		fail("Legacy service station was not initialized.")
		return 1

	for(var/cat_name in service_station.inventory)
		var/list/goods = service_station.inventory[cat_name]
		if(!islist(goods))
			continue
		for(var/good_id in goods)
			var/good_path = service_station.GetGoodPath(cat_name, good_id)
			if(ispath(good_path, /obj/item/seeds) && good_path != /obj/item/seeds && good_path != /obj/item/seeds/random)
				var/obj/item/seeds/seed_item = good_path
				if(initial(seed_item.seed_type))
					var/good_name = service_station.GetGoodName(cat_name, good_id)
					if(good_name == "packet of seeds")
						fail("Seed [good_path] with seed_type '[initial(seed_item.seed_type)]' has generic name '[good_name]'.")
						return 1

	var/datum/trading_station/sec_station = SSsupply.GetStationByUid("legacy_security")
	if(!istype(sec_station))
		fail("Legacy security station was not initialized.")
		return 1

	for(var/cat_name in sec_station.inventory)
		var/list/goods = sec_station.inventory[cat_name]
		if(!islist(goods))
			continue
		for(var/good_id in goods)
			var/good_path = sec_station.GetGoodPath(cat_name, good_id)
			if(ispath(good_path, /obj/item/clothing/accessory/arm_guards/blue))
				var/good_name = sec_station.GetGoodName(cat_name, good_id)
				if(good_name == "arm guards")
					fail("Blue arm guards have generic name '[good_name]'.")
					return 1

	pass("Legacy stations generated descriptive names for cartridges, seeds, and accessories.")
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
	qdel(account)
	qdel(station)
	return 1

/datum/unit_test/cargo_trade_station_smart_placement_spacing_test
	name = "CARGO: Smart beacon placement avoids clustering"

/datum/unit_test/cargo_trade_station_smart_placement_spacing_test/start_test()
	var/list/original_all_stations = SSsupply.all_trading_stations
	var/fail_reason = null
	var/turf/source_turf = get_safe_turf()
	var/obj/overmap/visitable/current_sector = SSsupply.GetOvermapSectorFor(source_turf)
	if(!istype(source_turf) || !istype(current_sector))
		skip("Overmap sector unavailable for smart placement spacing test.")
		return 1

	var/datum/trading_station/unit_test_duplicate_pricing/anchor_station = new
	var/datum/trading_station/unit_test_duplicate_pricing/test_station = new
	test_station.min_overmap_station_spacing = 5
	test_station.preferred_distance_from_base = 8
	test_station.max_distance_from_base = 20

	var/turf/near_turf = null
	var/turf/far_turf = null

	var/list/candidates = list()
	for(var/turf/candidate as anything in test_station.GetOvermapSpawnCandidateTurfs(current_sector.z))
		var/base_distance = test_station.GetBaseDistance(candidate)
		if(isnum(base_distance) && (base_distance < test_station.min_distance_from_base || base_distance > test_station.max_distance_from_base))
			continue
		candidates += candidate

	for(var/turf/candidate_a as anything in candidates)
		for(var/turf/candidate_b as anything in candidates)
			if(get_dist(candidate_a, candidate_b) >= test_station.min_overmap_station_spacing)
				near_turf = candidate_a
				far_turf = candidate_b
				break
		if(near_turf && far_turf)
			break

	if(!istype(near_turf) || !istype(far_turf))
		qdel(anchor_station)
		qdel(test_station)
		skip("Suitable overmap turfs unavailable for smart placement spacing test.")
		return 1

	anchor_station.overmap_location = near_turf
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
	var/turf/source_turf = get_safe_turf()
	var/obj/overmap/visitable/current_sector = SSsupply.GetOvermapSectorFor(source_turf)
	if(!istype(source_turf) || !istype(current_sector))
		skip("Overmap sector unavailable for smart placement hazard test.")
		return 1

	var/datum/trading_station/unit_test_duplicate_pricing/test_station = new
	test_station.hazard_buffer = 1

	var/turf/hazard_turf = null
	var/turf/adjacent_turf = null

	for(var/turf/candidate as anything in test_station.GetOvermapSpawnCandidateTurfs(current_sector.z))
		for(var/turf/neighbor as anything in RANGE_TURFS(candidate, 1))
			if(neighbor == candidate)
				continue
			if(test_station.CanUseOvermapSpawnLocation(neighbor))
				hazard_turf = candidate
				adjacent_turf = neighbor
				break
		if(hazard_turf && adjacent_turf)
			break

	if(!istype(hazard_turf) || !istype(adjacent_turf))
		qdel(test_station)
		skip("Suitable overmap turfs unavailable for smart placement hazard test.")
		return 1

	var/fail_reason = null
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
