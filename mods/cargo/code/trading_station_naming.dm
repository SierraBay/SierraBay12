// Procedural trading station naming and identity generator.

/proc/GenerateSectorIndex(turf/target_turf = null)
	if(isturf(target_turf) && isnum(target_turf.x) && isnum(target_turf.y))
		return "SEC-[target_turf.x].[target_turf.y]"
	var/greek = LAZYLEN(GLOB.greek_letters) ? pick(GLOB.greek_letters) : "Alpha"
	return "SEC-[rand(10, 99)]-[greek]"

/proc/GetStationNamingPrefixData(datum/trading_station/station)
	if(istype(station, /datum/trading_station/caravan))
		return list("short" = pick("FTV", "MSV", "CSV"), "full" = "Free Trade Vessel")
	if(station.faction == FACTION_INDIE_CONFED || istype(station, /datum/trading_station/weapons_terra))
		return list("short" = pick("TTB", "CTB", "PTB"), "full" = "Terran Trade Beacon")
	if(station.faction == FACTION_NANOTRASEN)
		return list("short" = pick("NTB", "NSB"), "full" = "NanoTrasen Beacon")
	return list("short" = pick("FTB", "ISB", "OSB", "ASB"), "full" = "Free Trade Beacon")

/proc/GetStationThematicCores(datum/trading_station/station)
	if(istype(station, /datum/trading_station/caravan))
		return list("Wayfarer", "Long Haul", "Open Palm", "Far Market", "Stray Wind", "Nomad's Coin", "Drift Hopper", "Silver Horizon", "Peregrine", "Wandering Star")
	if(istype(station, /datum/trading_station/weapons_terra) || istype(station, /datum/trading_station/legacy/security) || istype(station, /datum/trading_station/legacy/munitions))
		return list("Telum", "Aegis", "Glaive", "Ballista", "Centurion", "Castellan", "Bulwark", "Palisade", "Hoplon", "Redoubt", "Iron Gate", "Vanguard")
	if(istype(station, /datum/trading_station/materials) || istype(station, /datum/trading_station/legacy/materials))
		return list("Jacarta", "Steel Deck", "Crucible", "Foundry", "Slag Peak", "Anvil Point", "Bulkhead", "Bauxite Drift", "Ferrous Gate", "Cobalt Ridge")
	if(istype(station, /datum/trading_station/eva) || istype(station, /datum/trading_station/legacy/atmospherics))
		return list("Oxyta", "Spacer", "Voidstrider", "Airlock Zero", "Cold Drift", "Vacuum Verge", "Blue Lung", "Zephyr", "Vortex", "Aero Wells")
	if(istype(station, /datum/trading_station/legacy/medicine))
		return list("Trauma Bay", "Caduceus", "Hygeia", "Panacea", "Triage Point", "Bio-Pulse", "Sanctuary", "Vitalis", "Remedy", "Helix")
	if(istype(station, /datum/trading_station/legacy/science))
		return list("Peer Review", "Synapse", "Observatory", "Collider", "Spectra", "Hypothesis", "Quark", "Prism", "Archimedes", "Cipher")
	if(istype(station, /datum/trading_station/legacy/operations))
		return list("Quartermaster", "Longhaul", "Crossroads", "Waypoint", "Cargo Core", "Freightline", "Manifest", "Tranship", "Dockside")
	if(istype(station, /datum/trading_station/legacy/engineering))
		return list("Arc Weld", "Gridline", "Dyno Relay", "Conduit Point", "Scaffold", "Transformer", "Riveter", "Circuit", "Gantry")
	if(istype(station, /datum/trading_station/legacy/service) || istype(station, /datum/trading_station/legacy/civilian))
		return list("Mess Hall", "Wardrobe", "Pantry Post", "Cornucopia", "Hydro-Haven", "Bazaar", "Comfort Line", "Mercantile", "Haven")
	return list("Apex", "Zenith", "Horizon", "Pioneer", "Frontier", "Endeavor", "Atlas", "Beacon", "Prometheus", "Orion", "Nova", "Eclipse")

/proc/GetStationRoleSummary(datum/trading_station/station)
	if(istype(station, /datum/trading_station/caravan))
		return "mobile deep-space commercial cargo transit"
	if(istype(station, /datum/trading_station/weapons_terra) || istype(station, /datum/trading_station/legacy/security) || istype(station, /datum/trading_station/legacy/munitions))
		return "defensive surplus, tactical weaponry, and munitions logistics"
	if(istype(station, /datum/trading_station/materials) || istype(station, /datum/trading_station/legacy/materials))
		return "raw ore refining, structural alloys, and mineral distribution"
	if(istype(station, /datum/trading_station/eva) || istype(station, /datum/trading_station/legacy/atmospherics))
		return "extravehicular life support, void suits, and gas replenishment"
	if(istype(station, /datum/trading_station/legacy/medicine))
		return "pharmaceutical stock, triage medical replenishments, and sterile supplies"
	if(istype(station, /datum/trading_station/legacy/science))
		return "scientific consumables, laboratory apparatus, and research provisions"
	if(istype(station, /datum/trading_station/legacy/engineering))
		return "power grid machinery, structural materials, and technical field repair goods"
	if(istype(station, /datum/trading_station/legacy/operations))
		return "freight handling, expedition logistics, and mining equipment"
	if(istype(station, /datum/trading_station/legacy/service) || istype(station, /datum/trading_station/legacy/civilian))
		return "crew provisions, leisure goods, commissary wares, and textiles"
	return "automated commercial supply and merchant transshipment"

/proc/GetStationFacilitySuffix(datum/trading_station/station)
	if(istype(station, /datum/trading_station/caravan))
		return prob(30) ? " [pick("Runner", "Hauler", "Convoy", "Express")]" : ""
	var/list/facility_suffixes = list("Depot", "Outpost", "Relay", "Hub", "Platform", "Terminal", "Exchange", "Array", "Facility")
	return prob(65) ? " [pick(facility_suffixes)]" : ""

/proc/IsTradeStationNameTaken(test_name)
	if(!SSsupply || !istext(test_name))
		return FALSE
	for(var/datum/trading_station/existing as anything in SSsupply.all_trading_stations)
		if(existing.name == test_name)
			return TRUE
	return FALSE

/proc/EnsureUniqueTradeStationName(candidate_name)
	if(!IsTradeStationNameTaken(candidate_name))
		return candidate_name
	for(var/counter in 2 to 50)
		var/adjusted_name = "[candidate_name] \Roman[counter]"
		if(!IsTradeStationNameTaken(adjusted_name))
			return adjusted_name
	return "[candidate_name] #[rand(100, 999)]"

/proc/GenerateProceduralStationIdentity(datum/trading_station/station, turf/target_turf = null)
	ASSERT(istype(station))
	var/list/prefix_data = GetStationNamingPrefixData(station)
	var/short_prefix = prefix_data["short"]
	var/full_prefix = prefix_data["full"]
	var/core_name = pick(GetStationThematicCores(station))
	var/facility_suffix = GetStationFacilitySuffix(station)
	var/sector_index = GenerateSectorIndex(target_turf)

	var/candidate_name = "[short_prefix] \"[core_name][facility_suffix]\" ([sector_index])"
	var/final_name = EnsureUniqueTradeStationName(candidate_name)

	var/faction_name = station.faction || FACTION_INDEPENDENT
	var/role_text = GetStationRoleSummary(station)
	var/final_desc = "[full_prefix] \"[core_name]\" operating in [sector_index]. Dedicated to [role_text] under [faction_name] registry."

	return list("name" = final_name, "desc" = final_desc)
