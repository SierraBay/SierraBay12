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
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.status == CONTRACT_STATUS_COMPLETED || contract.status == CONTRACT_STATUS_FAILED)
			resolved_count++
	while(resolved_count > max_resolved_trade_contracts)
		var/datum/trade_contract/oldest_resolved = null
		for(var/datum/trade_contract/contract as anything in trade_contracts)
			if(contract.status == CONTRACT_STATUS_COMPLETED || contract.status == CONTRACT_STATUS_FAILED)
				if(contract.HasPendingRefund() || contract.HasPendingPayout())
					continue
				if(!oldest_resolved || contract.resolved_at < oldest_resolved.resolved_at)
					oldest_resolved = contract
		if(!oldest_resolved)
			break
		trade_contracts -= oldest_resolved
		qdel(oldest_resolved)
		resolved_count--

/datum/controller/subsystem/supply/proc/ProcessPendingContractRefunds()
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.HasPendingRefund())
			contract.TrySettlePendingRefund()
		if(contract.HasPendingPayout())
			contract.TrySettlePendingPayout()
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
	for(var/category_name in station.offers_by_category)
		var/list/category = station.offers_by_category[category_name]
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

	for(var/source_category_name in source_station.offers_by_category)
		var/list/source_category = source_station.offers_by_category[source_category_name]
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
	var/item_path = source_station.GetGoodPath(source_category_name, source_good_id)
	if(source_available < 1 || !ispath(item_path, /atom/movable))
		return null
	var/source_unit_cost = GetStationRestockCost(source_good_id, source_station, source_category_name)
	if(source_unit_cost < 1)
		return null

	var/source_surplus = max(0, -source_station.GetLiveMarketStockPressure(source_category_name, source_good_id))
	var/desired_amount = max(1, round(target_value / source_unit_cost))
	var/list/destination_match = FindStationCommodityByPath(destination_station, item_path)
	var/list/market = islist(destination_match) \
		? GetSharedContractMarket(destination_station, destination_match, source_unit_cost, source_available, desired_amount, source_surplus, route_distance) \
		: GetUnmatchedContractMarket(destination_station, source_good_id, source_unit_cost, source_available, desired_amount, source_surplus, route_distance, target_value)
	if(!islist(market) || market["amount"] < 1)
		return null

	var/amount = market["amount"]
	var/base_value = source_unit_cost * amount
	if(base_value < min_trade_contract_value)
		return null

	return BuildCandidatePayload(source_station, market, source_category_name, source_good_id, item_path, source_unit_cost, amount, base_value, route_distance)

/datum/controller/subsystem/supply/proc/CalculateContractReward(base_value, route_distance, destination_sell_price, source_unit_cost, amount)
	var/value_commission = round(base_value * 0.2)
	var/distance_pay = round(route_distance * 35)
	var/spread_pay = round(max(0, (destination_sell_price - source_unit_cost) * amount) * 0.5)
	return max(100, max(value_commission + distance_pay, value_commission + spread_pay))

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

/datum/controller/subsystem/supply/proc/BuildCandidatePayload(datum/trading_station/source_station, list/market, source_category_name, source_good_id, item_path, source_unit_cost, amount, base_value, route_distance)
	var/destination_sell_price = market["sell_price"]
	var/reward = CalculateContractReward(base_value, route_distance, destination_sell_price, source_unit_cost, amount)
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
		"reward" = reward,
		"deposit" = round(base_value * 0.3),
		"penalty" = round(max(base_value, destination_sell_price * amount) * 1.5),
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
