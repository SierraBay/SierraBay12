/*
General Explination:
The research datum is the "folder" where all the research information is stored in a R&D console. It's also a holder for all the
various procs used to manipulate it. It has four variables and seven procs:

Variables:
- tech_trees is a list of all /datum/tech that can potentially be researched by the player.
- all_designs is a list of all /datum/technology that can potentially be researched by the player.
- researched_tech contains all researched technologies
- known_designs contains all researched /datum/design.
- experiments contains data related to earning research points, more info in experiment.dm
- research_points is an amount of points that can be spend on researching technologies
- design_categories_protolathe stores all unlocked categories for protolathe designs
- design_categories_imprinter stores all unlocked categories for circuit imprinter designs

Procs:
- AddDesign2Known: Adds a /datum/design to known_designs.
- IsResearched
- CanResearch
- UnlockTechology
- download_from: Unlocks all technologies from a different /datum/research and syncs experiment data
- forget_techology
- forget_random_technology
- forget_all

The tech datums are the actual "tech trees" that you improve through researching. Each one has five variables:
- Name:		Pretty obvious. This is often viewable to the players.
- Desc:		Pretty obvious. Also player viewable.
- ID:		This is the unique ID of the tech that is used by the various procs to find and/or maniuplate it.
- Level:	This is the current level of the tech. Based on the amount of researched technologies
- MaxLevel: Maxium level possible for this tech. Based on the amount of technologies of that tech

*/
/***************************************************************
**						Master Types						  **
**	Includes all the helper procs and basic tech processing.  **
***************************************************************/
#define RESEARCH_ENGINEERING   /datum/tech/engineering
#define RESEARCH_BIOTECH       /datum/tech/biotech
#define RESEARCH_COMBAT        /datum/tech/combat
#define RESEARCH_DATA          /datum/tech/programming
#define RESEARCH_POWERSTORAGE  /datum/tech/powerstorage
#define RESEARCH_BLUESPACE     /datum/tech/bluespace
#define RESEARCH_ESOTERIC      /datum/tech/esoteric
#define RESEARCH_MAGNETS       /datum/tech/magnets
#define RESEARCH_MATERIALS     /datum/tech/materials

GLOBAL_VAR_INIT(research_point_gained, 0)
GLOBAL_VAR_INIT(score_research_point_gained, 0)
var/global/list/RDcomputer_list = list()
var/global/list/explosion_watcher_list = list()


/datum/research								//Holder for all the existing, archived, and known tech. Individual to console.
	var/list/known_designs = list()			//List of available designs (at base reliability).
	//Increased by each created prototype with formula: reliability += reliability * (RND_RELIABILITY_EXPONENT^created_prototypes)
	var/list/design_categories_protolathe = list()
	var/list/design_categories_imprinter = list()

	var/list/researched_tech = list() // Tree = list(of_researched_tech)
	var/list/researched_nodes = list() // All research nodes

	var/datum/experiment_data/experiments
	var/research_points = 0
	var/list/uniquekeys = list()
	var/known_research_file_ids = list()


/datum/research/New()
	..()
	SSresearch.initialize_research_datum(src)
	experiments = new /datum/experiment_data()
	// This is a science station. Most tech is already at least somewhat known.
	experiments.init_known_tech()

/datum/research/proc/IsResearched(datum/technology/T)
	return (T in researched_nodes)

/datum/research/proc/CanResearch(datum/technology/T)
	if(T.cost > research_points)
		return FALSE
	var/datum/tech/mytree = locate(T.tech_type) in researched_tech
	if(!mytree || !mytree.shown) // invalid tech_type or hidden tree, no bypassing safeties!
		return

	for(var/tree in T.required_tech_levels)
		var/datum/tech/tech_tree = locate(tree) in researched_tech
		var/level = T.required_tech_levels[tree]

		if(tech_tree.level < level)
			return FALSE

	for(var/tech in T.required_technologies)
		var/datum/technology/tech_node = locate(tech) in SSresearch.all_tech_nodes
		if(!IsResearched(tech_node))
			return FALSE

	return TRUE

/datum/research/proc/UnlockTechology(datum/technology/T, force = FALSE, initial = FALSE)
	if(IsResearched(T))
		return FALSE
	if(!CanResearch(T) && !force)
		return FALSE
	researched_nodes += T
	var/datum/tech/tree = locate(T.tech_type) in researched_tech
	researched_tech[tree] += T
	if(!force)
		adjust_research_points(-T.cost)

	if(initial) // Initial technologies don't add levels
		tree.maxlevel -= 1
	else
		tree.level += 1

	for(var/id in T.unlocks_designs)
		AddDesign2Known(SSresearch.get_design(id))

	return TRUE


/datum/research/proc/download_from(datum/research/O)
	for(var/t in O.researched_tech)
		var/datum/tech/tree = t
		var/datum/tech/our_tree = locate(tree.type) in researched_tech

		if(tree.shown && !our_tree.shown)
			our_tree.shown = tree.shown
			. = TRUE // we actually updated something

		for(var/tech in O.researched_tech[t])
			var/datum/technology/T = tech
			if(UnlockTechology(T, force = TRUE))
				. = TRUE // we actually updated something
	known_research_file_ids |= O.known_research_file_ids
	experiments.merge_with(O.experiments)

/datum/research/proc/forget_techology(datum/technology/T)
	if(!IsResearched(T))
		return
	var/datum/tech/tree = locate(T.tech_type) in researched_tech
	if(!tree)
		return
	tree.level -= 1
	researched_tech[tree] -= T
	researched_nodes -= T

	for(var/D in T.unlocks_designs)
		known_designs -= D

/datum/research/proc/forget_random_technology()
	if(LAZYLEN(researched_tech) > 0)
		var/random_tech = pick(researched_tech)
		var/datum/technology/T = researched_tech[random_tech]

		forget_techology(T)

/datum/research/proc/forget_all(tech_type)
	var/datum/tech/tree = locate(tech_type) in researched_tech
	if(!tree)
		return
	tree.level = 1
	researched_nodes -= researched_tech[tree] // Remove all the nodes of the tree from the general researched nodes list
	for(var/tech in researched_tech[tree])
		var/datum/technology/T = tech
		for(var/D in T.unlocks_designs)
			known_designs -= D

/datum/research/proc/AddDesign2Known(datum/design/D)
	if(D in known_designs)
		return

	for(var/datum/design/known in known_designs)
		if(D.id == known.id)
			return
	known_designs += D

	if(D.category)
		if(D.build_type & PROTOLATHE)
			for(var/cat in D.category)
				design_categories_protolathe |= cat
		else if(D.build_type & IMPRINTER)
			for(var/cat in D.category)
				design_categories_imprinter |= cat
	else
		if(D.build_type & PROTOLATHE)
			design_categories_protolathe |= "Unspecified"
		else if(D.build_type & IMPRINTER)
			design_categories_imprinter |= "Unspecified"

// Unlocks hidden tech trees
/datum/research/proc/check_item_for_tech(obj/item/I)
	var/list/temp_tech = I.origin_tech
	if(!LAZYLEN(temp_tech))
		return

	for(var/tree in researched_tech)
		var/datum/tech/T = tree
		if(T.shown || !T.item_tech_req)
			continue

		for(var/item_tech in temp_tech)
			if(item_tech == T.item_tech_req)
				T.shown = TRUE
				return

/datum/research/proc/AddSciPoints(datum/computer_file/binary/sci/D)
	if(D.uniquekey in uniquekeys)
		return 0
	uniquekeys += D.uniquekey
	return (rand(500, 1000) * D.size)

/datum/research/proc/adjust_research_points(value)
	if(value > 0)
		GLOB.research_point_gained += value
	research_points += value

/datum/tech	//Datum of individual technologies.
	var/name = "name"          //Name of the technology.
	var/shortname = "name"
	var/desc = "description"   //General description of what it does and what it makes.
	var/id = "id"              //An easily referenced ID. Must be alphanumeric, lower-case, and no symbols.
	var/level = 0              //A simple number scale of the research level.
	var/rare = 1               //How much CentCom wants to get that tech. Used in supply shuttle tech cost calculation.
	var/maxlevel               //Calculated based on the amount of technologies
	var/shown = TRUE           //Used to hide tech that is not supposed to be shown from the start
	var/item_tech_req          //Deconstructing items with this tech will unlock this tech tree

/datum/tech/proc/getCost(current_level = null)
	// Calculates tech disk's supply points sell cost
	if(!current_level)
		current_level = initial(level)

	if(current_level >= level)
		return 0

	var/cost = 0
	for(var/i = current_level + 1 to level)
		if(i == initial(level))
			continue
		cost += i*rare

	return cost

/datum/tech/proc/Copy()
	var/datum/tech/new_tech = new type
	new_tech.level = level
	return new_tech

//Trunk Technologies (don't require any other techs and you start knowning them).

/datum/tech/engineering
	name = "Engineering Research"
	shortname = "Engineering"
	desc = "Development of new and improved engineering parts."
	id = RESEARCH_ENGINEERING

/datum/tech/powerstorage
	name = "Power Manipulation Technology"
	shortname = "Power Manipulation"
	desc = "The various technologies behind the storage and generation of electicity."

/datum/tech/bluespace
	name = "'Blue-space' Technology"
	shortname = "Blue-space"
	desc = "Devices that utilize the sub-reality known as 'blue-space'"

/datum/tech/biotech
	name = "Biological Technology"
	shortname = "Biotech"
	desc = "Deeper mysteries of life and organic substances."
	id = RESEARCH_BIOTECH

/datum/tech/magnets
	name = "Robotics"
	shortname = "Robotics"
	desc = "The use of magnetic fields to make electrical devices."

/datum/tech/combat
	name = "Combat Systems"
	shortname = "Combat"
	desc = "Offensive and defensive systems."

/datum/tech/programming
	name = "Data Theory"
	shortname = "Data Theory"
	desc = "Computer and artificial intelligence and data storage systems."

/datum/tech/esoteric
	name = "Esoteric Technology"
	shortname = "Esoteric"
	desc = "A miscellaneous tech category filled with information on non-standard designs, personal projects and half-baked ideas."
	id = RESEARCH_ESOTERIC
	shown = FALSE
	item_tech_req = TECH_ESOTERIC

/obj/item/disk/tech_disk
	name = "fabricator data disk"
	desc = "A disk for storing fabricator learning data for backup."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_PLASTIC = 30, MATERIAL_STEEL = 30, MATERIAL_GLASS = 10)
	var/datum/tech/stored

/obj/item/disk/design_disk
	name = "component design disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_PLASTIC = 30, MATERIAL_STEEL = 30, MATERIAL_GLASS = 10)
	var/datum/design/blueprint


/datum/technology
	var/name = "name"
	var/desc = "description"                // Not used because lazy
	var/id = "id"                           // should be unique
	var/tech_type                           // Which tech tree does this techology belongs to

	var/x = 0.5                             // Position on the tech tree map, 0 - left, 1 - right
	var/y = 0.5                             // 0 - down, 1 - top
	var/icon = "gun"                        // css class of techology icon, defined in shared.css

	var/list/required_technologies = list() // Ids of techologies that are required to be unlocked before this one. Should have same tech_type
	var/list/required_tech_levels = list()  // list("biotech" = 5, ...) Ids and required levels of tech
	var/cost = 100                          // How much research points required to unlock this techology
	var/list/unlocks_designs = list()       // Ids of designs that this technology unlocks

/datum/technology/proc/getCost()
	// Calculates tech disk's supply points sell cost
	var/datum/tech/tree = locate(tech_type) in SSresearch.all_tech_trees
	if(tree)
		return (cost/100)*initial(tree.rare)
	else
		return cost/100
