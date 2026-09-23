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
	var/live_market_demand_decay = 0.85
	var/live_market_min_buy_multiplier = 0.8
	var/live_market_max_buy_multiplier = 1.75
	var/live_market_min_sell_multiplier = 0.35
	var/live_market_max_sell_multiplier = 1.15
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
	var/base_price = max(1, round(SSsupply.GetStationRestockCost(good_id, src, category_name)))
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
		commodity_state["base_price"] = max(1, round(SSsupply.GetStationRestockCost(good_id, src, category_name)))
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
	return max(1, round(SSsupply.GetStationRestockCost(good_id, src, category_name)))

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
		AddLiveMarketModifier(pick(MARKET_MOD_BOOM, MARKET_MOD_SHORTAGE, MARKET_MOD_INDUSTRIAL_DEMAND, MARKET_MOD_BLOCKADE), rand(3, 5))

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

/datum/controller/subsystem/supply/proc/GetStationBuyPrice(good_ref, datum/trading_station/station, buyer_faction = null, category_name = null)
	var/base_price = GetStationTradeBasePrice(good_ref, station, buyer_faction, category_name)
	if(!base_price || !istype(station) || !istext(category_name) || !station.live_market_enabled || !station.HasLiveMarketCommodity(category_name, good_ref))
		return max(1, round(base_price))
	return max(1, round(base_price * station.GetLiveMarketBuyMultiplier(category_name, good_ref)))

/datum/controller/subsystem/supply/proc/GetStationTradeRelationMultiplier(datum/trading_station/station, seller_faction = null)
	if(!istype(station) || !seller_faction)
		return 1
	var/datum/trade_faction/station_faction = GetFaction(station.faction)
	if(!istype(station_faction))
		return 1

	var/seller_name = seller_faction
	if(istype(seller_faction, /datum/trade_faction))
		var/datum/trade_faction/F = seller_faction
		seller_name = F.name
	else if(!istext(seller_name))
		return 1

	if(islist(station_faction.embargo) && (seller_name in station_faction.embargo))
		return 0
	if(length(station.blacklist_factions) && (seller_name in station.blacklist_factions))
		return 0
	if(length(station.whitelist_factions) && !(seller_name in station.whitelist_factions))
		return 0

	var/rel = station_faction.relationship[seller_name]
	if(isnull(rel))
		var/datum/trade_faction/seller_datum = GetFaction(seller_name)
		if(istype(seller_datum) && isnum(station_faction.relationship[seller_datum.name]))
			rel = station_faction.relationship[seller_datum.name]
		else
			rel = FACTION_STATE_NEUTRAL

	var/multiplier = 1
	switch(rel)
		if(FACTION_STATE_WAR)
			return 0
		if(FACTION_STATE_ENEMY)
			multiplier = 0.5
		if(FACTION_STATE_RIVAL)
			multiplier = 0.7
		if(FACTION_STATE_ANIMOSITY)
			multiplier = 0.85
		if(FACTION_STATE_NEUTRAL)
			multiplier = 0.95
		if(FACTION_STATE_WELCOMING)
			multiplier = 1.05
		if(FACTION_STATE_FRIEND)
			multiplier = 1.1
		if(FACTION_STATE_ALLY)
			multiplier = 1.2
		if(FACTION_STATE_PROTECTORATE)
			multiplier = 1.25

	if(seller_name in station_faction.trade_markup)
		var/markup = station_faction.trade_markup[seller_name]
		if(isnum(markup) && markup > 1)
			multiplier /= markup

	return multiplier

/datum/controller/subsystem/supply/proc/GetStationSellPrice(good_ref, datum/trading_station/station, seller_faction = null, category_name = null, amount = 1, sold_offset = 0)
	if(istype(station) && istext(seller_faction) && isnull(category_name))
		if(seller_faction in station.inventory)
			category_name = seller_faction
			seller_faction = null

	if(!isnum(amount) || amount <= 0)
		return 0

	var/base_price = GetStationTradeBasePrice(good_ref, station, null, category_name)
	if(!base_price || !istype(station))
		return 0

	var/faction_mult = GetStationTradeRelationMultiplier(station, seller_faction)
	if(!faction_mult)
		return 0

	if(!station.live_market_enabled)
		return max(1, round(base_price * faction_mult * amount))

	if(!istext(category_name) || !station.HasLiveMarketCommodity(category_name, good_ref))
		return max(1, round(base_price * 0.55 * faction_mult * amount))

	var/baseline = max(1, station.GetLiveMarketBaseline(category_name, good_ref))
	var/initial_stock = max(0, station.GetGoodAmount(category_name, good_ref))
	var/initial_demand = station.GetLiveMarketDemandScore(category_name, good_ref)
	var/event_mult = station.GetLiveMarketEventPriceMultiplier(category_name, good_ref, "sell_shift")
	var/buy_price_cap = round(GetStationBuyPrice(good_ref, station, seller_faction, category_name) * 0.9)

	var/total_price = 0
	if(amount <= 50)
		var/full_units = floor(amount)
		var/fraction = amount - full_units
		if(full_units > 0)
			for(var/k in 1 to full_units)
				var/units_sold_before = (k - 1) + sold_offset
				var/sim_stock = initial_stock + units_sold_before
				var/sim_demand = clamp(initial_demand - (units_sold_before / baseline), -2, 2.5)

				var/sim_pressure = 0
				if(sim_stock < baseline)
					sim_pressure = min((baseline - sim_stock) / baseline, 1)
				else if(sim_stock > baseline)
					sim_pressure = -min((sim_stock - baseline) / baseline, 1)

				var/unit_mult = 0.62
				if(sim_pressure > 0)
					unit_mult += min(sim_pressure * 0.35, 0.28)
				else if(sim_pressure < 0)
					unit_mult -= min(abs(sim_pressure) * 0.18, 0.18)

				if(sim_demand > 0)
					unit_mult += min(sim_demand * 0.18, 0.25)
				else if(sim_demand < 0)
					unit_mult -= min(abs(sim_demand) * 0.12, 0.2)

				unit_mult *= event_mult
				unit_mult = clamp(unit_mult, station.live_market_min_sell_multiplier, station.live_market_max_sell_multiplier)

				var/unit_price = max(1, round(base_price * unit_mult * faction_mult))
				if(buy_price_cap > 0)
					unit_price = min(unit_price, buy_price_cap)
				total_price += unit_price

				if(unit_mult <= station.live_market_min_sell_multiplier)
					var/remaining = full_units - k
					if(remaining > 0)
						total_price += remaining * unit_price
					fraction = 0
					break

		if(fraction > 0)
			var/units_sold_before = full_units + sold_offset
			var/sim_stock = initial_stock + units_sold_before
			var/sim_demand = clamp(initial_demand - (units_sold_before / baseline), -2, 2.5)

			var/sim_pressure = 0
			if(sim_stock < baseline)
				sim_pressure = min((baseline - sim_stock) / baseline, 1)
			else if(sim_stock > baseline)
				sim_pressure = -min((sim_stock - baseline) / baseline, 1)

			var/unit_mult = 0.62
			if(sim_pressure > 0)
				unit_mult += min(sim_pressure * 0.35, 0.28)
			else if(sim_pressure < 0)
				unit_mult -= min(abs(sim_pressure) * 0.18, 0.18)

			if(sim_demand > 0)
				unit_mult += min(sim_demand * 0.18, 0.25)
			else if(sim_demand < 0)
				unit_mult -= min(abs(sim_demand) * 0.12, 0.2)

			unit_mult *= event_mult
			unit_mult = clamp(unit_mult, station.live_market_min_sell_multiplier, station.live_market_max_sell_multiplier)

			var/unit_price = max(1, round(base_price * unit_mult * faction_mult))
			if(buy_price_cap > 0)
				unit_price = min(unit_price, buy_price_cap)
			total_price += max(1, round(unit_price * fraction))
	else
		var/buckets = 25
		var/bucket_size = amount / buckets
		for(var/b in 1 to buckets)
			var/units_sold_before = ((b - 0.5) * bucket_size) + sold_offset
			var/sim_stock = initial_stock + units_sold_before
			var/sim_demand = clamp(initial_demand - (units_sold_before / baseline), -2, 2.5)

			var/sim_pressure = 0
			if(sim_stock < baseline)
				sim_pressure = min((baseline - sim_stock) / baseline, 1)
			else if(sim_stock > baseline)
				sim_pressure = -min((sim_stock - baseline) / baseline, 1)

			var/unit_mult = 0.62
			if(sim_pressure > 0)
				unit_mult += min(sim_pressure * 0.35, 0.28)
			else if(sim_pressure < 0)
				unit_mult -= min(abs(sim_pressure) * 0.18, 0.18)

			if(sim_demand > 0)
				unit_mult += min(sim_demand * 0.18, 0.25)
			else if(sim_demand < 0)
				unit_mult -= min(abs(sim_demand) * 0.12, 0.2)

			unit_mult *= event_mult
			unit_mult = clamp(unit_mult, station.live_market_min_sell_multiplier, station.live_market_max_sell_multiplier)

			var/unit_price = max(1, round(base_price * unit_mult * faction_mult))
			if(buy_price_cap > 0)
				unit_price = min(unit_price, buy_price_cap)

			if(unit_mult <= station.live_market_min_sell_multiplier)
				var/remaining_buckets = buckets - b + 1
				total_price += round(remaining_buckets * bucket_size * unit_price)
				break

			total_price += round(bucket_size * unit_price)

	return max(1, round(total_price))

/datum/controller/subsystem/supply/proc/GetStationRestockCost(good_ref, datum/trading_station/station, category_name = null)
	if(!istype(station))
		return 1
	var/datum/trade_offer/offer = station.GetOffer(good_ref)
	var/cat = category_name || (offer ? offer.category : null)
	if(istext(cat) && station.live_market_enabled && station.HasLiveMarketCommodity(cat, good_ref))
		var/base_market_price = station.GetLiveMarketBasePrice(cat, good_ref)
		if(base_market_price > 0)
			return max(1, round(base_market_price))
	if(istype(offer))
		return max(1, round(offer.base_price))
	var/price = station.GetGoodPrice(cat, good_ref)
	if(price > 0)
		return max(1, round(price))
	var/item_path = station.GetGoodPath(cat, good_ref)
	if(ispath(item_path))
		var/raw_val = get_value(item_path)
		return max(1, round(raw_val))
	return 1

/datum/controller/subsystem/supply/proc/GetStationMarketQuote(datum/trading_station/station, category_name, good_id, buyer_faction = null)
	if(!istype(station) || !istext(category_name) || !good_id)
		return null
	return list(
		"station_uid" = station.uid,
		"category" = category_name,
		"good_id" = good_id,
		"buy_price" = round(GetStationBuyPrice(good_id, station, buyer_faction, category_name), 0.01),
		"sell_price" = round(GetStationSellPrice(good_id, station, buyer_faction, category_name), 0.01),
		"stock" = max(0, station.GetGoodAmount(category_name, good_id))
	)

/datum/controller/subsystem/supply/proc/SnapshotCartItem(list/result, list/item, buyer_faction)
	var/datum/trading_station/station = item["station"]
	var/datum/trade_offer/offer = item["offer"] || station.GetOffer(item["good_id"])
	var/cat = item["cat"] || (offer ? offer.category : null)
	var/gid = offer ? offer.id : item["good_id"]
	var/unit_price = GetStationBuyPrice(gid, station, buyer_faction, cat)
	var/list/packet = list("unit_price" = unit_price, "station_uid" = station.uid, "amount" = item["count"], "timestamp" = world.time)
	var/list/snap = result[station]
	if(!islist(snap))
		snap = list("station_uid" = station.uid, "timestamp" = world.time, "quality" = "quoted")
		result[station] = snap
		if(station.uid)
			result["[station.uid]"] = snap
	snap[gid] = packet
	if(istext(cat))
		var/list/cat_snap = snap[cat] || list()
		cat_snap[gid] = packet
		snap[cat] = cat_snap

/datum/controller/subsystem/supply/proc/BuildMarketSnapshot(list/shop_list, buyer_faction = null)
	var/list/result = list()
	if(!islist(shop_list) || !length(shop_list))
		return result
	for(var/list/item as anything in ExtractCartItems(shop_list))
		SnapshotCartItem(result, item, buyer_faction)
	return result

/datum/controller/subsystem/supply/proc/GetSnapshotUnitPrice(list/price_snapshot, datum/trading_station/station, category_name, good_id)
	if(!islist(price_snapshot) || !istype(station) || !good_id)
		return null
	var/list/station_snapshot = price_snapshot[station]
	if(!islist(station_snapshot) && istext(station.uid))
		station_snapshot = price_snapshot["[station.uid]"]
	if(!islist(station_snapshot))
		return null
	var/value = station_snapshot[good_id]
	if(isnull(value) && istext(category_name) && islist(station_snapshot[category_name]))
		var/list/category_snapshot = station_snapshot[category_name]
		value = category_snapshot[good_id]
	if(isnum(value))
		return value
	if(islist(value) && isnum(value["unit_price"]))
		return value["unit_price"]
	return null

/datum/controller/subsystem/supply/proc/ApplyTradeTransaction(datum/trading_station/station, category_name, good_id, amount, mode, faction = null)
	if(!istype(station) || !istext(category_name) || !good_id || !isnum(amount) || amount <= 0)
		return
	if(!station.live_market_enabled || !station.HasLiveMarketCommodity(category_name, good_id))
		return

	switch(mode)
		if(MARKET_TRANS_BUY)
			station.AdjustLiveMarketDemand(category_name, good_id, amount)
		if(MARKET_TRANS_SELL)
			station.AdjustLiveMarketDemand(category_name, good_id, -amount)
			station.SetGoodAmount(category_name, good_id, station.GetGoodAmount(category_name, good_id) + amount)

/datum/controller/subsystem/supply/proc/TrackLiveMarketSales(list/shop_list, buyer_faction = null)
	if(!islist(shop_list))
		return
	for(var/list/item as anything in ExtractCartItems(shop_list))
		var/datum/trading_station/station = item["station"]
		var/datum/trade_offer/offer = item["offer"] || station.GetOffer(item["good_id"])
		var/cat = item["cat"] || (offer ? offer.category : null)
		var/gid = offer ? offer.id : item["good_id"]
		ApplyTradeTransaction(station, cat, gid, item["count"], MARKET_TRANS_BUY, buyer_faction)

/datum/controller/subsystem/supply/proc/GetExportStackAmount(atom/movable/exported)
	if(isstack(exported))
		var/obj/item/stack/S = exported
		return S.get_amount()
	return 1

/datum/controller/subsystem/supply/proc/FindLegacyCommodityForExport(atom/movable/exported, datum/trading_station/station)
	if(!islist(station.inventory))
		return null
	var/target_mat = null
	if(istype(exported, /obj/item/stack/material))
		var/obj/item/stack/material/mat_stack = exported
		target_mat = mat_stack.material ? mat_stack.material.name : mat_stack.default_type

	for(var/cat_name in station.inventory)
		var/list/cat = station.inventory[cat_name]
		if(!islist(cat))
			continue
		for(var/good_id in cat)
			var/item_path = station.GetGoodPath(cat_name, good_id)
			if(!item_path)
				continue
			var/matched = FALSE
			if(istype(exported, item_path))
				matched = TRUE
			else if(target_mat && ispath(item_path, /obj/item/stack/material))
				var/obj/item/stack/material/dummy = item_path
				if(initial(dummy.default_type) == target_mat)
					matched = TRUE
			if(matched)
				var/pack_size = 1
				if(ispath(item_path, /obj/item/stack))
					var/obj/item/stack/S = item_path
					pack_size = max(1, initial(S.amount))
				var/packages = GetExportStackAmount(exported) / pack_size
				return list("category" = cat_name, "good_id" = good_id, "amount" = packages)
	return null

/datum/controller/subsystem/supply/proc/FindCommodityForExport(atom/movable/exported, datum/trading_station/station)
	if(!istype(exported) || !istype(station))
		return null
	var/datum/trade_offer/offer = station.GetOfferByPath(exported.type)
	if(!offer && istype(exported, /obj/item/stack/material))
		var/obj/item/stack/material/mat_stack = exported
		var/target_mat = mat_stack.material ? mat_stack.material.name : mat_stack.default_type
		if(target_mat && islist(station.offers))
			for(var/id in station.offers)
				var/datum/trade_offer/candidate = station.offers[id]
				if(!istype(candidate) || !ispath(candidate.item_path, /obj/item/stack/material))
					continue
				var/obj/item/stack/material/dummy = candidate.item_path
				var/offer_mat = initial(dummy.default_type)
				if(offer_mat == target_mat)
					offer = candidate
					break
	if(offer)
		var/pack_size = offer.pack_size || 1
		var/packages = GetExportStackAmount(exported) / pack_size
		return list("category" = offer.category, "good_id" = offer.id, "amount" = packages)
	return FindLegacyCommodityForExport(exported, station)


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
				"sell_price" = round(GetStationSellPrice(good_id, station, buyer_faction, category_name), 0.01),
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

/datum/controller/subsystem/supply/proc/GetSnapshotTotalCost(list/snapshot, list/shop_list, buyer_faction = null)
	. = 0
	if(!islist(shop_list))
		return
	for(var/list/item as anything in ExtractCartItems(shop_list))
		var/datum/trading_station/station = item["station"]
		var/gid = item["good_id"]
		var/cat = item["cat"]
		var/count = item["count"]
		var/unit_price = null
		if(islist(snapshot))
			unit_price = GetSnapshotUnitPrice(snapshot, station, cat, gid)
		if(isnull(unit_price))
			unit_price = GetImportCost(gid, station, buyer_faction, cat)
		. += unit_price * count

/datum/controller/subsystem/supply/BuildOrder(requesting_account, reason, list/shopping_list, buyer_faction = null)
	. = ..(requesting_account, reason, shopping_list, buyer_faction)
	if(!. || !(. in order_queue))
		return
	var/list/order_data = order_queue[.]
	if(islist(order_data))
		var/list/snapshot = BuildMarketSnapshot(shopping_list, buyer_faction)
		order_data["price_snapshot"] = snapshot
		var/snapshot_cost = GetSnapshotTotalCost(snapshot, shopping_list, buyer_faction)
		order_data["cost"] = snapshot_cost
		var/datum/money_account/master_account = get_supply_department_account()
		var/is_requestor_master = master_account && (requesting_account == master_account)
		order_data["fee"] = is_requestor_master ? 0 : round(snapshot_cost * handling_fee, 0.01)

#undef MARKET_MOD_BOOM
#undef MARKET_MOD_SHORTAGE
#undef MARKET_MOD_INDUSTRIAL_DEMAND
#undef MARKET_MOD_BLOCKADE

#undef MARKET_TRANS_BUY
#undef MARKET_TRANS_SELL

