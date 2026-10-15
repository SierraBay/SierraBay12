/datum/trading_station/proc/RegainTradeStationsBudget(budget = spawn_cost)
	if(!spawn_always)
		SSsupply.trade_stations_budget += budget

/datum/trading_station/proc/StationTick()
	if(QDELETED(src))
		return
	if(initialized)
		GoodsTick()
	else
		initialized = TRUE
	update_time = rand(6, 8) MINUTES
	update_timer_start = world.time
	next_update_at = world.time + update_time

/datum/trading_station/proc/UpdateTick()
	StationTick()

/datum/trading_station/proc/GoodsTick()
	wealth += base_income
	ProcessMetabolism()
	var/budget = unique_good_count ? round(wealth / unique_good_count) : 0
	var/list/restock_candidates = CollectRestockCandidates(budget)
	ApplyRestockCandidates(restock_candidates)
	TryUnlockHiddenInv()

/datum/trading_station/proc/ProcessMetabolism()
	if(!metabolism_enabled)
		return
	ProcessMetabolicProduction()
	ProcessMetabolicConsumption()

/datum/trading_station/proc/ProcessMetabolicProduction()
	var/list/candidates = GetMetabolicCandidates(metabolic_production_tags)
	if(!length(candidates))
		return
	var/batch_size = clamp(rand(1, 2), 1, length(candidates))
	for(var/i in 1 to batch_size)
		for(var/list/candidate as anything in candidates.Copy())
			if(!CanProduceMetabolicCommodity(candidate["category"], candidate["good_id"]))
				candidates -= list(candidate)
		if(!length(candidates))
			break
		var/list/chosen = pick(candidates)
		candidates -= list(chosen)
		ProduceMetabolicCommodity(chosen["category"], chosen["good_id"])

/datum/trading_station/proc/CanProduceMetabolicCommodity(category_name, good_id)
	if(GetGoodAmount(category_name, good_id) >= GetMetabolicProductionLimit(category_name, good_id))
		return FALSE
	var/base_price = max(1, round(GetLiveMarketBasePrice(category_name, good_id)))
	var/prod_cost = max(1, round(base_price * metabolic_production_cost_ratio))
	return wealth >= prod_cost

/datum/trading_station/proc/GetMetabolicProductionLimit(category_name, good_id)
	var/baseline = max(1, GetLiveMarketBaseline(category_name, good_id))
	return max(baseline + 1, round(baseline * max_production_multiplier))

/datum/trading_station/proc/ProduceMetabolicCommodity(category_name, good_id)
	if(!CanProduceMetabolicCommodity(category_name, good_id))
		return FALSE

	var/base_price = max(1, round(GetLiveMarketBasePrice(category_name, good_id)))
	var/prod_cost = max(1, round(base_price * metabolic_production_cost_ratio))
	SubtractFromWealth(prod_cost)
	SetGoodAmount(category_name, good_id, GetGoodAmount(category_name, good_id) + 1)
	AdjustLiveMarketDemand(category_name, good_id, -0.2)
	return TRUE

/datum/trading_station/proc/ProcessMetabolicConsumption()
	var/list/candidates = GetMetabolicCandidates(metabolic_consumption_tags)
	if(!length(candidates))
		return
	var/batch_size = clamp(rand(1, 2), 1, length(candidates))
	for(var/i in 1 to batch_size)
		if(!length(candidates))
			break
		var/list/chosen = pick(candidates)
		candidates -= list(chosen)
		ConsumeMetabolicCommodity(chosen["category"], chosen["good_id"])

/datum/trading_station/proc/ConsumeMetabolicCommodity(category_name, good_id)
	var/current_stock = GetGoodAmount(category_name, good_id)
	var/base_price = max(1, round(GetLiveMarketBasePrice(category_name, good_id)))

	if(current_stock > min_consumption_reserve)
		SetGoodAmount(category_name, good_id, current_stock - 1)
		var/revenue = max(1, round(base_price * metabolic_consumption_wealth_ratio))
		AddToWealth(revenue, FALSE, FALSE)
		AdjustLiveMarketDemand(category_name, good_id, 0.6)
		return TRUE

	AdjustLiveMarketDemand(category_name, good_id, 1.0)
	return FALSE

/datum/trading_station/proc/GetMetabolicCandidates(list/filter_tags)
	var/list/candidates = list()
	if(!islist(offers_by_category) || !length(offers_by_category) || !islist(filter_tags) || !length(filter_tags))
		return candidates

	for(var/category_name in offers_by_category)
		var/list/category = offers_by_category[category_name]
		if(!islist(category))
			continue
		for(var/good_id in category)
			var/datum/trade_offer/offer = GetOffer(good_id)
			if(istype(offer) && offer.hidden && !hidden_inv_unlocked)
				continue
			if(!MatchesMetabolicTags(category_name, good_id, filter_tags))
				continue
			candidates += list(list("category" = category_name, "good_id" = good_id))
	return candidates

/datum/trading_station/proc/MatchesMetabolicTags(category_name, good_id, list/filter_tags)
	if(!islist(filter_tags) || !length(filter_tags))
		return FALSE
	var/list/comm_state = GetLiveMarketState(category_name, good_id, TRUE)
	var/list/tags = islist(comm_state) ? comm_state["tags"] : null
	if(islist(tags))
		for(var/tag in filter_tags)
			if(tags[tag])
				return TRUE
	if(istext(category_name) && (lowertext(category_name) in filter_tags))
		return TRUE
	return FALSE

/datum/trading_station/proc/CollectRestockCandidates(budget)
	var/list/candidates = list()
	for(var/category_name in offers_by_category)
		var/list/category = offers_by_category[category_name]
		if(!islist(category))
			continue
		for(var/good_id in category)
			var/current_amount = GetGoodAmount(category_name, good_id)
			var/baseline = max(1, GetLiveMarketBaseline(category_name, good_id))
			if(metabolism_enabled && current_amount >= baseline && MatchesMetabolicTags(category_name, good_id, metabolic_production_tags))
				continue
			var/chance = current_amount < 5 ? 100 : (current_amount > 20 ? 0 : 15)
			if(!prob(chance))
				continue
			var/cost = max(1, round(SSsupply.GetStationRestockCost(good_id, src, category_name) * live_market_restock_discount))
			var/amount_to_add = budget ? max(1, rand(1, max(1, round(budget / cost)))) : 1
			candidates += list(list(
				"category" = category_name,
				"good_id" = good_id,
				"unit_cost" = cost,
				"amount" = amount_to_add
			))
	return candidates

/datum/trading_station/proc/ApplyRestockCandidates(list/restock_candidates)
	for(var/i in 1 to 20)
		if(!length(restock_candidates) || wealth <= 0)
			break
		var/idx = rand(1, length(restock_candidates))
		var/list/good_packet = restock_candidates[idx]
		restock_candidates.Cut(idx, idx + 1)
		var/category_name = good_packet["category"]
		var/good_id = good_packet["good_id"]
		var/current_amount = GetGoodAmount(category_name, good_id)
		var/amount_to_add = good_packet["amount"]
		if(metabolism_enabled && MatchesMetabolicTags(category_name, good_id, metabolic_production_tags))
			var/max_stock = GetMetabolicProductionLimit(category_name, good_id)
			amount_to_add = min(amount_to_add, max(0, max_stock - current_amount))
		if(amount_to_add <= 0)
			continue
		var/total_cost = good_packet["unit_cost"] * amount_to_add
		if(total_cost <= wealth)
			SetGoodAmount(category_name, good_id, current_amount + amount_to_add)
			SubtractFromWealth(total_cost)

/datum/trading_station/proc/AddToWealth(income, is_offer = FALSE, add_favor = TRUE)
	if(!isnum(income))
		return
	wealth += income
	if(add_favor)
		favor += income * (is_offer ? 1 : 0.25)
		TryUnlockHiddenInv()

/datum/trading_station/proc/SubtractFromWealth(cost)
	if(isnum(cost) && cost > 0)
		wealth = max(0, wealth - cost)
