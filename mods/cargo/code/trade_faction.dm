/datum/trade_faction
	var/name = "Trade Faction"
	var/desc = "A trade faction."
	var/list/relationship
	var/list/embargo
	var/list/trade_markup
	var/access_required = null

/datum/trade_faction/New()
	..()
	if(relationship)
		relationship = relationship.Copy()
	else
		relationship = list()
	if(embargo)
		embargo = embargo.Copy()
	else
		embargo = list()
	if(trade_markup)
		trade_markup = trade_markup.Copy()
	else
		trade_markup = list()

/datum/trade_faction/Destroy()
	relationship?.Cut()
	relationship = null
	embargo?.Cut()
	embargo = null
	trade_markup?.Cut()
	trade_markup = null
	return ..()

/datum/trade_faction/proc/ModifyRelationsWith(target, change = FACTION_STATE_NEUTRAL)
	var/target_name = target
	if(istype(target_name, /datum/trade_faction))
		var/datum/trade_faction/target_faction = target_name
		target_name = target_faction.name

	if(!istext(target_name) || !target_name || target_name == name)
		return FALSE

	if(!isnum(change))
		return FALSE

	change = clamp(change, FACTION_STATE_WAR, FACTION_STATE_PROTECTORATE)
	relationship ||= list()
	relationship[target_name] = change
	return TRUE

/datum/trade_faction/independent
	name = FACTION_INDEPENDENT
	desc = "Belongs to no major power and trades independently."

/datum/trade_faction/terragov
	name = FACTION_INDIE_CONFED
	desc = "A part of the Terran Government trade sphere."
	relationship = list(
		FACTION_INDEPENDENT = FACTION_STATE_ANIMOSITY,
		FACTION_SOL_CENTRAL = FACTION_STATE_RIVAL,
		FACTION_FREETRADE = FACTION_STATE_RIVAL,
		FACTION_NANOTRASEN = FACTION_STATE_ANIMOSITY,
		FACTION_DAIS = FACTION_STATE_ANIMOSITY
	)

/datum/trade_faction/solgov
	name = FACTION_SOL_CENTRAL
	desc = "A part of the Sol Central Government trade sphere."
	relationship = list(
		FACTION_INDEPENDENT = FACTION_STATE_ANIMOSITY,
		FACTION_INDIE_CONFED = FACTION_STATE_RIVAL,
		FACTION_FREETRADE = FACTION_STATE_RIVAL,
		FACTION_NANOTRASEN = FACTION_STATE_WELCOMING
	)
	access_required = access_bridge

/datum/trade_faction/ftu
	name = FACTION_FREETRADE
	desc = "A part of the Independent Free Trade Union."
	relationship = list(
		FACTION_INDIE_CONFED = FACTION_STATE_RIVAL,
		FACTION_SOL_CENTRAL = FACTION_STATE_RIVAL,
		FACTION_NANOTRASEN = FACTION_STATE_ALLY,
		FACTION_DAIS = FACTION_STATE_ALLY
	)
	access_required = access_cargo

/datum/trade_faction/nanotrasen
	name = FACTION_NANOTRASEN
	desc = "A part of the NanoTrasen corporate trade sphere."
	relationship = list(
		FACTION_INDIE_CONFED = FACTION_STATE_ANIMOSITY,
		FACTION_SOL_CENTRAL = FACTION_STATE_WELCOMING,
		FACTION_FREETRADE = FACTION_STATE_ALLY,
		FACTION_DAIS = FACTION_STATE_ALLY
	)
	access_required = access_qm

/datum/trade_faction/dais
	name = FACTION_DAIS
	desc = "A part of the DAIS corporate trade sphere."
	relationship = list(
		FACTION_INDIE_CONFED = FACTION_STATE_ANIMOSITY,
		FACTION_SOL_CENTRAL = FACTION_STATE_WELCOMING,
		FACTION_FREETRADE = FACTION_STATE_ALLY,
		FACTION_NANOTRASEN = FACTION_STATE_ALLY
	)
	access_required = access_research
