/datum/map_template/ruin/sfv_arbiter
	name = "SFV Arbiter"
	id = "arbiter"
	description = "A fairly standard armed transport shuttle belonging to the Sol Fleet. It's transponder reads 'SFV Arbiter'."
	prefix = "mods/_maps/general_maps/maps/"
	suffixes = list("maps/event/sfv_arbiter/sfv_arbiter.dmm")
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/sfv_arbiter)
	skip_main_unit_tests = "Ruin has shuttle landmark."
