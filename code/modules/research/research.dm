//[SIERRA-EDIT] - MODPACK_RND

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
#define RESEARCH_ESOTERIC       "illegal"
#define RESEARCH_MAGNETS        "magnets"  //used in robotics
#define RESEARCH_MATERIALS       "materials"

/datum/research								//Holder for all the existing, archived, and known tech. Individual to console.
	var/list/known_designs = list()			//List of available designs (at base reliability).
	var/list/design_by_id = list()
	//Increased by each created prototype with formula: reliability += reliability * (RND_RELIABILITY_EXPONENT^created_prototypes)

	var/list/design_categories_protolathe = list()
	var/list/design_categories_imprinter = list()

	var/list/datum/tech/tech_trees = list() // associative
	var/list/all_technologies = list() // associative
	var/list/researched_tech = list()

	var/datum/experiment_data/experiments
	var/research_points = 0
	var/list/uniquekeys = list()
//[/SIERRA-EDIT] - MODPACK_RND
