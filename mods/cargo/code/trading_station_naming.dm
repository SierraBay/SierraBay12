// Procedural trading station naming and identity generator.

/proc/GenerateSectorIndex(turf/target_turf = null)
	if(isturf(target_turf) && isnum(target_turf.x) && isnum(target_turf.y))
		return "SEC-[target_turf.x].[target_turf.y]"
	var/greek = LAZYLEN(GLOB.greek_letters) ? pick(GLOB.greek_letters) : "Alpha"
	return "SEC-[rand(10, 99)]-[greek]"

/proc/GetStationNamingPrefixData(datum/trading_station/station)
	if(station)
		return station.GetNamingPrefixData()
	return list("short" = pick("FTB", "ISB", "OSB", "ASB"), "full" = "Free Trade Beacon")

/proc/GetStationThematicCores(datum/trading_station/station)
	if(station)
		return station.GetThematicCores()
	return list("Apex", "Zenith", "Horizon", "Pioneer", "Frontier", "Endeavor", "Atlas", "Beacon", "Prometheus", "Orion", "Nova", "Eclipse")

/proc/GetStationRoleSummary(datum/trading_station/station)
	if(station)
		return station.GetRoleSummary()
	return "automated commercial supply and merchant transshipment"

/proc/GetStationFacilitySuffix(datum/trading_station/station)
	if(station)
		return station.GetFacilitySuffix()
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
