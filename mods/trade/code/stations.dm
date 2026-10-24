/datum/trade_station
	var/uid
	var/name
	var/desc = "A local orbital relay serving passing frontier convoys."
	var/markup = TRADE_COMMON
	var/spawn_chance = 100
	var/start_discovered = FALSE
	var/discovered = FALSE
	var/black_market = FALSE
	var/base_income = 1600
	var/wealth = 0
	var/favor = 0
	var/hidden_inv_threshold = 2000
	var/recommendation_threshold = 4000
	var/hidden_inv_unlocked = FALSE
	var/recommendation_unlocked = FALSE
	var/list/stations_recommended = list()
	var/list/recommendations_received = list()
	var/recommendations_needed = 1
	var/list/inventory = list()
	var/list/hidden_inventory = list()
	var/list/offer_types = list()
	var/list/goods = list()
	var/list/offers = list()
	var/next_update = 0
	var/obj/overmap/trade_station/overmap_object
	var/tree_x = 50
	var/tree_y = 50
	var/icon_state = "signal"
	var/tree_label = "Relay"

/datum/trade_station/proc/setup()
	discovered = start_discovered
	add_inventory(inventory, hidden = FALSE)
	add_inventory(hidden_inventory, hidden = TRUE)
	for(var/path in offer_types)
		add_offer(path, offer_types[path])
	next_update = world.time + rand(6, 8) MINUTES

/datum/trade_station/proc/add_inventory(list/source, hidden)
	for(var/category in source)
		var/list/entries = source[category]
		for(var/path in entries)
			var/item_type = istext(path) ? text2path(path) : path
			if(item_type)
				add_good(item_type, category, entries[path], hidden)

/datum/trade_station/proc/add_good(path, category, list/packet, hidden = FALSE, req_access = null)
	ASSERT(ispath(path, /atom/movable))
	var/datum/trade_good/good = new
	good.station = src
	good.id = "[uid]-[length(goods) + 1]"
	good.item_type = path
	good.category = category
	good.hidden = hidden
	good.stack_size = ispath(path, /obj/item/stack) ? max(0, round(packet?["stack_size"] || 0)) : 0
	var/access = packet?["req_access"] || req_access
	good.req_access = access
	if(islist(access))
		var/list/requirements = access
		good.req_access = requirements.Copy()
	var/atom/item = path
	good.name = packet?["name"] || initial(item.name)
	good.base_price = max(1, good.get_native_value(), packet?["price"] || 0)
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
	if(ispath(path, /obj))
		offer.unit_price = max(1, min(offer.unit_price, floor(get_value(path) * offer.native_stack_size * TRADE_HOCKABLE * multiplier)))
	offer.max_amount = max(1, packet["amount"])
	offer.amount = rand(1, offer.max_amount)
	offer.live_required = ispath(path, /mob/living)
	if(ispath(path, /datum/reagent))
		offer.reagent_type = path
		offer.item_type = /obj/item/reagent_containers
	offers[offer.id] = offer

/datum/trade_station/proc/update_tick()
	wealth += base_income
	var/budget = round(wealth / max(1, length(goods)))
	for(var/id in goods)
		var/datum/trade_good/good = goods[id]
		if(good.hidden && !hidden_inv_unlocked)
			continue
		if(good.stock < good.min_stock || (good.stock < good.max_stock && prob(15)))
			restock(good, budget)
	for(var/id in offers)
		var/datum/trade_offer/offer = offers[id]
		offer.amount = rand(1, offer.max_amount)
		offer.completed = FALSE
	next_update = world.time + rand(6, 8) MINUTES

/datum/trade_station/proc/restock(datum/trade_good/good, budget)
	var/cost = max(1, round(good.get_price() / 2))
	var/count = min(good.max_stock - good.stock - good.reserved_stock, floor(min(wealth, budget) / cost))
	if(count <= 0)
		return
	count = rand(1, count)
	good.stock += count
	wealth -= cost * count

/datum/trade_station/proc/add_to_wealth(income, is_offer = FALSE)
	wealth += income
	favor += income * (is_offer ? 1 : 0.25)
	hidden_inv_unlocked ||= favor >= hidden_inv_threshold
	if(recommendation_unlocked || favor < recommendation_threshold)
		return
	recommendation_unlocked = TRUE
	for(var/target_uid in stations_recommended)
		var/datum/trade_station/target = SStrade.stations[target_uid]
		if(!target)
			continue
		target.recommendations_received |= uid
		if(length(target.recommendations_received) >= target.recommendations_needed)
			target.discovered = TRUE

/datum/trade_station/Destroy()
	QDEL_NULL(overmap_object)
	for(var/id in goods)
		SStrade.goods -= id
		qdel(goods[id])
	for(var/id in offers)
		qdel(offers[id])
	goods.Cut()
	offers.Cut()
	return ..()
