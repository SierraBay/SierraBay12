/obj/overmap/visitable/sector/battlefield
	name = "small desert exoplanet"
	desc = "A small rocky sandy exoplanet with artificial objects."
	icon_state = "globe"

/datum/map_template/ruin/away_site/battlefield
	name = "Small desert exoplanet"
	id = "awaysite_battlefield"
	description = "Small sandy exoplanet with battle field on the surface."
	mappaths = list('mods/_events/battlefield_event/battlefield.dmm')
	spawn_cost = 50
	accessibility_weight = 30
	area_usage_test_exempted_root_areas = list(/area/battlefield)
	apc_test_exempt_areas = list(
		/area/battlefield/energy = NO_SCRUBBER|NO_VENT,
		/area/battlefield/camp = NO_SCRUBBER|NO_VENT,
		/area/battlefield/surface = NO_SCRUBBER|NO_VENT|NO_APC
	)

// Зоны (Areas)
/area/battlefield/energy
	name = "\improper SCG Camp Energy Sector"
	icon_state = "yellow"

/area/battlefield/camp
	name = "\improper SCG Camp"
	icon_state = "green"
	ambience = list('sound/ambience/shipambience.ogg')

/area/battlefield/surface
	name = "\improper Planet Surface"
	icon_state = "purple"
	ambience = list('sound/ambience/bluespace_interlude_ambience.ogg')

/area/battlefield/ship
	name = "\improper ICCG Crush Site"
	icon_state = "blue-red"
	ambience = list('sound/ambience/shipambience.ogg')


// Навигационные точки для посадки (Navpoints)
/obj/shuttle_landmark/battlefield/nav1
	name = "Ravine landing zone"
	landmark_tag = "nav_battlefield_1"
	base_area = /area/battlefield/surface
	base_turf = /turf/simulated/floor/exoplanet/desert
