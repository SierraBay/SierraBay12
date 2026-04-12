/obj/overmap/trade_beacon
	name = "trade beacon"
	desc = "A long-range commercial beacon offering remote trade services."
	scannable = TRUE
	requires_contact = TRUE
	instant_contact = TRUE
	icon_state = "trading_station"

/datum/trading_station
	var/name
	var/desc
	var/uid
	var/list/name_pool = list()
	var/list/icon_states = list("trading_station")
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

	var/list/inventory = list()
	var/hidden_inv_unlocked = FALSE
	var/list/hidden_inventory = list()
	var/list/legacy_supply_roots = list()
	var/list/amounts_of_goods = list()
	var/unique_good_count = 0
	var/next_good_offer_id = 0

	var/markup = 1.2
	var/base_income = 1600
	var/wealth = 0

	var/update_time = 0
	var/update_timer_start = 0

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

	var/list/whitelist_factions = list()
	var/list/blacklist_factions = list()

/datum/trading_station/New(init_on_new)
	. = ..()
	if(init_on_new)
		InitSrc()

/datum/trading_station/Destroy()
	if(overmap_location && start_hidden)
		GLOB.entered_event.unregister(overmap_location, src, .proc/Discovered)
	if(SSsupply)
		SSsupply.all_trading_stations -= src
		SSsupply.hidden_trading_stations -= src
		SSsupply.visible_trading_stations -= src
	QDEL_NULL(overmap_object)
	overmap_location = null
	return ..()

/datum/trading_station/proc/GetFaction()
	return SSsupply.GetFaction(faction)

/datum/trading_station/proc/InitSrc(turf/station_loc = null, force_discovered = FALSE)
	if(name)
		CRASH("[type] trade station had name set before InitSrc() was called!")

	for(var/datum/trading_station/other_station as anything in SSsupply.all_trading_stations)
		name_pool.Remove(other_station.name)
		if(!length(name_pool))
			warning("Trade station name pool exhausted: [type]")
			name_pool = other_station.name_pool.Copy()
			break

	name = pick(name_pool)
	desc = name_pool[name]

	AssembleInventory()
	InitGoods()
	UpdateTick()

	if(start_hidden)
		start_hidden = !force_discovered

	if(LAZYLEN(random_factions))
		faction = pick(random_factions)

	if(!GLOB.using_map.use_overmap)
		start_hidden = FALSE
	else
		var/turf/spawn_turf = ResolveOvermapSpawnLocation(station_loc)
		if(istype(spawn_turf))
			PlaceOvermap(spawn_turf.x, spawn_turf.y, spawn_turf.z)

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

	var/list/sampled_candidates = list()
	var/list/used_indices = list()
	while(length(sampled_candidates) < sample_size && length(used_indices) < length(candidate_turfs))
		var/sample_index = rand(1, length(candidate_turfs))
		if(used_indices["[sample_index]"])
			continue
		used_indices["[sample_index]"] = TRUE
		sampled_candidates += candidate_turfs[sample_index]
	return sampled_candidates

/datum/trading_station/proc/GetOvermapSpawnCandidateTurfs(spawn_z)
	if(!spawn_z)
		return list()

	var/map_low = OVERMAP_EDGE
	var/map_high = GLOB.using_map.overmap_size - OVERMAP_EDGE
	var/min_x = map_low
	var/max_x = map_high
	var/min_y = map_low
	var/max_y = map_high
	if(recursive_list_len(forced_overmap_zone) == 6)
		min_x = max(map_low, forced_overmap_zone[1][1])
		max_x = min(map_high, forced_overmap_zone[1][2])
		min_y = max(map_low, forced_overmap_zone[2][1])
		max_y = min(map_high, forced_overmap_zone[2][2])

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
		for(var/turf/nearby as anything in orange(hazard_buffer, candidate))
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
	for(var/turf/nearby as anything in orange(2, candidate))
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

/datum/trading_station/proc/Discovered(_, obj/overmap/visitable/ship)
	if(!istype(ship) || !(HAS_FLAGS(ship.sector_flags, OVERMAP_SECTOR_BASE)))
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
	BuildLegacyInventory()
	NormalizeInventory(inventory)
	NormalizeInventory(hidden_inventory)
	NormalizeGoodsRecords()

/datum/trading_station/proc/NormalizeInventory(list/target_inventory)
	if(!islist(target_inventory))
		return
	for(var/category_name as anything in target_inventory)
		if(!islist(category_name))
			continue
		var/list/category_packet = category_name
		if(length(category_packet) < 2 || !("name" in category_packet))
			continue
		var/new_category_name = category_packet["name"]
		var/list/content = target_inventory[category_packet]
		if(!istext(new_category_name) || !islist(content))
			continue
		var/category_name_index = target_inventory.Find(category_packet)
		target_inventory.Cut(category_name_index, category_name_index + 1)
		target_inventory.Insert(category_name_index, new_category_name)
		target_inventory[new_category_name] = content

/datum/trading_station/proc/BuildLegacyInventory()
	var/list/root_types = legacy_supply_roots
	if(!LAZYLEN(root_types) && ("legacy_station_group_type" in vars))
		var/group_type = vars["legacy_station_group_type"]
		if(ispath(group_type, /datum/legacy_station_group))
			var/datum/legacy_station_group/group = new group_type
			root_types = group.root_categories
	if(!LAZYLEN(root_types))
		return
	for(var/root_type in root_types)
		var/list/pack_map = GET_SINGLETON_SUBTYPE_MAP(root_type)
		for(var/pack_type in pack_map)
			if(pack_type == root_type)
				continue
			var/singleton/hierarchy/supply_pack/supply_pack = pack_map[pack_type]
			if(!istype(supply_pack) || !length(supply_pack.contains) || !supply_pack.sec_available())
				continue
			var/item_count = GetLegacyPackItemCount(supply_pack)
			var/category_name = GetLegacyPackCategoryName(supply_pack, root_type)
			var/list/target_inventory = (supply_pack.hidden || supply_pack.contraband) ? hidden_inventory : inventory
			for(var/item_path in supply_pack.contains)
				RegisterLegacyPackItem(target_inventory, category_name, item_path, supply_pack, item_count)

/datum/trading_station/proc/NormalizeGoodsRecords()
	NormalizeGoodsRecordsFor(inventory)
	NormalizeGoodsRecordsFor(hidden_inventory)

/datum/trading_station/proc/NormalizeGoodsRecordsFor(list/target_inventory)
	if(!islist(target_inventory))
		return
	for(var/category_name in target_inventory.Copy())
		var/list/category = target_inventory[category_name]
		if(!islist(category))
			continue
		target_inventory[category_name] = NormalizeGoodCategory(category)

/datum/trading_station/proc/NormalizeGoodCategory(list/category)
	var/list/normalized = list()
	if(!islist(category))
		return normalized
	for(var/good_ref in category)
		var/list/source_packet = category[good_ref]
		var/item_path = null
		if(islist(source_packet) && ispath(source_packet["item_path"], /atom/movable))
			item_path = source_packet["item_path"]
		else if(ispath(good_ref, /atom/movable))
			item_path = good_ref
		if(!ispath(item_path, /atom/movable))
			continue
		normalized[GenerateGoodOfferId()] = BuildGoodPacket(item_path, source_packet)
	return normalized

/datum/trading_station/proc/GenerateGoodOfferId()
	return "good_[++next_good_offer_id]"

/datum/trading_station/proc/BuildGoodPacket(item_path, list/source_packet = null)
	var/list/good_packet = islist(source_packet) ? source_packet.Copy() : list()
	good_packet["item_path"] = item_path
	if(!("name" in good_packet))
		good_packet["name"] = null
	if(!("amount_range" in good_packet))
		good_packet["amount_range"] = null
	if(!("price" in good_packet))
		good_packet["price"] = null
	return good_packet

/datum/trading_station/proc/GetLegacyPackItemCount(singleton/hierarchy/supply_pack/supply_pack)
	if(!istype(supply_pack))
		return 1
	if(isnum(supply_pack.num_contained) && supply_pack.num_contained > 0)
		return supply_pack.num_contained
	. = 0
	for(var/item_path in supply_pack.contains)
		. += max(1, supply_pack.contains[item_path])
	return max(1, .)

/datum/trading_station/proc/GetLegacyPackCategoryName(singleton/hierarchy/supply_pack/supply_pack, root_type)
	var/root_name = GetLegacyRootName(root_type)
	if(!istype(supply_pack) || !supply_pack.name)
		return root_name
	var/separator = findtext(supply_pack.name, " - ")
	if(separator > 1)
		return copytext(supply_pack.name, 1, separator)
	return root_name

/datum/trading_station/proc/GetLegacyRootName(root_type)
	var/list/path_bits = splittext("[root_type]", "/")
	if(!length(path_bits))
		return "Legacy"
	var/root_name = path_bits[path_bits.len]
	root_name = replacetext(root_name, "_", " ")
	if(length(root_name) <= 1)
		return uppertext(root_name)
	return "[uppertext(copytext(root_name, 1, 2))][copytext(root_name, 2)]"

/datum/trading_station/proc/GetLegacyGoodName(singleton/hierarchy/supply_pack/supply_pack, item_path, item_count)
	if(istype(supply_pack) && item_count == 1 && supply_pack.name)
		return supply_pack.name
	var/atom/movable/item_type = item_path
	return ispath(item_path, /atom/movable) ? initial(item_type.name) : null

/datum/trading_station/proc/RegisterLegacyPackItem(list/target_inventory, category_name, item_path, singleton/hierarchy/supply_pack/supply_pack, item_count)
	if(!islist(target_inventory) || !istext(category_name) || !istype(supply_pack) || !ispath(item_path, /atom/movable))
		return
	if(!islist(target_inventory[category_name]))
		target_inventory[category_name] = list()
	var/list/category = target_inventory[category_name]
	var/legacy_cost = isnum(supply_pack.cost) ? supply_pack.cost * CARGO_POINT_TO_THALLER : get_value(item_path)
	var/unit_price = max(1, round(legacy_cost / max(1, item_count)))
	var/name_override = GetLegacyGoodName(supply_pack, item_path, item_count)
	var/list/good_packet = GOODS_DATA(name_override, null, unit_price)
	good_packet["item_path"] = item_path
	category[GenerateGoodOfferId()] = good_packet

/datum/trading_station/proc/InitGoods()
	for(var/category_name in inventory)
		var/list/category = inventory[category_name]
		if(!islist(category))
			continue
		for(var/good_id in category)
			var/cost = SSsupply.GetImportCost(good_id, src, null, category_name)
			var/list/rand_args = list(5, max(5, round(30 / max(cost / 200, 1))))
			var/list/good_packet = category[good_id]
			if(islist(good_packet) && islist(good_packet["amount_range"]))
				rand_args = good_packet["amount_range"]
			if(!islist(amounts_of_goods[category_name]))
				amounts_of_goods[category_name] = list()
			var/list/content = amounts_of_goods[category_name]
			content[good_id] = max(0, rand(rand_args[1], rand_args[2]))
			unique_good_count += 1

/datum/trading_station/proc/TryUnlockHiddenInv()
	if(favor < unlock_favor || hidden_inv_unlocked)
		return

	hidden_inv_unlocked = TRUE
	for(var/category_name in hidden_inventory)
		var/list/category = hidden_inventory[category_name]
		if(!istext(category_name) || !islist(category))
			continue
		if(!(category_name in inventory))
			inventory[category_name] = list()
		var/list/visible_category = inventory[category_name]
		for(var/good_id in category)
			visible_category[good_id] = category[good_id]
			var/cost = SSsupply.GetImportCost(good_id, src, null, category_name)
			var/list/rand_args = list(1, max(1, round(30 / max(cost / 200, 1))))
			var/list/good_packet = category[good_id]
			if(islist(good_packet) && islist(good_packet["amount_range"]))
				rand_args = good_packet["amount_range"]
			if(!islist(amounts_of_goods[category_name]))
				amounts_of_goods[category_name] = list()
			var/list/content = amounts_of_goods[category_name]
			content[good_id] = max(0, rand(rand_args[1], rand_args[2]))
			unique_good_count += 1

/datum/trading_station/proc/SpendTradeStationsBudget(budget = spawn_cost)
	if(!spawn_always)
		SSsupply.trade_stations_budget -= budget

/datum/trading_station/proc/RegainTradeStationsBudget(budget = spawn_cost)
	if(!spawn_always)
		SSsupply.trade_stations_budget += budget

/datum/trading_station/proc/UpdateTick()
	if(initialized)
		GoodsTick()
	else
		initialized = TRUE
	update_time = rand(6, 8) MINUTES
	update_timer_start = world.time
	addtimer(new Callback(src, .proc/UpdateTick), update_time, TIMER_STOPPABLE)

/datum/trading_station/proc/GoodsTick()
	wealth += base_income

	var/starting_balance = wealth
	var/budget = unique_good_count ? round(starting_balance / unique_good_count) : 0
	var/list/restock_candidates = list()

	for(var/category_name in inventory)
		var/list/category = inventory[category_name]
		for(var/good_id in category)
			var/good_index = category.Find(good_id)
			var/current_amount = GetGoodAmount(category_name, good_index)
			var/chance_to_restock = current_amount < 5 ? 100 : current_amount > 20 ? 0 : 15
			if(rand(1, 100) > chance_to_restock)
				continue
			var/cost = max(1, round(SSsupply.GetImportCost(good_id, src, null, category_name) / 2))
			var/amount_to_add = budget ? max(1, rand(1, max(1, round(budget / cost)))) : 1
			var/list/content = list(
				"cat" = category_name,
				"index" = good_index,
				"cost" = cost,
				"to_add" = amount_to_add,
				"current_amt" = current_amount
			)
			var/restock_index = restock_candidates.len + 1
			restock_candidates.Insert(restock_index, restock_index)
			restock_candidates[restock_index] = content

	for(var/i in 1 to 20)
		if(!restock_candidates.len || !wealth)
			break

		var/list/good_packet = pick(restock_candidates)
		var/candidate_index = restock_candidates.Find(good_packet)
		var/total_cost = good_packet["cost"] * good_packet["to_add"]
		restock_candidates.Cut(candidate_index, candidate_index + 1)

		if(total_cost < wealth)
			SetGoodAmount(good_packet["cat"], good_packet["index"], good_packet["to_add"] + good_packet["current_amt"])
			SubtractFromWealth(total_cost)

	TryUnlockHiddenInv()

/datum/trading_station/proc/GetGoodPacket(category_name, good_ref)
	if(isnum(category_name))
		category_name = inventory[category_name]
	if(!istext(category_name) || !good_ref)
		return null
	var/list/category = inventory[category_name]
	if(!islist(category))
		return null
	var/list/good_packet = category[good_ref]
	return islist(good_packet) ? good_packet : null

/datum/trading_station/proc/GetGoodPath(category_name, good_ref)
	var/list/good_packet = GetGoodPacket(category_name, good_ref)
	var/item_path = islist(good_packet) ? good_packet["item_path"] : null
	return ispath(item_path, /atom/movable) ? item_path : null

/datum/trading_station/proc/GetGoodName(category_name, good_ref)
	var/list/good_packet = GetGoodPacket(category_name, good_ref)
	if(islist(good_packet) && good_packet["name"])
		return good_packet["name"]
	if(islist(good_packet) && good_packet["resolved_name"])
		return good_packet["resolved_name"]
	var/item_path = GetGoodPath(category_name, good_ref)
	var/resolved_name = null
	if(ispath(item_path, /atom/movable))
		var/atom/movable/temp_item = new item_path
		if(istype(temp_item))
			resolved_name = temp_item.name
			qdel(temp_item)
		if(!resolved_name)
			var/atom/movable/item_type = item_path
			resolved_name = initial(item_type.name)
	if(islist(good_packet) && resolved_name)
		good_packet["resolved_name"] = resolved_name
	return resolved_name || "[good_ref]"

/datum/trading_station/proc/GetGoodPrice(good_ref, category_name = null)
	. = 0
	var/list/good_packet = GetGoodPacket(category_name, good_ref)
	if(islist(good_packet) && isnum(good_packet["price"]))
		return good_packet["price"]

/datum/trading_station/proc/GetGoodAmount(cat, good_index)
	. = 0
	if(isnum(cat))
		cat = inventory[cat]
	if(!istext(cat) || !islist(amounts_of_goods))
		return
	var/list/goods = amounts_of_goods[cat]
	var/list/category = inventory[cat]
	if(islist(goods) && islist(category))
		var/good_id = isnum(good_index) ? category[good_index] : good_index
		. = goods[good_id]

/datum/trading_station/proc/SetGoodAmount(cat, index, value)
	if(isnum(cat))
		cat = inventory[cat]
	if(!istext(cat) || !islist(amounts_of_goods))
		return
	var/list/goods = amounts_of_goods[cat]
	var/list/category = inventory[cat]
	if(islist(goods) && islist(category))
		var/good_id = isnum(index) ? category[index] : index
		goods[good_id] = value

/datum/trading_station/proc/AddToWealth(income, is_offer = FALSE)
	if(!isnum(income))
		return
	wealth += income
	favor += income * (is_offer ? 1 : 0.25)
	TryUnlockHiddenInv()

/datum/trading_station/proc/SubtractFromWealth(cost)
	if(isnum(cost))
		wealth -= cost
