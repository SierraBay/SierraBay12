/datum/controller/subsystem/supply/proc/GetFaction(faction_ref)
	if(istype(faction_ref, /datum/trade_faction))
		return faction_ref
	if(istext(faction_ref) && (faction_ref in factions))
		return factions[faction_ref]
	return null

/datum/controller/subsystem/supply/proc/SetFactionRelations(fac1, fac2, relation)
	var/datum/trade_faction/first = GetFaction(fac1)
	var/datum/trade_faction/second = GetFaction(fac2)
	if(!istype(first) || !istype(second) || first == second || isnull(relation))
		return FALSE
	first.ModifyRelationsWith(second.name, relation)
	second.ModifyRelationsWith(first.name, relation)
	return TRUE

/datum/controller/subsystem/supply/proc/InitializeRelations()
	for(var/faction_name in factions)
		var/datum/trade_faction/first = factions[faction_name]
		first.relationship[first.name] = FACTION_STATE_PROTECTORATE
		for(var/other_name in factions)
			if(faction_name == other_name)
				continue
			var/datum/trade_faction/second = factions[other_name]
			var/has_first = (second.name in first.relationship)
			var/has_second = (first.name in second.relationship)
			if(!has_first && !has_second)
				SetFactionRelations(first, second, FACTION_STATE_NEUTRAL)
			else if(has_first && !has_second)
				second.relationship[first.name] = first.relationship[second.name]
			else if(!has_first && has_second)
				first.relationship[second.name] = second.relationship[first.name]
