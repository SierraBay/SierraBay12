/datum/trading_station
	var/name
	var/desc
	var/uid
	/// Possible names and descriptions
	var/list/name_pool = list()
	var/list/icon_states = list("trading_station")
	var/initialized = FALSE

	/// Dictates availability of certain wares and the prices
	var/favor = 0

	/// Amount of favor required to unlock hidden inventory
	var/unlock_favor = 5000

	/// Its parent trade faction. Factions have relations with other factions, but it is usually outside of player's control
	var/faction = FACTION_INDEPENDENT

	/// If not empty - faction will be chosen from this list
	var/list/random_factions = list()

	/// If TRUE - will always spawn round-start
	var/spawn_always = FALSE

	/// Weight of appearing round-start, if spawn_always is FALSE
	var/spawn_probability = 60
	var/spawn_cost = 1
	var/start_hidden = FALSE
	/// What we sell

	/// A very big assoc list of Category = list(Type = Cost, ...)
	var/list/inventory = list()
	var/hidden_inv_unlocked = FALSE

	/// A big assoc list, similar to inventory.
	/// All items here are available after passing the favor threshold
	var/list/hidden_inventory = list()
	var/list/amounts_of_goods = list()
	var/unique_good_count = 0

	/// Default price markup on all sold goods
	var/markup = 1.2

	// Lets stations restock without player interaction.
	var/base_income = 1600
	var/wealth = 0

	/// For displaying the time remaining on the UI
	var/update_time = 0
	var/update_timer_start = 0

	/// Overmap object that represents the station on the overmap
	var/obj/overmap/overmap_object

	/// The location of the overmap object
	var/turf/overmap_location

	/// A list of forced overmap zones. Each zone is a list of two lists: one for the min and max X coordinates and one for the min and max Y coordinates.
	/// Example: forced_overmap_zone = list(list(10, 20), list(30, 40)) would restrict the overmap object to spawn within the area (10, 30) to (20, 40)
	var/list/forced_overmap_zone

	/// The opacity of the overmap object. 0 means fully transparent, 255 means fully opaque
	var/overmap_opacity = 0

	/// The color of the overmap object. If null, the default color will be used
	var/overmap_color = null

	/// If not empty - only factions in this list can trade with it
	var/list/whitelist_factions = list()
	/// Factions in this list cannot trade with this station
	var/list/blacklist_factions = list()

/datum/trading_station/New(init_on_new)
	. = ..()
	if(init_on_new)
		InitSrc()

/// Returns the datum of our faction
/datum/trading_station/proc/GetFaction()
	var/datum/trade_faction/TF = SSsupply.factions[faction]
	if(!istype(TF))
		return null
	return TF

/datum/trading_station/proc/InitSrc(turf/station_loc = null, force_discovered = FALSE)
	if(name)
		CRASH("[type] trade station had name set before InitSrc() was called!")
	for(var/datum/trading_station/S in SSsupply.all_trading_stations)
		name_pool.Remove(S.name)
		if(!length(name_pool))
			warning("Trade station name pool exhausted: [type]")
			name_pool = S.name_pool
			break
	name = pick(name_pool)
	desc = name_pool[name]

	AssembleInventory()
	InitGoods()

	UpdateTick()

	if(start_hidden)
		start_hidden = !force_discovered

	var/x = 1
	var/y = 1
	if(station_loc)  // Spawn trading station at custom location
		x = station_loc.x
		y = station_loc.y
	else if(RecursiveLen(forced_overmap_zone) == 6)
		x = rand(forced_overmap_zone[1][1], forced_overmap_zone[1][2])
		y = rand(forced_overmap_zone[2][1], forced_overmap_zone[2][2])
	else
		x = rand(OVERMAP_EDGE, GLOB.using_map.overmap_size)
		y = rand(OVERMAP_EDGE, GLOB.using_map.overmap_size)
	PlaceOvermap(min(x, GLOB.using_map.overmap_size - OVERMAP_EDGE), min(y, GLOB.using_map.overmap_size - OVERMAP_EDGE))

	SSsupply.all_trading_stations += src
	if(!start_hidden)
		SSsupply.visible_trading_stations += src

	if(LAZYLEN(random_factions))
		faction = pick(random_factions)

/datum/trading_station/proc/PlaceOvermap(x, y, z = GLOB.using_map.overmap_z)
	overmap_location = locate(x, y, z)

	overmap_object = new (overmap_location)
	overmap_object.name = "bluespace trade beacon - [name]"
	overmap_object.desc = "A bluespace trade beacon used to make purchases and sell items over large distances."
	overmap_object.opacity = overmap_opacity
	overmap_object.dir = pick(rand(1,2), 4, 8)
	overmap_object.icon_state = pick(icon_states)
	overmap_object.color = overmap_color

	if(start_hidden)
		overmap_object.name = "unidentified trade beacon"
		overmap_object.color = "#444444"
		GLOB.entered_event.register(overmap_location, src, .proc/Discovered)

/datum/trading_station/proc/Discovered(_, obj/overmap/visitable/ship)
	if(!istype(ship) || !(HAS_FLAGS(ship.sector_flags, OVERMAP_SECTOR_BASE)))
		return

	SSsupply.visible_trading_stations |= src
	overmap_object.name = "bluespace trade beacon - [name]"
	overmap_object.color = overmap_color
	for(var/obj/machinery/computer/ship/helm/H in SSmachines.machinery)
		H.visible_message(SPAN_NOTICE("\The [H] pings as <b>[overmap_object.name]</b> is discovered!"))
		playsound(H, 'sound/machines/sensors/contactgeneric.ogg', 50, TRUE, 3)

/datum/trading_station/proc/AssembleInventory()
	for(var/list/category_name in inventory)
		if(length(category_name) >= 2)
			var/new_category_name
			if(!category_name.Find("name"))
				continue
			new_category_name = category_name["name"]
			var/list/content = list()
			if(islist(inventory[category_name]))
				content = inventory[category_name]

			if(istext(new_category_name) && islist(content))
				var/category_name_index = inventory.Find(category_name)
				inventory.Cut(category_name_index, category_name_index + 1)
				inventory.Insert(category_name_index, new_category_name)
				inventory[new_category_name] = content

/datum/trading_station/proc/InitGoods()
	for(var/category_name in inventory)
		var/list/category = inventory[category_name]
		if(islist(category))
			for(var/good_path in category)
				var/cost = SSsupply.GetImportCost(good_path, src)
				var/list/rand_args = list(5, 30 / max(cost/200, 1))
				var/list/good_packet = category[good_path]
				if(islist(good_packet))
					if(islist(good_packet["amount_range"]))
						rand_args = good_packet["amount_range"]
				if(!islist(amounts_of_goods[category_name]))
					amounts_of_goods[category_name] = list()
				var/content = amounts_of_goods[category_name]
				var/good_quantity = max(0, rand(rand_args[1], rand_args[2]))
				content[good_path] = good_quantity
				unique_good_count += 1

/datum/trading_station/proc/TryUnlockHiddenInv()
	if(favor >= unlock_favor)
		hidden_inv_unlocked = TRUE
		for(var/category_name in hidden_inventory)
			var/list/category = hidden_inventory[category_name]
			if(istext(category_name) && islist(category))
				if(!(category_name in inventory))
					inventory[category_name] = list()
				inventory[category_name] |= category
				for(var/good_path in category)
					var/cost = SSsupply.GetImportCost(good_path, src)
					var/list/rand_args = list(1, 30 / max(cost/200, 1))
					var/list/good_packet = category[good_path]
					if(islist(good_packet))
						if(islist(good_packet["amount_range"]))
							rand_args = good_packet["amount_range"]
					if(!islist(amounts_of_goods[category_name]))
						amounts_of_goods[category_name] = list()
					var/content = amounts_of_goods[category_name]
					var/good_quantity = max(0, rand(rand_args[1], rand_args[2]))
					content[good_path] = good_quantity
					unique_good_count += 1

/datum/trading_station/proc/SpendTradeStationsBudget(budget = spawn_cost)
	if(!spawn_always)
		SSsupply.trade_stations_budget -= budget

/datum/trading_station/proc/RegainTradeStationsBudget(budget = spawn_cost)
	if(!spawn_always)
		SSsupply.trade_stations_budget += budget

/datum/trading_station/proc/UpdateTick()
	//OfferTick()
	if(initialized) // So the station doesn't get paid or restock at roundstart
		GoodsTick()
	else
		initialized = TRUE
	update_time = rand(6, 8) MINUTES
	addtimer(new Callback(src, .proc/UpdateTick), update_time, TIMER_STOPPABLE)
	update_timer_start = world.time

// The station will restock based on base_income + wealth, then check unlockables.
/datum/trading_station/proc/GoodsTick()
	// Add base income
	wealth += base_income // Base income doesn't contribute to favor

	// Restock
	var/starting_balance = wealth								// For calculating production budget
	var/budget = round(starting_balance / unique_good_count)	// Don't wanna blow the whole balance on one item
	var/list/restock_candidates = list()

	for(var/category_name in inventory)
		var/list/category = inventory[category_name]
		for(var/good_path in category)
			var/good_index = category.Find(good_path)
			var/current_amount = GetGoodAmount(category_name, good_index)
			var/chance_to_restock = (current_amount < 5) ? 100 : (current_amount > 20) ? 0 : 15		// Always restock low quantity goods, never restock well-stocked goods
			var/roll = rand(1,100)
			if(roll <= chance_to_restock)
				var/cost = max(1, round(SSsupply.GetImportCost(good_path, src) / 2))			// Cost of production is lower than sale price. Otherwise, it wouldn't make sense for the station to operate.
				var/amount_to_add = rand(1, round(budget / cost))
				var/list/content = list(
					"cat" = category_name,
					"index" = good_index,
					"cost" = cost,
					"to add" = amount_to_add,
					"current amt" = current_amount)
				var/restock_index = restock_candidates.len + 1
				restock_candidates.Insert(restock_index, restock_index)
				restock_candidates[restock_index] = content

	for(var/count in 1 to 20)
		if(!restock_candidates.len || !wealth)
			break

		var/list/good_packet = pick(restock_candidates)
		var/candidate_index = restock_candidates.Find(good_packet)
		var/total_cost = good_packet["cost"] * good_packet["to add"]
		restock_candidates.Cut(candidate_index, candidate_index + 1)

		if(total_cost < wealth)
			SetGoodAmount(good_packet["cat"], good_packet["index"], good_packet["to add"] + good_packet["current amt"])
			SubtractFromWealth(total_cost)

	// Compare total favor and unlock thresholds
	if(!hidden_inv_unlocked)
		TryUnlockHiddenInv()

/datum/trading_station/proc/GetGoodPrice(item_path)
	. = 0
	if(ispath(item_path))
		for(var/category_name in inventory)
			var/list/category = inventory[category_name]
			var/list/item_path_check = list(item_path)
			var/list/good_path = category & item_path_check
			if(length(good_path))
				if(islist(category[item_path]))
					var/list/good_packet = category[item_path]
					. += good_packet["price"]

/datum/trading_station/proc/GetGoodAmount(cat, good_index)
	. = 0
	if(isnum(cat))
		cat = inventory[cat]
	if(istext(cat))
		if(islist(amounts_of_goods))
			var/list/L = amounts_of_goods[cat]
			if(islist(L))
				. = L[L[good_index]]

/datum/trading_station/proc/SetGoodAmount(cat, index, value)
	if(isnum(cat))
		cat = inventory[cat]
	if(istext(cat) && text2num(index))
		if(islist(amounts_of_goods))
			var/list/L = amounts_of_goods[cat]
			if(islist(L))
				L[L[index]] = value

/datum/trading_station/proc/AddToWealth(income, is_offer = FALSE)
	if(!isnum(income))
		return
	wealth += income
	favor += income * (is_offer ? 1 : 0.25)

	// Unlocks without needing to wait for update tick
	if(!hidden_inv_unlocked)
		TryUnlockHiddenInv()

/datum/trading_station/proc/SubtractFromWealth(cost)
	if(!isnum(cost))
		return
	wealth -= cost

/// Returns a multiplier to markup based on faction relations
/datum/trading_station/proc/GetFactionMarkup(datum/trade_faction/buyer_faction)
	// Returns a multiplier that marks up the price of goods based on the faction relations between the buyer and seller.
	// This is to simulate the fact that different factions have different resources and priorities, so the same good
	// might cost more or less depending on which faction is buying it.
	// The faction relations are used to determine the markup, as well as the seller's faction to determine the
	// baseline price of the good.

	var/datum/trade_faction/seller_faction = SSsupply.GetFaction(faction)
	if(!istype(seller_faction) || !istype(buyer_faction))
		return 1.0 // If the factions can't be determined, don't apply a markup

	// The faction relationships are as follows:
	//  - FACTION_STATE_ANIMOSITY: 25% markup
	//  - FACTION_STATE_RIVAL: 50% markup
	//  - FACTION_STATE_ENEMY: 100% markup
	//  - FACTION_STATE_WAR: 200% markup (but this is normally an embargo, so it shouldn't come up)
	//  - Anything else: no markup
	switch(seller_faction.relationship[buyer_faction.name])
		if(FACTION_STATE_ANIMOSITY)
			return 1.25
		if(FACTION_STATE_RIVAL)
			return 1.5
		if(FACTION_STATE_ENEMY)
			return 2.0
		if(FACTION_STATE_WAR)
			return 3.0
		else
			return 1.0
