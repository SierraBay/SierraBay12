/datum/trading_station
	var/name
	var/desc
	var/uid
	var/list/name_pool = list()
	var/icon = 'mods/cargo/icons/trading_stations.dmi'
	var/list/icon_states = list("trade")
	var/initialized = FALSE

	var/favor = 0
	var/unlock_favor = 5000
	var/faction = FACTION_INDEPENDENT
	var/list/random_factions = list()

	var/spawn_always = FALSE
	var/spawn_probability = 60
	var/spawn_cost = 1
	var/start_hidden = FALSE
	var/trade_range = 1
	var/supports_contracts = TRUE
	var/can_host_caravans = TRUE
	var/is_mobile = FALSE

	var/list/offers = list()
	var/list/offers_by_category = list()
	var/list/commodity_by_path = list()
	var/list/hidden_offers = list()

	var/list/inventory = list()
	var/hidden_inv_unlocked = FALSE
	var/list/hidden_inventory = list()
	var/list/amounts_of_goods = list()
	var/unique_good_count = 0
	var/next_good_offer_id = 0

	var/markup = 1.2
	var/base_income = 1600
	var/wealth = 0

	var/metabolism_enabled = TRUE
	var/max_production_multiplier = 2.0
	var/min_consumption_reserve = 1
	var/metabolic_consumption_wealth_ratio = 0.35
	var/metabolic_production_cost_ratio = 0.40
	var/list/metabolic_production_tags = list()
	var/list/metabolic_consumption_tags = list()

	var/update_time = 0
	var/update_timer_start = 0
	var/next_update_at = 0

	var/obj/overmap/overmap_object
	var/turf/overmap_location
	var/list/forced_overmap_zone
	var/overmap_opacity = 0
	var/use_smart_overmap_placement = TRUE
	var/min_overmap_station_spacing = 5
	var/min_distance_from_base = 4
	var/preferred_distance_from_base = 10
	var/max_distance_from_base = 18
	var/hazard_buffer = 1
	var/placement_attempt_sample = 250

	var/list/whitelist_factions
	var/list/blacklist_factions
	var/list/thematic_cores = list("Apex", "Zenith", "Horizon", "Pioneer", "Frontier", "Endeavor", "Atlas", "Beacon", "Prometheus", "Orion", "Nova", "Eclipse")
	var/role_summary = "automated commercial supply and merchant transshipment"

/datum/trading_station/New(init_on_new)
	. = ..()
	CopyConfigurationLists()
	if(init_on_new)
		InitSrc()

/datum/trading_station/proc/CopyConfigurationLists()
	whitelist_factions = islist(whitelist_factions) ? whitelist_factions.Copy() : list()
	blacklist_factions = islist(blacklist_factions) ? blacklist_factions.Copy() : list()
	metabolic_production_tags = islist(metabolic_production_tags) ? metabolic_production_tags.Copy() : list()
	metabolic_consumption_tags = islist(metabolic_consumption_tags) ? metabolic_consumption_tags.Copy() : list()
	if(islist(thematic_cores))
		thematic_cores = thematic_cores.Copy()
	else
		thematic_cores = list("Apex", "Zenith", "Horizon", "Pioneer", "Frontier", "Endeavor", "Atlas", "Beacon", "Prometheus", "Orion", "Nova", "Eclipse")

/datum/trading_station/proc/GetFacilitySuffix()
	var/list/facility_suffixes = list("Depot", "Outpost", "Relay", "Hub", "Platform", "Terminal", "Exchange", "Array", "Facility")
	return prob(65) ? " [pick(facility_suffixes)]" : ""

/datum/trading_station/proc/GetNamingPrefixData()
	if(faction == FACTION_INDIE_CONFED)
		return list("short" = pick("TTB", "CTB", "PTB"), "full" = "Terran Trade Beacon")
	if(faction == FACTION_NANOTRASEN)
		return list("short" = pick("NTB", "NSB"), "full" = "NanoTrasen Beacon")
	return list("short" = pick("FTB", "ISB", "OSB", "ASB"), "full" = "Free Trade Beacon")

/datum/trading_station/proc/GetThematicCores()
	return thematic_cores

/datum/trading_station/proc/GetRoleSummary()
	return role_summary

/datum/trading_station/proc/GetFaction()
	return SSsupply.GetFaction(faction)

/datum/trading_station/proc/InitSrc(turf/station_loc = null, force_discovered = FALSE)
	var/turf/spawn_turf = ResolveOvermapSpawnLocation(station_loc)
	AssignStationIdentity(spawn_turf)
	AssembleInventory()
	InitGoods()
	UpdateTick()
	SetupOvermapPlacement(spawn_turf, force_discovered)
	RegisterStation()

/datum/trading_station/proc/AssignStationIdentity(turf/station_loc = null)
	if(name)
		CRASH("[type] trade station had name set before InitSrc() was called!")
	if(LAZYLEN(random_factions))
		faction = pick(random_factions)

	var/list/available_names = islist(name_pool) ? name_pool.Copy() : list()
	for(var/datum/trading_station/other_station as anything in SSsupply?.all_trading_stations)
		if(other_station.name)
			available_names.Remove(other_station.name)

	if(length(available_names))
		name = pick(available_names)
		desc = available_names[name]
	else
		log_debug("Trade station name pool exhausted for [type]; generating procedural identity.")
		AssignProceduralIdentity(station_loc)

	uid ||= "[type]_[random_id(type, 100, 999)]"

/datum/trading_station/proc/AssignProceduralIdentity(turf/station_loc = null)
	var/turf/target_turf = istype(station_loc) ? station_loc : overmap_location
	var/list/identity = GenerateProceduralStationIdentity(src, target_turf)
	name = identity["name"]
	desc = identity["desc"]
	if(!name)
		name = "[initial(name) || "Trade Station"] [random_id(type, 100, 999)]"
	if(!desc)
		desc = initial(desc) || "An automated merchant outpost."

/datum/trading_station/proc/SetupOvermapPlacement(turf/station_loc = null, force_discovered = FALSE)
	if(start_hidden)
		start_hidden = !force_discovered

	if(!GLOB.using_map.use_overmap)
		start_hidden = FALSE
		return

	var/turf/spawn_turf = ResolveOvermapSpawnLocation(station_loc)
	if(istype(spawn_turf))
		PlaceOvermap(spawn_turf.x, spawn_turf.y, spawn_turf.z)

/datum/trading_station/proc/RegisterStation()
	SSsupply.all_trading_stations += src
	if(start_hidden)
		SSsupply.hidden_trading_stations += src
	else
		SSsupply.visible_trading_stations += src

/datum/trading_station/proc/ResolveOvermapSpawnLocation(turf/station_loc = null)
	if(!GLOB.using_map?.overmap_z)
		return null
	if(istype(station_loc))
		return station_loc
	if(use_smart_overmap_placement)
		var/turf/smart_turf = FindSmartOvermapSpawnLocation(GLOB.using_map.overmap_z)
		if(istype(smart_turf))
			return smart_turf
	return FindFallbackOvermapSpawnLocation(GLOB.using_map.overmap_z)

/datum/trading_station/proc/FindFallbackOvermapSpawnLocation(spawn_z)
	var/list/candidate_turfs = GetOvermapSpawnCandidateTurfs(spawn_z)
	if(!length(candidate_turfs))
		return null
	return pick(candidate_turfs)

/datum/trading_station/proc/FindSmartOvermapSpawnLocation(spawn_z)
	var/list/candidate_turfs = GetOvermapSpawnCandidateTurfs(spawn_z)
	if(!length(candidate_turfs))
		return null

	if(isnum(placement_attempt_sample) && placement_attempt_sample > 0 && length(candidate_turfs) > placement_attempt_sample)
		candidate_turfs = SampleOvermapSpawnCandidates(candidate_turfs, placement_attempt_sample)

	var/list/weighted_candidates = list()
	var/best_score = null
	for(var/turf/candidate as anything in candidate_turfs)
		var/score = ScoreOvermapSpawnLocation(candidate)
		if(!isnum(score) || score <= 0)
			continue
		weighted_candidates[candidate] = score
		if(isnull(best_score) || score > best_score)
			best_score = score

	if(length(weighted_candidates))
		return pickweight(weighted_candidates)
	return null

/datum/trading_station/proc/SampleOvermapSpawnCandidates(list/candidate_turfs, sample_size)
	if(!islist(candidate_turfs) || !length(candidate_turfs) || !isnum(sample_size) || sample_size <= 0)
		return candidate_turfs
	if(length(candidate_turfs) <= sample_size)
		return candidate_turfs.Copy()

	var/list/pool = candidate_turfs.Copy()
	var/list/sampled = list()
	for(var/i in 1 to sample_size)
		if(!length(pool))
			break
		var/picked = pick(pool)
		pool -= picked
		sampled += picked
	return sampled

/datum/trading_station/proc/GetOvermapSpawnCandidateTurfs(spawn_z)
	if(!spawn_z)
		return list()

	var/map_low = OVERMAP_EDGE
	var/map_high = GLOB.using_map.overmap_size - OVERMAP_EDGE
	var/min_x = map_low
	var/max_x = map_high
	var/min_y = map_low
	var/max_y = map_high
	if(islist(forced_overmap_zone) && length(forced_overmap_zone) >= 2)
		var/list/x_bounds = forced_overmap_zone[1]
		var/list/y_bounds = forced_overmap_zone[2]
		if(islist(x_bounds) && length(x_bounds) >= 2 && islist(y_bounds) && length(y_bounds) >= 2)
			min_x = max(map_low, x_bounds[1])
			max_x = min(map_high, x_bounds[2])
			min_y = max(map_low, y_bounds[1])
			max_y = min(map_high, y_bounds[2])

	if(min_x > max_x || min_y > max_y)
		return list()

	var/list/result = list()
	for(var/turf/candidate as anything in block(locate(min_x, min_y, spawn_z), locate(max_x, max_y, spawn_z)))
		if(!CanUseOvermapSpawnLocation(candidate))
			continue
		result += candidate
	return result

/datum/trading_station/proc/CanUseOvermapSpawnLocation(turf/candidate)
	ASSERT(istype(candidate, /turf))
	if(!istype(candidate, /turf/unsimulated/map) || istype(candidate, /turf/unsimulated/map/edge))
		return FALSE
	if(locate(/obj/overmap/visitable) in candidate)
		return FALSE
	if(locate(/obj/overmap/trade_beacon) in candidate)
		return FALSE
	if(length(overmap_event_handler.hazard_by_turf[candidate]))
		return FALSE
	if(hazard_buffer > 0)
		for(var/turf/nearby as anything in RANGE_TURFS(candidate, hazard_buffer))
			if(nearby == candidate)
				continue
			if(length(overmap_event_handler.hazard_by_turf[nearby]))
				return FALSE
	return TRUE

/datum/trading_station/proc/ScoreOvermapSpawnLocation(turf/candidate)
	ASSERT(istype(candidate, /turf))
	if(!CanUseOvermapSpawnLocation(candidate))
		return 0

	var/score = 100
	var/nearest_station_distance = GetNearestTradeStationDistance(candidate)
	if(isnum(nearest_station_distance))
		if(nearest_station_distance < min_overmap_station_spacing)
			return 0
		score += min(nearest_station_distance, 12) * 10

	var/base_distance = GetBaseDistance(candidate)
	if(isnum(base_distance))
		if(base_distance < min_distance_from_base)
			return 0
		if(isnum(max_distance_from_base) && max_distance_from_base > 0 && base_distance > max_distance_from_base)
			score -= min((base_distance - max_distance_from_base) * 6, 60)
		if(isnum(preferred_distance_from_base) && preferred_distance_from_base > 0)
			score += max(0, 60 - (abs(base_distance - preferred_distance_from_base) * 8))

	score += GetOpenSpaceScore(candidate)
	return max(0, round(score))

/datum/trading_station/proc/GetNearestTradeStationDistance(turf/candidate)
	ASSERT(istype(candidate, /turf))
	var/nearest = null
	for(var/datum/trading_station/other_station as anything in SSsupply.all_trading_stations)
		if(other_station == src || !istype(other_station.overmap_location))
			continue
		var/distance = get_dist(candidate, other_station.overmap_location)
		if(isnull(nearest) || distance < nearest)
			nearest = distance
	return nearest

/datum/trading_station/proc/GetBaseDistance(turf/candidate)
	ASSERT(istype(candidate, /turf))
	var/obj/overmap/visitable/base_sector = GetPrimaryBaseSector()
	if(!istype(base_sector) || base_sector.z != candidate.z)
		return null
	return get_dist(candidate, base_sector)

/datum/trading_station/proc/GetPrimaryBaseSector()
	for(var/key in map_sectors)
		var/obj/overmap/visitable/sector = map_sectors[key]
		if(istype(sector) && HAS_FLAGS(sector.sector_flags, OVERMAP_SECTOR_BASE))
			return sector
	return null

/datum/trading_station/proc/GetOpenSpaceScore(turf/candidate)
	ASSERT(istype(candidate, /turf))
	var/score = 0
	for(var/turf/nearby as anything in RANGE_TURFS(candidate, 2))
		if(nearby == candidate)
			continue
		if(!istype(nearby, /turf/unsimulated/map) || istype(nearby, /turf/unsimulated/map/edge))
			continue
		if(locate(/obj/overmap/visitable) in nearby)
			score -= 12
			continue
		if(locate(/obj/overmap/trade_beacon) in nearby)
			score -= 10
			continue
		if(length(overmap_event_handler.hazard_by_turf[nearby]))
			score -= 16
			continue
		score += 2
	return score

/datum/trading_station/proc/PlaceOvermap(spawn_x, spawn_y, spawn_z = GLOB.using_map.overmap_z)
	if(!spawn_z)
		return

	var/turf/new_location = locate(spawn_x, spawn_y, spawn_z)
	UpdateOvermapLocation(new_location)
	if(!overmap_location)
		return

	var/overmap_type = GetOvermapObjectType()
	overmap_object = new overmap_type(overmap_location)
	overmap_object.name = GetOvermapName()
	overmap_object.desc = GetOvermapDesc()
	overmap_object.scanner_desc = GetOvermapScannerDesc()
	overmap_object.opacity = overmap_opacity
	overmap_object.dir = pick(rand(1, 2), 4, 8)
	if(icon)
		overmap_object.icon = icon
	overmap_object.icon_state = pick(icon_states)

	if(start_hidden)
		overmap_object.color = "#444444"

/datum/trading_station/proc/UpdateOvermapLocation(turf/new_location)
	if(overmap_location == new_location)
		return
	if(overmap_location && start_hidden)
		GLOB.entered_event.unregister(overmap_location, src, .proc/Discovered)
	overmap_location = new_location
	if(overmap_location && start_hidden)
		GLOB.entered_event.register(overmap_location, src, .proc/Discovered)

/datum/trading_station/proc/GetOvermapObjectType()
	return /obj/overmap/trade_beacon

/datum/trading_station/proc/GetOvermapName()
	return name || "Trade Beacon"

/datum/trading_station/proc/GetOvermapDesc()
	if(desc)
		return desc
	return "A long-range commercial beacon offering remote trade services."

/datum/trading_station/proc/GetOvermapScannerDesc()
	var/faction_name = faction || FACTION_INDEPENDENT
	return {"\[i\]Registration\[/i\]: [GetOvermapName()]
\[i\]Class\[/i\]: Commercial Trade Beacon
\[i\]Transponder\[/i\]: Transmitting (CIV), [faction_name]
\[b\]Notice\[/b\]: [GetOvermapDesc()]"}

/datum/trading_station/proc/GetAvailabilityBlockReason(atom/source = null)
	return null

/datum/trading_station/proc/GetAvailabilityStatusData()
	return null

/datum/trading_station/proc/GetAvailabilityWindowRemaining()
	return null

/datum/trading_station/proc/Discovered(_, atom/movable/O)
	if(istype(O, /obj/overmap/visitable/ship))
		// Mobile ship or shuttle discovered the station
	else if(istype(O, /obj/overmap/visitable/sector))
		var/obj/overmap/visitable/sector/S = O
		if(!HAS_FLAGS(S.sector_flags, OVERMAP_SECTOR_BASE))
			return
	else
		return

	start_hidden = FALSE
	SSsupply.hidden_trading_stations -= src
	if(!(src in SSsupply.visible_trading_stations))
		SSsupply.visible_trading_stations += src
	if(overmap_object)
		overmap_object.color = null
	if(overmap_location)
		GLOB.entered_event.unregister(overmap_location, src, .proc/Discovered)

/datum/trading_station/proc/AssembleInventory()
	NormalizeGoodsRecords()

/datum/trading_station/proc/ResetOfferRegistries()
	offers = list()
	offers_by_category = list()
	commodity_by_path = list()
	hidden_offers = list()
	amounts_of_goods = list()
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
	var/category_name = isnum(category_ref) ? inventory[category_ref] : category_ref
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
	var/list/raw_inv = inventory
	var/list/raw_hidden = hidden_inventory
	ResetOfferRegistries()
	inventory = raw_inv
	hidden_inventory = raw_hidden
	PopulateOffers()
	inventory = offers_by_category
	SyncAmountsOfGoods()

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
		offer.stock = max(0, rand(amount_range[1], amount_range[2]))
		offer.baseline_stock = max(1, round((amount_range[1] + amount_range[2]) / 2))
	else
		var/cost = offer.base_price || 100
		var/min_val = is_hidden ? 1 : 5
		var/max_val = max(min_val, round(30 / max(cost / 200, 1)))
		offer.stock = max(0, rand(min_val, max_val))
		offer.baseline_stock = max(1, offer.stock)

/datum/trading_station/proc/SyncAmountsOfGoods()
	amounts_of_goods = list()
	for(var/category_name in offers_by_category)
		var/list/cat_offers = offers_by_category[category_name]
		if(!islist(cat_offers))
			continue
		var/list/cat_amounts = list()
		for(var/offer_id in cat_offers)
			var/datum/trade_offer/offer = cat_offers[offer_id]
			if(istype(offer))
				cat_amounts[offer_id] = offer.stock
		amounts_of_goods[category_name] = cat_amounts

/datum/trading_station/proc/GenerateGoodOfferId()
	var/offer_id = "good_[++next_good_offer_id]"
	while(offers[offer_id])
		offer_id = "good_[++next_good_offer_id]"
	return offer_id

/datum/trading_station/proc/InitGoods()
	SyncAmountsOfGoods()
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
		var/category_name = offer.category || "General"
		if(!islist(amounts_of_goods[category_name]))
			amounts_of_goods[category_name] = list()
		var/list/cat_amounts = amounts_of_goods[category_name]
		cat_amounts[offer.id] = offer.stock
	hidden_offers.Cut()
	UpdateVisibleGoodCount()

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
	if(!islist(inventory) || !length(inventory) || !islist(filter_tags) || !length(filter_tags))
		return candidates

	for(var/category_name in inventory)
		var/list/category = inventory[category_name]
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
	for(var/category_name in inventory)
		var/list/category = inventory[category_name]
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

/datum/trading_station/proc/GetGoodPacket(category_name, good_ref)
	if(isnum(category_name))
		category_name = inventory[category_name]
	var/datum/trade_offer/offer = ResolveOffer(category_name, good_ref)
	if(istype(offer))
		return list(
			"item_path" = offer.item_path,
			"name" = offer.name,
			"desc" = offer.desc,
			"price" = offer.base_price,
			"amount_range" = list(offer.stock, offer.stock),
			"offer" = offer
		)
	if(!istext(category_name) || !good_ref || !islist(inventory))
		return null
	var/list/category = inventory[category_name]
	return islist(category) ? category[good_ref] : null

/datum/trading_station/proc/GetGoodPath(category_name, good_ref)
	var/datum/trade_offer/offer = ResolveOffer(category_name, good_ref)
	if(istype(offer))
		return ispath(offer.item_path, /atom/movable) ? offer.item_path : null
	var/list/good_packet = GetGoodPacket(category_name, good_ref)
	var/item_path = islist(good_packet) ? good_packet["item_path"] : null
	return ispath(item_path, /atom/movable) ? item_path : null

/datum/trading_station/proc/GetGoodName(category_name, good_ref)
	var/datum/trade_offer/offer = ResolveOffer(category_name, good_ref)
	if(istype(offer))
		return offer.name || "[good_ref]"
	var/list/good_packet = GetGoodPacket(category_name, good_ref)
	if(islist(good_packet) && good_packet["name"])
		return good_packet["name"]
	return "[good_ref]"

/datum/trading_station/proc/GetGoodPrice(good_ref, category_name = null)
	var/datum/trade_offer/offer = ResolveOffer(category_name, good_ref)
	if(istype(offer))
		return offer.base_price
	var/list/good_packet = GetGoodPacket(category_name, good_ref)
	if(islist(good_packet) && isnum(good_packet["price"]))
		return good_packet["price"]
	return 0

/datum/trading_station/proc/GetGoodAmount(category_ref, good_ref)
	var/category_name = isnum(category_ref) ? inventory[category_ref] : category_ref
	var/datum/trade_offer/offer = ResolveOffer(category_name, good_ref)
	if(istype(offer))
		return offer.stock
	if(!istext(category_name) || !islist(amounts_of_goods))
		return 0
	var/list/goods = amounts_of_goods[category_name]
	var/list/category = inventory[category_name]
	if(!islist(goods) || !islist(category))
		return 0
	var/good_id = isnum(good_ref) ? category[good_ref] : good_ref
	return goods[good_id] || 0

/datum/trading_station/proc/SetGoodAmount(category_ref, good_ref, value)
	if(!isnum(value))
		return
	var/category_name = isnum(category_ref) ? inventory[category_ref] : category_ref
	var/stock = max(0, round(value))
	var/datum/trade_offer/offer = ResolveOffer(category_name, good_ref)
	if(istype(offer))
		offer.stock = stock
	if(!istext(category_name) || !islist(amounts_of_goods))
		return
	var/list/goods = amounts_of_goods[category_name]
	var/list/category = inventory[category_name]
	if(!islist(goods) || !islist(category))
		return
	var/good_id = isnum(good_ref) ? category[good_ref] : good_ref
	goods[good_id] = stock

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

/datum/trading_station/Destroy()
	if(overmap_location)
		GLOB.entered_event.unregister(overmap_location, src, .proc/Discovered)
		overmap_location = null
	if(overmap_object)
		var/obj/overmap/saved_obj = overmap_object
		overmap_object = null
		if(!istype(saved_obj, /obj/overmap/visitable))
			qdel(saved_obj)
	if(SSsupply)
		SSsupply.PurgeStationFromOrders(src)
		SSsupply.all_trading_stations -= src
		SSsupply.visible_trading_stations -= src
		SSsupply.hidden_trading_stations -= src
	if(islist(metabolic_production_tags))
		metabolic_production_tags.Cut()
		metabolic_production_tags = null
	if(islist(metabolic_consumption_tags))
		metabolic_consumption_tags.Cut()
		metabolic_consumption_tags = null
	DestroyOfferRegistries()
	return ..()

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
	if(islist(amounts_of_goods))
		for(var/category_name in amounts_of_goods)
			var/list/cat_amts = amounts_of_goods[category_name]
			if(islist(cat_amts))
				cat_amts.Cut()
		amounts_of_goods.Cut()
		amounts_of_goods = null
	inventory = null
	hidden_inventory = null
