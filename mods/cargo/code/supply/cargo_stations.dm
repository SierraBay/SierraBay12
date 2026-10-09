/datum/controller/subsystem/supply/proc/RefreshTradeBeacons()
	for(var/obj/machinery/trade_beacon/sending/beacon as anything in beacons_sending)
		if(QDELETED(beacon))
			beacons_sending -= beacon
	for(var/obj/machinery/trade_beacon/receiving/beacon as anything in beacons_receiving)
		if(QDELETED(beacon))
			beacons_receiving -= beacon

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
	if(!istext(target_uid) || !length(target_uid))
		return null
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
	if(!is_valid_cargo_cart(shop_list))
		return "Invalid cargo cart."
	for(var/station_key in shop_list)
		var/datum/trading_station/station = GetStationByUid(station_key)
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
