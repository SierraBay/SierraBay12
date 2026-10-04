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

/datum/trading_station/proc/InitSrc(turf/station_loc = null, force_discovered = FALSE)
	var/turf/spawn_turf = ResolveOvermapSpawnLocation(station_loc)
	AssignStationIdentity(spawn_turf)
	AssembleInventory()
	InitGoods()
	UpdateTick()
	SetupOvermapPlacement(spawn_turf, force_discovered)
	RegisterStation()

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
	inventory = null
	hidden_inventory = null
	return ..()
