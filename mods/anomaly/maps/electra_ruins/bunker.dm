/datum/map_template/ruin/exoplanet/electra_bunker
	name = "science bunker"
	id = "planetsite_anomalies_bunker"
	description = "anomalies lol."
	mappaths = list('mods/anomaly/maps/electra_ruins/bunker.dmm')
	spawn_cost = 1
	ruin_tags = RUIN_ELECTRA_ANOMALIES
	apc_test_exempt_areas = list(
		/area/map_template/bunker = NO_SCRUBBER|NO_VENT|NO_APC
	)

/area/map_template/bunker
	name = "\improper Science bunker"
	icon_state = "A"
	turfs_airless = TRUE

/turf/simulated/wall/titanium/bunker_map/Initialize()
	. = ..()
	name = "Armored titanium wall"

/turf/simulated/wall/titanium/bunker_map/damage_health(damage, damage_type, damage_flags, severity, skip_can_damage_check)
	SHOULD_CALL_PARENT(FALSE)
	return


/turf/simulated/wall/titanium/bunker_map/use_tool(obj/item/W, mob/living/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	return //С этой стеной вообще нельзя взаимодействовать

/obj/item/toy/bronze_pig
	name = "bronze pig"
	desc = "This bronze piglet is the ultimate home decor flex—small, shiny, and ready to oink its way into your heart"
	icon_state = "bronze_pig"
	w_class = ITEM_SIZE_GARGANTUAN
	icon = 'mods/anomaly/icons/pig.dmi'

/obj/item/toy/bronze_pig/Initialize()
	slowdown_per_slot[slot_l_hand] =  5
	slowdown_per_slot[slot_r_hand] =  5

	. = ..()
//Пути ниже требуются дабы не ругался юнит тест Away sites
/obj/item/storage/firstaid/combat/bunker
/obj/item/storage/firstaid/combat/special/bunker
