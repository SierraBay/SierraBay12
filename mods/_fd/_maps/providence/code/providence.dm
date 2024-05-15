// Map template data.
/datum/map_template/ruin/away_site/providence
	name = "IPV Providence"
	id = "awaysite_trucker"
	description = "."
	prefix = "mods/_fd/_maps/providence/maps/"
	suffixes = list("providence.dmm")
	spawn_cost = 1
	area_usage_test_exempted_root_areas = /area/ship/providence
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/providence)

/obj/overmap/visitable/sector/providence
	name = "Bluespace Residue"
	desc = "/ERROR/."
	icon_state = "event"
	hide_from_reports = TRUE
	sector_flags = OVERMAP_SECTOR_IN_SPACE | OVERMAP_SECTOR_UNTARGETABLE

/obj/submap_landmark/joinable_submap/providence
	name = "ITV Providence"
	archetype = /singleton/submap_archetype/providence
