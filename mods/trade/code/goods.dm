// Eris good_data and offer_data packets, resolved to server-owned records before use.
/datum/trade_good
	var/id
	var/name
	var/desc = ""
	var/category
	var/item_type
	var/supply_pack_type
	var/stack_size = 0
	var/req_access
	var/security_level
	var/datum/trade_station/station
	var/base_price = 0
	var/export_floor = 0
	var/stock = 0
	var/reserved_stock = 0
	var/min_stock = 1
	var/max_stock = 5
	var/hidden = FALSE
	var/is_bundle = FALSE
	var/randomized_count = 0
	var/container_label = "Personal Locker"
	var/delivery_mode = "personal"
	var/list/contents_preview = list()
	var/list/req_access_flat = list()
	var/list/access_labels = list()
	var/security_level_code
	var/security_label

/datum/trade_good/proc/get_price()
	return max(1, ceil(base_price * station.markup))

/datum/trade_good/proc/sec_available(hacked = FALSE)
	if(hacked || isnull(security_level))
		return TRUE
	if(supply_pack_type)
		var/singleton/hierarchy/supply_pack/pack = GET_SINGLETON(supply_pack_type)
		if(pack)
			return pack.sec_available()
	var/singleton/security_state/security_state = GET_SINGLETON(GLOB.using_map.security_state)
	if(!security_state)
		return TRUE
	var/singleton/security_level/target_level = security_level
	switch(security_level)
		if(SUPPLY_SECURITY_ELEVATED)
			target_level = length(security_state.all_security_levels) > 1 ? security_state.all_security_levels[2] : security_state.high_security_level
		if(SUPPLY_SECURITY_HIGH)
			target_level = security_state.high_security_level
	if(!istype(target_level))
		return TRUE
	return security_state.current_security_level_is_same_or_higher_than(target_level)

/datum/trade_good/proc/is_available(hacked = FALSE, mob/user = null, personal = FALSE, obj/item/card/id/card = null)
	if(hidden && !station.hidden_inv_unlocked)
		return FALSE
	if(station.black_market && !hacked)
		return FALSE
	if(!sec_available(hacked))
		return FALSE
	if(personal && req_access && !hacked)
		if(!user || !card)
			return FALSE
		var/list/required = islist(req_access) ? req_access : list(req_access)
		return has_access(required, card.GetAccess())
	return TRUE

/datum/trade_good/proc/spawn_item(atom/location, buyer_name = null)
	return spawn_trade_good(supply_pack_type, item_type, stack_size, location, req_access, buyer_name)

/datum/trade_good/proc/needs_floor()
	return !!supply_pack_type || !ispath(item_type, /obj/item)

/datum/trade_good/proc/get_native_value()
	if(supply_pack_type)
		return get_pack_export_floor()
	var/obj/item/storage/box/preview = new(null)
	var/atom/movable/prototype = spawn_item(preview)
	var/value = 0
	if(istype(prototype) && !QDELETED(prototype))
		var/datum/trade_appraisal/quote = SStrade.appraise(prototype)
		value = quote.total
		qdel(quote)
		qdel(prototype)
	qdel(preview)
	return value

/datum/trade_good/proc/get_pack_export_floor()
	var/singleton/hierarchy/supply_pack/pack = GET_SINGLETON(supply_pack_type)
	if(!pack)
		return 0
	if(ispath(pack.containertype, /obj/structure/largecrate/animal))
		var/obj/structure/largecrate/animal/animal_crate = pack.containertype
		var/held = initial(animal_crate.held_type)
		if(ispath(held, /mob/living/simple_animal/hostile))
			return 600
		return 300
	var/obj/item/storage/box/preview = new(null)
	var/value = 0
	if(pack.supply_method == /singleton/supply_method/randomized)
		var/max_single = 0
		for(var/cpath in pack.contains)
			if(!ispath(cpath, /atom/movable))
				continue
			var/atom/movable/inst = new cpath(preview)
			var/entry_val = appraise_preview_entry(inst, preview)
			if(entry_val > max_single)
				max_single = entry_val
		value = max_single * max(1, pack.num_contained || 1)
	else
		var/list/spawned = pack.spawn_contents(preview)
		if(islist(spawned))
			for(var/atom/movable/inst as anything in preview.contents.Copy())
				value += appraise_preview_entry(inst, preview)
	for(var/atom/movable/leftover as anything in preview.contents.Copy())
		qdel(leftover)
	qdel(preview)
	return value

/datum/trade_good/proc/appraise_preview_entry(atom/movable/inst, atom/holder)
	if(!istype(inst) || QDELETED(inst))
		return 0
	var/val = 0
	if(istype(inst, /obj/item/sealgen_case))
		var/obj/machinery/sealgen/deployed = new(holder)
		var/datum/trade_appraisal/deploy_quote = SStrade.appraise(deployed)
		val = deploy_quote.total
		qdel(deploy_quote)
		qdel(deployed)
	else
		var/datum/trade_appraisal/quote = SStrade.appraise(inst)
		val = quote.total
		qdel(quote)
	qdel(inst)
	return val

/datum/trade_good/proc/populate_metadata()
	req_access_flat = flatten_trade_access(req_access)
	access_labels = list()
	for(var/acc in req_access_flat)
		var/desc_txt = get_access_desc(acc)
		if(desc_txt)
			access_labels |= desc_txt
	if(security_level == SUPPLY_SECURITY_ELEVATED)
		security_level_code = "elevated"
		security_label = "Blue / Elevated Alert"
	else if(security_level == SUPPLY_SECURITY_HIGH)
		security_level_code = "high"
		security_label = "Red / High Alert"
	else
		security_level_code = null
		security_label = null
	contents_preview = list()
	if(supply_pack_type)
		var/singleton/hierarchy/supply_pack/pack = GET_SINGLETON(supply_pack_type)
		if(pack)
			if(!pack.manifest)
				pack.setup()
			is_bundle = TRUE
			if(pack.supply_method == /singleton/supply_method/randomized)
				randomized_count = max(1, pack.num_contained || 1)
			var/ctype = pack.containertype || /obj/structure/closet/crate
			if(ispath(ctype, /obj/structure/largecrate/animal))
				delivery_mode = "livestock"
				container_label = "Animal Carrier Crate"
				var/obj/structure/largecrate/animal/ac = ctype
				var/atom/held = initial(ac.held_type)
				var/hcnt = max(1, initial(ac.held_count) || 1)
				var/hname = ispath(held) ? initial(held.name) : (pack.containername || pack.name)
				contents_preview += list(list("name" = capitalize(hname), "count" = hcnt))
			else if(ispath(ctype, /obj/structure/largecrate))
				delivery_mode = "large_crate"
				container_label = "Large Wooden Crate"
			else if(ispath(ctype, /obj/structure/closet/crate/secure) || length(req_access_flat))
				delivery_mode = "secure_crate"
				container_label = "Secure Crate"
			else if(ispath(ctype, /obj/structure/closet/crate/freezer))
				delivery_mode = "crate"
				container_label = "Freezer Crate"
			else if(ispath(ctype, /obj/structure/closet) && !ispath(ctype, /obj/structure/closet/crate))
				delivery_mode = "crate"
				container_label = "Storage Locker"
			else if(ispath(ctype, /obj/item/storage))
				delivery_mode = "crate"
				container_label = "Dufflebag / Case"
			else
				delivery_mode = "crate"
				container_label = "Supply Crate"
			if(!length(contents_preview))
				for(var/cpath in pack.contains)
					if(!ispath(cpath))
						continue
					var/atom/A = cpath
					var/cname = initial(A.name) || "[cpath]"
					var/cnt = max(1, pack.contains[cpath] || 1)
					if(ispath(cpath, /obj/item/stack))
						var/obj/item/stack/S = cpath
						var/samt = max(1, initial(S.amount) || 1)
						if(samt > 1)
							cname = "[cname] ([samt])"
					contents_preview += list(list("name" = capitalize(cname), "count" = cnt))
			if(!desc)
				var/summary = randomized_count ? "Any [randomized_count] of: " : "Contains: "
				var/list/parts = list()
				for(var/list/row as anything in contents_preview)
					parts += (row["count"] > 1 && !randomized_count) ? "[row["count"]]x [row["name"]]" : "[row["name"]]"
				desc = length(parts) ? "[summary][jointext(parts, ", ")]." : "Packed freight container delivered directly to receiving pad."
		return
	var/atom/item = item_type
	if(!desc && ispath(item))
		desc = initial(item.desc) || ""
	if(needs_floor())
		delivery_mode = "floor"
		container_label = "Floor Delivery"
	else
		delivery_mode = "personal"
		container_label = "Shipment Locker / Crate"
	var/label_name = name
	if(stack_size > 1)
		label_name = "[name] ([stack_size] units)"
	contents_preview += list(list("name" = label_name, "count" = 1))

/datum/trade_good/Destroy()
	station = null
	req_access = null
	req_access_flat.Cut()
	access_labels.Cut()
	contents_preview.Cut()
	return ..()

/proc/flatten_trade_access(raw_access)
	var/list/flat = list()
	if(isnull(raw_access))
		return flat
	if(!islist(raw_access))
		if(isnum(raw_access) && raw_access > 0)
			flat |= raw_access
		return flat
	for(var/entry in raw_access)
		if(islist(entry))
			for(var/sub in entry)
				if(isnum(sub) && sub > 0)
					flat |= sub
		else if(isnum(entry) && entry > 0)
			flat |= entry
	return flat

/proc/get_implicit_stack_amount(path)
	if(ispath(path, /obj/item/stack))
		var/obj/item/stack/S = path
		return max(1, initial(S.amount) || 1)
	return 1

/proc/get_pack_item_count(singleton/hierarchy/supply_pack/pack)
	if(!pack)
		return 1
	if(pack.supply_method == /singleton/supply_method/randomized)
		return max(1, pack.num_contained || 1)
	var/total = 0
	for(var/cpath in pack.contains)
		total += max(1, pack.contains[cpath] || 1)
	return max(1, total)

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
		var/good_price = good.get_price()
		if(reagent_type)
			if(!good.supply_pack_type)
				if(!ispath(good.item_type, /obj/item/reagent_containers))
					continue
				var/atom/movable/prototype = good.spawn_item(null)
				var/volume = prototype?.reagents?.get_reagent_amount(reagent_type) || 0
				qdel(prototype)
				if(volume > 0)
					unit_price = min(unit_price, max(1, floor(good_price * (reagent_volume / volume) * TRADE_HOCKABLE)))
			else
				var/singleton/hierarchy/supply_pack/pack = GET_SINGLETON(good.supply_pack_type)
				if(!pack)
					continue
				var/n_items = get_pack_item_count(pack)
				for(var/cpath in pack.contains)
					if(!ispath(cpath, /obj/item/reagent_containers))
						continue
					var/atom/movable/sample = new cpath(null)
					var/volume = sample?.reagents?.get_reagent_amount(reagent_type) || 0
					qdel(sample)
					if(volume > 0)
						var/per_item_price = good_price / n_items
						unit_price = min(unit_price, max(1, floor(per_item_price * (reagent_volume / volume) * TRADE_HOCKABLE)))
			continue
		if(!good.supply_pack_type)
			if(!ispath(good.item_type, item_type))
				continue
			var/quantity = good.stack_size || get_implicit_stack_amount(good.item_type)
			unit_price = min(unit_price, max(1, floor(good_price * native_stack_size / quantity * TRADE_HOCKABLE)))
		else
			var/singleton/hierarchy/supply_pack/pack = GET_SINGLETON(good.supply_pack_type)
			if(!pack)
				continue
			var/is_rand = (pack.supply_method == /singleton/supply_method/randomized)
			var/total_cnt = get_pack_item_count(pack)
			for(var/cpath in pack.contains)
				if(!ispath(cpath, item_type))
					continue
				var/cnt = is_rand ? max(1, pack.num_contained || 1) : max(1, pack.contains[cpath] || 1)
				var/c_stk = get_implicit_stack_amount(cpath)
				var/unit_buy = (good_price / (is_rand ? cnt : total_cnt)) * (native_stack_size / c_stk)
				unit_price = min(unit_price, max(1, floor(unit_buy * TRADE_HOCKABLE)))

/datum/trade_offer/Destroy()
	attachments.Cut()
	station = null
	return ..()
