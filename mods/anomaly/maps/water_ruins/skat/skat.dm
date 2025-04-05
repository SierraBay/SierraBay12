/datum/map_template/ruin/exoplanet/drowned_skat
	name = "drowned SKAT"
	id = "planetsite_anomalies_flying_home"
	description = "anomalies lol"
	mappaths = list('mods/anomaly/maps/water_ruins/skat/skat-1.dmm')
	spawn_cost = 0
	apc_test_exempt_areas = list(
		/area/map_template/skat = NO_SCRUBBER|NO_VENT|NO_APC
	)
	ruin_tags = RUIN_CHUDO_ANOMALIES
	skip_main_unit_tests = TRUE

/area/map_template/skat
	name = "\improper Drowned ship"
	icon_state = "A"
	turfs_airless = TRUE

/obj/decal/skat_decals
	icon = 'mods/anomaly/icons/wires_and_tubes.dmi'
	mouse_opacity = MOUSE_OPACITY_NORMAL

/obj/decal/skat_decals/water_and_pipes
	icon_state = "wires&pipes"

/obj/decal/skat_decals/wall_left_wires
	icon_state = "wall_left_wires"

/obj/decal/skat_decals/wires_first
	icon_state = "wires1"

/obj/decal/skat_decals/wires_second
	icon_state = "wires2"

/obj/decal/skat_decals/wall_right_leaking_pipe
	icon_state = "wall_right_leaking_pipe"


/obj/structure/broken_cryo/opened
	name = "broken cryo sleeper"
	desc = "This cryo system will never work again."
	icon = 'icons/obj/machines/medical/cryopod.dmi'
	icon_state = "broken_cryo_open"

/obj/structure/broken_cryo/opened/attack_hand(mob/user)
	return

/obj/structure/broken_cryo/opened/use_tool(obj/item/tool, mob/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	return
