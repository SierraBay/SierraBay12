/datum/map_template/ruin/away_site/scavver_gantry
	name =  "\improper Salvage Gantry"
	id = "awaysite_gantry"
	description = "Salvage Gantry turned Ship"
	prefix = "mods/_maps/general_maps/maps/"
	spawn_cost = 1
	player_cost = 4
	accessibility_weight = 10
	shuttles_to_initialise = list(
		/datum/shuttle/autodock/overmap/scavver_gantry,
		/datum/shuttle/autodock/overmap/scavver_gantry/two,
		/datum/shuttle/autodock/overmap/scavver_gantry/three,
		/datum/shuttle/autodock/ferry/gantry
	)
	area_usage_test_exempted_root_areas = list(/area/scavver)
	apc_test_exempt_areas = list(
		/area/scavver/yachtdown = NO_SCRUBBER|NO_VENT,
		/area/scavver/yachtup = NO_SCRUBBER|NO_VENT,
		/area/scavver/gantry/down1 = NO_SCRUBBER|NO_VENT,
		/area/scavver/gantry/down2= NO_SCRUBBER|NO_VENT,
		/area/scavver/gantry/up1 = NO_SCRUBBER|NO_VENT,
		/area/scavver/gantry/up2 = NO_SCRUBBER|NO_VENT,
		/area/scavver/gantry/lift = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/scavver/harvestpod = NO_SCRUBBER|NO_VENT
	)
	spawn_weight = 0.67
