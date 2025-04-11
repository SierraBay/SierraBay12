/datum/map_template/ruin/exoplanet/electra_cave
	name = "garage"
	id = "planetsite_anomalies_cave"
	description = "anomalies lol."
	mappaths = list('mods/anomaly/maps/electra_ruins/ice_cave.dmm')
	spawn_cost = 1
	ruin_tags = RUIN_ELECTRA_ANOMALIES

/obj/landmark/corpse/ice_cave
	corpse_outfits = list(/singleton/hierarchy/outfit/ice_science)

/singleton/hierarchy/outfit/ice_science
	name = "Sciencist"
	uniform = /obj/item/clothing/under/tactical
	shoes = /obj/item/clothing/shoes/magboots
	gloves = /obj/item/clothing/gloves/latex
	head = /obj/item/clothing/head/helmet/space/void/ceti/alt
	suit = /obj/item/clothing/suit/space/void/ceti
