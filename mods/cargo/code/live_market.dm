#define MARKET_MOD_BOOM "boom"
#define MARKET_MOD_SHORTAGE "shortage"
#define MARKET_MOD_INDUSTRIAL_DEMAND "industrial_demand"
#define MARKET_MOD_BLOCKADE "blockade"

#define MARKET_TRANS_BUY "buy"
#define MARKET_TRANS_SELL "sell"

/datum/trading_station
	var/live_market_enabled = TRUE
	var/list/live_market_state = list()
	var/list/live_market_modifiers = list()
	var/live_market_demand_decay = 0.6
	var/live_market_min_buy_multiplier = 0.75
	var/live_market_max_buy_multiplier = 1.8
	var/live_market_min_sell_multiplier = 0.45
	var/live_market_max_sell_multiplier = 1.35
	var/live_market_restock_discount = 0.5
	var/live_market_remote_quote_limit = 6
	var/live_market_auto_events = TRUE

/datum/trading_station/proc/OpenLiveMarketCategory(list/storage, category_name, autocreate = TRUE)
	if(!islist(storage) || !istext(category_name))
		return null
	if(!islist(storage[category_name]))
		if(!autocreate)
			return null
		storage[category_name] = list()
	return storage[category_name]

/datum/trading_station/proc/BuildLiveMarketCommodityTags(category_name, good_id)
	var/list/tags = list()
	if(istext(category_name))
		var/lower_category = lowertext(category_name)
		tags[lower_category] = TRUE
		if(findtext(lower_category, "material"))
			tags["materials"] = TRUE
			tags["industrial"] = TRUE
		if(findtext(lower_category, "medical"))
			tags["medical"] = TRUE
		if(findtext(lower_category, "science"))
			tags["science"] = TRUE
		if(findtext(lower_category, "service"))
			tags["consumer"] = TRUE
		if(findtext(lower_category, "engineering"))
			tags["industrial"] = TRUE
			tags["parts"] = TRUE

	var/item_path = GetGoodPath(category_name, good_id)
	if(ispath(item_path, /obj/item/stack/material))
		tags["materials"] = TRUE
		tags["industrial"] = TRUE
	if(ispath(item_path, /obj/item/reagent_containers/food))
		tags["food"] = TRUE
		tags["consumer"] = TRUE
	if(ispath(item_path, /obj/item/clothing))
		tags["consumer"] = TRUE
	if(ispath(item_path, /obj/item/reagent_containers) || ispath(item_path, /obj/item/stack/medical))
		tags["medical"] = TRUE
	if(ispath(item_path, /obj/item/device) || ispath(item_path, /obj/item/stock_parts))
		tags["parts"] = TRUE
		tags["industrial"] = TRUE
	if(!length(tags))
		tags["general"] = TRUE
	return tags

/datum/trading_station/proc/GetLiveMarketState(category_name, good_id, autocreate = FALSE)
	if(!live_market_enabled || !istext(category_name) || !good_id)
		return null
	var/list/category_state = OpenLiveMarketCategory(live_market_state, category_name, autocreate)
	if(!islist(category_state))
		return null
	var/list/commodity_state = category_state[good_id]
	if(islist(commodity_state) || !autocreate)
		return commodity_state
	var/base_price = max(1, round(SSsupply.GetBasicImportCost(good_id, src, category_name)))
	var/baseline_stock = max(1, round(GetGoodAmount(category_name, good_id)))
	commodity_state = list(
		"base_price" = base_price,
		"baseline_stock" = baseline_stock,
		"demand" = 0,
		"tags" = BuildLiveMarketCommodityTags(category_name, good_id),
		"remote_visible" = FALSE
	)
	category_state[good_id] = commodity_state
	return commodity_state

/datum/trading_station/proc/EnsureLiveMarketCommodity(category_name, good_id, base_price = null, baseline_stock = null)
	var/list/commodity_state = GetLiveMarketState(category_name, good_id, TRUE)
	if(!islist(commodity_state))
		return null
	if(isnum(base_price))
		commodity_state["base_price"] = max(1, round(base_price))
	else if(!isnum(commodity_state["base_price"]))
		commodity_state["base_price"] = max(1, round(SSsupply.GetBasicImportCost(good_id, src, category_name)))
	if(isnum(baseline_stock))
		commodity_state["baseline_stock"] = max(1, round(baseline_stock))
	else if(!isnum(commodity_state["baseline_stock"]))
		commodity_state["baseline_stock"] = max(1, round(GetGoodAmount(category_name, good_id)))
	if(!islist(commodity_state["tags"]))
		commodity_state["tags"] = BuildLiveMarketCommodityTags(category_name, good_id)
	if(!isnum(commodity_state["demand"]))
		commodity_state["demand"] = 0
	return commodity_state

/datum/trading_station/proc/RecordLiveMarketBaselines()
	if(!live_market_enabled)
		return
	for(var/category_name in inventory)
		var/list/category = inventory[category_name]
		if(!istext(category_name) || !islist(category))
			continue
		for(var/good_id in category)
			EnsureLiveMarketCommodity(category_name, good_id)

/datum/trading_station/proc/GetLiveMarketBasePrice(category_name, good_id)
	var/list/commodity_state = GetLiveMarketState(category_name, good_id, TRUE)
	if(islist(commodity_state) && isnum(commodity_state["base_price"]))
		return max(1, round(commodity_state["base_price"]))
	return max(1, round(SSsupply.GetBasicImportCost(good_id, src, category_name)))

/datum/trading_station/proc/GetLiveMarketBaseline(category_name, good_id)
	var/list/commodity_state = GetLiveMarketState(category_name, good_id, TRUE)
	if(islist(commodity_state) && isnum(commodity_state["baseline_stock"]))
		return max(1, round(commodity_state["baseline_stock"]))
	return max(1, round(GetGoodAmount(category_name, good_id)))

/datum/trading_station/proc/HasLiveMarketCommodity(category_name, good_id)
	return islist(GetLiveMarketState(category_name, good_id))

/datum/trading_station/proc/GetLiveMarketDemandScore(category_name, good_id)
	var/list/commodity_state = GetLiveMarketState(category_name, good_id)
	if(islist(commodity_state) && isnum(commodity_state["demand"]))
		return commodity_state["demand"]
	return 0

/datum/trading_station/proc/AdjustLiveMarketDemand(category_name, good_id, amount)
	if(!live_market_enabled || !istext(category_name) || !good_id || !isnum(amount))
		return
	var/list/commodity_state = EnsureLiveMarketCommodity(category_name, good_id)
	if(!islist(commodity_state))
		return
	var/baseline = max(1, GetLiveMarketBaseline(category_name, good_id))
	var/current = isnum(commodity_state["demand"]) ? commodity_state["demand"] : 0
	commodity_state["demand"] = clamp(current + (amount / baseline), -2, 2.5)

/datum/trading_station/proc/GetLiveMarketTagWeight(category_name, good_id, list/tag_weights, default_weight = 0)
	if(!islist(tag_weights))
		return default_weight
	var/weight = default_weight
	var/list/commodity_state = EnsureLiveMarketCommodity(category_name, good_id)
	var/list/tags = islist(commodity_state) ? commodity_state["tags"] : null
	if(!islist(tags))
		return weight
	if(isnum(tag_weights["*"]))
		weight = max(weight, tag_weights["*"])
	for(var/tag_name in tags)
		if(isnum(tag_weights[tag_name]))
			weight = max(weight, tag_weights[tag_name])
	return weight

/datum/trading_station/proc/CreateLiveMarketModifier(type, duration = null, list/target_tags = null)
	var/list/modifier = list(
		"id" = "[type]_[rand(1000, 9999)]",
		"type" = type,
		"name" = "Market Shift",
		"desc" = "Local market conditions changed.",
		"duration" = isnum(duration) ? max(1, round(duration)) : 4,
		"buy_shift" = 0,
		"sell_shift" = 0,
		"demand_shift" = 0,
		"stock_shift" = 0,
		"tone" = "average",
		"tag_weights" = islist(target_tags) ? target_tags.Copy() : list()
	)

	switch(type)
		if(MARKET_MOD_BOOM)
			modifier["name"] = "Economic Boom"
			modifier["desc"] = "Civilian demand is strong and the station is paying well for finished goods."
			modifier["buy_shift"] = -0.08
			modifier["sell_shift"] = 0.1
			modifier["demand_shift"] = -0.05
			modifier["stock_shift"] = 0.15
			modifier["tone"] = "good"
			if(!length(modifier["tag_weights"]))
				modifier["tag_weights"] = list("consumer" = 1, "food" = 0.8, "service" = 1, "general" = 0.4)
		if(MARKET_MOD_SHORTAGE)
			modifier["name"] = "Acute Shortage"
			modifier["desc"] = "Stocks are strained and the station is bidding aggressively for replacements."
			modifier["buy_shift"] = 0.18
			modifier["sell_shift"] = 0.24
			modifier["demand_shift"] = 0.22
			modifier["stock_shift"] = -0.2
			modifier["tone"] = "bad"
			if(!length(modifier["tag_weights"]))
				modifier["tag_weights"] = list("*" = 0.55)
		if(MARKET_MOD_INDUSTRIAL_DEMAND)
			modifier["name"] = "Industrial Demand"
			modifier["desc"] = "Manufacturing demand is spiking for parts and raw materials."
			modifier["buy_shift"] = 0.1
			modifier["sell_shift"] = 0.18
			modifier["demand_shift"] = 0.16
			modifier["stock_shift"] = -0.1
			modifier["tone"] = "average"
			if(!length(modifier["tag_weights"]))
				modifier["tag_weights"] = list("materials" = 1, "industrial" = 1, "parts" = 0.9)
		if(MARKET_MOD_BLOCKADE)
			modifier["name"] = "Shipping Blockade"
			modifier["desc"] = "Logistics disruption is tightening supply and pushing import prices up."
			modifier["buy_shift"] = 0.22
			modifier["sell_shift"] = 0.12
			modifier["demand_shift"] = 0.1
			modifier["stock_shift"] = -0.18
			modifier["tone"] = "bad"
			if(!length(modifier["tag_weights"]))
				modifier["tag_weights"] = list("*" = 0.8)
	return modifier

/datum/trading_station/proc/AddLiveMarketModifier(type, duration = null, list/target_tags = null)
	if(!live_market_enabled)
		return null
	var/list/modifier = CreateLiveMarketModifier(type, duration, target_tags)
	if(!islist(modifier))
		return null
	live_market_modifiers += list(modifier)
	return modifier

/datum/trading_station/proc/GetPrimaryLiveMarketModifier()
	if(!length(live_market_modifiers))
		return null
	for(var/list/modifier as anything in live_market_modifiers)
		if(islist(modifier))
			return modifier
	return null

/datum/trading_station/proc/GetLiveMarketEventPriceMultiplier(category_name, good_id, field_name)
	if(!live_market_enabled || !length(live_market_modifiers))
		return 1
	var/multiplier = 1
	for(var/list/modifier as anything in live_market_modifiers)
		if(!islist(modifier))
			continue
		var/shift = modifier[field_name]
		if(!isnum(shift) || !shift)
			continue
		var/weight = GetLiveMarketTagWeight(category_name, good_id, modifier["tag_weights"])
		if(!weight)
			continue
		multiplier *= 1 + (shift * weight)
	return max(0.1, multiplier)

/datum/trading_station/proc/GetLiveMarketStockPressure(category_name, good_id)
	var/baseline = max(1, GetLiveMarketBaseline(category_name, good_id))
	var/current = max(0, GetGoodAmount(category_name, good_id))
	if(current < baseline)
		return min((baseline - current) / baseline, 1)
	if(current > baseline)
		return -min((current - baseline) / baseline, 1)
	return 0

/datum/trading_station/proc/GetLiveMarketBuyMultiplier(category_name, good_id)
	if(!live_market_enabled)
		return 1
	var/pressure = GetLiveMarketStockPressure(category_name, good_id)
	var/demand_score = GetLiveMarketDemandScore(category_name, good_id)
	var/multiplier = 1
	if(pressure > 0)
		multiplier += min(pressure * 0.6, 0.45)
	else if(pressure < 0)
		multiplier -= min(abs(pressure) * 0.2, 0.15)
	if(demand_score > 0)
		multiplier += min(demand_score * 0.22, 0.32)
	else if(demand_score < 0)
		multiplier -= min(abs(demand_score) * 0.08, 0.12)
	multiplier *= GetLiveMarketEventPriceMultiplier(category_name, good_id, "buy_shift")
	return clamp(multiplier, live_market_min_buy_multiplier, live_market_max_buy_multiplier)

/datum/trading_station/proc/GetLiveMarketSellMultiplier(category_name, good_id)
	if(!live_market_enabled)
		return 1
	var/pressure = GetLiveMarketStockPressure(category_name, good_id)
	var/demand_score = GetLiveMarketDemandScore(category_name, good_id)
	var/multiplier = 0.62
	if(pressure > 0)
		multiplier += min(pressure * 0.35, 0.28)
	else if(pressure < 0)
		multiplier -= min(abs(pressure) * 0.18, 0.18)
	if(demand_score > 0)
		multiplier += min(demand_score * 0.18, 0.25)
	else if(demand_score < 0)
		multiplier -= min(abs(demand_score) * 0.12, 0.2)
	multiplier *= GetLiveMarketEventPriceMultiplier(category_name, good_id, "sell_shift")
	return clamp(multiplier, live_market_min_sell_multiplier, live_market_max_sell_multiplier)

/datum/trading_station/proc/DecayLiveMarketDemand()
	if(!live_market_enabled)
		return
	for(var/category_name in live_market_state)
		var/list/category_state = live_market_state[category_name]
		if(!islist(category_state))
			continue
		for(var/good_id in category_state)
			var/list/commodity_state = category_state[good_id]
			if(!islist(commodity_state) || !isnum(commodity_state["demand"]))
				continue
			commodity_state["demand"] *= live_market_demand_decay
			if(abs(commodity_state["demand"]) < 0.03)
				commodity_state["demand"] = 0

/datum/trading_station/proc/DecayLiveMarketModifiers()
	if(!length(live_market_modifiers))
		return
	for(var/list/modifier as anything in live_market_modifiers.Copy())
		if(!islist(modifier))
			live_market_modifiers -= modifier
			continue
		if(isnum(modifier["duration"]))
			modifier["duration"] = max(0, modifier["duration"] - 1)
		if(!modifier["duration"])
			live_market_modifiers -= list(modifier)

/datum/trading_station/proc/ApplyLiveMarketModifierStockEffects()
	if(!live_market_enabled || !length(live_market_modifiers))
		return
	for(var/list/modifier as anything in live_market_modifiers)
		if(!islist(modifier))
			continue
		var/stock_shift = modifier["stock_shift"]
		if(!isnum(stock_shift) || !stock_shift)
			continue
		for(var/category_name in inventory)
			var/list/category = inventory[category_name]
			if(!islist(category))
				continue
			for(var/good_id in category)
				var/weight = GetLiveMarketTagWeight(category_name, good_id, modifier["tag_weights"])
				if(!weight)
					continue
				if(stock_shift < 0 && prob(round(abs(stock_shift) * weight * 100)))
					var/current = GetGoodAmount(category_name, good_id)
					if(current > 1)
						SetGoodAmount(category_name, good_id, max(1, current - 1))
				else if(stock_shift > 0 && prob(round(stock_shift * weight * 100)))
					SetGoodAmount(category_name, good_id, GetGoodAmount(category_name, good_id) + 1)

/datum/trading_station/proc/EnsureLiveMarketActivity()
	if(!live_market_enabled || !live_market_auto_events || length(live_market_modifiers))
		return
	if(prob(35))
		AddLiveMarketModifier(pick(MARKET_MOD_BOOM, MARKET_MOD_SHORTAGE, MARKET_MOD_INDUSTRIAL_DEMAND, MARKET_MOD_BLOCKADE), rand(3, 6))

/datum/trading_station/proc/GetLiveMarketStatusLabel()
	var/list/modifier = GetPrimaryLiveMarketModifier()
	return islist(modifier) ? (modifier["name"] || "Stable Market") : "Stable Market"

/datum/trading_station/proc/GetLiveMarketStatusTone()
	var/list/modifier = GetPrimaryLiveMarketModifier()
	return islist(modifier) ? (modifier["tone"] || "good") : "good"

/datum/trading_station/proc/GetLiveMarketStatusDescription()
	var/list/modifier = GetPrimaryLiveMarketModifier()
	return islist(modifier) ? (modifier["desc"] || "Prices are following normal local conditions.") : "Prices are following normal local conditions."

/datum/trading_station/InitGoods()
	..()
	RecordLiveMarketBaselines()
	EnsureLiveMarketActivity()

/datum/trading_station/TryUnlockHiddenInv()
	..()
	RecordLiveMarketBaselines()

/datum/trading_station/GoodsTick()
	DecayLiveMarketDemand()
	DecayLiveMarketModifiers()
	EnsureLiveMarketActivity()
	ApplyLiveMarketModifierStockEffects()
	..()
	RecordLiveMarketBaselines()

/datum/trading_station/proc/DestroyLiveMarket()
	if(islist(live_market_modifiers))
		for(var/list/modifier as anything in live_market_modifiers)
			if(islist(modifier))
				modifier.Cut()
		live_market_modifiers.Cut()
		live_market_modifiers = null
	if(islist(live_market_state))
		for(var/category_name in live_market_state)
			var/list/cat_state = live_market_state[category_name]
			if(islist(cat_state))
				for(var/good_id in cat_state)
					var/list/comm_state = cat_state[good_id]
					if(islist(comm_state))
						var/list/tags = comm_state["tags"]
						if(islist(tags))
							tags.Cut()
						comm_state.Cut()
				cat_state.Cut()
		live_market_state.Cut()
		live_market_state = null

/datum/trading_station/Destroy()
	DestroyLiveMarket()
	return ..()

/datum/controller/subsystem/supply/proc/GetStationTradeBasePrice(good_ref, datum/trading_station/station, buyer_faction = null, category_name = null)
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

/datum/controller/subsystem/supply/proc/GetStationBuyPrice(good_ref, datum/trading_station/station, buyer_faction = null, category_name = null)
	var/base_price = GetStationTradeBasePrice(good_ref, station, buyer_faction, category_name)
	if(!base_price || !istype(station) || !istext(category_name) || !station.live_market_enabled || !station.HasLiveMarketCommodity(category_name, good_ref))
		return max(1, round(base_price))
	return max(1, round(base_price * station.GetLiveMarketBuyMultiplier(category_name, good_ref)))

/datum/controller/subsystem/supply/proc/GetStationSellPrice(good_ref, datum/trading_station/station, category_name = null)
	var/base_price = GetStationTradeBasePrice(good_ref, station, null, category_name)
	if(!base_price || !istype(station) || !istext(category_name) || !station.live_market_enabled || !station.HasLiveMarketCommodity(category_name, good_ref))
		return max(1, round(base_price * 0.55))
	return max(1, round(base_price * station.GetLiveMarketSellMultiplier(category_name, good_ref)))

/datum/controller/subsystem/supply/proc/GetStationRestockCost(good_ref, datum/trading_station/station, category_name = null)
	var/base_price = GetBasicImportCost(good_ref, station, category_name)
	if(!base_price || !istype(station) || !istext(category_name) || !station.live_market_enabled || !station.HasLiveMarketCommodity(category_name, good_ref))
		return max(1, round(base_price))
	var/base_market_price = station.GetLiveMarketBasePrice(category_name, good_ref)
	return max(1, round(base_market_price))

/datum/controller/subsystem/supply/proc/GetStationMarketQuote(datum/trading_station/station, category_name, good_id, buyer_faction = null)
	if(!istype(station) || !istext(category_name) || !good_id)
		return null
	return list(
		"station_uid" = station.uid,
		"category" = category_name,
		"good_id" = good_id,
		"buy_price" = round(GetStationBuyPrice(good_id, station, buyer_faction, category_name), 0.01),
		"sell_price" = round(GetStationSellPrice(good_id, station, category_name), 0.01),
		"stock" = max(0, station.GetGoodAmount(category_name, good_id))
	)

/datum/controller/subsystem/supply/proc/BuildMarketSnapshot(list/shop_list, buyer_faction = null)
	var/list/result = list()
	if(!islist(shop_list))
		return result
	for(var/datum/trading_station/station as anything in shop_list)
		var/list/categories = shop_list[station]
		if(!istype(station) || !islist(categories))
			continue
		var/list/station_snapshot = list(
			"station_uid" = station.uid,
			"timestamp" = world.time,
			"quality" = "quoted"
		)
		for(var/category_name in categories)
			var/list/goods = categories[category_name]
			if(!istext(category_name) || !islist(goods))
				continue
			var/list/category_snapshot = list()
			for(var/good_id in goods)
				category_snapshot[good_id] = list(
					"unit_price" = GetStationBuyPrice(good_id, station, buyer_faction, category_name),
					"station_uid" = station.uid,
					"amount" = goods[good_id],
					"timestamp" = world.time
				)
			if(length(category_snapshot))
				station_snapshot[category_name] = category_snapshot
		if(length(station_snapshot) > 3)
			result[station] = station_snapshot
	return result

/datum/controller/subsystem/supply/proc/GetSnapshotUnitPrice(list/price_snapshot, datum/trading_station/station, category_name, good_id)
	if(!islist(price_snapshot) || !istype(station) || !istext(category_name) || !good_id)
		return null
	var/list/station_snapshot = price_snapshot[station]
	if(!islist(station_snapshot))
		return null
	var/list/category_snapshot = station_snapshot[category_name]
	if(!islist(category_snapshot))
		return null
	var/value = category_snapshot[good_id]
	if(isnum(value))
		return value
	if(islist(value) && isnum(value["unit_price"]))
		return value["unit_price"]
	return null

/datum/controller/subsystem/supply/proc/ApplyTradeTransaction(datum/trading_station/station, category_name, good_id, amount, transaction_type)
	if(!istype(station) || !istext(category_name) || !good_id || !isnum(amount) || amount <= 0)
		return
	switch(transaction_type)
		if(MARKET_TRANS_BUY)
			station.AdjustLiveMarketDemand(category_name, good_id, amount)
		if(MARKET_TRANS_SELL)
			station.AdjustLiveMarketDemand(category_name, good_id, -amount)
			station.SetGoodAmount(category_name, good_id, station.GetGoodAmount(category_name, good_id) + amount)

/datum/controller/subsystem/supply/proc/TrackLiveMarketSales(list/shop_list)
	if(!islist(shop_list))
		return
	for(var/datum/trading_station/station as anything in shop_list)
		var/list/categories = shop_list[station]
		if(!istype(station) || !islist(categories))
			continue
		for(var/category_name in categories)
			var/list/goods = categories[category_name]
			if(!istext(category_name) || !islist(goods))
				continue
			for(var/good_id in goods)
				ApplyTradeTransaction(station, category_name, good_id, goods[good_id], MARKET_TRANS_BUY)

/datum/controller/subsystem/supply/proc/FindCommodityForExport(atom/movable/exported, datum/trading_station/station)
	if(!istype(exported) || !istype(station) || !islist(station.inventory))
		return null
	for(var/category_name in station.inventory)
		var/list/category = station.inventory[category_name]
		if(!islist(category))
			continue
		for(var/good_id in category)
			var/list/good_packet = category[good_id]
			if(!islist(good_packet))
				continue
			var/item_path = good_packet["item_path"]
			if(!ispath(item_path, /atom/movable))
				continue
			if(istype(exported, item_path))
				var/export_amount = 1
				if(isstack(exported))
					var/obj/item/stack/S = exported
					export_amount = S.get_amount()
				return list(
					"category" = category_name,
					"good_id" = good_id,
					"amount" = export_amount
				)
	return null


/datum/controller/subsystem/supply/proc/BuildStationMarketIntel(datum/trading_station/station, buyer_faction = null)
	if(!istype(station))
		return null
	var/list/quotes = list()
	for(var/category_name in station.inventory)
		var/list/category = station.inventory[category_name]
		if(!islist(category))
			continue
		for(var/good_id in category)
			quotes += list(list(
				"category" = category_name,
				"good_id" = good_id,
				"name" = station.GetGoodName(category_name, good_id),
				"buy_price" = round(GetStationBuyPrice(good_id, station, buyer_faction, category_name), 0.01),
				"sell_price" = round(GetStationSellPrice(good_id, station, category_name), 0.01),
				"stock" = station.GetGoodAmount(category_name, good_id)
			))
			if(length(quotes) >= station.live_market_remote_quote_limit)
				break
		if(length(quotes) >= station.live_market_remote_quote_limit)
			break
	return list(
		"station_uid" = station.uid,
		"station_name" = station.name,
		"status_label" = station.GetLiveMarketStatusLabel(),
		"status_tone" = station.GetLiveMarketStatusTone(),
		"status_desc" = station.GetLiveMarketStatusDescription(),
		"timestamp" = world.time,
		"quality" = "detailed",
		"quotes" = quotes
	)

/datum/controller/subsystem/supply/GetImportCost(good_ref, datum/trading_station/station, buyer_faction = null, category_name = null)
	return GetStationBuyPrice(good_ref, station, buyer_faction, category_name)

/datum/controller/subsystem/supply/BuildOrder(requesting_account, reason, list/shopping_list, buyer_faction = null)
	. = ..(requesting_account, reason, shopping_list, buyer_faction)
	if(!. || !(. in order_queue))
		return
	var/list/order_data = order_queue[.]
	if(islist(order_data))
		order_data["price_snapshot"] = BuildMarketSnapshot(shopping_list, buyer_faction)

#undef MARKET_MOD_BOOM
#undef MARKET_MOD_SHORTAGE
#undef MARKET_MOD_INDUSTRIAL_DEMAND
#undef MARKET_MOD_BLOCKADE

#undef MARKET_TRANS_BUY
#undef MARKET_TRANS_SELL

