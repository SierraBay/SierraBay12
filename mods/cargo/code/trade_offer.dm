/datum/trade_offer
	var/id
	var/atom/movable/item_path
	var/name
	var/desc
	var/category
	var/base_price = 1
	var/has_custom_price = FALSE
	var/pack_size = 1
	var/stock = 0
	var/baseline_stock = 1
	var/demand = 0
	var/list/tags = list()
	var/hidden = FALSE
	var/datum/trading_station/station

/datum/trade_offer/New(
	new_id,
	atom/movable/new_item_path,
	new_name = null,
	new_desc = null,
	new_category = null,
	new_base_price = 0,
	new_stock = 0,
	new_baseline = null,
	new_demand = 0,
	list/new_tags = null,
	datum/trading_station/new_station = null,
	new_hidden = FALSE
)
	. = ..()
	id = new_id
	item_path = new_item_path
	station = new_station
	hidden = !!new_hidden
	category = (istext(new_category) && length(new_category)) ? new_category : "General"
	name = (istext(new_name) && length(new_name)) ? new_name : ResolveItemName(new_item_path)
	desc = istext(new_desc) ? new_desc : ResolveItemDesc(new_item_path)
	InitPricing(new_base_price, new_item_path)
	InitStockAndDemand(new_stock, new_baseline, new_demand)
	InitTags(new_tags)

/datum/trade_offer/Destroy()
	tags?.Cut()
	tags = null
	item_path = null
	station = null
	return ..()

/datum/trade_offer/proc/InitPricing(new_base_price, new_item_path)
	pack_size = ResolvePackSize(new_item_path)
	if(isnum(new_base_price) && new_base_price > 0)
		has_custom_price = TRUE
		base_price = max(1, round(new_base_price))
		return
	has_custom_price = FALSE
	var/item_value = ispath(new_item_path, /atom/movable) ? get_value(new_item_path) : null
	base_price = (isnum(item_value) && item_value > 0) ? max(1, round(item_value)) : 1

/datum/trade_offer/proc/ResolvePackSize(path)
	if(!ispath(path, /obj/item/stack))
		return 1
	var/obj/item/stack/stack_type = path
	var/initial_amount = initial(stack_type.amount)
	return isnum(initial_amount) ? max(1, initial_amount) : 1

/datum/trade_offer/proc/InitStockAndDemand(new_stock, new_baseline, new_demand)
	stock = isnum(new_stock) ? max(0, round(new_stock)) : 0
	baseline_stock = isnum(new_baseline) ? max(1, round(new_baseline)) : max(1, stock)
	demand = isnum(new_demand) ? clamp(new_demand, -2.0, 2.5) : 0

/datum/trade_offer/proc/InitTags(list/new_tags)
	if(islist(new_tags) && length(new_tags))
		tags = list()
		for(var/tag_key in new_tags)
			tags[tag_key] = TRUE
	else
		tags = BuildDefaultTags()

/datum/trade_offer/proc/Duplicate(new_id = null, datum/trading_station/new_station = null)
	var/datum/trade_offer/duplicate = new(
		new_id || id,
		item_path,
		name,
		desc,
		category,
		base_price,
		stock,
		baseline_stock,
		demand,
		islist(tags) ? tags.Copy() : null,
		new_station || station,
		hidden
	)
	duplicate.has_custom_price = has_custom_price
	duplicate.pack_size = pack_size
	return duplicate

/datum/trade_offer/proc/ResolveItemName(path)
	if(!ispath(path, /atom/movable))
		return id || "Unknown Commodity"
	if(ispath(path, /obj/item/seeds) && path != /obj/item/seeds && path != /obj/item/seeds/random)
		return ResolveSeedName(path)
	if(ispath(path, /obj/item/reagent_containers/chem_disp_cartridge))
		return ResolveCartridgeName(path)
	var/atom/movable/item_type = path
	return initial(item_type.name) || id || "Unknown Commodity"

/datum/trade_offer/proc/ResolveSeedName(path)
	var/obj/item/seeds/seed_item = path
	var/seed_key = initial(seed_item.seed_type)
	if(!seed_key)
		return initial(seed_item.name) || "packet of seeds"
	var/list/seed_registry = SSplants?.seeds
	if(seed_registry?[seed_key])
		var/datum/seed/seed_datum = seed_registry[seed_key]
		if(seed_datum.seed_name && seed_datum.seed_noun)
			var/container_name = (seed_datum.seed_noun in list(SEED_NOUN_SEEDS, SEED_NOUN_PITS, SEED_NOUN_NODES)) ? "packet" : "sample"
			return "[container_name] of [seed_datum.seed_name] [seed_datum.seed_noun]"
		return "packet of [seed_datum.seed_name || seed_key] seeds"
	return "packet of [seed_key] seeds"

/datum/trade_offer/proc/ResolveCartridgeName(path)
	var/obj/item/reagent_containers/chem_disp_cartridge/cartridge = path
	var/datum/reagent/reagent_type = initial(cartridge.spawn_reagent)
	if(ispath(reagent_type, /datum/reagent))
		return "[initial(cartridge.name)] ([initial(reagent_type.name)])"
	return initial(cartridge.name) || "chemical dispenser cartridge"

/datum/trade_offer/proc/ResolveItemDesc(path)
	if(ispath(path, /atom/movable))
		var/atom/movable/item_type = path
		return initial(item_type.desc) || ""
	return ""

/datum/trade_offer/proc/BuildDefaultTags()
	var/list/built_tags = list()
	PopulateCategoryTags(built_tags)
	PopulateItemPathTags(built_tags)
	if(!length(built_tags))
		built_tags["general"] = TRUE
	return built_tags

/datum/trade_offer/proc/PopulateCategoryTags(list/built_tags)
	if(!istext(category))
		return
	var/normalized_category = lowertext(category)
	built_tags[normalized_category] = TRUE
	if(findtext(normalized_category, "material"))
		built_tags["materials"] = TRUE
		built_tags["industrial"] = TRUE
	if(findtext(normalized_category, "medical") || findtext(normalized_category, "chemical") || findtext(normalized_category, "surgery"))
		built_tags["medical"] = TRUE
	if(findtext(normalized_category, "science") || findtext(normalized_category, "research"))
		built_tags["science"] = TRUE
	if(findtext(normalized_category, "service") || findtext(normalized_category, "food") || findtext(normalized_category, "leisure"))
		built_tags["consumer"] = TRUE
	if(findtext(normalized_category, "engineering") || findtext(normalized_category, "power") || findtext(normalized_category, "tools"))
		built_tags["industrial"] = TRUE
		built_tags["parts"] = TRUE
	if(findtext(normalized_category, "weapons") || findtext(normalized_category, "security") || findtext(normalized_category, "ammo"))
		built_tags["security"] = TRUE
		built_tags["military"] = TRUE

/datum/trade_offer/proc/PopulateItemPathTags(list/built_tags)
	if(!ispath(item_path, /atom/movable))
		return
	if(ispath(item_path, /obj/item/stack/material))
		built_tags["materials"] = TRUE
		built_tags["industrial"] = TRUE
	if(ispath(item_path, /obj/item/reagent_containers/food) || ispath(item_path, /obj/item/clothing))
		built_tags["consumer"] = TRUE
	if(ispath(item_path, /obj/item/reagent_containers) || ispath(item_path, /obj/item/stack/medical))
		built_tags["medical"] = TRUE
	if(ispath(item_path, /obj/item/device) || ispath(item_path, /obj/item/stock_parts))
		built_tags["parts"] = TRUE
		built_tags["industrial"] = TRUE
	if(ispath(item_path, /obj/item/gun) || ispath(item_path, /obj/item/ammo_magazine) || ispath(item_path, /obj/item/ammo_casing))
		built_tags["security"] = TRUE
		built_tags["military"] = TRUE

/datum/trade_offer/proc/GetUnitPrice(markup = 1.0, is_selling = FALSE, modifier_mult = 1.0, use_market = TRUE)
	if(is_selling)
		return GetSellUnitPrice(modifier_mult, use_market)
	return GetBuyUnitPrice(markup, modifier_mult, use_market)

/datum/trade_offer/proc/GetBuyUnitPrice(markup = 1.0, modifier_mult = 1.0, use_market = TRUE)
	var/applied_markup = (!has_custom_price && isnum(markup) && markup > 0) ? markup : 1.0
	var/marked_up_price = base_price * applied_markup
	if(!use_market)
		return max(1, round(marked_up_price))
	var/market_multiplier = GetBuyMarketMultiplier()
	market_multiplier *= NormalizePriceModifier(modifier_mult)
	return max(1, round(marked_up_price * clamp(market_multiplier, 0.8, 1.75)))

/datum/trade_offer/proc/GetBuyMarketMultiplier()
	var/multiplier = 1.0
	var/baseline = max(1, baseline_stock)
	if(stock < baseline)
		var/stock_pressure = min((baseline - stock) / baseline, 1.0)
		multiplier += min(stock_pressure * 0.6, 0.45)
	else if(stock > baseline)
		var/stock_pressure = min((stock - baseline) / baseline, 1.0)
		multiplier -= min(stock_pressure * 0.2, 0.15)
	if(demand > 0)
		multiplier += min(demand * 0.22, 0.32)
	else if(demand < 0)
		multiplier -= min(abs(demand) * 0.08, 0.12)
	return multiplier

/datum/trade_offer/proc/GetSellUnitPrice(modifier_mult = 1.0, use_market = TRUE)
	if(!use_market)
		return max(1, round(base_price * 0.62))
	var/market_multiplier = GetSellMarketMultiplier()
	market_multiplier *= NormalizePriceModifier(modifier_mult)
	return max(1, round(base_price * clamp(market_multiplier, 0.35, 1.15)))

/datum/trade_offer/proc/GetSellMarketMultiplier()
	var/multiplier = 0.62
	var/baseline = max(1, baseline_stock)
	if(stock < baseline)
		var/stock_pressure = min((baseline - stock) / baseline, 1.0)
		multiplier += min(stock_pressure * 0.35, 0.28)
	else if(stock > baseline)
		var/stock_pressure = min((stock - baseline) / baseline, 1.0)
		multiplier -= min(stock_pressure * 0.18, 0.18)
	if(demand > 0)
		multiplier += min(demand * 0.18, 0.25)
	else if(demand < 0)
		multiplier -= min(abs(demand) * 0.12, 0.2)
	return multiplier

/datum/trade_offer/proc/NormalizePriceModifier(modifier_mult)
	return (isnum(modifier_mult) && modifier_mult > 0) ? modifier_mult : 1.0

/datum/trade_offer/proc/AdjustStock(delta)
	if(!isnum(delta))
		return stock
	stock = max(0, stock + round(delta))
	return stock

/datum/trade_offer/proc/Restock(amount)
	if(!isnum(amount) || amount <= 0)
		return stock
	return AdjustStock(amount)

/datum/trade_offer/proc/AdjustDemand(delta)
	if(!isnum(delta))
		return demand
	var/baseline = max(1, baseline_stock)
	demand = clamp(demand + (delta / baseline), -2.0, 2.5)
	return demand

/datum/trade_offer/proc/CanFulfill(amount = 1)
	var/quantity = NormalizeQuantity(amount)
	return !isnull(quantity) && stock >= quantity

/datum/trade_offer/proc/ConsumeStock(amount = 1)
	var/quantity = NormalizeQuantity(amount)
	if(isnull(quantity) || stock < quantity)
		return FALSE
	stock -= quantity
	return TRUE

/datum/trade_offer/proc/NormalizeQuantity(amount)
	if(!isnum(amount) || amount <= 0)
		return null
	return max(1, round(amount))

/datum/trade_offer/proc/HasTag(tag_name)
	return islist(tags) && tags[tag_name]

/datum/trade_offer/proc/Serialize(markup = 1.0, in_cart = 0, can_add = TRUE, is_target = FALSE, icon_ref = null)
	var/buy_price = GetUnitPrice(markup, FALSE)
	var/sell_price = GetUnitPrice(1.0, TRUE)
	var/list/data = list(
		"id" = id,
		"item_path" = "[item_path]",
		"name" = name,
		"desc" = desc,
		"category" = category,
		"base_price" = base_price,
		"price" = buy_price,
		"sell_price" = sell_price,
		"stock" = stock,
		"baseline_stock" = baseline_stock,
		"demand" = demand,
		"can_add" = can_add && (stock > 0),
		"in_cart_amount" = in_cart,
		"quantity_form_open" = is_target,
		"tags" = islist(tags) ? tags.Copy() : list()
	)
	if(icon_ref)
		data["icon"] = icon_ref
	return data
