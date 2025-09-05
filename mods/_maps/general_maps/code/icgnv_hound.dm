/datum/map_template/ruin/icgnv_hound
	name = "ICGNV Hound"
	id = "icgnv_hound"
	description = "A standard ALFA-pattern, armed ICCGN transport shuttle. The transponder reads on open channels as ICCG and is broadcasting the designation 'ICGNV Hound' in Zurich Accord Common."
	prefix = "mods/_maps/general_maps/maps/"
	suffixes = list("icgnv_hound.dmm")
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/icgnv_hound)
	skip_main_unit_tests = "Ruin has shuttle landmark."
