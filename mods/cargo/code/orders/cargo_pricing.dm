/datum/controller/subsystem/supply/proc/GetBasicImportCost(good_ref, datum/trading_station/station, category_name = null)
	var/datum/trade_offer/offer = null
	if(istype(station))
		offer = station.GetOffer(good_ref)
		if(!offer && istext(category_name) && islist(station.offers_by_category[category_name]))
			var/list/cat = station.offers_by_category[category_name]
			if(isnum(good_ref) && good_ref >= 1 && good_ref <= length(cat))
				offer = cat[cat[good_ref]]
	if(istype(offer))
		if(offer.has_custom_price)
			return offer.base_price
		var/markup = (istype(station) && isnum(station.markup)) ? station.markup : 1.0
		return max(1, round(offer.base_price * markup))

	. = station ? station.GetGoodPrice(good_ref, category_name) : 0
	var/markup = (istype(station) && isnum(station.markup)) ? station.markup : 1.0
	if(!.)
		var/item_path = null
		if(istype(station))
			item_path = station.GetGoodPath(category_name, good_ref)
		else if(ispath(good_ref, /atom/movable))
			item_path = good_ref
		if(item_path)
			. = get_value(item_path) * markup
	else
		. *= markup
	if(!. || !isnum(.))
		. = 1
	. = max(1, round(.))

/datum/controller/subsystem/supply/proc/GetStationTradeBasePrice(good_ref, datum/trading_station/station, buyer_faction = null, category_name = null)
	. = GetBasicImportCost(good_ref, station, category_name)
	if(!. || !buyer_faction || !istype(station))
		return
	var/buyer_name = buyer_faction
	if(istype(buyer_name, /datum/trade_faction))
		var/datum/trade_faction/F = buyer_name
		buyer_name = F.name
	var/datum/trade_faction/seller = GetFaction(station.faction)
	if(!istype(seller) || !istext(buyer_name))
		return
	switch(seller.relationship[buyer_name])
		if(FACTION_STATE_ANIMOSITY)
			. *= 1.25
		if(FACTION_STATE_RIVAL)
			. *= 1.5
		if(FACTION_STATE_ENEMY)
			. *= 2
		if(FACTION_STATE_WAR)
			. *= 3
	if(buyer_name in seller.trade_markup)
		. *= seller.trade_markup[buyer_name]
	. = max(1, round(.))

/datum/controller/subsystem/supply/proc/GetImportCost(good_ref, datum/trading_station/station, buyer_faction = null, category_name = null)
	return GetStationBuyPrice(good_ref, station, buyer_faction, category_name)
