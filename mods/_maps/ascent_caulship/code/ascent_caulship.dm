#define WEBHOOK_SUBMAP_LOADED_ASCENT "webhook_submap_ascent"

#include "ascent_caulship_areas.dm"
#include "ascent_caulship_jobs.dm"
#include "ascent_caulship_props.dm"
#include "ascent_caulship_shuttles.dm"

// Map template data.
/datum/map_template/ruin/away_site/ascent_caulship_docking_ring
	name = "Ascent Caulship"
	id = "awaysite_ascent_caulship"
	description = "A small Ascent caulship with a tiny crew."
	prefix = "mods/_maps/ascent_caulship/maps/"
	suffixes = list("ascent_caulship.dmm")
	area_usage_test_exempted_areas = list(
		/area/ship/ascent_caulship
	)
	spawn_cost = 2000
	spawn_weight = 50
	//player_cost = 4 // Нынешнее значение основано на количестве игроков в авейке ~bear1ake
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/ascent)

/obj/overmap/visitable/sector/ascent_caulship_ring
	name = "Ruined Bluespace Jump Ring"
	desc = "A ruined jumpdrive ring of Ascent design, used to transport individual ships at FTL speeds."
	sector_flags = OVERMAP_SECTOR_IN_SPACE
	icon_state = "event"
	hide_from_reports = TRUE
	scannable = TRUE

/obj/submap_landmark/joinable_submap/ascent_caulship
	name = "Ascent Caulship"
	archetype = /singleton/submap_archetype/ascent_caulship
	submap_datum_type = /datum/submap/ascent

// Submap datum and archetype.
/singleton/webhook/submap_loaded/ascent
	id = WEBHOOK_SUBMAP_LOADED_ASCENT

/singleton/submap_archetype/ascent_caulship
	descriptor = "Ascent Caulship"
	map = "Ascent Caulship"
	blacklisted_species = null
	whitelisted_species = null
	crew_jobs = list(
		/datum/job/submap/ascent,
		/datum/job/submap/ascent/alate,
		/datum/job/submap/ascent/drone,
		/datum/job/submap/ascent/worker,
		/datum/job/submap/ascent/queen
	)
	call_webhook = WEBHOOK_SUBMAP_LOADED_ASCENT

/obj/submap_landmark/joinable_submap/ascent_caulship/Initialize(mapload)
	var/list/all_elements = list(
		"Hydrogen",      "Helium",     "Lithium",     "Beryllium",    "Carbon",       "Nitrogen",      "Oxygen",
		"Fluorine",      "Neon",       "Sodium",      "Magnesium",    "Silicon",      "Phosphorus",    "Sulfur",
		"Chlorine",      "Argon",      "Potassium",   "Calcium",      "Scandium",     "Titanium",      "Chromium",
		"Manganese",     "Iron",       "Cobalt",      "Nickel",       "Zinc",         "Gallium",       "Germanium",
		"Arsenic",       "Selenium",   "Bromine",     "Krypton",      "Rubidium",     "Strontium",     "Zirconium",
		"Molybdenum",    "Technetium", "Ruthenium",   "Rhodium",      "Palladium",    "Silver",        "Cadmium",
		"Indium",        "Tin",        "Antimony",    "Tellurium",    "Iodine",       "Xenon",         "Caesium",
		"Barium",        "Lanthanum",  "Cerium",      "Praseodymium", "Neodymium",    "Promethium",    "Samarium",
		"Gadolinium",    "Dysprosium", "Holmium",     "Erbium",       "Ytterbium",    "Hafnium",       "Tantalum",
		"Tungsten",      "Rhenium",    "Osmium",      "Iridium",      "Gold",         "Mercury",       "Lead",
		"Bismuth",       "Polonium",   "Astatine",    "Radon",        "Francium",     "Radium",        "Actinium",
		"Thorium",       "Uranium",    "Plutonium",   "Americium",    "Curium",       "Berkelium",     "Californium",
		"Einsteinium",   "Fermium",    "Mendelevium", "Nobelium",     "Lawrencium",   "Rutherfordium", "Dubnium",
		"Seaborgium",    "Bohrium",    "Hassium",     "Meitnerium",   "Darmstadtium", "Roentgenium",   "Copernicium",
		"Nihonium",      "Flerovium",  "Moscovium",   "Livermorium",  "Tennessine",   "Oganesson"
	)
	name = "[pick(all_elements)]-[rand(10,99)]-[rand(10,99)]"
	. = ..()

#undef WEBHOOK_SUBMAP_LOADED_ASCENT
