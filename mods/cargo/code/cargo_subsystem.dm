#define MAX_SUPPLY_LOG_ENTRIES 50

// Subsystem for ship trade-network operations.
/datum/controller/subsystem/supply
	name = "Supply"
	priority = SS_PRIORITY_SUPPLY
	wait = 20 SECONDS
	trade_network_active = TRUE
	flags = 0

	var/trade_stations_budget = 5
	var/list/all_trading_stations = list()
	var/list/visible_trading_stations = list()
	var/list/hidden_trading_stations = list()
	var/list/factions = list()
	var/list/beacons_sending = list()
	var/list/beacons_receiving = list()

	var/shipping_invoice_number = 0
	var/export_invoice_number = 0
	var/order_number = 0
	var/contract_number = 0

	var/list/shipping_log = list()
	var/list/export_log = list()
	var/list/order_log = list()
	var/list/contract_log = list()

	var/handling_fee = 0.1
	var/order_queue_id = 0
	var/list/order_queue = list()
	var/trade_contract_id = 0
	var/list/trade_contracts = list()
	var/max_resolved_trade_contracts = 20
	var/min_trade_contract_distance = 3
	var/min_trade_contract_value = 120
	var/max_trade_contract_value = 800

/datum/controller/subsystem/supply/Initialize(start_uptime)
	. = ..()
	all_trading_stations = list()
	visible_trading_stations = list()
	hidden_trading_stations = list()
	factions = list()
	if(!islist(beacons_sending))
		beacons_sending = list()
	if(!islist(beacons_receiving))
		beacons_receiving = list()
	shipping_log = list()
	export_log = list()
	order_log = list()
	contract_log = list()
	order_queue = list()
	trade_contracts = list()
	point_sources = list()
	point_source_descriptions = list(
		"time" = "Legacy cargo stipend",
		"manifest" = "Legacy export manifests",
		"crate" = "Legacy crate export",
		"gep" = "Good explorer points",
		"anomaly" = "Analyzed anomalies",
		"research_reports" = "Research data compilations",
		"virology_antibodies" = "Uploaded antibody data",
		"virology_dishes" = "Exported virus dishes",
		"animal" = "Captured exotic fauna",
		"artefacts" = "Exported artefacts",
		"total" = "Total legacy income"
	)
	sold_virus_strains = list()

	for(var/faction_type in (typesof(/datum/trade_faction) - /datum/trade_faction))
		var/datum/trade_faction/trade_faction = new faction_type
		factions[trade_faction.name] = trade_faction

	InitializeRelations()
	InitTradeStations()

	RefreshTradeBeacons()

/datum/controller/subsystem/supply/fire(reschedule)
	ProcessPendingContractRefunds()
	for(var/datum/trading_station/station as anything in all_trading_stations)
		if(QDELETED(station))
			continue
		if(world.time >= station.next_update_at)
			station.StationTick()
		MC_TICK_CHECK
	EnsureVisibleContractOffers()

/datum/controller/subsystem/supply/Destroy()
	DeInitTradeStations()
	if(islist(trade_contracts))
		for(var/datum/trade_contract/contract in trade_contracts)
			qdel(contract)
		trade_contracts.Cut()
		trade_contracts = null
	if(islist(factions))
		for(var/f_key in factions)
			qdel(factions[f_key])
		factions.Cut()
		factions = null
	beacons_sending?.Cut()
	beacons_sending = null
	beacons_receiving?.Cut()
	beacons_receiving = null
	shipping_log?.Cut()
	shipping_log = null
	export_log?.Cut()
	export_log = null
	order_log?.Cut()
	order_log = null
	contract_log?.Cut()
	contract_log = null
	if(islist(order_queue))
		for(var/order_id in order_queue)
			var/list/order = order_queue[order_id]
			if(islist(order))
				order.Cut()
		order_queue.Cut()
		order_queue = null
	return ..()

/datum/controller/subsystem/supply/UpdateStat(time)
	if(PreventUpdateStat(time))
		return ..()
	var/datum/money_account/master_account = get_supply_department_account()
	var/budget = master_account ? master_account.money : 0
	return ..("Stations: [length(visible_trading_stations)] | Orders: [length(order_queue)] | Contracts: [GetActiveContractCount()] | Budget: [round(budget)]")

/datum/controller/subsystem/supply/proc/GetFaction(faction_ref)
	if(istype(faction_ref, /datum/trade_faction))
		return faction_ref
	if(istext(faction_ref) && (faction_ref in factions))
		return factions[faction_ref]
	return null

/datum/controller/subsystem/supply/proc/RefreshTradeBeacons()
	for(var/obj/machinery/trade_beacon/sending/beacon as anything in beacons_sending)
		if(QDELETED(beacon))
			beacons_sending -= beacon
	for(var/obj/machinery/trade_beacon/receiving/beacon as anything in beacons_receiving)
		if(QDELETED(beacon))
			beacons_receiving -= beacon

/datum/controller/subsystem/supply/proc/SetFactionRelations(fac1, fac2, relation)
	var/datum/trade_faction/first = GetFaction(fac1)
	var/datum/trade_faction/second = GetFaction(fac2)
	if(!istype(first) || !istype(second) || first == second || isnull(relation))
		return FALSE
	first.ModifyRelationsWith(second.name, relation)
	second.ModifyRelationsWith(first.name, relation)
	return TRUE

/datum/controller/subsystem/supply/proc/InitializeRelations()
	for(var/faction_name in factions)
		var/datum/trade_faction/first = factions[faction_name]
		first.relationship[first.name] = FACTION_STATE_PROTECTORATE
		for(var/other_name in factions)
			if(faction_name == other_name)
				continue
			var/datum/trade_faction/second = factions[other_name]
			var/has_first = (second.name in first.relationship)
			var/has_second = (first.name in second.relationship)
			if(!has_first && !has_second)
				SetFactionRelations(first, second, FACTION_STATE_NEUTRAL)
			else if(has_first && !has_second)
				second.relationship[first.name] = first.relationship[second.name]
			else if(!has_first && has_second)
				first.relationship[second.name] = second.relationship[first.name]

/datum/controller/subsystem/supply/proc/DiscoverAllTradeStations()
	visible_trading_stations = all_trading_stations.Copy()
	hidden_trading_stations = list()

/datum/controller/subsystem/supply/proc/ReInitTradeStations()
	DeInitTradeStations()
	InitTradeStations()

/datum/controller/subsystem/supply/proc/DeInitTradeStations()
	for(var/datum/trading_station/trading_station as anything in all_trading_stations.Copy())
		trading_station.RegainTradeStationsBudget()
		qdel(trading_station)
	all_trading_stations = list()
	visible_trading_stations = list()
	hidden_trading_stations = list()

/datum/controller/subsystem/supply/proc/InitTradeStations()
	var/list/weighted_station_list = CollectTradeStations()
	var/list/stations_to_init = CollectSpawnAlways()

	while(trade_stations_budget > 0 && length(weighted_station_list))
		var/station_type = pickweight(weighted_station_list)
		if(!ispath(station_type, /datum/trading_station))
			break
		stations_to_init += station_type
		var/datum/trading_station/dummy = station_type
		trade_stations_budget -= initial(dummy.spawn_cost)
		weighted_station_list.Remove(station_type)

	InitTradeStationsByList(stations_to_init)

/datum/controller/subsystem/supply/proc/InitTradeStation(station_type)
	var/datum/trading_station/trading_station
	if(istype(station_type, /datum/trading_station))
		trading_station = station_type
		if(!trading_station.name)
			trading_station.InitSrc()
	else if(ispath(station_type, /datum/trading_station))
		trading_station = new station_type(TRUE)
	return trading_station

/datum/controller/subsystem/supply/proc/InitTradeStationsByList(list/station_list)
	var/list/initialized = list()
	for(var/station_type in station_list)
		var/datum/trading_station/trading_station = InitTradeStation(station_type)
		if(istype(trading_station))
			initialized += trading_station
	return initialized

/datum/controller/subsystem/supply/proc/DiscoverByUid(list/uid_list)
	for(var/target_uid in uid_list)
		for(var/datum/trading_station/trading_station as anything in all_trading_stations)
			if(trading_station.uid != target_uid)
				continue
			if(!(trading_station in visible_trading_stations))
				visible_trading_stations += trading_station
			hidden_trading_stations -= trading_station
			if(trading_station.overmap_location)
				GLOB.entered_event.unregister(trading_station.overmap_location, trading_station, /datum/trading_station/proc/Discovered)

/datum/controller/subsystem/supply/proc/GetStationByUid(target_uid)
	if(!target_uid)
		return null
	for(var/datum/trading_station/trading_station as anything in all_trading_stations)
		if(trading_station.uid == target_uid || trading_station.name == target_uid)
			return trading_station
	return null

/datum/controller/subsystem/supply/proc/ResolveStation(station_ref)
	if(istype(station_ref, /datum/trading_station))
		return station_ref
	if(istext(station_ref))
		return GetStationByUid(station_ref)
	return null

/datum/controller/subsystem/supply/proc/GetVisibleStationByUid(target_uid)
	for(var/datum/trading_station/trading_station as anything in visible_trading_stations)
		if(trading_station.uid == target_uid)
			return trading_station
	return null

/datum/controller/subsystem/supply/proc/GetVisibleTradeStationsReportData()
	var/list/result = list()
	for(var/datum/trading_station/trading_station as anything in visible_trading_stations)
		if(!istype(trading_station) || !istype(trading_station.overmap_location))
			continue
		result.Add(list(list(
			"name" = trading_station.name,
			"desc" = trading_station.desc || "",
			"x" = trading_station.overmap_location.x,
			"y" = trading_station.overmap_location.y
		)))
	return result

/datum/controller/subsystem/supply/proc/GetAvailableContractCount()
	. = 0
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.status == CONTRACT_STATUS_AVAILABLE)
			. += 1

/datum/controller/subsystem/supply/proc/GetActiveContractCount()
	. = 0
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.status == CONTRACT_STATUS_ACTIVE)
			. += 1

/datum/controller/subsystem/supply/proc/GetTradeContract(contract_id)
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.id == contract_id)
			return contract
	return null

/datum/controller/subsystem/supply/proc/TrimResolvedContracts()
	var/resolved_count = 0
	var/datum/trade_contract/oldest_resolved = null
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.status == CONTRACT_STATUS_COMPLETED || contract.status == CONTRACT_STATUS_FAILED)
			resolved_count++
			if(contract.HasPendingRefund())
				continue
			if(!oldest_resolved || contract.resolved_at < oldest_resolved.resolved_at)
				oldest_resolved = contract
	if(resolved_count > max_resolved_trade_contracts && oldest_resolved)
		trade_contracts -= oldest_resolved
		qdel(oldest_resolved)

/datum/controller/subsystem/supply/proc/ProcessPendingContractRefunds()
	var/settled_refund = FALSE
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.HasPendingRefund() && contract.TrySettlePendingRefund())
			settled_refund = TRUE
	if(settled_refund)
		TrimResolvedContracts()

/datum/controller/subsystem/supply/proc/GetVisibleContractBySource(source_uid)
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.status != CONTRACT_STATUS_AVAILABLE || contract.source_uid != source_uid)
			continue
		if(contract.ShouldDisplayAvailable())
			return contract
	return null

/datum/controller/subsystem/supply/proc/GetVisibleContractBySourceAndType(source_uid, contract_type)
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.status != CONTRACT_STATUS_AVAILABLE || contract.source_uid != source_uid)
			continue
		if(contract.GetTypeId() != contract_type)
			continue
		if(contract.ShouldDisplayAvailable())
			return contract
	return null

/datum/controller/subsystem/supply/proc/GetPendingTradeContract(source_uid, contract_type = "delivery")
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.source_uid != source_uid)
			continue
		if(contract_type && contract.GetTypeId() != contract_type)
			continue
		if(contract.status == CONTRACT_STATUS_AVAILABLE || contract.status == CONTRACT_STATUS_ACTIVE)
			return contract
	return null

/datum/controller/subsystem/supply/proc/GetPendingCaravanContract(caravan_uid)
	var/datum/trading_station/caravan/caravan_station = GetStationByUid(caravan_uid)
	var/obj/overmap/trade_beacon/caravan/caravan_object = istype(caravan_station) ? caravan_station.overmap_object : null
	var/current_stop_uid = (istype(caravan_object) && istype(caravan_object.current_stop)) ? caravan_object.current_stop.uid : null
	var/current_window_end = istype(caravan_object) ? caravan_object.trade_window_end : 0

	for(var/datum/trade_contract/caravan_rendezvous/contract as anything in trade_contracts)
		if(!istype(contract))
			continue
		if(contract.destination_uid != caravan_uid)
			continue
		if(contract.status == CONTRACT_STATUS_AVAILABLE || contract.status == CONTRACT_STATUS_ACTIVE)
			return contract
		if(current_stop_uid && contract.source_uid == current_stop_uid && contract.trade_window_end && contract.trade_window_end == current_window_end)
			return contract
	return null

/datum/controller/subsystem/supply/proc/PickContractDestination(datum/trading_station/source_station)
	var/list/candidates = list()
	for(var/datum/trading_station/destination_station as anything in visible_trading_stations)
		if(destination_station == source_station)
			continue
		var/distance = GetTradeDistance(source_station.overmap_object, destination_station)
		if(isnum(distance) && distance < min_trade_contract_distance)
			continue
		candidates += destination_station
	if(!length(candidates))
		return null
	return pick(candidates)

/datum/controller/subsystem/supply/proc/FindStationCommodityByPath(datum/trading_station/station, item_path)
	if(!istype(station) || !ispath(item_path, /atom/movable))
		return null
	var/datum/trade_offer/offer = station.GetOfferByPath(item_path)
	if(istype(offer))
		return list(
			"category" = offer.category,
			"good_id" = offer.id
		)
	if(islist(station.commodity_by_path))
		var/list/match = station.commodity_by_path[item_path]
		if(islist(match))
			return list(
				"category" = match["category"],
				"good_id" = match["good_id"]
			)
	for(var/category_name in station.inventory)
		var/list/category = station.inventory[category_name]
		if(!islist(category))
			continue
		for(var/good_id in category)
			if(station.GetGoodPath(category_name, good_id) != item_path)
				continue
			return list(
				"category" = category_name,
				"good_id" = good_id
			)
	return null

/datum/controller/subsystem/supply/proc/GetTradeContractShortageUnits(datum/trading_station/station, category_name, good_id)
	if(!istype(station) || !istext(category_name) || !good_id)
		return 0
	var/baseline_stock = max(1, round(station.GetLiveMarketBaseline(category_name, good_id)))
	var/current_stock = max(0, round(station.GetGoodAmount(category_name, good_id)))
	return max(0, round(max(0, baseline_stock - current_stock)))

/datum/controller/subsystem/supply/proc/GetTradeContractMarketReason(destination_shortage, destination_demand, spread_ratio)
	var/has_shortage_pressure = destination_shortage >= 0.2 || destination_demand >= 0.25
	var/has_spread = spread_ratio >= 1.2
	if(has_shortage_pressure && has_spread)
		return "hybrid"
	if(has_spread)
		return "spread"
	return "shortage"

/datum/controller/subsystem/supply/proc/BuildTradeContractCandidate(datum/trading_station/source_station, datum/trading_station/destination_station, route_distance)
	if(!istype(source_station) || !istype(destination_station) || destination_station == source_station)
		return null
	if(!source_station.supports_contracts || !destination_station.supports_contracts)
		return null
	if(!(source_station in visible_trading_stations) || !(destination_station in visible_trading_stations))
		return null
	if(!isnum(route_distance) || route_distance < min_trade_contract_distance)
		return null

	var/target_value = clamp(route_distance * 120, min_trade_contract_value, max_trade_contract_value)
	var/list/best_candidate = null

	for(var/source_category_name in source_station.inventory)
		var/list/source_category = source_station.inventory[source_category_name]
		if(!islist(source_category))
			continue
		for(var/source_good_id in source_category)
			var/list/candidate = BuildTradeContractCommodityCandidate(source_station, destination_station, route_distance, target_value, source_category_name, source_good_id)
			if(IsBetterTradeContractCandidate(candidate, best_candidate))
				best_candidate = candidate

	return best_candidate

/datum/controller/subsystem/supply/proc/IsBetterTradeContractCandidate(list/candidate, list/current_best)
	if(!islist(candidate))
		return FALSE
	if(!islist(current_best))
		return TRUE
	return candidate["score"] > current_best["score"] || (candidate["score"] == current_best["score"] && candidate["base_value"] > current_best["base_value"])

/datum/controller/subsystem/supply/proc/BuildTradeContractCommodityCandidate(datum/trading_station/source_station, datum/trading_station/destination_station, route_distance, target_value, source_category_name, source_good_id)
	var/source_available = source_station.GetGoodAmount(source_category_name, source_good_id)
	if(source_available < 1)
		return null
	var/item_path = source_station.GetGoodPath(source_category_name, source_good_id)
	if(!ispath(item_path, /atom/movable))
		return null
	var/source_unit_cost = GetStationRestockCost(source_good_id, source_station, source_category_name)
	if(source_unit_cost < 1)
		return null

	var/source_surplus = max(0, -source_station.GetLiveMarketStockPressure(source_category_name, source_good_id))
	var/desired_amount = max(1, round(target_value / source_unit_cost))
	var/list/destination_match = FindStationCommodityByPath(destination_station, item_path)
	var/list/market
	if(islist(destination_match))
		market = GetSharedContractMarket(destination_station, destination_match, source_unit_cost, source_available, desired_amount, source_surplus, route_distance)
	else
		market = GetUnmatchedContractMarket(destination_station, source_good_id, source_unit_cost, source_available, desired_amount, source_surplus, route_distance, target_value)
	if(!islist(market))
		return null

	var/amount = market["amount"]
	if(amount < 1)
		return null
	var/base_value = source_unit_cost * amount
	if(base_value < min_trade_contract_value)
		return null

	var/destination_sell_price = market["sell_price"]
	var/value_commission = round(base_value * 0.2)
	var/distance_pay = round(route_distance * 35)
	var/spread_pay = round(max(0, (destination_sell_price - source_unit_cost) * amount) * 0.5)
	var/calculated_reward = max(value_commission + distance_pay, value_commission + spread_pay)
	return list(
		"score" = market["score"],
		"market_reason" = market["reason"],
		"source_category" = source_category_name,
		"source_good_id" = source_good_id,
		"destination_category" = market["category"],
		"destination_good_id" = market["good_id"],
		"source_unit_cost" = source_unit_cost,
		"destination_sell_price" = destination_sell_price,
		"distance" = route_distance,
		"base_value" = base_value,
		"reward" = max(100, calculated_reward),
		"deposit" = round(base_value * 0.3),
		"penalty" = round(base_value * 1.5),
		"content" = list(
			"category" = source_category_name,
			"good_id" = source_good_id,
			"destination_category" = market["category"],
			"destination_good_id" = market["good_id"],
			"item_path" = item_path,
			"name" = source_station.GetGoodName(source_category_name, source_good_id),
			"amount" = amount
		)
	)

/datum/controller/subsystem/supply/proc/GetSharedContractMarket(datum/trading_station/destination_station, list/destination_match, source_unit_cost, source_available, desired_amount, source_surplus, route_distance)
	var/category_name = destination_match["category"]
	var/good_id = destination_match["good_id"]
	var/sell_price = GetStationSellPrice(good_id, destination_station, category_name)
	if(sell_price < 1)
		return null
	var/shortage = max(0, destination_station.GetLiveMarketStockPressure(category_name, good_id))
	var/demand = max(0, destination_station.GetLiveMarketDemandScore(category_name, good_id))
	var/spread_ratio = sell_price / max(1, source_unit_cost)
	if(shortage < 0.2 && demand < 0.25 && spread_ratio < 1.2)
		return null

	// Shared arbitrage must outrank generic procurement.
	var/score = 3.0 + (shortage * 4) + (demand * 2) + (max(0, spread_ratio - 1) * 2) + source_surplus + min(route_distance / 10, 1)
	var/amount = min(source_available, desired_amount)
	if(shortage > 0)
		var/shortage_units = max(1, GetTradeContractShortageUnits(destination_station, category_name, good_id))
		amount = min(amount, shortage_units)
	return list(
		"category" = category_name,
		"good_id" = good_id,
		"sell_price" = sell_price,
		"reason" = GetTradeContractMarketReason(shortage, demand, spread_ratio),
		"score" = score,
		"amount" = amount
	)

/datum/controller/subsystem/supply/proc/GetUnmatchedContractMarket(datum/trading_station/destination_station, source_good_id, source_unit_cost, source_available, desired_amount, source_surplus, route_distance, target_value)
	var/amount = min(source_available, desired_amount)
	var/base_value = source_unit_cost * amount
	var/value_fit = max(0, 1 - (abs(base_value - target_value) / max(target_value, 1)))
	var/diversity_salt = ((length(destination_station.name) * 7) + (length(source_good_id) * 13) + (trade_contract_id * 11)) % 23 / 100
	// Unmatched freight stays below the shared arbitrage score of at least 3.0.
	var/score = 0.3 + (source_surplus * 0.6) + (value_fit * 0.3) + min(route_distance / 30, 0.3) + diversity_salt
	return list(
		"category" = null,
		"good_id" = null,
		"sell_price" = round(source_unit_cost * 1.35),
		"reason" = (source_surplus >= 0.2) ? "surplus_export" : "procurement",
		"score" = score,
		"amount" = amount
	)

/datum/controller/subsystem/supply/proc/CreateTradeContract(datum/trading_station/source_station)
	if(!istype(source_station) || !source_station.supports_contracts || !(source_station in visible_trading_stations) || GetPendingTradeContract(source_station.uid, "delivery"))
		return null

	var/list/best_candidate = null
	var/datum/trading_station/destination_station = null
	for(var/datum/trading_station/candidate_destination as anything in visible_trading_stations)
		if(candidate_destination == source_station || !candidate_destination.supports_contracts)
			continue
		var/route_distance = GetTradeDistance(source_station.overmap_object || source_station, candidate_destination)
		if(!isnum(route_distance) || route_distance < min_trade_contract_distance)
			continue
		var/list/candidate = BuildTradeContractCandidate(source_station, candidate_destination, route_distance)
		if(IsBetterTradeContractCandidate(candidate, best_candidate))
			best_candidate = candidate
			destination_station = candidate_destination

	if(!istype(destination_station) || !islist(best_candidate))
		return null

	var/datum/trade_contract/contract = new
	contract.id = "contract_[++trade_contract_id]"
	contract.contract_serial = "[1000 + trade_contract_id]"
	contract.source_uid = source_station.uid
	contract.destination_uid = destination_station.uid
	contract.contents = list(best_candidate["content"])
	contract.source_category = best_candidate["source_category"]
	contract.source_good_id = best_candidate["source_good_id"]
	contract.destination_category = best_candidate["destination_category"]
	contract.destination_good_id = best_candidate["destination_good_id"]
	contract.market_reason = best_candidate["market_reason"]
	contract.snapshot_source_unit_cost = best_candidate["source_unit_cost"]
	contract.snapshot_destination_sell_price = best_candidate["destination_sell_price"]
	contract.market_score = best_candidate["score"]
	contract.distance = best_candidate["distance"]
	contract.created_at = world.time
	contract.base_value = best_candidate["base_value"]
	contract.reward = best_candidate["reward"]
	contract.deposit = best_candidate["deposit"]
	contract.penalty = best_candidate["penalty"]
	trade_contracts += contract
	return contract

/datum/controller/subsystem/supply/proc/CreateCaravanRendezvousContract(datum/trading_station/caravan/caravan_station)
	if(!istype(caravan_station) || !(caravan_station in visible_trading_stations) || GetPendingCaravanContract(caravan_station.uid))
		return null

	var/datum/trading_station/source_station = null
	var/obj/overmap/trade_beacon/caravan/caravan_object = caravan_station.overmap_object
	if(istype(caravan_object) && istype(caravan_object.current_stop))
		source_station = caravan_object.current_stop
	if(!istype(source_station) || !(source_station in visible_trading_stations))
		return null
	if(!istype(source_station.overmap_location) || !istype(caravan_station.overmap_location))
		return null

	var/route_distance = max(min_trade_contract_distance, get_dist(source_station.overmap_location, caravan_station.overmap_location))
	var/base_value = clamp(120 + (route_distance * 30), min_trade_contract_value, max_trade_contract_value)

	var/datum/trade_contract/caravan_rendezvous/contract = new
	contract.id = "contract_[++trade_contract_id]"
	contract.contract_serial = "[1000 + trade_contract_id]"
	contract.source_uid = source_station.uid
	contract.destination_uid = caravan_station.uid
	contract.market_reason = "market_intelligence"
	contract.distance = route_distance
	contract.created_at = world.time
	contract.base_value = base_value
	contract.reward = clamp(round(120 + (route_distance * 20)), 120, 350)
	contract.deposit = 0
	contract.penalty = 0
	contract.trade_window_end = caravan_object ? caravan_object.trade_window_end : 0
	trade_contracts += contract
	return contract

/datum/controller/subsystem/supply/proc/RefreshCaravanContracts()
	for(var/datum/trade_contract/contract as anything in trade_contracts.Copy())
		if(!istype(contract, /datum/trade_contract/caravan_rendezvous))
			continue
		if(contract.status == CONTRACT_STATUS_AVAILABLE && !contract.ShouldDisplayAvailable())
			trade_contracts -= contract
			qdel(contract)
			continue
		if(contract.status == CONTRACT_STATUS_ACTIVE && !contract.CanStayActive())
			contract.HandleActiveTargetLoss()

/datum/controller/subsystem/supply/proc/EnsureVisibleContractOffers()
	RefreshCaravanContracts()
	for(var/datum/trade_contract/contract as anything in trade_contracts.Copy())
		if(contract.status == CONTRACT_STATUS_ACTIVE && !contract.CanStayActive())
			contract.HandleActiveTargetLoss()
			continue
		if(contract.status != CONTRACT_STATUS_AVAILABLE || contract.GetTypeId() != "delivery")
			continue
		if(!contract.CanAccept())
			trade_contracts -= contract
			qdel(contract)
	for(var/datum/trading_station/source_station as anything in visible_trading_stations)
		if(!source_station.supports_contracts)
			continue
		if(GetPendingTradeContract(source_station.uid, "delivery"))
			continue
		CreateTradeContract(source_station)
	for(var/datum/trading_station/caravan/caravan_station as anything in visible_trading_stations)
		CreateCaravanRendezvousContract(caravan_station)

/datum/controller/subsystem/supply/proc/AcceptTradeContract(obj/machinery/trade_beacon/receiving/receiver_beacon, datum/money_account/account, contract_id, buyer_faction = null)
	var/datum/trade_contract/contract = GetTradeContract(contract_id)
	if(!istype(contract))
		return FALSE
	return contract.Accept(receiver_beacon, account, buyer_faction)

/datum/controller/subsystem/supply/proc/DeliverTradeContract(obj/machinery/trade_beacon/sending/sender_beacon, contract_id)
	var/datum/trade_contract/contract = GetTradeContract(contract_id)
	if(!istype(contract))
		return FALSE
	return contract.Deliver(sender_beacon)

/datum/controller/subsystem/supply/proc/GetOvermapSectorFor(atom/source)
	if(!GLOB.using_map.use_overmap || !istype(source))
		return null
	var/turf/source_turf = get_turf(source)
	if(!istype(source_turf))
		return null
	return map_sectors["[source_turf.z]"]

/datum/controller/subsystem/supply/proc/GetTradeDistance(source, datum/trading_station/station)
	if(!GLOB.using_map.use_overmap || !istype(station))
		return null

	var/turf/target_turf = station.overmap_location
	if(!istype(target_turf))
		return null

	var/atom/origin
	if(istype(source, /datum/trading_station))
		var/datum/trading_station/source_station = source
		origin = source_station.overmap_location || get_turf(source_station.overmap_object)
	else if(istype(source, /obj/overmap))
		origin = source
	else if(isturf(source))
		var/turf/source_turf = source
		origin = (source_turf.z == target_turf.z) ? source_turf : GetOvermapSectorFor(source_turf)
	else if(istype(source, /atom))
		origin = GetOvermapSectorFor(source)

	if(!istype(origin) || origin.z != target_turf.z)
		return null

	return get_dist(origin, target_turf)

/datum/controller/subsystem/supply/proc/GetTradeRangeBlockReason(atom/source, datum/trading_station/station)
	if(!GLOB.using_map.use_overmap || !istype(station) || !station.overmap_location || station.trade_range < 0)
		return null
	var/availability_block = station.GetAvailabilityBlockReason(source)
	if(availability_block)
		return availability_block

	var/obj/overmap/visitable/current_sector = GetOvermapSectorFor(source)
	if(!istype(current_sector))
		return "Trade delivery is available only while your vessel is present on the overmap."
	if(current_sector.z != station.overmap_location.z)
		return "This trade beacon is outside your current overmap region."

	var/distance = get_dist(current_sector, station.overmap_location)
	if(distance > station.trade_range)
		var/range_suffix = station.trade_range == 1 ? "" : "s"
		return "Move within [station.trade_range] overmap tile[range_suffix] of this trade beacon to receive goods."
	return null

/datum/controller/subsystem/supply/proc/GetShopListTradeRangeBlockReason(atom/source, list/shop_list)
	if(!islist(shop_list))
		return null
	for(var/station_key in shop_list)
		var/datum/trading_station/station = ResolveStation(station_key)
		if(!istype(station))
			continue
		var/block_reason = GetTradeRangeBlockReason(source, station)
		if(block_reason)
			return "[station.name]: [block_reason]"
	return null

/datum/controller/subsystem/supply/proc/GetStationFactionBlockReason(datum/trading_station/target_station, buyer_faction = null)
	if(!istype(target_station))
		return "Station unavailable."
	if(!buyer_faction)
		return null
	var/datum/trade_faction/station_faction = GetFaction(target_station.faction)
	if(istype(station_faction) && (buyer_faction in station_faction.embargo))
		return "Economic embargo in effect. Trading denied."
	if(length(target_station.whitelist_factions) && !(buyer_faction in target_station.whitelist_factions))
		return "This station trades only with approved factions."
	if(length(target_station.blacklist_factions) && (buyer_faction in target_station.blacklist_factions))
		return "This station refuses trade with your faction."
	return null

/datum/controller/subsystem/supply/proc/CollectSpawnAlways()
	var/list/result = list()
	for(var/path in (typesof(/datum/trading_station) - /datum/trading_station))
		var/datum/trading_station/dummy = path
		if(initial(dummy.spawn_always))
			result += path
	return result

/datum/controller/subsystem/supply/proc/CollectTradeStations()
	var/list/result = list()
	for(var/path in (typesof(/datum/trading_station) - /datum/trading_station))
		var/datum/trading_station/dummy = path
		if(initial(dummy.spawn_always) || !initial(dummy.spawn_probability))
			continue
		result[path] = initial(dummy.spawn_probability)
	return result

/datum/controller/subsystem/supply/proc/GetBasicImportCost(good_ref, datum/trading_station/station, category_name = null)
	var/datum/trade_offer/offer = null
	if(istype(station))
		offer = station.GetOffer(good_ref)
		if(!offer && istext(category_name) && islist(station.offers_by_category[category_name]))
			var/list/cat = station.offers_by_category[category_name]
			if(isnum(good_ref) && good_ref >= 1 && good_ref <= length(cat))
				offer = cat[cat[good_ref]]
	if(istype(offer))
		if(offer.has_custom_price)
			return offer.base_price
		var/markup = (istype(station) && isnum(station.markup)) ? station.markup : 1.0
		return max(1, round(offer.base_price * markup))

	. = station ? station.GetGoodPrice(good_ref, category_name) : 0
	var/markup = (istype(station) && isnum(station.markup)) ? station.markup : 1.0
	if(!.)
		var/item_path = null
		if(istype(station))
			item_path = station.GetGoodPath(category_name, good_ref)
		else if(ispath(good_ref, /atom/movable))
			item_path = good_ref
		if(item_path)
			. = get_value(item_path) * markup
	else
		. *= markup
	if(!. || !isnum(.))
		. = 1
	. = max(1, round(.))

/datum/controller/subsystem/supply/proc/GetStationTradeBasePrice(good_ref, datum/trading_station/station, buyer_faction = null, category_name = null)
	. = GetBasicImportCost(good_ref, station, category_name)
	if(!. || !buyer_faction || !istype(station))
		return
	var/buyer_name = buyer_faction
	if(istype(buyer_name, /datum/trade_faction))
		var/datum/trade_faction/F = buyer_name
		buyer_name = F.name
	var/datum/trade_faction/seller = GetFaction(station.faction)
	if(!istype(seller) || !istext(buyer_name))
		return
	switch(seller.relationship[buyer_name])
		if(FACTION_STATE_ANIMOSITY)
			. *= 1.25
		if(FACTION_STATE_RIVAL)
			. *= 1.5
		if(FACTION_STATE_ENEMY)
			. *= 2
		if(FACTION_STATE_WAR)
			. *= 3
	if(buyer_name in seller.trade_markup)
		. *= seller.trade_markup[buyer_name]
	. = max(1, round(.))

/datum/controller/subsystem/supply/proc/GetImportCost(good_ref, datum/trading_station/station, buyer_faction = null, category_name = null)
	return GetStationBuyPrice(good_ref, station, buyer_faction, category_name)

/datum/controller/subsystem/supply/proc/ExtractCartItems(list/shop_list)
	var/list/items = list()
	if(!islist(shop_list))
		return items
	var/list/merged_by_key = list()
	for(var/station_key in shop_list)
		var/datum/trading_station/station = ResolveStation(station_key)
		if(!istype(station))
			return list()
		var/list/sub = shop_list[station_key]
		if(!islist(sub))
			return list()
		for(var/key in sub)
			var/val = sub[key]
			if(isnum(val))
				if(!is_valid_cargo_quantity(val))
					return list()
				var/datum/trade_offer/offer = station.GetOffer(key)
				var/cat = offer ? offer.category : null
				var/merge_key = "[station.uid]_[key]"
				if(merged_by_key[merge_key])
					var/list/existing = merged_by_key[merge_key]
					existing["count"] += round(val)
					if(existing["count"] > 1000)
						return list()
				else
					var/list/entry = list("station" = station, "good_id" = key, "cat" = cat, "count" = round(val), "offer" = offer)
					merged_by_key[merge_key] = entry
					items += list(entry)
			else if(islist(val))
				for(var/good_id in val)
					var/cnt = val[good_id]
					if(!isnum(cnt) || !is_valid_cargo_quantity(cnt))
						return list()
					var/datum/trade_offer/offer = station.GetOffer(good_id)
					var/merge_key = "[station.uid]_[good_id]"
					if(merged_by_key[merge_key])
						var/list/existing = merged_by_key[merge_key]
						existing["count"] += round(cnt)
						if(existing["count"] > 1000)
							return list()
					else
						var/list/entry = list("station" = station, "good_id" = good_id, "cat" = key, "count" = round(cnt), "offer" = offer)
						merged_by_key[merge_key] = entry
						items += list(entry)
			else
				return list()
	return items

/datum/controller/subsystem/supply/proc/CollectCountsFrom(list/shop_list)
	. = 0
	if(!islist(shop_list))
		return
	for(var/list/item as anything in ExtractCartItems(shop_list))
		. += item["count"]

/datum/controller/subsystem/supply/proc/CollectPriceForCategory(list/category, datum/trading_station/station, buyer_faction = null, category_name = null)
	. = 0
	if(!islist(category) || !istype(station) || !istext(category_name))
		return
	for(var/good_id in category)
		. += GetImportCost(good_id, station, buyer_faction, category_name) * category[good_id]

/datum/controller/subsystem/supply/proc/CollectPriceForList(list/shop_list, buyer_faction = null)
	. = 0
	if(!islist(shop_list))
		return
	for(var/list/item as anything in ExtractCartItems(shop_list))
		var/datum/trading_station/station = item["station"]
		var/gid = item["good_id"]
		var/cat = item["cat"]
		var/count = item["count"]
		. += GetImportCost(gid, station, buyer_faction, cat) * count

/datum/controller/subsystem/supply/proc/ClearShopList(list/target_list)
	if(!islist(target_list))
		return
	for(var/station_key in target_list)
		var/list/sub = target_list[station_key]
		if(islist(sub))
			for(var/entry in sub)
				var/list/inner = sub[entry]
				if(islist(inner))
					inner.Cut()
			sub.Cut()
	target_list.Cut()

/datum/controller/subsystem/supply/proc/ClearMarketSnapshot(list/snapshot)
	if(!islist(snapshot))
		return
	for(var/datum/trading_station/station as anything in snapshot)
		var/list/station_snap = snapshot[station]
		if(islist(station_snap))
			for(var/category_name in station_snap)
				var/list/category_snap = station_snap[category_name]
				if(islist(category_snap))
					for(var/good_id in category_snap)
						var/list/good_snap = category_snap[good_id]
						if(islist(good_snap))
							good_snap.Cut()
					category_snap.Cut()
			station_snap.Cut()
	snapshot.Cut()

/datum/controller/subsystem/supply/proc/DismantleOrder(order_id)
	if(!order_id || !(order_id in order_queue))
		return FALSE
	var/list/order = order_queue[order_id]
	if(islist(order) && (order["processing"] || order["status"] == "processing"))
		return FALSE
	order_queue.Remove(order_id)
	if(islist(order))
		order["requesting_acct"] = null
		if(islist(order["contents"]))
			ClearShopList(order["contents"])
			order["contents"] = null
		if(islist(order["price_snapshot"]))
			ClearMarketSnapshot(order["price_snapshot"])
			order["price_snapshot"] = null
		order.Cut()
	return TRUE

/datum/controller/subsystem/supply/proc/PurgeStationFromOrders(datum/trading_station/station)
	if(!istype(station))
		return
	var/st_uid = station.uid
	for(var/order_id as anything in order_queue.Copy())
		var/list/order = order_queue[order_id]
		if(!islist(order))
			order_queue.Remove(order_id)
			continue
		var/list/contents = order["contents"]
		var/changed = FALSE
		if(islist(contents))
			var/list/station_keys = list()
			if(station in contents)
				station_keys += station
			if(st_uid && (st_uid in contents))
				station_keys += st_uid
			for(var/station_key in station_keys)
				var/list/station_cart = contents[station_key]
				if(islist(station_cart))
					for(var/entry in station_cart)
						var/list/inner = station_cart[entry]
						if(islist(inner))
							inner.Cut()
					station_cart.Cut()
				contents -= station_key
				changed = TRUE
		var/list/price_snapshot = order["price_snapshot"]
		if(islist(price_snapshot))
			var/list/snap_keys = list()
			if(station in price_snapshot)
				snap_keys += station
			if(st_uid && (st_uid in price_snapshot))
				snap_keys += st_uid
			for(var/snap_key in snap_keys)
				var/list/station_snap = price_snapshot[snap_key]
				if(islist(station_snap))
					for(var/cat in station_snap)
						var/list/cat_snap = station_snap[cat]
						if(islist(cat_snap))
							for(var/gid in cat_snap)
								var/list/gsnap = cat_snap[gid]
								if(islist(gsnap))
									gsnap.Cut()
							cat_snap.Cut()
					station_snap.Cut()
				price_snapshot -= snap_key
				changed = TRUE
		if(changed)
			if(CollectCountsFrom(contents) <= 0)
				DismantleOrder(order_id)
			else
				var/new_cost = GetSnapshotTotalCost(order["price_snapshot"], contents, order["buyer_faction"])
				order["cost"] = new_cost
				var/datum/money_account/master_account = get_supply_department_account()
				var/is_master = master_account && (order["requesting_acct"] == master_account)
				order["fee"] = is_master ? 0 : round(new_cost * handling_fee, 0.01)
				order["viewable_contents"] = BuildOrderViewableContents(contents)

/datum/controller/subsystem/supply/proc/BuildOrderViewableContents(list/shopping_list)
	. = ""
	for(var/list/item_data as anything in ExtractCartItems(shopping_list))
		var/datum/trading_station/station = item_data["station"]
		var/item_name = station.GetGoodName(item_data["cat"], item_data["good_id"])
		. += "<li>[item_data["count"]]x [item_name]</li>"

/datum/controller/subsystem/supply/proc/BuildOrder(requesting_account, reason, list/shopping_list, buyer_faction = null)
	if(!requesting_account || !islist(shopping_list) || !length(shopping_list) || CollectCountsFrom(shopping_list) <= 0)
		return null

	var/cost = CollectPriceForList(shopping_list, buyer_faction)
	var/datum/money_account/master_account = get_supply_department_account()
	var/is_requestor_master = master_account && requesting_account == master_account

	var/order_queue_slot = "order_[++order_queue_id]"
	order_queue[order_queue_slot] = list(
		"requesting_acct" = requesting_account,
		"reason" = reason,
		"cost" = cost,
		"fee" = is_requestor_master ? 0 : round(cost * handling_fee, 0.01),
		"contents" = shopping_list,
		"buyer_faction" = buyer_faction || FACTION_INDEPENDENT,
		"viewable_contents" = BuildOrderViewableContents(shopping_list),
		"status" = "pending",
		"processing" = FALSE
	)
	return order_queue_slot

/datum/controller/subsystem/supply/proc/RefundEscrowOrder(list/order, datum/money_account/master_account, datum/money_account/requesting_account, transferred, total_cost)
	if(transferred && istype(master_account) && istype(requesting_account))
		master_account.transfer(requesting_account, total_cost, "Trade Network Order Refund")
	if(islist(order))
		order["processing"] = FALSE
		order["status"] = "pending"

/datum/controller/subsystem/supply/proc/CompleteOrder(order_id)
	if(!order_id || !(order_id in order_queue))
		return FALSE
	var/list/order = order_queue[order_id]
	order_queue.Remove(order_id)
	if(islist(order))
		order["processing"] = FALSE
		order["status"] = "completed"
		order["requesting_acct"] = null
		if(islist(order["contents"]))
			ClearShopList(order["contents"])
			order["contents"] = null
		if(islist(order["price_snapshot"]))
			ClearMarketSnapshot(order["price_snapshot"])
			order["price_snapshot"] = null
		order.Cut()
	return TRUE

/datum/controller/subsystem/supply/proc/PurchaseOrder(obj/machinery/trade_beacon/receiving/beacon, order_id)
	if(QDELETED(beacon) || !istype(beacon) || !beacon.operable() || !order_id || !(order_id in order_queue))
		return FALSE

	var/list/order = order_queue[order_id]
	if(!islist(order) || order["processing"] || order["status"] == "processing")
		return FALSE

	var/datum/money_account/master_account = get_supply_department_account()
	var/datum/money_account/requesting_account = order["requesting_acct"]
	if(!master_account || !requesting_account || master_account.suspended || requesting_account.suspended)
		return FALSE

	var/base_cost = order["cost"]
	var/total_cost = base_cost + order["fee"]
	var/is_requestor_master = (master_account == requesting_account)
	if((!is_requestor_master && requesting_account.money < total_cost) || (is_requestor_master && master_account.money < base_cost))
		return FALSE

	order["processing"] = TRUE
	order["status"] = "processing"
	var/transferred = !is_requestor_master && requesting_account.transfer(master_account, total_cost, "Trade Network Order (Escrow)")
	if(!is_requestor_master && !transferred)
		RefundEscrowOrder(order, master_account, requesting_account, FALSE, total_cost)
		return FALSE

	var/list/shopping_list = order["contents"]
	var/buyer_faction = order["buyer_faction"]
	var/list/price_snapshot = order["price_snapshot"]
	if(!Buy(beacon, master_account, shopping_list, !is_requestor_master, requesting_account.owner_name, buyer_faction, price_snapshot, !is_requestor_master, is_requestor_master ? null : base_cost))
		RefundEscrowOrder(order, master_account, requesting_account, transferred, total_cost)
		return FALSE

	CreateLogEntry("Order", requesting_account.owner_name, order["viewable_contents"], total_cost)
	CompleteOrder(order_id)
	return TRUE

/datum/controller/subsystem/supply/proc/ResolveCartOffer(datum/trading_station/station, cat, good_id)
	if(!istype(station))
		return null
	var/datum/trade_offer/offer = station.GetOffer(good_id)
	if(!istype(offer))
		return null
	if(cat && offer.category != cat)
		return null
	if(offer.hidden && !station.hidden_inv_unlocked)
		return null
	return offer

/datum/controller/subsystem/supply/proc/ValidateCartItems(obj/machinery/trade_beacon/receiving/beacon, list/items, buyer_faction, list/price_snapshot)
	var/total_price = 0
	var/packable = 0
	for(var/list/data as anything in items)
		var/datum/trading_station/station = data["station"]
		if(!istype(station) || GetTradeRangeBlockReason(beacon, station))
			return null
		if(GetStationFactionBlockReason(station, buyer_faction))
			return null
		var/datum/trade_offer/offer = data["offer"] || ResolveCartOffer(station, data["cat"], data["good_id"])
		if(!istype(offer))
			return null
		if(offer.hidden && !station.hidden_inv_unlocked)
			return null
		if(data["cat"] && offer.category != data["cat"])
			return null
		if(offer.stock < data["count"])
			return null
		var/good_path = offer.item_path
		if(!good_path)
			return null
		var/gid = offer.id
		var/price = islist(price_snapshot) ? GetSnapshotUnitPrice(price_snapshot, station, data["cat"], gid) : GetImportCost(gid, station, buyer_faction, data["cat"])
		if(!isnum(price) || price < 1)
			return null
		total_price += price * data["count"]
		if(CanPackPurchase(good_path))
			packable += data["count"]
	return list("price" = total_price, "packable" = packable)

/datum/controller/subsystem/supply/proc/CreateOrderLocker(obj/machinery/trade_beacon/receiving/beacon, is_order, buyer_name)
	var/obj/structure/closet/crate/trade/locker = beacon.DropItem(/obj/structure/closet/crate/trade)
	if(locker && is_order)
		locker.locked = TRUE
		locker.registered_name = buyer_name
		locker.name = "[initial(locker.name)] ([locker.registered_name])"
		locker.update_icon()
	return locker

/datum/controller/subsystem/supply/proc/CanPackPurchase(path, remaining_capacity = null)
	if(!ispath(path, /obj/item))
		return FALSE
	var/obj/item/item_type = path
	var/obj/structure/closet/crate/crate_type = /obj/structure/closet/crate
	var/capacity = isnull(remaining_capacity) ? initial(crate_type.storage_capacity) : remaining_capacity
	return initial(item_type.w_class) < ITEM_SIZE_NO_CONTAINER && initial(item_type.w_class) / 2 <= capacity

/datum/controller/subsystem/supply/proc/SpawnPurchasedItems(obj/machinery/trade_beacon/receiving/beacon, list/cart_items, obj/structure/closet/locker)
	var/list/spawned = list()
	var/remaining_capacity = locker ? locker.storage_capacity : 0
	if(locker)
		spawned += locker
	for(var/list/data as anything in cart_items)
		var/datum/trading_station/station = data["station"]
		var/datum/trade_offer/offer = data["offer"] || ResolveCartOffer(station, data["cat"], data["good_id"])
		var/path = offer ? offer.item_path : station.GetGoodPath(data["cat"], data["good_id"])
		for(var/i in 1 to data["count"])
			if(locker && CanPackPurchase(path, remaining_capacity))
				var/obj/item/item = new path(locker)
				remaining_capacity -= locker.content_size(item)
			else
				var/atom/movable/item = beacon.DropItem(path)
				if(!item)
					for(var/atom/movable/spawned_item as anything in spawned)
						qdel(spawned_item)
					if(locker)
						qdel(locker)
					return null
				spawned += item
	return spawned

/datum/controller/subsystem/supply/proc/FulfillCartStock(list/cart_items, buyer_faction, list/price_snapshot)
	var/list/wealth_by_station = list()
	var/contents_info = ""
	for(var/list/data as anything in cart_items)
		var/datum/trading_station/station = data["station"]
		var/datum/trade_offer/offer = data["offer"] || ResolveCartOffer(station, data["cat"], data["good_id"])
		var/gid = offer ? offer.id : data["good_id"]
		var/count = data["count"]
		var/price = islist(price_snapshot) ? GetSnapshotUnitPrice(price_snapshot, station, data["cat"], gid) : GetImportCost(gid, station, buyer_faction, data["cat"])
		wealth_by_station[station] += price * count
		if(offer)
			offer.ConsumeStock(count)
		else
			station.SetGoodAmount(data["cat"], gid, max(0, station.GetGoodAmount(data["cat"], gid) - count))
		var/item_name = offer ? offer.name : station.GetGoodName(data["cat"], gid)
		contents_info += "<li>[count]x [item_name]</li>"
	for(var/datum/trading_station/station as anything in wealth_by_station)
		station.AddToWealth(wealth_by_station[station])
	return contents_info

/datum/controller/subsystem/supply/proc/ChargeBuyerAccount(datum/money_account/account, price, is_escrow)
	if(!price)
		return TRUE
	if(is_escrow)
		if(!account.withdraw(price, "Trade Network Purchase", "Trade Network"))
			account.money -= price
		return TRUE
	if(account.money < price || !account.withdraw(price, "Trade Network Purchase", "Trade Network"))
		return FALSE
	return TRUE

/datum/controller/subsystem/supply/proc/Buy(obj/machinery/trade_beacon/receiving/receiver_beacon, datum/money_account/account, list/shop_list, is_order = FALSE, buyer_name = null, buyer_faction = null, list/price_snapshot = null, is_escrow = FALSE, order_cost = null)
	if(QDELETED(receiver_beacon) || !istype(receiver_beacon) || !receiver_beacon.operable() || !account || !islist(shop_list) || !length(shop_list))
		return FALSE
	var/list/cart_items = ExtractCartItems(shop_list)
	if(!length(cart_items))
		return FALSE
	var/list/check = ValidateCartItems(receiver_beacon, cart_items, buyer_faction, price_snapshot)
	if(!check)
		return FALSE
	var/price = (isnum(order_cost) && order_cost > 0) ? order_cost : check["price"]
	if(!is_escrow && account.money < price)
		return FALSE
	var/obj/structure/closet/locker = (check["packable"] > 1) ? CreateOrderLocker(receiver_beacon, is_order, buyer_name) : null
	if(check["packable"] > 1 && !locker)
		return FALSE
	var/list/spawned = SpawnPurchasedItems(receiver_beacon, cart_items, locker)
	if(!spawned)
		return FALSE
	if(!ChargeBuyerAccount(account, price, is_escrow))
		if(locker)
			qdel(locker)
		for(var/atom/movable/spawned_item in spawned)
			qdel(spawned_item)
		return FALSE
	var/info = FulfillCartStock(cart_items, buyer_faction, price_snapshot)
	var/atom/invoice_loc = locker || (length(spawned) ? get_turf(spawned[1]) : null)
	CreateLogEntry("Shipping", is_order && buyer_name ? buyer_name : account.owner_name, info, price, TRUE, invoice_loc)
	TrackLiveMarketSales(shop_list)
	return TRUE

/datum/controller/subsystem/supply/proc/FindRnDInvoice(atom/movable/container)
	if(!istype(container))
		return null
	for(var/atom/movable/item as anything in GetExportTree(container))
		if(!istype(item, /obj/item/paper/manifest/rnd_invoice))
			continue
		var/obj/item/paper/manifest/rnd_invoice/invoice = item
		if(!invoice.is_copy && LAZYLEN(invoice.stamped) && invoice.target_account_number)
			return invoice
	return null

/datum/controller/subsystem/supply/proc/GetExportTree(atom/movable/root)
	var/list/ordered = list()
	var/list/seen = list()
	var/list/pending = list(root)
	var/index = 1
	while(index <= length(pending))
		var/atom/movable/item = pending[index++]
		if(!istype(item) || QDELETED(item) || seen[item])
			continue
		seen[item] = TRUE
		ordered += item
		for(var/atom/movable/child as anything in item.contents)
			if(!seen[child])
				pending += child
	return ordered

/datum/controller/subsystem/supply/proc/GetExportItemQuote(atom/movable/item, datum/trading_station/station, seller_faction, find_manifest, list/sold_counts, list/seen_strains)
	var/special_item = istype(item, /obj/item/virusdish) || istype(item, /obj/item/paper) || istype(item, /obj/item/disk/research_report) || istype(item, /obj/item/artefact) || istype(item, /obj/item/collector) || istype(item, /obj/item/disk/survey)
	var/list/match = special_item ? null : FindCommodityForExport(item, station)
	if(istype(item, /obj/machinery/portable_atmospherics/canister) && !istype(item, /obj/machinery/portable_atmospherics/canister/empty))
		var/obj/machinery/portable_atmospherics/canister/canister = item
		if(canister.return_pressure() < 10 * ONE_ATMOSPHERE)
			var/empty_price = round(get_value(canister))
			if(islist(match))
				var/good_id = match["good_id"]
				var/amount = match["amount"]
				var/offset = sold_counts[good_id] || 0
				var/full_price = GetStationSellPrice(good_id, station, seller_faction, match["category"], amount, offset)
				empty_price = min(empty_price, max(0, full_price - 1))
			return list("price" = empty_price, "match" = null, "amount" = 1)
	if(islist(match))
		var/good_id = match["good_id"]
		var/amount = match["amount"]
		if(!isnum(amount) || amount <= 0)
			amount = 1
		var/offset = sold_counts[good_id] || 0
		return list("price" = GetStationSellPrice(good_id, station, seller_faction, match["category"], amount, offset), "match" = match, "amount" = amount)
	var/price = 0
	if(istype(item, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/crate = item
		price = initial(crate.points_per_crate) * CARGO_POINT_TO_THALLER
	else
		price = GetCrateItemLegacyValue(item, find_manifest, seen_strains)
	return list("price" = round(price, 0.01), "match" = null, "amount" = isstack(item) ? GetExportStackAmount(item) : 1)

/datum/controller/subsystem/supply/proc/BuildExportPlan(list/roots, datum/trading_station/station = null, seller_faction = null, budget = INFINITY, list/rejected = null, list/sold_counts = null, list/seen_strains = null)
	var/list/entries = list()
	var/list/visited = list()
	var/list/counts = islist(sold_counts) ? sold_counts : list()
	var/list/strains = islist(seen_strains) ? seen_strains : list()
	var/total = 0
	var/budget_limited = FALSE
	if(istype(station) && seller_faction && GetStationTradeRelationMultiplier(station, seller_faction) <= 0)
		return list("entries" = entries, "total" = 0, "budget_limited" = FALSE)
	for(var/atom/movable/root as anything in roots)
		if(visited[root])
			continue
		if(istype(root, /obj/structure/closet/crate/trade_contract))
			continue
		if(!CanExportAtom(root))
			if(islist(rejected))
				rejected += root
			continue
		var/find_manifest = istype(root, /obj/structure/closet)
		for(var/atom/movable/item as anything in GetExportTree(root))
			if(visited[item] || QDELETED(item))
				continue
			visited[item] = TRUE
			var/list/trial_counts = counts.Copy()
			var/list/trial_strains = strains.Copy()
			var/list/quote = GetExportItemQuote(item, station, seller_faction, find_manifest, trial_counts, trial_strains)
			var/price = quote["price"]
			var/sell = price > 0 && price <= budget - total
			if(price > budget - total)
				budget_limited = TRUE
			if(sell)
				var/list/match = quote["match"]
				if(islist(match))
					var/good_id = match["good_id"]
					counts[good_id] = (counts[good_id] || 0) + quote["amount"]
				strains = trial_strains
				if(find_manifest && istype(item, /obj/item/paper/manifest) && !istype(item, /obj/item/paper/manifest/rnd_invoice))
					find_manifest = FALSE
				total += price
			entries.Add(list(list("item" = item, "root" = root, "sell" = sell, "price" = price, "match" = quote["match"], "amount" = quote["amount"])))
	if(islist(seen_strains))
		seen_strains |= strains
	return list("entries" = entries, "total" = round(total, 0.01), "budget_limited" = budget_limited)

/datum/controller/subsystem/supply/proc/Export(obj/machinery/trade_beacon/sending/sender_beacon, datum/money_account/money_account, datum/trading_station/target_station = null, seller_faction = null)
	if(QDELETED(sender_beacon) || !istype(money_account) || money_account.suspended || !sender_beacon.CanExport())
		return FALSE
	if(istype(target_station) && (target_station.wealth <= 0 || GetTradeRangeBlockReason(sender_beacon, target_station) || (seller_faction && GetStationTradeRelationMultiplier(target_station, seller_faction) <= 0)))
		return FALSE
	var/list/rejected = list()
	var/list/roots = GetExportCandidates(sender_beacon, rejected)
	if(!length(roots))
		return FALSE
	var/list/plan = BuildExportPlan(roots, target_station, seller_faction, istype(target_station) ? target_station.wealth : INFINITY, rejected)
	if(plan["total"] <= 0)
		return FALSE
	var/list/payouts_by_account = list()
	var/list/root_accounts = list()
	var/list/invoices = list()
	var/list/plan_entries = plan["entries"]
	for(var/list/entry as anything in plan_entries)
		if(!entry["sell"])
			continue
		var/atom/movable/root = entry["root"]
		var/datum/money_account/payee = root_accounts[root]
		if(!payee)
			payee = money_account
			if(istype(root, /obj/structure/closet))
				var/obj/item/paper/manifest/rnd_invoice/slip = FindRnDInvoice(root)
				if(slip)
					invoices += slip
					payee = get_account(slip.target_account_number)
					if(!istype(payee) || payee.suspended)
						return FALSE
			root_accounts[root] = payee
		entry["account"] = payee
		payouts_by_account[payee] += entry["price"]
	plan["payouts"] = payouts_by_account
	plan["invoices"] = invoices
	if(!DepositExportPayouts(sender_beacon, money_account, payouts_by_account))
		return FALSE
	for(var/atom/movable/rejected_atom as anything in rejected)
		HandleRejectedExport(rejected_atom)
	if(istype(target_station))
		target_station.SubtractFromWealth(plan["total"])
	RecordExportPlan(sender_beacon, money_account, target_station, seller_faction, plan)
	return plan["budget_limited"] ? TRADE_EXPORT_PARTIAL : TRADE_EXPORT_SUCCESS

/datum/controller/subsystem/supply/proc/GetExportCandidates(obj/machinery/trade_beacon/sending/sender_beacon, list/rejected)
	var/list/candidates = list()
	for(var/atom/movable/exported as anything in sender_beacon.GetObjects())
		if(istype(exported, /obj/structure/closet/crate/trade_contract))
			continue
		if(!CanExportAtom(exported))
			rejected += exported
			continue
		candidates += exported
	return candidates

/datum/controller/subsystem/supply/proc/DepositExportPayouts(obj/machinery/trade_beacon/sending/sender_beacon, datum/money_account/money_account, list/payouts_by_account)
	var/list/successful_deposits = list()
	var/deposit_failed = FALSE
	for(var/datum/money_account/account as anything in payouts_by_account)
		var/amount = payouts_by_account[account]
		if(amount <= 0)
			continue
		var/description = (account == money_account) ? "Trade Network Export" : "R&D Invoice sale"
		if(!account.deposit(amount, description, "Trade Network"))
			deposit_failed = TRUE
			break
		successful_deposits += list(list(account, amount))

	if(!deposit_failed && sender_beacon.StartExport())
		return TRUE
	for(var/list/deposit in successful_deposits)
		var/datum/money_account/account = deposit[1]
		var/amount = deposit[2]
		account.withdraw(amount, "Export Transaction Rollback", "Trade Network")
	return FALSE

/datum/controller/subsystem/supply/proc/RecordExportPlan(obj/machinery/trade_beacon/sending/sender_beacon, datum/money_account/money_account, datum/trading_station/target_station, seller_faction, list/plan)
	var/list/items_by_account = list()
	var/list/entries = plan["entries"]
	for(var/list/entry as anything in entries)
		if(!entry["sell"])
			continue
		var/datum/money_account/payee = entry["account"] || money_account
		var/atom/movable/logged_item = entry["item"]
		items_by_account[payee] = "[items_by_account[payee] || ""]<li>[logged_item.name]</li>"
	var/list/invoices = plan["invoices"]
	for(var/obj/item/paper/manifest/rnd_invoice/slip as anything in invoices)
		qdel(slip)
	for(var/i = length(entries) to 1 step -1)
		var/list/entry = entries[i]
		if(!entry["sell"])
			continue
		var/atom/movable/item = entry["item"]
		if(QDELETED(item))
			continue
		var/list/match = entry["match"]
		if(islist(match))
			ApplyTradeTransaction(target_station, match["category"], match["good_id"], entry["amount"], "sell", seller_faction)
		if(istype(item, /obj/item/virusdish))
			var/obj/item/virusdish/dish = item
			if(dish.analysed && istype(dish.virus2) && dish.virus2.uniqueID)
				sold_virus_strains += dish.virus2.uniqueID
		if(istype(item, /obj/item/artefact))
			var/obj/item/artefact/artefact = item
			if(SSanom)
				SSanom.earned_cargo_points += artefact.cargo_price
		else if(istype(item, /obj/item/collector))
			var/obj/item/collector/collector = item
			if(SSanom && collector.stored_artefact)
				SSanom.earned_cargo_points += collector.stored_artefact.cargo_price
		var/turf/floor = get_turf(item)
		if(floor)
			for(var/atom/movable/child as anything in item.contents)
				child.forceMove(floor)
		qdel(item)
	for(var/datum/money_account/payee as anything in items_by_account)
		var/list/payouts = plan["payouts"]
		CreateLogEntry("Export", payee.owner_name, items_by_account[payee], payouts[payee], TRUE, get_turf(sender_beacon), seller_faction, target_station ? target_station.name : null)

/datum/controller/subsystem/supply/proc/CreateLogEntry(type, ordering_account, contents, total_paid, create_invoice = FALSE, invoice_location = null, faction_name = null, station_name = null)
	var/log_id
	var/list/log_entry = list(
		"id" = null,
		"ordering_acct" = ordering_account,
		"contents" = contents,
		"total_paid" = total_paid,
		"time" = time2text(world.time, "hh:mm"),
		"faction" = faction_name,
		"station" = station_name
	)

	switch(type)
		if("Shipping")
			log_id = "[++shipping_invoice_number]-S"
			log_entry["id"] = log_id
			shipping_log += list(log_entry)
			if(length(shipping_log) > MAX_SUPPLY_LOG_ENTRIES)
				shipping_log.Cut(1, 2)
		if("Export")
			log_id = "[++export_invoice_number]-E"
			log_entry["id"] = log_id
			export_log += list(log_entry)
			if(length(export_log) > MAX_SUPPLY_LOG_ENTRIES)
				export_log.Cut(1, 2)
		if("Order")
			log_id = "[++order_number]-O"
			log_entry["id"] = log_id
			order_log += list(log_entry)
			if(length(order_log) > MAX_SUPPLY_LOG_ENTRIES)
				order_log.Cut(1, 2)
		if("Contract")
			log_id = "[++contract_number]-C"
			log_entry["id"] = log_id
			contract_log += list(log_entry)
			if(length(contract_log) > MAX_SUPPLY_LOG_ENTRIES)
				contract_log.Cut(1, 2)
		else
			return

	if(create_invoice && invoice_location && log_id)
		PrintInvoice(type, log_id, ordering_account, contents, total_paid, FALSE, invoice_location, faction_name, station_name)
		if(type == "Shipping")
			PrintInvoice(type, log_id, ordering_account, contents, total_paid, TRUE, invoice_location, faction_name, station_name)

/datum/controller/subsystem/supply/proc/PrintInvoice(type, log_id, ordering_account, contents, total_paid, is_internal = FALSE, location, faction_name = null, station_name = null)
	if(!location)
		return
	var/title = "[lowertext(type)] invoice - #[log_id]"
	if(is_internal)
		title += " (internal)"
	var/text = ""
	text += "<h3>[type] Invoice - #[log_id]</h3><hr><font size='2'>"
	if(is_internal)
		text += "FOR INTERNAL USE ONLY<br><br>"
	text += "Recipient: [ordering_account]<br>"
	if(faction_name)
		text += "Faction: [faction_name]<br>"
	if(station_name)
		text += "Trading Partner: [station_name]<br>"
	text += "Contents:<ul>[contents]</ul>"
	text += "Total Credits Paid: [total_paid]<br>"
	text += "</font>"
	new /obj/item/paper(location, text, title)

/datum/controller/subsystem/supply/proc/GetLogDataById(log_id)
	var/list/target_log
	var/list/id_data = splittext(log_id, "-")
	if(length(id_data) < 2)
		return null
	switch(uppertext(id_data[2]))
		if("S")
			target_log = shipping_log
		if("E")
			target_log = export_log
		if("O")
			target_log = order_log
		if("C")
			target_log = contract_log
		else
			return null

	for(var/list/entry in target_log)
		if(entry["id"] == log_id)
			return entry
	return null

/datum/controller/subsystem/supply/proc/HasLivingOccupants(atom/movable/exported)
	if(!istype(exported) || QDELETED(exported))
		return FALSE
	if(isliving(exported))
		return TRUE
	for(var/atom/movable/content as anything in GetExportTree(exported))
		if(isliving(content))
			return TRUE
	return FALSE

/datum/controller/subsystem/supply/proc/CanExportAtom(atom/movable/exported)
	if(!istype(exported) || QDELETED(exported))
		return FALSE
	if(HasLivingOccupants(exported))
		return FALSE
	return TRUE

/datum/controller/subsystem/supply/proc/HandleRejectedExport(atom/movable/exported)
	if(!istype(exported) || QDELETED(exported))
		return
	if(isliving(exported))
		var/mob/living/living_mob = exported
		to_chat(living_mob, SPAN_DANGER("The export beacon rejects biological matter with a painful electric shock!"))
		living_mob.apply_damage(15, DAMAGE_BURN)
		return
	for(var/atom/movable/content as anything in GetExportTree(exported))
		if(!isliving(content))
			continue
		var/mob/living/living_mob = content
		to_chat(living_mob, SPAN_DANGER("The export beacon rejects biological matter inside the container with a buzzing jolt!"))
		living_mob.apply_damage(5, DAMAGE_BURN)

/datum/controller/subsystem/supply/proc/GetCrateItemLegacyValue(atom/movable/item, find_manifest = FALSE, list/seen_strains = null)
	if(!istype(item) || QDELETED(item))
		return 0
	if(istype(item, /obj/item/paper/manifest/rnd_invoice))
		return 0
	if(istype(item, /obj/item/disk/research_report))
		var/obj/item/disk/research_report/report = item
		return max(0, report.cargo_value)
	if(istype(item, /obj/item/virusdish))
		var/obj/item/virusdish/dish = item
		if(dish.analysed && istype(dish.virus2) && dish.virus2.uniqueID)
			var/strain_id = dish.virus2.uniqueID
			if(!(strain_id in sold_virus_strains) && (!islist(seen_strains) || !(strain_id in seen_strains)))
				if(islist(seen_strains))
					seen_strains += strain_id
				return 5 * CARGO_POINT_TO_THALLER
		return 0
	if(find_manifest && istype(item, /obj/item/paper/manifest))
		var/obj/item/paper/manifest/slip = item
		if(!slip.is_copy && LAZYLEN(slip.stamped))
			return points_per_slip * CARGO_POINT_TO_THALLER
		return 0
	if(istype(item, /obj/item/paper))
		return 0
	if(istype(item, /obj/item/stack/material))
		var/obj/item/stack/material/material_stack = item
		var/val = 0
		if(material_stack.material && material_stack.material.sale_price > 0)
			val += material_stack.get_amount() * material_stack.material.sale_price * material_stack.matter_multiplier * CARGO_POINT_TO_THALLER
		if(material_stack.reinf_material && material_stack.reinf_material.sale_price > 0)
			val += material_stack.get_amount() * material_stack.reinf_material.sale_price * material_stack.matter_multiplier * 0.5 * CARGO_POINT_TO_THALLER
		return val
	if(istype(item, /obj/item/disk/survey))
		var/obj/item/disk/survey/survey_disk = item
		return round(survey_disk.Value() * 0.05) * CARGO_POINT_TO_THALLER
	if(istype(item, /obj/item/artefact))
		var/obj/item/artefact/artefact = item
		return artefact.cargo_price * CARGO_POINT_TO_THALLER
	if(istype(item, /obj/item/collector))
		var/obj/item/collector/collector = item
		if(collector.stored_artefact)
			return collector.stored_artefact.cargo_price * CARGO_POINT_TO_THALLER
		return 0
	if(istype(item, /obj/item/storage) || length(item.contents))
		return round(get_value(item.type))
	return round(get_value(item))

/datum/controller/subsystem/supply/proc/GetCrateExportBreakdown(obj/structure/closet/crate, datum/trading_station/target_station, seller_faction = null, list/sold_counts = null, list/seen_strains = null)
	if(!istype(crate))
		return list("base_value" = 0, "contents_value" = 0, "total_value" = 0, "display_name" = "Crate", "sub_items" = list())
	var/list/plan = BuildExportPlan(list(crate), target_station, seller_faction, INFINITY, null, sold_counts, seen_strains)
	var/list/sub_items = list()
	var/base_value = 0
	var/contents_value = 0
	var/list/entries = plan["entries"]
	for(var/list/entry as anything in entries)
		if(!entry["sell"])
			continue
		var/atom/movable/item = entry["item"]
		var/amount = max(1, entry["amount"])
		if(item == crate)
			base_value = entry["price"]
		else
			contents_value += entry["price"]
		sub_items.Add(list(list("name" = item == crate ? "[item.name] (packaging)" : item.name, "amount" = amount, "unit_value" = round(entry["price"] / amount, 0.01), "value" = entry["price"])))
	var/obj/item/paper/manifest/rnd_invoice/slip = FindRnDInvoice(crate)
	var/display_name = slip ? "[crate.name] (R&D #[slip.target_account_number])" : crate.name
	return list("base_value" = base_value, "contents_value" = contents_value, "total_value" = plan["total"], "display_name" = display_name, "sub_items" = sub_items)

/datum/controller/subsystem/supply/proc/GetStationCrateExportValue(obj/structure/closet/crate/crate, datum/trading_station/target_station, seller_faction = null, list/sold_counts = null)
	if(!istype(crate) || !istype(target_station))
		return 0
	var/list/breakdown = GetCrateExportBreakdown(crate, target_station, seller_faction, sold_counts)
	return breakdown["contents_value"]

/datum/controller/subsystem/supply/proc/GetExportValue(atom/movable/exported, datum/trading_station/target_station = null, seller_faction = null, list/sold_counts = null, list/seen_strains = null)
	var/list/plan = BuildExportPlan(list(exported), target_station, seller_faction, INFINITY, null, sold_counts, seen_strains)
	return plan["total"]
