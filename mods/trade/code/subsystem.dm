SUBSYSTEM_DEF(trade)
	name = "Frontier Trade"
	init_order = SS_INIT_SHUTTLE - 1
	priority = SS_PRIORITY_SUPPLY
	wait = 2 SECONDS
	var/enabled = FALSE
	var/list/stations = list()
	var/list/goods = list()
	var/list/orders = list()
	var/list/shipping_log = list()
	var/list/beacons_sending = list()
	var/list/beacons_receiving = list()
	var/next_order_id = 0
	var/next_invoice_id = 0
	var/transaction_busy = FALSE
	var/list/request_ready_at = list()

/datum/controller/subsystem/trade/Initialize(start_uptime)
	enabled = GLOB.using_map.path == "sierra" && GLOB.using_map.use_overmap
	if(!enabled)
		return ..()
	install_requisition_software()
	for(var/path in subtypesof(/datum/trade_station))
		var/datum/trade_station/station = new path
		if(!prob(station.spawn_chance))
			qdel(station)
			continue
		stations[station.uid] = station
		station.setup()
		place_station(station)
	for(var/uid in stations)
		var/datum/trade_station/station = stations[uid]
		for(var/id in station.offers)
			var/datum/trade_offer/offer = station.offers[id]
			offer.balance_price()
	return ..()

/datum/controller/subsystem/trade/fire(resumed)
	if(!enabled)
		return
	for(var/uid in stations)
		var/datum/trade_station/station = stations[uid]
		if(!station.discovered)
			check_discovery(station)
		if(world.time >= station.next_update)
			station.update_tick()
	for(var/id in orders)
		var/datum/trade_order/order = orders[id]
		if(order.state == TRADE_PAID)
			deliver(order)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/trade/proc/check_discovery(datum/trade_station/station)
	for(var/level in GLOB.using_map.station_levels)
		var/obj/overmap/visitable/ship/ship = map_sectors["[level]"]
		if(!istype(ship) || !(ship.sector_flags & OVERMAP_SECTOR_BASE))
			continue
		for(var/obj/machinery/shipsensors/sensors as anything in ship.sensors)
			if(sensors.contact_datums[station.overmap_object])
				station.discovered = TRUE
				return

/datum/controller/subsystem/trade/proc/place_station(datum/trade_station/station)
	var/edge = GLOB.using_map.overmap_size - OVERMAP_EDGE
	var/turf/location = locate(rand(OVERMAP_EDGE, edge), rand(OVERMAP_EDGE, edge), GLOB.using_map.overmap_z)
	if(!location)
		return
	station.overmap_object = new(location)
	station.overmap_object.station = station
	station.overmap_object.name = station.name
	station.overmap_object.desc = station.desc
	station.overmap_object.add_scan_data("trade", station.desc)

/datum/controller/subsystem/trade/proc/get_receiver(datum/trade_order/order = null)
	var/count = order ? order.get_floor_count() : 1
	for(var/obj/machinery/trade_beacon/receiving/beacon as anything in beacons_receiving)
		if(order?.receiver_id && order.receiver_id != "\ref[beacon]")
			continue
		if(order?.delivery_area && order.delivery_area != get_area(beacon))
			continue
		if(length(beacon.get_landing_turfs(count)) == count)
			return beacon

/datum/controller/subsystem/trade/proc/log_transaction(kind, title, amount, account_name, list/contents = null, account_number = 0, fee = 0, requester_key = null)
	next_invoice_id++
	var/list/entry = list(
		"id" = next_invoice_id,
		"kind" = kind,
		"title" = html_encode(title),
		"amount" = amount,
		"account" = html_encode(account_name),
		"time" = stationtime2text(),
		"contents" = copy_trade_rows(contents),
		"account_number" = account_number,
		"fee" = fee,
		"requester_key" = requester_key,
	)
	shipping_log.Insert(1, list(entry))
	if(length(shipping_log) > TRADE_LOG_LIMIT)
		shipping_log.Cut(TRADE_LOG_LIMIT + 1)
	return entry["id"]

/datum/controller/subsystem/trade/Destroy()
	for(var/id in orders)
		qdel(orders[id])
	for(var/uid in stations)
		qdel(stations[uid])
	request_ready_at.Cut()
	orders.Cut()
	stations.Cut()
	goods.Cut()
	return ..()

/datum/controller/subsystem/trade/proc/install_requisition_software()
	for(var/datum/job/job as anything in SSjobs.primary_job_datums)
		job.software_on_spawn = islist(job.software_on_spawn) ? job.software_on_spawn.Copy() : list()
		job.software_on_spawn |= /datum/computer_file/program/trade_orders
