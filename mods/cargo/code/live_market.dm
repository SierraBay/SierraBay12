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

	var/static/list/live_market_category_tag_rules = list(
		"material" = list("materials", "industrial"),
		"medical" = list("medical"),
		"medkit" = list("medical", "medkits"),
		"medical kit" = list("medkits"),
		"surgery" = list("medical"),
		"science" = list("science"),
		"research" = list("science"),
		"component" = list("components"),
		"service" = list("consumer"),
		"janitor" = list("consumer"),
		"leisure" = list("consumer"),
		"engineering" = list("industrial", "parts", "tools"),
		"tool" = list("industrial", "parts", "tools"),
		"power" = list("power", "industrial"),
		"food" = list("food", "consumer"),
		"botany" = list("food", "consumer"),
		"cloth" = list("clothing", "consumer"),
		"chem" = list("chemical", "medical"),
		"munit" = list("munitions", "industrial"),
		"ammo" = list("munitions", "industrial"),
		"weapon" = list("weaponry", "security"),
		"secur" = list("security"),
		"armor" = list("security"),
		"atmos" = list("atmospherics", "industrial"),
		"gas" = list("atmospherics", "industrial"),
		"eva" = list("eva", "consumer"),
		"voidsuit" = list("eva", "consumer"),
		"rig" = list("eva", "consumer"),
		"crate" = list("crates", "supply"),
		"packag" = list("crates", "supply")
	)
	var/static/list/live_market_item_tag_rules = list(
		/obj/item/stack/material = list("materials", "industrial"),
		/obj/item/reagent_containers/food = list("food", "consumer"),
		/obj/item/clothing = list("clothing", "consumer"),
		/obj/item/reagent_containers = list("medical"),
		/obj/item/stack/medical = list("medical"),
		/obj/item/storage/firstaid = list("medical"),
		/obj/item/device = list("parts", "industrial"),
		/obj/item/stock_parts = list("parts", "industrial"),
		/obj/item/cell = list("power", "industrial"),
		/obj/item/stack/cable_coil = list("power", "industrial"),
		/obj/item/light = list("power", "industrial"),
		/obj/item/gun = list("munitions", "security"),
		/obj/item/ammobox = list("munitions", "security"),
		/obj/item/ammo_magazine = list("munitions", "security")
	)

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
		for(var/fragment in live_market_category_tag_rules)
			if(findtext(lower_category, fragment))
				for(var/tag in live_market_category_tag_rules[fragment])
					tags[tag] = TRUE

	var/item_path = GetGoodPath(category_name, good_id)
	for(var/item_type in live_market_item_tag_rules)
		if(ispath(item_path, item_type))
			for(var/tag in live_market_item_tag_rules[item_type])
				tags[tag] = TRUE
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
		"tags" = BuildLiveMarketCommodityTags(category_name, good_id)
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
	for(var/category_name in offers_by_category)
		var/list/category = offers_by_category[category_name]
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
	ApplyLiveMarketModifierPreset(modifier, type)
	return modifier

/datum/trading_station/proc/ApplyLiveMarketModifierPreset(list/modifier, type)
	switch(type)
		if(MARKET_MOD_BOOM)
			ApplyBoomModifierPreset(modifier)
		if(MARKET_MOD_SHORTAGE)
			ApplyShortageModifierPreset(modifier)
		if(MARKET_MOD_INDUSTRIAL_DEMAND)
			ApplyIndustrialModifierPreset(modifier)
		if(MARKET_MOD_BLOCKADE)
			ApplyBlockadeModifierPreset(modifier)

/datum/trading_station/proc/ApplyBoomModifierPreset(list/modifier)
	modifier["name"] = "Economic Boom"
	modifier["desc"] = "Civilian demand is strong and the station is paying well for finished goods."
	modifier["buy_shift"] = -0.08
	modifier["sell_shift"] = 0.1
	modifier["demand_shift"] = -0.05
	modifier["stock_shift"] = 0.15
	modifier["tone"] = "good"
	if(!length(modifier["tag_weights"]))
		modifier["tag_weights"] = list("consumer" = 1, "food" = 0.8, "service" = 1, "general" = 0.4)

/datum/trading_station/proc/ApplyShortageModifierPreset(list/modifier)
	modifier["name"] = "Acute Shortage"
	modifier["desc"] = "Stocks are strained and the station is bidding aggressively for replacements."
	modifier["buy_shift"] = 0.18
	modifier["sell_shift"] = 0.24
	modifier["demand_shift"] = 0.22
	modifier["stock_shift"] = -0.2
	modifier["tone"] = "bad"
	if(!length(modifier["tag_weights"]))
		modifier["tag_weights"] = list("*" = 0.55)

/datum/trading_station/proc/ApplyIndustrialModifierPreset(list/modifier)
	modifier["name"] = "Industrial Demand"
	modifier["desc"] = "Manufacturing demand is spiking for parts and raw materials."
	modifier["buy_shift"] = 0.1
	modifier["sell_shift"] = 0.18
	modifier["demand_shift"] = 0.16
	modifier["stock_shift"] = -0.1
	modifier["tone"] = "average"
	if(!length(modifier["tag_weights"]))
		modifier["tag_weights"] = list("materials" = 1, "industrial" = 1, "parts" = 0.9)

/datum/trading_station/proc/ApplyBlockadeModifierPreset(list/modifier)
	modifier["name"] = "Shipping Blockade"
	modifier["desc"] = "Logistics disruption is tightening supply and pushing import prices up."
	modifier["buy_shift"] = 0.22
	modifier["sell_shift"] = 0.12
	modifier["demand_shift"] = 0.1
	modifier["stock_shift"] = -0.18
	modifier["tone"] = "bad"
	if(!length(modifier["tag_weights"]))
		modifier["tag_weights"] = list("*" = 0.8)

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
		for(var/category_name in offers_by_category)
			var/list/category = offers_by_category[category_name]
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
					var/current = GetGoodAmount(category_name, good_id)
					if(metabolism_enabled && MatchesMetabolicTags(category_name, good_id, metabolic_production_tags))
						if(current >= GetMetabolicProductionLimit(category_name, good_id))
							continue
					SetGoodAmount(category_name, good_id, current + 1)

/datum/trading_station/proc/EnsureLiveMarketActivity()
	if(!live_market_enabled || !live_market_auto_events || length(live_market_modifiers))
		return
	if(prob(35))
		AddLiveMarketModifier(pick(MARKET_MOD_BOOM, MARKET_MOD_SHORTAGE, MARKET_MOD_INDUSTRIAL_DEMAND, MARKET_MOD_BLOCKADE), rand(3, 5))

/datum/trading_station/proc/ApplyLiveMarketModifierDemandEffects()
	for(var/list/modifier as anything in live_market_modifiers)
		var/shift = modifier["demand_shift"]
		if(!isnum(shift) || !shift)
			continue
		for(var/category_name in offers_by_category)
			var/list/category = offers_by_category[category_name]
			for(var/good_id in category)
				var/weight = GetLiveMarketTagWeight(category_name, good_id, modifier["tag_weights"])
				AdjustLiveMarketDemand(category_name, good_id, shift * weight * GetLiveMarketBaseline(category_name, good_id))

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
	ApplyLiveMarketModifierDemandEffects()
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

	if(IsFactionTradeBlocked(station, station_faction, seller_name))
		return 0

	var/rel = GetFactionRelationshipState(station_faction, seller_name)
	var/multiplier = GetRelationStateMultiplier(rel)
	if(multiplier && (seller_name in station_faction.trade_markup))
		var/markup = station_faction.trade_markup[seller_name]
		if(isnum(markup) && markup > 1)
			multiplier /= markup
	return multiplier

/datum/controller/subsystem/supply/proc/IsFactionTradeBlocked(datum/trading_station/station, datum/trade_faction/station_faction, seller_name)
	if(islist(station_faction.embargo) && (seller_name in station_faction.embargo))
		return TRUE
	if(length(station.blacklist_factions) && (seller_name in station.blacklist_factions))
		return TRUE
	if(length(station.whitelist_factions) && !(seller_name in station.whitelist_factions))
		return TRUE
	return FALSE

/datum/controller/subsystem/supply/proc/GetFactionRelationshipState(datum/trade_faction/station_faction, seller_name)
	var/rel = station_faction.relationship[seller_name]
	if(!isnull(rel))
		return rel
	var/datum/trade_faction/seller_datum = GetFaction(seller_name)
	if(istype(seller_datum) && isnum(station_faction.relationship[seller_datum.name]))
		return station_faction.relationship[seller_datum.name]
	return FACTION_STATE_NEUTRAL

/datum/controller/subsystem/supply/proc/GetRelationStateMultiplier(rel)
	switch(rel)
		if(FACTION_STATE_WAR)
			return 0
		if(FACTION_STATE_ENEMY)
			return 0.5
		if(FACTION_STATE_RIVAL)
			return 0.7
		if(FACTION_STATE_ANIMOSITY)
			return 0.85
		if(FACTION_STATE_NEUTRAL)
			return 0.95
		if(FACTION_STATE_WELCOMING)
			return 1.05
		if(FACTION_STATE_FRIEND)
			return 1.1
		if(FACTION_STATE_ALLY)
			return 1.2
		if(FACTION_STATE_PROTECTORATE)
			return 1.25
	return 1

/datum/controller/subsystem/supply/proc/GetStationSellPrice(good_ref, datum/trading_station/station, seller_faction = null, category_name = null, amount = 1, sold_offset = 0)
	if(istype(station) && istext(seller_faction) && isnull(category_name) && (seller_faction in station.offers_by_category))
		category_name = seller_faction
		seller_faction = null

	if(!isnum(amount) || amount <= 0 || !istype(station))
		return 0

	var/base_price = GetStationTradeBasePrice(good_ref, station, null, category_name)
	var/faction_mult = GetStationTradeRelationMultiplier(station, seller_faction)
	if(!base_price || !faction_mult)
		return 0

	if(!station.live_market_enabled)
		return round(base_price * faction_mult * (sold_offset + amount), 0.01) - round(base_price * faction_mult * sold_offset, 0.01)

	if(!istext(category_name) || !station.HasLiveMarketCommodity(category_name, good_ref))
		return round(base_price * 0.55 * faction_mult * (sold_offset + amount), 0.01) - round(base_price * 0.55 * faction_mult * sold_offset, 0.01)

	return CalculateSimulatedSellPrice(good_ref, station, category_name, amount, sold_offset, base_price, faction_mult, seller_faction)

/datum/controller/subsystem/supply/proc/CalculateSimulatedSellPrice(good_ref, datum/trading_station/station, category_name, amount, sold_offset, base_price, faction_mult, seller_faction)
	var/baseline = max(1, station.GetLiveMarketBaseline(category_name, good_ref))
	var/datum/trade_offer/offer = station.ResolveOffer(category_name, good_ref)
	var/initial_stock = max(0, station.GetGoodAmount(category_name, good_ref)) + (offer?.export_stock_remainder || 0)
	var/initial_demand = station.GetLiveMarketDemandScore(category_name, good_ref)
	var/event_mult = station.GetLiveMarketEventPriceMultiplier(category_name, good_ref, "sell_shift")
	var/buy_price_cap = round(GetStationBuyPrice(good_ref, station, seller_faction, category_name) * 0.9)

	var/end_price = SimulateDirectSellPrice(station, sold_offset + amount, 0, baseline, initial_stock, initial_demand, event_mult, base_price, faction_mult, buy_price_cap)
	var/start_price = SimulateDirectSellPrice(station, sold_offset, 0, baseline, initial_stock, initial_demand, event_mult, base_price, faction_mult, buy_price_cap)
	return round(end_price, 0.01) - round(start_price, 0.01)

/datum/controller/subsystem/supply/proc/CalculateLiveMarketSellUnitMult(sim_stock, baseline, sim_demand, event_mult, datum/trading_station/station)
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
	return clamp(unit_mult, station.live_market_min_sell_multiplier, station.live_market_max_sell_multiplier)

/datum/controller/subsystem/supply/proc/CalculateLiveMarketSellUnitPrice(base_price, unit_mult, faction_mult, buy_price_cap)
	var/unit_price = max(1, round(base_price * unit_mult * faction_mult))
	if(buy_price_cap > 0)
		unit_price = min(unit_price, buy_price_cap)
	return unit_price

/datum/controller/subsystem/supply/proc/SimulateDirectSellPrice(datum/trading_station/station, amount, sold_offset, baseline, initial_stock, initial_demand, event_mult, base_price, faction_mult, buy_price_cap)
	var/full_units = floor(amount)
	var/fraction = amount - full_units
	var/total_price = full_units > 0 ? SimulateFullUnitsSellPrice(station, full_units, sold_offset, baseline, initial_stock, initial_demand, event_mult, base_price, faction_mult, buy_price_cap) : 0
	if(fraction > 0)
		var/units_sold_before = full_units + sold_offset
		var/sim_stock = initial_stock + units_sold_before
		var/sim_demand = clamp(initial_demand - (units_sold_before / baseline), -2, 2.5)
		var/unit_mult = CalculateLiveMarketSellUnitMult(sim_stock, baseline, sim_demand, event_mult, station)
		var/unit_price = CalculateLiveMarketSellUnitPrice(base_price, unit_mult, faction_mult, buy_price_cap)
		total_price += unit_price * fraction
	return total_price

/datum/controller/subsystem/supply/proc/SimulateFullUnitsSellPrice(datum/trading_station/station, full_units, sold_offset, baseline, initial_stock, initial_demand, event_mult, base_price, faction_mult, buy_price_cap)
	var/total_price = 0
	for(var/k in 1 to full_units)
		var/units_sold_before = (k - 1) + sold_offset
		var/sim_stock = initial_stock + units_sold_before
		var/sim_demand = clamp(initial_demand - (units_sold_before / baseline), -2, 2.5)
		var/unit_mult = CalculateLiveMarketSellUnitMult(sim_stock, baseline, sim_demand, event_mult, station)
		var/unit_price = CalculateLiveMarketSellUnitPrice(base_price, unit_mult, faction_mult, buy_price_cap)
		total_price += unit_price
		if(unit_mult <= station.live_market_min_sell_multiplier || (sim_stock >= 2 * baseline && sim_demand <= -2))
			var/remaining = full_units - k
			if(remaining > 0)
				total_price += remaining * unit_price
			break
	return total_price

/datum/controller/subsystem/supply/proc/SimulateBucketedSellPrice(datum/trading_station/station, amount, sold_offset, baseline, initial_stock, initial_demand, event_mult, base_price, faction_mult, buy_price_cap)
	return SimulateDirectSellPrice(station, amount + sold_offset, 0, baseline, initial_stock, initial_demand, event_mult, base_price, faction_mult, buy_price_cap) - SimulateDirectSellPrice(station, sold_offset, 0, baseline, initial_stock, initial_demand, event_mult, base_price, faction_mult, buy_price_cap)

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
	var/price = station.GetGoodPrice(good_ref, cat)
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

/datum/controller/subsystem/supply/proc/SnapshotCartItem(list/result, list/item, buyer_faction, unit_price = null)
	var/datum/trading_station/station = item["station"]
	var/datum/trade_offer/offer = item["offer"]
	var/list/goods = result[station.uid]
	if(!islist(goods))
		goods = list()
		result[station.uid] = goods
	if(isnull(unit_price))
		unit_price = GetStationBuyPrice(offer.id, station, buyer_faction, offer.category)
	goods[offer.id] = list("unit_price" = unit_price, "amount" = item["count"], "timestamp" = world.time)

/datum/controller/subsystem/supply/proc/BuildMarketSnapshot(list/shop_list, buyer_faction = null)
	var/list/result = list()
	if(!islist(shop_list) || !length(shop_list))
		return result
	for(var/list/item as anything in ExtractCartItems(shop_list))
		SnapshotCartItem(result, item, buyer_faction)
	return result

/datum/controller/subsystem/supply/proc/GetSnapshotUnitPrice(list/price_snapshot, datum/trading_station/station, category_name, good_id)
	if(!islist(price_snapshot) || !istype(station) || !istext(good_id))
		return null
	var/list/goods = price_snapshot[station.uid]
	if(!islist(goods))
		return null
	var/list/packet = goods[good_id]
	return is_valid_cargo_quote_packet(packet) ? packet["unit_price"] : null

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
			station.AddExportStock(category_name, good_id, amount)

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
	if(!islist(station.offers_by_category))
		return null
	for(var/category_name in station.offers_by_category)
		var/list/category = station.offers_by_category[category_name]
		for(var/good_id in category)
			var/atom/movable/path = station.GetGoodPath(category_name, good_id)
			if(!path)
				continue
			var/obj/item/stack/stack_type = path
			var/pack_size = ispath(path, /obj/item/stack) ? max(1, initial(stack_type.amount)) : 1
			var/amount = GetExportCommodityAmount(exported, path, pack_size)
			if(amount > 0)
				return list("category" = category_name, "good_id" = good_id, "amount" = amount)
	return null

/datum/controller/subsystem/supply/proc/FindCommodityForExport(atom/movable/exported, datum/trading_station/station)
	if(!istype(exported) || !istype(station))
		return null
	var/datum/trade_offer/offer = FindExportOfferByPath(station, exported.type)
	var/amount = offer ? GetExportCommodityAmount(exported, offer.item_path, offer.pack_size) : 0
	if(amount > 0)
		return list("category" = offer.category, "good_id" = offer.id, "amount" = amount)
	if(istype(exported, /obj/item/stack/material))
		for(var/id in station.offers)
			var/datum/trade_offer/candidate = station.offers[id]
			if(!ispath(candidate.item_path, /obj/item/stack/material))
				continue
			amount = GetExportCommodityAmount(exported, candidate.item_path, candidate.pack_size)
			if(amount > 0)
				return list("category" = candidate.category, "good_id" = candidate.id, "amount" = amount)
	return FindLegacyCommodityForExport(exported, station)

/datum/controller/subsystem/supply/proc/BuildStationMarketIntel(datum/trading_station/station, buyer_faction = null)
	if(!istype(station))
		return null
	var/list/quotes = list()
	for(var/category_name in station.offers_by_category)
		var/list/category = station.offers_by_category[category_name]
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
	if(!is_valid_cargo_cart(shop_list) || !is_valid_cargo_quote(snapshot))
		return null
	for(var/list/item as anything in ExtractCartItems(shop_list))
		var/datum/trading_station/station = item["station"]
		var/gid = item["good_id"]
		var/cat = item["cat"]
		var/count = item["count"]
		var/unit_price = GetSnapshotUnitPrice(snapshot, station, cat, gid)
		if(isnull(unit_price))
			return null
		. += unit_price * count

#undef MARKET_MOD_BOOM
#undef MARKET_MOD_SHORTAGE
#undef MARKET_MOD_INDUSTRIAL_DEMAND
#undef MARKET_MOD_BLOCKADE

#undef MARKET_TRANS_BUY
#undef MARKET_TRANS_SELL
