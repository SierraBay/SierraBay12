/datum/trading_station/unit_test_live_market
	name = "Unit Test Live Market"
	desc = "Trade station used for live-market unit tests."
	uid = "unit_test_live_market"
	spawn_probability = 0
	spawn_cost = 0
	base_income = 0
	wealth = 100000
	live_market_remote_quote_limit = 3
	live_market_auto_events = FALSE

/datum/trading_station/unit_test_live_market/AssembleInventory()
	inventory = list(
		"Alpha" = list(/obj/item/pen = GOODS_DATA("Live Market Pen", null, 100)),
		"Materials" = list(/obj/item/stack/material/steel/ten = GOODS_DATA("Steel Bundle", null, 80))
	)
	hidden_inventory = list()
	amounts_of_goods = list()
	unique_good_count = 0
	next_good_offer_id = 0
	live_market_state = list()
	live_market_modifiers = list()
	NormalizeGoodsRecords()

/datum/unit_test/cargo_market_buy_price_test
	name = "CARGO MARKET: Buy price reacts to shortages"

/datum/unit_test/cargo_market_buy_price_test/start_test()
	var/datum/trading_station/unit_test_live_market/station = new
	var/fail_reason = null

	station.AssembleInventory()
	station.InitGoods()
	var/good_id = station.inventory["Alpha"][1]
	if(!good_id)
		fail_reason = "Failed to create buy-price test inventory."
	else
		station.SetGoodAmount("Alpha", good_id, 10)
		station.EnsureLiveMarketCommodity("Alpha", good_id, 100, 10)
		var/steady_price = SSsupply.GetStationBuyPrice(good_id, station, FACTION_INDEPENDENT, "Alpha")
		station.SetGoodAmount("Alpha", good_id, 2)
		var/shortage_price = SSsupply.GetStationBuyPrice(good_id, station, FACTION_INDEPENDENT, "Alpha")
		if(shortage_price <= steady_price)
			fail_reason = "Shortage price [shortage_price] did not exceed steady price [steady_price]."

	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Buy prices rise under shortage pressure.")
	return 1

/datum/unit_test/cargo_market_sell_price_test
	name = "CARGO MARKET: Sell price is distinct from buy price"

/datum/unit_test/cargo_market_sell_price_test/start_test()
	var/datum/trading_station/unit_test_live_market/station = new
	var/fail_reason = null

	station.AssembleInventory()
	station.InitGoods()
	var/good_id = station.inventory["Alpha"][1]
	if(!good_id)
		fail_reason = "Failed to create sell-price test inventory."
	else
		station.SetGoodAmount("Alpha", good_id, 10)
		station.EnsureLiveMarketCommodity("Alpha", good_id, 100, 10)
		var/buy_price = SSsupply.GetStationBuyPrice(good_id, station, FACTION_INDEPENDENT, "Alpha")
		var/sell_price = SSsupply.GetStationSellPrice(good_id, station, "Alpha")
		if(sell_price >= buy_price)
			fail_reason = "Sell price [sell_price] should be lower than buy price [buy_price]."
		else
			station.AdjustLiveMarketDemand("Alpha", good_id, 5)
			var/hot_sell_price = SSsupply.GetStationSellPrice(good_id, station, "Alpha")
			if(hot_sell_price <= sell_price)
				fail_reason = "Demand-adjusted sell price [hot_sell_price] did not rise above [sell_price]."

	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Sell prices stay distinct and react independently.")
	return 1

/datum/unit_test/cargo_market_restock_cost_test
	name = "CARGO MARKET: Restock cost ignores player-facing price swings"

/datum/unit_test/cargo_market_restock_cost_test/start_test()
	var/datum/trading_station/unit_test_live_market/station = new
	var/fail_reason = null

	station.AssembleInventory()
	station.InitGoods()
	var/good_id = station.inventory["Alpha"][1]
	if(!good_id)
		fail_reason = "Failed to create restock-cost test inventory."
	else
		station.SetGoodAmount("Alpha", good_id, 10)
		station.EnsureLiveMarketCommodity("Alpha", good_id, 100, 10)
		var/base_restock = SSsupply.GetStationRestockCost(good_id, station, "Alpha")
		station.SetGoodAmount("Alpha", good_id, 1)
		station.AdjustLiveMarketDemand("Alpha", good_id, 5)
		var/live_buy_price = SSsupply.GetStationBuyPrice(good_id, station, FACTION_INDEPENDENT, "Alpha")
		var/live_restock = SSsupply.GetStationRestockCost(good_id, station, "Alpha")
		if(live_buy_price <= base_restock)
			fail_reason = "Live buy price [live_buy_price] did not exceed restock baseline [base_restock]."
		else if(live_restock != base_restock)
			fail_reason = "Restock cost changed from [base_restock] to [live_restock]."

	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Restock cost stays anchored to station economics.")
	return 1

/datum/unit_test/cargo_market_order_quote_test
	name = "CARGO MARKET: Orders keep quoted buy prices"

/datum/unit_test/cargo_market_order_quote_test/start_test()
	var/datum/computer_file/program/supply/program = new
	var/datum/trading_station/unit_test_live_market/station = new
	var/list/original_order_queue = SSsupply.order_queue
	var/original_order_queue_id = SSsupply.order_queue_id
	var/fail_reason = null

	station.AssembleInventory()
	station.InitGoods()
	var/good_id = station.inventory["Alpha"][1]
	if(!good_id)
		fail_reason = "Failed to create quoted-order test inventory."
	else
		station.SetGoodAmount("Alpha", good_id, 10)
		station.EnsureLiveMarketCommodity("Alpha", good_id, 100, 10)
		var/datum/money_account/account = new
		account.owner_name = "Unit Test"
		SSsupply.order_queue = list()
		var/list/shop_list = list()
		var/list/categories = list("Alpha" = list())
		shop_list[station] = categories
		var/list/alpha_goods = categories["Alpha"]
		alpha_goods[good_id] = 1
		var/quoted_price = SSsupply.GetStationBuyPrice(good_id, station, FACTION_INDEPENDENT, "Alpha")
		var/order_id = SSsupply.BuildOrder(account, "Quote test", shop_list, FACTION_INDEPENDENT)
		station.SetGoodAmount("Alpha", good_id, 1)
		station.AdjustLiveMarketDemand("Alpha", good_id, 5)
		var/current_price = SSsupply.GetStationBuyPrice(good_id, station, FACTION_INDEPENDENT, "Alpha")
		program.current_order = order_id
		var/list/selected_order = program.SerializeSelectedOrder()
		if(!order_id)
			fail_reason = "BuildOrder() did not create an order."
		else if(current_price <= quoted_price)
			fail_reason = "Live price [current_price] did not move above quoted price [quoted_price]."
		else if(!islist(selected_order))
			fail_reason = "SerializeSelectedOrder() did not return order data."
		else
			var/list/groups = selected_order["contents"]
			if(length(groups) != 1)
				fail_reason = "Quoted order serialized [length(groups)] groups instead of 1."
			else
				var/list/items = groups[1]["categories"][1]["items"]
				var/list/item = length(items) ? items[1] : null
				if(!islist(item))
					fail_reason = "Quoted order did not serialize its first item."
				else if(item["price"] != quoted_price)
					fail_reason = "Serialized quote price was [item["price"]] instead of [quoted_price]."

	SSsupply.order_queue = original_order_queue
	SSsupply.order_queue_id = original_order_queue_id
	qdel(program)
	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Quoted orders preserve their buy snapshot.")
	return 1

/datum/unit_test/cargo_market_export_arbitrage_test
	name = "CARGO MARKET: Export uses destination sell price"

/datum/unit_test/cargo_market_export_arbitrage_test/start_test()
	var/datum/trading_station/unit_test_live_market/station = new
	var/datum/money_account/account = new
	var/obj/machinery/trade_beacon/sending/beacon = new(get_safe_turf())
	var/fail_reason = null

	account.owner_name = "Unit Test"
	account.money = 0
	station.AssembleInventory()
	station.InitGoods()
	var/good_id = station.inventory["Alpha"][1]
	var/good_path = station.GetGoodPath("Alpha", good_id)
	if(!good_id || !ispath(good_path, /atom/movable))
		fail_reason = "Failed to create export-arbitrage inventory."
	else
		station.SetGoodAmount("Alpha", good_id, 1)
		station.EnsureLiveMarketCommodity("Alpha", good_id, 100, 10)
		station.AdjustLiveMarketDemand("Alpha", good_id, 5)
		var/sell_price = SSsupply.GetStationSellPrice(good_id, station, "Alpha")
		for(var/atom/movable/AM in range(2, beacon))
			if(AM != beacon && !AM.anchored)
				qdel(AM)
		new good_path(get_turf(beacon))
		if(!SSsupply.Export(beacon, account, station))
			fail_reason = "Export() rejected a matching commodity."
		else if(account.money != sell_price)
			fail_reason = "Export paid [account.money] instead of destination sell price [sell_price]."
		else if(station.GetGoodAmount("Alpha", good_id) < 2)
			fail_reason = "Destination market stock was not replenished by export."

	qdel(beacon)
	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Exports pay destination sell prices and replenish the market.")
	return 1

/datum/unit_test/cargo_market_modifier_decay_test
	name = "CARGO MARKET: Event modifiers spike prices and expire"

/datum/unit_test/cargo_market_modifier_decay_test/start_test()
	var/datum/trading_station/unit_test_live_market/station = new
	var/fail_reason = null

	station.AssembleInventory()
	station.InitGoods()
	var/good_id = station.inventory["Materials"][1]
	if(!good_id)
		fail_reason = "Failed to create modifier test inventory."
	else
		station.SetGoodAmount("Materials", good_id, 10)
		station.EnsureLiveMarketCommodity("Materials", good_id, 80, 10)
		var/stable_price = SSsupply.GetStationBuyPrice(good_id, station, FACTION_INDEPENDENT, "Materials")
		station.live_market_modifiers = list()
		station.AddLiveMarketModifier("industrial_demand", 1)
		var/hot_price = SSsupply.GetStationBuyPrice(good_id, station, FACTION_INDEPENDENT, "Materials")
		station.DecayLiveMarketModifiers()
		var/cooled_price = SSsupply.GetStationBuyPrice(good_id, station, FACTION_INDEPENDENT, "Materials")
		if(hot_price <= stable_price)
			fail_reason = "Modifier price [hot_price] did not exceed stable price [stable_price]."
		else if(cooled_price != stable_price)
			fail_reason = "Price stayed at [cooled_price] instead of returning to [stable_price] after expiration."

	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Market event modifiers move and then release pricing pressure.")
	return 1

/datum/unit_test/cargo_market_intel_snapshot_test
	name = "CARGO MARKET: Intel snapshots expose market metadata"

/datum/unit_test/cargo_market_intel_snapshot_test/start_test()
	var/datum/computer_file/program/supply/program = new
	var/datum/trading_station/unit_test_live_market/station = new
	var/list/original_visible_stations = SSsupply.visible_trading_stations
	var/fail_reason = null

	station.AssembleInventory()
	station.InitGoods()
	SSsupply.visible_trading_stations = list(station)
	program.station = station
	program.chosen_category = "Alpha"
	program.RememberMarketIntel(station)
	var/list/intel_entries = program.SerializeKnownMarketIntel()
	if(length(intel_entries) != 1)
		fail_reason = "Expected 1 intel snapshot, got [length(intel_entries)]."
	else
		var/list/intel = intel_entries[1]
		if(intel["station_uid"] != station.uid)
			fail_reason = "Intel station uid was [intel["station_uid"]] instead of [station.uid]."
		else if(!length(intel["quotes"]))
			fail_reason = "Intel snapshot contained no quotes."
		else if(intel["quality"] != "detailed")
			fail_reason = "Intel quality was [intel["quality"]] instead of detailed."

	SSsupply.visible_trading_stations = original_visible_stations
	qdel(program)
	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Market intel exposes station metadata and quotes.")
	return 1

/datum/unit_test/cargo_market_isolated_state_test
	name = "CARGO MARKET: Stations maintain isolated market state and modifier lists"

/datum/unit_test/cargo_market_isolated_state_test/start_test()
	var/datum/trading_station/station_a = new
	var/datum/trading_station/station_b = new
	var/fail_reason = null

	station_a.live_market_auto_events = FALSE
	station_b.live_market_auto_events = FALSE

	station_a.InitSrc(null, TRUE)
	station_b.InitSrc(null, TRUE)

	if(station_a.live_market_state == station_b.live_market_state)
		fail_reason = "station_a and station_b share the same live_market_state list reference."
	else if(station_a.live_market_modifiers == station_b.live_market_modifiers)
		fail_reason = "station_a and station_b share the same live_market_modifiers list reference."
	else if(length(station_a.live_market_modifiers) != 0 || length(station_b.live_market_modifiers) != 0)
		fail_reason = "Stations initialized with unexpected modifiers despite auto_events disabled."
	else
		var/list/mod_a = station_a.AddLiveMarketModifier("boom", 4)
		if(!islist(mod_a) || !(mod_a in station_a.live_market_modifiers))
			fail_reason = "Failed to add modifier to station_a."
		else if(length(station_b.live_market_modifiers) > 0 || (mod_a in station_b.live_market_modifiers))
			fail_reason = "Adding modifier to station_a contaminated station_b."
		else
			station_a.EnsureLiveMarketCommodity("Alpha", "pen", 50, 10)
			station_a.AdjustLiveMarketDemand("Alpha", "pen", 2)
			if(!station_a.HasLiveMarketCommodity("Alpha", "pen"))
				fail_reason = "Failed to record market commodity state on station_a."
			else if(station_b.HasLiveMarketCommodity("Alpha", "pen") || length(station_b.live_market_state) > 0)
				fail_reason = "Updating market commodity state on station_a contaminated station_b."

	qdel(station_a)
	qdel(station_b)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Stations maintain strictly isolated market state.")
	return 1

/datum/unit_test/cargo_market_auto_event_test
	name = "CARGO MARKET: Auto events trigger and respect flag"

/datum/unit_test/cargo_market_auto_event_test/start_test()
	var/datum/trading_station/station = new
	var/fail_reason = null

	station.live_market_auto_events = FALSE
	station.InitSrc(null, TRUE)
	if(length(station.live_market_modifiers) > 0)
		fail_reason = "Station generated auto events while live_market_auto_events was FALSE."
	else
		station.live_market_auto_events = TRUE
		var/triggered = FALSE
		for(var/i in 1 to 50)
			station.EnsureLiveMarketActivity()
			if(length(station.live_market_modifiers) > 0)
				triggered = TRUE
				break
		if(!triggered)
			fail_reason = "EnsureLiveMarketActivity() failed to roll any event after 50 attempts with prob(35)."

	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Auto events respect configuration and trigger successfully.")
	return 1

/datum/unit_test/cargo_market_single_demand_accounting_test
	name = "CARGO MARKET: Buy with price snapshot records demand exactly once"

/datum/unit_test/cargo_market_single_demand_accounting_test/start_test()
	var/datum/trading_station/unit_test_live_market/station = new
	var/obj/machinery/trade_beacon/receiving/beacon = new(get_safe_turf())
	var/datum/money_account/account = new
	var/fail_reason = null

	account.owner_name = "Unit Test Account"
	account.money = 10000

	station.AssembleInventory()
	station.InitGoods()
	var/good_id = station.inventory["Alpha"][1]
	if(!good_id)
		fail_reason = "Failed to create test inventory."
	else
		station.SetGoodAmount("Alpha", good_id, 20)
		station.EnsureLiveMarketCommodity("Alpha", good_id, 100, 20)

		var/list/shop_list = list()
		var/list/categories = list("Alpha" = list())
		shop_list[station] = categories
		var/list/alpha_goods = categories["Alpha"]
		alpha_goods[good_id] = 2

		var/list/price_snapshot = SSsupply.BuildMarketSnapshot(shop_list, FACTION_INDEPENDENT)
		var/initial_demand = station.GetLiveMarketDemandScore("Alpha", good_id)

		if(!SSsupply.Buy(beacon, account, shop_list, FALSE, null, FACTION_INDEPENDENT, price_snapshot))
			fail_reason = "Buy() with price snapshot failed."
		else
			var/new_demand = station.GetLiveMarketDemandScore("Alpha", good_id)
			var/expected_demand = initial_demand + (2 / 20)
			if(abs(new_demand - expected_demand) > 0.001)
				fail_reason = "Expected demand [expected_demand], but got [new_demand] (possible double counting)."

	qdel(beacon)
	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Buy() with price snapshot increments demand exactly once.")
	return 1

/datum/unit_test/cargo_market_demand_decay_rebalance_test
	name = "CARGO MARKET: Demand decay is calibrated to 0.85"

/datum/unit_test/cargo_market_demand_decay_rebalance_test/start_test()
	var/datum/trading_station/unit_test_live_market/station = new
	var/fail_reason = null

	station.AssembleInventory()
	station.InitGoods()
	var/good_id = station.inventory["Alpha"][1]
	if(!good_id)
		fail_reason = "Failed to create test inventory."
	else if(abs(station.live_market_demand_decay - 0.85) > 0.001)
		fail_reason = "live_market_demand_decay was [station.live_market_demand_decay] instead of 0.85."
	else
		station.EnsureLiveMarketCommodity("Alpha", good_id, 100, 10)
		station.AdjustLiveMarketDemand("Alpha", good_id, 10)
		station.DecayLiveMarketDemand()
		var/demand_after_1 = station.GetLiveMarketDemandScore("Alpha", good_id)
		if(abs(demand_after_1 - 0.85) > 0.01)
			fail_reason = "Demand after 1 decay tick was [demand_after_1], expected ~0.85."
		else
			station.DecayLiveMarketDemand()
			var/demand_after_2 = station.GetLiveMarketDemandScore("Alpha", good_id)
			var/expected_2 = 0.85 * 0.85
			if(abs(demand_after_2 - expected_2) > 0.01)
				fail_reason = "Demand after 2 decay ticks was [demand_after_2], expected ~[expected_2]."

	qdel(station)
	if(fail_reason)
		fail(fail_reason)
	else
		pass("Live market demand decay holds smoothly at 0.85.")
	return 1

/datum/unit_test/cargo_market_faction_sell_price_test
	name = "CARGO MARKET: Factions influence station sell prices and export"

/datum/unit_test/cargo_market_faction_sell_price_test/start_test()
	var/datum/trading_station/unit_test_live_market/station = new
	var/datum/money_account/account = new
	var/obj/machinery/trade_beacon/sending/beacon = new(get_safe_turf())
	var/fail_reason = null

	account.owner_name = "Faction Test Account"
	account.money = 0

	station.faction = FACTION_NANOTRASEN
	station.AssembleInventory()
	station.InitGoods()
	var/good_id = station.inventory["Alpha"][1]
	var/good_path = station.GetGoodPath("Alpha", good_id)
	if(!good_id || !ispath(good_path, /atom/movable))
		fail_reason = "Failed to create test inventory."
	else
		station.SetGoodAmount("Alpha", good_id, 10)
		station.EnsureLiveMarketCommodity("Alpha", good_id, 100, 10)

		var/ally_price = SSsupply.GetStationSellPrice(good_id, station, FACTION_FREETRADE, "Alpha")
		var/neutral_price = SSsupply.GetStationSellPrice(good_id, station, FACTION_INDEPENDENT, "Alpha")
		var/hostile_price = SSsupply.GetStationSellPrice(good_id, station, FACTION_INDIE_CONFED, "Alpha")

		if(ally_price <= neutral_price)
			fail_reason = "Ally sell price [ally_price] did not exceed neutral price [neutral_price]."
		else if(neutral_price <= hostile_price)
			fail_reason = "Neutral sell price [neutral_price] did not exceed hostile price [hostile_price]."
		else
			var/datum/trade_faction/nt_faction = SSsupply.GetFaction(FACTION_NANOTRASEN)
			if(istype(nt_faction))
				nt_faction.embargo += "EmbargoedTestFaction"
				var/embargo_price = SSsupply.GetStationSellPrice(good_id, station, "EmbargoedTestFaction", "Alpha")
				if(embargo_price != 0)
					fail_reason = "Embargoed faction sell price was [embargo_price] instead of 0."
				else
					for(var/atom/movable/AM in range(2, beacon))
						if(AM != beacon && !AM.anchored)
							qdel(AM)
					new good_path(get_turf(beacon))
					if(SSsupply.Export(beacon, account, station, "EmbargoedTestFaction"))
						fail_reason = "Export succeeded for an embargoed faction."
					else if(account.money != 0)
						fail_reason = "Account received money [account.money] from an embargoed export."
				nt_faction.embargo -= "EmbargoedTestFaction"

	qdel(beacon)
	qdel(account)
	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Faction diplomatic standing correctly scales sell prices and enforces embargoes.")
	return 1

/datum/unit_test/cargo_market_volume_slippage_test
	name = "CARGO MARKET: Bulk exports experience volume price slippage"

/datum/unit_test/cargo_market_volume_slippage_test/start_test()
	var/datum/trading_station/unit_test_live_market/station = new
	var/datum/money_account/account = new
	var/obj/machinery/trade_beacon/sending/beacon = new(get_safe_turf())
	var/fail_reason = null

	account.owner_name = "Volume Slippage Account"
	account.money = 0

	station.AssembleInventory()
	station.InitGoods()
	var/good_id = station.inventory["Alpha"][1]
	var/good_path = station.GetGoodPath("Alpha", good_id)
	if(!good_id || !ispath(good_path, /atom/movable))
		fail_reason = "Failed to create test inventory."
	else
		station.SetGoodAmount("Alpha", good_id, 10)
		station.EnsureLiveMarketCommodity("Alpha", good_id, 100, 10)
		station.AdjustLiveMarketDemand("Alpha", good_id, 5)

		var/single_unit_price = SSsupply.GetStationSellPrice(good_id, station, null, "Alpha", 1)
		var/bulk_50_price = SSsupply.GetStationSellPrice(good_id, station, null, "Alpha", 50)
		var/linear_50_price = single_unit_price * 50

		if(bulk_50_price >= linear_50_price)
			fail_reason = "Bulk price [bulk_50_price] was not lower than linear price [linear_50_price] (no slippage)."
		else
			var/first_unit = SSsupply.GetStationSellPrice(good_id, station, null, "Alpha", 1, 0)
			var/mid_unit = SSsupply.GetStationSellPrice(good_id, station, null, "Alpha", 1, 20)
			var/late_unit = SSsupply.GetStationSellPrice(good_id, station, null, "Alpha", 1, 40)

			if(first_unit <= mid_unit)
				fail_reason = "First unit [first_unit] did not sell for more than mid unit [mid_unit]."
			else if(mid_unit < late_unit)
				fail_reason = "Mid unit [mid_unit] sold for less than late unit [late_unit]."
			else
				for(var/atom/movable/AM in range(2, beacon))
					if(AM != beacon && !AM.anchored)
						qdel(AM)

				var/mat_id = station.inventory["Materials"][1]
				var/mat_path = station.GetGoodPath("Materials", mat_id)
				station.SetGoodAmount("Materials", mat_id, 10)
				station.EnsureLiveMarketCommodity("Materials", mat_id, 80, 10)
				var/obj/item/stack/material/steel/ten/bundle = new mat_path(get_turf(beacon))
				var/expected_bundle_val = SSsupply.GetStationSellPrice(mat_id, station, null, "Materials", bundle.get_amount())
				if(!SSsupply.Export(beacon, account, station))
					fail_reason = "Export of stack bundle failed."
				else if(account.money != expected_bundle_val)
					fail_reason = "Export payout [account.money] did not match slipped price [expected_bundle_val]."

	qdel(beacon)
	qdel(account)
	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Volume price slippage successfully discounts bulk exports.")
	return 1

/datum/unit_test/cargo_market_intra_station_arbitrage_prevention_test
	name = "CARGO MARKET: Intra-station arbitrage is strictly impossible"

/datum/unit_test/cargo_market_intra_station_arbitrage_prevention_test/start_test()
	var/datum/trading_station/unit_test_live_market/station = new
	var/fail_reason = null

	station.AssembleInventory()
	station.InitGoods()
	var/good_id = station.inventory["Alpha"][1]
	if(!good_id)
		fail_reason = "Failed to create test inventory."
	else
		station.SetGoodAmount("Alpha", good_id, 1)
		station.EnsureLiveMarketCommodity("Alpha", good_id, 100, 10)
		station.AdjustLiveMarketDemand("Alpha", good_id, 25)

		var/buy_price = SSsupply.GetStationBuyPrice(good_id, station, FACTION_INDEPENDENT, "Alpha")
		var/sell_price = SSsupply.GetStationSellPrice(good_id, station, FACTION_INDEPENDENT, "Alpha", 1)

		if(sell_price >= buy_price)
			fail_reason = "Sell price [sell_price] reached or exceeded buy price [buy_price] on the same station."
		else if(sell_price > round(buy_price * 0.90))
			fail_reason = "Sell price [sell_price] exceeded the 90% buy price cap ([round(buy_price * 0.90)])."

	qdel(station)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Intra-station arbitrage loops are guaranteed impossible.")
	return 1
