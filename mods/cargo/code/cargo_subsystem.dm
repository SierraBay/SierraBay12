// Subsystem for ship trade-network operations.
/datum/controller/subsystem/supply
	name = "Supply"
	priority = SS_PRIORITY_SUPPLY
	flags = SS_NO_FIRE

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
	var/min_trade_contract_distance = 3
	var/min_trade_contract_value = 120
	var/max_trade_contract_value = 800

/datum/controller/subsystem/supply/Initialize(start_uptime)
	. = ..()
	all_trading_stations = list()
	visible_trading_stations = list()
	hidden_trading_stations = list()
	factions = list()
	beacons_sending = list()
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
		"virology_antibodies" = "Uploaded antibody data",
		"virology_dishes" = "Exported virus dishes",
		"animal" = "Captured exotic fauna",
		"artefacts" = "Exported artefacts",
		"total" = "Total legacy income"
	)

	for(var/faction_type in (typesof(/datum/trade_faction) - /datum/trade_faction))
		var/datum/trade_faction/trade_faction = new faction_type
		factions[trade_faction.name] = trade_faction

	for(var/faction_name in factions)
		var/datum/trade_faction/first = factions[faction_name]
		for(var/other_name in factions)
			var/datum/trade_faction/second = factions[other_name]
			if(first == second)
				first.relationship[second.name] = FACTION_STATE_PROTECTORATE
				continue
			if(!(second.name in first.relationship))
				first.relationship[second.name] = FACTION_STATE_NEUTRAL
			SetFactionRelations(first, second, first.relationship[second.name])

	InitTradeStations()
	RefreshTradeBeacons()

/datum/controller/subsystem/supply/Destroy()
	DeInitTradeStations()
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
	beacons_sending = list()
	beacons_receiving = list()
	for(var/obj/machinery/machine as anything in SSmachines.get_all_machinery())
		if(QDELETED(machine))
			continue
		if(istype(machine, /obj/machinery/trade_beacon/sending))
			beacons_sending += machine
			continue
		if(istype(machine, /obj/machinery/trade_beacon/receiving))
			beacons_receiving += machine

/datum/controller/subsystem/supply/proc/SetFactionRelations(fac1, fac2, relation)
	var/datum/trade_faction/first = GetFaction(fac1)
	var/datum/trade_faction/second = GetFaction(fac2)
	if(!istype(first) || !istype(second) || first == second || isnull(relation))
		return FALSE
	first.ModifyRelationsWith(second.name, relation)
	second.ModifyRelationsWith(first.name, relation)
	return TRUE

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
		var/datum/trading_station/trading_station = pickweight(weighted_station_list)
		if(!istype(trading_station))
			break
		stations_to_init += trading_station
		trading_station.SpendTradeStationsBudget()
		weighted_station_list.Remove(trading_station)

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
	for(var/datum/trading_station/trading_station as anything in all_trading_stations)
		if(trading_station.uid == target_uid)
			return trading_station
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
		if(contract.status == "available")
			. += 1

/datum/controller/subsystem/supply/proc/GetActiveContractCount()
	. = 0
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.status == "active")
			. += 1

/datum/controller/subsystem/supply/proc/GetTradeContract(contract_id)
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.id == contract_id)
			return contract
	return null

/datum/controller/subsystem/supply/proc/GetVisibleContractBySource(source_uid)
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.status != "available" || contract.source_uid != source_uid)
			continue
		if(contract.ShouldDisplayAvailable())
			return contract
	return null

/datum/controller/subsystem/supply/proc/GetVisibleContractBySourceAndType(source_uid, contract_type)
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(contract.status != "available" || contract.source_uid != source_uid)
			continue
		if(contract.GetTypeId() != contract_type)
			continue
		if(contract.ShouldDisplayAvailable())
			return contract
	return null

/datum/controller/subsystem/supply/proc/GetPendingCaravanContract(caravan_uid)
	for(var/datum/trade_contract/contract as anything in trade_contracts)
		if(!istype(contract, /datum/trade_contract/caravan_rendezvous))
			continue
		if(contract.destination_uid != caravan_uid)
			continue
		if(contract.status == "available" || contract.status == "active")
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
			var/source_available = source_station.GetGoodAmount(source_category_name, source_good_id)
			if(source_available < 1)
				continue

			var/item_path = source_station.GetGoodPath(source_category_name, source_good_id)
			if(!ispath(item_path, /atom/movable))
				continue

			var/list/destination_match = FindStationCommodityByPath(destination_station, item_path)
			if(!islist(destination_match))
				continue

			var/destination_category_name = destination_match["category"]
			var/destination_good_id = destination_match["good_id"]
			var/source_unit_cost = GetStationRestockCost(source_good_id, source_station, source_category_name)
			var/destination_sell_snapshot = GetStationSellPrice(destination_good_id, destination_station, destination_category_name)
			if(source_unit_cost < 1 || destination_sell_snapshot < 1)
				continue

			var/destination_shortage = max(0, destination_station.GetLiveMarketStockPressure(destination_category_name, destination_good_id))
			var/destination_demand = max(0, destination_station.GetLiveMarketDemandScore(destination_category_name, destination_good_id))
			var/source_surplus = max(0, -source_station.GetLiveMarketStockPressure(source_category_name, source_good_id))
			var/spread_ratio = destination_sell_snapshot / max(1, source_unit_cost)
			if(destination_shortage < 0.2 && destination_demand < 0.25 && spread_ratio < 1.2)
				continue

			var/score = (destination_shortage * 4) + (destination_demand * 2) + (max(0, spread_ratio - 1) * 2) + source_surplus + min(route_distance / 10, 1)
			var/desired_amount = max(1, round(target_value / source_unit_cost))
			var/amount = 0
			if(destination_shortage > 0)
				var/shortage_units = max(1, GetTradeContractShortageUnits(destination_station, destination_category_name, destination_good_id))
				amount = min(source_available, desired_amount, shortage_units)
			else
				amount = min(source_available, desired_amount)
			if(amount < 1)
				continue

			var/base_value = source_unit_cost * amount
			if(base_value < min_trade_contract_value)
				continue

			var/list/candidate = list(
				"score" = score,
				"market_reason" = GetTradeContractMarketReason(destination_shortage, destination_demand, spread_ratio),
				"source_category" = source_category_name,
				"source_good_id" = source_good_id,
				"destination_category" = destination_category_name,
				"destination_good_id" = destination_good_id,
				"source_unit_cost" = source_unit_cost,
				"destination_sell_price" = destination_sell_snapshot,
				"distance" = route_distance,
				"base_value" = base_value,
				"reward" = max(base_value + round(route_distance * 40), round(base_value + max(0, (destination_sell_snapshot - source_unit_cost) * amount) * 0.8)),
				"penalty" = base_value * 2,
				"content" = list(
					"category" = source_category_name,
					"good_id" = source_good_id,
					"item_path" = item_path,
					"name" = source_station.GetGoodName(source_category_name, source_good_id),
					"amount" = amount
				)
			)
			if(!islist(best_candidate) || candidate["score"] > best_candidate["score"] || (candidate["score"] == best_candidate["score"] && candidate["base_value"] > best_candidate["base_value"]))
				best_candidate = candidate

	return best_candidate

/datum/controller/subsystem/supply/proc/CreateTradeContract(datum/trading_station/source_station)
	if(!istype(source_station) || !source_station.supports_contracts || !(source_station in visible_trading_stations) || GetVisibleContractBySourceAndType(source_station.uid, "delivery"))
		return null

	var/list/best_candidate = null
	var/datum/trading_station/destination_station = null
	for(var/datum/trading_station/candidate_destination as anything in visible_trading_stations)
		if(candidate_destination == source_station || !candidate_destination.supports_contracts)
			continue
		var/route_distance = GetTradeDistance(source_station.overmap_object, candidate_destination)
		if(!isnum(route_distance) || route_distance < min_trade_contract_distance)
			continue
		var/list/candidate = BuildTradeContractCandidate(source_station, candidate_destination, route_distance)
		if(!islist(candidate))
			continue
		if(!islist(best_candidate) || candidate["score"] > best_candidate["score"] || (candidate["score"] == best_candidate["score"] && candidate["base_value"] > best_candidate["base_value"]))
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
	contract.reward = round(base_value + (route_distance * 25))
	contract.penalty = 0
	trade_contracts += contract
	return contract

/datum/controller/subsystem/supply/proc/RefreshCaravanContracts()
	for(var/datum/trade_contract/contract as anything in trade_contracts.Copy())
		if(!istype(contract, /datum/trade_contract/caravan_rendezvous))
			continue
		if(contract.status == "available" && !contract.ShouldDisplayAvailable())
			trade_contracts -= contract
			qdel(contract)
			continue
		if(contract.status == "active" && !contract.CanStayActive())
			contract.HandleActiveTargetLoss()

/datum/controller/subsystem/supply/proc/EnsureVisibleContractOffers()
	RefreshCaravanContracts()
	for(var/datum/trading_station/source_station as anything in visible_trading_stations)
		if(!source_station.supports_contracts)
			continue
		if(GetVisibleContractBySourceAndType(source_station.uid, "delivery"))
			continue
		CreateTradeContract(source_station)
	for(var/datum/trading_station/caravan/caravan_station as anything in visible_trading_stations)
		CreateCaravanRendezvousContract(caravan_station)

/datum/controller/subsystem/supply/proc/AcceptTradeContract(obj/machinery/trade_beacon/receiving/receiver_beacon, datum/money_account/account, contract_id)
	var/datum/trade_contract/contract = GetTradeContract(contract_id)
	if(!istype(contract))
		return FALSE
	return contract.Accept(receiver_beacon, account)

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

/datum/controller/subsystem/supply/proc/GetTradeDistance(atom/source, datum/trading_station/station)
	if(!GLOB.using_map.use_overmap || !istype(station) || !station.overmap_location)
		return null
	var/obj/overmap/visitable/current_sector = GetOvermapSectorFor(source)
	if(!istype(current_sector) || current_sector.z != station.overmap_location.z)
		return null
	return get_dist(current_sector, station.overmap_location)

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
	for(var/datum/trading_station/station as anything in shop_list)
		var/block_reason = GetTradeRangeBlockReason(source, station)
		if(block_reason)
			return "[station.name]: [block_reason]"
	return null

/datum/controller/subsystem/supply/proc/CollectSpawnAlways()
	var/list/result = list()
	for(var/path in (typesof(/datum/trading_station) - /datum/trading_station))
		var/datum/trading_station/trading_station = path
		if(initial(trading_station.spawn_always))
			result += new path()
	return result

/datum/controller/subsystem/supply/proc/CollectTradeStations()
	var/list/result = list()
	for(var/path in (typesof(/datum/trading_station) - /datum/trading_station))
		var/datum/trading_station/trading_station = path
		if(initial(trading_station.spawn_always) || !initial(trading_station.spawn_probability))
			continue
		result[new path()] = initial(trading_station.spawn_probability)
	return result

/datum/controller/subsystem/supply/proc/GetBasicImportCost(good_ref, datum/trading_station/station, category_name = null)
	. = station ? station.GetGoodPrice(good_ref, category_name) : 0
	if(!.)
		var/item_path = null
		if(istype(station))
			item_path = station.GetGoodPath(category_name, good_ref)
		else if(ispath(good_ref, /atom/movable))
			item_path = good_ref
		if(item_path)
			. = get_value(item_path)
			if(istype(station))
				. *= station.markup
	if(!.)
		return 0
	. = max(1, round(.))

/datum/controller/subsystem/supply/proc/GetImportCost(good_ref, datum/trading_station/station, buyer_faction = null, category_name = null)
	. = GetBasicImportCost(good_ref, station, category_name)
	if(!. || !buyer_faction || !istype(station))
		return
	var/datum/trade_faction/buyer = GetFaction(buyer_faction)
	var/datum/trade_faction/seller = GetFaction(station.faction)
	if(!istype(buyer) || !istype(seller))
		return
	switch(seller.relationship[buyer.name])
		if(FACTION_STATE_ANIMOSITY)
			. *= 1.25
		if(FACTION_STATE_RIVAL)
			. *= 1.5
		if(FACTION_STATE_ENEMY)
			. *= 2
		if(FACTION_STATE_WAR)
			. *= 3
	if(buyer.name in seller.trade_markup)
		. *= seller.trade_markup[buyer.name]
	. = max(1, round(.))

/datum/controller/subsystem/supply/proc/CollectCountsFrom(list/shop_list)
	. = 0
	if(!islist(shop_list))
		return
	for(var/datum/trading_station/station as anything in shop_list)
		var/list/categories = shop_list[station]
		if(!islist(categories))
			continue
		for(var/category_name in categories)
			var/list/goods = categories[category_name]
			if(!islist(goods))
				continue
			for(var/good_id in goods)
				. += goods[good_id]

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
	for(var/datum/trading_station/station as anything in shop_list)
		var/list/categories = shop_list[station]
		if(!islist(categories))
			continue
		for(var/category_name in categories)
			. += CollectPriceForCategory(categories[category_name], station, buyer_faction, category_name)

/datum/controller/subsystem/supply/proc/BuildOrder(requesting_account, reason, list/shopping_list, buyer_faction = null)
	if(!requesting_account || !islist(shopping_list) || !length(shopping_list))
		return null

	var/cost = CollectPriceForList(shopping_list, buyer_faction)
	var/contents_info = ""
	var/datum/money_account/requestor = requesting_account
	var/datum/money_account/master_account = get_supply_department_account()
	var/is_requestor_master = master_account && requestor == master_account

	for(var/datum/trading_station/station as anything in shopping_list)
		var/list/categories = shopping_list[station]
		for(var/category_name in categories)
			var/list/goods = categories[category_name]
			for(var/good_id in goods)
				var/amount_to_add = goods[good_id]
				var/item_name = station.GetGoodName(category_name, good_id)
				contents_info += "<li>[amount_to_add]x [item_name]</li>"

	var/list/new_order = list(
		"requesting_acct" = requesting_account,
		"reason" = reason,
		"cost" = cost,
		"fee" = is_requestor_master ? 0 : round(cost * handling_fee),
		"contents" = shopping_list,
		"buyer_faction" = buyer_faction || FACTION_INDEPENDENT,
		"viewable_contents" = contents_info
	)

	var/order_queue_slot = "order_[++order_queue_id]"
	order_queue[order_queue_slot] = new_order
	return order_queue_slot

/datum/controller/subsystem/supply/proc/PurchaseOrder(obj/machinery/trade_beacon/receiving/beacon, order_id)
	if(QDELETED(beacon) || !order_id || !(order_id in order_queue))
		return FALSE

	var/list/order = order_queue[order_id]
	var/datum/money_account/master_account = get_supply_department_account()
	var/datum/money_account/requesting_account = order["requesting_acct"]
	var/list/shopping_list = order["contents"]
	var/list/viewable_contents = order["viewable_contents"]
	var/buyer_faction = order["buyer_faction"]
	var/base_cost = order["cost"]
	var/total_cost = base_cost + order["fee"]
	var/is_requestor_master = master_account && requesting_account == master_account

	if(!master_account || !requesting_account || master_account.money < base_cost || requesting_account.money < total_cost)
		return FALSE
	if(!Buy(beacon, master_account, shopping_list, !is_requestor_master, requesting_account.owner_name, buyer_faction))
		return FALSE
	if(!is_requestor_master)
		requesting_account.transfer(master_account, total_cost, "Trade Network Order")
	CreateLogEntry("Order", requesting_account.owner_name, viewable_contents, total_cost)
	return TRUE

/datum/controller/subsystem/supply/proc/Buy(obj/machinery/trade_beacon/receiving/receiver_beacon, datum/money_account/account, list/shop_list, is_order = FALSE, buyer_name = null, buyer_faction = null)
	if(QDELETED(receiver_beacon) || !istype(receiver_beacon) || !account || !islist(shop_list) || !length(shop_list))
		return FALSE

	var/count_of_all = CollectCountsFrom(shop_list)
	if(!count_of_all)
		return FALSE

	for(var/datum/trading_station/station as anything in shop_list)
		var/list/categories = shop_list[station]
		if(!istype(station) || !islist(categories))
			return FALSE
		if(GetTradeRangeBlockReason(receiver_beacon, station))
			return FALSE
		for(var/category_name in categories)
			var/list/goods = categories[category_name]
			if(!istext(category_name) || !islist(goods) || !islist(station.inventory[category_name]))
				return FALSE
			for(var/good_id in goods)
				var/count_of_good = goods[good_id]
				if(!isnum(count_of_good) || count_of_good < 1)
					return FALSE
				if(!station.GetGoodPacket(category_name, good_id) || !station.GetGoodPath(category_name, good_id))
					return FALSE
				if(station.GetGoodAmount(category_name, good_id) < count_of_good)
					return FALSE

	var/price_for_all = CollectPriceForList(shop_list, buyer_faction)
	if(price_for_all && account.money < price_for_all)
		return FALSE

	var/obj/structure/closet/secure_closet/personal/trade/locker
	if(count_of_all > 1)
		locker = receiver_beacon.DropItem(/obj/structure/closet/secure_closet/personal/trade)
		if(!locker)
			return FALSE
		if(is_order)
			locker.locked = TRUE
			locker.registered_name = buyer_name
			locker.name = "[initial(locker.name)] ([locker.registered_name])"
			locker.update_icon()

	var/order_contents_info = ""
	var/invoice_location

	for(var/datum/trading_station/station as anything in shop_list)
		var/list/categories = shop_list[station]
		var/to_station_wealth = 0
		for(var/category_name in categories)
			var/list/goods = categories[category_name]
			if(!islist(goods))
				continue
			if(!islist(station.inventory[category_name]))
				continue
			to_station_wealth += CollectPriceForCategory(goods, station, buyer_faction, category_name)
			for(var/good_id in goods)
				var/count_of_good = goods[good_id]
				var/good_path = station.GetGoodPath(category_name, good_id)
				if(!good_path)
					return FALSE
				for(var/i in 1 to count_of_good)
					if(istype(locker))
						new good_path(locker)
						invoice_location = locker
					else
						var/atom/movable/new_item = receiver_beacon.DropItem(good_path)
						invoice_location = new_item ? new_item.loc : null
				station.SetGoodAmount(category_name, good_id, max(0, station.GetGoodAmount(category_name, good_id) - count_of_good))
				var/item_name = station.GetGoodName(category_name, good_id)
				order_contents_info += "<li>[count_of_good]x [item_name]</li>"
		station.AddToWealth(to_station_wealth)

	if(count_of_all > 1)
		invoice_location = locker

	CreateLogEntry("Shipping", is_order && buyer_name ? buyer_name : account.owner_name, order_contents_info, price_for_all, TRUE, invoice_location)
	account.withdraw(price_for_all, "Trade Network Purchase", "Trade Network")
	return TRUE

/datum/controller/subsystem/supply/proc/Export(obj/machinery/trade_beacon/sending/sender_beacon, datum/money_account/money_account)
	if(QDELETED(sender_beacon) || !istype(money_account))
		return FALSE

	var/invoice_contents_info = ""
	var/export_count = 0
	var/cost = 0
	var/list/exportables = list()

	for(var/atom/movable/exported as anything in sender_beacon.GetObjects())
		if(istype(exported, /obj/structure/closet/crate/trade_contract))
			continue
		if(!CanExportAtom(exported))
			HandleRejectedExport(exported)
			continue

		var/export_value = GetExportValue(exported)
		if(!export_value)
			continue

		exportables[exported] = export_value

	if(!length(exportables))
		return FALSE
	if(!sender_beacon.StartExport())
		return FALSE

	for(var/atom/movable/exported as anything in exportables)
		var/export_value = exportables[exported]
		invoice_contents_info += "<li>[exported.name]</li>"
		cost += export_value
		qdel(exported)
		++export_count

		if(export_count > 100)
			break

	if(!cost)
		return FALSE
	money_account.deposit(cost, "Trade Network Export", "Trade Network")
	if(invoice_contents_info)
		CreateLogEntry("Export", money_account.owner_name, invoice_contents_info, cost, TRUE, get_turf(sender_beacon))
	return TRUE

/datum/controller/subsystem/supply/proc/CreateLogEntry(type, ordering_account, contents, total_paid, create_invoice = FALSE, invoice_location = null)
	var/log_id
	var/list/log_entry = list(
		"id" = null,
		"ordering_acct" = ordering_account,
		"contents" = contents,
		"total_paid" = total_paid,
		"time" = time2text(world.time, "hh:mm")
	)

	switch(type)
		if("Shipping")
			log_id = "[++shipping_invoice_number]-S"
			log_entry["id"] = log_id
			shipping_log += list(log_entry)
		if("Export")
			log_id = "[++export_invoice_number]-E"
			log_entry["id"] = log_id
			export_log += list(log_entry)
		if("Order")
			log_id = "[++order_number]-O"
			log_entry["id"] = log_id
			order_log += list(log_entry)
		if("Contract")
			log_id = "[++contract_number]-C"
			log_entry["id"] = log_id
			contract_log += list(log_entry)
		else
			return

	if(create_invoice && invoice_location && log_id)
		PrintInvoice(type, log_id, ordering_account, contents, total_paid, FALSE, invoice_location)
		if(type == "Shipping")
			PrintInvoice(type, log_id, ordering_account, contents, total_paid, TRUE, invoice_location)

/datum/controller/subsystem/supply/proc/PrintInvoice(type, log_id, ordering_account, contents, total_paid, is_internal = FALSE, location)
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
	text += "Contents:<ul>[contents]</ul>"
	text += "Total Credits Paid: [total_paid]<br>"
	text += "</font>"
	new /obj/item/paper(location, text, title)

/datum/controller/subsystem/supply/proc/GetLogDataById(log_id)
	var/list/id_data = splittext(log_id, "-")
	if(id_data.len < 2)
		return null
	var/log_num = text2num(id_data[1])
	switch(id_data[2])
		if("S")
			return shipping_log[log_num]
		if("E")
			return export_log[log_num]
		if("O")
			return order_log[log_num]
		if("C")
			return contract_log[log_num]
	return null

/datum/controller/subsystem/supply/proc/CanExportAtom(atom/movable/exported)
	if(!istype(exported) || QDELETED(exported))
		return FALSE
	if(ishuman(exported))
		return FALSE
	var/list/contents_including_self = exported.GetAllContents(3, TRUE)
	return !is_path_in_list(/mob/living/carbon/human, contents_including_self)

/datum/controller/subsystem/supply/proc/HandleRejectedExport(atom/movable/exported)
	if(ishuman(exported))
		var/mob/living/carbon/human/human = exported
		human.apply_damage(15, DAMAGE_BURN)

/datum/controller/subsystem/supply/proc/GetExportValue(atom/movable/exported, datum/trading_station/target_station = null)
	if(!CanExportAtom(exported))
		return 0
	if(istype(target_station))
		var/list/match = FindCommodityForExport(exported, target_station)
		if(islist(match))
			return GetStationSellPrice(match["good_id"], target_station, match["category"]) * max(1, match["amount"])
	if(istype(exported, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/crate = exported
		return round(GetLegacyCrateExportValue(crate))
	return round(get_value(exported))

/datum/controller/subsystem/supply/proc/GetLegacyCrateExportValue(obj/structure/closet/crate/crate)
	. = 0
	if(!istype(crate))
		return
	. += initial(crate.points_per_crate) * CARGO_POINT_TO_THALLER
	var/find_manifest = TRUE
	for(var/atom/movable/item as anything in crate)
		if(find_manifest && istype(item, /obj/item/paper/manifest))
			var/obj/item/paper/manifest/slip = item
			if(!slip.is_copy && slip.stamped && length(slip.stamped))
				. += points_per_slip * CARGO_POINT_TO_THALLER
				find_manifest = FALSE
			continue
		if(istype(item, /obj/item/stack/material))
			var/obj/item/stack/material/material_stack = item
			if(material_stack.material && material_stack.material.sale_price > 0)
				. += material_stack.get_amount() * material_stack.material.sale_price * material_stack.matter_multiplier * CARGO_POINT_TO_THALLER
			if(material_stack.reinf_material && material_stack.reinf_material.sale_price > 0)
				. += material_stack.get_amount() * material_stack.reinf_material.sale_price * material_stack.matter_multiplier * 0.5 * CARGO_POINT_TO_THALLER
			continue
		if(istype(item, /obj/item/disk/survey))
			var/obj/item/disk/survey/survey_disk = item
			. += round(survey_disk.Value() * 0.05) * CARGO_POINT_TO_THALLER
			continue
		if(istype(item, /obj/item/artefact))
			var/obj/item/artefact/artefact = item
			. += artefact.cargo_price * CARGO_POINT_TO_THALLER
			continue
		if(istype(item, /obj/item/collector))
			var/obj/item/collector/collector = item
			if(collector.stored_artefact)
				. += collector.stored_artefact.cargo_price * CARGO_POINT_TO_THALLER
			continue
		if(CanExportAtom(item))
			. += get_value(item)
