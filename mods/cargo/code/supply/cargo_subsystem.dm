// Subsystem for ship trade-network operations.
/datum/controller/subsystem/supply
	name = "Supply"
	priority = SS_PRIORITY_SUPPLY
	wait = 20 SECONDS
	trade_network_active = TRUE
	flags = 0

	var/trade_stations_budget = 5
	var/list/all_trading_stations = list()
	var/list/visible_trading_stations = list()
	var/list/hidden_trading_stations = list()
	var/list/factions = list()
	var/list/beacons_sending = list()
	var/list/beacons_receiving = list()

	var/shipping_invoice_number = 0
	var/export_invoice_number = 0
	var/order_number = 0
	var/contract_number = 0

	var/list/shipping_log = list()
	var/list/export_log = list()
	var/list/order_log = list()
	var/list/contract_log = list()

	var/handling_fee = 0.1
	var/order_queue_id = 0
	var/list/order_queue = list()
	var/trade_contract_id = 0
	var/list/trade_contracts = list()
	var/max_resolved_trade_contracts = 20
	var/min_trade_contract_distance = 3
	var/min_trade_contract_value = 120
	var/max_trade_contract_value = 800

/datum/controller/subsystem/supply/Initialize(start_uptime)
	. = ..()
	all_trading_stations = list()
	visible_trading_stations = list()
	hidden_trading_stations = list()
	factions = list()
	if(!islist(beacons_sending))
		beacons_sending = list()
	if(!islist(beacons_receiving))
		beacons_receiving = list()
	shipping_log = list()
	export_log = list()
	order_log = list()
	contract_log = list()
	order_queue = list()
	trade_contracts = list()
	point_sources = list()
	point_source_descriptions = list(
		"time" = "Legacy cargo stipend",
		"manifest" = "Legacy export manifests",
		"crate" = "Legacy crate export",
		"gep" = "Good explorer points",
		"anomaly" = "Analyzed anomalies",
		"research_reports" = "Research data compilations",
		"virology_antibodies" = "Uploaded antibody data",
		"virology_dishes" = "Exported virus dishes",
		"animal" = "Captured exotic fauna",
		"artefacts" = "Exported artefacts",
		"total" = "Total legacy income"
	)
	sold_virus_strains = list()

	for(var/faction_type in (typesof(/datum/trade_faction) - /datum/trade_faction))
		var/datum/trade_faction/trade_faction = new faction_type
		factions[trade_faction.name] = trade_faction

	InitializeRelations()
	InitTradeStations()

	RefreshTradeBeacons()

/datum/controller/subsystem/supply/fire(reschedule)
	ProcessPendingOrderRefunds()
	ProcessPendingContractRefunds()
	for(var/datum/trading_station/station as anything in all_trading_stations)
		if(QDELETED(station))
			continue
		if(world.time >= station.next_update_at)
			station.StationTick()
		MC_TICK_CHECK
	EnsureVisibleContractOffers()

/datum/controller/subsystem/supply/Destroy()
	DeInitTradeStations()
	if(islist(trade_contracts))
		for(var/datum/trade_contract/contract in trade_contracts)
			qdel(contract)
		trade_contracts.Cut()
		trade_contracts = null
	if(islist(factions))
		for(var/f_key in factions)
			qdel(factions[f_key])
		factions.Cut()
		factions = null
	beacons_sending?.Cut()
	beacons_sending = null
	beacons_receiving?.Cut()
	beacons_receiving = null
	shipping_log?.Cut()
	shipping_log = null
	export_log?.Cut()
	export_log = null
	order_log?.Cut()
	order_log = null
	contract_log?.Cut()
	contract_log = null
	if(islist(order_queue))
		for(var/order_id in order_queue.Copy())
			qdel(order_queue[order_id])
		order_queue.Cut()
		order_queue = null
	return ..()

/datum/controller/subsystem/supply/UpdateStat(time)
	if(PreventUpdateStat(time))
		return ..()
	var/datum/money_account/master_account = get_supply_department_account()
	var/budget = master_account ? master_account.money : 0
	return ..("Stations: [length(visible_trading_stations)] | Orders: [length(order_queue)] | Contracts: [GetActiveContractCount()] | Budget: [round(budget)]")
