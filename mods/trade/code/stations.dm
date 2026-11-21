/datum/trade_station
	var/uid
	var/name
	var/desc = "A local orbital relay serving passing frontier convoys."
	var/markup = TRADE_COMMON
	var/spawn_chance = 100
	var/start_discovered = FALSE
	var/discovered = FALSE
	var/black_market = FALSE
	var/base_income = 2500
	var/wealth = 3000
	var/wealth_cap = 25000
	var/favor = 0
	var/hidden_inv_threshold = 1500
	var/recommendation_threshold = 3000
	var/hidden_inv_unlocked = FALSE
	var/recommendation_unlocked = FALSE
	var/list/stations_recommended = list()
	var/list/recommendations_received = list()
	var/recommendations_needed = 1
	var/list/inventory = list()
	var/list/sierra_inventory = list()
	var/list/hidden_inventory = list()
	var/list/offer_types = list()
	var/list/goods = list()
	var/list/offers = list()
	var/list/specialties = list()
	var/next_update = 0
	var/obj/overmap/trade_station/overmap_object
	var/tree_x = 50
	var/tree_y = 50
	var/icon_state = "signal"
	var/overmap_color = "#66ccff"
	var/tree_label = "Relay"

/datum/trade_station/proc/setup()
	discovered = start_discovered
	add_inventory(inventory, hidden = FALSE)
	add_inventory(sierra_inventory, hidden = FALSE)
	add_inventory(hidden_inventory, hidden = TRUE)
	for(var/path in offer_types)
		add_offer(path, offer_types[path])
	recalculate_economy_parameters()
	next_update = world.time + rand(5, 7) MINUTES

/datum/trade_station/proc/recalculate_economy_parameters()
	var/n = length(goods)
	wealth = max(3000, n * 100)
	base_income = max(2500, n * 50)
	wealth_cap = max(25000, n * 400)
	if(!length(specialties))
		for(var/id in goods)
			var/datum/trade_good/good = goods[id]
			if(good.category)
				specialties |= good.category

/datum/trade_station/proc/add_inventory(list/source, hidden)
	for(var/category in source)
		var/list/entries = source[category]
		for(var/path in entries)
			if(ispath(path, /singleton/hierarchy/supply_pack))
				add_supply_pack(path, category, entries[path], hidden)
			else if(ispath(path, /atom/movable))
				add_good(path, category, entries[path], hidden)

/datum/trade_station/proc/add_supply_pack(pack_type, category, list/packet = null, hidden = FALSE, req_access = null)
	ASSERT(ispath(pack_type, /singleton/hierarchy/supply_pack))
	var/singleton/hierarchy/supply_pack/pack = GET_SINGLETON(pack_type)
	if(!pack)
		return null
	if(!pack.manifest)
		pack.setup()
	var/datum/trade_good/good = new
	good.station = src
	good.id = "[uid]-[length(goods) + 1]"
	good.supply_pack_type = pack_type
	good.item_type = pack.containertype || /obj/structure/closet/crate
	good.category = category || "Supplies"
	good.hidden = hidden
	var/access = !isnull(packet?["req_access"]) ? packet["req_access"] : (!isnull(req_access) ? req_access : pack.access)
	good.req_access = access
	if(islist(access))
		var/list/requirements = access
		good.req_access = requirements.Copy()
	good.security_level = packet?["security_level"] || pack.security_level
	good.name = packet?["name"] || pack.name
	good.desc = packet?["desc"] || ""
	good.populate_metadata()
	var/target_price = packet?["target_price"] || packet?["price"] || (max(1, pack.cost || 10) * TRADE_POINT_VALUE)
	var/raw_base = max(1, round(target_price / markup))
	good.export_floor = good.get_native_value()
	good.base_price = max(1, raw_base, ceil(good.export_floor * 1.4))
	var/list/stock_range = packet?["amount_range"]
	if(length(stock_range) == 2)
		good.min_stock = max(0, stock_range[1])
		good.max_stock = max(good.min_stock, stock_range[2])
	else
		var/fprice = good.get_price()
		if(fprice <= 300)
			good.min_stock = 4
			good.max_stock = 10
		else if(fprice <= 900)
			good.min_stock = 2
			good.max_stock = 6
		else
			good.min_stock = 1
			good.max_stock = 3
	good.stock = rand(good.min_stock, good.max_stock)
	goods[good.id] = good
	SStrade.goods[good.id] = good
	SStrade.routed_packs[pack_type] = good.id
	return good

/datum/trade_station/proc/add_good(path, category, list/packet = null, hidden = FALSE, req_access = null)
	ASSERT(ispath(path, /atom/movable))
	var/datum/trade_good/good = new
	good.station = src
	good.id = "[uid]-[length(goods) + 1]"
	good.item_type = path
	good.category = category
	good.hidden = hidden
	good.stack_size = ispath(path, /obj/item/stack) ? max(0, round(packet?["stack_size"] || 0)) : 0
	var/access = !isnull(packet?["req_access"]) ? packet["req_access"] : req_access
	good.req_access = access
	if(islist(access))
		var/list/requirements = access
		good.req_access = requirements.Copy()
	good.security_level = packet?["security_level"]
	var/atom/item = path
	good.name = packet?["name"] || initial(item.name)
	good.desc = packet?["desc"] || ""
	good.populate_metadata()
	var/raw_base = packet?["target_price"] ? round(packet["target_price"] / markup) : (packet?["price"] || 0)
	good.export_floor = good.get_native_value()
	good.base_price = max(1, raw_base, ceil(good.export_floor * 1.4))
	var/list/stock_range = packet?["amount_range"]
	if(length(stock_range) == 2)
		good.min_stock = max(0, stock_range[1])
		good.max_stock = max(good.min_stock, stock_range[2])
	good.stock = rand(good.min_stock, good.max_stock)
	goods[good.id] = good
	SStrade.goods[good.id] = good
	return good

/datum/trade_station/proc/add_offer(path, list/packet)
	var/datum/trade_offer/offer = new
	offer.id = "[uid]-offer-[length(offers) + 1]"
	offer.station = src
	offer.item_type = path
	offer.name = packet["name"]
	var/list/attachments = packet["attachments"]
	if(islist(attachments))
		offer.attachments = attachments.Copy()
	offer.attach_count = max(0, round(packet["attach_count"] || 0))
	var/multiplier = clamp(packet["price_multiplier"] || 1, 1, 2)
	offer.unit_price = max(1, packet["price"] * multiplier)
	if(ispath(path, /obj/item/stack))
		var/obj/item/stack/stack_type = path
		offer.native_stack_size = initial(stack_type.max_amount)
	if(packet["reagent_volume"])
		offer.reagent_volume = max(1, round(packet["reagent_volume"]))
	offer.max_amount = max(1, packet["amount"])
	offer.amount = rand(1, offer.max_amount)
	offer.live_required = ispath(path, /mob/living)
	if(ispath(path, /datum/reagent))
		offer.reagent_type = path
		offer.item_type = /obj/item/reagent_containers
	offers[offer.id] = offer

/datum/trade_station/proc/update_tick()
	var/n = length(goods)
	base_income = max(2500, n * 50)
	wealth_cap = max(25000, n * 400)
	wealth = min(wealth_cap, wealth + base_income)
	var/list/depleted = list()
	var/list/surplus = list()
	for(var/id in goods)
		var/datum/trade_good/good = goods[id]
		if(good.hidden && !hidden_inv_unlocked)
			continue
		if(good.stock < good.min_stock)
			depleted += good
		else if(good.stock < good.max_stock)
			surplus += good
	// Pass 1: Depleted floor recovery with zero-permanent-stockout guarantee.
	for(var/datum/trade_good/good as anything in shuffle(depleted))
		var/cost = max(1, round(good.get_price() * 0.35))
		var/need = max(0, good.min_stock - good.stock - good.reserved_stock)
		var/add = min(need, floor(wealth / cost))
		if(good.stock == 0 && good.min_stock >= 1 && add <= 0 && good.reserved_stock < good.max_stock)
			add = 1
		if(add > 0)
			good.stock += add
			wealth = max(0, wealth - cost * add)
	// Pass 2: Surplus 20% top-up.
	for(var/datum/trade_good/good as anything in shuffle(surplus))
		if(!prob(20))
			continue
		var/cost = max(1, round(good.get_price() * 0.35))
		if(wealth < cost)
			continue
		var/room = max(0, good.max_stock - good.stock - good.reserved_stock)
		var/add = min(room, rand(1, 2), floor(wealth / cost))
		if(add > 0)
			good.stock += add
			wealth = max(0, wealth - cost * add)
	for(var/id in offers)
		var/datum/trade_offer/offer = offers[id]
		offer.amount = rand(1, offer.max_amount)
		offer.completed = FALSE
	next_update = world.time + rand(5, 7) MINUTES

/datum/trade_station/proc/restock(datum/trade_good/good, budget)
	var/cost = max(1, round(good.get_price() * 0.35))
	var/room = good.max_stock - good.stock - good.reserved_stock
	var/count = min(room, floor(min(wealth, budget) / cost))
	if(count <= 0 && good.stock == 0 && good.min_stock >= 1 && room > 0)
		count = 1
	if(count <= 0)
		return
	good.stock += count
	wealth = max(0, wealth - cost * count)

/datum/trade_station/proc/add_to_wealth(income, is_offer = FALSE)
	wealth = min(max(25000, length(goods) * 400), wealth + income)
	favor += income * (is_offer ? 1 : 0.30)
	if(!hidden_inv_unlocked && favor >= hidden_inv_threshold)
		hidden_inv_unlocked = TRUE
		SStrade.catalog_version++
	if(recommendation_unlocked || favor < recommendation_threshold)
		return
	recommendation_unlocked = TRUE
	for(var/target_uid in stations_recommended)
		var/datum/trade_station/target = SStrade.stations[target_uid]
		if(!target)
			continue
		target.recommendations_received |= uid
		if(!target.discovered && length(target.recommendations_received) >= target.recommendations_needed)
			target.discovered = TRUE
			SStrade.catalog_version++

/datum/trade_station/Destroy()
	QDEL_NULL(overmap_object)
	for(var/id in goods)
		SStrade.goods -= id
		qdel(goods[id])
	for(var/id in offers)
		qdel(offers[id])
	goods.Cut()
	offers.Cut()
	specialties.Cut()
	return ..()
