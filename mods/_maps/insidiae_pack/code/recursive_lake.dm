/datum/map_template/ruin/exoplanet/recursive_lake
	name = "recursive lake"
	id = "recursive_lake"
	description = "An island in the middle of a lake in the middle of an island in the middle of a lake."
	prefix = "mods/_maps/insidiae_pack/maps/"
	suffixes = list("recursive_lake_base.dmm")
	spawn_cost = 0.5
	template_flags = TEMPLATE_FLAG_CLEAR_CONTENTS | TEMPLATE_FLAG_NO_RUINS
	ruin_tags = RUIN_NATURAL|RUIN_WATER
	skip_main_unit_tests = TRUE

/obj/landmark/map_load_mark/recursive_lake
	name = "random recursive lake"
	templates = list(/datum/map_template/recursive_lake/a, /datum/map_template/recursive_lake/b, /datum/map_template/recursive_lake/c)

/datum/map_template/recursive_lake
	skip_main_unit_tests = TRUE

/datum/map_template/recursive_lake/a
	name = "random recursive lake #1"
	id = "recursive_lake_1"
	mappaths = list("mods/_maps/insidiae_pack/maps/recursive_lake1.dmm")

/datum/map_template/recursive_lake/b
	name = "random recursive lake #2"
	id = "recursive_lake_2"
	mappaths = list("mods/_maps/insidiae_pack/maps/recursive_lake2.dmm")

/datum/map_template/recursive_lake/c
	name = "random recursive lake #3 (tar)"
	id = "recursive_lake_3"
	mappaths = list("mods/_maps/insidiae_pack/maps/recursive_lake3.dmm")
