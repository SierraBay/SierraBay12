
var/global/list/RDcomputer_list = list()
var/global/list/explosion_watcher_list = list()


/datum/research/New()
	for(var/D in subtypesof(/datum/design))
		var/datum/design/d = new D(src)
		design_by_id[d.id] = d
		var/datum/computer_file/binary/design/design_file = new
		design_file.design = d
		design_file.set_filename(d.shortname)
		d.file = design_file
		d.file.setsize(d)

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
		Tech_Tree.maxlevel = length(all_technologies[tech_tree_id])

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


/datum/research/proc/download_from(datum/research/O)

	for(var/tech_tree_id in O.tech_trees)
		var/datum/tech/Tech_Tree = O.tech_trees[tech_tree_id]
		var/datum/tech/Our_Tech_Tree = tech_trees[tech_tree_id]

		if(Tech_Tree.shown)
			Our_Tech_Tree.shown = Tech_Tree.shown

	for(var/tech_id in O.researched_tech)
		var/datum/technology/T = O.researched_tech[tech_id]
		UnlockTechology(T, force = TRUE)

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
	if(LAZYLEN(researched_tech) > 0)
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
	if(!LAZYLEN(I.origin_tech))
		return

	for(var/tech_tree_id in tech_trees)
		var/datum/tech/T = tech_trees[tech_tree_id]
		if(T.shown || !T.item_tech_req)
			continue

		for(var/item_tech in I.origin_tech)
			if(item_tech == T.item_tech_req)
				T.shown = TRUE
				return


/datum/research/proc/AddSciPoints(datum/computer_file/binary/sci/D)
	if(D.uniquekey in uniquekeys)
		return 0
	uniquekeys += D.uniquekey
	return (rand(500, 1000) * D.size)


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
	name = "Robotics"
	shortname = "Robotics"
	desc = "The use of magnetic fields to make electrical devices."
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
