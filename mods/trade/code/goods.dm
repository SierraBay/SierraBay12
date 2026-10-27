// Eris good_data and offer_data packets, resolved to server-owned records before use.
/datum/trade_good
	var/id
	var/name
	var/category
	var/item_type
	var/stack_size = 0
	var/req_access
	var/datum/trade_station/station
	var/base_price = 0
	var/stock = 0
	var/reserved_stock = 0
	var/min_stock = 1
	var/max_stock = 5
	var/hidden = FALSE

/datum/trade_good/proc/get_price()
	return max(1, ceil(base_price * station.markup))

/datum/trade_good/proc/is_available(hacked = FALSE, mob/user = null, personal = FALSE, obj/item/card/id/card = null)
	if(hidden && !station.hidden_inv_unlocked)
		return FALSE
	if(station.black_market && !hacked)
		return FALSE
	if(personal && req_access && !hacked)
		if(!user || !card)
			return FALSE
		var/list/required = islist(req_access) ? req_access : list(req_access)
		return has_access(required, card.GetAccess())
	return TRUE

/datum/trade_good/proc/spawn_item(atom/location)
	return spawn_trade_item(item_type, stack_size, location)

/datum/trade_good/proc/needs_floor()
	return !ispath(item_type, /obj/item)

/datum/trade_good/proc/get_native_value()
	// Price intrinsic contents too, including components of fixed-price native items.
	var/obj/item/storage/box/preview = new(null)
	var/atom/movable/prototype = spawn_item(preview)
	ASSERT(istype(prototype) && !QDELETED(prototype))
	var/value = 0
	for(var/atom/movable/part as anything in SStrade.get_contents_tree(prototype))
		if(TRADE_TAG_NONEXPORTABLE in part.trade_export_tags)
			continue
		value += max(0, get_value(part, include_contents = FALSE))
	qdel(prototype)
	qdel(preview)
	return value

/datum/trade_good/Destroy()
	station = null
	req_access = null
	return ..()

/datum/trade_offer
	var/id
	var/name
	var/item_type
	var/datum/trade_station/station
	var/unit_price
	var/amount = 1
	var/max_amount = 1
	var/completed = FALSE
	var/live_required = FALSE
	var/reagent_type
	var/reagent_volume = 60
	var/native_stack_size = 1
	var/list/attachments = list()
	var/attach_count = 0

/datum/trade_offer/proc/matches(atom/movable/target)
	if(QDELETED(target) || !check_attachments(target))
		return FALSE
	if(reagent_type)
		return istype(target, /obj/item/reagent_containers) && target.reagents?.get_reagent_amount(reagent_type) >= reagent_volume
	if(!istype(target, item_type))
		return FALSE
	if(istype(target, /obj/item/stack))
		var/obj/item/stack/stack = target
		if(stack.amount < stack.max_amount)
			return FALSE
	if(live_required)
		var/mob/living/animal = target
		return istype(animal) && !animal.mind && !animal.client && animal.stat != DEAD && istype(animal.loc, /obj/machinery/stasis_cage)
	return get_value(target) >= get_value(item_type)

/datum/trade_offer/proc/get_priority()
	return length(splittext("[item_type]", "/")) + (reagent_type ? 100 : 0) + (attach_count ? 1000 : 0)

/datum/trade_offer/proc/balance_price()
	for(var/id in SStrade.goods)
		var/datum/trade_good/good = SStrade.goods[id]
		if(!ispath(good.item_type, item_type))
			continue
		var/quantity = good.stack_size || 1
		unit_price = min(unit_price, max(1, floor(good.get_price() * native_stack_size / quantity * TRADE_HOCKABLE)))

/datum/trade_offer/Destroy()
	attachments.Cut()
	station = null
	return ..()
