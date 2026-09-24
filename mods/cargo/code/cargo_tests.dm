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

/datum/unit_test/cargo_native_station_inventory_test
	name = "CARGO: Native stations declare catalog contents"

/datum/unit_test/cargo_native_station_inventory_test/start_test()
	var/list/required_station_uids = list(
		"operations",
		"engineering",
		"atmospherics",
		"materials",
		"security",
		"medicine",
		"science",
		"service",
		"civilian",
		"munitions"
	)
	for(var/station_uid in required_station_uids)
		var/datum/trading_station/trading_station = SSsupply.GetStationByUid(station_uid)
		if(!istype(trading_station))
			fail("Trading station [station_uid] was not initialized.")
			return 1
		if(!length(trading_station.inventory) && !length(trading_station.hidden_inventory))
			fail("Trading station [station_uid] has no inventory.")
			return 1
	pass("Native stations initialized with catalog contents.")
	return 1

/datum/unit_test/cargo_native_good_names_test
	name = "CARGO: Native stations generate descriptive names for cartridges, seeds, and accessories"

/datum/unit_test/cargo_native_good_names_test/start_test()
	var/datum/trading_station/med_station = SSsupply.GetStationByUid("medicine")
	if(!istype(med_station))
		fail("Medicine station was not initialized.")
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

	var/datum/trading_station/service_station = SSsupply.GetStationByUid("service")
	if(!istype(service_station))
		fail("Service station was not initialized.")
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

	var/datum/trading_station/sec_station = SSsupply.GetStationByUid("security")
	if(!istype(sec_station))
		fail("Security station was not initialized.")
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

	pass("Native stations generated descriptive names for cartridges, seeds, and accessories.")
	return 1

/datum/trading_station/unit_test_duplicate_pricing
	name = "Unit Test Trader"
	desc = "Trade station used for cargo unit tests."
	uid = "unit_test_duplicate_pricing"
	spawn_probability = 0
	spawn_cost = 0
	base_income = 0
	live_market_enabled = FALSE

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

/datum/unit_test/cargo_export_science_disk_test
	name = "CARGO EXPORT: Research report disks are valued and sold"

/datum/unit_test/cargo_export_science_disk_test/start_test()
	var/turf/safe_turf = get_safe_turf()
	if(!safe_turf)
		skip("Safe turf unavailable.")
		return 1

	for(var/atom/movable/AM in range(2, safe_turf))
		if(!AM.anchored)
			qdel(AM)

	var/obj/machinery/trade_beacon/sending/beacon = new(safe_turf)
	var/datum/money_account/account = new
	account.owner_name = "Cargo Test Account"
	account.account_number = 888101
	account.money = 0
	all_money_accounts += account

	var/obj/structure/closet/crate/crate = new(safe_turf)
	var/obj/item/disk/research_report/report = new(crate)
	report.cargo_value = 300

	var/expected_crate_val = initial(crate.points_per_crate) * CARGO_POINT_TO_THALLER + 300
	var/calc_val = SSsupply.GetExportValue(crate)
	var/fail_reason = null

	if(calc_val != expected_crate_val)
		fail_reason = "GetExportValue returned [calc_val], expected [expected_crate_val]."
	else if(!SSsupply.Export(beacon, account))
		fail_reason = "Export() failed for crate containing research report disk."
	else if(account.money != expected_crate_val)
		fail_reason = "Cargo account credited [account.money], expected [expected_crate_val]."

	all_money_accounts -= account
	qdel(account)
	qdel(beacon)
	if(crate)
		qdel(crate)
	if(report)
		qdel(report)

	for(var/atom/movable/AM in range(2, safe_turf))
		if(!AM.anchored)
			qdel(AM)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Research report disks are correctly valued and sold.")
	return 1

/datum/unit_test/cargo_export_virology_dish_test
	name = "CARGO EXPORT: Virology dishes are sold and recorded uniquely"

/datum/unit_test/cargo_export_virology_dish_test/start_test()
	var/turf/safe_turf = get_safe_turf()
	if(!safe_turf)
		skip("Safe turf unavailable.")
		return 1

	for(var/atom/movable/AM in range(2, safe_turf))
		if(!AM.anchored)
			qdel(AM)

	var/obj/machinery/trade_beacon/sending/beacon = new(safe_turf)
	var/datum/money_account/account = new
	account.owner_name = "Medical Cargo Account"
	account.account_number = 888102
	account.money = 0
	all_money_accounts += account

	var/test_strain_id = 998877
	SSsupply.sold_virus_strains -= test_strain_id

	var/obj/structure/closet/crate/crate = new(safe_turf)
	var/obj/item/virusdish/dish1 = new(crate)
	dish1.analysed = TRUE
	dish1.virus2 = new /datum/disease2/disease
	dish1.virus2.uniqueID = test_strain_id

	var/obj/item/virusdish/dish2 = new(crate)
	dish2.analysed = TRUE
	dish2.virus2 = new /datum/disease2/disease
	dish2.virus2.uniqueID = test_strain_id

	var/expected_val = initial(crate.points_per_crate) * CARGO_POINT_TO_THALLER + (5 * CARGO_POINT_TO_THALLER)
	var/calc_val = SSsupply.GetExportValue(crate)
	var/fail_reason = null

	if(calc_val != expected_val)
		fail_reason = "Duplicate strain in crate was counted multiple times. Expected [expected_val], got [calc_val]."
	else if(!SSsupply.Export(beacon, account))
		fail_reason = "Export() failed for crate containing virology dishes."
	else if(account.money != expected_val)
		fail_reason = "Account payout was [account.money], expected [expected_val]."
	else if(!(test_strain_id in SSsupply.sold_virus_strains))
		fail_reason = "Strain ID [test_strain_id] was not recorded in SSsupply.sold_virus_strains."
	else
		var/obj/item/virusdish/dish3 = new(safe_turf)
		dish3.analysed = TRUE
		dish3.virus2 = new /datum/disease2/disease
		dish3.virus2.uniqueID = test_strain_id
		var/second_val = SSsupply.GetExportValue(dish3)
		if(second_val != 0)
			fail_reason = "Previously sold virus strain was valued at [second_val] instead of 0."
		qdel(dish3)

	all_money_accounts -= account
	qdel(account)
	qdel(beacon)
	if(crate)
		qdel(crate)
	if(dish1)
		qdel(dish1)
	if(dish2)
		qdel(dish2)

	for(var/atom/movable/AM in range(2, safe_turf))
		if(!AM.anchored)
			qdel(AM)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Virology dishes sold uniquely and recorded in sold_virus_strains.")
	return 1

/datum/unit_test/cargo_export_rnd_invoice_redirection_test
	name = "CARGO EXPORT: RnD invoice redirects crate earnings to science account"

/datum/unit_test/cargo_export_rnd_invoice_redirection_test/start_test()
	var/turf/safe_turf = get_safe_turf()
	if(!safe_turf)
		skip("Safe turf unavailable.")
		return 1

	for(var/atom/movable/AM in range(2, safe_turf))
		if(!AM.anchored)
			qdel(AM)

	var/obj/machinery/trade_beacon/sending/beacon = new(safe_turf)
	var/datum/money_account/cargo_account = new
	cargo_account.owner_name = "Cargo Dept"
	cargo_account.account_number = 888103
	cargo_account.money = 0
	all_money_accounts += cargo_account

	var/datum/money_account/science_account = new
	science_account.owner_name = "Science Dept"
	science_account.account_number = 888104
	science_account.money = 0
	all_money_accounts += science_account

	var/obj/structure/closet/crate/crate = new(safe_turf)
	var/obj/item/paper/manifest/rnd_invoice/invoice = new(crate)
	invoice.target_account_number = science_account.account_number
	invoice.stamped = list("Science")
	invoice.is_copy = FALSE

	var/obj/item/disk/research_report/report = new(crate)
	report.cargo_value = 450

	var/expected_crate_val = initial(crate.points_per_crate) * CARGO_POINT_TO_THALLER + 450
	var/fail_reason = null

	if(!SSsupply.Export(beacon, cargo_account))
		fail_reason = "Export() failed for crate with R&D invoice."
	else if(cargo_account.money != 0)
		fail_reason = "Cargo account received [cargo_account.money] instead of 0."
	else if(science_account.money != expected_crate_val)
		fail_reason = "Science account received [science_account.money], expected [expected_crate_val]."

	all_money_accounts -= cargo_account
	all_money_accounts -= science_account
	qdel(cargo_account)
	qdel(science_account)
	qdel(beacon)
	if(crate)
		qdel(crate)
	if(report)
		qdel(report)
	if(invoice)
		qdel(invoice)

	for(var/atom/movable/AM in range(2, safe_turf))
		if(!AM.anchored)
			qdel(AM)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("R&D invoice correctly redirected all crate earnings to science account.")
	return 1

/datum/unit_test/cargo_order_escrow_low_cargo_budget_test
	name = "CARGO: Order approval succeeds with zero cargo funds via escrow"

/datum/unit_test/cargo_order_escrow_low_cargo_budget_test/start_test()
	var/turf/safe_turf = get_safe_turf()
	if(!safe_turf)
		skip("Safe turf unavailable.")
		return 1

	for(var/atom/movable/AM in range(2, safe_turf))
		if(!AM.anchored)
			qdel(AM)

	var/datum/money_account/old_supply = department_accounts["Supply"]
	var/datum/money_account/cargo_account = new
	cargo_account.owner_name = "Supply Account"
	cargo_account.account_number = 777001
	cargo_account.money = 0
	department_accounts["Supply"] = cargo_account
	all_money_accounts += cargo_account

	var/datum/money_account/customer_account = new
	customer_account.owner_name = "Customer"
	customer_account.account_number = 777002
	customer_account.money = 16500
	all_money_accounts += customer_account

	var/datum/trading_station/unit_test_duplicate_pricing/station = new
	station.AssembleInventory()
	station.InitGoods()
	var/good_id = station.inventory["Alpha"][1]
	station.SetGoodAmount("Alpha", good_id, 5)

	var/obj/machinery/trade_beacon/receiving/beacon = new(safe_turf)
	var/list/shop_list = list()
	var/list/goods = list()
	goods[good_id] = 1
	shop_list[station] = list("Alpha" = goods)

	var/order_id = SSsupply.BuildOrder(customer_account, "Personal tool", shop_list, FACTION_INDEPENDENT)
	var/list/order_data = SSsupply.order_queue[order_id]
	order_data["cost"] = 15000
	order_data["fee"] = 1500

	var/fail_reason = null
	if(!SSsupply.PurchaseOrder(beacon, order_id))
		fail_reason = "PurchaseOrder() failed when cargo account had 0 funds."
	else if(customer_account.money != 0)
		fail_reason = "Customer account balance is [customer_account.money], expected 0."
	else if(cargo_account.money != 1500)
		fail_reason = "Cargo account balance is [cargo_account.money], expected fee of 1500."
	else if(order_id in SSsupply.order_queue)
		fail_reason = "Successful order [order_id] was not removed from order_queue."

	department_accounts["Supply"] = old_supply
	all_money_accounts -= cargo_account
	all_money_accounts -= customer_account
	qdel(cargo_account)
	qdel(customer_account)
	qdel(beacon)
	qdel(station)

	for(var/atom/movable/AM in range(2, safe_turf))
		if(!AM.anchored)
			qdel(AM)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Escrow orders succeed even when cargo has 0 balance, correctly retaining fee.")
	return 1

/datum/unit_test/cargo_order_escrow_refund_on_failure_test
	name = "CARGO: Failed order approval refunds customer escrow payment in full"

/datum/unit_test/cargo_order_escrow_refund_on_failure_test/start_test()
	var/turf/safe_turf = get_safe_turf()
	if(!safe_turf)
		skip("Safe turf unavailable.")
		return 1

	var/datum/money_account/old_supply = department_accounts["Supply"]
	var/datum/money_account/cargo_account = new
	cargo_account.owner_name = "Supply Account"
	cargo_account.account_number = 777003
	cargo_account.money = 0
	department_accounts["Supply"] = cargo_account
	all_money_accounts += cargo_account

	var/datum/money_account/customer_account = new
	customer_account.owner_name = "Customer"
	customer_account.account_number = 777004
	customer_account.money = 16500
	all_money_accounts += customer_account

	var/datum/trading_station/unit_test_duplicate_pricing/station = new
	station.AssembleInventory()
	station.InitGoods()
	var/good_id = station.inventory["Alpha"][1]
	station.SetGoodAmount("Alpha", good_id, 0)

	var/obj/machinery/trade_beacon/receiving/beacon = new(safe_turf)
	var/list/shop_list = list()
	var/list/goods = list()
	goods[good_id] = 1
	shop_list[station] = list("Alpha" = goods)

	var/order_id = SSsupply.BuildOrder(customer_account, "Sold out item", shop_list, FACTION_INDEPENDENT)
	var/list/order_data = SSsupply.order_queue[order_id]
	order_data["cost"] = 15000
	order_data["fee"] = 1500

	var/fail_reason = null
	if(SSsupply.PurchaseOrder(beacon, order_id))
		fail_reason = "PurchaseOrder() succeeded despite out-of-stock item."
	else if(customer_account.money != 16500)
		fail_reason = "Customer account was not refunded after failed Buy(). Balance: [customer_account.money]."
	else if(cargo_account.money != 0)
		fail_reason = "Cargo account retained funds after failed Buy(). Balance: [cargo_account.money]."
	else if(!(order_id in SSsupply.order_queue))
		fail_reason = "Failed order [order_id] was prematurely removed from order_queue."

	department_accounts["Supply"] = old_supply
	all_money_accounts -= cargo_account
	all_money_accounts -= customer_account
	qdel(cargo_account)
	qdel(customer_account)
	qdel(beacon)
	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Escrow payment is refunded in full upon purchase failure.")
	return 1

/datum/unit_test/cargo_station_wealth_bounds_test
	name = "CARGO: Station wealth never drops below zero"

/datum/unit_test/cargo_station_wealth_bounds_test/start_test()
	var/datum/trading_station/unit_test_duplicate_pricing/station = new
	station.wealth = 100

	station.SubtractFromWealth(250)
	var/fail_reason = null
	if(station.wealth != 0)
		fail_reason = "Station wealth dropped to [station.wealth] instead of being clamped to 0."

	station.wealth = 50
	station.SubtractFromWealth(50)
	if(!fail_reason && station.wealth != 0)
		fail_reason = "Station wealth is [station.wealth] after exact subtraction, expected 0."

	qdel(station)
	if(fail_reason)
		fail(fail_reason)
	else
		pass("Station wealth is properly clamped to zero.")
	return 1

/datum/unit_test/cargo_export_partial_purchase_wealth_test
	name = "CARGO: Export partially purchases goods within station wealth"

/datum/unit_test/cargo_export_partial_purchase_wealth_test/start_test()
	var/turf/safe_turf = get_safe_turf()
	if(!safe_turf)
		skip("Safe turf unavailable.")
		return 1

	var/obj/machinery/trade_beacon/sending/beacon = new(safe_turf)
	var/datum/money_account/seller_account = new
	seller_account.owner_name = "Export Seller"
	seller_account.account_number = 777005
	seller_account.money = 0
	all_money_accounts += seller_account

	var/datum/trading_station/unit_test_duplicate_pricing/station = new
	station.AssembleInventory()
	station.wealth = 15

	var/obj/item/pen/pen1 = new(safe_turf)
	var/obj/item/pen/pen2 = new(safe_turf)

	var/export_result = SSsupply.Export(beacon, seller_account, station)
	var/fail_reason = null

	if(export_result != TRADE_EXPORT_PARTIAL)
		fail_reason = "Export() returned [export_result], expected TRADE_EXPORT_PARTIAL ([TRADE_EXPORT_PARTIAL])."
	else if(seller_account.money != 10)
		fail_reason = "Seller credited [seller_account.money], expected 10."
	else if(station.wealth != 5)
		fail_reason = "Station wealth is [station.wealth], expected 5 (15 - 10)."
	else if(QDELETED(pen1) == QDELETED(pen2))
		fail_reason = "Expected exactly one pen to be exported and one left intact on turf."

	all_money_accounts -= seller_account
	qdel(seller_account)
	qdel(beacon)
	qdel(station)
	if(!QDELETED(pen1))
		qdel(pen1)
	if(!QDELETED(pen2))
		qdel(pen2)

	for(var/atom/movable/AM in range(2, safe_turf))
		if(!AM.anchored)
			qdel(AM)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Export greedily purchases within station wealth and leaves remaining items on beacon.")
	return 1

/datum/unit_test/cargo_export_cooldown_not_triggered_on_failure_test
	name = "CARGO: Export cooldown is not triggered on failed or zero-value exports"

/datum/unit_test/cargo_export_cooldown_not_triggered_on_failure_test/start_test()
	var/turf/safe_turf = get_safe_turf()
	if(!safe_turf)
		skip("Safe turf unavailable.")
		return 1

	var/obj/machinery/trade_beacon/sending/beacon = new(safe_turf)
	var/datum/money_account/seller_account = new
	seller_account.owner_name = "Seller"
	seller_account.money = 0
	all_money_accounts += seller_account

	var/fail_reason = null
	beacon.export_cooldown = 0

	if(SSsupply.Export(beacon, seller_account))
		fail_reason = "Export() succeeded on empty beacon."
	else if(beacon.export_cooldown != 0)
		fail_reason = "Beacon cooldown activated on empty export ([beacon.export_cooldown])."

	if(!fail_reason)
		var/datum/trading_station/unit_test_duplicate_pricing/station = new
		station.AssembleInventory()
		station.wealth = 0
		var/obj/item/pen/pen = new(safe_turf)

		if(SSsupply.Export(beacon, seller_account, station))
			fail_reason = "Export() succeeded to station with 0 wealth."
		else if(beacon.export_cooldown != 0)
			fail_reason = "Beacon cooldown activated when station had 0 wealth."
		else if(QDELETED(pen))
			fail_reason = "Item was deleted when export failed."

		qdel(pen)
		qdel(station)

	all_money_accounts -= seller_account
	qdel(seller_account)
	qdel(beacon)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Beacon cooldown is never triggered on failed exports.")
	return 1

/datum/unit_test/cargo_caravan_rendezvous_intel_disk_test
	name = "CARGO: Caravan rendezvous dispenses and requires encrypted intel disk"

/datum/unit_test/cargo_caravan_rendezvous_intel_disk_test/start_test()
	var/turf/safe_turf = get_safe_turf()
	if(!safe_turf)
		skip("Safe turf unavailable.")
		return 1

	for(var/atom/movable/AM in range(2, safe_turf))
		if(!AM.anchored)
			qdel(AM)

	var/datum/money_account/account = new
	account.owner_name = "Courier Account"
	account.money = 1000
	all_money_accounts += account

	var/obj/machinery/trade_beacon/receiving/receiver = new(safe_turf)
	var/obj/machinery/trade_beacon/sending/sender = new(safe_turf)

	var/datum/trading_station/unit_test_duplicate_pricing/source_station = new
	source_station.name = "Source Station"
	source_station.uid = "source_station_test"
	SSsupply.all_trading_stations += source_station
	SSsupply.visible_trading_stations += source_station

	var/datum/trading_station/caravan/caravan_station = new(FALSE)
	caravan_station.name = "Caravan Test"
	caravan_station.uid = "caravan_station_test"
	SSsupply.all_trading_stations += caravan_station
	SSsupply.visible_trading_stations += caravan_station

	var/datum/trade_contract/caravan_rendezvous/contract = new
	contract.id = 9991
	contract.contract_serial = 1234
	contract.source_uid = source_station.uid
	contract.destination_uid = caravan_station.uid
	contract.reward = 350
	contract.status = CONTRACT_STATUS_AVAILABLE
	SSsupply.trade_contracts += contract

	var/fail_reason = null
	if(!contract.Accept(receiver, account))
		fail_reason = "Failed to accept caravan rendezvous contract."
	else if(!istype(contract.assigned_disk, /obj/item/disk/trade_data))
		fail_reason = "Accepting contract did not assign a trade_data disk."
	else if(contract.assigned_disk.contract_id != contract.id)
		fail_reason = "Assigned disk contract_id mismatch: [contract.assigned_disk.contract_id] vs [contract.id]."
	else
		var/obj/item/disk/trade_data/disk = contract.assigned_disk
		disk.forceMove(null)
		if(contract.CanFulfillDeliveryPayload(sender))
			fail_reason = "CanFulfillDeliveryPayload() returned TRUE without disk on sender beacon."
		else
			disk.forceMove(safe_turf)
			if(!contract.CanFulfillDeliveryPayload(sender))
				fail_reason = "CanFulfillDeliveryPayload() returned FALSE with disk in range."
			else if(!contract.Deliver(sender))
				fail_reason = "Deliver() failed with valid intel disk."
			else if(contract.status != CONTRACT_STATUS_COMPLETED)
				fail_reason = "Contract status is [contract.status], expected COMPLETED."
			else if(account.money != 1350)
				fail_reason = "Account balance is [account.money], expected 1350."
			else if(!QDELETED(disk))
				fail_reason = "Intel disk was not deleted upon delivery."

	SSsupply.trade_contracts -= contract
	SSsupply.all_trading_stations -= source_station
	SSsupply.visible_trading_stations -= source_station
	SSsupply.all_trading_stations -= caravan_station
	SSsupply.visible_trading_stations -= caravan_station
	all_money_accounts -= account
	qdel(contract)
	qdel(source_station)
	qdel(caravan_station)
	qdel(account)
	qdel(receiver)
	qdel(sender)

	for(var/atom/movable/AM in range(2, safe_turf))
		if(!AM.anchored)
			qdel(AM)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Caravan rendezvous successfully dispenses, validates, and consumes encrypted intel disk.")
	return 1

/datum/unit_test/cargo_trade_offer_datum_test
	name = "CARGO: Trade offer datum lifecycle and operations"

/datum/unit_test/cargo_trade_offer_datum_test/start_test()
	var/datum/trade_offer/offer = new("offer_test_1", /obj/item/pen, "Test Pen", "A pen", "Tools", 50, 10, 10, 0, list("writing" = TRUE))
	var/fail_reason = null
	if(offer.id != "offer_test_1" || offer.base_price != 50 || offer.stock != 10)
		fail_reason = "Offer fields not initialized correctly."
	else if(!offer.CanFulfill(5) || offer.CanFulfill(15))
		fail_reason = "CanFulfill() logic incorrect."
	else if(!offer.ConsumeStock(4) || offer.stock != 6)
		fail_reason = "ConsumeStock() did not decrement stock properly."
	else if(offer.ConsumeStock(10))
		fail_reason = "ConsumeStock() allowed overdrawing stock."
	else
		offer.AdjustStock(5)
		if(offer.stock != 11)
			fail_reason = "AdjustStock() failed."
		else
			fail_reason = VerifyOfferCloningAndSerial(offer)
	qdel(offer)
	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade offer datum lifecycle and operations function correctly.")
	return 1

/datum/unit_test/cargo_trade_offer_datum_test/proc/VerifyOfferCloningAndSerial(datum/trade_offer/offer)
	var/datum/trade_offer/clone = offer.Duplicate("offer_test_2")
	if(!clone || clone.id != "offer_test_2" || clone.stock != offer.stock)
		qdel(clone)
		return "Duplicate() failed."
	var/list/data = clone.Serialize()
	qdel(clone)
	if(!islist(data) || data["id"] != "offer_test_2" || data["base_price"] != 50)
		return "Serialize() did not return valid offer data."
	return null

/datum/unit_test/cargo_station_offer_registry_test
	name = "CARGO: Trading station offer registry indexing"

/datum/unit_test/cargo_station_offer_registry_test/start_test()
	var/datum/trading_station/unit_test_duplicate_pricing/station = new
	station.AssembleInventory()
	var/fail_reason = null
	if(!length(station.offers) || !length(station.offers_by_category))
		fail_reason = "Offers registry empty after AssembleInventory()."
	else
		var/good_id = station.inventory["Alpha"][1]
		var/datum/trade_offer/offer = station.GetOffer(good_id)
		if(!offer || offer.id != good_id)
			fail_reason = "GetOffer() failed to retrieve offer by ID."
		else if(station.GetOfferByPath(/obj/item/pen) != offer)
			fail_reason = "GetOfferByPath() failed to resolve pen offer."
		else
			var/list/cat_offers = station.GetOffersByCategory("Alpha")
			if(!islist(cat_offers) || !(offer in cat_offers))
				fail_reason = "GetOffersByCategory() did not return category offers."
	qdel(station)
	if(fail_reason)
		fail(fail_reason)
	else
		pass("Station offer registry indexes offers and maintains category access.")
	return 1

/datum/unit_test/cargo_2level_cart_test
	name = "CARGO: 2-level cart UID structure and extraction"

/datum/unit_test/cargo_2level_cart_test/start_test()
	var/datum/trading_station/unit_test_duplicate_pricing/station = new
	station.AssembleInventory()
	var/already_registered = (station in SSsupply.all_trading_stations)
	if(!already_registered)
		SSsupply.all_trading_stations += station
	var/good_id = station.inventory["Alpha"][1]
	var/list/cart = list()
	var/datum/computer_file/program/supply/prog = new
	prog.shopping_list = cart
	prog.station = station
	prog.AddToShopList(good_id, 3, 3, station)
	var/fail_reason = null
	if(!islist(cart[station.uid]) || cart[station.uid][good_id] != 3)
		fail_reason = "AddToShopList() did not populate 2-level cart structure."
	else if(SSsupply.CollectCountsFrom(cart) != 3)
		fail_reason = "CollectCountsFrom() returned incorrect count for 2-level cart."
	else
		var/list/items = SSsupply.ExtractCartItems(cart)
		if(!length(items) || items[1]["count"] != 3 || items[1]["station"] != station)
			fail_reason = "ExtractCartItems() failed to normalize 2-level cart entry."
	if(!already_registered)
		SSsupply.all_trading_stations -= station
	qdel(prog)
	qdel(station)
	if(fail_reason)
		fail(fail_reason)
	else
		pass("2-level cart structure functions correctly with helper procs.")
	return 1

/datum/unit_test/cargo_snapshot_security_test
	name = "CARGO: Market snapshot rejects mismatched good IDs"

/datum/unit_test/cargo_snapshot_security_test/start_test()
	var/datum/trading_station/unit_test_duplicate_pricing/station = new
	station.AssembleInventory()
	var/good_id = station.inventory["Alpha"][1]
	var/list/cart = list()
	var/list/goods = list()
	goods[good_id] = 1
	cart[station] = list("Alpha" = goods)
	var/list/snap = SSsupply.BuildMarketSnapshot(cart, FACTION_INDEPENDENT)
	var/fail_reason = null
	var/valid_price = SSsupply.GetSnapshotUnitPrice(snap, station, "Alpha", good_id)
	if(!valid_price)
		fail_reason = "GetSnapshotUnitPrice() returned null for valid good_id."
	else
		var/bad_price = SSsupply.GetSnapshotUnitPrice(snap, station, "Alpha", "nonexistent_exploit_id")
		if(!isnull(bad_price))
			fail_reason = "GetSnapshotUnitPrice() returned price [bad_price] for nonexistent good_id!"
	qdel(station)
	if(fail_reason)
		fail(fail_reason)
	else
		pass("Market snapshot securely returns null for invalid offer IDs.")
	return 1

/datum/unit_test/cargo_asset_cache_icon_test
	name = "CARGO: Asset cache registers commodity icons as file references"

/datum/unit_test/cargo_asset_cache_icon_test/start_test()
	var/datum/computer_file/program/supply/prog = new
	var/asset_name = prog.GetGoodIconAsset(/obj/item/wrench)
	var/fail_reason = null
	if(!asset_name || !istext(asset_name))
		fail_reason = "GetGoodIconAsset() failed to generate asset name for /obj/item/wrench."
	else if(!findtext(asset_name, "cargo_icon_"))
		fail_reason = "GetGoodIconAsset() returned invalid asset filename format: [asset_name]"
	else
		var/singleton/asset_cache/asset_cache = GET_SINGLETON(/singleton/asset_cache)
		if(!asset_cache.cache[asset_name])
			fail_reason = "Asset [asset_name] was not registered in asset_cache singleton."
	qdel(prog)
	if(fail_reason)
		fail(fail_reason)
	else
		pass("Commodity icon properly registered in asset cache without Base64 overhead.")
	return 1

/datum/unit_test/cargo_export_biological_containment_test
	name = "CARGO: Export beacon detects biological matter at arbitrary nesting depths"

/datum/unit_test/cargo_export_biological_containment_test/start_test()
	var/turf/safe_turf = get_safe_turf()
	var/obj/structure/closet/crate/crate = new(safe_turf)
	var/obj/item/storage/backpack/backpack = new(crate)
	var/obj/item/storage/box/box = new(backpack)
	var/mob/living/simple_animal/passive/mouse/mouse = new(box)

	var/fail_reason = null
	if(!SSsupply.HasLivingOccupants(crate))
		fail_reason = "HasLivingOccupants() failed to detect living mob nested at depth 4."
	else if(SSsupply.CanExportAtom(crate))
		fail_reason = "CanExportAtom() allowed export of crate with deeply nested living mob."

	qdel(mouse)
	qdel(box)
	qdel(backpack)
	qdel(crate)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Biological containment correctly rejects arbitrarily nested living occupants.")
	return 1

/datum/unit_test/cargo_contract_circular_reference_test
	name = "CARGO: Contract and crate/disk references clean up cooperatively on deletion"

/datum/unit_test/cargo_contract_circular_reference_test/start_test()
	var/turf/safe_turf = get_safe_turf()
	var/obj/structure/closet/crate/trade_contract/crate = new(safe_turf)
	var/datum/trade_contract/contract = new
	crate.linked_contract = contract
	contract.assigned_crate = crate

	var/fail_reason = null
	qdel(crate)
	if(!isnull(contract.assigned_crate))
		fail_reason = "Deleting crate failed to clear contract.assigned_crate reference."

	var/obj/item/disk/trade_data/disk = new(safe_turf)
	var/datum/trade_contract/caravan_rendezvous/caravan_contract = new
	disk.linked_contract = caravan_contract
	caravan_contract.assigned_disk = disk

	qdel(disk)
	if(!isnull(caravan_contract.assigned_disk))
		fail_reason = "Deleting disk failed to clear caravan_contract.assigned_disk reference."

	var/obj/structure/closet/crate/trade_contract/crate2 = new(safe_turf)
	contract.assigned_crate = crate2
	crate2.linked_contract = contract
	qdel(contract)
	if(!isnull(crate2.linked_contract))
		fail_reason = "Deleting contract failed to clear crate.linked_contract reference."

	qdel(caravan_contract)
	qdel(crate2)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Cooperative destruction cleanly severed circular references between contracts and crates/disks.")
	return 1

/datum/unit_test/cargo_loose_storage_export_dumps_contents_test
	name = "CARGO: Exporting loose storage container dumps unpurchased contents to turf"

/datum/unit_test/cargo_loose_storage_export_dumps_contents_test/start_test()
	var/turf/safe_turf = get_safe_turf()
	var/obj/machinery/trade_beacon/sending/beacon = new(safe_turf)
	var/obj/item/storage/backpack/backpack = new(safe_turf)
	var/obj/item/pen/pen = new(backpack)

	var/datum/money_account/account = new
	account.owner_name = "Unit Test Storage"
	account.money = 0

	var/export_result = SSsupply.Export(beacon, account, null, FACTION_INDEPENDENT)
	var/fail_reason = null
	if(!export_result)
		fail_reason = "Export of loose storage container failed."
	else if(!QDELETED(backpack))
		fail_reason = "Exported backpack was not deleted."
	else if(QDELETED(pen))
		fail_reason = "Item inside exported backpack was destroyed instead of dumped."
	else if(pen.loc != safe_turf)
		fail_reason = "Item inside exported backpack was not dumped onto the beacon turf."

	QDEL_NULL(pen)
	QDEL_NULL(backpack)
	QDEL_NULL(beacon)
	QDEL_NULL(account)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Loose storage export successfully emptied child contents onto turf before container disposal.")
	return 1

