/datum/map_template/ruin/exoplanet/drowned_skat_third_deck
	name = "drowned SKAT"
	id = "planetsite_anomalies_flying_home"
	description = "anomalies lol"
	mappaths = list('mods/anomaly/maps/water_ruins/skat/skat-3.dmm')
	spawn_cost = 100000
	ruin_tags = RUIN_CHUDO_ANOMALIES
	apc_test_exempt_areas = list(
		/area/map_template/anomaly/skat_third_deck = NO_SCRUBBER|NO_VENT|NO_APC
	)

/area/map_template/anomaly/skat_third_deck
	name = "\improper SKAT third deck"
	icon_state = "A"
	turfs_airless = TRUE

/obj/item/crab_egg
	name = "blue crab egg"
	desc = "Eggy egg."
	icon = 'mods/ascent/icons/obj/items/egg.dmi'
	icon_state = "egg_single"

/obj/decal/cleanable/blood/crab_sliz
	name = "something blue"
	desc = "Склизкое синее нечто. Кровь? Слизь? Почему оно остаётся не полу под водой?"
	icon = 'icons/effects/blood.dmi'
	basecolor = "#055eee"
	cleanable_scent = null
