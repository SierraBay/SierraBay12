SUBSYSTEM_DEF(trade)
	name = "Frontier Trade"
	init_order = SS_INIT_SHUTTLE - 1
	priority = SS_PRIORITY_SUPPLY
	wait = 2 SECONDS
	var/enabled = FALSE
	var/catalog_version = 1
	var/list/stations = list()
	var/list/goods = list()
	var/list/orders = list()
	var/list/shipping_log = list()
	var/list/beacons_sending = list()
	var/list/beacons_receiving = list()
	var/list/routed_packs = list()
	var/list/aliased_packs = list()
	var/list/printable_types = list()
	var/list/vending_prices = list()
	var/list/catalog_min_unit_price = list()
	var/next_order_id = 0
	var/next_invoice_id = 0
	var/transaction_busy = FALSE
	var/list/request_ready_at = list()

/datum/controller/subsystem/trade/Initialize(start_uptime)
	enabled = GLOB.using_map.path == "sierra" && GLOB.using_map.use_overmap
	if(!enabled)
		return ..()
	build_anti_exploit_caches()
	seed_default_pack_aliases()
	install_requisition_software()
	for(var/path in subtypesof(/datum/trade_station))
		var/datum/trade_station/station = new path
		if(!prob(station.spawn_chance))
			qdel(station)
			continue
		stations[station.uid] = station
		station.setup()
		place_station(station)
	ensure_legacy_pack_coverage()
	finalize_catalog_pricing()
	catalog_version++
	return ..()

/datum/controller/subsystem/trade/proc/build_anti_exploit_caches()
	printable_types.Cut()
	vending_prices.Cut()
	for(var/datum/design/design_path as anything in subtypesof(/datum/design))
		var/bp = initial(design_path.build_path)
		if(ispath(bp))
			printable_types[bp] = TRUE
	for(var/vtype in subtypesof(/obj/machinery/vending))
		var/obj/machinery/vending/vendor = new vtype(null, 0, FALSE)
		var/list/pmap = islist(vendor.prices) ? vendor.prices : list()
		var/list/all_lists = list(vendor.products, vendor.contraband, vendor.premium)
		for(var/list/plist as anything in all_lists)
			if(!islist(plist))
				continue
			for(var/item_path in plist)
				if(!ispath(item_path))
					continue
				var/vp = isnum(pmap[item_path]) ? pmap[item_path] : 0
				if(isnull(vending_prices[item_path]) || vp < vending_prices[item_path])
					vending_prices[item_path] = vp
		qdel(vendor)

/datum/controller/subsystem/trade/proc/register_pack_alias(pack_type, target = TRUE)
	if(ispath(pack_type, /singleton/hierarchy/supply_pack))
		aliased_packs[pack_type] = target

/datum/controller/subsystem/trade/proc/seed_default_pack_aliases()
	for(var/singleton/hierarchy/supply_pack/sp as anything in SSsupply.master_supply_list)
		if(istype(sp, /singleton/hierarchy/supply_pack/prosthesis))
			var/singleton/hierarchy/supply_pack/prosthesis/prost = sp
			if(prost.select_part)
				aliased_packs[sp.type] = /obj/item/prosthetic_kit/frontier_trade

/datum/controller/subsystem/trade/proc/ensure_legacy_pack_coverage()
	var/list/routed_signatures = list()
	for(var/pack_type in routed_packs)
		var/singleton/hierarchy/supply_pack/rp = GET_SINGLETON(pack_type)
		if(rp)
			routed_signatures[get_supply_pack_signature(rp)] = pack_type
	var/list/touched_stations = list()
	for(var/singleton/hierarchy/supply_pack/sp as anything in SSsupply.master_supply_list)
		if(!istype(sp) || isnull(sp.cost) || sp.is_category())
			continue
		if((sp.type in routed_packs) || (sp.type in aliased_packs))
			continue
		var/sig = get_supply_pack_signature(sp)
		if(sig && routed_signatures[sig])
			aliased_packs[sp.type] = routed_signatures[sig]
			continue
		var/list/route = resolve_fallback_pack_route(sp)
		var/datum/trade_station/station = stations[route["station_uid"]] || stations["general"] || (length(stations) ? stations[stations[1]] : null)
		if(!station)
			continue
		station.add_supply_pack(sp.type, route["category"])
		routed_signatures[sig] = sp.type
		touched_stations |= station
	for(var/datum/trade_station/station as anything in touched_stations)
		station.recalculate_economy_parameters()

/datum/controller/subsystem/trade/proc/get_supply_pack_signature(singleton/hierarchy/supply_pack/sp)
	if(!sp || !length(sp.contains))
		return ""
	var/list/parts = list("[sp.containertype]|[sp.supply_method]|[sp.num_contained]")
	for(var/cpath in sp.contains)
		parts += "[cpath]=[max(1, sp.contains[cpath] || 1)]"
	return jointext(parts, ";")

/datum/controller/subsystem/trade/proc/resolve_fallback_pack_route(singleton/hierarchy/supply_pack/sp)
	if(sp.contraband || sp.hidden)
		return list("station_uid" = "smugglers", "category" = "Contraband")
	if(istype(sp, /singleton/hierarchy/supply_pack/materials))
		return list("station_uid" = "engineering", "category" = "Materials")
	if(istype(sp, /singleton/hierarchy/supply_pack/engineering) || istype(sp, /singleton/hierarchy/supply_pack/machinery))
		return list("station_uid" = "engineering", "category" = "Engineering")
	if(istype(sp, /singleton/hierarchy/supply_pack/atmospherics) || istype(sp, /singleton/hierarchy/supply_pack/dispenser_cartridges/boron))
		return list("station_uid" = "engines", "category" = "Atmospherics")
	if(istype(sp, /singleton/hierarchy/supply_pack/medical))
		return list("station_uid" = "medicine", "category" = "Medical")
	if(istype(sp, /singleton/hierarchy/supply_pack/prosthesis))
		return list("station_uid" = "medicine", "category" = "Prosthetics")
	if(istype(sp, /singleton/hierarchy/supply_pack/science))
		return list("station_uid" = "electronics", "category" = "Science & Robotics")
	if(istype(sp, /singleton/hierarchy/supply_pack/hydroponics))
		return list("station_uid" = "fauna", "category" = "Chemistry & Hydroponics")
	if(istype(sp, /singleton/hierarchy/supply_pack/livecargo))
		return list("station_uid" = "fauna", "category" = "Livestock & Fauna")
	if(istype(sp, /singleton/hierarchy/supply_pack/security) || istype(sp, /singleton/hierarchy/supply_pack/ammunition) || istype(sp, /singleton/hierarchy/supply_pack/munition))
		var/sec_uid = stations["security"] ? "security" : "engineering"
		return list("station_uid" = sec_uid, "category" = "Security")
	if(istype(sp, /singleton/hierarchy/supply_pack/galley) || istype(sp, /singleton/hierarchy/supply_pack/dispenser_cartridges))
		return list("station_uid" = "general", "category" = "Food & Service")
	if(istype(sp, /singleton/hierarchy/supply_pack/clothes_uniforms) || istype(sp, /singleton/hierarchy/supply_pack/nonessent))
		return list("station_uid" = "general", "category" = "Clothing & Gear")
	return list("station_uid" = "general", "category" = "Cargo & Logistics")

/datum/controller/subsystem/trade/proc/finalize_catalog_pricing()
	catalog_min_unit_price.Cut()
	for(var/id in goods)
		var/datum/trade_good/good = goods[id]
		var/price = good.get_price()
		if(good.supply_pack_type)
			var/singleton/hierarchy/supply_pack/pack = GET_SINGLETON(good.supply_pack_type)
			if(!pack)
				continue
			var/n_items = get_pack_item_count(pack)
			var/per_item = price / n_items
			for(var/cpath in pack.contains)
				record_catalog_unit_price(cpath, per_item)
		else
			var/qty = max(1, good.stack_size || get_implicit_stack_amount(good.item_type))
			record_catalog_unit_price(good.item_type, price / qty)
	for(var/id in goods)
		var/datum/trade_good/good = goods[id]
		good.export_floor = good.get_native_value()
		good.base_price = max(1, good.base_price, ceil(good.export_floor * 1.4))
	for(var/uid in stations)
		var/datum/trade_station/station = stations[uid]
		for(var/id in station.offers)
			var/datum/trade_offer/offer = station.offers[id]
			offer.balance_price()

/datum/controller/subsystem/trade/proc/record_catalog_unit_price(path, unit_price)
	if(!ispath(path))
		return
	var/stk = get_implicit_stack_amount(path)
	if(stk > 1)
		unit_price = unit_price / stk
	if(isnull(catalog_min_unit_price[path]) || unit_price < catalog_min_unit_price[path])
		catalog_min_unit_price[path] = unit_price
	if(path == /obj/item/sealgen_case)
		if(isnull(catalog_min_unit_price[/obj/machinery/sealgen]) || unit_price < catalog_min_unit_price[/obj/machinery/sealgen])
			catalog_min_unit_price[/obj/machinery/sealgen] = unit_price

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
				catalog_version++
				return

/datum/controller/subsystem/trade/proc/place_station(datum/trade_station/station)
	var/edge = GLOB.using_map.overmap_size - OVERMAP_EDGE
	var/overmap_z = GLOB.using_map.overmap_z
	var/turf/location
	for(var/attempt in 1 to 48)
		var/turf/candidate = locate(rand(OVERMAP_EDGE, edge), rand(OVERMAP_EDGE, edge), overmap_z)
		if(candidate && !(locate(/obj/overmap) in candidate))
			location = candidate
			break
	if(!location)
		var/list/candidates = block(locate(OVERMAP_EDGE, OVERMAP_EDGE, overmap_z), locate(edge, edge, overmap_z))
		for(var/turf/candidate as anything in candidates)
			if(!(locate(/obj/overmap) in candidate))
				location = candidate
				break
		if(!location && length(candidates))
			location = pick(candidates)
	if(!location)
		return
	station.overmap_object = new(location, station)

/datum/controller/subsystem/trade/proc/get_receiver(datum/trade_order/order = null, require_ready = TRUE)
	var/count = order ? max(1, order.get_floor_count()) : 1
	var/obj/machinery/trade_beacon/receiving/fallback
	for(var/obj/machinery/trade_beacon/receiving/beacon as anything in beacons_receiving)
		if(order?.receiver_id && order.receiver_id != "\ref[beacon]")
			continue
		if(order?.delivery_area && order.delivery_area != get_area(beacon))
			continue
		if(length(beacon.get_landing_turfs(count)) >= count)
			return beacon
		if(!require_ready && !fallback && !QDELETED(beacon) && !beacon.panel_open && !MACHINE_IS_BROKEN(beacon) && beacon.powered())
			fallback = beacon
	return require_ready ? null : fallback

/datum/controller/subsystem/trade/proc/log_transaction(kind, title, amount, account_name, list/contents = null, account_number = 0, fee = 0, requester_key = null)
	next_invoice_id++
	var/list/entry = list(
		"id" = next_invoice_id,
		"kind" = kind,
		"title" = title,
		"amount" = amount,
		"account" = account_name,
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
	routed_packs.Cut()
	aliased_packs.Cut()
	printable_types.Cut()
	vending_prices.Cut()
	catalog_min_unit_price.Cut()
	return ..()

/datum/controller/subsystem/trade/proc/install_requisition_software()
	for(var/datum/job/job as anything in SSjobs.primary_job_datums)
		job.software_on_spawn = islist(job.software_on_spawn) ? job.software_on_spawn.Copy() : list()
		if(/datum/computer_file/program/supply in job.software_on_spawn)
			job.software_on_spawn -= /datum/computer_file/program/supply
			job.software_on_spawn |= /datum/computer_file/program/trade
		job.software_on_spawn |= /datum/computer_file/program/trade_orders
	if(ntnet_global)
		for(var/datum/computer_file/program/P as anything in ntnet_global.available_station_software.Copy())
			if(P.type == /datum/computer_file/program/supply)
				ntnet_global.available_station_software -= P
				var/list/cat_list = ntnet_global.available_software_by_category[P.category]
				if(islist(cat_list))
					cat_list -= P
