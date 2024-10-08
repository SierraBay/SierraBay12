#define WEBHOOK_SUBMAP_LOADED_ASCENT_INF "webhook_submap_ascent_inf"

#include "ascent_seedship_areas.dm"
#include "ascent_seedship_jobs.dm"
#include "ascent_seedship_shuttles.dm"

// Map template data.
/datum/map_template/ruin/away_site/ascent_seedship_inf
	name = "Ascent Seedship"
	id = "awaysite_ascent_seedship_inf"
	description = "A small Ascent colony ship."
	prefix = "mods/_maps/ascent_seedship/maps/"
	suffixes = list("ascent_seedship.dmm")
	spawn_cost = 2000 // Отключено до лучших времен. Было 2 ~Laxesh
	spawn_weight = 50 //HABITABLE SHIPS SPAWN
	shuttles_to_initialise = list(
		/datum/shuttle/autodock/overmap/ascent_inf,
		/datum/shuttle/autodock/overmap/ascent_inf/two
	)

// Overmap objects.
/obj/overmap/visitable/ship/ascent_seedship_inf
	name = "Alien Vessel"
	desc = "Wake signature indicates a small to medium sized vessel of unknown design."
	vessel_mass = 6500
	fore_dir = WEST
	max_speed = 0.6/(1 SECOND)
	hide_from_reports = TRUE
	initial_restricted_waypoints = list(
		"Trichopterax" = list("nav_hangar_ascent_inf_one"),
		"Lepidopterax" = list("nav_hangar_ascent_inf_two")
	)

/obj/submap_landmark/joinable_submap/ascent_seedship_inf
	name = "Ascent Colony Ship"
	archetype = /singleton/submap_archetype/ascent_seedship_inf
	submap_datum_type = /datum/submap/ascent_inf

// Submap datum and archetype.
/singleton/webhook/submap_loaded/ascent_inf
	id = WEBHOOK_SUBMAP_LOADED_ASCENT_INF

/singleton/submap_archetype/ascent_seedship_inf
	descriptor = "Ascent Colony Ship"
	map = "Ascent Seedship"
	blacklisted_species = null
	whitelisted_species = null
	crew_jobs = list(
		/datum/job/submap/ascent_inf,
		/datum/job/submap/ascent_inf/alate,
		/datum/job/submap/ascent_inf/drone,
		/datum/job/submap/ascent_inf/monarch_queen,
		/datum/job/submap/ascent_inf/monarch_worker
		//datum/job/submap/ascent_inf/control_mind
	)
	call_webhook = WEBHOOK_SUBMAP_LOADED_ASCENT_INF

#undef WEBHOOK_SUBMAP_LOADED_ASCENT_INF
