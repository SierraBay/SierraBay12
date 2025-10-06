/datum/map_template/ruin/exoplanet/recursive_lake
	name = "recursive lake"
	id = "recursive_lake"
	description = ""
	prefix = "mods/chich_overmap_content/maps/insidiae/"
	suffixes = list("recursive_lake_site.dmm")
	spawn_cost = 0.5
	template_flags = TEMPLATE_FLAG_CLEAR_CONTENTS | TEMPLATE_FLAG_NO_RUINS
	ruin_tags = RUIN_NATURAL|RUIN_WATER

/obj/landmark/map_load_mark/recursive_lake
	name = "random recursive lake"
	templates = list(/datum/map_template/recursive_lake/a, /datum/map_template/recursive_lake/b, /datum/map_template/recursive_lake/c)

/datum/map_template/recursive_lake/a
	name = "random recursive lake #1"
	id = "recursive_lake_1"
	mappaths = list("mods/chich_overmap_content/maps/insidiae/recursive_lake1.dmm")

/datum/map_template/recursive_lake/b
	name = "random recursive lake #2"
	id = "recursive_lake_2"
	mappaths = list("mods/chich_overmap_content/maps/insidiae/recursive_lake2.dmm")

/datum/map_template/recursive_lake/c
	name = "random recursive lake #3 (tar)"
	id = "recursive_lake_3"
	mappaths = list("mods/chich_overmap_content/maps/insidiae/recursive_lake3.dmm")
