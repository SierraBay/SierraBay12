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
	id = new_id
	item_path = new_item_path
	station = new_station
	hidden = new_hidden
	category = new_category || "General"
	name = new_name ? new_name : ResolveItemName(new_item_path)
	desc = new_desc ? new_desc : ResolveItemDesc(new_item_path)
	InitPricing(new_base_price, new_item_path)
	InitStockAndDemand(new_stock, new_baseline, new_demand)
	InitTags(new_tags)

/datum/trade_offer/Destroy()
	if(islist(tags))
		tags.Cut()
		tags = null
	item_path = null
	station = null
	return ..()

/datum/trade_offer/proc/InitPricing(new_base_price, new_item_path)
	if(ispath(new_item_path, /obj/item/stack))
		var/obj/item/stack/S = new_item_path
		pack_size = max(1, initial(S.amount))
	else
		pack_size = 1
	if(isnum(new_base_price) && new_base_price > 0)
		has_custom_price = TRUE
		base_price = max(1, round(new_base_price))
	else if(ispath(new_item_path, /atom/movable))
		has_custom_price = FALSE
		var/cost = get_value(new_item_path)
		base_price = (isnum(cost) && cost > 0) ? max(1, round(cost)) : 1
	else
		has_custom_price = FALSE
		base_price = 1

/datum/trade_offer/proc/InitStockAndDemand(new_stock, new_baseline, new_demand)
	stock = isnum(new_stock) ? max(0, round(new_stock)) : 0
	baseline_stock = isnum(new_baseline) ? max(1, round(new_baseline)) : max(1, stock)
	demand = isnum(new_demand) ? new_demand : 0

/datum/trade_offer/proc/InitTags(list/new_tags)
	if(islist(new_tags) && length(new_tags))
		tags = list()
		for(var/tag_key in new_tags)
			tags[tag_key] = TRUE
	else
		tags = BuildDefaultTags()

/datum/trade_offer/proc/Duplicate(new_id = null, datum/trading_station/new_station = null)
	var/datum/trade_offer/dup = new(
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
	dup.has_custom_price = has_custom_price
	dup.pack_size = pack_size
	return dup

/datum/trade_offer/proc/ResolveItemName(path)
	if(!ispath(path, /atom/movable))
		return id || "Unknown Commodity"
	if(ispath(path, /obj/item/seeds) && path != /obj/item/seeds && path != /obj/item/seeds/random)
		return ResolveSeedName(path)
	if(ispath(path, /obj/item/reagent_containers/chem_disp_cartridge))
		return ResolveCartridgeName(path)
	var/atom/movable/item_type = path
	return initial(item_type.name) || "[id]"

/datum/trade_offer/proc/ResolveSeedName(path)
	var/obj/item/seeds/seed_item = path
	var/seed_key = initial(seed_item.seed_type)
	if(!seed_key)
		return initial(seed_item.name) || "packet of seeds"
	if(!isnull(SSplants?.seeds) && SSplants.seeds[seed_key])
		var/datum/seed/seed_datum = SSplants.seeds[seed_key]
		if(seed_datum.seed_name && seed_datum.seed_noun)
			var/prefix = (seed_datum.seed_noun in list(SEED_NOUN_SEEDS, SEED_NOUN_PITS, SEED_NOUN_NODES)) ? "packet" : "sample"
			return "[prefix] of [seed_datum.seed_name] [seed_datum.seed_noun]"
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
	var/lower_cat = lowertext(category)
	built_tags[lower_cat] = TRUE
	if(findtext(lower_cat, "material"))
		built_tags["materials"] = TRUE
		built_tags["industrial"] = TRUE
	if(findtext(lower_cat, "medical") || findtext(lower_cat, "chemical") || findtext(lower_cat, "surgery"))
		built_tags["medical"] = TRUE
	if(findtext(lower_cat, "science") || findtext(lower_cat, "research"))
		built_tags["science"] = TRUE
	if(findtext(lower_cat, "service") || findtext(lower_cat, "food") || findtext(lower_cat, "leisure"))
		built_tags["consumer"] = TRUE
	if(findtext(lower_cat, "engineering") || findtext(lower_cat, "power") || findtext(lower_cat, "tools"))
		built_tags["industrial"] = TRUE
		built_tags["parts"] = TRUE
	if(findtext(lower_cat, "weapons") || findtext(lower_cat, "security") || findtext(lower_cat, "ammo"))
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
	var/applied_markup = has_custom_price ? 1.0 : (isnum(markup) ? markup : 1.0)
	var/base = base_price * applied_markup
	if(!use_market)
		return max(1, round(base))
	var/multiplier = 1.0
	var/baseline = max(1, baseline_stock)
	if(stock < baseline)
		var/pressure = min((baseline - stock) / baseline, 1.0)
		multiplier += min(pressure * 0.6, 0.45)
	else if(stock > baseline)
		var/pressure = min((stock - baseline) / baseline, 1.0)
		multiplier -= min(pressure * 0.2, 0.15)
	if(demand > 0)
		multiplier += min(demand * 0.22, 0.32)
	else if(demand < 0)
		multiplier -= min(abs(demand) * 0.08, 0.12)
	multiplier *= modifier_mult
	multiplier = clamp(multiplier, 0.8, 1.75)
	return max(1, round(base * multiplier))

/datum/trade_offer/proc/GetSellUnitPrice(modifier_mult = 1.0, use_market = TRUE)
	if(!use_market)
		return max(1, round(base_price * 0.62))
	var/multiplier = 0.62
	var/baseline = max(1, baseline_stock)
	if(stock < baseline)
		var/pressure = min((baseline - stock) / baseline, 1.0)
		multiplier += min(pressure * 0.35, 0.28)
	else if(stock > baseline)
		var/pressure = min((stock - baseline) / baseline, 1.0)
		multiplier -= min(pressure * 0.18, 0.18)
	if(demand > 0)
		multiplier += min(demand * 0.18, 0.25)
	else if(demand < 0)
		multiplier -= min(abs(demand) * 0.12, 0.2)
	multiplier *= modifier_mult
	multiplier = clamp(multiplier, 0.35, 1.15)
	return max(1, round(base_price * multiplier))

/datum/trade_offer/proc/AdjustStock(delta)
	if(!isnum(delta))
		return stock
	stock = max(0, stock + round(delta))
	return stock

/datum/trade_offer/proc/Restock(amount)
	return AdjustStock(amount)

/datum/trade_offer/proc/AdjustDemand(delta)
	if(!isnum(delta))
		return demand
	var/baseline = max(1, baseline_stock)
	demand = clamp(demand + (delta / baseline), -2.0, 2.5)
	return demand

/datum/trade_offer/proc/CanFulfill(amount = 1)
	return stock >= max(1, round(amount))

/datum/trade_offer/proc/ConsumeStock(amount = 1)
	var/qty = max(1, round(amount))
	if(stock < qty)
		return FALSE
	stock -= qty
	return TRUE

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
