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

/datum/trading_station/proc/OpenLiveMarketCategory(list/storage, category_name)
	if(!islist(storage) || !istext(category_name))
		return null
	if(!islist(storage[category_name]))
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
	var/list/category_state = OpenLiveMarketCategory(live_market_state, category_name)
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
		if("boom")
			modifier["name"] = "Economic Boom"
			modifier["desc"] = "Civilian demand is strong and the station is paying well for finished goods."
			modifier["buy_shift"] = -0.08
			modifier["sell_shift"] = 0.1
			modifier["demand_shift"] = -0.05
			modifier["stock_shift"] = 0.15
			modifier["tone"] = "good"
			if(!length(modifier["tag_weights"]))
				modifier["tag_weights"] = list("consumer" = 1, "food" = 0.8, "service" = 1, "general" = 0.4)
		if("shortage")
			modifier["name"] = "Acute Shortage"
			modifier["desc"] = "Stocks are strained and the station is bidding aggressively for replacements."
			modifier["buy_shift"] = 0.18
			modifier["sell_shift"] = 0.24
			modifier["demand_shift"] = 0.22
			modifier["stock_shift"] = -0.2
			modifier["tone"] = "bad"
			if(!length(modifier["tag_weights"]))
				modifier["tag_weights"] = list("*" = 0.55)
		if("industrial_demand")
			modifier["name"] = "Industrial Demand"
			modifier["desc"] = "Manufacturing demand is spiking for parts and raw materials."
			modifier["buy_shift"] = 0.1
			modifier["sell_shift"] = 0.18
			modifier["demand_shift"] = 0.16
			modifier["stock_shift"] = -0.1
			modifier["tone"] = "average"
			if(!length(modifier["tag_weights"]))
				modifier["tag_weights"] = list("materials" = 1, "industrial" = 1, "parts" = 0.9)
		if("blockade")
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
			live_market_modifiers -= modifier

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
		AddLiveMarketModifier(pick("boom", "shortage", "industrial_demand", "blockade"), rand(3, 6))

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
	for(var/category_name in inventory)
		var/list/category = inventory[category_name]
		if(!islist(category))
			continue
		for(var/good_id in category)
			var/cost = SSsupply.GetStationRestockCost(good_id, src, category_name)
			var/list/rand_args = list(5, max(5, round(30 / max(cost / 200, 1))))
			var/list/good_packet = category[good_id]
			if(islist(good_packet) && islist(good_packet["amount_range"]))
				rand_args = good_packet["amount_range"]
			if(!islist(amounts_of_goods[category_name]))
				amounts_of_goods[category_name] = list()
			var/list/content = amounts_of_goods[category_name]
			content[good_id] = max(0, rand(rand_args[1], rand_args[2]))
			unique_good_count += 1
	RecordLiveMarketBaselines()
	EnsureLiveMarketActivity()

/datum/trading_station/TryUnlockHiddenInv()
	if(favor < unlock_favor || hidden_inv_unlocked)
		return

	hidden_inv_unlocked = TRUE
	for(var/category_name in hidden_inventory)
		var/list/category = hidden_inventory[category_name]
		if(!istext(category_name) || !islist(category))
			continue
		if(!(category_name in inventory))
			inventory[category_name] = list()
		var/list/visible_category = inventory[category_name]
		for(var/good_id in category)
			visible_category[good_id] = category[good_id]
			var/cost = SSsupply.GetStationRestockCost(good_id, src, category_name)
			var/list/rand_args = list(1, max(1, round(30 / max(cost / 200, 1))))
			var/list/good_packet = category[good_id]
			if(islist(good_packet) && islist(good_packet["amount_range"]))
				rand_args = good_packet["amount_range"]
			if(!islist(amounts_of_goods[category_name]))
				amounts_of_goods[category_name] = list()
			var/list/content = amounts_of_goods[category_name]
			content[good_id] = max(0, rand(rand_args[1], rand_args[2]))
			unique_good_count += 1
	RecordLiveMarketBaselines()

/datum/trading_station/GoodsTick()
	DecayLiveMarketDemand()
	DecayLiveMarketModifiers()
	EnsureLiveMarketActivity()
	ApplyLiveMarketModifierStockEffects()

	wealth += base_income

	var/starting_balance = wealth
	var/budget = unique_good_count ? round(starting_balance / unique_good_count) : 0
	var/list/restock_candidates = list()

	for(var/category_name in inventory)
		var/list/category = inventory[category_name]
		for(var/good_id in category)
			var/good_index = category.Find(good_id)
			var/current_amount = GetGoodAmount(category_name, good_index)
			var/chance_to_restock = current_amount < 5 ? 100 : current_amount > 20 ? 0 : 15
			if(rand(1, 100) > chance_to_restock)
				continue
			var/cost = max(1, round(SSsupply.GetStationRestockCost(good_id, src, category_name) / 2))
			var/amount_to_add = budget ? max(1, rand(1, max(1, round(budget / cost)))) : 1
			var/list/content = list(
				"cat" = category_name,
				"index" = good_index,
				"cost" = cost,
				"to_add" = amount_to_add,
				"current_amt" = current_amount
			)
			var/restock_index = restock_candidates.len + 1
			restock_candidates.Insert(restock_index, restock_index)
			restock_candidates[restock_index] = content

	for(var/i in 1 to 20)
		if(!restock_candidates.len || !wealth)
			break

		var/list/good_packet = pick(restock_candidates)
		var/candidate_index = restock_candidates.Find(good_packet)
		var/total_cost = good_packet["cost"] * good_packet["to_add"]
		restock_candidates.Cut(candidate_index, candidate_index + 1)

		if(total_cost < wealth)
			SetGoodAmount(good_packet["cat"], good_packet["index"], good_packet["to_add"] + good_packet["current_amt"])
			SubtractFromWealth(total_cost)

	TryUnlockHiddenInv()
	RecordLiveMarketBaselines()

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
		return base_price
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
		"buy_price" = GetStationBuyPrice(good_id, station, buyer_faction, category_name),
		"sell_price" = GetStationSellPrice(good_id, station, category_name),
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
		if("buy")
			station.AdjustLiveMarketDemand(category_name, good_id, amount)
		if("sell")
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
				ApplyTradeTransaction(station, category_name, good_id, goods[good_id], "buy")

/datum/controller/subsystem/supply/proc/FindCommodityForExport(atom/movable/exported, datum/trading_station/station)
	if(!istype(exported) || !istype(station))
		return null
	for(var/category_name in station.inventory)
		var/list/category = station.inventory[category_name]
		if(!islist(category))
			continue
		for(var/good_id in category)
			var/item_path = station.GetGoodPath(category_name, good_id)
			if(!ispath(item_path, /atom/movable))
				continue
			if(istype(exported, item_path))
				return list(
					"category" = category_name,
					"good_id" = good_id,
					"amount" = 1
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
				"buy_price" = GetStationBuyPrice(good_id, station, buyer_faction, category_name),
				"sell_price" = GetStationSellPrice(good_id, station, category_name),
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

/datum/controller/subsystem/supply/CollectPriceForCategory(list/category, datum/trading_station/station, buyer_faction = null, category_name = null)
	. = 0
	if(!islist(category) || !istype(station) || !istext(category_name))
		return
	for(var/good_id in category)
		. += GetStationBuyPrice(good_id, station, buyer_faction, category_name) * category[good_id]

/datum/controller/subsystem/supply/BuildOrder(requesting_account, reason, list/shopping_list, buyer_faction = null)
	. = ..(requesting_account, reason, shopping_list, buyer_faction)
	if(!. || !(. in order_queue))
		return
	var/list/order_data = order_queue[.]
	if(islist(order_data))
		order_data["price_snapshot"] = BuildMarketSnapshot(shopping_list, buyer_faction)

/datum/controller/subsystem/supply/PurchaseOrder(obj/machinery/trade_beacon/receiving/beacon, order_id)
	if(QDELETED(beacon) || !order_id || !(order_id in order_queue))
		return FALSE

	var/list/order = order_queue[order_id]
	var/list/price_snapshot = islist(order) ? order["price_snapshot"] : null
	if(!islist(price_snapshot))
		return ..(beacon, order_id)

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
	if(!Buy(beacon, master_account, shopping_list, !is_requestor_master, requesting_account.owner_name, buyer_faction, price_snapshot))
		return FALSE
	if(!is_requestor_master)
		requesting_account.transfer(master_account, total_cost, "Trade Network Order")
	CreateLogEntry("Order", requesting_account.owner_name, viewable_contents, total_cost)
	return TRUE

/datum/controller/subsystem/supply/Buy(obj/machinery/trade_beacon/receiving/receiver_beacon, datum/money_account/account, list/shop_list, is_order = FALSE, buyer_name = null, buyer_faction = null, list/price_snapshot = null)
	if(!islist(price_snapshot))
		. = ..(receiver_beacon, account, shop_list, is_order, buyer_name, buyer_faction)
		if(.)
			TrackLiveMarketSales(shop_list)
		return

	if(QDELETED(receiver_beacon) || !istype(receiver_beacon) || !account || !islist(shop_list) || !length(shop_list))
		return FALSE

	var/count_of_all = CollectCountsFrom(shop_list)
	if(!count_of_all)
		return FALSE

	var/price_for_all = 0
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
				var/unit_price = GetSnapshotUnitPrice(price_snapshot, station, category_name, good_id)
				if(!isnum(unit_price) || unit_price < 1)
					return FALSE
				price_for_all += unit_price * count_of_good

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
			if(!islist(goods) || !islist(station.inventory[category_name]))
				continue
			for(var/good_id in goods)
				var/count_of_good = goods[good_id]
				var/good_path = station.GetGoodPath(category_name, good_id)
				var/unit_price = GetSnapshotUnitPrice(price_snapshot, station, category_name, good_id)
				if(!good_path || !isnum(unit_price) || unit_price < 1)
					return FALSE
				to_station_wealth += unit_price * count_of_good
				for(var/i in 1 to count_of_good)
					if(istype(locker))
						new good_path(locker)
						invoice_location = locker
					else
						var/atom/movable/new_item = receiver_beacon.DropItem(good_path)
						invoice_location = new_item ? new_item.loc : null
				station.SetGoodAmount(category_name, good_id, max(0, station.GetGoodAmount(category_name, good_id) - count_of_good))
				ApplyTradeTransaction(station, category_name, good_id, count_of_good, "buy")
				var/item_name = station.GetGoodName(category_name, good_id)
				order_contents_info += "<li>[count_of_good]x [item_name]</li>"
		station.AddToWealth(to_station_wealth)

	if(count_of_all > 1)
		invoice_location = locker

	CreateLogEntry("Shipping", is_order && buyer_name ? buyer_name : account.owner_name, order_contents_info, price_for_all, TRUE, invoice_location)
	account.withdraw(price_for_all, "Trade Network Purchase", "Trade Network")
	return TRUE

/datum/controller/subsystem/supply/Export(obj/machinery/trade_beacon/sending/sender_beacon, datum/money_account/money_account, datum/trading_station/target_station = null)
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

		var/export_value = GetExportValue(exported, target_station)
		if(!export_value)
			continue

		exportables[exported] = export_value

	if(!length(exportables))
		return FALSE
	if(istype(target_station))
		var/block_reason = GetTradeRangeBlockReason(sender_beacon, target_station)
		if(block_reason)
			return FALSE
	if(!sender_beacon.StartExport())
		return FALSE

	for(var/atom/movable/exported as anything in exportables)
		var/export_value = exportables[exported]
		invoice_contents_info += "<li>[exported.name]</li>"
		cost += export_value
		if(istype(target_station))
			var/list/match = FindCommodityForExport(exported, target_station)
			if(islist(match))
				ApplyTradeTransaction(target_station, match["category"], match["good_id"], match["amount"], "sell")
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
