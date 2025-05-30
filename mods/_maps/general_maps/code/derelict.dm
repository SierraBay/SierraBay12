/datum/map_template/ruin/away_site/derelict
	name = "Derelict Station"
	id = "awaysite_derelict"
	description = "An abandoned construction project."
	prefix = "mods/_maps/general_maps/maps/"
	spawn_cost = 1
	accessibility_weight = 10
	area_usage_test_exempted_areas = list(/area/constructionsite/AIsattele)
	area_usage_test_exempted_root_areas = list(/area/constructionsite, /area/derelict)
	apc_test_exempt_areas = list(
		/area/constructionsite/AIsattele = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/constructionsite = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/constructionsite/ai = NO_SCRUBBER|NO_VENT,
		/area/constructionsite/atmospherics = NO_SCRUBBER|NO_VENT,
		/area/constructionsite/teleporter = NO_SCRUBBER|NO_VENT,
		/area/derelict/ship = NO_SCRUBBER|NO_VENT,
		/area/djstation = NO_SCRUBBER|NO_VENT|NO_APC
	)
	area_coherency_test_subarea_count = list(
		/area/constructionsite = 7,
		/area/constructionsite/maintenance = 14,
		/area/constructionsite/solar = 3,
	)
