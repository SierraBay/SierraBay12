/datum/trading_station/proc/AssembleInventory()
	NormalizeGoodsRecords()

/datum/trading_station/proc/ResetOfferRegistries()
	DestroyOfferRegistries()
	offers = list()
	offers_by_category = list()
	commodity_by_path = list()
	hidden_offers = list()
	unique_good_count = 0
	next_good_offer_id = 0

/datum/trading_station/proc/AddOffer(datum/trade_offer/offer)
	if(!istype(offer))
		return null
	if(!offer.id || offers[offer.id])
		offer.id = GenerateGoodOfferId()
	offer.station = src
	offers[offer.id] = offer
	if(offer.hidden)
		hidden_offers[offer.id] = offer
	else
		RegisterVisibleOffer(offer)
	UpdateVisibleGoodCount()
	return offer

/datum/trading_station/proc/RegisterVisibleOffer(datum/trade_offer/offer)
	ASSERT(istype(offer))
	var/category_name = offer.category || "General"
	if(!islist(offers_by_category[category_name]))
		offers_by_category[category_name] = list()
	var/list/category_offers = offers_by_category[category_name]
	category_offers[offer.id] = offer
	if(ispath(offer.item_path, /atom/movable) && !(offer.item_path in commodity_by_path))
		commodity_by_path[offer.item_path] = offer

/datum/trading_station/proc/UpdateVisibleGoodCount()
	unique_good_count = max(0, length(offers) - length(hidden_offers))

/datum/trading_station/proc/GetOffer(offer_id, include_hidden = FALSE)
	if(!offer_id || !islist(offers))
		return null
	var/datum/trade_offer/offer = null
	if(istype(offer_id, /datum/trade_offer))
		offer = offer_id
	else if(offers[offer_id])
		offer = offers[offer_id]
	else if(isnum(offer_id))
		var/idx = round(offer_id)
		if(idx >= 1 && idx <= length(offers))
			offer = offers[offers[idx]]
	else if(include_hidden && islist(hidden_offers) && hidden_offers[offer_id])
		offer = hidden_offers[offer_id]
	if(istype(offer) && offer.station == src)
		if(offer.hidden && !hidden_inv_unlocked && !include_hidden)
			return null
		return offer
	return null

/datum/trading_station/proc/ResolveOffer(category_ref, good_ref, include_hidden = FALSE)
	var/category_name = isnum(category_ref) ? offers_by_category[category_ref] : category_ref
	if(istext(category_name) && islist(offers_by_category[category_name]))
		var/list/category_offers = offers_by_category[category_name]
		var/offer_id = good_ref
		if(isnum(good_ref))
			var/category_index = round(good_ref)
			if(category_index >= 1 && category_index <= length(category_offers))
				offer_id = category_offers[category_index]
		var/datum/trade_offer/category_offer = category_offers[offer_id]
		if(istype(category_offer))
			return category_offer
		return null
	var/datum/trade_offer/offer = GetOffer(good_ref, include_hidden)
	if(istype(offer) && (!istext(category_name) || offer.category == category_name))
		return offer
	return null

/datum/trading_station/proc/GetOfferByPath(item_path)
	if(!ispath(item_path) || !islist(commodity_by_path))
		return null
	var/datum/trade_offer/offer = commodity_by_path[item_path]
	if(istype(offer))
		return offer
	var/curr_type = item_path
	while(curr_type && curr_type != /atom/movable && curr_type != /obj && curr_type != /mob)
		offer = commodity_by_path[curr_type]
		if(istype(offer))
			commodity_by_path[item_path] = offer
			return offer
		curr_type = type2parent(curr_type)
	return null

/datum/trading_station/proc/GetOffersByCategory(category)
	var/list/result = list()
	if(!istext(category) || !islist(offers_by_category))
		return result
	var/list/cat_offers = offers_by_category[category]
	if(!islist(cat_offers))
		return result
	for(var/id in cat_offers)
		var/datum/trade_offer/offer = cat_offers[id]
		if(istype(offer))
			result += offer
		else if(offers[id])
			result += offers[id]
	return result

/datum/trading_station/proc/NormalizeInventory(list/target_inventory)
	if(!islist(target_inventory))
		return
	for(var/category_key in target_inventory.Copy())
		if(!islist(category_key))
			continue
		var/list/category_packet = category_key
		if(length(category_packet) < 2 || !category_packet["name"])
			continue
		var/new_category_name = category_packet["name"]
		var/list/content = target_inventory[category_key]
		if(!istext(new_category_name) || !islist(content))
			continue
		target_inventory.Remove(category_key)
		target_inventory[new_category_name] = content

/datum/trading_station/proc/NormalizeGoodsRecords()
	NormalizeInventory(inventory)
	NormalizeInventory(hidden_inventory)
	ResetOfferRegistries()
	PopulateOffers()

/datum/trading_station/proc/PopulateOffers()
	if(islist(inventory))
		for(var/category_name in inventory)
			var/list/goods = inventory[category_name]
			if(!islist(goods))
				continue
			for(var/good_ref in goods)
				CreateOfferFromTemplate(category_name, good_ref, goods[good_ref], FALSE)
	if(islist(hidden_inventory))
		for(var/category_name in hidden_inventory)
			var/list/goods = hidden_inventory[category_name]
			if(!islist(goods))
				continue
			for(var/good_ref in goods)
				CreateOfferFromTemplate(category_name, good_ref, goods[good_ref], TRUE)

/datum/trading_station/proc/CreateOfferFromTemplate(category_name, good_ref, source_packet, is_hidden = FALSE)
	var/item_path = null
	var/custom_name = null
	var/custom_price = null
	var/list/amount_range = null
	if(islist(source_packet))
		custom_name = source_packet["name"]
		custom_price = source_packet["price"]
		amount_range = source_packet["amount_range"]
		if(ispath(source_packet["item_path"], /atom/movable))
			item_path = source_packet["item_path"]
	if(!item_path && ispath(good_ref, /atom/movable))
		item_path = good_ref
	if(!item_path && !custom_name)
		return null
	var/datum/trade_offer/offer = new(
		new_id = GenerateGoodOfferId(),
		new_item_path = item_path,
		new_name = custom_name,
		new_category = category_name,
		new_base_price = custom_price,
		new_station = src,
		new_hidden = is_hidden
	)
	RollOfferStock(offer, amount_range, is_hidden)
	AddOffer(offer)
	return offer

/datum/trading_station/proc/RollOfferStock(datum/trade_offer/offer, list/amount_range, is_hidden)
	if(islist(amount_range) && length(amount_range) >= 2)
		offer.SetStock(rand(amount_range[1], amount_range[2]))
		offer.baseline_stock = max(1, round((amount_range[1] + amount_range[2]) / 2))
	else
		var/cost = offer.base_price || 100
		var/min_val = is_hidden ? 1 : 5
		var/max_val = max(min_val, round(30 / max(cost / 200, 1)))
		offer.SetStock(rand(min_val, max_val))
		offer.baseline_stock = max(1, offer.stock)

/datum/trading_station/proc/GenerateGoodOfferId()
	var/offer_id = "good_[++next_good_offer_id]"
	while(offers[offer_id])
		offer_id = "good_[++next_good_offer_id]"
	return offer_id

/datum/trading_station/proc/InitGoods()
	UpdateVisibleGoodCount()

/datum/trading_station/proc/TryUnlockHiddenInv()
	if(favor < unlock_favor || hidden_inv_unlocked)
		return
	hidden_inv_unlocked = TRUE
	for(var/id in hidden_offers)
		var/datum/trade_offer/offer = hidden_offers[id]
		if(!istype(offer))
			continue
		offer.hidden = FALSE
		RegisterVisibleOffer(offer)
	hidden_offers.Cut()
	UpdateVisibleGoodCount()

/datum/trading_station/proc/GetGoodPacket(category_name, good_ref)
	var/datum/trade_offer/offer = ResolveOffer(category_name, good_ref)
	if(!offer)
		return null
	return list("item_path" = offer.item_path, "name" = offer.name, "desc" = offer.desc, "price" = offer.base_price, "amount_range" = list(offer.stock, offer.stock), "offer" = offer)

/datum/trading_station/proc/GetGoodPath(category_name, good_ref)
	var/datum/trade_offer/offer = ResolveOffer(category_name, good_ref)
	return offer && ispath(offer.item_path, /atom/movable) ? offer.item_path : null

/datum/trading_station/proc/GetGoodName(category_name, good_ref)
	var/datum/trade_offer/offer = ResolveOffer(category_name, good_ref)
	return offer ? (offer.name || "[good_ref]") : "[good_ref]"

/datum/trading_station/proc/GetGoodPrice(good_ref, category_name = null)
	var/datum/trade_offer/offer = ResolveOffer(category_name, good_ref)
	return offer ? offer.base_price : 0

/datum/trading_station/proc/GetGoodAmount(category_ref, good_ref)
	var/datum/trade_offer/offer = ResolveOffer(category_ref, good_ref)
	return offer ? offer.stock : 0

/datum/trading_station/proc/SetGoodAmount(category_ref, good_ref, value)
	var/datum/trade_offer/offer = ResolveOffer(category_ref, good_ref)
	if(offer)
		offer.SetStock(value)

/datum/trading_station/proc/AddExportStock(category_name, good_id, amount)
	var/datum/trade_offer/offer = ResolveOffer(category_name, good_id)
	if(!istype(offer) || !isnum(amount) || amount <= 0)
		return
	// Compensate float rounding so repeated small exports still form a full package.
	var/adjusted_amount = amount - offer.export_stock_compensation
	var/total_packages = offer.export_stock_remainder + adjusted_amount
	offer.export_stock_compensation = (total_packages - offer.export_stock_remainder) - adjusted_amount
	var/packages = floor(total_packages)
	offer.export_stock_remainder = total_packages - packages
	SetGoodAmount(category_name, good_id, offer.stock + packages)

/datum/trading_station/proc/DestroyOfferRegistries()
	if(islist(offers))
		for(var/offer_id in offers)
			var/datum/trade_offer/offer = offers[offer_id]
			if(istype(offer))
				qdel(offer)
		offers.Cut()
		offers = null
	if(islist(hidden_offers))
		for(var/offer_id in hidden_offers)
			var/datum/trade_offer/offer = hidden_offers[offer_id]
			if(istype(offer) && !QDELETED(offer))
				qdel(offer)
		hidden_offers.Cut()
		hidden_offers = null
	if(islist(offers_by_category))
		for(var/category_name in offers_by_category)
			var/list/cat_offers = offers_by_category[category_name]
			if(islist(cat_offers))
				cat_offers.Cut()
		offers_by_category.Cut()
		offers_by_category = null
	if(islist(commodity_by_path))
		commodity_by_path.Cut()
		commodity_by_path = null
