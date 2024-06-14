/*
General Explination:
The research datum is the "folder" where all the research information is stored in a R&D console. It's also a holder for all the
various procs used to manipulate it. It has four variables and seven procs:

Variables:
- tech_trees is a list of all /datum/tech that can potentially be researched by the player.
- all_technologies is a list of all /datum/technology that can potentially be researched by the player.
- researched_tech contains all researched technologies
- design_by_id contains all existing /datum/design.
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
#define RESEARCH_ENGINEERING   "engineering"
#define RESEARCH_BIOTECH       "biotech"
#define RESEARCH_COMBAT        "combat"
#define RESEARCH_DATA          "computer"
#define RESEARCH_POWERSTORAGE  "powerstorage"
#define RESEARCH_BLUESPACE     "bluespace"
#define RESEARCH_ROBOTICS      "robotics"
#define RESEARCH_ESOTERIC       "illegal"
#define RESEARCH_MAGNETS        "magnets"
#define RESEARCH_MATERIALS       "materials"
#define RND_RELIABILITY_EXPONENT 0.75

/datum/research								//Holder for all the existing, archived, and known tech. Individual to console.
	var/list/known_designs = list()			//List of available designs (at base reliability).
	var/list/design_by_id = list()
	//Increased by each created prototype with formula: reliability += reliability * (RND_RELIABILITY_EXPONENT^created_prototypes)
	var/list/design_reliabilities = list()
	var/list/design_created_prototypes = list()
	var/list/design_categories_protolathe = list()
	var/list/design_categories_imprinter = list()

	var/list/datum/tech/tech_trees = list() // associative
	var/list/all_technologies = list() // associative
	var/list/researched_tech = list()

	var/datum/experiment_data/experiments

	var/research_points = 0

/datum/research/New()
	for(var/D in subtypesof(/datum/design))
		var/datum/design/d = new D(src)
		design_by_id[d.id] = d
		if(d.starts_unlocked)
			design_reliabilities[d.id] = 120
			design_created_prototypes[d.id] = 15
		else
			design_reliabilities[d.id] = 10
			design_created_prototypes[d.id] = 0

	for(var/T in subtypesof(/datum/tech))
		var/datum/tech/Tech_Tree = new T
		tech_trees[Tech_Tree.id] = Tech_Tree
		all_technologies[Tech_Tree.id] = list()

	for(var/T in subtypesof(/datum/technology))
		var/datum/technology/Tech = new T
		if(all_technologies[Tech.tech_type])
			all_technologies[Tech.tech_type][Tech.id] = Tech
		else
			WARNING("Unknown tech_type '[Tech.tech_type]' in technology '[Tech.name]'")

	for(var/tech_tree_id in tech_trees)
		var/datum/tech/Tech_Tree = tech_trees[tech_tree_id]
		Tech_Tree.maxlevel = 1 + length(all_technologies[tech_tree_id])

	for(var/design_id in design_by_id)
		var/datum/design/D = design_by_id[design_id]
		if(D.starts_unlocked)
			AddDesign2Known(D)

	experiments = new /datum/experiment_data()
	// This is a science station. Most tech is already at least somewhat known.
	experiments.init_known_tech()

/datum/research/proc/IsResearched(datum/technology/T)
	return !!researched_tech[T.id]

/datum/research/proc/CanResearch(datum/technology/T)
	if(T.cost > research_points)
		return FALSE

	for(var/t in T.required_tech_levels)
		var/datum/tech/Tech_Tree = tech_trees[t]
		var/level = T.required_tech_levels[t]

		if(Tech_Tree.level < level)
			return FALSE

	for(var/t in T.required_technologies)
		var/datum/technology/OTech = all_technologies[T.tech_type][t]

		if(!IsResearched(OTech))
			return FALSE

	return TRUE

/datum/research/proc/CanUpgrade(datum/technology/T)
	if(T.reliability_upgrade_cost > research_points)
		return FALSE
	return TRUE

/datum/research/proc/GetReliabilityUpgradeCost(datum/technology/T)
	if(!T.unlocks_designs || !T.unlocks_designs.len)
		return 0

	var/reliability_increase = 0
	var/total_reliability = 0

	for(var/t in T.unlocks_designs)
		reliability_increase += design_reliabilities[t] * (RND_RELIABILITY_EXPONENT ** design_created_prototypes[t])
		total_reliability += design_reliabilities[t]

	var/tech_cost_modifier = 1.0
	if(T.cost > 0.0)
		tech_cost_modifier = T.cost

	return round((tech_cost_modifier * (total_reliability + reliability_increase)) / (100 * T.unlocks_designs.len))

/datum/research/proc/GetAverageDesignReliability(datum/technology/T)
	if(!T.unlocks_designs || !T.unlocks_designs.len)
		return 0

	var/total_reliability = 0

	for(var/id in T.unlocks_designs)
		total_reliability += design_reliabilities[id]

	return round(total_reliability / T.unlocks_designs.len)

/datum/research/proc/UnlockTechology(datum/technology/T, force = FALSE)
	if(IsResearched(T))
		return
	if(!CanResearch(T) && !force)
		return

	researched_tech[T.id] = T
	if(!force)
		research_points -= T.cost
	tech_trees[T.tech_type].level += 1

	for(var/t in T.unlocks_designs)
		var/datum/design/D = design_by_id[t]

		AddDesign2Known(D)

	T.reliability_upgrade_cost = GetReliabilityUpgradeCost(T)
	T.avg_reliability = GetAverageDesignReliability(T)

/datum/research/proc/UpgradeTechology(datum/technology/T, force = FALSE)
	if(!IsResearched(T))
		return

	T.reliability_upgrade_cost = GetReliabilityUpgradeCost(T)

	if(!CanUpgrade(T) && !force)
		return

	if(!force)
		research_points -= T.reliability_upgrade_cost

	for(var/t in T.unlocks_designs)
		design_reliabilities[t] += design_reliabilities[t] * (RND_RELIABILITY_EXPONENT ** design_created_prototypes[t])
		design_reliabilities[t] = max(round(design_reliabilities[t], 5), 1)
		design_created_prototypes[t]++ // Since we don't want to be able to increase it infinitely.

	T.reliability_upgrade_cost = GetReliabilityUpgradeCost(T)
	T.avg_reliability = GetAverageDesignReliability(T)

/datum/research/proc/download_from(datum/research/O)

	for(var/tech_tree_id in O.tech_trees)
		var/datum/tech/Tech_Tree = O.tech_trees[tech_tree_id]
		var/datum/tech/Our_Tech_Tree = tech_trees[tech_tree_id]

		if(Tech_Tree.shown)
			Our_Tech_Tree.shown = Tech_Tree.shown

	for(var/tech_id in O.researched_tech)
		var/datum/technology/T = O.researched_tech[tech_id]
		UnlockTechology(T, force = TRUE)

		for(var/D in T.unlocks_designs)
			if(O.design_reliabilities[D] > design_reliabilities[D]) //check, is the reliability better in the downloadable
				design_reliabilities[D] = O.design_reliabilities[D]
				design_created_prototypes[D] = O.design_created_prototypes[D]

	experiments.merge_with(O.experiments)

/datum/research/proc/forget_techology(datum/technology/T)
	if(!IsResearched(T))
		return
	var/datum/tech/Tech_Tree = tech_trees[T.tech_type]
	if(!Tech_Tree)
		return
	Tech_Tree.level -= 1
	researched_tech -= T.id

	for(var/t in T.unlocks_designs)
		var/datum/design/D = design_by_id[t]
		known_designs -= D

/datum/research/proc/forget_random_technology()
	if(researched_tech.len > 0)
		var/random_tech = pick(researched_tech)
		var/datum/technology/T = researched_tech[random_tech]

		forget_techology(T)

/datum/research/proc/forget_all(tech_type)
	var/datum/tech/Tech_Tree = tech_trees[tech_type]
	if(!Tech_Tree)
		return
	Tech_Tree.level = 1
	for(var/tech_id in researched_tech)
		var/datum/technology/T = researched_tech[tech_id]
		if(T.tech_type == tech_type)
			researched_tech -= tech_id

			for(var/t in T.unlocks_designs)
				var/datum/design/D = design_by_id[t]
				known_designs -= D

/datum/research/proc/AddDesign2Known(datum/design/D)
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
	if(!I.origin_tech.len)
		return

	for(var/tech_tree_id in tech_trees)
		var/datum/tech/T = tech_trees[tech_tree_id]
		if(T.shown || !T.item_tech_req)
			continue

		for(var/item_tech in I.origin_tech)
			if(item_tech == T.item_tech_req)
				T.shown = TRUE
				return

/datum/tech	//Datum of individual technologies.
	var/name = "name"          //Name of the technology.
	var/shortname = "name"
	var/desc = "description"   //General description of what it does and what it makes.
	var/id = "id"              //An easily referenced ID. Must be alphanumeric, lower-case, and no symbols.
	var/level = 1              //A simple number scale of the research level. Level 0 = Secret tech.
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

//Trunk Technologies (don't require any other techs and you start knowning them).
/datum/tech/materials
	name = "Materials Technology"
	shortname = "Materials"
	desc = "The use of materials and their properties."
	id = RESEARCH_MATERIALS

/datum/tech/engineering
	name = "Engineering Research"
	shortname = "Engineering"
	desc = "Development of new and improved engineering parts."
	id = RESEARCH_ENGINEERING

/datum/tech/powerstorage
	name = "Power Manipulation Technology"
	shortname = "Power Manipulation"
	desc = "The various technologies behind the storage and generation of electicity."
	id = RESEARCH_POWERSTORAGE

/datum/tech/bluespace
	name = "'Blue-space' Technology"
	shortname = "Blue-space"
	desc = "Devices that utilize the sub-reality known as 'blue-space'"
	id = RESEARCH_BLUESPACE

/datum/tech/biotech
	name = "Biological Technology"
	shortname = "Biotech"
	desc = "Deeper mysteries of life and organic substances."
	id = RESEARCH_BIOTECH

/datum/tech/magnets
	name = "Magnets"
	shortname = "Magnetic Fields"
	desc = "The use of magnetic fields to manipulate matter."
	id = RESEARCH_MAGNETS

/datum/tech/combat
	name = "Combat Systems"
	shortname = "Combat"
	desc = "Offensive and defensive systems."
	id = RESEARCH_COMBAT

/datum/tech/programming
	name = "Data Theory"
	shortname = "Data Theory"
	desc = "Computer and artificial intelligence and data storage systems."
	id = RESEARCH_DATA

/datum/tech/esoteric
	name = "Esoteric Technology"
	shortname = "Esoteric"
	desc = "A miscellaneous tech category filled with information on non-standard designs, personal projects and half-baked ideas."
	id = RESEARCH_ESOTERIC
	level = 0
	shown = FALSE

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

	var/reliability_upgrade_cost = 0        // Is set after researched, updated each time it is upgraded.
	var/avg_reliability = 0                 // Shows the average reliability of designs in this tech. Is set after researched, updated each time it is upgraded.

	var/list/unlocks_designs = list()       // Ids of designs that this technology unlocks

// Engineering

/datum/technology/basic_engineering
	name = "Basic Engineering"
	desc = "Basic"
	id = "basic_engineering"
	tech_type = RESEARCH_ENGINEERING

	x = 0.1
	y = 0.4
	icon = "wrench"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	//unlocks_designs = list("science_tool", "basic_micro_laser", "basic_matter_bin", "arcademachine", "libraryconsole", "autolathe", "vendor", "light_replacer", "weldingmask", "mesons")

/datum/technology/monitoring
	name = "Monitoring"
	desc = "Monitoring"
	id = "monitoring"
	tech_type = RESEARCH_ENGINEERING

	x = 0.2
	y = 0.4
	icon = "monitoring"

	required_technologies = list("basic_engineering")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("atmosalerts", "air_management")

/datum/technology/ice_and_fire
	name = "Ice And Fire"
	desc = "Ice And Fire"
	id = "ice_and_fire"
	tech_type = RESEARCH_ENGINEERING

	x = 0.2
	y = 0.6
	icon = "spaceheater"

	required_technologies = list("monitoring")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("space_heater", "gasheater", "gascooler")

/datum/technology/adv_engineering
	name = "Advanced Engineering"
	desc = "Advanced Engineering"
	id = "adv_engineering"
	tech_type = RESEARCH_ENGINEERING

	x = 0.3
	y = 0.4
	icon = "rd"

	required_technologies = list("monitoring")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("rdconsole", "rdservercontrol", "rdserver", "destructive_analyzer", "protolathe", "circuit_imprinter", "idcardconsole")
