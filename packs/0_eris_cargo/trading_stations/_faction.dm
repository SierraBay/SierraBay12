/datum/trade_faction
	var/name = "Tegu Station Developers"
	var/desc = "A bunch of people that decided it is upon them to modify this universe as they see fit."
	/// Associative list Faction = State
	var/list/relationship = list()
	/// List of factions who we will not trade with
	var/list/embargo = list()
	/// Associative list Faction = Additional markup; This is additional markup! Bad relations will have their own
	var/list/trade_markup = list()
	/// Access level required to set faction on supply program to this
	var/access_required = null

/datum/trade_faction/New()
	. = ..()
	// Factions that aren't set in relationship list of the datum are set to neutral.
	for(var/datum/trade_faction/TF in SSsupply.factions)
		if(TF.name == name)
			// Technically not, but this will be how we declare same faction relations for now
			relationship[TF.name] = FACTION_STATE_PROTECTORATE
			continue
		if(!(TF.name in relationship))
			relationship[TF.name] = FACTION_STATE_NEUTRAL
		// This ensures that relations are always mirrored between two datums
		SSsupply.SetFactionRelations(name, TF.name, relationship[TF.name])

/datum/trade_faction/proc/ModifyRelationsWith(target = null, change = FACTION_STATE_NEUTRAL)
	if(istype(target, /datum/trade_faction))
		var/datum/trade_faction/faction = target
		target = faction.name
	relationship[target] = change
	return

/datum/trade_faction/independent
	name = FACTION_INDEPENDENT
	desc = "Belongs to no big players in the universe, all on their own in this cruel world."

// The big three

/datum/trade_faction/terragov
	name = FACTION_INDIE_CONFED
	desc = "A part of the Terran Government, a large militaristic republic that rivals SolGov."
	relationship = list(
		FACTION_INDEPENDENT = FACTION_STATE_ANIMOSITY,
		FACTION_SOL_CENTRAL = FACTION_STATE_RIVAL,
		FACTION_FREETRADE = FACTION_STATE_RIVAL,
		FACTION_NANOTRASEN = FACTION_STATE_ANIMOSITY,
		FACTION_DAIS = FACTION_STATE_ANIMOSITY,
		)

/datum/trade_faction/solgov
	name = FACTION_SOL_CENTRAL
	desc = "A part of the Sol Central Government, a large democratic republic that rivals TerraGov."
	relationship = list(
		FACTION_INDEPENDENT = FACTION_STATE_ANIMOSITY,
		FACTION_INDIE_CONFED = FACTION_STATE_RIVAL,
		FACTION_FREETRADE = FACTION_STATE_RIVAL,
		FACTION_NANOTRASEN = FACTION_STATE_WELCOMING,
		)

/datum/trade_faction/ftu
	name = FACTION_FREETRADE
	desc = "A part of the Independent Free Trade Union, big union of independent traders."
	relationship = list(
		FACTION_INDIE_CONFED = FACTION_STATE_RIVAL,
		FACTION_SOL_CENTRAL = FACTION_STATE_RIVAL,
		FACTION_NANOTRASEN = FACTION_STATE_ALLY,
		FACTION_DAIS = FACTION_STATE_ALLY,
		)

// Corpos

/datum/trade_faction/nanotrasen
	name = FACTION_NANOTRASEN
	desc = "A part of the mega-corporation that specializes in development of bluespace technology."
	relationship = list(
		FACTION_INDIE_CONFED = FACTION_STATE_ANIMOSITY,
		FACTION_SOL_CENTRAL = FACTION_STATE_WELCOMING,
		FACTION_FREETRADE = FACTION_STATE_ALLY,
		FACTION_DAIS = FACTION_STATE_ALLY,
		)

/datum/trade_faction/dais
	name = FACTION_DAIS
	desc = "A part of the DAIS mega-corporation which specializes in development of implants and artificial intelligence."
	relationship = list(
		FACTION_INDIE_CONFED = FACTION_STATE_ANIMOSITY,
		FACTION_SOL_CENTRAL = FACTION_STATE_WELCOMING,
		FACTION_FREETRADE = FACTION_STATE_ALLY,
		FACTION_NANOTRASEN = FACTION_STATE_ALLY,
		)

// Member states of ISC

// Purely independent states
